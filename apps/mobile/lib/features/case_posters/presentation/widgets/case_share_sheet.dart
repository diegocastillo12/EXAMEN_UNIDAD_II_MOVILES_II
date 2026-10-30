import '../../../../core/presentation/widgets/panel_action_button.dart';
import '../../../../core/presentation/widgets/origin_page_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/presentation/widgets/confirmation_toast.dart';
import '../../../../core/presentation/widgets/loading_shimmer.dart';
import '../../domain/entities/case_poster.dart';
import '../../domain/entities/case_share.dart';
import '../view_models/case_share_view_model.dart';

class CaseShareSheet extends ConsumerStatefulWidget {
  const CaseShareSheet({
    required this.target,
    required this.title,
    required this.eventLabel,
    required this.onReport,
    this.caseActions = const [],
    super.key,
  });
  final PosterCase target;
  final String title, eventLabel;
  final Future<void> Function(OriginPageSource source) onReport;
  final List<Widget> caseActions;
  @override
  ConsumerState<CaseShareSheet> createState() => _CaseShareSheetState();
}

class _CaseShareSheetState extends ConsumerState<CaseShareSheet> {
  bool _reporting = false;

  Future<void> _report(BuildContext sourceContext) async {
    if (_reporting) return;
    final box = sourceContext.findRenderObject() as RenderBox;
    final navigator = Navigator.of(context).context.findRenderObject();
    final source = OriginPageSource(
      bounds: box.localToGlobal(Offset.zero, ancestor: navigator) & box.size,
      color: const Color(0xFFEEEEF0),
      radius: box.size.shortestSide / 2,
      child: const Icon(
        Icons.flag_outlined,
        size: 26,
        color: Color(0xFF111111),
      ),
    );
    setState(() => _reporting = true);
    try {
      await widget.onReport(source);
    } finally {
      if (mounted) setState(() => _reporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.target;
    final state = ref.watch(caseShareViewModelProvider(target));
    final model = ref.read(caseShareViewModelProvider(target).notifier);
    final v = state.isLoading ? null : state.asData?.value;
    final busy = v?.busy == true;
    Widget channel(
      CaseShareChannel action,
      String label,
      Color color,
      Widget icon,
    ) => Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingShimmer(
            isLoading: v?.action == action,
            loadingLabel: label,
            radius: 28,
            child: IconButton(
              tooltip: label,
              style: IconButton.styleFrom(
                backgroundColor: color,
                disabledBackgroundColor: color,
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white,
                fixedSize: const Size.square(56),
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
              ),
              onPressed: v == null || busy ? null : () => model.execute(action),
              icon: icon,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.25,
              color: Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
    return ConfirmationToastHost(
      confirmed: state.hasError || v?.notice != null,
      noticeId: (target, state.error, v?.actor, v?.noticeId),
      isError: state.hasError || v?.isError == true,
      message: state.hasError
          ? 'No pudimos preparar las opciones. Reintenta.'
          : v?.notice ?? '',
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .8,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Compartir ficha', style: AppTypography.primaryTitle),
                const SizedBox(height: 6),
                Text(
                  '${widget.title} · ${widget.eventLabel}',
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: Color(0xFF737F90),
                  ),
                ),
                const SizedBox(height: 28),
                if (state.isLoading)
                  const LoadingShimmer(
                    isLoading: true,
                    isAction: false,
                    loadingLabel: 'Preparando opciones de compartir',
                    child: SizedBox(
                      height: 100,
                      child: ColoredBox(color: Color(0xFFEEEEF0)),
                    ),
                  )
                else if (state.hasError)
                  TextButton(
                    onPressed: model.retry,
                    child: const Text('Reintentar'),
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      channel(
                        CaseShareChannel.copyLink,
                        'Copiar enlace',
                        const Color(0xFF0866FF),
                        const Icon(Icons.link_rounded, size: 30),
                      ),
                      channel(
                        CaseShareChannel.whatsapp,
                        'WhatsApp',
                        const Color(0xFF25D366),
                        const _WhatsAppIcon(),
                      ),
                      channel(
                        CaseShareChannel.facebook,
                        'Facebook',
                        const Color(0xFF0866FF),
                        const Text(
                          'f',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            height: 1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Divider(height: 1, color: Color(0xFFE2E3E6)),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    LoadingShimmer(
                      isLoading: v?.action == CaseShareChannel.download,
                      loadingLabel: 'Preparando PDF',
                      radius: 28,
                      child: PanelActionButton(
                        label: 'Descargar ficha en PDF',
                        onPressed: v == null || busy
                            ? null
                            : () => model.execute(CaseShareChannel.download),
                        icon: Icons.file_download_outlined,
                      ),
                    ),
                    Builder(
                      builder: (sourceContext) => IgnorePointer(
                        ignoring: _reporting,
                        child: Opacity(
                          opacity: _reporting ? 0 : 1,
                          child: PanelActionButton(
                            label: 'Denunciar contenido',
                            onPressed: busy
                                ? null
                                : () => _report(sourceContext),
                            icon: Icons.flag_outlined,
                          ),
                        ),
                      ),
                    ),
                    ...widget.caseActions.map(
                      (action) => SizedBox(width: 56, child: action),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WhatsAppIcon extends StatelessWidget {
  const _WhatsAppIcon();
  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 34,
    child: CustomPaint(
      painter: _ChatRing(),
      child: const Center(
        child: Icon(Icons.phone_rounded, color: Colors.white, size: 21),
      ),
    ),
  );
}

class _ChatRing extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;
    canvas.drawCircle(
      Offset(size.width * .51, size.height * .46),
      size.width * .39,
      paint,
    );
    final tail = Path()
      ..moveTo(size.width * .19, size.height * .7)
      ..lineTo(size.width * .12, size.height * .94)
      ..lineTo(size.width * .38, size.height * .83);
    canvas.drawPath(tail, paint);
  }

  @override
  bool shouldRepaint(_ChatRing oldDelegate) => false;
}
