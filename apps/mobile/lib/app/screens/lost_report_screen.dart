import 'package:flutter/material.dart';
import '../../core/presentation/widgets/report_draft_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/report_location_search.dart';

import '../../core/presentation/widgets/case_screen_shell.dart';
import '../../core/presentation/widgets/confirm_discard_action.dart';
import '../../core/presentation/widgets/app_select_field.dart';
import '../../core/presentation/widgets/case_report_fields.dart';
import '../../core/presentation/widgets/shake_field.dart';
import '../../features/lost_cases/domain/entities/lost_case.dart';
import '../../features/found_cases/domain/entities/found_case.dart';
import '../../features/found_cases/presentation/screens/found_editor_screen.dart';
import '../../features/found_cases/presentation/state/found_editor_state.dart';
import '../../features/found_cases/presentation/view_models/found_editor_view_model.dart';
import '../../features/lost_cases/presentation/screens/case_editor_screen.dart';
import '../../features/lost_cases/presentation/state/case_editor_state.dart';
import '../../features/lost_cases/presentation/view_models/case_editor_view_model.dart';
import '../../features/lost_cases/presentation/widgets/case_public_content.dart';

/// Composes animal details and one common report block for a route lifetime.
/// Switching preserves animal drafts and transfers the shared event fields.
class LostReportScreen extends ConsumerStatefulWidget {
  const LostReportScreen({this.initialCommunity = false, super.key});
  final bool initialCommunity;

  @override
  ConsumerState<LostReportScreen> createState() => _LostReportScreenState();
}

class _LostReportScreenState extends ConsumerState<LostReportScreen> {
  late bool _community = widget.initialCommunity;
  bool _leaving = false, _canPop = false;
  final _place = TextEditingController();
  @override
  void dispose() {
    _place.dispose();
    super.dispose();
  }

  void _select(String selection) {
    final own = ref.read(caseEditorViewModelProvider).asData?.value;
    final other = ref.read(foundEditorViewModelProvider).asData?.value;
    final community = selection == 'unregistered';
    if (own?.busy == true ||
        own?.loadingPhotos == true ||
        other?.busy == true ||
        own?.lockedDraft != null ||
        other?.lockedDraft != null) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    if (community != _community &&
        own != null &&
        other != null &&
        own.ownerId == other.ownerId) {
      if (community) {
        ref
            .read(foundEditorViewModelProvider.notifier)
            .restoreReportDetails(
              ownerId: own.ownerId,
              dateTime: own.dateTimeDraft,
              latitude: own.latitude,
              longitude: own.longitude,
              placeReference: own.placeReference,
            );
      } else {
        ref
            .read(caseEditorViewModelProvider.notifier)
            .restoreReportDetails(
              ownerId: other.ownerId,
              dateTime: other.dateTimeDraft,
              latitude: other.latitude,
              longitude: other.longitude,
              placeReference: other.placeReference,
            );
      }
    }
    setState(() => _community = community);
    if (!community && selection != own?.pet?.id) {
      ref.read(caseEditorViewModelProvider.notifier).selectPet(selection);
    }
  }

  Widget _reportFields(
    CaseEditorState? own,
    FoundEditorState? other,
    bool blocked,
  ) {
    final dateTime = _community ? other!.dateTimeDraft : own!.dateTimeDraft;
    final place = _community ? other!.placeReference : own!.placeReference;
    if (_place.text != place) _place.text = place;
    final ownModel = ref.read(caseEditorViewModelProvider.notifier);
    final otherModel = ref.read(foundEditorViewModelProvider.notifier);
    return CaseReportFields(
      locationSearchBuilder: buildReportLocationSearch,
      key: const ValueKey('shared-report-fields'),
      dateTime: dateTime,
      latitude: _community ? other!.latitude : own!.latitude,
      longitude: _community ? other!.longitude : own!.longitude,
      placeController: _place,
      errorId: _community ? other!.errorId : own!.errorId,
      enabled: !blocked,
      dateInvalid: _community
          ? other!.invalidFields.contains(FoundField.date)
          : own!.invalidFields.contains(CaseField.date),
      pointInvalid: _community
          ? other!.invalidFields.contains(FoundField.point)
          : own!.invalidFields.contains(CaseField.point),
      placeInvalid: _community
          ? other!.invalidFields.contains(FoundField.place)
          : own!.invalidFields.contains(CaseField.place),
      onDate: _community ? otherModel.chooseDate : ownModel.chooseDate,
      onTime: _community ? otherModel.chooseTime : ownModel.chooseTime,
      onPoint: (lat, lon) => _community
          ? otherModel.edit(latitude: lat, longitude: lon)
          : ownModel.edit(latitude: lat, longitude: lon),
      onPlace: (text) => _community
          ? otherModel.edit(placeReference: text)
          : ownModel.edit(placeReference: text),
      onReview: _community ? otherModel.preview : ownModel.preview,
    );
  }

