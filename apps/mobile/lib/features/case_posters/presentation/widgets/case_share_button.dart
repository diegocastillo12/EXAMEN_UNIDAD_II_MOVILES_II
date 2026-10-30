import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/glass_navigation_button.dart';
import '../../../../core/presentation/widgets/origin_page_transition.dart';
import '../../domain/entities/case_poster.dart';
import 'case_share_sheet.dart';

class CaseShareButton extends StatefulWidget {
  const CaseShareButton({
    required this.target,
    required this.title,
    required this.eventLabel,
    required this.onReport,
    this.caseActions = const [],
    super.key,
  });
  final PosterCase target;
  final String title, eventLabel;
  final Future<void> Function(OriginPageSource source) onReport;
  final List<Widget> caseActions;
  @override
  State<CaseShareButton> createState() => _CaseShareButtonState();
}

class _CaseShareButtonState extends State<CaseShareButton> {
  bool _open = false;
  Future<void> _show() async {
    if (_open) return;
    setState(() => _open = true);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      elevation: 0,
      barrierColor: const Color(0x66000000),
      showDragHandle: true,
      sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
          ? AnimationStyle.noAnimation
          : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => CaseShareSheet(
        target: widget.target,
        title: widget.title,
        eventLabel: widget.eventLabel,
        onReport: widget.onReport,
        caseActions: widget.caseActions,
      ),
    );
    if (!mounted) return;
    setState(() => _open = false);
  }

  @override
  Widget build(BuildContext context) => GlassNavigationButton(
    tooltip: 'Compartir ficha',
    icon: Icons.ios_share_rounded,
    onPressed: _open ? null : _show,
  );
}
