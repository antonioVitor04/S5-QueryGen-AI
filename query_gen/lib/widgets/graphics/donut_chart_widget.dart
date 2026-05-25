import 'dart:math';
import 'package:flutter/material.dart';

class DonutChartWidget extends StatelessWidget {
  final String label;
  final List<DonutSegment> segments;

  const DonutChartWidget({
    super.key,
    this.label = 'Lorem',
    this.segments = const [
      DonutSegment(label: 'Lorem', value: 0.42, color: Color(0xFF6366f1)),
      DonutSegment(label: 'Lorem',  value: 0.28, color: Color(0xFF34d399)),
      DonutSegment(label: 'Lorem',  value: 0.18, color: Color(0xFFf59e0b)),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0f1119),
        border: Border.all(color: const Color(0xFF1e2236)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Color(0xFF6b7280), fontSize: 12)),
          const Text('Lorem',
              style: TextStyle(
                  color: Color(0xFFf0f2fc),
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: CustomPaint(
                    painter: _DonutPainter(
                      segments: segments,
                      progress: 1.0,
                      rotationAngle: 0.0,
                      hoveredIndex: -1,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(segments.length, (i) {
                      final seg = segments[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        child: Row(children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: seg.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(seg.label,
                              style: const TextStyle(
                                  color: Color(0xFF9ca3af), fontSize: 12)),
                          const Spacer(),
                          Text('${(seg.value * 100).toInt()}%',
                              style: const TextStyle(
                                  color: Color(0xFFe8eaf0),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ]),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
  final double progress;
  final double rotationAngle;
  final int hoveredIndex;

  _DonutPainter({
    required this.segments,
    required this.progress,
    required this.rotationAngle,
    required this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(cx, cy) - 10;
    const sw = 13.0;

    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..color = const Color(0xFF1e2236),
    );

    double startAngle = -pi / 2;
    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i];
      final sweep = seg.value * 2 * pi * progress;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round
        ..color = seg.color;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startAngle,
        sweep,
        false,
        paint,
      );

      startAngle += sweep;
    }

    final tp = TextPainter(
      text: const TextSpan(
        text: 'Total',
        style: TextStyle(color: Color(0xFF6b7280), fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - 14));

    final tp2 = TextPainter(
      text: const TextSpan(
        text: '88%',
        style: TextStyle(
          color: Color(0xFFf0f2fc),
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp2.paint(canvas, Offset(cx - tp2.width / 2, cy - 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}