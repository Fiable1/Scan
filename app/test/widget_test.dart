import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rwanda_school_book_scanner/main.dart';

void main() {
  testWidgets('App builds and renders a MaterialApp', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const BookScannerApp());
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('RWANDA SCHOOL BOOK SCANNER'), findsOneWidget);
  });
}