import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';

class SocialSignInButton extends StatelessWidget {
  const SocialSignInButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });
  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: LoadingShimmer(
      isLoading: isLoading,
      loadingLabel: 'Iniciando sesión',
      highlight: const Color(0x3324282A),
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF17191D),
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          side: const BorderSide(color: Color(0xFFE0E1E7)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
