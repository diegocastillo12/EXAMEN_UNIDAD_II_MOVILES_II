import '../../../../core/presentation/widgets/content_refresh.dart';
import '../../../../core/presentation/widgets/collection_add_button.dart';
import '../../../../core/presentation/widgets/collection_header.dart';
import '../../../../core/presentation/widgets/managed_case_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../view_models/case_read_view_model.dart';
import '../widgets/case_screen_shell.dart';

class MyCasesScreen extends ConsumerWidget {
  const MyCasesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myCasesViewModelProvider);
    final model = ref.read(myCasesViewModelProvider.notifier);
    return CaseScreenShell(
      title: 'Mis casos',
      header: const CollectionHeader(
        title: 'Mis casos',
        action: CollectionAddButton(
          label: 'Reportar mascota perdida',
          route: '/home/lost-cases/new',
          compact: true,
        ),
      ),
      loading: state.isLoading,
      noticeIsError:
          state.hasError ||
          state.asData?.value.noticeIsError == true ||
          state.asData?.value.refreshFailed == true,
      notice:
          state.asData?.value.notice ??
          (state.hasError
              ? 'No pudimos consultar tus casos.'
              : state.asData?.value.refreshFailed == true
              ? 'No pudimos actualizar. Se conserva la última consulta.'
              : null),
      noticeId: state.error ?? state.asData?.value,
      child: state.isLoading
          ? const SkeletonFormFields(fieldCount: 3)
          : state.hasError
          ? Column(
              children: [
                TextButton(
                  onPressed: model.retry,
                  child: const Text('Reintentar'),
                ),
              ],
            )
          : ContentRefresh(
              refreshing: state.requireValue.refreshing,
              label: 'Actualizando casos',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ManagedCaseCollection(
                    items: [
                      for (final item in state.requireValue.cases)
                        ManagedCaseItem(
                          id: item.id,
                          title: item.petName.isEmpty
                              ? 'Mascota perdida'
                              : item.petName,
                          status: item.status,
                          coverUri: item.coverUri,
                        ),
                    ],
                    busyId: state.requireValue.busyId,
                    disabled: state.requireValue.refreshing,
                    onOpen: (id, origin) =>
                        context.push('/home/cases/$id', extra: origin),
                    onDelete: (id) => model.delete(
                      state.requireValue.cases.singleWhere(
                        (item) => item.id == id,
                      ),
                    ),
                  ),
                  if (state.requireValue.refreshFailed)
                    TextButton(
                      onPressed: state.requireValue.busyId != null
                          ? null
                          : model.retry,
                      child: const Text('Reintentar'),
                    ),
                ],
              ),
            ),
    );
  }
}
