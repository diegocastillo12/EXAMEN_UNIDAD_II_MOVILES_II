import '../../../../core/theme/app_typography.dart';
import '../../../../core/presentation/widgets/app_scaffold.dart';
import '../../domain/failures/preference_failure.dart';
import '../../../../core/presentation/widgets/scroll_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/confirm_discard_action.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/cover_reveal.dart';
import '../../../../core/presentation/widgets/glass_navigation_button.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../view_models/alert_preferences_view_model.dart';
import '../widgets/preference_options.dart';

class AlertPreferencesScreen extends ConsumerWidget {
  const AlertPreferencesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(alertPreferencesViewModelProvider);
    final data = async.isLoading || async.hasError ? null : async.asData?.value;
    final vm = ref.read(alertPreferencesViewModelProvider.notifier);
    Future<void> back() async {
      if (data?.busy == true) return;
      if (data?.dirty == true) {
        if (!await confirmDiscardAction(
          context,
          '¿Descartar cambios?',
          'Tu selección sin guardar se perderá.',
          'Descartar',
        )) {
          return;
        }
        if (!context.mounted) return;
        vm.discard();
      }
      if (context.mounted) context.pop();
    }

    return ConfirmationToastHost(
      confirmed:
          async.hasError || data?.issue != null || data?.confirmed == true,
      isError: async.hasError || data?.issue != null,
      message: async.hasError
          ? 'No se pudieron consultar tus preferencias.'
          : data?.issue != null
          ? preferenceFailureLabel(data!.issue!)
          : 'Preferencias guardadas',
      noticeId: (data?.saved.ownerId, data?.noticeId, data?.issue, async.error),
      child: PopScope(
        canPop: data?.busy != true && data?.dirty != true,
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
                    SingleChildScrollView(
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
                            'Preferencias de alertas',
                            style: AppTypography.primaryTitle,
                          ),
                          const SizedBox(height: 20),
                          AuthStageTransition(
                            enabled: !async.isLoading,
                            startCovered: true,
                            stage: 'preferences',
                            builder: (play) => ContentReveal(
                              loading: async.isLoading,
                              play: play,
                              count: 4,
                              child: async.isLoading
                                  ? const LoadingShimmer(
                                      isLoading: true,
                                      loadingLabel: 'Consultando preferencias',
                                      child: SkeletonFormFields(fieldCount: 4),
                                    )
                                  : async.hasError
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        TextButton(
                                          onPressed: vm.retry,
                                          child: const Text('Reintentar'),
                                        ),
                                      ],
                                    )
                                  : data == null
                                  ? const SizedBox.shrink()
                                  : PreferenceOptions(state: data),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.paddingOf(context).top + 4,
                      left: 24,
                      child: GlassNavigationButton(
                        tooltip: 'Volver al perfil',
                        icon: Icons.chevron_left_rounded,
                        onPressed: data?.busy == true ? null : back,
                      ),
                    ),
                    if (data?.refreshing == true)
                      Positioned(
                        top: MediaQuery.paddingOf(context).top + 64,
                        left: 24,
                        right: 24,
                        child: const LoadingShimmer(
                          isLoading: true,
                          loadingLabel: 'Actualizando preferencias',
                          radius: 2,
                          child: SizedBox(
                            height: 2,
                            width: double.infinity,
                            child: ColoredBox(color: Color(0xFFE5E5EA)),
                          ),
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
}

String preferenceFailureLabel(PreferenceFailureKind kind) => switch (kind) {
  PreferenceFailureKind.invalidTypes =>
    'Elige al menos un tipo de aviso o desactiva Recibir alertas.',
  PreferenceFailureKind.invalidChannels =>
    'Elige al menos un canal o desactiva Recibir alertas.',
  PreferenceFailureKind.conflict =>
    'Las preferencias cambiaron en otro dispositivo. Consulta la versión actual antes de volver a guardar.',
  PreferenceFailureKind.signedOut =>
    'Tu sesión cambió. Vuelve a ingresar para guardar.',
  PreferenceFailureKind.unavailable =>
    'No se pudo completar la operación. Tu selección se conserva; puedes reintentar.',
};
