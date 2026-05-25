import 'package:flutter/material.dart';

class LineChartWidget extends StatelessWidget {
  final String label;
  final String value;
  final String delta;
  final List<double> data2025;
  final List<double> data2024;
  final List<String> xLabels;
  final Color lineColor;

  const LineChartWidget({
    super.key,
    this.label = 'Lorem',
    this.value = 'R\$ 237k',
    this.delta = '▲ 14.2%',
    this.data2025 = const [0.15, 0.28, 0.42, 0.48, 0.60, 0.64, 0.74, 0.84],
    this.data2024 = const [0.05, 0.10, 0.18, 0.25, 0.32, 0.36, 0.40, 0.44],
    this.xLabels = const ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago'],
    this.lineColor = const Color(0xFF6366f1),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label,
                    style: const TextStyle(
                        color: Color(0xFF6b7280), fontSize: 12)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(value,
                        style: const TextStyle(
                            color: Color(0xFFf0f2fc),
                            fontSize: 22,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Text(delta,
                        style: const TextStyle(
                            color: Color(0xFF34d399), fontSize: 12)),
                  ],
                ),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                _LegendDot(color: lineColor, label: '2025'),
                const SizedBox(height: 4),
                const _LegendDot(color: Color(0xFF2a3050), label: '2024'),
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
                lineProgress: 1.0,
                areaOpacity: 1.0,
                pulseRadius: 4.0,
                hoveredIndex: null,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: xLabels
                .map((l) => Text(l,
                    style: const TextStyle(
                        color: Color(0xFF3d4460), fontSize: 9.5)))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> data2025;
  final List<double> data2024;
  final Color lineColor;
  final double lineProgress;
  final double areaOpacity;
  final double pulseRadius;
  final int? hoveredIndex;

  _LinePainter({
    required this.data2025,
    required this.data2024,
    required this.lineColor,
    required this.lineProgress,
    required this.areaOpacity,
    required this.pulseRadius,
    this.hoveredIndex,
  });

  List<Offset> _points(List<double> data, Size size) {
    final n = data.length;
    return List.generate(n, (i) {
      final x = i / (n - 1) * size.width;
      final y = (1.0 - data[i]) * size.height;
      return Offset(x, y);
    });
  }

  Path _smoothPath(List<Offset> pts) {
    final path = Path();
    if (pts.isEmpty) return path;
    path.moveTo(pts[0].dx, pts[0].dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final cp1 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i].dy);
      final cp2 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i + 1].dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i + 1].dx, pts[i + 1].dy);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final pts25 = _points(data2025, size);
    final pts24 = _points(data2024, size);

    // 2024 ghost line
    final ghostPath = _smoothPath(pts24);
    canvas.drawPath(
      ghostPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF2a3050),
    );

    // 2025 area
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
            lineColor.withOpacity(0.22),
            lineColor.withOpacity(0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // 2025 line
    canvas.drawPath(
      linePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = lineColor,
    );

    // Dots on 2025 points
    for (int i = 0; i < pts25.length; i++) {
      final pt = pts25[i];
      canvas.drawCircle(
        pt,
        3.5,
        Paint()..color = lineColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 8, height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(label,
          style: const TextStyle(color: Color(0xFF6b7280), fontSize: 11)),
    ]);
  }
}