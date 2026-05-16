import 'package:flutter_test/flutter_test.dart';
import 'package:neuroot/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NeurootApp());
    // App boots without crashing
    expect(find.byType(NeurootApp), findsOneWidget);
  });
}
