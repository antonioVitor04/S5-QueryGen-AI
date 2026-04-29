import 'package:flutter/material.dart';

class StatPillWidget extends StatelessWidget {
  final String icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final int targetValue;
  final String suffix;

  const StatPillWidget({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.targetValue,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0f1119),
        border: Border.all(color: const Color(0xFF1e2236)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(icon,
                style: TextStyle(color: iconColor, fontSize: 15)),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$targetValue$suffix',
              style: const TextStyle(
                color: Color(0xFFf0f2fc),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF6b7280), fontSize: 10.5),
            ),
          ],
        ),
      ]),
    );
  }
}

class StatPillsRow extends StatelessWidget {
  const StatPillsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: const [
      Expanded(
        child: StatPillWidget(
          icon: '⚡',
          iconBg: Color(0xFF1a1d35),
          iconColor: Color(0xFF818cf8),
          label: 'Lorem',
          targetValue: 42,
          suffix: 'ms',
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        child: StatPillWidget(
          icon: '✓',
          iconBg: Color(0xFF0d2420),
          iconColor: Color(0xFF34d399),
          label: 'Lorem',
          targetValue: 99,
          suffix: '%',
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        child: StatPillWidget(
          icon: '◈',
          iconBg: Color(0xFF261d0d),
          iconColor: Color(0xFFf59e0b),
          label: 'Lorem',
          targetValue: 1247,
          suffix: '',
        ),
      ),
    ]);
  }
}