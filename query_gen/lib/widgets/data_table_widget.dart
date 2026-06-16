import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DataTableWidget extends StatelessWidget {
  final List<dynamic> dados;

  const DataTableWidget({super.key, required this.dados});

  @override
  Widget build(BuildContext context) {
    if (dados.isEmpty) {
      return Center(
        child: Text('Nenhum dado encontrado',
            style: TextStyle(color: AppColors.text2Of(context))),
      );
    }

    final primeiro = dados.first;
    if (primeiro is! Map) {
      return Center(
        child: Text('Formato de dados inválido',
            style: TextStyle(color: AppColors.text2Of(context))),
      );
    }
    final linhas = dados.take(100);
    final colunas = <String>{};
    for (final row in linhas) {
      if (row is Map) colunas.addAll(row.keys.map((k) => k.toString()));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.surfaceOf(context)),
        dataRowColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.accent.withValues(alpha: 0.1)
                : AppColors.panelOf(context)),
        dividerThickness: 0.5,
        columnSpacing: 20,
        headingTextStyle: TextStyle(
          color: AppColors.text2Of(context),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        dataTextStyle: TextStyle(
          color: AppColors.textOf(context),
          fontSize: 12,
          fontFamily: 'monospace',
        ),
        border: TableBorder.all(
          color: AppColors.borderOf(context),
          width: 0.5,
          borderRadius: BorderRadius.circular(8),
        ),
        columns: colunas.map((col) =>
          DataColumn(label: Text(col)),
        ).toList(),
        rows: linhas.map((row) =>
          DataRow(
            cells: colunas.map((col) =>
              DataCell(Text(
                row is Map ? (row[col]?.toString() ?? '—') : '—',
              )),
            ).toList(),
          ),
        ).toList(),
      ),
    );
  }
}