import 'selection_pill_surface.dart';
import 'package:flutter/material.dart';

/// Joined selector for the two real pet lists, with a single moving indicator.
class TwoOptionFilter extends StatelessWidget {
  const TwoOptionFilter({
    required this.secondSelected,
    required this.onChanged,
    required this.firstLabel,
    required this.secondLabel,
    this.indicatorKey = const ValueKey('pet-list-active-indicator'),
    this.onOptionPressed,
    super.key,
  });

  final bool secondSelected;
  final String firstLabel, secondLabel;
  final Key indicatorKey;
  final ValueChanged<bool>? onChanged;
  final void Function(bool, BuildContext)? onOptionPressed;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final style = Theme.of(context).textTheme.labelLarge!.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );
      final painter = TextPainter(
        text: TextSpan(
          text: firstLabel.length > secondLabel.length
              ? firstLabel
              : secondLabel,
          style: style,
        ),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      final stacked = (constraints.maxWidth - 12) / 2 < painter.width + 32;
      painter.dispose();
      final rtl = Directionality.of(context) == TextDirection.rtl;
      return SelectionPillSurface(
        child: TweenAnimationBuilder<double>(
          tween: Tween(
            begin: secondSelected ? 1.0 : 0.0,
            end: secondSelected ? 1.0 : 0.0,
          ),
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 320),
          curve: Curves.easeInOutCubic,
          builder: (context, position, _) => Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment: stacked
                      ? Alignment(0, position * 2 - 1)
                      : Alignment((rtl ? 1 - position : position) * 2 - 1, 0),
                  child: FractionallySizedBox(
                    widthFactor: stacked ? 1 : .5,
                    heightFactor: stacked ? .5 : 1,
                    child: DecoratedBox(
                      key: indicatorKey,
                      decoration: BoxDecoration(
                        color: SelectionPillSurface.selected,
                        borderRadius: BorderRadius.circular(
                          SelectionPillSurface.optionRadius,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Flex(
                direction: stacked ? Axis.vertical : Axis.horizontal,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: stacked
                    ? CrossAxisAlignment.stretch
                    : CrossAxisAlignment.center,
                children: [
                  for (final option in [false, true])
                    if (stacked)
                      _option(option, style, position)
                    else
                      Expanded(child: _option(option, style, position)),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _option(bool option, TextStyle style, double position) => Builder(
    builder: (source) => Semantics(
      selected: secondSelected == option,
      button: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(SelectionPillSurface.optionRadius),
        child: InkWell(
          onTap: onChanged == null && onOptionPressed == null
              ? null
              : () => onOptionPressed != null
                    ? onOptionPressed!(option, source)
                    : onChanged!(option),
          borderRadius: BorderRadius.circular(
            SelectionPillSurface.optionRadius,
          ),
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: Text(
                  option ? secondLabel : firstLabel,
                  textAlign: TextAlign.center,
                  style: style.copyWith(
                    color: Color.lerp(
                      SelectionPillSurface.selected,
                      Colors.white,
                      option ? position : 1 - position,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
