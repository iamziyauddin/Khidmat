// Basic Flutter widget test for Khidmat app.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:khidmat/main.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: KhidmatApp()));

    // Verify that splash screen loads
    expect(find.text('Khidmat'), findsOneWidget);
    expect(find.text('Connecting Hearts,\nTransforming Lives'), findsOneWidget);
  });
}
