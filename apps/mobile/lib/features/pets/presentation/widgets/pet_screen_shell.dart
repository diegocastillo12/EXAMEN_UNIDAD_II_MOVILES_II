import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/entity_screen_shell.dart';

class PetScreenShell extends StatelessWidget {
  const PetScreenShell({
    this.title,
    this.onBack,
    this.navigationEnabled = true,
    required this.loading,
    required this.child,
    this.count = 9,
    super.key,
  });
  final String? title;
  final VoidCallback? onBack;
  final bool navigationEnabled;
  final bool loading;
  final Widget child;
  final int count;
  @override
  Widget build(BuildContext context) => EntityScreenShell(
    title: title,
    onBack: onBack,
    navigationEnabled: navigationEnabled,
    navigationTooltip: 'Volver a mis mascotas',
    loading: loading,
    count: count,
    child: child,
  );
}
