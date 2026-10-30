import 'package:flutter/services.dart';

/// Uses Unicode scalar values, matching domain limits and PostgreSQL char_length.
class UnicodeLengthLimitingFormatter extends TextInputFormatter {
  const UnicodeLengthLimitingFormatter(this.maxLength);
  final int maxLength;
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.runes.length <= maxLength ||
        (newValue.composing.isValid && !newValue.composing.isCollapsed)) {
      return newValue;
    }
    final text = String.fromCharCodes(newValue.text.runes.take(maxLength));
    return newValue.copyWith(
      text: text,
      selection: TextSelection(
        baseOffset: newValue.selection.baseOffset.clamp(0, text.length),
        extentOffset: newValue.selection.extentOffset.clamp(0, text.length),
      ),
      composing: TextRange.empty,
    );
  }
}
