import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class StatPillWidget extends StatefulWidget {
  final String icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final int targetValue;
  final String suffix;
  final Duration delay;

  const StatPillWidget({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.targetValue,
    this.suffix = '',
    this.delay = Duration.zero,
  });

  @override
  State<StatPillWidget> createState() => _StatPillWidgetState();
}

class _StatPillWidgetState extends State<StatPillWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _enterAnim;
  late Animation<double> _countAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _enterAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _countAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic),
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
        final displayValue =
            (_countAnim.value * widget.targetValue).round();

        return Opacity(
          opacity: enter,
          child: Transform.translate(
            offset: Offset(0, (1 - enter) * 10),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0f1119),
                border: Border.all(color: const Color(0xFF1e2236)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.iconBg,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: widget.iconColor
                            .withValues(alpha: 0.3 * enter),
                        blurRadius: 10 * enter,
                        spreadRadius: 1 * enter,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(widget.icon,
                        style: TextStyle(
                            color: widget.iconColor, fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$displayValue${widget.suffix}',
                      style: const TextStyle(
                        color: Color(0xFFf0f2fc),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      widget.label,
                      style: const TextStyle(
                          color: Color(0xFF6b7280), fontSize: 10.5),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        );
      },
=======
    final bgColor     = AppColors.panelOf(context);
    final borderColor = AppColors.borderOf(context);
    final valueColor  = AppColors.textOf(context);
    final labelColor  = AppColors.text2Of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(icon, style: TextStyle(color: iconColor, fontSize: 15))),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$targetValue$suffix',
                style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.w700)),
            Text(label, style: TextStyle(color: labelColor, fontSize: 10.5)),
          ],
        ),
      ]),
>>>>>>> fa8d5fd552d9671f017231d83f3d7aa75a54123b
    );
  }
}

class StatPillsRow extends StatelessWidget {
  const StatPillsRow({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return const Row(children: [
      Expanded(
        child: StatPillWidget(
          icon: '⚡',
          iconBg: Color(0xFF1a1d35),
          iconColor: Color(0xFF818cf8),
          label: 'Latência',
          targetValue: 42,
          suffix: 'ms',
          delay: Duration(milliseconds: 0),
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        child: StatPillWidget(
          icon: '✓',
          iconBg: Color(0xFF0d2420),
          iconColor: Color(0xFF34d399),
          label: 'Uptime',
          targetValue: 99,
          suffix: '%',
          delay: Duration(milliseconds: 100),
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        child: StatPillWidget(
          icon: '◈',
          iconBg: Color(0xFF261d0d),
          iconColor: Color(0xFFf59e0b),
          label: 'Consultas',
          targetValue: 1247,
          suffix: '',
          delay: Duration(milliseconds: 200),
        ),
      ),
=======
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(children: [
      Expanded(child: StatPillWidget(
        icon: '⚡',
        iconBg: isDark ? const Color(0xFF1a1d35) : const Color(0xFFEEF0FF),
        iconColor: const Color(0xFF818cf8),
        label: 'Lorem', targetValue: 42, suffix: 'ms',
      )),
      const SizedBox(width: 10),
      Expanded(child: StatPillWidget(
        icon: '✓',
        iconBg: isDark ? const Color(0xFF0d2420) : const Color(0xFFE6FAF5),
        iconColor: const Color(0xFF34d399),
        label: 'Lorem', targetValue: 99, suffix: '%',
      )),
      const SizedBox(width: 10),
      Expanded(child: StatPillWidget(
        icon: '◈',
        iconBg: isDark ? const Color(0xFF261d0d) : const Color(0xFFFFF8E6),
        iconColor: const Color(0xFFf59e0b),
        label: 'Lorem', targetValue: 1247, suffix: '',
      )),
>>>>>>> fa8d5fd552d9671f017231d83f3d7aa75a54123b
    ]);
  }
}
