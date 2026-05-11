import 'dart:math' as math;
import 'package:flutter/material.dart';

class LineChartWidget extends StatefulWidget {
  final String label;
  final String value;
  final String delta;
  final List<double> data2025;
  final List<double> data2024;
  final List<String> xLabels;
  final Color lineColor;

  const LineChartWidget({
    super.key,
    this.label = 'Receita total',
    this.value = 'R\$ 237k',
    this.delta = '▲ 14.2%',
    this.data2025 = const [0.15, 0.28, 0.42, 0.48, 0.60, 0.64, 0.74, 0.84],
    this.data2024 = const [0.05, 0.10, 0.18, 0.25, 0.32, 0.36, 0.40, 0.44],
    this.xLabels = const ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago'],
    this.lineColor = const Color(0xFF6366f1),
  });

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _loopController;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _loopController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant LineChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data2025 != widget.data2025 || oldWidget.data2024 != widget.data2024) {
      _entryController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _loopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entryController, _loopController]),
      builder: (context, _) {
        final appear = Curves.easeOutCubic.transform(_entryController.value);
        return Opacity(
          opacity: appear,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF101526), Color(0xFF0C111F)]),
              border: Border.all(color: const Color(0xFF263055)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.label, style: const TextStyle(color: Color(0xFF7782A7), fontSize: 12)),
                  Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                    Text(widget.value, style: const TextStyle(color: Color(0xFFF0F3FF), fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Text(widget.delta, style: const TextStyle(color: Color(0xFF34d399), fontSize: 12, fontWeight: FontWeight.w600)),
                  ]),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  _LegendDot(color: widget.lineColor, label: '2025'),
                  const SizedBox(height: 4),
                  const _LegendDot(color: Color(0xFF2A3050), label: '2024'),
                ]),
              ]),
              const SizedBox(height: 12),
              Expanded(
                child: CustomPaint(
                  painter: _LinePainter(
                    data2025: widget.data2025,
                    data2024: widget.data2024,
                    lineColor: widget.lineColor,
                    phase: _loopController.value,
                    reveal: appear,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: widget.xLabels.map((l) => Text(l, style: const TextStyle(color: Color(0xFF475173), fontSize: 9.5))).toList()),
            ]),
          ),
        );
      },
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> data2025;
  final List<double> data2024;
  final Color lineColor;
  final double phase;
  final double reveal;

  _LinePainter({required this.data2025, required this.data2024, required this.lineColor, required this.phase, required this.reveal});

  List<Offset> _points(List<double> data, Size s) {
    final n = data.length;
    return List.generate(n, (i) => Offset(i / (n - 1) * s.width, (1 - data[i]) * s.height));
  }

  Path _smooth(List<Offset> p) {
    final path = Path()..moveTo(p.first.dx, p.first.dy);
    for (int i = 0; i < p.length - 1; i++) {
      final cp1 = Offset((p[i].dx + p[i + 1].dx) / 2, p[i].dy);
      final cp2 = Offset((p[i].dx + p[i + 1].dx) / 2, p[i + 1].dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p[i + 1].dx, p[i + 1].dy);
    }
    return path;
  }

  Offset _lerp(List<Offset> p, double t) {
    final scaled = t * (p.length - 1);
    final i = math.min(math.max(scaled.floor(), 0), p.length - 2);
    return Offset.lerp(p[i], p[i + 1], scaled - i)!;
  }

  @override
  void paint(Canvas c, Size s) {
    final p25 = _points(data2025, s);
    final p24 = _points(data2024, s);
    final g = _smooth(p24);
    final m = _smooth(p25);

    c.drawPath(g, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = const Color(0xFF33406B).withOpacity(0.8 * reveal));
    c.drawPath(Path.from(m)..lineTo(s.width, s.height)..lineTo(0, s.height)..close(), Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [lineColor.withOpacity(0.2 * reveal), lineColor.withOpacity(0)]).createShader(Rect.fromLTWH(0, 0, s.width, s.height)));
    c.drawPath(m, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.8..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..color = lineColor);

    for (int i = 0; i < p25.length; i++) {
      final pulse = (math.sin((phase * math.pi * 2) + (i * 0.9)) + 1) * 0.5;
      c.drawCircle(p25[i], 3.2 + (1.2 * pulse), Paint()..color = lineColor.withOpacity(0.9));
    }
    final t = _lerp(p25, phase);
    c.drawCircle(t, 11, Paint()..color = lineColor.withOpacity(0.18));
    c.drawCircle(t, 4.6, Paint()..color = lineColor);
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) => old.phase != phase || old.reveal != reveal || old.data2025 != data2025 || old.data2024 != data2024 || old.lineColor != lineColor;
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 4), Text(label, style: const TextStyle(color: Color(0xFF7782A7), fontSize: 11))]);
  }
}