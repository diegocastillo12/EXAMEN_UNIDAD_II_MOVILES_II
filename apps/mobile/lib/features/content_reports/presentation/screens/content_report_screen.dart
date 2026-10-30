import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/formatters/case_date_label.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/case_screen_shell.dart';
import '../../../../core/presentation/widgets/confirm_discard_action.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../../../core/presentation/widgets/unicode_length_limiting_formatter.dart';
import '../../../../core/presentation/widgets/validation_surface.dart';
import '../../domain/entities/content_report.dart';
import '../state/content_report_state.dart';
import '../view_models/content_report_view_model.dart';

class ContentReportScreen extends ConsumerStatefulWidget {
  const ContentReportScreen({required this.target, super.key});
  final ReportTarget target;
  @override
  ConsumerState<ContentReportScreen> createState() =>
      _ContentReportScreenState();
}

class _ContentReportScreenState extends ConsumerState<ContentReportScreen> {
  final _reason = TextEditingController(), _evidence = TextEditingController();
  bool _canPop = false, _leaving = false;
  @override
  void dispose() {
    _reason.dispose();
    _evidence.dispose();
    super.dispose();
  }

  Future<void> _leave() async {
    final value = ref
        .read(contentReportViewModelProvider(widget.target))
        .asData
        ?.value;
    if (value?.busy == true || _leaving) return;
    _leaving = true;
    final leave =
        value?.dirty != true ||
        await confirmDiscardAction(
          context,
          '¿Salir de la denuncia?',
          value?.frozen != null
              ? 'El envío pudo haberse guardado. Reintenta la misma operación para confirmar el resultado antes de salir.'
              : 'Se descartarán el motivo y la evidencia que todavía no enviaste.',
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
    final provider = contentReportViewModelProvider(widget.target);
    ref.listen(provider, (previous, next) {
      if (next.isLoading ||
          next.hasError ||
          previous?.asData?.value.actor != next.asData?.value.actor) {
        _reason.clear();
        _evidence.clear();
      }
    });
    final async = ref.watch(provider), model = ref.read(provider.notifier);
    final value = async.isLoading || async.hasError
        ? null
        : async.asData?.value;
    if (value != null) {
      if (_reason.text != value.reason) _reason.text = value.reason;
      if (_evidence.text != value.evidence) _evidence.text = value.evidence;
    }
    final issue = async.error is ReportFailure
        ? (async.error as ReportFailure).issue
        : ReportIssue.unavailable;
    return PopScope(
      canPop: _canPop || (value?.busy != true && value?.dirty != true),
      onPopInvokedWithResult: (popped, _) {
        if (!popped) _leave();
      },
      child: CaseScreenShell(
        title: 'Denuncia',
        count: value?.receipt == null ? 4 : 1,
        stage: value?.receipt == null ? 'form' : 'receipt',
        loading: async.isLoading,
        onBack: _leave,
        notice: async.hasError
            ? reportFailureLabel(issue)
            : value?.issue != null
            ? reportFailureLabel(value!.issue!)
            : value?.receipt != null
            ? 'Denuncia guardada'
            : null,
        noticeIsError: value?.receipt == null,
        noticeId: (async.error, value?.actor, value?.notice),
        child: async.isLoading
            ? const SkeletonFormFields(fieldCount: 2)
            : value == null
            ? TextButton(
                onPressed: model.retry,
                child: const Text('Reintentar'),
              )
            : _content(value, model),
      ),
    );
  }

  Widget _content(ContentReportState value, ContentReportViewModel model) {
    final receipt = value.receipt;
    if (receipt != null) {
      return StaggerRevealItem(
        order: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Denuncia registrada',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tu denuncia quedó guardada para revisión. El contenido mantiene su estado; este recibo no implica una decisión de moderación.',
            ),
            const SizedBox(height: 20),
            Text('Fecha: ${caseDateTimeLabel(receipt.submittedAt)}'),
            const SizedBox(height: 12),
            Text('Motivo: ${receipt.reason}'),
            if (receipt.evidence != null) ...[
              const SizedBox(height: 12),
              Text('Evidencia: ${receipt.evidence}'),
            ],
            const SizedBox(height: 12),
            SelectableText('Referencia: ${receipt.id}'),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _leave,
              child: const Text('Volver al contenido'),
            ),
          ],
        ),
      );
    }
    final invalid = value.issue == ReportIssue.invalid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StaggerRevealItem(
          order: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.target.kind == 'sighting'
                    ? 'Denunciar este avistamiento'
                    : 'Denunciar esta publicación',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Explica qué contenido necesita revisión. El motivo y la evidencia son privados: solo tú y las cuentas autorizadas para revisar denuncias pueden consultarlos. Enviar una denuncia no oculta ni cierra el caso.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        StaggerRevealItem(
          order: 1,
          child: ValidationSurface(
            invalid: invalid,
            errorId: value.notice,
            child: AppTextField(
              label: 'Motivo',
              controller: _reason,
              enabled: value.editable,
              invalid: invalid,
              maxLines: 4,
              minLines: 2,
              footer: Text('${value.reason.runes.length}/500'),
              inputFormatters: [UnicodeLengthLimitingFormatter(500)],
              onChanged: (text) => model.edit(reason: text),
            ),
          ),
        ),
        const SizedBox(height: 16),
        StaggerRevealItem(
          order: 2,
          child: ValidationSurface(
            invalid: invalid && value.evidence.trim().runes.length > 1000,
            errorId: value.notice,
            child: AppTextField(
              label: 'Evidencia escrita (opcional)',
              controller: _evidence,
              enabled: value.editable,
              invalid: invalid && value.evidence.trim().runes.length > 1000,
              maxLines: 5,
              minLines: 2,
              footer: Text('${value.evidence.runes.length}/1000'),
              inputFormatters: [UnicodeLengthLimitingFormatter(1000)],
              onChanged: (text) => model.edit(evidence: text),
            ),
          ),
        ),
        const SizedBox(height: 20),
        StaggerRevealItem(
          order: 3,
          child: LoadingShimmer(
            isLoading: value.busy,
            loadingLabel: 'Enviando denuncia',
            child: FilledButton(
              style: primaryActionButtonStyle(context, isLoading: value.busy),
              onPressed: value.busy || value.issue == ReportIssue.conflict
                  ? null
                  : model.submit,
              child: const Text('Enviar denuncia'),
            ),
          ),
        ),
      ],
    );
  }
}
