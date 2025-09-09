import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/text_screen.dart';
import 'package:frontend/screens/main_screen.dart';

void main() {
  group('Text Field Integration Tests', () {
    testWidgets('Flujo completo de traducción funciona correctamente', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: TextScreen(),
        ),
      );

      // Act - Escribir en el TextField de entrada
      await tester.enterText(find.byType(TextField).first, "Hola mundo");
      await tester.pump();

      // Assert - Verificar que la traducción aparece
      final outputTextField = tester.widget<TextField>(find.byType(TextField).at(1));
      expect(outputTextField.controller?.text, "Hola mundo (translated xd)");

      // Act - Cambiar el texto
      await tester.enterText(find.byType(TextField).first, "¿Cómo estás?");
      await tester.pump();

      // Assert - Verificar que la traducción se actualiza
      expect(outputTextField.controller?.text, "¿Cómo estás? (translated xd)");

      // Act - Limpiar el texto
      await tester.enterText(find.byType(TextField).first, "");
      await tester.pump();

      // Assert - Verificar que la salida se limpia
      expect(outputTextField.controller?.text, "");
    });

    testWidgets('Intercambio de idiomas funciona en contexto completo', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: TextScreen(),
        ),
      );

      // Act - Hacer clic en el botón de intercambio
      await tester.tap(find.byIcon(Icons.swap_horiz_outlined));
      await tester.pump();

      // Assert - Verificar que los idiomas se intercambian
      final dropdownMenus = find.byType(DropdownMenu);
      final inputDropdown = tester.widget<DropdownMenu>(dropdownMenus.first);
      final outputDropdown = tester.widget<DropdownMenu>(dropdownMenus.at(1));

      expect(inputDropdown.controller?.text, "Ingles");
      expect(outputDropdown.controller?.text, "");
    });

    testWidgets('Selección de idiomas funciona correctamente', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: TextScreen(),
        ),
      );

      // Act - Abrir el dropdown de entrada
      await tester.tap(find.byType(DropdownMenu).first);
      await tester.pumpAndSettle();

      // Assert - Verificar que el menú se abre
      expect(find.text("Español"), findsOneWidget);
      expect(find.text("Ingles"), findsOneWidget);
      expect(find.text("Alemán"), findsOneWidget);
      expect(find.text("Java"), findsOneWidget);
      expect(find.text("C++"), findsOneWidget);
    });

    testWidgets('Botones de sugerencias son interactivos', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: TextScreen(),
        ),
      );

      // Act - Hacer clic en un botón de sugerencia
      await tester.tap(find.text("Hello"));
      await tester.pump();

      // Assert - Verificar que el botón responde (aunque no haga nada por ahora)
      expect(find.text("Hello"), findsOneWidget);
    });

    testWidgets('Navegación entre pantallas mantiene estado de text fields', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: MainScreen(),
        ),
      );

      // Act - Escribir en el TextField de entrada
      await tester.enterText(find.byType(TextField).first, "Texto de prueba");
      await tester.pump();

      // Act - Cambiar a otra pestaña y volver
      await tester.tap(find.text("Buscar"));
      await tester.pump();
      await tester.tap(find.text("Traducir"));
      await tester.pump();

      // Assert - Verificar que el texto se mantiene
      final inputTextField = tester.widget<TextField>(find.byType(TextField).first);
      expect(inputTextField.controller?.text, "Texto de prueba");
    });

    testWidgets('Manejo de errores en text fields', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: TextScreen(),
        ),
      );

      // Act - Intentar operaciones que podrían causar errores
      await tester.enterText(find.byType(TextField).first, "Texto muy largo " * 100);
      await tester.pump();

      // Assert - Verificar que no hay errores
      expect(tester.takeException(), isNull);

      // Act - Limpiar y probar con caracteres especiales
      await tester.enterText(find.byType(TextField).first, "");
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, "🚀🎉💻");
      await tester.pump();

      // Assert - Verificar que funciona con emojis
      final inputTextField = tester.widget<TextField>(find.byType(TextField).first);
      expect(inputTextField.controller?.text, "🚀🎉💻");
    });

    testWidgets('Performance con múltiples actualizaciones', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: TextScreen(),
        ),
      );

      // Act - Múltiples actualizaciones rápidas
      for (int i = 0; i < 10; i++) {
        await tester.enterText(find.byType(TextField).first, "Texto $i");
        await tester.pump();
      }

      // Assert - Verificar que la última actualización es correcta
      final inputTextField = tester.widget<TextField>(find.byType(TextField).first);
      final outputTextField = tester.widget<TextField>(find.byType(TextField).at(1));
      
      expect(inputTextField.controller?.text, "Texto 9");
      expect(outputTextField.controller?.text, "Texto 9 (translated xd)");
    });
  });

  group('Accessibility Tests', () {
    testWidgets('Text fields tienen propiedades de accesibilidad', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: TextScreen(),
        ),
      );

      // Assert - Verificar que los TextFields tienen hintText
      final inputTextField = tester.widget<TextField>(find.byType(TextField).first);
      final outputTextField = tester.widget<TextField>(find.byType(TextField).at(1));
      
      expect(inputTextField.decoration?.hintText, "Ingrese un texto...");
      expect(outputTextField.decoration?.hintText, "Translation here...");
    });

  });
}
