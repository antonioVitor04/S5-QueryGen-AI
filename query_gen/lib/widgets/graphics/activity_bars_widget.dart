import 'dart:math' as math;
import 'package:flutter/material.dart';

class ActivityBarsWidget extends StatefulWidget {
  final String title;
  final List<ActivityItem> items;

  const ActivityBarsWidget({
    super.key,
    this.title = 'Atividade',
    this.items = const [
      ActivityItem(label: '/home', value: 0.72, color: Color(0xFF6366f1)),
      ActivityItem(label: '/pricing', value: 0.45, color: Color(0xFF818cf8)),
      ActivityItem(label: '/checkout', value: 0.88, color: Color(0xFF34d399)),
      ActivityItem(label: '/blog', value: 0.31, color: Color(0xFFf59e0b)),
    ],
  });

  @override
  State<ActivityBarsWidget> createState() => _ActivityBarsWidgetState();
}

class _ActivityBarsWidgetState extends State<ActivityBarsWidget> with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _loopController;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _loopController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  }

  @override
  void didUpdateWidget(covariant ActivityBarsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _entryController
        ..reset()
        ..forward();
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
        return Opacity(
          opacity: appear,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF101526), Color(0xFF0C111F)]),
              border: Border.all(color: const Color(0xFF263055)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.title.toUpperCase(), style: const TextStyle(color: Color(0xFF7782A7), fontSize: 10.5, fontWeight: FontWeight.w600, letterSpacing: .9)),
              const SizedBox(height: 14),
              ...List.generate(widget.items.length, (i) {
                final item = widget.items[i];
                final phase = _loopController.value * math.pi * 2 + (i * 0.8);
                final wave = reduced ? 0.5 : (math.sin(phase) + 1) * 0.5;
                final grow = 0.93 + (0.08 * wave);
                final w = (item.value * grow).clamp(0.0, 1.0).toDouble();
                return Padding(
                  padding: EdgeInsets.only(bottom: i < widget.items.length - 1 ? 12 : 0),
                  child: Row(children: [
                    SizedBox(width: 82, child: Text(item.label, style: const TextStyle(color: Color(0xFF9CA6C1), fontSize: 11.5))),
                    Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6), child: Stack(children: [
                      Container(height: 26, color: const Color(0xFF1A223E)),
                      FractionallySizedBox(widthFactor: w, child: Container(height: 26, decoration: BoxDecoration(gradient: LinearGradient(colors: [item.color.withOpacity(0.78), item.color])))),
                    ]))),
                    const SizedBox(width: 10),
                    SizedBox(width: 38, child: Text('${(w * 100).round()}%', textAlign: TextAlign.right, style: TextStyle(color: item.color, fontSize: 11.5, fontWeight: FontWeight.w700))),
                  ]),
                );
              }),
            ]),
          ),
        );
      },
    );
  }
}

class ActivityItem {
  final String label;
  final double value;
  final Color color;
  const ActivityItem({required this.label, required this.value, required this.color});
}
