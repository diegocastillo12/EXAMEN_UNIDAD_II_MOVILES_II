import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/public_case_grid.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../view_models/cached_cases_view_model.dart';

class CachedCasesSection extends ConsumerWidget {
  const CachedCasesSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cachedCasesViewModelProvider);
    final items = state.isLoading ? null : state.asData?.value;
    return ConfirmationToastHost(
      confirmed: state.hasError,
      isError: true,
      noticeId: state.error,
      message:
          'No pudimos leer las fichas de este dispositivo. Puedes reintentar.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            'Consultados en este dispositivo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Hasta 30 fichas consultadas, separadas por cuenta. Puedes abrirlas sin conexión. Las fotos disponibles se conservan; el mapa requiere red.',
          ),
          const SizedBox(height: 16),
          if (state.isLoading)
            const LoadingShimmer(
              isLoading: true,
              loadingLabel: 'Consultando fichas locales',
              child: PublicCaseGrid.skeleton(),
            )
          else if (state.hasError)
            TextButton(
              onPressed: ref
                  .read(cachedCasesViewModelProvider.notifier)
                  .refresh,
              child: const Text('Reintentar'),
            )
          else if (items == null || items.isEmpty)
            const Text('Las fichas que consultes con conexión aparecerán aquí.')
          else
            PublicCaseGrid(
              items: items.map((i) => i.card).toList(),
              onOpen: (item, source) async {
                final box = source.findRenderObject() as RenderBox?;
                final origin = box == null
                    ? null
                    : box.localToGlobal(Offset.zero) & box.size;
                await context.push(
                  '/home/${item.fromPet ? 'cases' : 'found-cases'}/${item.id}',
                  extra: origin,
                );
                if (context.mounted) {
                  ref.read(cachedCasesViewModelProvider.notifier).refresh();
                }
              },
            ),
        ],
      ),
    );
  }
}
