import 'stagger_reveal.dart';
import 'package:flutter/material.dart';
import 'two_option_filter.dart';
import 'swipe_action_card.dart';
import 'entity_card_content.dart';
import 'confirm_action_dialog.dart';

class ManagedCaseItem {
  const ManagedCaseItem({
    required this.id,
    required this.title,
    required this.status,
    this.coverUri,
    this.subtitle,
  });
  final String id, title, status;
  final String? subtitle;
  final Uri? coverUri;
}

/// Reuses the exact card, filter and swipe interaction used by pet collections.
class ManagedCaseCollection extends StatefulWidget {
  const ManagedCaseCollection({
    required this.items,
    required this.onOpen,
    required this.onDelete,
    this.busyId,
    this.disabled = false,
    this.pending,
    this.emptyActiveLabel = 'No tienes casos abiertos',
    this.emptyResolvedLabel = 'No tienes casos resueltos',
    this.deleteTitle = '¿Eliminar caso?',
    super.key,
  });
  final List<ManagedCaseItem> items;
  final void Function(String id, Rect origin) onOpen;
  final Future<void> Function(String) onDelete;
  final String? busyId;
  final bool disabled;
  final Widget? pending;
  final String emptyActiveLabel, emptyResolvedLabel, deleteTitle;
  @override
  State<ManagedCaseCollection> createState() => _ManagedCaseCollectionState();
}

class _ManagedCaseCollectionState extends State<ManagedCaseCollection> {
  bool _resolved = false;
  @override
  Widget build(BuildContext context) {
    final items = widget.items
        .where((i) => i.status == (_resolved ? 'resolved' : 'active'))
        .toList();
    return StaggerRevealItem(
      order: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TwoOptionFilter(
            secondSelected: _resolved,
            firstLabel: 'Abiertos',
            secondLabel: 'Resueltos',
            indicatorKey: const ValueKey('case-list-active-indicator'),
            onChanged: widget.disabled || widget.busyId != null
                ? null
                : (value) => setState(() => _resolved = value),
          ),
          const SizedBox(height: 24),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                _resolved ? widget.emptyResolvedLabel : widget.emptyActiveLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Builder(
                builder: (cardContext) => SwipeActionCard(
                  key: ValueKey(item.id),
                  loadingLabel: 'Eliminando caso',
                  busy: widget.busyId == item.id,
                  disabled: widget.disabled || widget.busyId != null,
                  onOpen: () {
                    final box = cardContext.findRenderObject()! as RenderBox;
                    widget.onOpen(
                      item.id,
                      box.localToGlobal(Offset.zero) & box.size,
                    );
                  },
                  onDelete: (origin) async {
                    final source = EntityCardContent(
                      title: item.title,
                      subtitle:
                          item.subtitle ??
                          (_resolved ? 'Caso resuelto' : 'Caso abierto'),
                      imageUri: item.coverUri,
                    );
                    final confirmed = await confirmActionDialog(
                      context,
                      title: widget.deleteTitle,
                      description:
                          'Se retirará el caso de tu lista y dejará de estar disponible públicamente. Esta acción no se puede deshacer.',
                      action: 'Eliminar',
                      destructive: true,
                      origin: origin,
                      source: source,
                    );
                    if (confirmed && context.mounted) {
                      await widget.onDelete(item.id);
                    }
                  },
                  contentBuilder: (foreground, secondary) => EntityCardContent(
                    title: item.title,
                    subtitle:
                        item.subtitle ??
                        (_resolved ? 'Caso resuelto' : 'Caso abierto'),
                    imageUri: item.coverUri,
                    foreground: foreground,
                    secondary: secondary,
                  ),
                ),
              ),
            ),
          if (!_resolved && widget.pending != null) widget.pending!,
        ],
      ),
    );
  }
}
