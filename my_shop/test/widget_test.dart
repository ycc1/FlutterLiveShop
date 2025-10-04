import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_shop/main.dart';

void main() {
  testWidgets('MyShop widget test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Welcome to My Shop'), findsOneWidget);
  });
}