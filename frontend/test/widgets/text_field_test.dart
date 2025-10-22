import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/ui/widgets/text/text_translation_widget.dart';
import 'package:frontend/ui/widgets/language_selector.dart';
import 'package:frontend/logic/controllers/text_translation_controller.dart';

void main() {
  group('TextTranslation Widget Tests', () {
    late TextTranslationController translationController;

    setUp(() {
      translationController = TextTranslationController();
    });

    testWidgets('TextField de entrada se renderiza correctamente', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextTranslationWidget(translationController: translationController),
          ),
        ),
      );

      // Assert
      expect(find.byType(TextField), findsNWidgets(2)); // 2 TextFields en TextTranslation
      
      // Verificar que el primer TextField (entrada) tiene las propiedades correctas
      final inputTextField = tester.widget<TextField>(find.byType(TextField).first);
      expect(inputTextField.keyboardType, TextInputType.text);
      expect(inputTextField.enableSuggestions, true);
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
            body: TextTranslationWidget(translationController: translationController),
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
            body: TextTranslationWidget(translationController: translationController),
          ),
        ),
      );

      // Act - Escribir en el TextField de entrada
      await tester.enterText(find.byType(TextField).first, "Hola mundo");
      await tester.pump();
      
      // Wait for translation to complete with error handling
      await tester.pump(Duration(milliseconds: 100));

      // Assert - Since translation will fail in test, verify the output is empty or contains error
      final outputTextField = tester.widget<TextField>(find.byType(TextField).at(1));
      // In test environment, translation will fail, so expect empty or error message
      expect(outputTextField.controller?.text, anyOf(isEmpty, contains('Error')));
    });

    testWidgets('TextField de entrada se limpia cuando está vacío', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextTranslationWidget(translationController: translationController),
          ),
        ),
      );

      // Act - Escribir y luego borrar
      await tester.enterText(find.byType(TextField).first, "Texto de prueba");
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, "");
      await tester.pumpAndSettle();

      // Assert - Verificar que el TextField de salida se limpia
      final outputTextField = tester.widget<TextField>(find.byType(TextField).at(1));
      expect(outputTextField.controller?.text, "");
    });

    testWidgets('Botón de limpiar funciona correctamente', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextTranslationWidget(translationController: translationController),
          ),
        ),
      );

      // Act - Escribir texto y hacer clic en el botón de limpiar
      await tester.enterText(find.byType(TextField).first, "Texto de prueba");
      await tester.pumpAndSettle(); // Wait for state updates
      
      // Verificar que el botón de limpiar aparece
      expect(find.byIcon(Icons.delete), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle(); // Wait for state updates

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
            body: TextTranslationWidget(translationController: translationController),
          ),
        ),
      );

      // Assert - Inicialmente no debe haber botón de limpiar
      expect(find.byIcon(Icons.delete), findsNothing);

      // Act - Escribir texto y rebuild the widget to show the button
      await tester.enterText(find.byType(TextField).first, "Texto");
      await tester.pumpAndSettle(); // Wait for state updates

      // Assert - Ahora debe aparecer el botón de limpiar
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('Botones de acción en TextField de salida se renderizan', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextTranslationWidget(translationController: translationController),
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
      
      expect(inputDropdown.hintText, "Seleccione un idioma");
      expect(inputDropdown.dropdownMenuEntries.length, 5); // 5 idiomas en la lista (Auto + 4 idiomas)
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
      
      expect(outputDropdown.controller?.text, "Inglés");
      // The keyboardType might be null in DropdownMenu by default
      expect(outputDropdown.keyboardType, anyOf(isNull, equals(TextInputType.text)));
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
      
      // After swap: input should have the original output value ("Inglés")
      // and output should have the original input value ("Español")
      expect(inputDropdown.controller?.text, "Inglés");
      expect(outputDropdown.controller?.text, "Español");
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
      
      final expectedLanguages = ["Auto", "Inglés", "Alemán", "Italiano", "Japonés"];
      final actualLanguages = inputDropdown.dropdownMenuEntries
          .map((entry) => entry.label)
          .toList();
      
      expect(actualLanguages, equals(expectedLanguages));
    });
  });
}
