import 'package:flutter/material.dart';
import 'origin_dialog_transition.dart';
import 'popup_dialog_transition.dart';

Future<bool> confirmActionDialog(
  BuildContext context, {
  required String title,
  required String description,
  required String action,
  String cancelLabel = 'Cancelar',
  String? semanticLabel,
  bool destructive = true,
  Rect? origin,
  Widget? source,
}) async =>
    await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : Duration(milliseconds: origin == null ? 160 : 320),
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          origin == null
          ? PopupDialogTransition(animation: animation, child: child)
          : OriginDialogTransition(
              animation: animation,
              origin: origin,
              source: source,
              child: child,
            ),
      pageBuilder: (context, animation, secondaryAnimation) => Semantics(
        scopesRoute: true,
        namesRoute: true,
        label: semanticLabel ?? title,
        explicitChildNodes: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _ConfirmationHeader(title: title),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6E6E73),
                  ),
                ),
                const SizedBox(height: 24),
                _ConfirmationActions(
                  action: action,
                  cancelLabel: cancelLabel,
                  destructive: destructive,
                ),
              ],
            ),
          ),
        ),
      ),
    ) ??
    false;

class _ConfirmationHeader extends StatelessWidget {
  const _ConfirmationHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const style = TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111111),
      );
      final painter = TextPainter(
        text: TextSpan(text: title.split(' ').first, style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      final stacked = painter.width + 48 > constraints.maxWidth;
      painter.dispose();
      final heading = Text(title, style: style);
      final close = IconButton(
        tooltip: 'Cerrar confirmación',
        onPressed: () => Navigator.pop(context, false),
        icon: const Icon(Icons.close_rounded, color: Color(0xFF6E6E73)),
      );
      return stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(alignment: Alignment.centerRight, child: close),
                heading,
              ],
            )
          : Row(
              children: [
                Expanded(child: heading),
                close,
              ],
            );
    },
  );
}

class _ConfirmationActions extends StatelessWidget {
  const _ConfirmationActions({
    required this.action,
    required this.cancelLabel,
    required this.destructive,
  });
  final String action;
  final String cancelLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const textStyle = TextStyle(
        fontFamily: 'sans-serif',
        fontSize: 14,
        height: 1.3,
        fontWeight: FontWeight.w600,
      );
      final scaler = MediaQuery.textScalerOf(context);
      final direction = Directionality.of(context);
      final painter = TextPainter(
        text: TextSpan(text: action, style: textStyle),
        textDirection: direction,
        textScaler: scaler,
      )..layout();
      var preferredWidth = painter.width + 16;
      painter.text = TextSpan(text: cancelLabel, style: textStyle);
      painter.layout();
      if (painter.width + 16 > preferredWidth) {
        preferredWidth = painter.width + 16;
      }
      final sideBySide = preferredWidth * 2 + 8 <= constraints.maxWidth;
      final width = preferredWidth.clamp(0.0, constraints.maxWidth);
      painter.layout(maxWidth: width - 16);
      var height = (painter.height + 16).clamp(48.0, double.infinity);
      painter.text = TextSpan(text: action, style: textStyle);
      painter.layout(maxWidth: width - 16);
      height = (painter.height + 16).clamp(height, double.infinity);
      painter.dispose();
      final style = ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        textStyle: const WidgetStatePropertyAll(textStyle),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      );
      final cancel = SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          style: style.copyWith(
            foregroundColor: const WidgetStatePropertyAll(Color(0xFF111111)),
            side: const WidgetStatePropertyAll(
              BorderSide(color: Color(0xFFE5E5EA)),
            ),
          ),
          child: Text(cancelLabel, textAlign: TextAlign.center),
        ),
      );
      final delete = SizedBox(
        width: width,
        height: height,
        child: FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: style.copyWith(
            backgroundColor: WidgetStatePropertyAll(
              destructive ? const Color(0xFFF9ECEE) : const Color(0xFF111111),
            ),
            foregroundColor: WidgetStatePropertyAll(
              destructive ? const Color(0xFFB53F48) : Colors.white,
            ),
          ),
          child: Text(action, textAlign: TextAlign.center),
        ),
      );
      return Align(
        alignment: Alignment.bottomRight,
        child: sideBySide
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [cancel, const SizedBox(width: 8), delete],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [cancel, const SizedBox(height: 8), delete],
              ),
      );
    },
  );
}
