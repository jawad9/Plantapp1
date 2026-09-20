import 'package:flutter_test/flutter_test.dart';

import 'package:sproutroll_jungle_glow/main.dart';

void main() {
  testWidgets('Splash screen shows the SproutRoll title', (WidgetTester tester) async {
    await tester.pumpWidget(const SproutRollApp());

    // Let the splash sprout/title animation run partway.
    await tester.pump(const Duration(milliseconds: 1800));

    expect(find.text('SproutRoll'), findsOneWidget);
  });
}
