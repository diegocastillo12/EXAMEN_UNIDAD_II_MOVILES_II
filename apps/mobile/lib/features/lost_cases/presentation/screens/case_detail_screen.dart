import '../../../../core/presentation/widgets/cached_case_notice.dart';
import '../../domain/entities/lost_case.dart';
import '../../../../core/presentation/widgets/content_refresh.dart';
import '../../../../core/presentation/widgets/collection_add_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/case_public_cards_skeleton.dart';
import '../view_models/case_read_view_model.dart';
import '../../../../core/presentation/widgets/case_public_screen_shell.dart';
import '../widgets/case_public_content.dart';

class CaseDetailScreen extends ConsumerWidget {
  const CaseDetailScreen({
    required this.id,
    this.recoveryActions,
    this.contact,
    this.posterAction,
    this.timelineAction,
    this.shareActionBuilder,
    super.key,
  });
  final Widget? contact;
  final Widget? posterAction;
  final Widget? timelineAction;
  final Widget Function(String, String, bool)? shareActionBuilder;
  final String id;
  final Widget Function(PublicLostCase, VoidCallback)? recoveryActions;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(publicCaseViewModelProvider(id));
    final model = ref.read(publicCaseViewModelProvider(id).notifier);
    return CasePublicScreenShell(
      shareAction:
          !state.isLoading &&
              !state.hasError &&
              state.asData?.value.value != null &&
              state.asData?.value.cachedAt == null
          ? shareActionBuilder?.call(
              state.requireValue.value!.fields.name,
              'Mascota perdida',
              true,
            )
          : null,
      loading: state.isLoading,
      notice: state.asData?.value.storageFailed == true
          ? 'No pudimos actualizar la copia de este dispositivo. Reintenta actualizar.'
          : state.hasError
          ? 'No pudimos consultar el caso.'
          : state.asData?.value.refreshFailed == true
          ? 'No pudimos actualizar. Se conserva la última consulta.'
          : !state.isLoading && state.asData?.value.value == null
          ? 'Este caso no está disponible públicamente.'
          : null,
      noticeId: state.error ?? state.asData?.value,
      child: state.isLoading
          ? const CasePublicCardsSkeleton()
          : state.hasError
          ? Column(
              children: [
                TextButton(
                  onPressed: model.retry,
                  child: const Text('Reintentar'),
                ),
              ],
            )
          : state.requireValue.value == null
          ? const SizedBox.shrink()
          : ContentRefresh(
              refreshing: state.requireValue.refreshing,
              label: 'Actualizando caso',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.requireValue.cachedAt != null)
                    CachedCaseNotice(
                      storedAt: state.requireValue.cachedAt!,
                      onRefresh: state.requireValue.refreshing
                          ? null
                          : model.retry,
                    ),
                  CasePublicContent(
                    offline: state.requireValue.cachedAt != null,
                    value: state.requireValue.value!,
                    contact: state.requireValue.cachedAt == null
                        ? contact
                        : null,
                    actions: Column(
                      children: state.requireValue.cachedAt != null
                          ? const []
                          : [
                              if (timelineAction != null) timelineAction!,
                              if (state.requireValue.value!.status ==
                                  'active') ...[
                                CollectionAddButton(
                                  label: 'Reportar avistamiento',
                                  icon: Icons.visibility_outlined,
                                  accented: true,
                                  route: '/home/sightings/lost/$id',
                                ),
                                const SizedBox(height: 20),
                              ],
                              if (state.requireValue.value!.canResolve &&
                                  posterAction != null)
                                posterAction!,
                              if (recoveryActions != null)
                                recoveryActions!(
                                  state.requireValue.value!,
                                  model.retry,
                                ),
                              if (state.requireValue.refreshFailed)
                                TextButton(
                                  onPressed: state.requireValue.refreshing
                                      ? null
                                      : model.retry,
                                  child: const Text('Reintentar'),
                                ),
                            ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
