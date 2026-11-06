import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled Khmer fonts render regular and bold PDF text', () async {
    final regular = await rootBundle.load(
      'assets/fonts/NotoSansKhmer-Regular.ttf',
    );
    final bold = await rootBundle.load('assets/fonts/NotoSansKhmer-Bold.ttf');
    final latinRegular = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final latinBold = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');

    final regularFont = pw.Font.ttf(regular);
    final boldFont = pw.Font.ttf(bold);
    final latinFont = pw.Font.ttf(latinRegular);
    final latinBoldFont = pw.Font.ttf(latinBold);
    final document = pw.Document(
      theme: pw.ThemeData.withFont(
        base: regularFont,
        bold: boldFont,
        fontFallback: [latinFont, latinBoldFont],
      ),
    );
    document.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Wedding report - regular',
              style: pw.TextStyle(
                font: latinFont,
                fontNormal: latinFont,
                fontBold: latinBoldFont,
                fontSize: 12,
              ),
            ),
            pw.Text(
              'របាយការណ៍អាពាហ៍ពិពាហ៍',
              style: pw.TextStyle(
                font: regularFont,
                fontNormal: regularFont,
                fontBold: boldFont,
                fontFallback: [latinFont],
                fontSize: 12,
              ),
            ),
            pw.Text(
              'របាយការណ៍អាពាហ៍ពិពាហ៍',
              style: pw.TextStyle(
                font: boldFont,
                fontNormal: regularFont,
                fontBold: boldFont,
                fontWeight: pw.FontWeight.bold,
                fontFallback: [latinBoldFont],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );

    final bytes = await document.save();
    expect(bytes, isNotEmpty);
  });
}