  Future<void> _leave() async {
    final own = ref.read(caseEditorViewModelProvider).asData?.value;
    final other = ref.read(foundEditorViewModelProvider).asData?.value;
    if (_leaving || own?.busy == true || other?.busy == true) return;
    _leaving = true;
    final dirty = own?.dirty == true || other?.dirty == true;
    final ambiguous = own?.lockedDraft != null || other?.attempted == true;
    final leave =
        !dirty ||
        await confirmDiscardAction(
          context,
          '¿Salir del reporte?',
          ambiguous
              ? 'El envío pudo haber llegado al servidor. Consulta tus casos antes de publicarlo otra vez.'
              : 'Conservaremos los borradores en este dispositivo para que puedas retomarlos.',
          'Salir',
        );
    if (!mounted || !leave) {
      _leaving = false;
      return;
    }
    if (other?.dirty == true &&
        !await ref.read(foundEditorViewModelProvider.notifier).saveForLater()) {
      // The failed draft may be in the inactive editor; make its feedback visible.
      if (mounted) setState(() => _community = true);
      _leaving = false;
      return;
    }
    if (own?.dirty == true &&
        !await ref.read(caseEditorViewModelProvider.notifier).saveForLater()) {
      if (mounted) setState(() => _community = false);
      _leaving = false;
      return;
    }
    _leaving = false;
    if (!mounted) return;
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
    ref.listen(caseEditorViewModelProvider, (previous, next) {
      if (next.isLoading ||
          next.hasError ||
          previous?.asData?.value.ownerId != next.asData?.value.ownerId) {
        _place.clear();
      }
    });
    ref.listen(foundEditorViewModelProvider, (previous, next) {
      if (next.isLoading ||
          next.hasError ||
          previous?.asData?.value.ownerId != next.asData?.value.ownerId) {
        _place.clear();
      }
    });
    // Both editors stay mounted for switching; checkpoints survive the route.
    // The community editor needs the session, but no catalogue request.
    final ownAsync = ref.watch(caseEditorViewModelProvider);
    final otherAsync = ref.watch(foundEditorViewModelProvider);
    final own = ownAsync.isLoading || ownAsync.hasError
        ? null
        : ownAsync.asData?.value;
    final other = otherAsync.isLoading || otherAsync.hasError
        ? null
        : otherAsync.asData?.value;
    final loading = _community ? otherAsync.isLoading : ownAsync.isLoading;
    final error = _community ? otherAsync.hasError : ownAsync.hasError;
    final form = _community
        ? other == null || other.stage == FoundStage.form
        : own == null || own.stage == CaseEditorStage.form;
    final preview = _community
        ? other?.stage == FoundStage.preview
        : own?.stage == CaseEditorStage.preview;
    final confirmed = _community
        ? other?.stage == FoundStage.confirmed
        : own?.stage == CaseEditorStage.confirmed;
    final blocked =
        _leaving ||
        ownAsync.isLoading ||
        otherAsync.isLoading ||
        own?.busy == true ||
        own?.loadingPhotos == true ||
        other?.busy == true ||
        own?.lockedDraft != null ||
        other?.lockedDraft != null;
    final dirty = own?.dirty == true || other?.dirty == true;
    final notice = error
        ? 'No pudimos preparar el reporte. Revisa tu sesión y conexión.'
        : _community && other?.issue != null
        ? foundFailureLabel(other!.issue)
        : !_community && own?.issue != null
        ? caseFailureLabel(own!.issue)
        : confirmed
        ? (_community ? 'Búsqueda publicada' : 'Caso publicado')
        : null;
    return PopScope(
      canPop: _canPop || (!dirty && !blocked),
      onPopInvokedWithResult: (popped, result) {
        if (!popped) _leave();
      },
      child: CaseScreenShell(
        title: 'Mascota perdida',
        onBack: _leave,
        loading: loading,
        immersive: preview,
        // Both forms share this completed timeline, including outgoing fields.
        count: form ? 13 : 2,
        stage: form ? 'form' : (_community, preview ? 'preview' : 'confirmed'),
        notice: notice,
        noticeIsError: !confirmed,
        noticeId: (
          _community,
          _community ? otherAsync.error : ownAsync.error,
          _community ? other?.ownerId : own?.ownerId,
          _community ? other?.errorId : own?.errorId,
          confirmed,
        ),
        persistentHeader: form
            ? ShakeField(
                errorId: own?.errorId ?? 0,
                hasError:
                    !_community &&
                    own?.invalidFields.contains(CaseField.pet) == true,
                child: AppSelectField<String>(
                  key: const ValueKey('report-pet-selection'),
                  label: 'Mascota a reportar',
                  sheetTitle: 'Mascota',
                  hint: 'Selecciona una mascota',
                  value: _community ? 'unregistered' : own?.pet?.id,
                  invalid:
                      !_community &&
                      own?.invalidFields.contains(CaseField.pet) == true,
                  options: [
                    for (final pet in own?.pets ?? [])
                      AppSelectOption(
                        value: pet.id,
                        label: pet.fields.name,
                        icon: Icons.pets_outlined,
                      ),
                    const AppSelectOption(
                      value: 'unregistered',
                      label: 'No está en mis mascotas',
                      icon: Icons.add_rounded,
                    ),
                  ],
                  onChanged: blocked ? null : _select,
                ),
              )
            : null,
        child: !form
            ? (_community
                  ? const FoundEditorScreen(
                      embedded: true,
                      petDetailsOnly: true,
                    )
                  : const CaseEditorScreen(
                      embedded: true,
                      petDetailsOnly: true,
                    ))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!loading &&
                      !error &&
                      (_community ? other != null : own != null))
                    ReportDraftStatus(
                      submissionState:
                          (_community
                                  ? other?.submissionStatus
                                  : own?.submissionStatus)
                              ?.name,
                      onRetry:
                          blocked ||
                              (_community
                                  ? other?.issue !=
                                        FoundFailureKind.localStorage
                                  : own?.issue != CaseFailureKind.localStorage)
                          ? null
                          : (_community
                                ? ref
                                      .read(
                                        foundEditorViewModelProvider.notifier,
                                      )
                                      .saveForLater
                                : ref
                                      .read(
                                        caseEditorViewModelProvider.notifier,
                                      )
                                      .saveForLater),
                      onDiscard: blocked
                          ? null
                          : () => _community
                                ? ref
                                      .read(
                                        foundEditorViewModelProvider.notifier,
                                      )
                                      .discardLocalDraft(other!.draftId)
                                : ref
                                      .read(
                                        caseEditorViewModelProvider.notifier,
                                      )
                                      .discardLocalDraft(own!.draftId),
                    ),
                  if (_community)
                    const FoundEditorScreen(
                      embedded: true,
                      petDetailsOnly: true,
                    )
                  else
                    const CaseEditorScreen(
                      embedded: true,
                      petDetailsOnly: true,
                    ),
                  if (form &&
                      !loading &&
                      !error &&
                      (_community ? other != null : own != null))
                    _reportFields(own, other, blocked),
                ],
              ),
      ),
    );
  }
}
