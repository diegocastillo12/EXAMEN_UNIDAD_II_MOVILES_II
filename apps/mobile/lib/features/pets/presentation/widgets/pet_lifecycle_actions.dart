import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/confirm_action_dialog.dart';
import '../../domain/entities/pet.dart';
import '../../domain/failures/pet_failure.dart';
import '../view_models/pet_lifecycle_view_model.dart';
import '../view_models/pet_list_view_model.dart';

class PetLifecycleActions extends ConsumerWidget {
  const PetLifecycleActions({required this.pet, super.key});
  final Pet pet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(petLifecycleViewModelProvider(pet.id));
    final label = pet.isArchived ? 'Restaurar mascota' : 'Archivar mascota';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pet.isArchived) ...[
          const Text(
            'Archivada. Su ficha y fotos se conservan.',
            style: TextStyle(fontSize: 16, color: Color(0xFF6E6E73)),
          ),
          const SizedBox(height: 12),
        ],
        LoadingShimmer(
          isLoading: state.busy,
          loadingLabel: pet.isArchived
              ? 'Restaurando mascota'
              : 'Archivando mascota',
          child: OutlinedButton.icon(
            onPressed: state.busy
                ? null
                : () async {
                    if (!pet.isArchived) {
                      final confirmed = await _confirmArchive(context, pet);
                      if (!confirmed || !context.mounted) return;
                    }
                    await ref
                        .read(petLifecycleViewModelProvider(pet.id).notifier)
                        .change(pet);
                  },
            icon: Icon(
              pet.isArchived
                  ? Icons.unarchive_outlined
                  : Icons.archive_outlined,
            ),
            label: Text(label, textAlign: TextAlign.center),
          ),
        ),
        if (state.issue != null) ...[
          const SizedBox(height: 12),
          if (state.issue == PetFailureKind.conflict)
            TextButton(
              onPressed: () => ref
                  .read(petDetailViewModelProvider(pet.id).notifier)
                  .reload(),
              child: const Text('Actualizar ficha'),
            ),
        ],
      ],
    );
  }
}

Future<bool> _confirmArchive(
  BuildContext context,
  Pet pet,
) => confirmActionDialog(
  context,
  title: '¿Archivar mascota?',
  description:
      '${pet.fields.name} pasará a Archivadas. Su ficha y fotos se conservarán y podrás restaurarla.',
  action: 'Archivar',
  semanticLabel: 'Confirmar archivo de mascota',
  destructive: false,
);
