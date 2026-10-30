import 'package:flutter/material.dart';

/// Shared blue finish for the active navigation item and map detail action.
class NavigationAccentSurface extends StatelessWidget {
  const NavigationAccentSurface({
    required this.engaged,
    required this.child,
    super.key,
  });

  final bool engaged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    Color tint(Color color) =>
        engaged ? Color.lerp(color, Colors.black, .03)! : color;
    return AnimatedContainer(
      duration: reduced ? Duration.zero : const Duration(milliseconds: 200),
      curve: Curves.ease,
      transform: Matrix4.translationValues(0, engaged && !reduced ? -2 : 0, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            tint(const Color(0xFF75BFFF)),
            tint(const Color(0xFF459FF6)),
            tint(const Color(0xFF2887EF)),
          ],
          stops: const [0, .48, 1],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x402887EF),
            blurRadius: 20,
            offset: Offset(0, 7),
          ),
          BoxShadow(
            color: Color(0x1A2887EF),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x80FFFFFF), Color(0x20FFFFFF), Color(0x00FFFFFF)],
          stops: [0, .035, .10],
        ),
      ),
      child: child,
    );
  }
}
