import '../../../../core/theme/app_typography.dart';
import '../../../../core/presentation/widgets/app_scaffold.dart';
import '../../../../core/presentation/widgets/scroll_safe_area.dart';
import '../../../../core/presentation/widgets/pull_to_refresh.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/origin_page_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/brand_wordmark.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../view_models/home_view_model.dart';
import '../state/home_view_state.dart';
import '../widgets/liquid_navigation.dart';
import '../widgets/home_content.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    required this.profileAvatar,
    this.petsContent,
    this.exploreContent,
    this.exploreFloatingAction,
    this.onAlerts,
    this.onHomeRefresh,
    super.key,
  });
  final Widget profileAvatar;
  final Widget? petsContent;
  final Widget? exploreContent;
  final Widget? exploreFloatingAction;
  final ValueChanged<OriginPageSource?>? onAlerts;
  final Future<void> Function()? onHomeRefresh;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final model = ref.read(homeViewModelProvider.notifier);
    // Feature sections own their entrance; do not animate them a second time.
    final animateContent =
        state.section != HomeSection.pets &&
        (state.section != HomeSection.explore || exploreContent == null);
    return ConfirmationToastHost(
      confirmed: state.refreshError,
      isError: true,
      message: 'No pudimos actualizar el inicio.',
      noticeId: state.noticeId,
      actionLabel: 'Reintentar',
      onAction: onHomeRefresh == null
          ? null
          : () => model.refresh(onHomeRefresh!),
      child: AppScaffold(
        body: ScrollSafeArea(
          top: true,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: PullToRefresh(
                onRefresh:
                    state.section == HomeSection.home && onHomeRefresh != null
                    ? () => model.refresh(onHomeRefresh!)
                    : null,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: SingleChildScrollView(
                        key: ValueKey(state.section),
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                20,
                                24,
                                18,
                              ),
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: BrandWordmark(
                                        iconSize: 46,
                                        textSize: 22,
                                      ),
                                    ),
                                  ),
                                  Builder(
                                    builder: (source) => IconButton(
                                      tooltip: 'Alertas',
                                      onPressed: onAlerts == null
                                          ? null
                                          : () {
                                              final box = source
                                                  .findRenderObject();
                                              final navigator = Navigator.of(
                                                source,
                                              ).context.findRenderObject();
                                              final bounds =
                                                  box is RenderBox &&
                                                      box.hasSize
                                                  ? box.localToGlobal(
                                                          Offset.zero,
                                                          ancestor: navigator,
                                                        ) &
                                                        box.size
                                                  : null;
                                              onAlerts!(
                                                bounds == null
                                                    ? null
                                                    : OriginPageSource(
                                                        bounds: bounds,
                                                        color: Colors.white,
                                                        radius: 24,
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons
                                                                .notifications_none_rounded,
                                                            color: Color(
                                                              0xFF6E6E73,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                              );
                                            },
                                      icon: const Icon(
                                        Icons.notifications_none_rounded,
                                        color: Color(0xFF6E6E73),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  profileAvatar,
                                ],
                              ),
                            ),
                            Builder(
                              builder: (_) => StaggerReveal(
                                enabled: animateContent,
                                key: ValueKey(state.section),
                                count: state.section == HomeSection.home
                                    ? 4
                                    : 2,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    state.section == HomeSection.explore
                                        ? 12
                                        : 24,
                                    6,
                                    state.section == HomeSection.explore
                                        ? 12
                                        : 24,
                                    ScrollSafeArea.bottomPadding(
                                      context,
                                      state.section == HomeSection.explore &&
                                              exploreFloatingAction != null
                                          ? 200 +
                                                (MediaQuery.textScalerOf(
                                                          context,
                                                        ).scale(14) -
                                                        14)
                                                    .clamp(0, double.infinity)
                                          : 130,
                                    ),
                                  ),
                                  child: state.section == HomeSection.home
                                      ? HomeContent(
                                          onSelect: model.select,
                                          onReport: (source) => openLostReport(
                                            source,
                                            color: const Color(0xFF111111),
                                            radius: 22,
                                          ),
                                        )
                                      : state.section == HomeSection.explore &&
                                            exploreContent != null
                                      ? exploreContent!
                                      : state.section == HomeSection.pets &&
                                            petsContent != null
                                      ? petsContent!
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            StaggerRevealItem(
                                              order: 0,
                                              child: Text(
                                                state.section ==
                                                        HomeSection.explore
                                                    ? 'Explorar'
                                                    : 'Mis mascotas',
                                                style:
                                                    AppTypography.primaryTitle,
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            StaggerRevealItem(
                                              order: 1,
                                              child: HomeNotice(
                                                icon:
                                                    state.section ==
                                                        HomeSection.explore
                                                    ? Icons.travel_explore
                                                    : Icons.pets_outlined,
                                                title:
                                                    state.section ==
                                                        HomeSection.explore
                                                    ? 'Ayuda a encontrar su hogar'
                                                    : 'Su información, en un solo lugar',
                                                description:
                                                    state.section ==
                                                        HomeSection.explore
                                                    ? 'Aquí podrás consultar casos en lista o mapa y filtrar por ubicación. La búsqueda de casos aún no está disponible.'
                                                    : 'Aquí podrás registrar tus mascotas, sus fotos y consultar sus casos. El registro de mascotas aún no está disponible.',
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (state.section == HomeSection.explore &&
                        exploreFloatingAction != null)
                      Positioned(
                        right: 16,
                        bottom: ScrollSafeArea.bottomPadding(context, 100),
                        child: exploreFloatingAction!,
                      ),
                    Positioned(
                      // Keep the bar mounted when Explore inserts its map action.
                      key: const ValueKey('home-navigation'),
                      left: 16,
                      right: 16,
                      bottom: ScrollSafeArea.bottomPadding(context, 16),
                      child: LiquidNavigation(
                        selected: state.section,
                        onSelect: model.select,
                        onReport: (source) => openLostReport(source),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
