import '../../../../core/presentation/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/brand_wordmark.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../view_models/entry_view_model.dart';

class EntryScreen extends ConsumerWidget {
  const EntryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(entryViewModelProvider);
    final exit = ref.watch(entryExitViewModelProvider);
    return ConfirmationToastHost(
      confirmed: flow.hasError || exit.hasError,
      noticeId: (flow.error, exit.error),
      isError: true,
      message: exit.hasError
          ? 'No pudimos cerrar sesión. Reintenta.'
          : 'No pudimos preparar tu cuenta. Revisa tu conexión e inténtalo de nuevo.',
      child: AppScaffold(
        body: SafeArea(
          child: Center(
            child: flow.hasError
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilledButton(
                          onPressed: exit.isLoading
                              ? null
                              : () => ref
                                    .read(entryViewModelProvider.notifier)
                                    .retry(),
                          child: const Text('Reintentar'),
                        ),
                        LoadingShimmer(
                          isLoading: exit.isLoading,
                          loadingLabel: 'Cerrando sesión',
                          highlight: const Color(0x3324282A),
                          child: TextButton(
                            onPressed: exit.isLoading
                                ? null
                                : () => ref
                                      .read(entryExitViewModelProvider.notifier)
                                      .signOut(),
                            child: const Text('Cerrar sesión'),
                          ),
                        ),
                      ],
                    ),
                  )
                : Semantics(
                    label: 'Preparando tu cuenta',
                    liveRegion: true,
                    child: const ExcludeSemantics(
                      child: BrandWordmark(iconSize: 80, textSize: 32),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
