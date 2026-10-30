import 'package:flutter/material.dart';
import 'scroll_safe_area.dart';

abstract final class ImmersivePhotoSheetGeometry {
  static const titlePadding = EdgeInsets.fromLTRB(24, 0, 24, 12);
  static const cardRadius = 32.0;
  static double photoSpace(BuildContext context) =>
      (MediaQuery.sizeOf(context).height * .42).clamp(220.0, 380.0);
  static EdgeInsets cardPadding(BuildContext context) =>
      EdgeInsets.fromLTRB(16, 0, 16, ScrollSafeArea.bottomPadding(context, 20));
}
