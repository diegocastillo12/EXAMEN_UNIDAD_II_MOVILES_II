import '../../../../core/presentation/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/glass_navigation_button.dart';
import '../../../../core/presentation/widgets/glass_surface.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/content_refresh.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../view_models/explore_view_model.dart';
import '../widgets/explore_case_map.dart';
import '../widgets/explore_map_case_preview.dart';
import '../../domain/entities/explore_page.dart';

class ExploreMapScreen extends ConsumerStatefulWidget {
  const ExploreMapScreen({this.createTileProvider, super.key});
  final TileProvider Function()? createTileProvider;

  @override
  ConsumerState<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends ConsumerState<ExploreMapScreen> {
  final _sheetExtent = ValueNotifier<double>(.5);
  bool _openingCase = false;

  @override
  void dispose() {
    _sheetExtent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(exploreViewModelProvider);
    final data = value.isLoading || value.hasError ? null : value.asData?.value;
    final vm = ref.read(exploreViewModelProvider.notifier);
    Future<void> openCase(ExploreCase item, BuildContext source) async {
      if (_openingCase) return;
      setState(() => _openingCase = true);
      final box = source.findRenderObject() as RenderBox?;
      final navigator = Navigator.of(source).context.findRenderObject();
      final origin = box == null
          ? null
          : box.localToGlobal(Offset.zero, ancestor: navigator) & box.size;
      try {
        await context.push(
          '/home/${item.fromPet ? 'cases' : 'found-cases'}/${item.id}',
          extra: origin,
        );
        if (context.mounted) {
          await ref.read(exploreViewModelProvider.notifier).refresh();
        }
      } finally {
        if (mounted) setState(() => _openingCase = false);
      }
    }

    return AppScaffold(
      body: ConfirmationToastHost(
        confirmed: value.hasError || data?.notice != null,
        isError: true,
        message: value.hasError
            ? 'No pudimos consultar los casos.'
            : data?.notice ?? '',
        noticeId: (value.error, data?.noticeId),
        child: NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            _sheetExtent.value = notification.extent;
            return false;
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (data == null)
                value.hasError
                    ? Center(
                        child: TextButton(
                          onPressed: vm.refresh,
                          child: const Text('Reintentar'),
                        ),
                      )
                    : const LoadingShimmer(
                        isLoading: true,
                        loadingLabel: 'Consultando casos',
                        child: ColoredBox(color: Color(0xFFE5E5EA)),
                      )
              else
                ContentRefresh(
                  refreshing: data.refreshing,
                  label: 'Actualizando casos',
                  child: ExploreCaseMap(
                    key: ValueKey(data.owner),
                    items: data.items,
                    query: data.query,
                    emptyMessage: data.failed || data.busy
                        ? 'Puedes volver a Explorar para ajustar la búsqueda.'
                        : data.needsLocation
                        ? 'Elige una ubicación desde Explorar para ver casos cercanos.'
                        : null,
                    onOpen: data.busy || _openingCase ? null : openCase,
                    createTileProvider: widget.createTileProvider,
                    previewBuilder: (item, onSummaryHeight) =>
                        ExploreMapCasePreview(
                          key: ValueKey(item.key),
                          item: item,
                          scrollable: false,
                          onSummaryHeight: onSummaryHeight,
                          onOpen: data.busy || _openingCase
                              ? null
                              : (source) => openCase(item, source),
                        ),
                    trailing: [
                      if (data.failed || data.cursor != null)
                        LoadingShimmer(
                          isLoading: data.appending,
                          loadingLabel: 'Consultando más casos',
                          child: TextButton(
                            onPressed: data.busy
                                ? null
                                : data.failed && data.cursor == null
                                ? vm.refresh
                                : vm.more,
                            child: Text(
                              data.failed ? 'Reintentar' : 'Ver más casos',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              Positioned(
                top: MediaQuery.paddingOf(context).top + 8,
                left: 16,
                right: 16,
                child: ValueListenableBuilder<double>(
                  valueListenable: _sheetExtent,
                  child: Row(
                    children: [
                      GlassNavigationButton(
                        tooltip: 'Volver a Explorar',
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Center(
                          child: ValueListenableBuilder<double>(
                            valueListenable: _sheetExtent,
                            child: const GlassSurface(
                              radius: 24,
                              backdropBlendMode: BlendMode.src,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 12,
                                ),
                                child: Text(
                                  'Explorar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF171918),
                                  ),
                                ),
                              ),
                            ),
                            builder: (context, extent, child) {
                              final media = MediaQuery.of(context);
                              final remaining =
                                  media.size.height * (1 - extent) -
                                  media.padding.top;
                              final opacity = media.size.height < 500
                                  ? 0.0
                                  : ((remaining - 80) / 40).clamp(0.0, 1.0);
                              return ExcludeSemantics(
                                excluding: opacity == 0,
                                child: Opacity(opacity: opacity, child: child),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 52),
                    ],
                  ),
                  builder: (context, extent, child) {
                    final reduced = MediaQuery.disableAnimationsOf(context);
                    final progress = reduced || extent >= .8999
                        ? (extent >= .89 ? 1.0 : 0.0)
                        : ((extent - .78) / .12).clamp(0.0, 1.0);
                    return ExcludeSemantics(
                      excluding: progress >= 1,
                      child: IgnorePointer(
                        ignoring: progress >= 1,
                        child: Opacity(
                          opacity: 1 - progress,
                          child: Transform.translate(
                            offset: Offset(0, reduced ? 0 : -72 * progress),
                            child: child,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
