import '../../../../core/presentation/widgets/report_draft_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' show TileProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/case_screen_shell.dart';
import '../../../../core/presentation/widgets/confirm_discard_action.dart';
import '../../../../core/presentation/widgets/event_date_time_fields.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/photo_add_tile.dart';
import '../../../../core/presentation/widgets/photo_gallery_strip.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../../../../core/presentation/widgets/shake_field.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../../../core/presentation/widgets/stagger_reveal.dart';
import '../../../../core/presentation/widgets/unicode_length_limiting_formatter.dart';
import '../../../../core/presentation/widgets/zone_map_picker.dart';
import '../../../../core/presentation/widgets/validation_surface.dart';
import '../../../../core/presentation/formatters/case_date_label.dart';
import '../../domain/entities/sighting.dart';
import '../state/sighting_state.dart';
import '../view_models/sighting_view_model.dart';

class SightingScreen extends ConsumerStatefulWidget {
  const SightingScreen({this.createTileProvider, super.key});
  final TileProvider Function()? createTileProvider;
  @override
  ConsumerState<SightingScreen> createState() => _SightingScreenState();
}

class _SightingScreenState extends ConsumerState<SightingScreen> {
  final _comment = TextEditingController();
  bool _leaving = false, _canPop = false;
  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _leave() async {
    final v = ref.read(sightingViewModelProvider).asData?.value;
    if (_leaving || v?.busy == true) return;
    _leaving = true;
    final leave =
        v?.dirty != true ||
        await confirmDiscardAction(
          context,
          '¿Salir del avistamiento?',
          v?.frozen != null
              ? 'El envío pudo haberse guardado. Reintenta antes de salir para confirmar el resultado y evitar otro reporte.'
              : 'Conservaremos el borrador en este dispositivo para que puedas retomarlo.',
          'Salir',
        );
    _leaving = false;
    if (!mounted || !leave) return;
    if (!await ref.read(sightingViewModelProvider.notifier).saveForLater()) {
      return;
    }
    if (!mounted) return;
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
    ref.listen(sightingViewModelProvider, (previous, next) {
      if (next.isLoading ||
          next.hasError ||
          previous?.asData?.value.owner != next.asData?.value.owner) {
        _comment.clear();
      }
    });
    final async = ref.watch(sightingViewModelProvider),
        v = async.isLoading || async.hasError ? null : async.asData?.value;
    final m = ref.read(sightingViewModelProvider.notifier);
    if (v != null && _comment.text != v.comment) _comment.text = v.comment;
    final message = async.hasError
        ? 'No pudimos preparar el avistamiento. Revisa tu sesión y conexión.'
        : v?.receipt != null
        ? 'Avistamiento guardado'
        : v?.issue != null
        ? sightingIssueLabel(v!.issue!)
        : null;
    return PopScope(
      canPop: _canPop || (v?.dirty != true && v?.busy != true),
      onPopInvokedWithResult: (popped, result) {
        if (!popped) _leave();
      },
      child: CaseScreenShell(
        title: 'La vi',
        count: 7,
        onBack: _leave,
        stage: v?.receipt == null ? 'form' : 'confirmed',
        loading: async.isLoading,
        notice: message,
        noticeId: (async.error, v?.owner, v?.notice, v?.receipt),
        noticeIsError: v?.receipt == null,
        child: async.isLoading
            ? const SkeletonFormFields(fieldCount: 4)
            : async.hasError
            ? TextButton(onPressed: m.retry, child: const Text('Reintentar'))
            : v == null
            ? const SizedBox.shrink()
            : v.receipt != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Hora observada: ${caseDateTimeLabel(v.frozen!.observedAt)}',
                  ),
                  const SizedBox(height: 12),
                  Text('Recibido: ${caseDateTimeLabel(v.receipt!.receivedAt)}'),
                  const SizedBox(height: 16),
                  const Text(
                    'La búsqueda sigue abierta. Solo su responsable puede confirmar la recuperación.',
                  ),
                  if (v.receipt!.late)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text(
                        'Observación de hace más de 24 horas. Se conservó la hora real del avistamiento.',
                      ),
                    ),
                  const SizedBox(height: 24),
                  FilledButton(
                    style: primaryActionButtonStyle(context),
                    onPressed: _leave,
                    child: const Text('Volver a la ficha'),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ReportDraftStatus(
                    submissionState: v.submissionStatus?.name,
                    onRetry: v.issue == SightingIssue.localStorage && !v.busy
                        ? m.saveForLater
                        : null,
                    onDiscard: v.busy || v.frozen != null
                        ? null
                        : () => m.discardLocalDraft(v.id),
                  ),
                  _form(v, m),
                ],
              ),
      ),
    );
  }

  Widget _field(SightingState v, String field, Widget child) => field == 'point'
      ? ValidationSurface(
          invalid: v.fields.contains(field),
          errorId: v.notice,
          child: child,
        )
      : ShakeField(
          errorId: v.notice,
          hasError: v.fields.contains(field),
          child: child,
        );
  Widget _form(SightingState v, SightingViewModel m) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const StaggerRevealItem(
        order: 0,
        child: Text(
          'Indica cuándo y dónde la viste. El punto exacto, comentario y foto se guardan de forma privada; no aparecen en la ficha pública.',
        ),
      ),
      const SizedBox(height: 20),
      StaggerRevealItem(
        order: 1,
        child: _field(
          v,
          'observedAt',
          EventDateTimeFields(
            value: v.dateTime,
            invalid: v.fields.contains('observedAt'),
            onDate: !v.editable
                ? null
                : () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: v.dateTime.date ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (mounted && date != null) m.date(date);
                  },
            onTime: !v.editable
                ? null
                : () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: v.dateTime.hour == null
                          ? TimeOfDay.now()
                          : TimeOfDay(
                              hour: v.dateTime.hour!,
                              minute: v.dateTime.minute!,
                            ),
                    );
                    if (mounted && time != null) m.time(time.hour, time.minute);
                  },
          ),
        ),
      ),
      const SizedBox(height: 20),
      StaggerRevealItem(
        order: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Lugar del avistamiento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _field(
              v,
              'point',
              ZoneMapPicker(
                createTileProvider: widget.createTileProvider,
                latitude: v.point?.latitude,
                longitude: v.point?.longitude,
                radiusMeters: 200,
                onSelect: v.editable ? m.point : null,
                readOnly: !v.editable,
              ),
            ),
            LoadingShimmer(
              isLoading: v.busy,
              loadingLabel: 'Obteniendo ubicación',
              child: TextButton.icon(
                onPressed: v.editable ? m.locate : null,
                icon: const Icon(Icons.my_location),
                label: const Text('Usar mi ubicación'),
              ),
            ),
            const Text(
              'También puedes tocar el mapa para marcar el punto manualmente.',
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      StaggerRevealItem(
        order: 3,
        child: _field(
          v,
          'comment',
          AppTextField(
            label: 'Comentario (opcional)',
            controller: _comment,
            minLines: 2,
            maxLines: 4,
            enabled: v.editable,
            invalid: v.fields.contains('comment'),
            onChanged: m.comment,
            inputFormatters: const [UnicodeLengthLimitingFormatter(500)],
            footer: Align(
              alignment: Alignment.centerRight,
              child: Text('${v.comment.runes.length}/500'),
            ),
          ),
        ),
      ),
      const SizedBox(height: 20),
      StaggerRevealItem(
        order: 4,
        child: ValidationSurface(
          invalid: v.fields.contains('photo'),
          errorId: v.notice,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Foto (opcional)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final size = PhotoGalleryStrip.detailTileSize(
                    constraints.maxWidth,
                  );
                  return PhotoGalleryStrip(
                    children: [
                      if (v.photo != null)
                        PhotoGalleryTile(
                          id: v.id,
                          size: size,
                          remove: v.editable ? m.removePhoto : null,
                          child: Image.memory(
                            v.photo!,
                            width: size,
                            height: size,
                            fit: BoxFit.cover,
                            errorBuilder: (_, error, stack) =>
                                const Icon(Icons.broken_image_outlined),
                          ),
                        )
                      else
                        PhotoAddTile(
                          size: size,
                          invalid: v.fields.contains('photo'),
                          semanticLabel: 'Elegir foto de la galería',
                          onTap: v.editable ? () => m.photo() : null,
                        ),
                    ],
                  );
                },
              ),
              TextButton.icon(
                onPressed: v.editable ? () => m.photo(camera: true) : null,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Tomar foto'),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 24),
      StaggerRevealItem(
        order: 5,
        child: ValidationSurface(
          invalid: v.issue != null && v.fields.isEmpty,
          errorId: v.notice,
          child: LoadingShimmer(
            isLoading: v.busy,
            loadingLabel: 'Enviando avistamiento',
            child: FilledButton(
              style: primaryActionButtonStyle(context, isLoading: v.busy),
              onPressed: v.busy || v.issue == SightingIssue.closed
                  ? null
                  : m.submit,
              child: Text(
                v.frozen != null ? 'Reintentar envío' : 'Enviar avistamiento',
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
