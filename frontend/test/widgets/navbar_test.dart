import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/widgets/dashboard/tongi_navbar.dart';
import 'package:frontend/core/tongi_colors.dart';

void main() {
  testWidgets('Navbar muestra los items correctamente', (
    WidgetTester tester,
  ) async {
    // Arrange
    int tappedIndex = -1;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: TongiNavbar(
            currentIndex: 0,
            onTap: (index) {
              tappedIndex = index;
            },
          ),
        ),
      ),
    );

    // Assert: los textos existen
    expect(find.text('Texto'), findsOneWidget);
    expect(find.text('Camara'), findsOneWidget);
    expect(find.text('Audio'), findsOneWidget);

    // Act: hacer tap en "Camara"
    await tester.tap(find.text('Camara'));
    await tester.pumpAndSettle();

    // Assert: se llamó onTap con índice correcto
    expect(tappedIndex, 1);
  });

  testWidgets('Navbar resalta el item seleccionado', (
    WidgetTester tester,
  ) async {
    // Arrange: seleccionamos el índice 2 (Audio)
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: TongiNavbar(currentIndex: 2, onTap: (_) {}),
        ),
      ),
    );

    // Act + Assert: verificar que el BottomNavigationBar tiene el índice correcto seleccionado
    final bottomNavBar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(bottomNavBar.currentIndex, 2);
    expect(bottomNavBar.selectedItemColor, TongiColors.primary);
  });
}
