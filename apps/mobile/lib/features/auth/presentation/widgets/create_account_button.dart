import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateAccountButton extends StatelessWidget {
  const CreateAccountButton({required this.enabled, super.key});
  final bool enabled;

  @override
  Widget build(BuildContext context) => Builder(
    builder: (buttonContext) => TextButton(
      onPressed: !enabled
          ? null
          : () {
              final box = buttonContext.findRenderObject();
              final navigator = Navigator.of(
                buttonContext,
              ).context.findRenderObject();
              final origin = box is RenderBox && box.hasSize
                  ? box.localToGlobal(Offset.zero, ancestor: navigator) &
                        box.size
                  : null;
              buttonContext.push('/register', extra: origin);
            },
      child: const Text(
        'Crear cuenta',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
