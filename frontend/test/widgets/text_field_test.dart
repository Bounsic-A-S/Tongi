import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/ui/widgets/text/text_translation_widget.dart';
import 'package:frontend/ui/widgets/language_selector.dart';


void main() {
  group('TextTranslation Widget Tests', () {
    testWidgets('TextField de entrada se renderiza correctamente', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextTranslation(controller: TextTranslationController()),
          ),
        ),
      );

      // Assert
      expect(find.byType(TextField), findsNWidgets(2)); // 2 TextFields en TextTranslation
      
      // Verificar que el primer TextField (entrada) tiene las propiedades correctas
      final inputTextField = tester.widget<TextField>(find.byType(TextField).first);
      expect(inputTextField.keyboardType, TextInputType.text);
      expect(inputTextField.enableSuggestions, false);
      expect(inputTextField.readOnly, false);
      
      
      // Verificar la decoración del TextField de entrada
      final inputDecoration = inputTextField.decoration as InputDecoration;
      expect(inputDecoration.hintText, "Ingrese un texto...");
      expect(inputDecoration.enabledBorder, isA<OutlineInputBorder>());
      expect(inputDecoration.focusedBorder, isA<OutlineInputBorder>());
    });

    testWidgets('TextField de salida se renderiza correctamente', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextTranslation(controller: TextTranslationController()),
          ),
        ),
      );

      // Assert
      final outputTextField = tester.widget<TextField>(find.byType(TextField).at(1));
      expect(outputTextField.readOnly, true);
      
      // Verificar la decoración del TextField de salida
      final outputDecoration = outputTextField.decoration as InputDecoration;
      expect(outputDecoration.hintText, "Translation here...");
      expect(outputDecoration.filled, true);
    });

    testWidgets('TextField de entrada actualiza el TextField de salida al escribir', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextTranslation(controller: TextTranslationController()),
          ),
        ),
      );

      // Act - Escribir en el TextField de entrada
      await tester.enterText(find.byType(TextField).first, "Hola mundo");
      await tester.pump();

      // Assert - Verificar que el TextField de salida se actualiza
      final outputTextField = tester.widget<TextField>(find.byType(TextField).at(1));
      expect(outputTextField.controller?.text, "Hola mundo (translated xd)");
    });

    testWidgets('TextField de entrada se limpia cuando está vacío', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextTranslation(controller: TextTranslationController()),
          ),
        ),
      );

      // Act - Escribir y luego borrar
      await tester.enterText(find.byType(TextField).first, "Texto de prueba");
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, "");
      await tester.pump();

      // Assert - Verificar que el TextField de salida se limpia
      final outputTextField = tester.widget<TextField>(find.byType(TextField).at(1));
      expect(outputTextField.controller?.text, "");
    });

    testWidgets('Botón de limpiar funciona correctamente', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextTranslation(controller: TextTranslationController()),
          ),
        ),
      );

      // Act - Escribir texto y hacer clic en el botón de limpiar
      await tester.enterText(find.byType(TextField).first, "Texto de prueba");
      await tester.pump();
      
      // Verificar que el botón de limpiar aparece
      expect(find.byIcon(Icons.delete), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      // Assert - Verificar que ambos TextFields se limpian
      final inputTextField = tester.widget<TextField>(find.byType(TextField).first);
      final outputTextField = tester.widget<TextField>(find.byType(TextField).at(1));
      expect(inputTextField.controller?.text, "");
      expect(outputTextField.controller?.text, "");
    });

    testWidgets('Botón de limpiar solo aparece cuando hay texto', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextTranslation(controller: TextTranslationController()),
          ),
        ),
      );

      // Assert - Inicialmente no debe haber botón de limpiar
      expect(find.byIcon(Icons.delete), findsNothing);

      // Act - Escribir texto
      await tester.enterText(find.byType(TextField).first, "Texto");
      await tester.pump();

      // Assert - Ahora debe aparecer el botón de limpiar
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('Botones de acción en TextField de salida se renderizan', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextTranslation(controller: TextTranslationController()),
          ),
        ),
      );

      // Assert - Verificar que los botones de acción están presentes
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
      expect(find.byIcon(Icons.star_border_rounded), findsOneWidget);
    });
  });

  group('LanguageSelector Widget Tests', () {
    testWidgets('LanguageSelector se renderiza con dos DropdownMenu', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(),
          ),
        ),
      );

      // Assert
      expect(find.byType(DropdownMenu<String>), findsNWidgets(2));
      expect(find.text("Entrada"), findsOneWidget);
      expect(find.text("Salida"), findsOneWidget);
      expect(find.byIcon(Icons.swap_horiz_outlined), findsOneWidget);
    });

    testWidgets('DropdownMenu de entrada tiene propiedades correctas', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(),
          ),
        ),
      );

      // Assert
      final dropdownMenus = find.byType(DropdownMenu<String>);
      final inputDropdown = tester.widget<DropdownMenu<String>>(dropdownMenus.first);
      
      expect(inputDropdown.enableFilter, true);
      expect(inputDropdown.hintText, "Seleccione un idioma");
      expect(inputDropdown.dropdownMenuEntries.length, 5); // 5 idiomas en la lista
    });

    testWidgets('DropdownMenu de salida tiene valor inicial correcto', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(),
          ),
        ),
      );

      // Assert
      final dropdownMenus = find.byType(DropdownMenu<String>);
      final outputDropdown = tester.widget<DropdownMenu<String>>(dropdownMenus.at(1));
      
      expect(outputDropdown.controller?.text, "Ingles");
      expect(outputDropdown.keyboardType, TextInputType.text);
    });

    testWidgets('Botón de intercambio funciona correctamente', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(),
          ),
        ),
      );

      // Act - Hacer clic en el botón de intercambio
      await tester.tap(find.byIcon(Icons.swap_horiz_outlined));
      await tester.pump();

      // Assert - Verificar que los valores se intercambian
      final dropdownMenus = find.byType(DropdownMenu<String>);
      final inputDropdown = tester.widget<DropdownMenu<String>>(dropdownMenus.first);
      final outputDropdown = tester.widget<DropdownMenu<String>>(dropdownMenus.at(1));
      
      expect(inputDropdown.controller?.text, "Ingles");
      expect(outputDropdown.controller?.text, "");
    });

    testWidgets('Lista de idiomas contiene los idiomas correctos', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(),
          ),
        ),
      );

      // Assert
      final dropdownMenus = find.byType(DropdownMenu<String>);
      final inputDropdown = tester.widget<DropdownMenu<String>>(dropdownMenus.first);
      
      final expectedLanguages = ["Español", "Ingles", "Alemán", "Java", "C++"];
      final actualLanguages = inputDropdown.dropdownMenuEntries
          .map((entry) => entry.label)
          .toList();
      
      expect(actualLanguages, equals(expectedLanguages));
    });
  });
}
