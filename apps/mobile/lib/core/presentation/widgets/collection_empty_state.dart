import 'package:flutter/material.dart';

/// Shared empty collection layout; callers provide their copy and real action.
class CollectionEmptyState extends StatelessWidget {
  const CollectionEmptyState({
    required this.title,
    required this.description,
    this.icon = Icons.pets_outlined,
    this.action,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(
      children: [
        ExcludeSemantics(
          child: Icon(icon, size: 88, color: const Color(0xFF6E6E73)),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Color(0xFF6E6E73)),
        ),
        if (action != null) ...[
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: action,
          ),
        ],
      ],
    ),
  );
}
