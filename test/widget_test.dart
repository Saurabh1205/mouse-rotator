import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mouse_rotator/main.dart';

void main() {
  testWidgets('Mouse rotator app smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const MouseRotatorApp());
    expect(find.text('Auto Mouse Rotator'), findsOneWidget);
    expect(find.text('until auto-rotate'), findsOneWidget);
    expect(find.text('Actions & Controls'), findsOneWidget);
  });
}
