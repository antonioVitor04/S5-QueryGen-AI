import 'dart:math' as math;
import 'package:flutter/material.dart';

class BarChartWidget extends StatefulWidget {
  final String label;
  final String value;
  final String delta;
  final List<double> data;
  final List<bool> highlights;
  final Color accentColor;

  const BarChartWidget({
    super.key,
    this.label = 'Conversões',
    this.value = '84k',
    this.delta = '▲ 8.3%',
    this.data = const [0.35, 0.55, 0.42, 0.70, 0.60, 0.85, 0.75],
    this.highlights = const [false, false, false, false, false, true, false],
    this.accentColor = const Color(0xFF6366f1),
  });

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _loopController;
  late final AnimationController _shimmerController;
  late final AnimationController _glowController;

  // Per-bar stagger animations
  late final List<Animation<double>> _barAnimations;

  // Header text animations
  late final Animation<double> _labelFade;
  late final Animation<Offset> _labelSlide;
  late final Animation<double> _valueFade;
  late final Animation<Offset> _valueSlide;

  int? _hoveredBar;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Staggered bar rise animations
    _barAnimations = List.generate(widget.data.length, (i) {
      final start = (i * 0.08).clamp(0.0, 0.6).toDouble();
      final end = (start + 0.55).clamp(0.0, 1.0).toDouble();
      return CurvedAnimation(
        parent: _entryController,
        curve: Interval(start, end, curve: Curves.easeOutBack),
      );
    });

