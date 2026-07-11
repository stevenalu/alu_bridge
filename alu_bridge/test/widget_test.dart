import 'package:alu_bridge/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots to the theme scratch page', (WidgetTester tester) async {
    await tester.pumpWidget(const AluBridgeApp());

    expect(find.text('Theme scratch'), findsOneWidget);
  });
}
