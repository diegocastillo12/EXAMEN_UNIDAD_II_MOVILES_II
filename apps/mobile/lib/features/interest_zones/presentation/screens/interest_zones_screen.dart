import '../../../../core/theme/app_typography.dart';
import '../../../../core/presentation/widgets/app_scaffold.dart';
import '../../../../core/presentation/widgets/scroll_safe_area.dart';
import '../../../../core/presentation/widgets/pull_to_refresh.dart';
import '../../../../core/presentation/widgets/content_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/cover_reveal.dart';
import '../../../../core/presentation/widgets/glass_navigation_button.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../domain/entities/interest_zone.dart';
import '../../domain/failures/zone_failure.dart';
import '../state/zone_view_state.dart';
import '../view_models/interest_zones_view_model.dart';
import '../widgets/zone_editor.dart';
import '../widgets/zone_confirmation_dialog.dart';

class InterestZonesScreen extends ConsumerStatefulWidget {
  const InterestZonesScreen({this.followActionBuilder, super.key});
  final Widget Function(String id)? followActionBuilder;
  @override
  ConsumerState<InterestZonesScreen> createState() =>
      _InterestZonesScreenState();
}

class _InterestZonesScreenState extends ConsumerState<InterestZonesScreen> {
  final _scroll = ScrollController();
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(interestZonesViewModelProvider, (previous, next) {
      final before = previous?.asData?.value;
      final after = next.asData?.value;
      if (after != null &&
          !next.isLoading &&
          (before?.draft?.id != after.draft?.id ||
              before?.ownerId != after.ownerId)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scroll.hasClients) _scroll.jumpTo(0);
        });
      }
    });
    final async = ref.watch(interestZonesViewModelProvider);
    // Provider rebuilds hide any retained data, including while identity is resolving.
    final data = async.isLoading || async.hasError ? null : async.asData?.value;
    final vm = ref.read(interestZonesViewModelProvider.notifier);
    Future<void> back() async {
      if (data?.busy == true) return;
      if (data?.draft != null) {
        if (await confirmZoneAction(
          context,
          '¿Descartar cambios?',
          'La selección sin guardar se perderá.',
          'Descartar',
        )) {
          if (context.mounted) vm.discard();
        }
      } else if (context.mounted) {
        context.pop();
      }
    }

    return ConfirmationToastHost(
      confirmed:
          async.hasError || data?.issue != null || data?.confirmation != null,
      isError: async.hasError || data?.issue != null,
      message: async.hasError
          ? 'No se pudieron consultar tus ubicaciones.'
          : data?.issue != null
          ? zoneFailureLabel(data!.issue!)
          : data?.confirmation ?? '',
      noticeId: (data?.ownerId, data?.noticeId, data?.errorId, async.error),
      child: PopScope(
        canPop: data?.busy != true && data?.draft == null,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) back();
        },
        child: AppScaffold(
          body: ScrollSafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PullToRefresh(
                      indicatorTop: MediaQuery.paddingOf(context).top + 8,
                      enabled:
                          !async.isLoading &&
                          data != null &&
                          data.draft == null &&
                          !data.busy &&
                          !data.refreshing,
                      onRefresh: vm.refresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: _scroll,
                        padding: EdgeInsets.fromLTRB(
                          24,
                          MediaQuery.paddingOf(context).top + 80,
                          24,
                          ScrollSafeArea.bottomPadding(context, 32),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Ubicaciones de interés',
                              style: AppTypography.primaryTitle,
                            ),
                            const SizedBox(height: 20),
                            AuthStageTransition(
                              enabled: !async.isLoading,
                              startCovered: true,
                              stage: data?.draft?.id ?? 'list',
                              builder: (play) => ContentReveal(
                                loading: async.isLoading,
                                count: 2,
                                play: play,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    StaggerRevealItem(
                                      order: 0,
                                      child: async.isLoading
                                          ? LoadingShimmer(
                                              isLoading: true,
                                              loadingLabel:
                                                  'Consultando ubicaciones',
                                              child: const SkeletonFormFields(
                                                fieldCount: 3,
                                              ),
                                            )
                                          : async.hasError
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                TextButton(
                                                  onPressed: vm.retry,
                                                  child: const Text(
                                                    'Reintentar',
                                                  ),
                                                ),
                                              ],
                                            )
                                          : data == null
                                          ? const SizedBox.shrink()
                                          : data.draft != null
                                          ? ZoneEditor(
                                              key: ValueKey(data.draft!.id),
                                              state: data,
                                            )
                                          : ContentRefresh(
                                              refreshing: data.refreshing,
                                              label: 'Actualizando ubicaciones',
                                              child: _list(context, vm, data),
                                            ),
                                    ),
                                    if (data?.issue != null &&
                                        data!.issue !=
                                            ZoneFailureKind.invalidName &&
                                        data.issue !=
                                            ZoneFailureKind.invalidPoint)
                                      StaggerRevealItem(
                                        order: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 16,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              if (data.issue ==
                                                      ZoneFailureKind
                                                          .conflict ||
                                                  data.issue ==
                                                      ZoneFailureKind
                                                          .unavailable)
                                                TextButton(
                                                  onPressed: () async {
                                                    if (data.draft == null ||
                                                        await confirmZoneAction(
                                                          context,
                                                          '¿Consultar versión actual?',
                                                          'Se descartará la edición sin guardar.',
                                                          'Consultar',
                                                        )) {
                                                      if (context.mounted) {
                                                        vm.retry();
                                                      }
                                                    }
                                                  },
                                                  child: const Text(
                                                    'Consultar versión actual',
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.paddingOf(context).top + 4,
                      left: 24,
                      child: GlassNavigationButton(
                        tooltip: data?.draft != null
                            ? 'Volver a mis ubicaciones'
                            : 'Volver al perfil',
                        icon: Icons.chevron_left_rounded,
                        onPressed: data?.busy == true ? null : back,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _list(
    BuildContext context,
    InterestZonesViewModel vm,
    ZoneViewState data,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'Elige dónde quieres consultar novedades. No necesitas activar tu ubicación.',
        style: TextStyle(fontSize: 16, height: 1.4, color: Color(0xFF6E6E73)),
      ),
      const SizedBox(height: 20),
      if (data.zones.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'Todavía no tienes ubicaciones de interés.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      for (final zone in data.zones) _row(context, vm, data, zone),
      const SizedBox(height: 16),
      FilledButton(
        style: primaryActionButtonStyle(context),
        onPressed: data.busy || data.refreshing ? null : () => vm.startEditor(),
        child: const Text('Añadir ubicación'),
      ),
    ],
  );
  Widget _row(
    BuildContext context,
    InterestZonesViewModel vm,
    ZoneViewState data,
    InterestZone zone,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            zone.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Radio de ${(zone.radiusMeters / 1000).toStringAsFixed(1)} km',
            style: const TextStyle(color: Color(0xFF6E6E73)),
          ),
          Wrap(
            spacing: 12,
            children: [
              if (widget.followActionBuilder != null)
                widget.followActionBuilder!(zone.id),
              TextButton(
                onPressed: data.busy || data.refreshing
                    ? null
                    : () => vm.startEditor(zone),
                child: const Text('Editar'),
              ),
              LoadingShimmer(
                isLoading: data.busy && data.busyZoneId == zone.id,
                loadingLabel: 'Procesando ubicación',
                radius: 18,
                child: TextButton(
                  onPressed: data.busy || data.refreshing
                      ? null
                      : () async {
                          if (await confirmZoneAction(
                            context,
                            '¿Eliminar ubicación?',
                            'Dejarás de usar «${zone.name}» como ubicación de interés.',
                            'Eliminar',
                          )) {
                            if (context.mounted) await vm.delete(zone);
                          }
                        },
                  child: const Text(
                    'Eliminar',
                    style: TextStyle(color: Color(0xFFB53F48)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

String zoneFailureLabel(ZoneFailureKind kind) => switch (kind) {
  ZoneFailureKind.invalidName =>
    'Escribe un nombre de ubicación de 1 a 60 caracteres.',
  ZoneFailureKind.invalidPoint =>
    'Selecciona un punto válido en el mapa o indica sus coordenadas.',
  ZoneFailureKind.invalidRadius => 'El radio debe estar entre 0.1 y 50 km.',
  ZoneFailureKind.conflict =>
    'La ubicación cambió en otro dispositivo. Consulta la versión actual antes de volver a editar.',
  ZoneFailureKind.signedOut => 'Tu sesión cambió. Vuelve a ingresar.',
  ZoneFailureKind.unavailable =>
    'La ubicación no está disponible. Consulta tus ubicaciones actuales.',
  ZoneFailureKind.network =>
    'No se pudo completar la operación. Tus cambios se conservan; puedes reintentar.',
};
