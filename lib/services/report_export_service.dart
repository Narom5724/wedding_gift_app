import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:wedding_gift_app/models/report/gift_report_model.dart';

class ReportExportService {
  static const _xlsxMimeType =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  Future<bool> exportExcel(GiftReportData data) async {
    final excel = Excel.createExcel();
    excel.rename('Sheet1', 'Summary');

    final summary = excel['Summary'];
    _append(summary, ['Metric', 'Value']);
    _append(summary, ['Total guests', data.guestCount]);
    _append(summary, ['Gift records', data.giftCount]);
    _append(summary, ['Total USD', data.totalUsd]);
    _append(summary, ['Total KHR', data.totalKhr]);

    final weddings = excel['By wedding'];
    _append(weddings, ['Wedding', 'Gift records', 'USD total', 'KHR total']);
    for (final report in data.weddings) {
      _append(weddings, [
        report.weddingName,
        report.giftCount,
        report.totalUsd,
        report.totalKhr,
      ]);
    }

    final days = excel['By day'];
    _append(days, ['Date', 'Gift records', 'USD total', 'KHR total']);
    for (final report in data.byDay) {
      _append(days, [
        DateFormat('yyyy-MM-dd').format(report.period),
        report.giftCount,
        report.totalUsd,
        report.totalKhr,
      ]);
    }

    final months = excel['By month'];
    _append(months, ['Month', 'Gift records', 'USD total', 'KHR total']);
    for (final report in data.byMonth) {
      _append(months, [
        DateFormat('yyyy-MM').format(report.period),
        report.giftCount,
        report.totalUsd,
        report.totalKhr,
      ]);
    }

    final guests = excel['Guests'];
    _append(guests, [
      'Guest',
      'Relationship',
      'Phone',
      'Wedding',
      'Gift records',
      'USD total',
      'KHR total',
    ]);
    for (final report in data.guests) {
      _append(guests, [
        report.guestName,
        report.relationship,
        report.phone,
        report.weddingName,
        report.giftCount,
        report.totalUsd,
        report.totalKhr,
      ]);
    }

    final largestGifts = excel['Largest gifts'];
    _append(largestGifts, ['Currency', 'Guest', 'Wedding', 'Amount', 'Date']);
    for (final report in [data.largestUsdGift, data.largestKhrGift]) {
      if (report == null) continue;
      _append(largestGifts, [
        report.currency,
        report.guestName,
        report.weddingName,
        report.amount,
        DateFormat('yyyy-MM-dd').format(report.date),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) throw StateError('Could not build the Excel file.');
    final savedTo = await FileSaver.instance.saveAs(
      name: 'wedding_gift_report',
      bytes: Uint8List.fromList(bytes),
      fileExtension: 'xlsx',
      mimeType: MimeType.custom,
      customMimeType: _xlsxMimeType,
    );
    return savedTo != null;
  }

  Future<bool> exportPdf(GiftReportData data) async {
    final pdf = pw.Document();
    final number = NumberFormat('#,##0.##');
    final date = DateFormat('yyyy-MM-dd');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          pw.Text(
            'Wedding Gift Report',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Guests: ${data.guestCount}    Gift records: ${data.giftCount}    '
            'USD: ${number.format(data.totalUsd)}    '
            'KHR: ${number.format(data.totalKhr)}',
          ),
          pw.SizedBox(height: 18),
          _pdfHeading('Totals by wedding'),
          _pdfTable(
            ['Wedding', 'Gift records', 'USD total', 'KHR total'],
            data.weddings
                .map((item) => [
                      item.weddingName,
                      '${item.giftCount}',
                      number.format(item.totalUsd),
                      number.format(item.totalKhr),
                    ])
                .toList(),
          ),
          pw.SizedBox(height: 14),
          _pdfHeading('Gifts by day'),
          _pdfTable(
            ['Date', 'Gift records', 'USD total', 'KHR total'],
            data.byDay
                .map((item) => [
                      date.format(item.period),
                      '${item.giftCount}',
                      number.format(item.totalUsd),
                      number.format(item.totalKhr),
                    ])
                .toList(),
          ),
          pw.SizedBox(height: 14),
          _pdfHeading('Gifts by month'),
          _pdfTable(
            ['Month', 'Gift records', 'USD total', 'KHR total'],
            data.byMonth
                .map((item) => [
                      DateFormat('yyyy-MM').format(item.period),
                      '${item.giftCount}',
                      number.format(item.totalUsd),
                      number.format(item.totalKhr),
                    ])
                .toList(),
          ),
          pw.SizedBox(height: 14),
          _pdfHeading('Guest contributions'),
          _pdfTable(
            [
              'Guest',
              'Relationship',
              'Phone',
              'Wedding',
              'Records',
              'USD total',
              'KHR total',
            ],
            data.guests
                .map((item) => [
                      item.guestName,
                      item.relationship,
                      item.phone,
                      item.weddingName,
                      '${item.giftCount}',
                      number.format(item.totalUsd),
                      number.format(item.totalKhr),
                    ])
                .toList(),
          ),
          pw.SizedBox(height: 14),
          _pdfHeading('Largest gifts by currency'),
          _pdfTable(
            ['Currency', 'Guest', 'Wedding', 'Amount', 'Date'],
            [
              for (final item in [data.largestUsdGift, data.largestKhrGift])
                if (item != null)
                  [
                    item.currency,
                    item.guestName,
                    item.weddingName,
                    number.format(item.amount),
                    date.format(item.date),
                  ],
            ],
          ),
        ],
      ),
    );

    final savedTo = await FileSaver.instance.saveAs(
      name: 'wedding_gift_report',
      bytes: Uint8List.fromList(await pdf.save()),
      fileExtension: 'pdf',
      mimeType: MimeType.pdf,
    );
    return savedTo != null;
  }

  void _append(Sheet sheet, List<Object> values) {
    sheet.appendRow([
      for (final value in values)
        switch (value) {
          int value => IntCellValue(value),
          double value => DoubleCellValue(value),
          _ => TextCellValue(value.toString()),
        },
    ]);
  }

  pw.Widget _pdfHeading(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  );

  pw.Widget _pdfTable(List<String> headers, List<List<String>> rows) {
    return pw.Table.fromTextArray(
      headers: headers,
      data: rows.isEmpty ? [List.filled(headers.length, '—')] : rows,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellPadding: const pw.EdgeInsets.all(5),
    );
  }
}
