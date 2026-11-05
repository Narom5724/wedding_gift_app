import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wedding_gift_app/screen/widgets/responsive_app_shell.dart';
import 'package:wedding_gift_app/utils/app_translations.dart';

void main() {
  for (final width in [320.0, 390.0, 800.0, 1200.0]) {
    testWidgets('navigation adapts at width $width', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en'),
          fallbackLocale: const Locale('en'),
          home: const ResponsiveAppShell(
            selectedIndex: 0,
            child: Scaffold(body: Center(child: Text('Screen content'))),
          ),
        ),
      );
      await tester.pumpAndSettle();

      if (width >= 900) {
        expect(
          find.byKey(const ValueKey('responsive-navigation-rail')),
          findsOneWidget,
        );
        expect(find.text('Manage'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('responsive-navigation-bar')),
          findsNothing,
        );
      } else {
        expect(
          find.byKey(const ValueKey('responsive-navigation-rail')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('responsive-navigation-bar')),
          findsOneWidget,
        );
        expect(find.byTooltip('Manage'), findsOneWidget);
        if (width >= 600) {
          expect(find.text('Manage'), findsOneWidget);
        } else {
          expect(find.text('Manage'), findsNothing);
        }
      }

      expect(find.text('Screen content'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
