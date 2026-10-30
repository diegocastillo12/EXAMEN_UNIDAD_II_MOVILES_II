import '../../../../core/presentation/widgets/app_scaffold.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/brand_wordmark.dart';
import '../view_models/onboarding_view_model.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/onboarding_actions.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  int _revealPage = 0;
  static const _titles = [
    'Cada huella\nimporta',
    'Volvamos\na casa',
    'Una nueva\nhistoria',
  ];
  static const _descriptions = [
    'Encuentra, ayuda y cuida\na las mascotas cerca de ti.',
    'Con tu ayuda, más mascotas\npueden reencontrarse\ncon su familia.',
    'Pequeñas acciones generan\ngrandes finales.',
  ];
  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingViewModelProvider);
    ref.listen(onboardingViewModelProvider, (previous, next) {
      if (previous?.page != next.page &&
          _pages.hasClients &&
          _pages.page?.round() != next.page) {
        if (MediaQuery.disableAnimationsOf(context)) {
          _pages.jumpToPage(next.page);
          return;
        }
        _pages.animateToPage(
          next.page,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
    final vm = ref.read(onboardingViewModelProvider.notifier);
    return ConfirmationToastHost(
      confirmed: state.hasError,
      message: 'No se pudo guardar. Inténtalo de nuevo.',
      isError: true,
      noticeId: state,
      child: PopScope(
        canPop: false,
        child: AppScaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: BrandWordmark(iconSize: 56, textSize: 24),
                      ),
                    ),
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification.depth == 0 && _pages.hasClients) {
                            final position = _pages.page!;
                            final page = position.round();
                            // Start near arrival instead of waiting for ScrollEnd.
                            if ((position - page).abs() <= .15 &&
                                _revealPage != page) {
                              setState(() => _revealPage = page);
                            }
                          }
                          return false;
                        },
                        child: PageView.builder(
                          controller: _pages,
                          itemCount: 3,
                          onPageChanged: vm.selectPage,
                          physics: state.isBusy
                              ? const NeverScrollableScrollPhysics()
                              : null,
                          itemBuilder: (context, page) => OnboardingPage(
                            page: page,
                            isActive: state.page == page && _revealPage == page,
                            title: _titles[page],
                            description: _descriptions[page],
                          ),
                        ),
                      ),
                    ),
                    OnboardingActions(
                      page: state.page,
                      isBusy: state.isBusy,
                      onNext: vm.next,
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
