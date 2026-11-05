import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_gift_app/screen/widgets/summary_card.dart';

void main() {
  testWidgets('overview summary cards keep the same height', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Wrap(
            spacing: 16,
            children: [
              _card('Weddings', 'Active plans'),
              _card('Guests', 'Families invited'),
              _card('Gift records', 'Received today'),
              _card('Total gift amount', 'KHR collected: ៛315,000'),
            ],
          ),
        ),
      ),
    );

    final cards = find.byType(SummaryCard);
    expect(cards, findsNWidgets(4));
    for (var index = 0; index < 4; index++) {
      expect(tester.getSize(cards.at(index)).height, 236);
    }
    expect(tester.takeException(), isNull);
  });
}

Widget _card(String title, String subtitle) {
  return SummaryCard(
    icon: Icons.attach_money_rounded,
    title: title,
    value: '200',
    subtitle: subtitle,
    height: 236,
  );
}
