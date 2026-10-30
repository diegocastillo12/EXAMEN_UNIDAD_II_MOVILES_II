import '../../../../core/presentation/widgets/panel_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/glass_navigation_button.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../domain/entities/saved_case_ref.dart';
import '../view_models/saved_case_view_model.dart';

class SaveCaseButton extends ConsumerWidget {
  const SaveCaseButton({required this.target, this.inPanel = false, super.key});
  final SavedCaseRef target;
  final bool inPanel;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(savedCaseViewModelProvider(target));
    final value = async.isLoading || async.hasError
        ? null
        : async.asData?.value;
    final model = ref.read(savedCaseViewModelProvider(target).notifier);
    final busy = async.isLoading || value?.busy == true;
    final saved = value?.mark.saved == true;
    final retry = async.hasError || value?.reloadRequired == true;
    final label = retry
        ? 'Reintentar consulta de guardado'
        : value?.error == true
        ? 'Reintentar guardado'
        : saved
        ? 'Quitar de favoritos'
        : 'Añadir a favoritos';
    final icon = saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded;
    final VoidCallback? onPressed = busy
        ? null
        : retry
        ? model.retry
        : model.toggle;
    return ConfirmationToastHost(
      confirmed: async.hasError || value?.notice != null,
      isError: async.hasError || value?.error == true,
      noticeId: (target, async.error, value?.owner, value?.noticeId),
      message: async.hasError
          ? 'No pudimos consultar si guardaste este caso. Toca el marcador para reintentar.'
          : value?.notice ?? '',
      child: Semantics(
        toggled: value == null ? null : saved,
        child: LoadingShimmer(
          isLoading: busy,
          loadingLabel: async.isLoading
              ? 'Consultando caso guardado'
              : 'Actualizando guardado',
          radius: 26,
          child: inPanel
              ? PanelActionButton(
                  onPressed: onPressed,
                  icon: icon,
                  label: label,
                )
              : GlassNavigationButton(
                  tooltip: retry
                      ? 'Reintentar consulta de guardado'
                      : value?.error == true
                      ? 'Reintentar guardado'
                      : saved
                      ? 'Quitar de guardados'
                      : 'Guardar caso',
                  icon: saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  onPressed: busy
                      ? null
                      : retry
                      ? model.retry
                      : model.toggle,
                ),
        ),
      ),
    );
  }
}
