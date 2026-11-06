import 'package:flutter/material.dart';

class AppRecordTable extends StatelessWidget {
  const AppRecordTable({
    super.key,
    required this.columns,
    required this.rows,
    this.onRowTap,
  });

  final List<String> columns;
  final List<List<Widget>> rows;
  final List<VoidCallback>? onRowTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowHeight: 54,
              dataRowMinHeight: 72,
              dataRowMaxHeight: 72,
              horizontalMargin: 16,
              columnSpacing: 28,
              dividerThickness: 1,
              headingRowColor: WidgetStatePropertyAll(
                theme.colorScheme.surfaceContainerLow,
              ),
              headingTextStyle: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              columns: [
                for (final column in columns)
                  DataColumn(label: Text(column.toUpperCase())),
              ],
              rows: [
                for (var index = 0; index < rows.length; index++)
                  DataRow(
                    cells: [
                      for (var cellIndex = 0;
                          cellIndex < rows[index].length;
                          cellIndex++)
                        DataCell(
                          rows[index][cellIndex],
                          onTap: cellIndex == 0 &&
                                  onRowTap != null &&
                                  index < onRowTap!.length
                              ? onRowTap![index]
                              : null,
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
