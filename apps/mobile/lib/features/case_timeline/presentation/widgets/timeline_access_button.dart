import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../domain/entities/case_timeline.dart';
import '../view_models/case_timeline_view_model.dart';

class TimelineAccessButton extends ConsumerWidget {
  const TimelineAccessButton({required this.target, super.key});
  final TimelineTarget target;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = timelineAccessViewModelProvider(target),
        value = ref.watch(provider);
    if (value.isLoading) return const SizedBox.shrink();
    if (value.hasError) {
      return ConfirmationToastHost(
        confirmed: true,
        message: 'No pudimos consultar el acceso al historial.',
        noticeId: value.error,
        isError: true,
        child: TextButton(
          onPressed: ref.read(provider.notifier).retry,
          child: const Text('Reintentar historial'),
        ),
      );
    }
    if (value.asData?.value != true) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextButton(
        onPressed: () => context.push(
          '/home/timeline/${target.community ? 'found' : 'lost'}/${target.id}',
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text('Ver seguimiento', textAlign: TextAlign.center),
            ),
            SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
