import '../../../../core/presentation/widgets/app_scaffold.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../../../core/presentation/widgets/cover_reveal.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../domain/entities/recovery_access.dart';
import '../view_models/recovery_access_view_model.dart';
import '../view_models/password_recovery_view_model.dart';
import '../state/password_recovery_view_state.dart';
import '../widgets/auth_page_layout.dart';
import '../widgets/auth_primary_button_style.dart';
import '../widgets/email_code_confirmation.dart';
import '../widgets/recovery_form.dart';

class PasswordRecoveryScreen extends ConsumerWidget {
  const PasswordRecoveryScreen({this.resetMode = false, super.key});
  final bool resetMode;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(passwordRecoveryViewModelProvider);
    final access = ref.watch(recoveryAccessViewModelProvider);
    final vm = ref.read(passwordRecoveryViewModelProvider.notifier);
    final isReset =
        resetMode ||
        access.hasError ||
        access.asData?.value == RecoveryAccess.ready ||
        access.asData?.value == RecoveryAccess.invalid;
    final invalid =
        state.invalidLink || access.asData?.value == RecoveryAccess.invalid;
    final stage = isReset
        ? access.hasError
              ? 'unavailable'
              : invalid
              ? 'invalid'
              : state.updated
              ? 'success'
              : 'reset'
        : state.email != null
        ? 'code'
        : 'request';
    Future<void> login() async {
      if (isReset) {
        await vm.end();
        if (!context.mounted ||
            ref.read(passwordRecoveryViewModelProvider).message != null) {
          return;
        }
        context.go('/access');
      } else if (context.canPop()) {
        context.pop();
      } else {
        context.go('/access');
      }
    }

    final title = isReset
        ? access.hasError
              ? 'Recuperación no disponible'
              : invalid
              ? 'Enlace no válido'
              : state.updated
              ? 'Contraseña actualizada'
              : 'Nueva contraseña'
        : state.email == null
        ? 'Recuperar contraseña'
        : null;
    final resetOutcome = invalid || state.updated || access.hasError;
    return ConfirmationToastHost(
      confirmed:
          state.fieldHint != null || state.message != null || resetOutcome,
      noticeId: (state.errorId, state.message, stage, access.error),
      isError:
          !state.updated &&
          (state.errorField != null ||
              access.hasError ||
              invalid ||
              state.message != null),
      message:
          state.fieldHint ??
          state.message ??
          (access.hasError
              ? 'No pudimos comprobar el enlace. Revisa tu conexión e inténtalo de nuevo.'
              : invalid
              ? 'El enlace venció o ya no es válido. Solicita otro.'
              : state.updated
              ? 'Tu contraseña se guardó.'
              : ''),
      child: PopScope(
        canPop: !isReset && !state.isBusy,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && isReset && !state.isBusy) login();
        },
        child: StaggerReveal(
          count: 9,
          child: AppScaffold(
            body: AuthPageLayout(
              title: title,
              showClose: true,
              onClose: state.isBusy ? null : login,
              reveal: true,
              revealBrand: false,
              revealClose: false,
              contentBuilder: (content) => AuthStageTransition(
                stage: stage,
                startCovered: resetMode,
                builder: (play) => stage == 'request'
                    ? content
                    : StaggerReveal(
                        key: ValueKey(stage),
                        count: 9,
                        play: play,
                        child: content,
                      ),
              ),
              child: isReset
                  ? resetOutcome
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              StaggerRevealItem(
                                order: 3,
                                child: Text(
                                  'Ya puedes volver a iniciar sesión.',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    height: 1.4,
                                    color: Color(0xFF6E6E73),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),
                              if (access.hasError) ...[
                                StaggerRevealItem(
                                  order: 4,
                                  child: FilledButton(
                                    onPressed: state.isBusy
                                        ? null
                                        : () => ref.invalidate(
                                            recoveryAccessViewModelProvider,
                                          ),
                                    style: authPrimaryButtonStyle(context),
                                    child: const Text('Reintentar'),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              StaggerRevealItem(
                                order: access.hasError ? 5 : 4,
                                child: LoadingShimmer(
                                  isLoading: state.isBusy,
                                  loadingLabel:
                                      'Cerrando sesión de recuperación',
                                  child: FilledButton(
                                    onPressed: state.isBusy ? null : login,
                                    style: authPrimaryButtonStyle(
                                      context,
                                      isLoading: state.isBusy,
                                    ),
                                    child: const Text(
                                      'Volver a iniciar sesión',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : RecoveryForm(
                            reset: true,
                            state: state,
                            onEdited: vm.edited,
                            onSubmit: vm.reset,
                            onLogin: login,
                          )
                  : state.email != null
                  ? EmailCodeConfirmation(
                      email: state.email!,
                      isBusy: state.isBusy,
                      isVerifying: state.isVerifying,
                      resendSeconds: state.resendSeconds,
                      message: state.message,
                      onResend: vm.resend,
                      onVerify: vm.verify,
                      onCodeEdited: () => vm.edited(RecoveryField.code),
                      codeHint: state.errorField == RecoveryField.code
                          ? state.fieldHint
                          : null,
                      errorId: state.errorId,
                    )
                  : RecoveryForm(
                      state: state,
                      onEdited: vm.edited,
                      onSubmit: (email, _) => vm.request(email),
                      onLogin: login,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
