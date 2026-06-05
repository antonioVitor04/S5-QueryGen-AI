import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class DonutChartWidget extends StatefulWidget {
  final String label;
  final List<DonutSegment> segments;
  final Duration delay;

  const DonutChartWidget({
    super.key,
    this.label = 'Tipos de Consulta',
    this.segments = const [
<<<<<<< HEAD
      DonutSegment(label: 'SQL',     value: 0.42, color: Color(0xFF6366f1)),
      DonutSegment(label: 'NoSQL',   value: 0.28, color: Color(0xFF34d399)),
      DonutSegment(label: 'GraphQL', value: 0.18, color: Color(0xFFf59e0b)),
=======
      DonutSegment(label: 'Lorem', value: 0.42, color: Color(0xFF6366f1)),
      DonutSegment(label: 'Lorem', value: 0.28, color: Color(0xFF34d399)),
      DonutSegment(label: 'Lorem', value: 0.18, color: Color(0xFFf59e0b)),
>>>>>>> fa8d5fd552d9671f017231d83f3d7aa75a54123b
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
<<<<<<< HEAD
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
                        // Donut ring
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
                        // Legend with animated percentages
                        Expanded(
                          flex: 5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(widget.segments.length, (i) {
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
                                    // Colored left indicator
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
=======
    final bgColor     = AppColors.panelOf(context);
    final borderColor = AppColors.borderOf(context);
    final labelColor  = AppColors.text2Of(context);
    final valueColor  = AppColors.textOf(context);
    final legendColor = AppColors.text2Of(context);
    final pctColor    = AppColors.textOf(context);
    final trackColor  = AppColors.borderOf(context);
    final centerLabelColor = AppColors.text3Of(context);

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
          Text(label, style: TextStyle(color: labelColor, fontSize: 12)),
          Text('Lorem', style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: CustomPaint(
                    painter: _DonutPainter(
                      segments: segments,
                      trackColor: trackColor,
                      centerLabelColor: centerLabelColor,
                      centerValueColor: valueColor,
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        child: Row(children: [
                          Container(width: 8, height: 8,
                              decoration: BoxDecoration(color: seg.color, shape: BoxShape.circle)),
                          const SizedBox(width: 7),
                          Text(seg.label, style: TextStyle(color: legendColor, fontSize: 12)),
                          const Spacer(),
                          Text('${(seg.value * 100).toInt()}%',
                              style: TextStyle(color: pctColor, fontSize: 12, fontWeight: FontWeight.w600)),
                        ]),
                      );
                    }),
                  ),
                ),
              ],
>>>>>>> fa8d5fd552d9671f017231d83f3d7aa75a54123b
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
<<<<<<< HEAD
  final double progress;

  _DonutPainter({required this.segments, required this.progress});
=======
  final Color trackColor;
  final Color centerLabelColor;
  final Color centerValueColor;

  _DonutPainter({
    required this.segments,
    required this.trackColor,
    required this.centerLabelColor,
    required this.centerValueColor,
  });
>>>>>>> fa8d5fd552d9671f017231d83f3d7aa75a54123b

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(cx, cy) - 8;
    const sw = 14.0;

<<<<<<< HEAD
    // Background ring
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..color = const Color(0xFF1e2236),
    );
=======
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()..style = PaintingStyle.stroke..strokeWidth = sw..color = trackColor);
>>>>>>> fa8d5fd552d9671f017231d83f3d7aa75a54123b

    if (progress <= 0) return;

    double startAngle = -pi / 2;
    for (final seg in segments) {
<<<<<<< HEAD
      final sweep = seg.value * 2 * pi * progress;
      if (sweep <= 0) continue;

      // Outer glow (wider, semi-transparent)
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
=======
      final sweep = seg.value * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startAngle, sweep, false,
        Paint()..style = PaintingStyle.stroke..strokeWidth = sw..strokeCap = StrokeCap.round..color = seg.color,
>>>>>>> fa8d5fd552d9671f017231d83f3d7aa75a54123b
      );
      startAngle += sweep;
    }

<<<<<<< HEAD
    // Center: animated total
    final totalPct = segments.fold(0.0, (s, e) => s + e.value);
    final displayPct = (totalPct * 100 * progress).round();

    final tpLabel = TextPainter(
      text: const TextSpan(
        text: 'Total',
        style: TextStyle(color: Color(0xFF6b7280), fontSize: 10),
      ),
=======
    final tp = TextPainter(
      text: TextSpan(text: 'Total', style: TextStyle(color: centerLabelColor, fontSize: 11)),
>>>>>>> fa8d5fd552d9671f017231d83f3d7aa75a54123b
      textDirection: TextDirection.ltr,
    )..layout();
    tpLabel.paint(canvas, Offset(cx - tpLabel.width / 2, cy - 15));

<<<<<<< HEAD
    final tpPct = TextPainter(
      text: TextSpan(
        text: '$displayPct%',
        style: TextStyle(
          color: Color.lerp(const Color(0xFF9ca3af), const Color(0xFFf0f2fc),
              progress)!,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
=======
    final tp2 = TextPainter(
      text: TextSpan(text: '88%', style: TextStyle(color: centerValueColor, fontSize: 17, fontWeight: FontWeight.w700)),
>>>>>>> fa8d5fd552d9671f017231d83f3d7aa75a54123b
      textDirection: TextDirection.ltr,
    )..layout();
    tpPct.paint(canvas, Offset(cx - tpPct.width / 2, cy - 1));
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
<<<<<<< HEAD
      old.progress != progress;
}
=======
      old.trackColor != trackColor || old.centerValueColor != centerValueColor;
}
>>>>>>> fa8d5fd552d9671f017231d83f3d7aa75a54123b
