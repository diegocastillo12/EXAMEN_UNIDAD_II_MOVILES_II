import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/formatters/case_date_label.dart';
import '../../../../core/presentation/widgets/case_photo.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../../../core/presentation/widgets/navigation_accent_surface.dart';
import '../../domain/entities/explore_case_preview.dart';
import '../../domain/entities/explore_page.dart';
import '../../domain/entities/explore_query.dart';
import '../view_models/explore_case_preview_view_model.dart';

class ExploreMapCasePreview extends ConsumerWidget {
  const ExploreMapCasePreview({
    required this.item,
    this.scrollable = true,
    this.onOpen,
    this.onSummaryHeight,
    super.key,
  });
  final ExploreCase item;
  final bool scrollable;
  final ValueChanged<BuildContext>? onOpen;
  final ValueChanged<double>? onSummaryHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = exploreCasePreviewViewModelProvider(item);
    final state = ref.watch(provider);
    return ConfirmationToastHost(
      confirmed: state.hasError,
      isError: true,
      noticeId: state.error,
      message: 'No pudimos completar la vista previa del caso.',
      actionLabel: 'Reintentar',
      onAction: () => ref.invalidate(provider),
      child: ExploreMapPreviewContent(
        item: item,
        scrollable: scrollable,
        onOpen: onOpen,
        onSummaryHeight: onSummaryHeight,
        detail: state.asData?.value,
        loading: state.isLoading,
        failed: state.hasError,
      ),
    );
  }
}

/// Public case summary sharing the photo renderer used by case cards.
class ExploreMapPreviewContent extends StatelessWidget {
  const ExploreMapPreviewContent({
    required this.item,
    this.detail,
    this.loading = false,
    this.failed = false,
    this.scrollable = true,
    this.onOpen,
    this.onSummaryHeight,
    super.key,
  });
  final ExploreCase item;
  final ExploreCasePreview? detail;
  final bool loading, failed, scrollable;
  final ValueChanged<BuildContext>? onOpen;
  final ValueChanged<double>? onSummaryHeight;

  @override
  Widget build(BuildContext context) {
    final photo = detail?.photoUri ?? item.coverUri;
    final date = caseDateOnlyLabel(detail?.occurredAt ?? item.occurredAt);
    final event = item.kind == ExploreKind.lost
        ? 'Desaparición'
        : item.kind == ExploreKind.sighting
        ? 'Avistamiento'
        : 'Encuentro';
    final species = switch (item.species) {
      'dog' => 'Perro',
      'cat' => 'Gato',
      'other' => 'Otra especie',
      _ => 'Tipo no registrado',
    };
    final size = switch (detail?.size) {
      'small' => 'Pequeño',
      'medium' => 'Mediano',
      'large' => 'Grande',
      _ => failed ? 'Tamaño no disponible' : 'Tamaño no registrado',
    };
    final description = item.traits.trim();
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryMeasure(
            onHeight: onSummaryHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: SizedBox.square(
                        key: const ValueKey('map-preview-photo'),
                        dimension: 112,
                        child: photo == null
                            ? const ColoredBox(
                                color: Color(0xFFF5F5F7),
                                child: Center(child: Icon(Icons.pets_outlined)),
                              )
                            : CasePhotoView.network(
                                photo,
                                semanticLabel: 'Foto principal del caso',
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name.isEmpty ? 'Sin nombre' : item.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF171918),
                            ),
                          ),
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6E6E73),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _OpenCaseButton(onOpen: onOpen),
                  ],
                ),
                const SizedBox(height: 12),
                Builder(
                  builder: (source) => TextButton.icon(
                    onPressed: onOpen == null ? null : () => onOpen!(source),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF0F0F2),
                      foregroundColor: const Color(0xFF171918),
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    icon: const Icon(Icons.pets_outlined, size: 20),
                    label: const Text('Ver ficha'),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFE5E5EA)),
          ),
          const Text(
            'Detalles del caso',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF171918),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            key: const ValueKey('map-preview-facts'),
            children: [
              _PreviewFact(
                icon: Icons.straighten_rounded,
                label: 'Tamaño',
                value: loading
                    ? const LoadingShimmer(
                        isLoading: true,
                        isAction: false,
                        loadingLabel: 'Consultando detalles del caso',
                        child: SizedBox(
                          width: 80,
                          height: 16,
                          child: ColoredBox(color: Color(0xFFE5E5EA)),
                        ),
                      )
                    : Text(size),
              ),
              const SizedBox(height: 16),
              _PreviewFact(
                icon: Icons.pets_outlined,
                label: 'Especie',
                value: Text(species),
              ),
              const SizedBox(height: 16),
              _PreviewFact(
                icon: Icons.calendar_today_outlined,
                label: event,
                value: Text(date),
              ),
            ],
          ),
        ],
      ),
    );
    return scrollable ? SingleChildScrollView(child: content) : content;
  }
}

class _PreviewFact extends StatelessWidget {
  const _PreviewFact({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 2),
        child: ExcludeSemantics(
          child: Icon(icon, size: 22, color: const Color(0xFF8E8E93)),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF171918),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            DefaultTextStyle.merge(
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6E6E73),
                height: 1.2,
              ),
              child: value,
            ),
          ],
        ),
      ),
    ],
  );
}

class _OpenCaseButton extends StatefulWidget {
  const _OpenCaseButton({required this.onOpen});
  final ValueChanged<BuildContext>? onOpen;
  @override
  State<_OpenCaseButton> createState() => _OpenCaseButtonState();
}

class _OpenCaseButtonState extends State<_OpenCaseButton> {
  bool _hovered = false, _focused = false, _pressed = false;
  @override
  Widget build(BuildContext context) => Opacity(
    opacity: widget.onOpen == null ? .45 : 1,
    child: NavigationAccentSurface(
      engaged: widget.onOpen != null && (_hovered || _focused || _pressed),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onHover: (value) => setState(() => _hovered = value),
          onFocusChange: (value) => setState(() => _focused = value),
          onHighlightChanged: (value) => setState(() => _pressed = value),
          onTap: widget.onOpen == null ? null : () => widget.onOpen!(context),
          child: const Tooltip(
            message: 'Abrir ficha del caso',
            child: SizedBox.square(
              dimension: 48,
              child: Icon(
                Icons.north_east_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Reports the actual header/button height, independent of the sheet scroll.
class _SummaryMeasure extends SingleChildRenderObjectWidget {
  const _SummaryMeasure({required this.onHeight, required super.child});
  final ValueChanged<double>? onHeight;
  @override
  _SummaryMeasureRender createRenderObject(BuildContext context) =>
      _SummaryMeasureRender(onHeight);
  @override
  void updateRenderObject(
    BuildContext context,
    _SummaryMeasureRender renderObject,
  ) {
    renderObject.onHeight = onHeight;
  }
}

class _SummaryMeasureRender extends RenderProxyBox {
  _SummaryMeasureRender(this.onHeight);
  ValueChanged<double>? onHeight;
  double? _height;
  @override
  void performLayout() {
    super.performLayout();
    final height = size.height;
    if (_height == height) return;
    _height = height;
    WidgetsBinding.instance.addPostFrameCallback((_) => onHeight?.call(height));
  }
}
