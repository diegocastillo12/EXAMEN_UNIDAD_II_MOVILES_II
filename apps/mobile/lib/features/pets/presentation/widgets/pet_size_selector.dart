import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/size_choice_selector.dart';
import '../../domain/entities/pet.dart';
import 'pet_labels.dart';

class PetSizeSelector extends StatelessWidget {
  const PetSizeSelector({
    required this.value,
    required this.onChanged,
    this.invalid = false,
    super.key,
  });
  final PetSize? value;
  final bool invalid;
  final ValueChanged<PetSize?>? onChanged;
  @override
  Widget build(BuildContext context) => SizeChoiceSelector<PetSize>(
    value: value,
    onChanged: onChanged,
    invalid: invalid,
    options: [
      for (final size in PetSize.values)
        SizeChoiceOption(value: size, label: sizeLabel(size)),
    ],
  );
}
