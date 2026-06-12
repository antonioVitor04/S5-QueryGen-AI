import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class BarChartWidget extends StatefulWidget {
  final String label;
  final String value;
  final String delta;
  final List<double> data;
  final List<bool> highlights;
  final Color accentColor;
  final Duration delay;

  const BarChartWidget({
    super.key,
    this.label = 'Consultas Geradas',
    this.value = '84k',
    this.delta = '▲ 8.3%',
    this.data = const [0.35, 0.55, 0.42, 0.70, 0.60, 0.85, 0.75],
    this.highlights = const [false, false, false, false, false, true, false],
    this.accentColor = const Color(0xFF6366f1),
    this.delay = Duration.zero,
  });

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _enterAnim;
  late Animation<double> _barsAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1100),
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
        final n = widget.data.length;
        const stagger = 0.07;
        final remaining = 1.0 - (n - 1) * stagger;

        return Opacity(
          opacity: enter,
          child: Transform.translate(
            offset: Offset(0, (1 - enter) * 12),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.panelOf(context),
                border: Border.all(color: AppColors.borderOf(context)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.label,
                      style: TextStyle(
                          color: AppColors.text2Of(context), fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(widget.value,
                          style: TextStyle(
                            color: AppColors.textOf(context),
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(width: 8),
                      Text(widget.delta,
                          style: const TextStyle(
                            color: Color(0xFF34d399),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(n, (i) {
                        final isHighlight =
                            i < widget.highlights.length && widget.highlights[i];
                        final barT =
                            ((_barsAnim.value - i * stagger) / remaining)
                                .clamp(0.0, 1.0);
                        final animatedHeight = widget.data[i] * barT;

                        return Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 3),
                            child: FractionallySizedBox(
                              heightFactor: animatedHeight.clamp(0.0, 1.0),
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isHighlight
                                        ? [
                                            widget.accentColor,
                                            widget.accentColor
                                                .withValues(alpha: 0.7),
                                          ]
                                        : [
                                            AppColors.borderOf(context),
                                            AppColors.surfaceOf(context),
                                          ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(5)),
                                  boxShadow: isHighlight
                                      ? [
                                          BoxShadow(
                                            color: widget.accentColor
                                                .withValues(alpha: 0.4 * barT),
                                            blurRadius: 14 * barT,
                                            spreadRadius: 1 * barT,
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
                    children: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom']
                        .map((d) => Text(d,
                            style: TextStyle(
                                color: AppColors.text3Of(context),
                                fontSize: 9.5)))
                        .toList(),
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
