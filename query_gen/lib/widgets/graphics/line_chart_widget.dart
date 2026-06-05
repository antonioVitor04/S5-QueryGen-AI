import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class LineChartWidget extends StatefulWidget {
  final String label;
  final String value;
  final String delta;
  final List<double> data2025;
  final List<double> data2024;
  final List<String> xLabels;
  final Color lineColor;
  final Duration delay;

  const LineChartWidget({
    super.key,
    this.label = 'Receita Mensal',
    this.value = 'R\$ 237k',
    this.delta = '▲ 14.2%',
    this.data2025 = const [0.15, 0.28, 0.42, 0.48, 0.60, 0.64, 0.74, 0.84],
    this.data2024 = const [0.05, 0.10, 0.18, 0.25, 0.32, 0.36, 0.40, 0.44],
    this.xLabels = const [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago'
    ],
    this.lineColor = const Color(0xFF6366f1),
    this.delay = Duration.zero,
  });

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _enterAnim;
  late Animation<double> _lineAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    _enterAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );
    _lineAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.05, 1.0, curve: Curves.easeInOutCubic),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final enter = _enterAnim.value;

        return Opacity(
          opacity: enter,
          child: Transform.translate(
            offset: Offset(0, (1 - enter) * 12),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0f1119),
                border: Border.all(color: const Color(0xFF1e2236)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.label,
                                style: const TextStyle(
                                    color: Color(0xFF6b7280), fontSize: 12)),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(widget.value,
                                    style: const TextStyle(
                                        color: Color(0xFFf0f2fc),
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(width: 8),
                                Text(widget.delta,
                                    style: const TextStyle(
                                        color: Color(0xFF34d399),
                                        fontSize: 12)),
                              ],
                            ),
                          ]),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _LegendDot(color: widget.lineColor, label: '2025'),
                            const SizedBox(height: 4),
                            const _LegendDot(
                                color: Color(0xFF2a3050), label: '2024'),
                          ]),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: CustomPaint(
                      painter: _LinePainter(
                        data2025: widget.data2025,
                        data2024: widget.data2024,
                        lineColor: widget.lineColor,
                        lineProgress: _lineAnim.value,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: widget.xLabels
                        .map((l) => Text(l,
                            style: const TextStyle(
                                color: Color(0xFF3d4460), fontSize: 9.5)))
                        .toList(),
                  ),
                ],
=======
    final bgColor      = AppColors.panelOf(context);
    final borderColor  = AppColors.borderOf(context);
    final labelColor   = AppColors.text2Of(context);
    final valueColor   = AppColors.textOf(context);
    final xLabelColor  = AppColors.text3Of(context);
    final ghostColor   = AppColors.borderOf(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: TextStyle(color: labelColor, fontSize: 12)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(value, style: TextStyle(color: valueColor, fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Text(delta, style: const TextStyle(color: Color(0xFF34d399), fontSize: 12)),
                  ],
                ),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                _LegendDot(color: lineColor, label: '2025', labelColor: labelColor),
                const SizedBox(height: 4),
                _LegendDot(color: ghostColor, label: '2024', labelColor: labelColor),
              ]),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: CustomPaint(
              painter: _LinePainter(
                data2025: data2025,
                data2024: data2024,
                lineColor: lineColor,
                ghostColor: ghostColor,
>>>>>>> fa8d5fd552d9671f017231d83f3d7aa75a54123b
              ),
            ),
          ),
<<<<<<< HEAD
        );
      },
=======
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: xLabels.map((l) => Text(l, style: TextStyle(color: xLabelColor, fontSize: 9.5))).toList(),
          ),
        ],
      ),
>>>>>>> fa8d5fd552d9671f017231d83f3d7aa75a54123b
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> data2025;
  final List<double> data2024;
  final Color lineColor;
