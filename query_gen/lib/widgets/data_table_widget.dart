import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DataTableWidget extends StatelessWidget {
  final List<dynamic> dados;

  const DataTableWidget({super.key, required this.dados});

  @override
  Widget build(BuildContext context) {
    if (dados.isEmpty) {
      return const Center(
        child: Text('Nenhum dado encontrado',
            style: TextStyle(color: AppColors.text2)),
      );
    }

    final colunas = (dados.first as Map).keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.surface),
        dataRowColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.accent.withOpacity(0.1)
                : AppColors.panel),
        dividerThickness: 0.5,
        columnSpacing: 20,
        headingTextStyle: const TextStyle(
          color: AppColors.text2,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        dataTextStyle: const TextStyle(
          color: AppColors.text,
          fontSize: 12,
          fontFamily: 'monospace',
        ),
        border: TableBorder.all(
          color: AppColors.border,
          width: 0.5,
          borderRadius: BorderRadius.circular(8),
        ),
        columns: colunas.map((col) =>
          DataColumn(label: Text(col.toString())),
        ).toList(),
        rows: dados.take(100).map((row) =>
          DataRow(
            cells: colunas.map((col) =>
              DataCell(Text(
                row[col]?.toString() ?? '—',
              )),
            ).toList(),
          ),
        ).toList(),
      ),
    );
  }
}