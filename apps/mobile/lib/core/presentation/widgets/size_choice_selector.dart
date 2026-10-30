import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SizeChoiceOption<T> {
  const SizeChoiceOption({required this.value, required this.label});
  final T value;
  final String label;
}

class SizeChoiceSelector<T> extends StatelessWidget {
  const SizeChoiceSelector({
    required this.value,
    required this.options,
    required this.onChanged,
    this.invalid = false,
    super.key,
  });
  final T? value;
  final List<SizeChoiceOption<T>> options;
  final bool invalid;
  final ValueChanged<T?>? onChanged;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final slotWidth = (constraints.maxWidth - 16) / 3;
      final stacked =
          MediaQuery.textScalerOf(context).scale(14) > 18 || slotWidth < 108;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final size in options) ...[
            if (options.indexOf(size) > 0) const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: _label(context, size, slotWidth, stacked),
                selected: value == size.value,
                showCheckmark: false,
                surfaceTintColor: Colors.transparent,
                onSelected: onChanged == null
                    ? null
                    : (selected) => onChanged!(selected ? size.value : null),
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.surface,
                side: BorderSide(
                  color: invalid
                      ? AppColors.error
                      : value == size.value
                      ? AppColors.ink
                      : AppColors.divider,
                  width: invalid
                      ? 3.5
                      : value == size.value
                      ? 1.5
                      : 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                labelPadding: EdgeInsets.zero,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                labelStyle: TextStyle(
                  fontFamily: 'sans-serif',
                  fontSize: 14,
                  color: invalid ? AppColors.error : AppColors.ink,
                ),
              ),
            ),
          ],
        ],
      );
    },
  );

  Widget _label(
    BuildContext context,
    SizeChoiceOption<T> size,
    double slotWidth,
    bool stacked,
  ) {
    final width = (slotWidth - 16 - (invalid ? 7 : 3)).clamp(
      1.0,
      double.infinity,
    );
    final style = TextStyle(
      fontFamily: 'sans-serif',
      fontSize: 14,
      height: 1.3,
      letterSpacing: 0,
      color: invalid ? AppColors.error : AppColors.ink,
    );
    final text = Text(
      size.label,
      style: style,
      textAlign: stacked ? TextAlign.center : TextAlign.start,
      softWrap: true,
      maxLines: 3,
      overflow: TextOverflow.visible,
    );
    if (!stacked) {
      return SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _icon(size),
            const SizedBox(width: 4),
            Flexible(child: text),
          ],
        ),
      );
    }
    final painter = TextPainter(
      text: TextSpan(text: size.label, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 3,
    )..layout(maxWidth: width);
    final height = 26 + painter.height;
    painter.dispose();
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_icon(size), const SizedBox(height: 4), text],
      ),
    );
  }

  Widget _icon(SizeChoiceOption<T> size) => SizedBox.square(
    dimension: 22,
    child: Icon(
      Icons.pets_outlined,
      size: 14 + options.indexOf(size) * 4,
      color: invalid
          ? AppColors.error
          : value == size.value
          ? AppColors.ink
          : AppColors.secondary,
    ),
  );
}
