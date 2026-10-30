import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/case_screen_shell.dart';
import '../../../../core/presentation/widgets/content_refresh.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../view_models/user_block_view_model.dart';
import '../widgets/user_block_controls.dart';

class UserBlocksScreen extends ConsumerWidget {
  const UserBlocksScreen({this.onSettled, super.key});
  final VoidCallback? onSettled;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(userBlockViewModelProvider(null));
    final model = ref.read(userBlockViewModelProvider(null).notifier);
    final value = async.isLoading || async.hasError
        ? null
        : async.asData?.value;
    return PopScope(
      canPop: value?.busy != true,
      child: CaseScreenShell(
        title: 'Cuentas bloqueadas',
        loading: async.isLoading,
        count: 2,
        onBack: value?.busy == true ? () {} : null,
        notice: async.hasError || value?.issue != null
            ? blockFailureLabel(async.error ?? value?.issue)
            : value?.confirmed == true
            ? 'Cuenta desbloqueada'
            : null,
        noticeIsError: value?.confirmed != true,
        noticeId: (async.error, value?.actor, value?.notice),
        child: async.isLoading
            ? const SkeletonFormFields(fieldCount: 3)
            : value == null
            ? TextButton(
                onPressed: model.retry,
                child: const Text('Reintentar'),
              )
            : ContentRefresh(
                refreshing: value.refreshing,
                label: 'Actualizando bloqueos',
                child: StaggerRevealItem(
                  order: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(userBlockScope),
                      const SizedBox(height: 16),
                      if (value.items.isEmpty)
                        const Text('No tienes cuentas bloqueadas.'),
                      for (final entry in value.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(entry.label),
                              UserBlockAction(
                                key: ValueKey((value.actor, entry.id)),
                                entry: entry,
                                busy: value.busy,
                                locked:
                                    value.pending != null ||
                                    value.issue != null ||
                                    value.refreshing,
                                onChange: () async {
                                  await model.change(entry, false);
                                  onSettled?.call();
                                },
                              ),
                            ],
                          ),
                        ),
                      if (value.pending != null)
                        TextButton(
                          onPressed: value.busy
                              ? null
                              : () async {
                                  await model.change(
                                    value.pending!.entry,
                                    value.pending!.enabled,
                                  );
                                  onSettled?.call();
                                },
                          child: const Text('Reintentar cambio'),
                        ),
                      if (value.issue == null && value.next != null)
                        TextButton(
                          onPressed:
                              value.busy ||
                                  value.refreshing ||
                                  value.pending != null
                              ? null
                              : () => model.load(more: true),
                          child: const Text('Ver más'),
                        ),
                      TextButton(
                        onPressed:
                            value.busy ||
                                value.refreshing ||
                                value.pending != null
                            ? null
                            : value.issue != null
                            ? model.retry
                            : () => model.load(),
                        child: const Text('Consultar bloqueos'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
