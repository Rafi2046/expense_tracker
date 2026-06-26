import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';

class ExcelExportService {
  Future<File> generateExcel({
    required String title,
    required String dateRange,
    required List<String> headers,
    required List<Map<String, dynamic>> rows,
  }) async {
    final excel = Excel.createExcel();
    final sheetName = title.length > 31 ? title.substring(0, 31) : title;
    final sheet = excel[sheetName];

    sheet.setDefaultColumnWidth(18);

    final headerStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromInt(0xFF34495E),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    for (var col = 0; col < headers.length; col++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: col,
        rowIndex: 0,
      ));
      cell.value = TextCellValue(headers[col]);
      cell.cellStyle = headerStyle;
    }

    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];
      final isEven = rowIndex.isEven;
      final dataStyle = CellStyle(
        backgroundColorHex: isEven
            ? ExcelColor.fromHexString('FFF5F6FA')
            : ExcelColor.none,
        horizontalAlign: HorizontalAlign.Left,
        verticalAlign: VerticalAlign.Center,
      );

      for (var col = 0; col < headers.length; col++) {
        final headerKey = headers[col];
        final rawValue = row[headerKey];

        final cellIndex = CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: rowIndex + 1,
        );
        final cell = sheet.cell(cellIndex);

        if (rawValue is DateTime) {
          cell.value = DateTimeCellValue(
            year: rawValue.year,
            month: rawValue.month,
            day: rawValue.day,
            hour: rawValue.hour,
            minute: rawValue.minute,
          );
        } else if (rawValue is num) {
          cell.value = rawValue is int
              ? IntCellValue(rawValue)
              : DoubleCellValue(rawValue.toDouble());
        } else {
          cell.value = TextCellValue(rawValue?.toString() ?? '');
        }

        cell.cellStyle = dataStyle;
      }
    }

    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/report_$timestamp.xlsx');
    final bytes = excel.save();
    if (bytes == null) {
      throw Exception('Failed to generate Excel file');
    }
    await file.writeAsBytes(bytes);
    return file;
  }
}
