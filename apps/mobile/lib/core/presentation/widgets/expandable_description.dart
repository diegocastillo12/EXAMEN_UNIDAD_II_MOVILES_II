import 'package:flutter/material.dart';

/// Expands text in place without replaying the screen's entrance.
class ExpandableDescription extends StatefulWidget {
  const ExpandableDescription({required this.text, super.key});
  final String text;
  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool _expanded = false;
  @override
  void didUpdateWidget(ExpandableDescription oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) _expanded = false;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const style = TextStyle(
        fontSize: 16,
        height: 1.4,
        color: Color(0xFF111111),
      );
      final painter = TextPainter(
        text: TextSpan(text: widget.text, style: style),
        maxLines: 2,
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: constraints.maxWidth);
      final canExpand = painter.didExceedMaxLines;
      painter.dispose();
      final textContent = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.text,
            style: style,
            maxLines: _expanded ? null : 2,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
          if (canExpand)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _expanded ? 'Mostrar menos' : 'Ver descripción completa',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111111),
                ),
              ),
            ),
        ],
      );
      final content = MediaQuery.disableAnimationsOf(context)
          ? textContent
          : AnimatedSize(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topLeft,
              child: textContent,
            );
      if (!canExpand) return content;
      return Semantics(
        button: true,
        value: _expanded ? 'Expandida' : 'Contraída',
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _expanded = !_expanded),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: content,
          ),
        ),
      );
    },
  );
}
