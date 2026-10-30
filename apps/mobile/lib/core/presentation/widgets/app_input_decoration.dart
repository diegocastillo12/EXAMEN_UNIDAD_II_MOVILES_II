import 'package:flutter/material.dart';

InputDecoration appInputDecoration(
  String? hint,
  IconData? icon, {
  Widget? suffix,
  bool invalid = false,
  double verticalPadding = 22,
}) => InputDecoration(
  hintText: hint,
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(22),
    borderSide: const BorderSide(color: Color(0xFFB53F48), width: 3.5),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(22),
    borderSide: const BorderSide(color: Color(0xFFB53F48), width: 3.5),
  ),
  hintStyle: const TextStyle(
    fontSize: 16,
    height: 27 / 16,
    color: Color(0xFF6E6E73),
  ),
  prefixIcon: icon == null
      ? null
      : Icon(
          icon,
          size: 22,
          color: invalid ? const Color(0xFFB53F48) : const Color(0xFF6E6E73),
        ),
  suffixIcon: suffix,
  filled: true,
  fillColor: const Color(0xFFF5F5F7),
  contentPadding: EdgeInsets.symmetric(
    vertical: verticalPadding,
    horizontal: 16,
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(22),
    borderSide: BorderSide(
      color: invalid ? const Color(0xFFB53F48) : const Color(0xFFE5E5EA),
      width: invalid ? 3.5 : 1,
    ),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(22),
    borderSide: BorderSide(
      color: invalid ? const Color(0xFFB53F48) : const Color(0xFFE5E5EA),
      width: invalid ? 3.5 : 1,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(22),
    borderSide: BorderSide(
      color: invalid ? const Color(0xFFB53F48) : const Color(0xFF6E6E73),
      width: invalid ? 3.5 : 1.5,
    ),
  ),
);
