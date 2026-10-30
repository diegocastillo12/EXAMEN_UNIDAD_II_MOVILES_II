import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/skeleton_form_fields.dart';
import '../../domain/entities/search_place.dart';
import '../state/place_search_state.dart';
import '../view_models/place_search_view_model.dart';

class PlaceSearchFields extends ConsumerStatefulWidget {
  const PlaceSearchFields({
    required this.onSelect,
    this.initialLabel = '',
    this.citiesOnly = false,
    this.enabled = true,
    this.invalid = false,
    this.onQueryChanged,
    super.key,
  });
  final ValueChanged<SearchPlace> onSelect;
  final String initialLabel;
  final bool citiesOnly, enabled, invalid;
  final ValueChanged<String>? onQueryChanged;
  @override
  ConsumerState<PlaceSearchFields> createState() => _PlaceSearchFieldsState();
}

class _PlaceSearchFieldsState extends ConsumerState<PlaceSearchFields> {
  late final _controller = TextEditingController(text: widget.initialLabel);
  final _focus = FocusNode();
  final _portal = OverlayPortalController();
  final _link = LayerLink();
  final _anchor = GlobalKey();
  final _tapGroup = Object();
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_syncOverlay);
  }

  void _syncOverlay() {
    if (!mounted) return;
    final state = ref.read(
      placeSearchByModeViewModelProvider(widget.citiesOnly),
    );
    final show =
        widget.enabled &&
        _focus.hasFocus &&
        (state.busy || state.places.isNotEmpty);
    if (show == _open) return;
    setState(() => _open = show);
    if (show) {
      _portal.show();
    } else {
      _portal.hide();
    }
  }

  void _dismiss() {
    if (!mounted) return;
    _focus.unfocus();
    ref
        .read(placeSearchByModeViewModelProvider(widget.citiesOnly).notifier)
        .clear();
    _syncOverlay();
  }

  @override
  void didUpdateWidget(covariant PlaceSearchFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _dismiss();
      });
    }
    if (widget.initialLabel != oldWidget.initialLabel &&
        _controller.text != widget.initialLabel) {
      _controller.text = widget.initialLabel;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.text == widget.initialLabel) {
          ref
              .read(
                placeSearchByModeViewModelProvider(widget.citiesOnly).notifier,
              )
              .clear();
        }
      });
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_syncOverlay);
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = placeSearchByModeViewModelProvider(widget.citiesOnly);
    final state = ref.watch(provider);
    final model = ref.read(provider.notifier);
    ref.listen(provider, (_, _) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncOverlay());
    });
    return ConfirmationToastHost(
      confirmed: state.notice != null,
      isError: true,
      message: state.notice ?? '',
      noticeId: state.noticeId,
      child: PopScope(
        canPop: !_open,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _dismiss();
        },
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): _dismiss,
          },
          child: OverlayPortal(
            controller: _portal,
            overlayChildBuilder: (context) => _suggestions(context, state),
            child: CompositedTransformTarget(
              key: _anchor,
              link: _link,
              child: TapRegion(
                groupId: _tapGroup,
                onTapOutside: (_) {
                  if (_open) _dismiss();
                },
                child: AppTextField(
                  label: widget.citiesOnly ? 'Ciudad' : 'Ciudad o dirección',
                  hint: 'Por ejemplo, Miraflores, Lima',
                  icon: Icons.search_rounded,
                  controller: _controller,
                  focusNode: _focus,
                  enabled: widget.enabled,
                  invalid: widget.invalid,
                  textInputAction: TextInputAction.search,
                  onChanged: (query) {
                    widget.onQueryChanged?.call(query);
                    model.queryChanged(query);
                  },
                  onSubmitted: (_) => model.search(_controller.text),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _suggestions(BuildContext context, PlaceSearchState state) {
    final box = _anchor.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    if (box == null || !box.hasSize) return const SizedBox.shrink();
    final rect = box.localToGlobal(Offset.zero, ancestor: overlay) & box.size;
    final media = MediaQuery.of(context);
    final bottom =
        overlay.size.height -
        media.viewInsets.bottom -
        media.padding.bottom -
        8;
    final top = media.padding.top + 8;
    if (rect.bottom <= top || rect.top >= bottom) {
      return const SizedBox.shrink();
    }
    final below = (bottom - rect.bottom - 8).clamp(0.0, 320.0);
    final above = (rect.top - top - 8).clamp(0.0, 320.0);
    final upwards = below < 120 && above > below;
    final height = upwards ? above : below;
    return Positioned(
      left: 0,
      top: 0,
      child: CompositedTransformFollower(
        link: _link,
        showWhenUnlinked: false,
        targetAnchor: upwards ? Alignment.topLeft : Alignment.bottomLeft,
        followerAnchor: upwards ? Alignment.bottomLeft : Alignment.topLeft,
        offset: Offset(0, upwards ? -8 : 8),
        child: TapRegion(
          groupId: _tapGroup,
          child: TextFieldTapRegion(
            child: SizedBox(
              width: box.size.width,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: height),
                child: Material(
                  key: const ValueKey('place-suggestions'),
                  color: const Color(0xFFF5F5F7),
                  elevation: 2,
                  shadowColor: const Color(0x22171918),
                  borderRadius: BorderRadius.circular(22),
                  clipBehavior: Clip.antiAlias,
                  child: Semantics(
                    container: true,
                    explicitChildNodes: true,
                    label: 'Sugerencias de lugares',
                    child: SingleChildScrollView(
                      primary: false,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: state.busy
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: LoadingShimmer(
                                isLoading: true,
                                isAction: false,
                                loadingLabel: 'Consultando lugares',
                                child: SkeletonFormFields(fieldCount: 1),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (final place in state.places)
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      alignment: Alignment.centerLeft,
                                      minimumSize: const Size(0, 48),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),
                                      foregroundColor: const Color(0xFF171918),
                                      textStyle: const TextStyle(
                                        fontFamily: AppTheme.fontFamily,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      shape: const RoundedRectangleBorder(),
                                    ),
                                    onPressed: !widget.enabled
                                        ? null
                                        : () {
                                            _controller.text = place.label;
                                            _dismiss();
                                            widget.onSelect(place);
                                          },
                                    icon: const Icon(
                                      Icons.location_on_outlined,
                                      size: 18,
                                    ),
                                    label: Text(place.label),
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
    );
  }
}
