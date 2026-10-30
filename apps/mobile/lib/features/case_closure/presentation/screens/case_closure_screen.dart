import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/formatters/case_date_label.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/case_screen_shell.dart';
import '../../../../core/presentation/widgets/confirm_action_dialog.dart';
import '../../../../core/presentation/widgets/confirm_discard_action.dart';
import '../../../../core/presentation/widgets/content_refresh.dart';
import '../../../../core/presentation/widgets/entity_card_surface.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../../../core/presentation/widgets/unicode_length_limiting_formatter.dart';
import '../../../../core/presentation/widgets/validation_surface.dart';
import '../../domain/entities/case_closure.dart';
import '../state/case_closure_state.dart';
import '../view_models/case_closure_view_model.dart';

class CaseClosureScreen extends ConsumerStatefulWidget {
  const CaseClosureScreen({
    required this.target,
    required this.onSaved,
    super.key,
  });
  final ClosureTarget target;
  final VoidCallback onSaved;
  @override
  ConsumerState<CaseClosureScreen> createState() => _CaseClosureScreenState();
}

class _CaseClosureScreenState extends ConsumerState<CaseClosureScreen> {
  final _reason = TextEditingController(), _evidence = TextEditingController();
  bool _canPop = false, _leaving = false, _confirming = false;
  @override
  void dispose() {
    _reason.dispose();
    _evidence.dispose();
    super.dispose();
  }

  bool _dirty(CaseClosureState? v) =>
      v != null &&
      !v.detail.closed &&
      (v.reason.isNotEmpty || v.evidence.isNotEmpty || v.frozen != null);
  Future<void> _leave() async {
    final v = ref
        .read(caseClosureViewModelProvider(widget.target))
        .asData
        ?.value;
    if (v?.busy == true || _leaving || _confirming) return;
    _leaving = true;
    final leave =
        !_dirty(v) ||
        await confirmDiscardAction(
          context,
          '¿Salir del cierre?',
          v?.frozen != null
              ? 'El cierre pudo haberse guardado. Reintenta la misma operación para confirmar el resultado antes de salir.'
              : 'Se descartarán el motivo y los detalles que todavía no guardaste.',
          'Salir',
        );
    _leaving = false;
    if (!mounted || !leave) return;
    setState(() => _canPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = caseClosureViewModelProvider(widget.target);
    ref.listen(provider, (previous, next) {
      if (next.isLoading ||
          next.hasError ||
          previous?.asData?.value.owner != next.asData?.value.owner) {
        _reason.clear();
        _evidence.clear();
      }
    });
    final async = ref.watch(provider), model = ref.read(provider.notifier);
    final v = async.isLoading || async.hasError ? null : async.asData?.value;
    if (v != null) {
      if (_reason.text != v.reason) _reason.text = v.reason;
      if (_evidence.text != v.evidence) _evidence.text = v.evidence;
    }
    final issue = async.error is ClosureFailure
        ? (async.error as ClosureFailure).issue
        : ClosureIssue.unavailable;
    return PopScope(
      canPop: _canPop || (v?.busy != true && !_dirty(v) && !_confirming),
      onPopInvokedWithResult: (popped, _) {
        if (!popped) _leave();
      },
      child: CaseScreenShell(
        title: 'Cierre',
        count: v?.detail.closed == true ? 1 : 4,
        stage: v?.detail.closed == true ? 'receipt' : 'form',
        loading: async.isLoading,
        onBack: _leave,
        notice: async.hasError
            ? closureFailureLabel(issue)
            : v?.issue != null
            ? closureFailureLabel(v!.issue!)
            : v?.saved == true
            ? 'Recuperación confirmada'
            : null,
        noticeIsError: v?.saved != true,
        noticeId: (async.error, v?.owner, v?.notice),
        child: async.isLoading
            ? const SkeletonFormFields(fieldCount: 3)
            : v == null
            ? TextButton(
                onPressed: model.retry,
                child: const Text('Reintentar'),
              )
            : ContentRefresh(
                refreshing: v.refreshing,
                label: 'Actualizando cierre',
                child: _content(v, model),
              ),
      ),
    );
  }

  Widget _content(CaseClosureState v, CaseClosureViewModel model) {
    if (v.detail.closed) {
      final receipt = v.detail.receipt;
      return StaggerRevealItem(
        order: 0,
        child: EntityCardSurface(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Búsqueda finalizada',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const Text(
                  'El QR de este caso muestra el cierre. Una nueva desaparición se registra como otro caso.',
                ),
                if (receipt != null) ...[
                  const SizedBox(height: 16),
                  Text('Cierre: ${caseDateTimeLabel(receipt.closedAt)}'),
                  const Text('Confirmado por ti, responsable del caso.'),
                  const SizedBox(height: 12),
                  Text('Motivo: ${receipt.reason}'),
                  if (receipt.evidence != null) ...[
                    const SizedBox(height: 12),
                    Text('Evidencia adicional: ${receipt.evidence}'),
                  ],
                ] else ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Este cierre anterior no tiene motivo registrado.',
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
    final blocked = v.requiresRead;
    final invalid = v.issue == ClosureIssue.invalid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StaggerRevealItem(
          order: 0,
          child: Text(
            'Confirma que la mascota ya fue recuperada. El QR mostrará el cierre y la búsqueda dejará de aceptar avistamientos. El motivo y la evidencia adicional son privados.',
          ),
        ),
        const SizedBox(height: 20),
        StaggerRevealItem(
          order: 1,
          child: ValidationSurface(
            invalid: invalid,
            errorId: v.notice,
            child: AppTextField(
              label: 'Motivo de recuperación',
              controller: _reason,
              enabled: v.editable && !_confirming,
              invalid: invalid,
              maxLines: 4,
              minLines: 2,
              footer: Text('${v.reason.runes.length}/500'),
              inputFormatters: [UnicodeLengthLimitingFormatter(500)],
              onChanged: (text) => model.edit(reason: text),
            ),
          ),
        ),
        const SizedBox(height: 16),
        StaggerRevealItem(
          order: 2,
          child: AppTextField(
            label: 'Evidencia adicional (opcional)',
            controller: _evidence,
            enabled: v.editable && !_confirming,
            maxLines: 4,
            minLines: 2,
            footer: Text('${v.evidence.runes.length}/500'),
            inputFormatters: [UnicodeLengthLimitingFormatter(500)],
            onChanged: (text) => model.edit(evidence: text),
          ),
        ),
        const SizedBox(height: 20),
        StaggerRevealItem(
          order: 3,
          child: blocked
              ? TextButton(
                  onPressed: v.busy ? null : model.refresh,
                  child: const Text('Consultar cierre'),
                )
              : LoadingShimmer(
                  isLoading: v.busy,
                  loadingLabel: 'Confirmando recuperación',
                  child: FilledButton(
                    style: primaryActionButtonStyle(context, isLoading: v.busy),
                    onPressed: v.busy || _confirming
                        ? null
                        : () async {
                            if (v.frozen == null) {
                              setState(() => _confirming = true);
                              final confirmed = await confirmActionDialog(
                                context,
                                title: '¿Confirmar recuperación?',
                                description:
                                    'La búsqueda finalizará. Los carteles existentes seguirán mostrando el cierre desde el mismo QR.',
                                action: 'Confirmar',
                              );
                              if (!mounted) return;
                              setState(() => _confirming = false);
                              if (!confirmed) return;
                            }
                            if (await model.save() && mounted) widget.onSaved();
                          },
                    child: const Text('Confirmar recuperación'),
                  ),
                ),
        ),
      ],
    );
  }
}
