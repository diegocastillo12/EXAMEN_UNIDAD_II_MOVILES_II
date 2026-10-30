import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/glass_surface.dart';
import '../../../../core/presentation/widgets/origin_page_transition.dart';
import '../view_models/explore_view_model.dart';

/// A viewport action, composed above Home's navigation by the router.
class ExploreMapButton extends ConsumerWidget {
  const ExploreMapButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exploreViewModelProvider);
    final data = state.asData?.value;
    if (state.isLoading || state.hasError || data == null) {
      return const SizedBox.shrink();
    }
    return Builder(
      builder: (source) => GlassSurface(
        radius: 26,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap: data.busy
                ? null
                : () {
                    final box = source.findRenderObject() as RenderBox?;
                    final navigator = Navigator.of(
                      source,
                    ).context.findRenderObject();
                    final bounds = box == null
                        ? null
                        : box.localToGlobal(Offset.zero, ancestor: navigator) &
                              box.size;
                    source.push(
                      '/home/explore-map',
                      extra: bounds == null
                          ? null
                          : OriginPageSource(
                              bounds: bounds,
                              color: const Color(0xFFF5F5F7),
                              radius: 26,
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: _MapLabel(),
                              ),
                            ),
                    );
                  },
            child: const _MapLabel(),
          ),
        ),
      ),
    );
  }
}

class _MapLabel extends StatelessWidget {
  const _MapLabel();

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 48),
    child: const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.map_outlined, size: 22, color: Color(0xFF111111)),
          SizedBox(width: 8),
          Text(
            'Mapa',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111111),
            ),
          ),
        ],
      ),
    ),
  );
}
