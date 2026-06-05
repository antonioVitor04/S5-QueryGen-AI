import 'package:flutter/material.dart';

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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final enter = _enterAnim.value;
        final displayValue = (_countAnim.value * widget.targetValue).round();

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
                        color: widget.iconColor.withValues(alpha: 0.3 * enter),
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
    );
  }
}

class StatPillsRow extends StatelessWidget {
  const StatPillsRow({super.key});

  @override
  Widget build(BuildContext context) {
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
    ]);
  }
}
