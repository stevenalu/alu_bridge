import 'package:alu_bridge/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots to a blank scaffold', (WidgetTester tester) async {
    await tester.pumpWidget(const AluBridgeApp());

    expect(find.byType(Scaffold), findsOneWidget);
  });
}
