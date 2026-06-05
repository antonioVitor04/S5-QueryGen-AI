import 'dart:math';
import 'package:flutter/material.dart';

class DonutChartWidget extends StatefulWidget {
  final String label;
  final List<DonutSegment> segments;
  final Duration delay;

  const DonutChartWidget({
    super.key,
    this.label = 'Tipos de Consulta',
    this.segments = const [
      DonutSegment(label: 'SQL',     value: 0.42, color: Color(0xFF6366f1)),
      DonutSegment(label: 'NoSQL',   value: 0.28, color: Color(0xFF34d399)),
      DonutSegment(label: 'GraphQL', value: 0.18, color: Color(0xFFf59e0b)),
    ],
    this.delay = Duration.zero,
  });

  @override
  State<DonutChartWidget> createState() => _DonutChartWidgetState();
}

class _DonutChartWidgetState extends State<DonutChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _enterAnim;
  late Animation<double> _chartAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _enterAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );
    _chartAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.05, 1.0, curve: Curves.easeOutCubic),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final enter = _enterAnim.value;
        final sweep = _chartAnim.value;

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
                  Text(widget.label,
                      style: const TextStyle(
                          color: Color(0xFF6b7280), fontSize: 12)),
                  const Text('Distribuição',
                      style: TextStyle(
                          color: Color(0xFFf0f2fc),
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: CustomPaint(
                            painter: _DonutPainter(
                              segments: widget.segments,
                              progress: sweep,
                            ),
                            child: const SizedBox.expand(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                                List.generate(widget.segments.length, (i) {
                              final seg = widget.segments[i];
                              final animPct =
                                  (seg.value * 100 * sweep).round();
                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom: i < widget.segments.length - 1
                                        ? 8
                                        : 0),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 3,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: seg.color,
                                        borderRadius:
                                            BorderRadius.circular(2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: seg.color
                                                .withValues(alpha: 0.55),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: seg.color
                                              .withValues(alpha: 0.07),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Row(children: [
                                          Expanded(
                                            child: Text(
                                              seg.label,
                                              style: const TextStyle(
                                                color: Color(0xFF9ca3af),
                                                fontSize: 11,
                                              ),
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$animPct%',
                                            style: TextStyle(
                                              color: seg.color,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
  const DonutSegment(
      {required this.label, required this.value, required this.color});
}

class _DonutPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final double progress;

  _DonutPainter({required this.segments, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(cx, cy) - 8;
    const sw = 14.0;

    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..color = const Color(0xFF1e2236),
    );

    if (progress <= 0) return;

    double startAngle = -pi / 2;
    for (final seg in segments) {
      final sweep = seg.value * 2 * pi * progress;
      if (sweep <= 0) continue;

      // Outer glow
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startAngle,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw + 8
          ..strokeCap = StrokeCap.round
          ..color = seg.color.withValues(alpha: 0.18 * progress),
      );

      // Main arc
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startAngle,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round
          ..color = seg.color,
      );

      startAngle += sweep;
    }

    final totalPct = segments.fold(0.0, (s, e) => s + e.value);
    final displayPct = (totalPct * 100 * progress).round();

    final tpLabel = TextPainter(
      text: const TextSpan(
        text: 'Total',
        style: TextStyle(color: Color(0xFF6b7280), fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpLabel.paint(canvas, Offset(cx - tpLabel.width / 2, cy - 15));

    final tpPct = TextPainter(
      text: TextSpan(
        text: '$displayPct%',
        style: TextStyle(
          color: Color.lerp(
                  const Color(0xFF9ca3af), const Color(0xFFf0f2fc), progress)!,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpPct.paint(canvas, Offset(cx - tpPct.width / 2, cy - 1));
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.progress != progress;
}
