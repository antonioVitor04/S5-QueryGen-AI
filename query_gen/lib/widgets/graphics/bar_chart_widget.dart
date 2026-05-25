import 'package:flutter/material.dart';

class BarChartWidget extends StatelessWidget {
  final String label;
  final String value;
  final String delta;
  final List<double> data;
  final List<bool> highlights;
  final Color accentColor;

  const BarChartWidget({
    super.key,
    this.label = 'Lorem',
    this.value = '84k',
    this.delta = '▲ 8.3%',
    this.data = const [0.35, 0.55, 0.42, 0.70, 0.60, 0.85, 0.75],
    this.highlights = const [false, false, false, false, false, true, false],
    this.accentColor = const Color(0xFF6366f1),
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
          Text(
            label,
            style: const TextStyle(color: Color(0xFF6b7280), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFFf0f2fc),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                delta,
                style: const TextStyle(
                  color: Color(0xFF34d399),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(data.length, (i) {
                final isHighlight = highlights[i];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: FractionallySizedBox(
                      heightFactor: data[i],
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isHighlight
                                ? [accentColor, accentColor.withOpacity(0.7)]
                                : [const Color(0xFF1e2236), const Color(0xFF2a3050)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5),
                          ),
                          boxShadow: isHighlight
                              ? [
                                  BoxShadow(
                                    color: accentColor.withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, -2),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Lorem', 'Lorem', 'Lorem', 'Lorem', 'Lorem', 'Lorem', 'Lorem']
                .map((d) => Text(d,
                    style: const TextStyle(
                        color: Color(0xFF3d4460), fontSize: 9.5)))
                .toList(),
          ),
        ],
      ),
    );
  }
}