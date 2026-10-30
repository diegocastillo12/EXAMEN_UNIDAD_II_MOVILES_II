import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Screen-owned feedback. A new result announces it via activation or noticeId.
/// Disposal removes both the overlay and its timer, preventing stale notices.
class ConfirmationToastHost extends StatefulWidget {
  const ConfirmationToastHost({
    required this.confirmed,
    required this.message,
    required this.child,
    this.isError = false,
    this.noticeId,
    this.actionLabel,
    this.onAction,
    super.key,
  });
  final bool confirmed;
  final String message;
  final Widget child;
  final bool isError;
  final Object? noticeId;
  final String? actionLabel;
  final VoidCallback? onAction;
  @override
  State<ConfirmationToastHost> createState() => _ConfirmationToastHostState();
}

class _ConfirmationToastHostState extends State<ConfirmationToastHost> {
  // A nested image host and its screen must never stack competing notices.
  static _ConfirmationToastHostState? _visibleHost;
  OverlayEntry? _entry;
  int _generation = 0;
  void _clear() {
    if (identical(_visibleHost, this)) _visibleHost = null;
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
  }

  @override
  void didUpdateWidget(ConfirmationToastHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.confirmed == widget.confirmed &&
        (!widget.confirmed || oldWidget.noticeId == widget.noticeId)) {
      return;
    }
    _showNotice();
  }

  @override
  void initState() {
    super.initState();
    if (widget.confirmed) _showNotice();
  }

  void _showNotice() {
    final generation = ++_generation;
    _clear();
    if (!widget.confirmed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || generation != _generation) return;
      _visibleHost?._clear();
      _visibleHost = this;
      final media = MediaQuery.of(context);
      _entry = OverlayEntry(
        builder: (context) => Positioned(
          top: MediaQuery.paddingOf(context).top + 12,
          left: 24,
          right: 24,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 12,
          child: LayoutBuilder(
            builder: (context, bounds) => Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 360,
                  maxHeight:
                      ((bounds.maxHeight +
                                  MediaQuery.paddingOf(context).top +
                                  MediaQuery.viewInsetsOf(context).bottom +
                                  24) *
                              .3)
                          .clamp(48.0, 220.0)
                          .clamp(0.0, bounds.maxHeight),
                ),
                child: MediaQuery(
                  data: media,
                  child: _ConfirmationToast(
                    message: widget.message,
                    isError: widget.isError,
                    actionLabel: widget.actionLabel,
                    onAction: widget.onAction,
                    onClose: _clear,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      Overlay.of(context, rootOverlay: true).insert(_entry!);
    });
  }

  @override
  void dispose() {
    _generation++;
    _clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _ConfirmationToast extends StatefulWidget {
  const _ConfirmationToast({
    required this.message,
    required this.onClose,
    required this.isError,
    this.actionLabel,
    this.onAction,
  });
  final String message;
  final bool isError;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onClose;
  @override
  State<_ConfirmationToast> createState() => _ConfirmationToastState();
}

class _ConfirmationToastState extends State<_ConfirmationToast>
    with TickerProviderStateMixin {
  final _scroll = ScrollController();
  Timer? _timer;
  bool _closing = false;
  bool _returning = false;
  bool _pointerCancelled = false;
  double _drag = 0;
  Offset? _pointerStart;
  Duration? _pointerTime;
  Duration _lastPointerTime = Duration.zero;
  int? _pointer;
  late final _return = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
    reverseDuration: const Duration(milliseconds: 240),
  );
  late final _position = CurvedAnimation(
    parent: _animation,
    curve: const Cubic(.16, 1, .3, 1),
    reverseCurve: const Cubic(.4, 0, 1, 1).flipped,
  );
  double get _dragOffset => _returning
      ? _drag * (1 - const Cubic(.22, 1, .36, 1).transform(_return.value))
      : _drag;

  void _scheduleClose() {
    _timer?.cancel();
    if (mounted && !_closing && _pointer == null) {
      _timer = Timer(const Duration(milliseconds: 6500), _dismiss);
    }
  }

  Future<void> _dismiss({VoidCallback? action}) async {
    if (!mounted || _closing) return;
    _closing = true;
    _timer?.cancel();
    _pointer = null;
    final offset = _dragOffset;
    _return.stop();
    _returning = false;
    _drag = offset;
    if (!MediaQuery.disableAnimationsOf(context)) {
      try {
        await _animation.reverse().orCancel;
      } on TickerCanceled {
        return;
      }
    }
    if (!mounted) return;
    widget.onClose();
    action?.call();
  }

  void _pointerDown(PointerDownEvent event) {
    if (_closing || _pointer != null || event.buttons != kPrimaryButton) return;
    _pointer = event.pointer;
    _pointerCancelled = false;
    _pointerStart = event.position;
    _pointerTime = event.timeStamp;
    _lastPointerTime = event.timeStamp;
    _timer?.cancel();
    final offset = _dragOffset;
    _return.stop();
    _returning = false;
    _drag = offset;
  }

  void _pointerEnd(PointerEvent event) {
    if (event.pointer != _pointer) return;
    _lastPointerTime = event.timeStamp;
    _pointer = null;
    _scheduleClose();
  }

  void _dragUpdate(DragUpdateDetails details) {
    if (_closing || _pointerStart == null) return;
    final dy = details.globalPosition.dy - _pointerStart!.dy;
    setState(() => _drag = dy < 0 ? dy : (dy * .15).clamp(0.0, 18.0));
  }

  void _dragEnd(DragEndDetails details) {
    if (_closing || _pointerCancelled) return;
    final elapsed = _lastPointerTime - (_pointerTime ?? Duration.zero);
    final up = -_drag;
    final velocity = elapsed.inMicroseconds > 0
        ? up / (elapsed.inMicroseconds / 1000)
        : 0.0;
    if (up >= 40 || (up >= 12 && velocity > .45)) {
      _dismiss();
    } else {
      _returnToRest();
    }
  }

  void _returnToRest() {
    if (_closing) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      setState(() => _drag = 0);
    } else {
      setState(() => _returning = true);
      _return.forward(from: 0);
    }
    _scheduleClose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation.value = 1;
    } else if (_animation.value == 0 && !_animation.isAnimating) {
      _animation.forward();
    }
    if (_timer == null && _pointer == null) _scheduleClose();
  }

  @override
  void dispose() {
    _closing = true;
    _pointer = null;
    _scroll.dispose();
    _timer?.cancel();
    _position.dispose();
    _return.dispose();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([_position, _return]),
    builder: (context, child) => FractionalTranslation(
      translation: Offset(0, _position.value - 1),
      child: Transform.translate(
        offset: Offset(
          0,
          (MediaQuery.paddingOf(context).top + 24) * (_position.value - 1) +
              _dragOffset * _position.value,
        ),
        child: child,
      ),
    ),
    child: Listener(
      onPointerDown: _pointerDown,
      onPointerMove: (event) {
        if (event.pointer == _pointer) _lastPointerTime = event.timeStamp;
      },
      onPointerUp: _pointerEnd,
      onPointerCancel: (event) {
        if (event.pointer != _pointer) return;
        _pointerCancelled = true;
        _pointerEnd(event);
        _returnToRest();
      },
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(gestureSettings: const DeviceGestureSettings(touchSlop: 8)),
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): _dismiss,
          },
          child: GestureDetector(
            dragStartBehavior: DragStartBehavior.down,
            onVerticalDragUpdate: _dragUpdate,
            onVerticalDragEnd: _dragEnd,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A24282A),
                    blurRadius: 20,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xE6F5F5F7),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xB3FFFFFF)),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Semantics(
                        liveRegion: true,
                        button: true,
                        hint: 'Toca para cerrar o desliza hacia arriba',
                        onDismiss: _dismiss,
                        child: InkWell(
                          key: const ValueKey('feedback-toast'),
                          onTap: _dismiss,
                          splashFactory: NoSplash.splashFactory,
                          overlayColor: const WidgetStatePropertyAll(
                            Colors.transparent,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 48),
                            child: Scrollbar(
                              controller: _scroll,
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                controller: _scroll,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ExcludeSemantics(
                                        child: GestureDetector(
                                          dragStartBehavior:
                                              DragStartBehavior.down,
                                          onVerticalDragUpdate: _dragUpdate,
                                          onVerticalDragEnd: _dragEnd,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: Color(0x0D24282A),
                                              shape: BoxShape.circle,
                                            ),
                                            child: SizedBox(
                                              width: 32,
                                              height: 32,
                                              child: Icon(
                                                widget.isError
                                                    ? Icons
                                                          .error_outline_rounded
                                                    : Icons.check_rounded,
                                                color: widget.isError
                                                    ? const Color(0xFFB53F48)
                                                    : const Color(0xFF111111),
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                minHeight: 32,
                                              ),
                                              child: Align(
                                                widthFactor: 1,
                                                heightFactor: 1,
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  widget.message,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.4,
                                                    color: Color(0xFF111111),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (widget.actionLabel != null &&
                                                widget.onAction != null)
                                              TextButton(
                                                onPressed: () => _dismiss(
                                                  action: widget.onAction,
                                                ),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: const Color(
                                                    0xFF111111,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                      ),
                                                  minimumSize: const Size(
                                                    0,
                                                    44,
                                                  ),
                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                ),
                                                child: Text(
                                                  widget.actionLabel!,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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
