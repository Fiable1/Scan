import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rwanda_school_book_scanner/main.dart';

void main() {
  testWidgets('App builds and renders a MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(const BookScannerApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Rwanda School Book Scanner'), findsOneWidget);
  });
}