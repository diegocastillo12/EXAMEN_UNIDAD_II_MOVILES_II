import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/confirm_action_dialog.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../view_models/clear_offline_lists_view_model.dart';

class ClearOfflineListsButton extends ConsumerWidget {
  const ClearOfflineListsButton({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clearOfflineListsViewModelProvider);
    return ConfirmationToastHost(
      confirmed: state.message != null,
      message: state.message ?? '',
      isError: state.error,
      noticeId: state.revision,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: LoadingShimmer(
          isLoading: state.busy,
          loadingLabel: 'Borrando listas locales',
          child: OutlinedButton(
            onPressed: state.busy || !state.canClear
                ? null
                : () async {
                    final accepted = await confirmActionDialog(
                      context,
                      title: 'Borrar datos locales',
                      description:
                          'Se eliminarán las listas guardadas sin conexión de todas las cuentas de este teléfono y sus claves. Tu cuenta y favoritos del servidor se conservan.',
                      action: 'Borrar datos',
                    );
                    if (accepted && context.mounted) {
                      await ref
                          .read(clearOfflineListsViewModelProvider.notifier)
                          .clear();
                    }
                  },
            child: const Text(
              'Borrar datos de este teléfono',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
