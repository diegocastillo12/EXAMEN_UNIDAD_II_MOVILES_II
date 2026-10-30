import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_entrehuellas/core/presentation/widgets/confirmation_toast.dart';

void main() {
  final toast = find.byKey(const ValueKey('feedback-toast'));
  Future<void> mountToast(
    WidgetTester tester, {
    bool reduced = false,
    VoidCallback? onAction,
    String message = 'Cambios guardados',
    Size size = const Size(390, 844),
    double textScale = 1,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
            padding: const EdgeInsets.only(top: 24),
            disableAnimations: reduced,
          ),
          child: Scaffold(
            body: ConfirmationToastHost(
              confirmed: true,
              message: message,
              actionLabel: onAction == null ? null : 'Reintentar',
              onAction: onAction,
              child: const Text('Contenido'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    'Web parity: enters from offscreen, regular type, animated upward exit',
    (tester) async {
      await mountToast(tester);
      expect(tester.getRect(toast).bottom, lessThanOrEqualTo(0));
      await tester.pump(const Duration(milliseconds: 140));
      expect(tester.getTopLeft(toast).dy, lessThan(36));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(toast).dy, closeTo(36, .01));
      expect(
        tester.widget<Text>(find.text('Cambios guardados')).style!.fontWeight,
        FontWeight.w400,
      );
      await tester.tap(toast);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(tester.getTopLeft(toast).dy, lessThan(36));
      expect(toast, findsOneWidget);
      await tester.pumpAndSettle();
      expect(toast, findsNothing);
    },
  );

  for (final reduced in [false, true]) {
    testWidgets(
      'Whole surface follows upward drag and dismisses; reduced=$reduced',
      (tester) async {
        await mountToast(tester, reduced: reduced);
        await tester.pumpAndSettle();
        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Cambios guardados')),
        );
        await gesture.moveBy(
          const Offset(0, -24),
          timeStamp: const Duration(milliseconds: 200),
        );
        await tester.pump();
        expect(tester.getTopLeft(toast).dy, closeTo(12, .01));
        await gesture.moveBy(
          const Offset(0, -24),
          timeStamp: const Duration(milliseconds: 400),
        );
        await gesture.up(timeStamp: const Duration(milliseconds: 450));
        await tester.pumpAndSettle();
        expect(toast, findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final delta in [-20.0, 80.0]) {
    testWidgets(
      'Short or downward drag rebounds without accidental tap: $delta',
      (tester) async {
        await mountToast(tester);
        await tester.pumpAndSettle();
        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Cambios guardados')),
        );
        await gesture.moveBy(
          Offset(0, delta),
          timeStamp: const Duration(seconds: 1),
        );
        await tester.pump();
        expect(
          tester.getTopLeft(toast).dy,
          closeTo(36 + (delta < 0 ? delta : 12), .01),
        );
        await gesture.up(timeStamp: const Duration(seconds: 2));
        await tester.pumpAndSettle();
        expect(tester.getTopLeft(toast).dy, closeTo(36, .01));
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets(
    'Fast short upward flick dismisses and cancellation returns to rest',
    (tester) async {
      await mountToast(tester);
      await tester.pumpAndSettle();
      var gesture = await tester.startGesture(
        tester.getCenter(find.text('Cambios guardados')),
      );
      await gesture.moveBy(
        const Offset(0, -24),
        timeStamp: const Duration(milliseconds: 20),
      );
      await gesture.cancel(timeStamp: const Duration(milliseconds: 30));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(toast).dy, closeTo(36, .01));
      gesture = await tester.startGesture(
        tester.getCenter(find.text('Cambios guardados')),
      );
      await gesture.moveBy(
        const Offset(0, -24),
        timeStamp: const Duration(milliseconds: 20),
      );
      await gesture.up(timeStamp: const Duration(milliseconds: 30));
      await tester.pumpAndSettle();
      expect(toast, findsNothing);
    },
  );

  testWidgets('Holding pauses expiry; release resets the web 6500ms duration', (
    tester,
  ) async {
    await mountToast(tester);
    await tester.pumpAndSettle();
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Cambios guardados')),
    );
    await tester.pump(const Duration(seconds: 8));
    expect(toast, findsOneWidget);
    await gesture.moveBy(
      const Offset(0, 60),
      timeStamp: const Duration(seconds: 8),
    );
    await gesture.up(timeStamp: const Duration(seconds: 9));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    expect(toast, findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(toast, findsNothing);
  });

  testWidgets(
    'Dragging the retry action never invokes it; a tap invokes it once after exit',
    (tester) async {
      var actions = 0;
      await mountToast(tester, onAction: () => actions++);
      await tester.pumpAndSettle();
      await tester.drag(find.text('Reintentar'), const Offset(0, -60));
      await tester.pumpAndSettle();
      expect(actions, 0);
      expect(toast, findsNothing);
      await tester.pumpWidget(const SizedBox());
      await mountToast(tester, onAction: () => actions++);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(actions, 1);
      expect(toast, findsNothing);
    },
  );

  testWidgets('Escape dismisses when the notice has keyboard focus', (
    tester,
  ) async {
    await mountToast(tester);
    await tester.pumpAndSettle();
    Focus.of(tester.element(find.text('Cambios guardados'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(toast, findsNothing);
  });

  testWidgets(
    'Overflow keeps text scrollable and the icon still dismisses by swipe',
    (tester) async {
      await mountToast(
        tester,
        size: const Size(320, 350),
        textScale: 2,
        message:
            'No pudimos confirmar la operación. Conservamos los datos para reintentar sin duplicar el envío.',
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(toast).height, lessThanOrEqualTo(105));
      final scroll = tester
          .widget<SingleChildScrollView>(
            find.descendant(
              of: toast,
              matching: find.byType(SingleChildScrollView),
            ),
          )
          .controller!;
      expect(scroll.position.maxScrollExtent, greaterThan(0));
      final gesture = await tester.startGesture(
        tester.getCenter(find.byIcon(Icons.check_rounded)),
      );
      final initialY = tester.getTopLeft(toast).dy;
      await gesture.moveBy(
        const Offset(0, -24),
        timeStamp: const Duration(seconds: 1),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.getTopLeft(toast).dy, closeTo(initialY - 24, .01));
      await gesture.moveBy(
        const Offset(0, -36),
        timeStamp: const Duration(seconds: 2),
      );
      await gesture.up(timeStamp: const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(toast, findsNothing);
    },
  );

  testWidgets('Replacing a held notice releases the old gesture and timer', (
    tester,
  ) async {
    var notice = 0;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return ConfirmationToastHost(
                confirmed: true,
                noticeId: notice,
                message: 'Aviso $notice',
                child: const Text('Contenido'),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Aviso 0')),
    );
    await gesture.moveBy(
      const Offset(0, -24),
      timeStamp: const Duration(seconds: 1),
    );
    await tester.pump();
    update(() => notice++);
    await tester.pumpAndSettle();
    await gesture.up(timeStamp: const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Aviso 0'), findsNothing);
    expect(find.text('Aviso 1'), findsOneWidget);
    expect(toast, findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 8));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'Long scaled toast scrolls in bounded area and dismisses from its surface',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 350));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const message =
          'No pudimos confirmar la operación. Conservamos los datos para reintentar sin duplicar el envío.';
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(320, 350),
              textScaler: TextScaler.linear(2),
            ),
            child: Scaffold(
              body: ConfirmationToastHost(
                confirmed: true,
                message: message,
                isError: true,
                child: Text('Contenido conservado'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final toast = find.byKey(const ValueKey('feedback-toast'));
      expect(tester.getRect(toast).height, lessThanOrEqualTo(110));
      final scroll = find.descendant(
        of: toast,
        matching: find.byType(SingleChildScrollView),
      );
      final controller = tester
          .widget<SingleChildScrollView>(scroll)
          .controller!;
      expect(controller.position.maxScrollExtent, greaterThan(0));
      await tester.drag(scroll, const Offset(0, -180));
      await tester.pumpAndSettle();
      expect(controller.offset, greaterThan(0));
      expect(find.text('Contenido conservado'), findsOneWidget);
      await tester.tap(toast);
      await tester.pumpAndSettle();
      expect(find.text(message), findsNothing);
    },
  );

  testWidgets(
    'A new screen notice replaces the photo notice without stacking',
    (tester) async {
      var failed = false;
      var showPhoto = true;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return ConfirmationToastHost(
                  confirmed: failed,
                  isError: true,
                  message: 'Publicación rechazada',
                  child: showPhoto
                      ? const ConfirmationToastHost(
                          confirmed: true,
                          isError: true,
                          message: 'Foto no disponible',
                          child: Icon(Icons.broken_image_outlined),
                        )
                      : const SizedBox(),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Foto no disponible'), findsOneWidget);
      update(() => failed = true);
      await tester.pumpAndSettle();
      expect(find.text('Foto no disponible'), findsNothing);
      expect(find.text('Publicación rechazada'), findsOneWidget);
      update(() => showPhoto = false);
      await tester.pumpAndSettle();
      expect(find.text('Publicación rechazada'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 4));
      expect(find.text('Publicación rechazada'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Error notices repeat by event, conflict action dismisses and disposal clears overlay',
    (tester) async {
      var active = false;
      var noticeId = 0;
      var actions = 0;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return ConfirmationToastHost(
                  confirmed: active,
                  noticeId: noticeId,
                  isError: true,
                  message: 'La ficha cambió.',
                  actionLabel: 'Actualizar lista',
                  onAction: () => actions++,
                  child: const Text('Lista'),
                );
              },
            ),
          ),
        ),
      );
      update(() {
        active = true;
        noticeId++;
      });
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      await tester.tap(find.text('La ficha cambió.'));
      await tester.pumpAndSettle();
      expect(find.text('La ficha cambió.'), findsNothing);
      update(() => noticeId++);
      await tester.pumpAndSettle();
      expect(find.text('La ficha cambió.'), findsOneWidget);
      await tester.tap(find.text('Actualizar lista'));
      await tester.pumpAndSettle();
      expect(actions, 1);
      expect(find.text('La ficha cambió.'), findsNothing);
      update(() => noticeId++);
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 8));
      expect(find.text('La ficha cambió.'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  for (final reduced in [false, true]) {
    testWidgets(
      'Confirmation only appears on a new success, dismisses and disposes; reduced=$reduced',
      (tester) async {
        var confirmed = false;
        late StateSetter change;
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                disableAnimations: reduced,
                size: const Size(320, 350),
                textScaler: const TextScaler.linear(2),
              ),
              child: Scaffold(
                body: StatefulBuilder(
                  builder: (context, update) {
                    change = update;
                    return ConfirmationToastHost(
                      confirmed: confirmed,
                      message: 'Cambios guardados',
                      child: const Text('Contenido'),
                    );
                  },
                ),
              ),
            ),
          ),
        );
        expect(find.text('Cambios guardados'), findsNothing);
        change(() => confirmed = true);
        await tester.pumpAndSettle();
        expect(find.text('Cambios guardados'), findsOneWidget);
        expect(find.text('Contenido'), findsOneWidget);
        change(() {});
        await tester.pumpAndSettle();
        expect(find.text('Cambios guardados'), findsOneWidget);
        await tester.tap(find.text('Cambios guardados'));
        await tester.pumpAndSettle();
        expect(find.text('Cambios guardados'), findsNothing);
        change(() {});
        await tester.pumpAndSettle();
        expect(find.text('Cambios guardados'), findsNothing);
        change(() => confirmed = false);
        await tester.pump();
        change(() => confirmed = true);
        await tester.pumpAndSettle();
        expect(find.text('Cambios guardados'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 8));
        expect(find.text('Cambios guardados'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
