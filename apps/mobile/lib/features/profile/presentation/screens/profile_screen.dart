import '../../../../core/presentation/widgets/app_scaffold.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/scroll_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/glass_navigation_button.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../widgets/profile_editor.dart';
import '../widgets/profile_photo_editor.dart';
import '../view_models/profile_exit_view_model.dart';
import '../view_models/profile_view_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({
    this.cityFieldBuilder,
    this.offlineDataAction,
    super.key,
  });
  final ProfileCityFieldBuilder? cityFieldBuilder;
  final Widget? offlineDataAction;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exit = ref.watch(profileExitViewModelProvider);
    final routeAnimation =
        ModalRoute.of(context)?.animation ??
        const AlwaysStoppedAnimation<double>(1);
    return ConfirmationToastHost(
      confirmed: exit.hasError,
      message: 'No se pudo cerrar la sesión. Reintenta.',
      isError: true,
      noticeId: exit.error,
      child: AppScaffold(
        body: ScrollSafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      MediaQuery.paddingOf(context).top + 72,
                      24,
                      ScrollSafeArea.bottomPadding(context, 32),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ProfileEntrance(
                          animation: routeAnimation,
                          loading: ref
                              .watch(profileViewModelProvider)
                              .isLoading,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              StaggerRevealItem(
                                order: 0,
                                child: ProfilePhotoEditor(),
                              ),
                              SizedBox(height: 28),
                              StaggerRevealItem(
                                order: 1,
                                child: ProfileEditor(
                                  cityFieldBuilder: cityFieldBuilder,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton.icon(
                          onPressed: exit.isLoading
                              ? null
                              : () => context.push('/home/drafts'),
                          icon: const Icon(Icons.edit_note_rounded),
                          label: const Text('Borradores'),
                        ),
                        TextButton.icon(
                          onPressed: exit.isLoading
                              ? null
                              : () => context.push('/home/submissions'),
                          icon: const Icon(Icons.cloud_upload_outlined),
                          label: const Text('Envíos'),
                        ),
                        TextButton.icon(
                          onPressed: exit.isLoading
                              ? null
                              : () => context.push('/home/blocked-users'),
                          icon: const Icon(Icons.block_rounded),
                          label: const Text('Cuentas bloqueadas'),
                        ),
                        TextButton.icon(
                          onPressed: exit.isLoading
                              ? null
                              : () => context.push('/home/alert-preferences'),
                          icon: const Icon(Icons.notifications_outlined),
                          label: const Text('Preferencias de alertas'),
                        ),
                        TextButton.icon(
                          onPressed: exit.isLoading
                              ? null
                              : () => context.push('/home/interest-zones'),
                          icon: const Icon(Icons.location_on_outlined),
                          label: const Text('Ubicaciones de interés'),
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: exit.isLoading
                              ? null
                              : () => context.push('/home/appeals'),
                          icon: const Icon(Icons.fact_check_outlined),
                          label: const Text('Mis apelaciones'),
                        ),
                        if (offlineDataAction != null) offlineDataAction!,
                        LoadingShimmer(
                          isLoading: exit.isLoading,
                          loadingLabel: 'Cerrando sesión',
                          radius: 18,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFF9ECEE),
                              foregroundColor: const Color(0xFFB53F48),
                              disabledBackgroundColor: const Color(0xFFF9ECEE),
                              disabledForegroundColor: const Color(0xFFB53F48),
                              minimumSize: const Size(0, 48),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'sans-serif',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: exit.isLoading
                                ? null
                                : () => ref
                                      .read(
                                        profileExitViewModelProvider.notifier,
                                      )
                                      .signOut(),
                            child: const Text('Cerrar sesión'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + 4,
                    left: 24,
                    child: GlassNavigationButton(
                      tooltip: 'Cerrar perfil',
                      onPressed: () => context.pop(),
                      icon: Icons.close_rounded,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileEntrance extends StatelessWidget {
  const _ProfileEntrance({
    required this.animation,
    required this.child,
    required this.loading,
  });
  final Animation<double> animation;
  final Widget child;
  final bool loading;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    child: child,
    builder: (context, child) => ContentReveal(
      loading: loading,
      count: 2,
      play:
          animation.status == AnimationStatus.completed ||
          MediaQuery.disableAnimationsOf(context),
      child: child!,
    ),
  );
}
