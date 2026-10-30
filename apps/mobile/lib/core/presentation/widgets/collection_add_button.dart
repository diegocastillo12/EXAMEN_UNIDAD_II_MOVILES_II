import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'primary_action_button_style.dart';
import 'origin_page_transition.dart';
import 'navigation_accent_surface.dart';
import '../../theme/app_theme.dart';

class CollectionAddButton extends StatelessWidget {
  const CollectionAddButton({
    required this.label,
    this.route,
    this.onAction,
    this.compact = false,
    this.accented = false,
    this.beforeNavigate,
    this.icon = Icons.add_rounded,
    this.buttonKey,
    this.description,
    this.onReturn,
    super.key,
  }) : assert(route != null || onAction != null);
  final String label;
  final String? route;
  final ValueChanged<BuildContext>? onAction;
  final Key? buttonKey;
  final bool compact;
  final bool accented;
  final VoidCallback? beforeNavigate;
  final IconData icon;
  final String? description;
  final VoidCallback? onReturn;

  @override
  Widget build(BuildContext context) => Builder(
    builder: (buttonContext) {
      final button = Tooltip(
        message: label,
        excludeFromSemantics: true,
        child: FilledButton(
          key: buttonKey,
          style: compact
              ? FilledButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  foregroundColor: Colors.white,
                  fixedSize: const Size.square(56),
                  minimumSize: const Size.square(56),
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                )
              : primaryActionButtonStyle(context).copyWith(
                  minimumSize: const WidgetStatePropertyAll(Size(0, 56)),
                  padding: accented
                      ? const WidgetStatePropertyAll(EdgeInsets.all(8))
                      : null,
                  backgroundColor: accented
                      ? const WidgetStatePropertyAll(Colors.transparent)
                      : description == null
                      ? null
                      : const WidgetStatePropertyAll(Color(0xFFF5F5F7)),
                  foregroundColor: description == null
                      ? null
                      : const WidgetStatePropertyAll(AppColors.ink),
                ),
          onPressed: () {
            if (onAction != null) {
              onAction!(buttonContext);
              return;
            }
            final box = buttonContext.findRenderObject();
            final navigator = Navigator.of(
              buttonContext,
            ).context.findRenderObject();
            final origin = box is RenderBox && box.hasSize
                ? box.localToGlobal(Offset.zero, ancestor: navigator) & box.size
                : null;
            beforeNavigate?.call();
            buttonContext
                .push(
                  route!,
                  extra: origin == null
                      ? null
                      : OriginPageSource(
                          bounds: origin,
                          color: accented
                              ? const Color(0xFF2887EF)
                              : description == null
                              ? AppColors.ink
                              : const Color(0xFFF5F5F7),
                          radius: compact ? origin.shortestSide / 2 : 24,
                          child: DefaultTextStyle(
                            style:
                                (primaryActionButtonStyle(
                                          context,
                                        ).textStyle?.resolve({}) ??
                                        Theme.of(context).textTheme.labelLarge!)
                                    .copyWith(
                                      color: description == null
                                          ? Colors.white
                                          : AppColors.ink,
                                    ),
                            child: IconTheme(
                              data: IconThemeData(
                                color: description == null
                                    ? Colors.white
                                    : AppColors.ink,
                              ),
                              child: Padding(
                                padding: compact
                                    ? EdgeInsets.zero
                                    : const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 18,
                                      ),
                                child: Center(child: _content()),
                              ),
                            ),
                          ),
                        ),
                )
                .then((_) => onReturn?.call());
          },
          child: _content(),
        ),
      );
      return accented
          ? NavigationAccentSurface(engaged: false, child: button)
          : button;
    },
  );

  Widget _content() => compact
      ? Icon(Icons.add_rounded, size: 26, semanticLabel: label)
      : accented
      ? Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x30FFFFFF),
              ),
              child: Icon(icon, size: 22),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(label, textAlign: TextAlign.center)),
            const SizedBox(width: 48),
          ],
        )
      : description != null
      ? Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      color: Color(0xFF6E6E73),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right_rounded, size: 20),
          ],
        )
      : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22),
            SizedBox(width: 8),
            Flexible(child: Text(label)),
          ],
        );
}
