import 'dart:math' as math;
import 'package:flutter/material.dart';

class DonutChartWidget extends StatefulWidget {
  final String label;
  final List<DonutSegment> segments;

  const DonutChartWidget({
    super.key,
    this.label = 'Canais',
    this.segments = const [
      DonutSegment(label: 'Orgânico', value: 0.42, color: Color(0xFF6366f1)),
      DonutSegment(label: 'Pago', value: 0.28, color: Color(0xFF34d399)),
      DonutSegment(label: 'Referral', value: 0.18, color: Color(0xFFf59e0b)),
    ],
  });

  @override
  State<DonutChartWidget> createState() => _DonutChartWidgetState();
}

class _DonutChartWidgetState extends State<DonutChartWidget> with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _focusController;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _focusController = AnimationController(vsync: this, duration: const Duration(seconds: 7))..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant DonutChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.segments != widget.segments) {
      _entryController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.segments.fold<double>(0, (s, e) => s + e.value);
    return AnimatedBuilder(
      animation: Listenable.merge([_entryController, _focusController]),
      builder: (context, _) {
        final appear = Curves.easeOutCubic.transform(_entryController.value);
        final t = _focusController.value;
        final focusCenter =
            ((math.sin((t * math.pi * 2) - (math.pi / 2)) + 1) / 2) *
                (widget.segments.length - 1);

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
              Text(widget.label, style: const TextStyle(color: Color(0xFF7782A7), fontSize: 12)),
              const SizedBox(height: 2),
              const Text('Distribuição', style: TextStyle(color: Color(0xFFE7EBF7), fontSize: 28, fontWeight: FontWeight.w700, height: 1, letterSpacing: -0.3)),
              const SizedBox(height: 18),
              Expanded(
                child: Row(children: [
                  Expanded(
                    flex: 11,
                    child: Center(
                      child: SizedBox(
                        width: 170,
                        height: 170,
                        child: CustomPaint(
                          painter: _DonutPainter(segments: widget.segments, total: total, reveal: appear, focusCenter: focusCenter),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 9,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.segments.length, (i) {
                        final seg = widget.segments[i];
                        final emphasis = (1 - ((focusCenter - i).abs() / 1.2)).clamp(0.0, 1.0).toDouble();
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(children: [
                            Container(
                              width: 8 + (2 * emphasis),
                              height: 8 + (2 * emphasis),
                              decoration: BoxDecoration(color: seg.color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: seg.color.withOpacity(0.15 + (0.25 * emphasis)), blurRadius: 8)]),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(seg.label, style: TextStyle(color: Color.lerp(const Color(0xFFA8B0C4), const Color(0xFFEAF0FF), emphasis), fontSize: 12, fontWeight: FontWeight.w600))),
                            Text('${(seg.value * 100 * appear).round()}%', style: const TextStyle(color: Color(0xFFEAF0FF), fontSize: 12.5, fontWeight: FontWeight.w700)),
                          ]),
                        );
                      }),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class DonutSegment {
  final String label;
  final double value;
  final Color color;
  const DonutSegment({required this.label, required this.value, required this.color});
}

class _DonutPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final double total;
  final double reveal;
  final double focusCenter;

  _DonutPainter({required this.segments, required this.total, required this.reveal, required this.focusCenter});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width < size.height ? size.width : size.height) / 2 - 10;

    canvas.drawCircle(center, radius, Paint()..style = PaintingStyle.stroke..strokeWidth = 18..color = const Color(0xFF1B2340));

    const gap = 0.06;
    final normalized = total <= 0 ? 1.0 : total;
    var start = -3.14159265359 / 2;

    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i];
      final rawSweep = ((seg.value / normalized) * (3.14159265359 * 2)) - gap;
      final sweep = rawSweep * reveal;
      final emphasis = (1 - ((focusCenter - i).abs() / 1.2)).clamp(0.0, 1.0).toDouble();

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 18 + (3 * emphasis)
          ..strokeCap = StrokeCap.round
          ..shader = SweepGradient(startAngle: start, endAngle: start + sweep, colors: [seg.color.withOpacity(0.78 + (0.2 * emphasis)), seg.color]).createShader(Rect.fromCircle(center: center, radius: radius)),
      );

      start += rawSweep + gap;
    }

    final totalPct = (total * 100 * reveal).round();
    final t1 = TextPainter(text: const TextSpan(text: 'Total', style: TextStyle(color: Color(0xFF7782A7), fontSize: 12)), textDirection: TextDirection.ltr)..layout();
    t1.paint(canvas, Offset(center.dx - t1.width / 2, center.dy - 18));

    final t2 = TextPainter(text: TextSpan(text: '$totalPct%', style: const TextStyle(color: Color(0xFFEAF0FF), fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.6)), textDirection: TextDirection.ltr)..layout();
    t2.paint(canvas, Offset(center.dx - t2.width / 2, center.dy - 2));
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.segments != segments || oldDelegate.total != total || oldDelegate.reveal != reveal || oldDelegate.focusCenter != focusCenter;
  }
}
