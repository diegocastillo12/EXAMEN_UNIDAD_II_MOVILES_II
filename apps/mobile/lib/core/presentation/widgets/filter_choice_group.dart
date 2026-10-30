import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'selection_pill_surface.dart';

class FilterChoice<T> {
  const FilterChoice(this.value, this.label);
  final T value;
  final String label;
}

/// One moving selection indicator; options wrap without truncating enlarged text.
class FilterChoiceGroup<T> extends StatelessWidget {
  const FilterChoiceGroup({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    super.key,
  }) : assert(options.length > 0);
  final String label;
  final List<FilterChoice<T>> options;
  final T value;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 10),
      SelectionPillSurface(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final style = Theme.of(context).textTheme.labelLarge!.copyWith(
              fontSize: 14,
              height: 1.3,
              fontWeight: FontWeight.w600,
            );
            double width = 0, height = 0;
            for (final option in options) {
              final painter = TextPainter(
                text: TextSpan(text: option.label, style: style),
                textDirection: Directionality.of(context),
                textScaler: MediaQuery.textScalerOf(context),
              )..layout();
              width = math.max(width, painter.width);
              height = math.max(height, painter.height);
              painter.dispose();
            }
            final columns = (constraints.maxWidth / (width + 32)).floor().clamp(
              1,
              options.length,
            );
            final cellWidth = constraints.maxWidth / columns;
            // Measuring at the actual width also handles very large accessibility text.
            for (final option in options) {
              final painter = TextPainter(
                text: TextSpan(text: option.label, style: style),
                textDirection: Directionality.of(context),
                textScaler: MediaQuery.textScalerOf(context),
              )..layout(maxWidth: math.max(1, cellWidth - 24));
              height = math.max(height, painter.height);
              painter.dispose();
            }
            final cellHeight = math.max(48.0, height + 24);
            final selected = options.indexWhere((o) => o.value == value);
            final rtl = Directionality.of(context) == TextDirection.rtl;
            double left(int index) =>
                (rtl ? columns - 1 - index % columns : index % columns) *
                cellWidth;
            return SizedBox(
              height: ((options.length + columns - 1) ~/ columns) * cellHeight,
              child: Stack(
                children: [
                  if (selected >= 0)
                    AnimatedPositioned(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 180),
                      curve: Curves.easeInOutCubic,
                      left: left(selected),
                      top: (selected ~/ columns) * cellHeight,
                      width: cellWidth,
                      height: cellHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: SelectionPillSurface.selected,
                          borderRadius: BorderRadius.circular(
                            SelectionPillSurface.optionRadius,
                          ),
                        ),
                      ),
                    ),
                  for (final entry in options.indexed)
                    Positioned(
                      left: left(entry.$1),
                      top: (entry.$1 ~/ columns) * cellHeight,
                      width: cellWidth,
                      height: cellHeight,
                      child: Semantics(
                        selected: entry.$2.value == value,
                        button: true,
                        inMutuallyExclusiveGroup: true,
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            SelectionPillSurface.optionRadius,
                          ),
                          child: InkWell(
                            splashFactory: NoSplash.splashFactory,
                            overlayColor: const WidgetStatePropertyAll(
                              Colors.transparent,
                            ),
                            borderRadius: BorderRadius.circular(
                              SelectionPillSurface.optionRadius,
                            ),
                            onTap: onChanged == null
                                ? null
                                : () => onChanged!(entry.$2.value),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Center(
                                child: Text(
                                  entry.$2.label,
                                  textAlign: TextAlign.center,
                                  style: style.copyWith(
                                    color: entry.$2.value == value
                                        ? Colors.white
                                        : SelectionPillSurface.selected,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    ],
  );
}
