import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/formatters/case_date_label.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/case_screen_shell.dart';
import '../../../../core/presentation/widgets/confirm_discard_action.dart';
import '../../../../core/presentation/widgets/content_refresh.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../../../core/presentation/widgets/unicode_length_limiting_formatter.dart';
import '../../../../core/presentation/widgets/validation_surface.dart';
import '../../domain/entities/moderation_appeal.dart';
import '../state/appeals_state.dart';
import '../view_models/appeals_view_model.dart';

class AppealsScreen extends ConsumerStatefulWidget {
  const AppealsScreen({super.key});
  @override
  ConsumerState<AppealsScreen> createState() => _AppealsScreenState();
}

class _AppealsScreenState extends ConsumerState<AppealsScreen> {
  final _reason = TextEditingController();
  String? _decision;
  bool _leaving = false;
  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _leave() async {
    final v = ref.read(appealsViewModelProvider).asData?.value;
    if (v?.busy == true || _leaving) return;
    if (v?.dirty == true &&
        !await confirmDiscardAction(
          context,
          '¿Salir de la apelación?',
          'Se descartará el motivo. Si no se confirmó el envío, reintenta primero para consultar su resultado.',
          'Salir',
        )) {
      return;
    }
    if (!mounted) return;
    if (v?.selected != null) {
      ref.read(appealsViewModelProvider.notifier).select(null, discard: true);
      return;
    }
    setState(() => _leaving = true);
    await Future<void>.delayed(Duration.zero);
    if (mounted) context.pop();
  }

  String _message(AppealIssue issue) => switch (issue) {
    AppealIssue.invalid => 'Escribe un motivo de hasta 1000 caracteres.',
    AppealIssue.forbidden => 'No tienes permiso para consultar esta apelación.',
    AppealIssue.conflict =>
      'El estado cambió. Actualiza la consulta para continuar.',
    AppealIssue.unavailable =>
      'No pudimos confirmar la operación. Puedes reintentar.',
  };
  String _action(String action) => switch (action) {
    'hide' => 'Contenido oculto',
    'show' => 'Visibilidad restaurada',
    _ => 'Denuncia resuelta sin cambiar visibilidad',
  };
  @override
  Widget build(BuildContext context) {
    final async = ref.watch(appealsViewModelProvider),
        model = ref.read(appealsViewModelProvider.notifier);
    final value = async.asData?.value;
    if (_decision != value?.selected?.id || value?.saved == true) {
      _decision = value?.selected?.id;
      _reason.text = value?.reason ?? '';
    }
    final issue =
        value?.issue ??
        (async.error is AppealFailure
            ? (async.error as AppealFailure).issue
            : AppealIssue.unavailable);
    return PopScope(
      canPop: _leaving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: CaseScreenShell(
        title: 'Mis apelaciones',
        stage: (value?.actor, value?.selected?.id),
        loading: async.isLoading,
        onBack: _leave,
        notice: async.hasError || value?.issue != null
            ? _message(issue)
            : value?.saved == true
            ? 'Apelación enviada.'
            : null,
        noticeIsError: value?.saved != true,
        noticeId: (async.error, value?.actor, value?.notice),
        child: async.isLoading
            ? const SkeletonFormFields(fieldCount: 3)
            : value == null
            ? TextButton(
                onPressed: model.retry,
                child: const Text('Reintentar consulta'),
              )
            : ContentRefresh(
                refreshing: value.busy,
                label: 'Actualizando apelaciones',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextButton(
                      onPressed:
                          value.busy ||
                              (value.frozen != null && !value.refreshRequired)
                          ? null
                          : model.load,
                      child: const Text('Actualizar consulta'),
                    ),
                    if (value.selected == null) ...[
                      if (value.items.isEmpty)
                        const Text(
                          'No hay decisiones de moderación sobre tu contenido.',
                        ),
                      for (final item in value.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _action(item.action),
                                style: const TextStyle(fontSize: 20),
                              ),
                              Text(caseDateTimeLabel(item.decidedAt)),
                              Text(item.reason),
                              Text(
                                item.appeal?.answer != null
                                    ? 'Respondida'
                                    : item.appeal != null
                                    ? 'Pendiente de respuesta'
                                    : 'Puedes solicitar una revisión',
                              ),
                              TextButton(
                                onPressed: value.busy
                                    ? null
                                    : () => model.select(item),
                                child: Text(
                                  item.appeal == null
                                      ? 'Apelar decisión'
                                      : 'Consultar apelación',
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (value.next != null)
                        TextButton(
                          onPressed: value.busy
                              ? null
                              : () => model.load(more: true),
                          child: const Text('Ver más'),
                        ),
                    ] else
                      ..._detail(value, model),
                  ],
                ),
              ),
      ),
    );
  }

  List<Widget> _detail(AppealsState value, AppealsViewModel model) {
    final decision = value.selected!,
        appeal = decision.appeal,
        answer = appeal?.answer;
    return [
      Text(_action(decision.action), style: const TextStyle(fontSize: 20)),
      Text(caseDateTimeLabel(decision.decidedAt)),
      const SizedBox(height: 12),
      Text(decision.reason),
      if (appeal != null) ...[
        const SizedBox(height: 20),
        const Text('Apelación', style: TextStyle(fontSize: 20)),
        Text(appeal.reason),
        Text('Enviada: ${caseDateTimeLabel(appeal.submittedAt)}'),
        if (answer == null)
          const Text('Pendiente de respuesta')
        else ...[
          const SizedBox(height: 20),
          const Text('Respuesta de moderación', style: TextStyle(fontSize: 20)),
          Text(answer.reason),
          Text('Respondida: ${caseDateTimeLabel(answer.answeredAt)}'),
        ],
      ] else ...[
        const SizedBox(height: 20),
        const Text(
          'Explica por qué solicitas revisar esta decisión. El motivo solo se comparte con los revisores autorizados.',
        ),
        const SizedBox(height: 16),
        ValidationSurface(
          invalid: value.issue == AppealIssue.invalid,
          errorId: value.notice,
          child: AppTextField(
            controller: _reason,
            label: 'Motivo de la apelación',
            minLines: 3,
            maxLines: 6,
            enabled: !value.busy && value.frozen == null,
            invalid: value.issue == AppealIssue.invalid,
            inputFormatters: [UnicodeLengthLimitingFormatter(1000)],
            footer: Text('${value.reason.runes.length}/1000'),
            onChanged: model.edit,
          ),
        ),
        const SizedBox(height: 20),
        LoadingShimmer(
          isLoading: value.busy,
          loadingLabel: 'Enviando apelación',
          child: FilledButton(
            style: primaryActionButtonStyle(context, isLoading: value.busy),
            onPressed: value.busy || value.refreshRequired
                ? null
                : model.submit,
            child: Text(
              value.retrying ? 'Reintentar mismo envío' : 'Enviar apelación',
            ),
          ),
        ),
      ],
    ];
  }
}
