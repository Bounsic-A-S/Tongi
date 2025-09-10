import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/widgets/audio/record_button.dart';

void main() {
  testWidgets('RecordButton alterna íconos entre mic y stop', (tester) async {
    // Montamos el widget
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RecordButton())),
    );

    // Verificamos que al inicio muestra micrófono
    expect(find.byIcon(Icons.mic), findsOneWidget);
    expect(find.byIcon(Icons.stop), findsNothing);

    // Primer tap -> debería cambiar a ícono stop
    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(find.byIcon(Icons.stop), findsOneWidget);
    expect(find.byIcon(Icons.mic), findsNothing);

    // Segundo tap -> debería volver a micrófono
    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(find.byIcon(Icons.mic), findsOneWidget);
    expect(find.byIcon(Icons.stop), findsNothing);
  });
}
