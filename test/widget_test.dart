// Test de fumée (smoke test) : vérifie que l'application se lance
// et affiche bien la navigation principale.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';

import 'package:boutik_malin/main.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App launches and shows bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const BoutikMalinApp());

    expect(find.text('Boutik Malin'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);
  });
}
