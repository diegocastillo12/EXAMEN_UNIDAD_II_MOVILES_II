import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/collection_add_button.dart';
import '../../domain/entities/content_report.dart';

class ReportContentButton extends StatelessWidget {
  const ReportContentButton({required this.target, super.key});
  final ReportTarget target;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: CollectionAddButton(
      route: '/home/denounce/${target.kind}/${target.id}',
      icon: Icons.flag_outlined,
      label: 'Denunciar contenido',
      description: 'Pedir revisión de este contenido',
    ),
  );
}
