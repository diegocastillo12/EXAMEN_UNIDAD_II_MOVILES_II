import '../../../../core/presentation/widgets/panel_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../domain/entities/notification.dart';
import '../view_models/following_view_model.dart';

class FollowTargetButton extends ConsumerWidget {
  const FollowTargetButton({
    required this.target,
    this.inPanel = false,
    super.key,
  });
  final AlertTarget target;
  final bool inPanel;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(followingViewModelProvider(target));
    final data = async.isLoading || async.hasError ? null : async.asData?.value;
    final model = ref.read(followingViewModelProvider(target).notifier);
    final busy = async.isLoading || data?.busy == true;
    final reload = async.hasError || data?.reload == true;
    return ConfirmationToastHost(
      confirmed: async.hasError || data?.notice != null,
      isError: async.hasError || data?.failed == true,
      noticeId: (target, async.error, data?.owner, data?.noticeId),
      message: async.hasError
          ? 'No pudimos consultar el seguimiento. Puedes reintentar.'
          : data?.notice ?? '',
      child: LoadingShimmer(
        isLoading: busy,
        loadingLabel: 'Actualizando seguimiento',
        child: PanelActionButton(
          iconOnly: inPanel,
          onPressed: busy
              ? null
              : reload
              ? model.retry
              : model.toggle,
          icon: data?.subscription.following == true
              ? Icons.notifications_active_outlined
              : Icons.notifications_none_rounded,
          label: reload
              ? 'Reintentar seguimiento'
              : data?.failed == true
              ? 'Reintentar cambio'
              : data?.subscription.following == true
              ? 'Dejar de seguir'
              : 'Seguir ${target.kind == 'zone' ? 'zona' : 'caso'}',
        ),
      ),
    );
  }
}
