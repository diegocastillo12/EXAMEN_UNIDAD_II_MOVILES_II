import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/formatters/case_date_label.dart';
import '../../../../core/presentation/widgets/entity_screen_shell.dart';
import '../../../../core/presentation/widgets/entity_card_surface.dart';
import '../../../../core/presentation/widgets/collection_empty_state.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/content_refresh.dart';
import '../../../../core/presentation/widgets/pull_to_refresh.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../view_models/inbox_view_model.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({this.pushAction, super.key});
  final Widget? pushAction;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(inboxViewModelProvider);
    final data = async.isLoading || async.hasError ? null : async.asData?.value;
    final model = ref.read(inboxViewModelProvider.notifier);
    return ConfirmationToastHost(
      confirmed: async.hasError || data?.notice != null,
      isError: true,
      noticeId: (async.error, data?.owner, data?.noticeId),
      message:
          data?.notice ??
          'No pudimos consultar tus alertas. Puedes reintentar.',
      child: PullToRefresh(
        onRefresh: model.refresh,
        enabled: !async.isLoading && data?.busy != true,
        child: EntityScreenShell(
          title: 'Alertas',
          loading: async.isLoading,
          count: 1,
          scrollPhysics: const AlwaysScrollableScrollPhysics(),
          child: StaggerRevealItem(
            order: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton(
                  onPressed: () => context.push('/home/alert-preferences'),
                  child: const Text('Preferencias de alertas'),
                ),
                if (pushAction != null) pushAction!,
                if (async.isLoading)
                  const LoadingShimmer(
                    isLoading: true,
                    loadingLabel: 'Consultando alertas',
                    child: Column(
                      children: [
                        _Skeleton(),
                        SizedBox(height: 12),
                        _Skeleton(),
                        SizedBox(height: 12),
                        _Skeleton(),
                      ],
                    ),
                  )
                else if (async.hasError)
                  TextButton(
                    onPressed: model.refresh,
                    child: const Text('Reintentar'),
                  )
                else if (data != null)
                  ContentRefresh(
                    refreshing: data.busy,
                    label: 'Actualizando alertas',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (data.items.isEmpty)
                          const CollectionEmptyState(
                            title: 'Aún no tienes alertas',
                            description:
                                'Sigue casos o ubicaciones y activa tus preferencias para recibir novedades.',
                            icon: Icons.notifications_none_rounded,
                          ),
                        for (final item in data.items)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EntityCardSurface(
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: item.read
                                            ? FontWeight.w500
                                            : FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(caseDateTimeLabel(item.createdAt)),
                                    if (!item.read)
                                      const Text(
                                        'Sin leer',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    Wrap(
                                      spacing: 12,
                                      children: [
                                        TextButton(
                                          onPressed: data.busy
                                              ? null
                                              : () async {
                                                  final opened = await model
                                                      .markRead(item);
                                                  if (opened &&
                                                      context.mounted) {
                                                    await context.push(
                                                      '/home/${item.source == 'lost' ? 'cases' : 'found-cases'}/${item.caseId}',
                                                    );
                                                  }
                                                },
                                          child: const Text('Abrir caso'),
                                        ),
                                        if (!item.read)
                                          TextButton(
                                            onPressed: data.busy
                                                ? null
                                                : () => model.markRead(item),
                                            child: const Text('Marcar leída'),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (data.failed)
                          TextButton(
                            onPressed: data.busy ? null : model.retry,
                            child: const Text('Reintentar'),
                          )
                        else if (data.cursor != null)
                          LoadingShimmer(
                            isLoading: data.appending,
                            loadingLabel: 'Consultando más alertas',
                            child: TextButton(
                              onPressed: data.busy ? null : model.more,
                              child: const Text('Ver más alertas'),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();
  @override
  Widget build(BuildContext context) => Container(
    height: 130,
    decoration: BoxDecoration(
      color: const Color(0xFFECECEE),
      borderRadius: BorderRadius.circular(22),
    ),
  );
}
