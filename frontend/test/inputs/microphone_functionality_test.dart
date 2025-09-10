import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:path_provider_platform_interface/method_channel_path_provider.dart';
import 'package:record/record.dart';

import 'package:tu_app/record_button.dart'; // ajusta el import a tu ruta real

// --- Mocks ---
class MockAudioRecorder extends Mock implements AudioRecorder {}

class FakeRecordConfig extends Fake implements RecordConfig {}

class FakeDirectory extends Fake implements Directory {}

// --- Fake para path_provider ---
class FakePathProvider extends Fake implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => "/fake/documents";
}

void main() {
  late MockAudioRecorder mockRecorder;

  setUpAll(() {
    registerFallbackValue(FakeRecordConfig());
    PathProviderPlatform.instance = FakePathProvider(); // inyectamos fake
  });

  setUp(() {
    mockRecorder = MockAudioRecorder();
  });

  testWidgets('Renderiza botón inicial con ícono de micrófono', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecordButton(), // aquí tu widget
        ),
      ),
    );

    expect(find.byIcon(Icons.mic), findsOneWidget);
    expect(find.byIcon(Icons.stop), findsNothing);
  });

  testWidgets('Al presionar cambia de micrófono a stop y llama a start/stop', (tester) async {
    // Arrange
    when(() => mockRecorder.hasPermission()).thenAnswer((_) async => true);
    when(() => mockRecorder.start(any(), path: any(named: 'path')))
        .thenAnswer((_) async {});
    when(() => mockRecorder.stop()).thenAnswer((_) async => '/fake/documents/lastRecord.aacLc');

    // Montamos el widget pero reemplazando el recorder real por el mock
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return RecordButtonWithMock(mockRecorder);
            },
          ),
        ),
      ),
    );

    // Act 1: Presionamos → debe empezar grabación
    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(find.byIcon(Icons.stop), findsOneWidget);
    verify(() => mockRecorder.start(any(), path: any(named: 'path'))).called(1);

    // Act 2: Presionamos otra vez → debe detener grabación
    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(find.byIcon(Icons.mic), findsOneWidget);
    verify(() => mockRecorder.stop()).called(1);
  });
}

/// Versión de RecordButton que recibe un AudioRecorder inyectado
class RecordButtonWithMock extends RecordButton {
  final AudioRecorder recorder;
  const RecordButtonWithMock(this.recorder, {super.key});

  @override
  State<RecordButton> createState() => _RecordButtonWithMockState();
}

class _RecordButtonWithMockState extends _RecordButtonState {
  @override
  void initState() {
    super.initState();
    super.record = (widget as RecordButtonWithMock).recorder; // inyectamos mock
  }
}
