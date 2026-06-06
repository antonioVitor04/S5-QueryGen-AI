import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ActivityBarsWidget extends StatefulWidget {
  final String title;
  final List<ActivityItem> items;
  final Duration delay;

  const ActivityBarsWidget({
    super.key,
    this.title = 'Endpoints',
    this.items = const [
      ActivityItem(label: '/generate', value: 0.72, color: Color(0xFF6366f1)),
      ActivityItem(label: '/optimize', value: 0.45, color: Color(0xFF818cf8)),
      ActivityItem(label: '/export',   value: 0.88, color: Color(0xFF34d399)),
      ActivityItem(label: '/history',  value: 0.31, color: Color(0xFFf59e0b)),
    ],
    this.delay = Duration.zero,
  });

  @override
  State<ActivityBarsWidget> createState() => _ActivityBarsWidgetState();
}

class _ActivityBarsWidgetState extends State<ActivityBarsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _enterAnim;
  late Animation<double> _barsAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _enterAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    _barsAnim = CurvedAnimation(
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
        final n = widget.items.length;
        const stagger = 0.12;
        final remaining = 1.0 - (n - 1) * stagger;

        return Opacity(
          opacity: enter,
          child: Transform.translate(
            offset: Offset(0, (1 - enter) * 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.panelOf(context),
                border: Border.all(color: AppColors.borderOf(context)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF34d399),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF34d399).withValues(alpha: 0.7),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.title.toUpperCase(),
                      style: TextStyle(
                        color: AppColors.text2Of(context),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  Column(
                    children: List.generate(n, (i) {
                      final item = widget.items[i];
                      final barT =
                          ((_barsAnim.value - i * stagger) / remaining)
                              .clamp(0.0, 1.0);
                      final animatedWidth = item.value * barT;
                      final displayPct = (item.value * 100 * barT).round();

                      return Padding(
                        padding: EdgeInsets.only(bottom: i < n - 1 ? 12 : 0),
                        child: Row(children: [
                          SizedBox(
                            width: 80,
                            child: Text(
                              item.label,
                              style: TextStyle(
                                color: AppColors.text2Of(context),
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Stack(children: [
                                Container(
                                  height: 26,
                                  color: AppColors.borderOf(context),
                                ),
                                FractionallySizedBox(
                                  widthFactor: animatedWidth.clamp(0.0, 1.0),
                                  child: Container(
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: item.color.withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: item.color
                                              .withValues(alpha: 0.45 * barT),
                                          blurRadius: 8 * barT,
                                          spreadRadius: 0.5 * barT,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 36,
                            child: Text(
                              '$displayPct%',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: item.color,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ]),
                      );
                    }),
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

class ActivityItem {
  final String label;
  final double value;
  final Color color;
  const ActivityItem(
      {required this.label, required this.value, required this.color});
}
