import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/widgets/dashboard/tongi_appbar.dart';

void main() {
  testWidgets('TongiMicrophone muestra el  funcinamiento visual del microfono cuandose clickea un boton', (
    WidgetTester tester,
  ) async {
    bool pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: TongiAppbar(
            onSettingsPressed: () {
              pressed = true;
            },
          ),
        ),
      ),
    );

    // Verificar que existe la imagen del logo
    expect(find.byType(Image), findsOneWidget);

    // Verificar que el ícono de settings está presente
    expect(find.byIcon(Icons.settings), findsOneWidget);

    // Simular tap en el botón de settings
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Verificar que se ejecutó la acción
    expect(pressed, isTrue);
  });
}
