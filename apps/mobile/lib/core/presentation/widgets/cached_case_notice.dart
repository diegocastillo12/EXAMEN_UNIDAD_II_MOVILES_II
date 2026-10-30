import 'package:flutter/material.dart';
import '../formatters/case_date_label.dart';

class CachedCaseNotice extends StatelessWidget {
  const CachedCaseNotice({
    required this.storedAt,
    required this.onRefresh,
    super.key,
  });
  final DateTime storedAt;
  final VoidCallback? onRefresh;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Copia sin conexión · ${caseDateTimeLabel(storedAt.toLocal())}'),
        const SizedBox(height: 8),
        const Text(
          'Puede estar desactualizada. Algunas fotos pueden no estar disponibles. Conéctate y actualiza para consultar el estado actual.',
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onRefresh,
            child: const Text('Actualizar'),
          ),
        ),
      ],
    ),
  );
}
