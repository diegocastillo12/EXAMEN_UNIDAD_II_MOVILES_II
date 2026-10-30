import 'package:flutter/material.dart';

import 'stagger_reveal.dart';

/// Reveals explicit text lines in order, preserving one accessible label.
class StaggerRevealText extends StatelessWidget {
  const StaggerRevealText({
    required this.text,
    required this.startOrder,
    required this.style,
    super.key,
  });

  final String text;
  final int startOrder;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    return Semantics(
      label: text,
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < lines.length; index++)
              StaggerRevealItem(
                order: startOrder + index,
                child: Text(
                  lines[index],
                  textAlign: TextAlign.center,
                  style: style,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