    // Header animations
    _labelFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _labelSlide = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));
    _valueFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
    );
    _valueSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic),
    ));
  }

  @override
  void didUpdateWidget(covariant BarChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _entryController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _loopController.dispose();
    _shimmerController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _entryController,
        _loopController,
        _shimmerController,
        _glowController,
      ]),
      builder: (context, _) {
        final reduced = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
        final cardAppearRaw =
            Curves.easeOutCubic.transform(_entryController.value);
        final cardAppear = cardAppearRaw <= 0 ? 1.0 : cardAppearRaw;
        final shimmerPos = _shimmerController.value;
        final glowPulse = _glowController.value;

        return Opacity(
          opacity: cardAppear,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - cardAppear)),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF101526), Color(0xFF0C111F)],
                ),
                border: Border.all(
                  color: Color.lerp(
                    const Color(0xFF263055),
                    widget.accentColor.withOpacity(0.4),
                    glowPulse * 0.3,
                  )!,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor
                        .withOpacity(0.04 + 0.04 * glowPulse),
                    blurRadius: 30,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Shimmer overlay on entry
                  if (_entryController.value < 1.0)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: CustomPaint(
                          painter: _ShimmerPainter(
                            progress: shimmerPos,
                            opacity: (1 - _entryController.value).clamp(0.0, 0.4).toDouble(),
                          ),
                        ),
                      ),
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label with slide-in
                      FadeTransition(
                        opacity: _labelFade,
                        child: SlideTransition(
                          position: _labelSlide,
                          child: Text(
                            widget.label,
                            style: const TextStyle(
                              color: Color(0xFF7782A7),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Value with count-up feel via slide
                      FadeTransition(
                        opacity: _valueFade,
                        child: SlideTransition(
                          position: _valueSlide,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                widget.value,
                                style: const TextStyle(
                                  color: Color(0xFFF0F3FF),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Delta with shimmer glow
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D2B22),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFF34d399)
                                        .withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  widget.delta,
                                  style: const TextStyle(
                                    color: Color(0xFF34d399),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Bars
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(widget.data.length, (i) {
                            final wave = reduced
                                ? 0.5
                                : (math.sin((_loopController.value *
                                                math.pi *
                                                2) +
                                            (i * 0.9)) +
                                        1) *
                                    0.5;
                            final baseH = widget.data[i] *
                                (0.9 + 0.1 * wave) *
                                _barAnimations[i].value;
                            final hi = i < widget.highlights.length
                                ? widget.highlights[i]
                                : false;
                            final isHovered = _hoveredBar == i;

                            // Extra lift on hovered/highlighted bar
                              final h = isHovered
                                  ? (baseH * 1.05).clamp(0.0, 1.0).toDouble()
                                  : baseH.clamp(0.0, 1.0).toDouble();

                            return Expanded(
                              child: GestureDetector(
                                onTapDown: (_) =>
                                    setState(() => _hoveredBar = i),
                                onTapUp: (_) =>
                                    setState(() => _hoveredBar = null),
                                onTapCancel: () =>
                                    setState(() => _hoveredBar = null),
                                child: MouseRegion(
                                  onEnter: (_) =>
                                      setState(() => _hoveredBar = i),
                                  onExit: (_) =>
                                      setState(() => _hoveredBar = null),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Tooltip bubble on hover
                                        AnimatedOpacity(
                                          opacity: isHovered ? 1.0 : 0.0,
                                          duration: const Duration(
                                              milliseconds: 150),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 2),
                                            margin: const EdgeInsets.only(
                                                bottom: 4),
                                            decoration: BoxDecoration(
                                              color: hi
                                                  ? widget.accentColor
                                                  : const Color(0xFF2A3458),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '${(widget.data[i] * 100).round()}%',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Bar itself
                                        Expanded(
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            curve: Curves.easeOut,
                                            alignment: Alignment.bottomCenter,
                                            child: FractionallySizedBox(
                                              heightFactor: h,
                                              alignment:
                                                  Alignment.bottomCenter,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: hi
                                                        ? [
                                                            widget.accentColor
                                                                .withOpacity(
                                                                    0.6),
                                                            widget.accentColor,
                                                            Colors.white
                                                                .withOpacity(
                                                                    0.15),
                                                          ]
                                                        : isHovered
                                                            ? [
                                                                const Color(
                                                                    0xFF2D3860),
                                                                const Color(
                                                                    0xFF3D4F80),
                                                              ]
                                                            : [
                                                                const Color(
                                                                    0xFF1C2540),
                                                                const Color(
                                                                    0xFF263058),
                                                              ],
                                                    begin:
                                                        Alignment.bottomCenter,
                                                    end: Alignment.topCenter,
                                                    stops: hi
                                                        ? const [0.0, 0.7, 1.0]
                                                        : null,
                                                  ),
                                                  borderRadius:
                                                      const BorderRadius
                                                          .vertical(
                                                    top: Radius.circular(6),
                                                  ),
                                                  boxShadow: hi || isHovered
                                                      ? [
                                                          BoxShadow(
                                                            color: (hi
                                                                    ? widget
                                                                        .accentColor
                                                                    : const Color(
                                                                        0xFF45527F))
                                                                .withOpacity(
                                                                    0.15 +
                                                                        0.25 *
                                                                            wave),
                                                            blurRadius: 16,
                                                            offset:
                                                                const Offset(
                                                                    0, -3),
                                                          ),
                                                        ]
                                                      : null,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // X labels with staggered fade-in
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom']
                            .asMap()
                            .entries
                            .map((e) {
                          final labelAppear = Curves.easeOut.transform(
                                ((_entryController.value - e.key * 0.05) /
                                    0.6)
                                .clamp(0.0, 1.0).toDouble(),
                          );
                          return Opacity(
                            opacity: labelAppear,
                            child: Text(
                              e.value,
                              style: const TextStyle(
                                color: Color(0xFF475173),
                                fontSize: 9.5,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
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

class _ShimmerPainter extends CustomPainter {
  final double progress;
  final double opacity;

  _ShimmerPainter({required this.progress, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final x = -size.width + (size.width * 2.5 * progress);
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0),
          Colors.white.withOpacity(opacity),
          Colors.white.withOpacity(0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(x, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(x, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter old) =>
      old.progress != progress || old.opacity != opacity;
}
