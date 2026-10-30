import 'package:flutter/material.dart';

class PrimaryAction extends StatelessWidget {
  const PrimaryAction({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: onPressed,
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          const Icon(Icons.arrow_forward_rounded, size: 22),
        ],
      ),
    ),
  );
}