<<<<<<< HEAD
  final double lineProgress;

  _LinePainter({
    required this.data2025,
    required this.data2024,
    required this.lineColor,
    required this.lineProgress,
  });
=======
  final Color ghostColor;

  _LinePainter({required this.data2025, required this.data2024, required this.lineColor, required this.ghostColor});
>>>>>>> fa8d5fd552d9671f017231d83f3d7aa75a54123b

  List<Offset> _points(List<double> data, Size size) {
    final n = data.length;
    return List.generate(n, (i) => Offset(i / (n - 1) * size.width, (1.0 - data[i]) * size.height));
  }

  Path _smoothPath(List<Offset> pts) {
    final path = Path();
    if (pts.isEmpty) return path;
    path.moveTo(pts[0].dx, pts[0].dy);
    for (int i = 0; i < pts.length - 1; i++) {
<<<<<<< HEAD
      final cp1 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i].dy);
      final cp2 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i + 1].dy);
      path.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i + 1].dx, pts[i + 1].dy);
=======
      final cp1 = Offset((pts[i].dx + pts[i+1].dx) / 2, pts[i].dy);
      final cp2 = Offset((pts[i].dx + pts[i+1].dx) / 2, pts[i+1].dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i+1].dx, pts[i+1].dy);
>>>>>>> fa8d5fd552d9671f017231d83f3d7aa75a54123b
    }
    return path;
  }

  Offset _tipAt(Size size, double progress) {
    final n = data2025.length;
    final xProgress = progress * (n - 1);
    final i = xProgress.floor().clamp(0, n - 2);
    final t = xProgress - i;
    final smooth = t * t * (3 - 2 * t);
    final y1 = (1.0 - data2025[i]) * size.height;
    final y2 = (1.0 - data2025[i + 1]) * size.height;
    return Offset(size.width * progress, y1 + (y2 - y1) * smooth);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final pts25 = _points(data2025, size);
    final pts24 = _points(data2024, size);

<<<<<<< HEAD
    // Clip both lines to lineProgress
    canvas.save();
    canvas.clipRect(
        Rect.fromLTWH(0, 0, size.width * lineProgress, size.height));

    canvas.drawPath(
      _smoothPath(pts24),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF2a3050),
    );

    final linePath = _smoothPath(pts25);
    final areaPath = Path.from(linePath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.22),
            lineColor.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = lineColor,
    );

    for (final pt in pts25) {
      canvas.drawCircle(pt, 3.5, Paint()..color = lineColor);
    }

    canvas.restore();

    // Scanning dot at tip (only while drawing, not at final state)
    if (lineProgress > 0.01 && lineProgress < 0.98) {
      final tip = _tipAt(size, lineProgress);
      canvas.drawCircle(
        tip, 14,
        Paint()
          ..color = lineColor.withValues(alpha: 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      canvas.drawCircle(
        tip, 6,
        Paint()
          ..color = lineColor.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(tip, 3, Paint()..color = Colors.white);
=======
    canvas.drawPath(_smoothPath(pts24),
        Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = ghostColor);

    final linePath = _smoothPath(pts25);
    final areaPath = Path.from(linePath)
      ..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(areaPath, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [lineColor.withOpacity(0.22), lineColor.withOpacity(0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    canvas.drawPath(linePath, Paint()
      ..style = PaintingStyle.stroke..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..color = lineColor);

    for (final pt in pts25) {
      canvas.drawCircle(pt, 3.5, Paint()..color = lineColor);
>>>>>>> fa8d5fd552d9671f017231d83f3d7aa75a54123b
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
<<<<<<< HEAD
      old.lineProgress != lineProgress;
=======
      old.lineColor != lineColor || old.ghostColor != ghostColor;
>>>>>>> fa8d5fd552d9671f017231d83f3d7aa75a54123b
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final Color labelColor;
  const _LegendDot({required this.color, required this.label, required this.labelColor});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(color: labelColor, fontSize: 11)),
    ]);
  }
}
