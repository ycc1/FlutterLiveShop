import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_live_shop/main.dart';

void main() {
  testWidgets('MyShop widget test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Welcome to My Shop'), findsOneWidget);
  });

  testWidgets('Product List Screen displays products', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to the product list screen
    await tester.tap(find.byIcon(Icons.shopping_cart));
    await tester.pumpAndSettle();

    expect(find.byType(ProductListScreen), findsOneWidget);
  });

  testWidgets('Shopping Cart Screen displays cart items', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to the cart screen
    await tester.tap(find.byIcon(Icons.shopping_cart));
    await tester.pumpAndSettle();

    expect(find.byType(CartScreen), findsOneWidget);
  });

  testWidgets('Profile Screen displays user information', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to the profile screen
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  testWidgets('Live List Screen displays live streams', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to the live list screen
    await tester.tap(find.byIcon(Icons.live_tv));
    await tester.pumpAndSettle();

    expect(find.byType(LiveListScreen), findsOneWidget);
  });
}