import '../../../../core/presentation/widgets/app_scaffold.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../../../core/presentation/widgets/cover_reveal.dart';
import '../view_models/registration_view_model.dart';
import '../state/registration_view_state.dart';
import '../widgets/auth_page_layout.dart';
import '../widgets/registration_form.dart';
import '../widgets/registration_confirmation.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registrationViewModelProvider);
    final vm = ref.read(registrationViewModelProvider.notifier);
    void login() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/access');
      }
    }

    return ConfirmationToastHost(
      confirmed: state.fieldHint != null || state.message != null,
      message: state.fieldHint ?? state.message ?? '',
      isError: state.errorField != null || state.messageIsError,
      noticeId: (state.errorId, state.message),
      child: PopScope(
        canPop: !state.isBusy,
        child: StaggerReveal(
          count: 8,
          child: AppScaffold(
            body: AuthPageLayout(
              title: state.confirmationEmail == null ? 'Crear cuenta' : null,
              showClose: true,
              onClose: state.isBusy ? null : login,
              reveal: true,
              contentBuilder: (content) => AuthStageTransition(
                stage: state.confirmationEmail != null,
                builder: (play) => state.confirmationEmail == null
                    ? content
                    : StaggerReveal(
                        key: const ValueKey('registration-code-reveal'),
                        count: 9,
                        play: play,
                        child: content,
                      ),
              ),
              child: state.confirmationEmail != null
                  ? RegistrationConfirmation(
                      state: state,
                      onResend: vm.resend,
                      onVerify: vm.verify,
                      onCodeEdited: () => vm.edited(RegistrationField.code),
                    )
                  : RegistrationForm(
                      state: state,
                      onEdited: vm.edited,
                      onSubmit: vm.submit,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
