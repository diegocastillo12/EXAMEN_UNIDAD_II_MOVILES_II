import 'package:flutter/material.dart';

/// Main page, section and step headings, shared with web (ADR-111).
abstract final class AppTypography {
  static const primaryTitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: Color(0xFF454746),
    height: 1.25,
    letterSpacing: 0,
  );
}
