import '../../theme/app_typography.dart';
import 'app_scaffold.dart';
import 'scroll_safe_area.dart';
import 'package:flutter/material.dart';
import 'cover_reveal.dart';
import 'glass_navigation_bar.dart';
import 'stagger_reveal.dart';

class EntityScreenShell extends StatefulWidget {
  const EntityScreenShell({
    this.title,
    this.header,
    this.persistentHeader,
    this.trailingAction,
    this.stage = 'content',
    this.immersive = false,
    this.navigationTooltip = 'Volver',
    this.onBack,
    this.navigationEnabled = true,
    required this.loading,
    required this.child,
    this.count = 9,
    this.scrollPhysics,
    super.key,
  });
  final String? title;
  final Widget? header;
  final Widget? persistentHeader;
  final Widget? trailingAction;
  final Object stage;
  final bool immersive;
  final String navigationTooltip;
  final VoidCallback? onBack;
  final bool navigationEnabled;
  final bool loading;
  final Widget child;
  final int count;
  final ScrollPhysics? scrollPhysics;
  @override
  State<EntityScreenShell> createState() => _EntityScreenShellState();
}

class _EntityScreenShellState extends State<EntityScreenShell> {
  final _scroll = ScrollController(keepScrollOffset: false);
  @override
  void didUpdateWidget(EntityScreenShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stage != widget.stage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scroll.hasClients) _scroll.jumpTo(0);
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    body: ScrollSafeArea(
      top: false,
      lightNavigationIcons: widget.immersive,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _content(context),
              GlassNavigationBar(
                tooltip: widget.navigationTooltip,
                enabled: widget.navigationEnabled,
                onBack: widget.onBack,
                trailing: widget.trailingAction,
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Widget _content(BuildContext context) => SingleChildScrollView(
    controller: _scroll,
    physics: widget.scrollPhysics,
    padding: widget.immersive
        ? EdgeInsets.zero
        : EdgeInsets.fromLTRB(
            24,
            MediaQuery.paddingOf(context).top + 72,
            24,
            ScrollSafeArea.bottomPadding(context, 32),
          ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.immersive &&
            widget.header == null &&
            widget.title != null) ...[
          Text(widget.title!, style: AppTypography.primaryTitle),
          const SizedBox(height: 28),
        ],
        if (!widget.immersive && widget.persistentHeader != null) ...[
          widget.persistentHeader!,
          const SizedBox(height: 20),
        ],
        AuthStageTransition(
          enabled: !widget.loading,
          stage: widget.stage,
          startCovered: true,
          builder: (play) => ContentReveal(
            loading: widget.loading,
            count: widget.count,
            play: play,
            child: widget.immersive && !widget.loading
                ? SizedBox(
                    height: MediaQuery.sizeOf(context).height,
                    child: widget.child,
                  )
                : widget.header != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StaggerRevealItem(order: 0, child: widget.header!),
                      const SizedBox(height: 12),
                      widget.child,
                    ],
                  )
                : widget.child,
          ),
        ),
      ],
    ),
  );
}
