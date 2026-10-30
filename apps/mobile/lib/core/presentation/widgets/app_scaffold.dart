import 'package:flutter/material.dart';

import 'app_page_background.dart';

/// Paints the background across the viewport, outside keyboard resizing/insets.
class AppScaffold extends StatelessWidget {
  const AppScaffold({required this.body, super.key});

  final Widget body;

  @override
  Widget build(BuildContext context) => AppPageBackground(
    child: Scaffold(backgroundColor: Colors.transparent, body: body),
  );
}
