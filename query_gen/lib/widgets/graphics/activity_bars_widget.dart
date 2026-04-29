import 'package:flutter/material.dart';

class ActivityBarsWidget extends StatelessWidget {
  final String title;
  final List<ActivityItem> items;

  const ActivityBarsWidget({
    super.key,
    this.title = 'Lorem',
    this.items = const [
      ActivityItem(label: '/lorem',     value: 0.72, color: Color(0xFF6366f1)),
      ActivityItem(label: '/lorem',     value: 0.45, color: Color(0xFF818cf8)),
      ActivityItem(label: '/lorem',      value: 0.88, color: Color(0xFF34d399)),
      ActivityItem(label: '/lorem', value: 0.31, color: Color(0xFFf59e0b)),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0f1119),
        border: Border.all(color: const Color(0xFF1e2236)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF34d399),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFF34d399).withOpacity(0.6), blurRadius: 5)],
              ),
            ),
            const SizedBox(width: 6),
            Text(title.toUpperCase(),
                style: const TextStyle(color: Color(0xFF6b7280), fontSize: 10.5, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
          ]),
          const SizedBox(height: 14),
          Column(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final displayVal = item.value;
              return Padding(
                padding: EdgeInsets.only(bottom: i < items.length - 1 ? 12 : 0),
                child: Row(children: [
                  SizedBox(width: 80,
                    child: Text(item.label, style: const TextStyle(color: Color(0xFF9ca3af), fontSize: 11.5))),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Stack(children: [
                        Container(height: 26, color: const Color(0xFF1e2236)),
                        FractionallySizedBox(
                          widthFactor: displayVal.clamp(0.0, 1.0),
                          child: Container(
                            height: 26,
                            decoration: BoxDecoration(color: item.color.withOpacity(0.85), borderRadius: BorderRadius.circular(5)),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 36,
                    child: Text('${(displayVal * 100).round()}%',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: item.color, fontSize: 11.5, fontWeight: FontWeight.w600)),
                  ),
                ]),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class ActivityItem {
  final String label;
  final double value;
  final Color color;
  const ActivityItem({required this.label, required this.value, required this.color});
}