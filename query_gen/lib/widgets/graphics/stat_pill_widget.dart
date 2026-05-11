import 'dart:math' as math;
import 'package:flutter/material.dart';

class StatPillWidget extends StatefulWidget {
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
  State<StatPillWidget> createState() => _StatPillWidgetState();
}

class _StatPillWidgetState extends State<StatPillWidget>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _loopController;
  late Animation<int> _countAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();
    _loopController = AnimationController(vsync: this, duration: const Duration(seconds: 5))
      ..repeat();
    _countAnimation = IntTween(begin: 0, end: widget.targetValue).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(covariant StatPillWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetValue != widget.targetValue) {
      _entryController
        ..reset()
        ..forward();
      _countAnimation = IntTween(begin: 0, end: widget.targetValue).animate(
        CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
      );
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _loopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entryController, _loopController]),
      builder: (context, _) {
        final reduced = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
        final appear = Curves.easeOutCubic.transform(_entryController.value);
        final pulse = reduced ? 0.5 : (math.sin(_loopController.value * math.pi * 2) + 1) * 0.5;
        return Opacity(
          opacity: appear,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - appear)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF101526), Color(0xFF0B1020)],
                ),
                border: Border.all(color: const Color(0xFF263055)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                Transform.scale(
                  scale: 1 + (0.04 * pulse),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: widget.iconBg,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: widget.iconColor.withOpacity(0.14 + (0.1 * pulse)),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(child: Text(widget.icon, style: TextStyle(color: widget.iconColor))),
                  ),
                ),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${_countAnimation.value}${widget.suffix}',
                      style: const TextStyle(color: Color(0xFFF0F3FF), fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(widget.label, style: const TextStyle(color: Color(0xFF7D87A6), fontSize: 10.5)),
                ]),
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
    return Row(children: const [
      Expanded(child: StatPillWidget(icon: '⚡', iconBg: Color(0xFF1A1E39), iconColor: Color(0xFF8A92FF), label: 'Latência', targetValue: 42, suffix: 'ms')),
      SizedBox(width: 10),
      Expanded(child: StatPillWidget(icon: '✓', iconBg: Color(0xFF0E2822), iconColor: Color(0xFF3BD8A6), label: 'Disponibilidade', targetValue: 99, suffix: '%')),
      SizedBox(width: 10),
      Expanded(child: StatPillWidget(icon: '◈', iconBg: Color(0xFF2D220D), iconColor: Color(0xFFFFB020), label: 'Eventos', targetValue: 1247)),
    ]);
  }
}