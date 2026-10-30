import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/presentation/widgets/entity_card_content.dart';
import '../../domain/entities/pet.dart';
import 'pet_labels.dart';

class PetCardContent extends StatelessWidget {
  const PetCardContent({
    required this.pet,
    this.foreground = AppColors.ink,
    this.secondary = AppColors.secondary,
    super.key,
  });
  final Pet pet;
  final Color foreground, secondary;
  @override
  Widget build(BuildContext context) => EntityCardContent(
    title: pet.fields.name,
    subtitle: pet.fields.speciesDetail ?? speciesLabel(pet.fields.species),
    imageUri: pet.coverUri,
    foreground: foreground,
    secondary: secondary,
  );
}
