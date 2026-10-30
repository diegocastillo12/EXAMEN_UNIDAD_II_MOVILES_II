import 'package:flutter/material.dart';
import 'confirm_action_dialog.dart';
import 'loading_shimmer.dart';

/// State and actions are provided by each editor's ViewModel.
class ReportDraftStatus extends StatefulWidget {
  const ReportDraftStatus({
    required this.onRetry,
    this.onDiscard,
    this.submissionState,
    super.key,
  });
  final String? submissionState;
  final Future<bool> Function()? onRetry, onDiscard;
  @override
  State<ReportDraftStatus> createState() => _ReportDraftStatusState();
}

class _ReportDraftStatusState extends State<ReportDraftStatus> {
  bool _saving = false, _discarding = false, _confirming = false;
  bool get _busy => _saving || _discarding || _confirming;
  Future<void> _retry() async {
    final retry = widget.onRetry;
    if (_busy || retry == null) return;
    setState(() => _saving = true);
    try {
      await retry();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _discard() async {
    final discard = widget.onDiscard;
    if (_busy || discard == null) return;
    setState(() => _confirming = true);
    final confirmed = await confirmActionDialog(
      context,
      title: '¿Descartar borrador?',
      description:
          'Se eliminarán los datos y las fotos sin publicar de este borrador.',
      action: 'Descartar',
    );
    if (!mounted) return;
    setState(() {
      _confirming = false;
      _discarding = confirmed;
    });
    if (!confirmed) return;
    try {
      await discard();
    } finally {
      if (mounted) setState(() => _discarding = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(reportSubmissionStatusLabel(widget.submissionState)),
        const Text(
          'Puedes retomarlo desde este formulario en este dispositivo.',
        ),
        if (widget.onRetry != null)
          LoadingShimmer(
            isLoading: _saving,
            loadingLabel: 'Guardando borrador local',
            child: TextButton(
              onPressed: _busy ? null : _retry,
              child: const Text('Reintentar guardado local'),
            ),
          ),
        if (widget.onDiscard != null)
          LoadingShimmer(
            isLoading: _discarding,
            loadingLabel: 'Descartando borrador local',
            child: TextButton(
              onPressed: _busy ? null : _discard,
              child: const Text('Descartar borrador'),
            ),
          ),
      ],
    ),
  );
}

String reportSubmissionStatusLabel(String? state) => switch (state) {
  'pending' => 'Pendiente de envío',
  'sending' => 'Pendiente · Envío en curso',
  'failed' => 'Fallido · Requiere revisión',
  'published' => 'Publicado',
  _ => 'Borrador · Sin publicar',
};
