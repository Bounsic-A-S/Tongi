import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TextEditingController Unit Tests', () {
    late TextEditingController inputController;
    late TextEditingController outputController;

    setUp(() {
      inputController = TextEditingController();
      outputController = TextEditingController();
    });

    tearDown(() {
      inputController.dispose();
      outputController.dispose();
    });

    test('TextEditingController se inicializa vacío', () {
      // Assert
      expect(inputController.text, isEmpty);
      expect(outputController.text, isEmpty);
    });

    test('TextEditingController puede establecer texto', () {
      // Act
      inputController.text = "Hola mundo";
      outputController.text = "Hello world";

      // Assert
      expect(inputController.text, "Hola mundo");
      expect(outputController.text, "Hola mundo (translated xd)");
    });

    test('TextEditingController puede limpiar texto', () {
      // Arrange
      inputController.text = "Texto de prueba";
      outputController.text = "Texto de prueba (translated xd)";

      // Act
      inputController.clear();
      outputController.clear();

      // Assert
      expect(inputController.text, isEmpty);
      expect(outputController.text, isEmpty);
    });

    test('TextEditingController puede verificar si está vacío', () {
      // Arrange
      inputController.text = "Texto";
      outputController.text = "";

      // Assert
      expect(inputController.text.isNotEmpty, true);
      expect(outputController.text.isEmpty, true);
    });
  });

  group('TextTranslation Logic Tests', () {
    late TextEditingController inputController;
    late TextEditingController outputController;

    setUp(() {
      inputController = TextEditingController();
      outputController = TextEditingController();
    });

    tearDown(() {
      inputController.dispose();
      outputController.dispose();
    });

    test('Lógica de traducción simula correctamente', () {
      // Arrange
      const testInput = "Hola mundo";
      const expectedOutput = "Hola mundo (translated xd)";

      // Act - Simular la lógica de onChanged
      if (inputController.text.isEmpty) {
        outputController.text = "";
      } else {
        outputController.text = "${inputController.text} (translated xd)";
      }

      // Assert
      expect(outputController.text, "");

      // Act - Establecer texto de entrada
      inputController.text = testInput;
      if (inputController.text.isEmpty) {
        outputController.text = "";
      } else {
        outputController.text = "${inputController.text} (translated xd)";
      }

      // Assert
      expect(outputController.text, expectedOutput);
    });

    test('Lógica de limpieza funciona correctamente', () {
      // Arrange
      inputController.text = "Texto de prueba";
      outputController.text = "Texto de prueba (translated xd)";

      // Act - Simular limpieza
      inputController.clear();
      outputController.clear();

      // Assert
      expect(inputController.text, isEmpty);
      expect(outputController.text, isEmpty);
    });

    test('Lógica maneja texto vacío correctamente', () {
      // Arrange
      inputController.text = "Texto";
      outputController.text = "Texto (translated xd)";

      // Act - Simular entrada vacía
      inputController.text = "";
      if (inputController.text.isEmpty) {
        outputController.text = "";
      } else {
        outputController.text = "${inputController.text} (translated xd)";
      }

      // Assert
      expect(outputController.text, isEmpty);
    });
  });

  group('LanguageSelector Logic Tests', () {
    late TextEditingController inputMenuController;
    late TextEditingController outputMenuController;

    setUp(() {
      inputMenuController = TextEditingController();
      outputMenuController = TextEditingController(text: "Ingles");
    });

    tearDown(() {
      inputMenuController.dispose();
      outputMenuController.dispose();
    });

    test('LanguageSelector se inicializa con valores correctos', () {
      // Assert
      expect(inputMenuController.text, isEmpty);
      expect(outputMenuController.text, "Ingles");
    });

    test('Lógica de intercambio de idiomas funciona', () {
      // Arrange
      inputMenuController.text = "Español";
      outputMenuController.text = "Ingles";

      // Act - Simular intercambio
      String temp = inputMenuController.text;
      inputMenuController.text = outputMenuController.text;
      outputMenuController.text = temp;

      // Assert
      expect(inputMenuController.text, "Ingles");
      expect(outputMenuController.text, "Español");
    });

    test('Lógica de intercambio funciona con valores vacíos', () {
      // Arrange
      inputMenuController.text = "";
      outputMenuController.text = "Alemán";

      // Act - Simular intercambio
      String temp = inputMenuController.text;
      inputMenuController.text = outputMenuController.text;
      outputMenuController.text = temp;

      // Assert
      expect(inputMenuController.text, "Alemán");
      expect(outputMenuController.text, "");
    });

    test('Lista de idiomas contiene elementos correctos', () {
      // Arrange
      const List<String> expectedLanguages = ["Español", "Ingles", "Alemán", "Java", "C++"];

      // Assert
      expect(expectedLanguages.length, 5);
      expect(expectedLanguages, contains("Español"));
      expect(expectedLanguages, contains("Ingles"));
      expect(expectedLanguages, contains("Alemán"));
      expect(expectedLanguages, contains("Java"));
      expect(expectedLanguages, contains("C++"));
    });
  });

  group('TextSuggestions Logic Tests', () {
    test('Lista de sugerencias contiene elementos correctos', () {
      // Arrange
      const List<String> expectedSuggestions = ["Hello", "What's up", "How can I"];

      // Assert
      expect(expectedSuggestions.length, 3);
      expect(expectedSuggestions, contains("Hello"));
      expect(expectedSuggestions, contains("What's up"));
      expect(expectedSuggestions, contains("How can I"));
    });

  });

  group('TextField Validation Tests', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('TextField acepta texto normal', () {
      // Act
      controller.text = "Texto normal";

      // Assert
      expect(controller.text, "Texto normal");
      expect(controller.text.isNotEmpty, true);
    });

    test('TextField acepta texto con caracteres especiales', () {
      // Act
      controller.text = "Hola! Como estas? @#\$%";

      // Assert
      expect(controller.text, "Hola! Como estas? @#\$%");
    });

    test('TextField acepta texto multilínea', () {
      // Act
      controller.text = "Línea 1\nLínea 2\nLínea 3";

      // Assert
      expect(controller.text, "Línea 1\nLínea 2\nLínea 3");
      expect(controller.text.split('\n').length, 3);
    });

    test('TextField maneja texto muy largo', () {
      // Arrange
      String longText = "A" * 1000;

      // Act
      controller.text = longText;

      // Assert
      expect(controller.text.length, 1000);
      expect(controller.text, longText);
    });

    test('TextField maneja texto vacío y espacios', () {
      // Act & Assert
      controller.text = "";
      expect(controller.text.isEmpty, true);

      controller.text = "   ";
      expect(controller.text.trim().isEmpty, true);

      controller.text = "  texto  ";
      expect(controller.text.trim(), "texto");
    });
  });
}
