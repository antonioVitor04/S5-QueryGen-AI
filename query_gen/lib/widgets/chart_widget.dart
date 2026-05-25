import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';

class ChartWidget extends StatelessWidget {
  final List<dynamic> dados;
  final String tipoGrafico;
  final String? eixoX;
  final String? eixoY;

  const ChartWidget({
    super.key,
    required this.dados,
    required this.tipoGrafico,
    this.eixoX,
    this.eixoY,
  });

  static const _cores = [
    Color(0xFF2563EB),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
    Color(0xFF84CC16),
  ];

  Color _cor(int i) => _cores[i % _cores.length];

  String _labelX(dynamic item) {
    if (eixoX == null) return '';
    final val = item[eixoX];
    if (val == null) return '';
    final str = val.toString();
    return str.length > 10 ? '${str.substring(0, 10)}...' : str;
  }

  double _valorY(dynamic item) {
    if (eixoY == null) return 0;
    final val = item[eixoY];
    if (val == null) return 0;
    return double.tryParse(val.toString()) ?? 0;
  }

  String _formatNum(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(v % 1 == 0 ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    if (dados.isEmpty) {
      return const Center(
        child: Text('Sem dados para exibir',
            style: TextStyle(color: AppColors.text2)),
      );
    }

    switch (tipoGrafico) {
      case 'pizza':
        return _buildPizza();
      case 'linha':
        return _buildLinha();
      case 'barra':
      default:
        return _buildBarra();
    }
  }

  // ── PIZZA ──────────────────────────────────────────────────
  Widget _buildPizza() {
    final limitados = dados.take(8).toList();
    final total = limitados.fold<double>(0, (s, d) => s + _valorY(d));

    final sections = limitados.asMap().entries.map((e) {
      final valor = _valorY(e.value);
      final pct = total > 0 ? valor / total * 100 : 0;
      return PieChartSectionData(
        color: _cor(e.key),
        value: valor,
        title: '${pct.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (_, __) {},
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: limitados.asMap().entries.map((e) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: _cor(e.key),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                _labelX(e.value),
                style: const TextStyle(
                    color: AppColors.text2, fontSize: 11),
              ),
            ],
          )).toList(),
        ),
      ],
    );
  }

  // ── BARRA ──────────────────────────────────────────────────
  Widget _buildBarra() {
    final limitados = dados.take(10).toList();
    final maxY = limitados.fold<double>(
        0, (m, d) => _valorY(d) > m ? _valorY(d) : m);

    final groups = limitados.asMap().entries.map((e) =>
      BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: _valorY(e.value),
            color: _cor(e.key),
            width: 18,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4)),
          ),
        ],
      ),
    ).toList();

    return SizedBox(
      height: 240,
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.2,
          barGroups: groups,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: AppColors.border,
              strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (v, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(
                    _formatNum(v),
                    style: const TextStyle(
                        color: AppColors.text3, fontSize: 10),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= limitados.length) {
                    return const SizedBox();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      _labelX(limitados[i]),
                      style: const TextStyle(
                          color: AppColors.text3, fontSize: 9),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              // API atualizada 1.x — getTooltipColor no lugar de tooltipBgColor
              getTooltipColor: (_) => AppColors.surface,
              tooltipBorderRadius: BorderRadius.circular(8),
              getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                '${_labelX(limitados[group.x])}\n${_formatNum(rod.toY)}',
                const TextStyle(color: AppColors.text, fontSize: 11),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── LINHA ──────────────────────────────────────────────────
  Widget _buildLinha() {
    final limitados = dados.take(30).toList();
    final maxY = limitados.fold<double>(
        0, (m, d) => _valorY(d) > m ? _valorY(d) : m);

    final spots = limitados.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), _valorY(e.value)))
        .toList();

    return SizedBox(
      height: 240,
      child: LineChart(
        LineChartData(
          maxY: maxY * 1.2,
          minY: 0,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.accent,
              barWidth: 2.5,
              dotData: FlDotData(
                show: spots.length <= 15,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.accent,
                  strokeColor: AppColors.bg,
                  strokeWidth: 1.5,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.accent.withOpacity(0.1),
              ),
            ),
          ],
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: AppColors.border,
              strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (v, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(
                    _formatNum(v),
                    style: const TextStyle(
                        color: AppColors.text3, fontSize: 10),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: (limitados.length / 5).ceilToDouble(),
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= limitados.length) {
                    return const SizedBox();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      _labelX(limitados[i]),
                      style: const TextStyle(
                          color: AppColors.text3, fontSize: 9),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              // API atualizada 1.x — getTooltipColor no lugar de tooltipBgColor
              getTooltipColor: (_) => AppColors.surface,
              tooltipBorderRadius: BorderRadius.circular(8),
              getTooltipItems: (spots) => spots.map((s) {
                final i = s.x.toInt();
                final label =
                    i < limitados.length ? _labelX(limitados[i]) : '';
                return LineTooltipItem(
                  '$label\n${_formatNum(s.y)}',
                  const TextStyle(color: AppColors.text, fontSize: 11),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}