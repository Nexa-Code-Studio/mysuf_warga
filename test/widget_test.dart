
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsidia_mobile/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: SUBSIDIAApp()));

    // Verify that our counter starts at 0.
    expect(find.text('SUBSIDIA'), findsOneWidget);
  });
}
