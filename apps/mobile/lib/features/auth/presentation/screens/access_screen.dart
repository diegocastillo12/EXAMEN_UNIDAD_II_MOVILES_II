import '../../../../core/presentation/widgets/app_scaffold.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/cover_reveal.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../widgets/create_account_button.dart';
import '../widgets/auth_page_layout.dart';
import '../../domain/entities/social_provider.dart';
import '../view_models/login_view_model.dart';
import '../widgets/login_credentials_form.dart';
import '../widgets/social_sign_in_button.dart';

class AccessScreen extends ConsumerWidget {
  const AccessScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final login = ref.watch(loginViewModelProvider);
    final vm = ref.read(loginViewModelProvider.notifier);
    return ConfirmationToastHost(
      confirmed: login.isError && login.message != null,
      message: login.message ?? '',
      isError: true,
      noticeId: login.errorId,
      child: AppScaffold(
        body: AuthPageLayout(
          title: 'Iniciar sesión',
          reveal: true,
          revealBrand: false,
          contentBuilder: (content) => AuthStageTransition(
            stage: 'login',
            startCovered: true,
            builder: (play) =>
                StaggerReveal(count: 11, play: play, child: content),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LoginCredentialsForm(
                isBusy: login.isBusy,
                reveal: true,
                feedback: login,
                onFieldEdited: vm.fieldEdited,
                onSubmit: vm.password,
                onRecover: (origin) =>
                    context.push('/recover-password', extra: origin),
              ),

              const SizedBox(height: 24),
              const StaggerRevealItem(
                order: 7,
                child: Row(
                  children: [
                    Expanded(child: Divider(color: Color(0xFFE5E5EA))),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'o continúa con',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6E6E73),
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Color(0xFFE5E5EA))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              StaggerRevealItem(
                order: 8,
                child: SocialSignInButton(
                  isLoading: login.isBusy,
                  label: 'Continuar con Google',
                  icon: Image.asset(
                    'assets/branding/google_g.png',
                    width: 20,
                    height: 20,
                    excludeFromSemantics: true,
                  ),
                  onPressed: login.isBusy
                      ? null
                      : () => vm.social(SocialProvider.google),
                ),
              ),
              const SizedBox(height: 12),
              StaggerRevealItem(
                order: 9,
                child: SocialSignInButton(
                  isLoading: login.isBusy,
                  label: 'Continuar con Facebook',
                  icon: const ExcludeSemantics(
                    child: Icon(
                      Icons.facebook,
                      size: 24,
                      color: Color(0xFF0866FF),
                    ),
                  ),
                  onPressed: login.isBusy
                      ? null
                      : () => vm.social(SocialProvider.facebook),
                ),
              ),
              const SizedBox(height: 26),
              StaggerRevealItem(
                order: 10,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      '¿No tienes una cuenta?',
                      style: TextStyle(fontSize: 15, color: Color(0xFF6E6E73)),
                    ),
                    CreateAccountButton(enabled: !login.isBusy),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
