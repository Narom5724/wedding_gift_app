import 'package:flutter_test/flutter_test.dart';

import 'package:wedding_gift_app/main.dart';

void main() {
  testWidgets('GetX app bootstrap loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(isDarkModeSaved: false));
    await tester.pumpAndSettle();
    expect(find.text('Wedding Gift Book'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
