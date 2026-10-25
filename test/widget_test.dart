// This is a basic Flutter widget test for the Turco app.
import 'package:flutter_test/flutter_test.dart';

import 'package:turco/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TurcoApp());

    // Verify the app title is present.
    expect(find.text('Turco'), findsOneWidget);
  });
}
