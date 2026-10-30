import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/collection_add_button.dart';

class PetRegistrationButton extends StatelessWidget {
  const PetRegistrationButton({this.compact = false, super.key});
  final bool compact;
  @override
  Widget build(BuildContext context) => CollectionAddButton(
    label: 'Registrar mascota',
    route: '/home/pets/new',
    compact: compact,
    buttonKey: compact ? const ValueKey('pet-add-compact') : null,
  );
}
