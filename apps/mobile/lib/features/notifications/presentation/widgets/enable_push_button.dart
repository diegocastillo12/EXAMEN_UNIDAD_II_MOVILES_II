import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../view_models/push_view_model.dart';

class EnablePushButton extends ConsumerWidget {
  const EnablePushButton({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pushViewModelProvider);
    return ConfirmationToastHost(
      confirmed: state.notice != null,
      isError: state.error,
      message: state.notice ?? '',
      noticeId: state.noticeId,
      child: LoadingShimmer(
        isLoading: state.busy,
        loadingLabel: 'Registrando teléfono',
        child: TextButton.icon(
          onPressed: state.busy
              ? null
              : ref.read(pushViewModelProvider.notifier).enable,
          icon: const Icon(Icons.notifications_outlined),
          label: const Text('Activar avisos en este teléfono'),
        ),
      ),
    );
  }
}
