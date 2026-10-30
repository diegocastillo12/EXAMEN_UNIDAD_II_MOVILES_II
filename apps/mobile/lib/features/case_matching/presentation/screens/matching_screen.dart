import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/app_select_field.dart';
import '../../../../core/presentation/widgets/case_screen_shell.dart';
import '../../../../core/presentation/widgets/collection_empty_state.dart';
import '../../../../core/presentation/widgets/entity_card_surface.dart';
import '../../../../core/presentation/widgets/content_refresh.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/primary_action_button_style.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../domain/entities/case_match.dart';
import '../view_models/matching_view_model.dart';

class MatchingScreen extends ConsumerWidget {
  const MatchingScreen({required this.onOpen, super.key});
  final Future<void> Function(MatchReference reference, Rect? origin) onOpen;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(matchingViewModelProvider),
        v = async.isLoading ? null : async.asData?.value;
    final model = ref.read(matchingViewModelProvider.notifier);
    final issue = async.error is MatchFailure
        ? (async.error as MatchFailure).kind
        : v?.issue;
    final message = switch (issue) {
      MatchIssue.forbidden =>
        'Esta búsqueda ya no está disponible para tu cuenta.',
      MatchIssue.invalid => 'Revisa la búsqueda seleccionada.',
      MatchIssue.conflict =>
        'El caso cambió. Vuelve a consultar sus coincidencias.',
      MatchIssue.busy =>
        'La comparación está ocupada. Reintenta en unos momentos.',
      MatchIssue.unavailable =>
        'No pudimos comparar las publicaciones. Puedes reintentar.',
      null => async.hasError ? 'No pudimos consultar tus búsquedas.' : null,
    };
    return CaseScreenShell(
      title: 'Posibles coincidencias',
      loading: async.isLoading,
      notice:
          message ??
          (v?.saved != 0 && v?.saved != null
              ? 'Revisión guardada. La recuperación se confirma por separado.'
              : null),
      noticeIsError: message != null,
      noticeId: (async.error, v?.notice, v?.saved),
      child: async.isLoading
          ? const SkeletonFormFields(fieldCount: 3)
          : v == null
          ? TextButton(onPressed: model.retry, child: const Text('Reintentar'))
          : v.searches.isEmpty
          ? const CollectionEmptyState(
              title: 'Sin búsquedas activas',
              description:
                  'Publica una búsqueda con fotografías para consultar posibles coincidencias.',
              icon: Icons.manage_search_rounded,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Compara tu búsqueda con mascotas encontradas. La apariencia puede ser similar: revisa cada sugerencia.',
                ),
                const SizedBox(height: 20),
                AppSelectField<String>(
                  label: 'Tu búsqueda',
                  value: v.selected?.key,
                  options: [
                    for (final s in v.searches)
                      AppSelectOption(
                        value: s.reference.key,
                        label: s.name.isEmpty
                            ? switch (s.species) {
                                'dog' => 'Perro',
                                'cat' => 'Gato',
                                _ => 'Mascota',
                              }
                            : s.name,
                        icon: Icons.pets_outlined,
                      ),
                  ],
                  onChanged: v.busy ? null : model.select,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  style: primaryActionButtonStyle(context, isLoading: v.busy),
                  onPressed: v.busy ? null : model.search,
                  child: LoadingShimmer(
                    isLoading: v.busy,
                    loadingLabel: 'Comparando publicaciones',
                    child: Text(
                      v.result?.complete == false
                          ? 'Continuar comparación'
                          : 'Buscar coincidencias',
                    ),
                  ),
                ),
                if (v.busy && v.result == null) ...[
                  const SizedBox(height: 20),
                  const SkeletonFormFields(fieldCount: 3),
                ],
                if (v.result != null)
                  ContentRefresh(
                    refreshing: v.busy,
                    label: 'Actualizando coincidencias',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        if (!v.result!.complete)
                          const Text(
                            'Aún quedan fotografías por comparar. Continúa para completar los resultados.',
                          ),
                        if (v.result!.complete && v.result!.candidates.isEmpty)
                          const CollectionEmptyState(
                            title: 'Sin coincidencias por ahora',
                            description:
                                'No hay publicaciones compatibles disponibles. Puedes consultar nuevamente más adelante.',
                            icon: Icons.manage_search_rounded,
                          ),
                        for (final c in v.result!.candidates)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: EntityCardSurface(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      c.name.isEmpty
                                          ? 'Mascota encontrada'
                                          : c.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('Posible coincidencia'),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Comparación visual de la misma especie. Zonas aproximadas a ${(c.distanceMeters / 1000).toStringAsFixed(1)} km; ${c.daysApart} días entre los sucesos.',
                                    ),
                                    const Text(
                                      'La sugerencia puede ser incorrecta. Revisa fotos y rasgos.',
                                    ),
                                    if (c.review != null)
                                      Text(
                                        c.review == 'confirmed'
                                            ? 'Tu revisión: coincide.'
                                            : 'Tu revisión: descartada.',
                                      ),
                                    Builder(
                                      builder: (buttonContext) => TextButton(
                                        onPressed: v.busy
                                            ? null
                                            : () async {
                                                final box = buttonContext
                                                        .findRenderObject(),
                                                    navigator =
                                                        Navigator.of(
                                                              buttonContext,
                                                            ).context
                                                            .findRenderObject();
                                                final origin =
                                                    box is RenderBox &&
                                                        box.hasSize
                                                    ? box.localToGlobal(
                                                            Offset.zero,
                                                            ancestor: navigator,
                                                          ) &
                                                          box.size
                                                    : null;
                                                await onOpen(
                                                  c.reference,
                                                  origin,
                                                );
                                                if (context.mounted) {
                                                  model.search();
                                                }
                                              },
                                        child: const Text('Ver ficha'),
                                      ),
                                    ),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 8,
                                      children: [
                                        TextButton(
                                          onPressed:
                                              v.busy || c.review == 'confirmed'
                                              ? null
                                              : () => model.decide(
                                                  c,
                                                  'confirmed',
                                                ),
                                          child: const Text('Coincide'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              v.busy || c.review == 'dismissed'
                                              ? null
                                              : () => model.decide(
                                                  c,
                                                  'dismissed',
                                                ),
                                          child: const Text('Descartar'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
