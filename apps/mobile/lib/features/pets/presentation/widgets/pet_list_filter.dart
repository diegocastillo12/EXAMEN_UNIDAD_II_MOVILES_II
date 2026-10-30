import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/two_option_filter.dart';

class PetListFilter extends StatelessWidget {
  const PetListFilter({
    required this.archived,
    required this.onChanged,
    super.key,
  });
  final bool archived;
  final ValueChanged<bool>? onChanged;
  @override
  Widget build(BuildContext context) => TwoOptionFilter(
    secondSelected: archived,
    onChanged: onChanged,
    firstLabel: 'Activas',
    secondLabel: 'Archivadas',
  );
}
