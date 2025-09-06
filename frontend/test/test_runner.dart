import 'package:flutter_test/flutter_test.dart';

// Importar todos los archivos de test
import 'widgets/text_field_test.dart' as widget_tests;
import 'unit/text_editing_controller_test.dart' as unit_tests;
import 'integration/text_field_integration_test.dart' as integration_tests;

void main() {
  group('Text Field Test Suite', () {
    group('Widget Tests', () {
      widget_tests.main();
    });
    
    group('Unit Tests', () {
      unit_tests.main();
    });
    
    group('Integration Tests', () {
      integration_tests.main();
    });
  });
}
