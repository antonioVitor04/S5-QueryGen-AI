import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/chart_widget.dart';
import '../widgets/data_table_widget.dart';

class ChartScreen extends StatelessWidget {
  final List<dynamic> dados;
  final String tipoGrafico;
  final String? eixoX;
  final String? eixoY;
  final String descricao;

  const ChartScreen({
    super.key,
    required this.dados,
    required this.tipoGrafico,
    this.eixoX,
    this.eixoY,
    required this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          descricao,
          style: const TextStyle(fontSize: 15),
          overflow: TextOverflow.ellipsis,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gráfico
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _iconGrafico(),
                        color: AppColors.accent2,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _labelGrafico(),
                        style: const TextStyle(
                          color: AppColors.text2,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '${dados.length} registros',
                          style: const TextStyle(
                              color: AppColors.accent2,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ChartWidget(
                    dados: dados,
                    tipoGrafico: tipoGrafico,
                    eixoX: eixoX,
                    eixoY: eixoY,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tabela
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.table_chart_outlined,
                          color: AppColors.text2, size: 16),
                      const SizedBox(width: 8),
                      const Text('TABELA DE DADOS',
                          style: TextStyle(
                              color: AppColors.text2,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5)),
                      const Spacer(),
                      if (dados.length > 100)
                        const Text('Exibindo 100 primeiros',
                            style: TextStyle(
                                color: AppColors.text3, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DataTableWidget(dados: dados),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconGrafico() {
    switch (tipoGrafico) {
      case 'pizza':  return Icons.pie_chart_outline;
      case 'linha':  return Icons.show_chart;
      case 'barra':
      default:       return Icons.bar_chart;
    }
  }

  String _labelGrafico() {
    switch (tipoGrafico) {
      case 'pizza':  return 'GRÁFICO DE PIZZA';
      case 'linha':  return 'GRÁFICO DE LINHA';
      case 'barra':
      default:       return 'GRÁFICO DE BARRAS';
    }
  }
}