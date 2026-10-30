import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'primary_action.dart';

class ActionDock extends StatelessWidget {
  const ActionDock({
    required this.label,
    required this.onPressed,
    this.hint,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final String? hint;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: AppColors.background,
      border: Border(top: BorderSide(color: AppColors.divider)),
    ),
    child: SafeArea(
      top: false,
      child: Align(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryAction(label: label, onPressed: onPressed),
                if (hint != null) ...[
                  const SizedBox(height: 9),
                  Text(
                    hint!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
