import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' show TileProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/formatters/case_date_label.dart';
import '../../../../core/presentation/widgets/app_select_field.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/case_screen_shell.dart';
import '../../../../core/presentation/widgets/case_photo_failure.dart';
import '../../../../core/presentation/widgets/confirm_discard_action.dart';
import '../../../../core/presentation/widgets/content_refresh.dart';
import '../../../../core/presentation/widgets/entity_card_surface.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../../../core/presentation/widgets/unicode_length_limiting_formatter.dart';
import '../../../../core/presentation/widgets/validation_surface.dart';
import '../../../../core/presentation/widgets/zone_map_picker.dart';
import '../../../../core/presentation/widgets/pull_to_refresh.dart';
import '../state/case_timeline_state.dart';
import '../view_models/sighting_review_view_model.dart';
import '../../domain/entities/case_timeline.dart';

class SightingReviewScreen extends ConsumerStatefulWidget {
  const SightingReviewScreen({
    required this.reviewKey,
    this.createTileProvider,
    this.reportAction,
    super.key,
  });
  final ReviewKey reviewKey;
  final TileProvider Function()? createTileProvider;
  final Widget? reportAction;
  @override
  ConsumerState<SightingReviewScreen> createState() =>
      _SightingReviewScreenState();
}

class _SightingReviewScreenState extends ConsumerState<SightingReviewScreen> {
  final _reason = TextEditingController();
  bool _leaving = false, _canPop = false;
  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _leave() async {
    final v = ref
        .read(sightingReviewViewModelProvider(widget.reviewKey))
        .asData
        ?.value;
    if (_leaving || v?.busy == true) return;
    _leaving = true;
    final dirty =
        v != null &&
        (v.reason.isNotEmpty || v.selected.isNotEmpty || v.frozen != null);
    final leave =
        !dirty ||
        await confirmDiscardAction(
          context,
          '¿Salir de la revisión?',
          v.frozen != null
              ? 'La revisión pudo haberse guardado. Reintenta la misma decisión para confirmar el resultado antes de salir.'
              : 'Se descartarán la clasificación y el motivo que todavía no guardaste.',
          'Salir',
        );
    _leaving = false;
    if (!mounted || !leave) return;
    setState(() => _canPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = sightingReviewViewModelProvider(widget.reviewKey);
    ref.listen(provider, (previous, next) {
      if (next.isLoading ||
          next.hasError ||
          previous?.asData?.value.owner != next.asData?.value.owner) {
        _reason.clear();
      }
    });
    final async = ref.watch(provider),
        m = ref.read(provider.notifier),
        v = async.isLoading || async.hasError ? null : async.asData?.value;
    if (v != null && _reason.text != v.reason) _reason.text = v.reason;
    final error = async.error is TimelineFailure
        ? (async.error as TimelineFailure).issue
        : TimelineIssue.unavailable;
    return PopScope(
      canPop:
          _canPop ||
          (v?.busy != true &&
              (v == null ||
                  (v.reason.isEmpty &&
                      v.selected.isEmpty &&
                      v.frozen == null))),
      onPopInvokedWithResult: (popped, result) {
        if (!popped) _leave();
      },
      child: PullToRefresh(
        onRefresh: v == null ? null : m.refresh,
        enabled:
            v?.busy != true && (v?.frozen == null || v?.conflicted == true),
        child: CaseScreenShell(
          title: 'Revisión',
          count: 4,
          onBack: _leave,
          loading: async.isLoading,
          notice: async.hasError
              ? timelineFailureLabel(error)
              : v?.failure != null
              ? timelineFailureLabel(v!.failure!)
              : v?.saved == true
              ? 'Revisión guardada'
              : null,
          noticeId: (async.error, v?.owner, v?.notice),
          noticeIsError: v?.saved != true,
          child: async.isLoading
              ? const SkeletonFormFields(fieldCount: 4)
              : async.hasError
              ? TextButton(onPressed: m.retry, child: const Text('Reintentar'))
              : v == null
              ? const SizedBox.shrink()
              : ContentRefresh(
                  refreshing: v.work == ReviewWork.refresh,
                  label: 'Actualizando evidencia',
                  child: _content(v, m),
                ),
        ),
      ),
    );
  }

  Widget _content(SightingReviewState v, SightingReviewViewModel m) {
    final d = v.detail;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StaggerRevealItem(
          order: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Observado: ${caseDateTimeLabel(d.observedAt)}'),
              Text('Recibido: ${caseDateTimeLabel(d.receivedAt)}'),
              if (d.late) const Text('Reporte tardío · más de 24 horas'),
              const SizedBox(height: 16),
              Text(
                'Revisión: ${timelineStateLabel(d.state)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'La clasificación evalúa esta evidencia. No garantiza la ubicación actual de la mascota ni confirma su recuperación.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        StaggerRevealItem(
          order: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Evidencia recibida',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(d.comment.isEmpty ? 'Sin comentario' : d.comment),
              if (widget.reportAction != null) widget.reportAction!,
              const SizedBox(height: 16),
              ZoneMapPicker(
                latitude: d.latitude,
                longitude: d.longitude,
                radiusMeters: d.accuracy?.round() ?? 0,
                readOnly: true,
                readOnlyNavigation: true,
                onSelect: null,
                createTileProvider: widget.createTileProvider,
              ),
              const SizedBox(height: 8),
              Text(
                d.locationSource == 'gps'
                    ? 'Ubicación GPS · precisión ${d.accuracy?.round()} m'
                    : 'Punto marcado manualmente',
              ),
              const Text(
                'Punto exacto y foto privados, disponibles para el responsable del caso.',
              ),
              const SizedBox(height: 16),
              if (!d.hasPhoto)
                const Text('Sin foto adjunta')
              else if (v.photo != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.memory(
                    v.photo!,
                    semanticLabel: 'Foto adjunta al avistamiento',
                    height: 320,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (_, error, stack) => Column(
                      children: [
                        const CasePhotoFailure(),
                        TextButton(
                          onPressed: v.busy ? null : m.evidence,
                          child: const Text('Reintentar foto'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                LoadingShimmer(
                  isLoading: v.work == ReviewWork.photo,
                  loadingLabel: 'Consultando foto privada',
                  child: TextButton.icon(
                    onPressed: v.busy ? null : m.evidence,
                    icon: const Icon(Icons.photo_outlined),
                    label: const Text('Ver foto'),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        StaggerRevealItem(
          order: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (d.canReview && !v.closed) ...[
                const Text(
                  'Clasificar evidencia',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ValidationSurface(
                  invalid:
                      v.failure == TimelineIssue.invalid ||
                      v.failure == TimelineIssue.transition,
                  errorId: v.notice,
                  child: AppSelectField<String>(
                    label: 'Clasificación',
                    value: v.selected.isEmpty ? null : v.selected,
                    options: const [
                      AppSelectOption(
                        value: 'useful',
                        label: 'Útil',
                        icon: Icons.check_circle_outline,
                      ),
                      AppSelectOption(
                        value: 'doubtful',
                        label: 'Dudoso',
                        icon: Icons.help_outline,
                      ),
                      AppSelectOption(
                        value: 'rejected',
                        label: 'Rechazado',
                        icon: Icons.cancel_outlined,
                      ),
                      AppSelectOption(
                        value: 'confirmed',
                        label: 'Confirmado',
                        icon: Icons.verified_outlined,
                      ),
                    ],
                    onChanged: v.editable ? m.select : null,
                  ),
                ),
                const SizedBox(height: 16),
                ValidationSurface(
                  invalid: v.failure == TimelineIssue.invalid,
                  errorId: v.notice,
                  child: AppTextField(
                    label: 'Motivo de la revisión',
                    controller: _reason,
                    minLines: 2,
                    maxLines: 5,
                    enabled: v.editable,
                    invalid: v.failure == TimelineIssue.invalid,
                    onChanged: m.reason,
                    inputFormatters: const [
                      UnicodeLengthLimitingFormatter(500),
                    ],
                    footer: Align(
                      alignment: Alignment.centerRight,
                      child: Text('${v.reason.runes.length}/500'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ValidationSurface(
                  invalid: v.failure != null,
                  errorId: v.notice,
                  child: LoadingShimmer(
                    isLoading: v.work == ReviewWork.save,
                    loadingLabel: 'Guardando revisión',
                    child: FilledButton(
                      style: primaryActionButtonStyle(
                        context,
                        isLoading: v.work == ReviewWork.save,
                      ),
                      onPressed: v.busy || v.conflicted ? null : m.save,
                      child: const Text('Guardar revisión'),
                    ),
                  ),
                ),
              ] else
                const Text(
                  'Caso cerrado · historial disponible en modo lectura.',
                ),
              if (v.conflicted)
                TextButton(
                  onPressed: v.busy ? null : m.refresh,
                  child: const Text('Actualizar y revisar'),
                )
              else if (v.frozen == null && v.failure != null)
                TextButton(
                  onPressed: v.busy ? null : m.refresh,
                  child: const Text('Reintentar consulta'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        StaggerRevealItem(
          order: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Revisiones anteriores',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (d.history.isEmpty) const Text('Sin revisiones registradas'),
              for (final r in d.history)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EntityCardSurface(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '${timelineStateLabel(r.previousState)} a ${timelineStateLabel(r.state)}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(r.reason),
                          const SizedBox(height: 8),
                          Text(caseDateTimeLabel(r.reviewedAt)),
                          const Text('Responsable del caso'),
                        ],
                      ),
                    ),
                  ),
                ),
              if (d.nextRevision != null)
                LoadingShimmer(
                  isLoading: v.work == ReviewWork.history,
                  loadingLabel: 'Consultando revisiones anteriores',
                  child: TextButton(
                    onPressed: v.busy ? null : m.moreHistory,
                    child: const Text('Ver más revisiones'),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
