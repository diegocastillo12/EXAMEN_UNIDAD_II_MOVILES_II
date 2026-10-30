import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';

class OnboardingActions extends StatelessWidget {
  const OnboardingActions({
    required this.page,
    required this.isBusy,
    required this.onNext,
    super.key,
  });
  final int page;
  final bool isBusy;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final indicators = Semantics(
      label: 'Paso ${page + 1} de 3',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == page ? Colors.black : const Color(0xFFD9DADF),
            ),
          ),
        ),
      ),
    );
    final button = LoadingShimmer(
      isLoading: isBusy,
      loadingLabel: 'Guardando finalización del onboarding',
      radius: 26,
      child: FilledButton(
        onPressed: isBusy ? null : onNext,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF111111),
          disabledBackgroundColor: isBusy ? const Color(0xFF111111) : null,
          disabledForegroundColor: isBusy ? Colors.white : null,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          minimumSize: const Size(180, 68),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 22,
            height: 1.15,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 26),
            Expanded(
              child: Text(
                page == 2 ? 'Comenzar' : 'Continuar',
                textAlign: TextAlign.center,
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, size: 26),
          ],
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicators,
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: button),
        ],
      ),
    );
  }
}
