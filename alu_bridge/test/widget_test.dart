import 'package:alu_bridge/features/auth/view/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Onboarding page shows the get started button', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingPage()));

    expect(find.text('Get started'), findsOneWidget);
  });
}
