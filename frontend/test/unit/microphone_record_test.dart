import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/widgets/audio/record_button.dart';
import 'package:frontend/services/record_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class MockRecordService extends Mock implements RecordService {}

class _FakePathProvider extends PathProviderPlatform {
  Directory? _tempDir;

  Future<Directory> _ensureTemp() async {
    return _tempDir ??= await Directory.systemTemp.createTemp('path_provider_test_');
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    final dir = await _ensureTemp();
    return dir.path;
  }
}

void main() {
  late MockRecordService mockService;

  setUpAll(() {
    PathProviderPlatform.instance = _FakePathProvider();
  });

  setUp(() {
    mockService = MockRecordService();
  });

  testWidgets('Inicia y detiene grabación al presionar el botón', (tester) async {
    // Stub del servicio
    when(() => mockService.hasPermission()).thenAnswer((_) async => true);

    final startCompleter = Completer<void>();
    when(() => mockService.startRecording(any())).thenAnswer((_) async {
      startCompleter.complete();
    });

    final stopCompleter = Completer<void>();
    when(() => mockService.stopRecording()).thenAnswer((_) async {
      stopCompleter.complete();
      return 'fake_path';
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RecordButton(service: mockService)),
      ),
    );

    // Tap 1: inicia grabación
    await tester.tap(find.byType(IconButton));
    await tester.pump(); // 🔑 deja que procese el cambio de estado
    await startCompleter.future;

    verify(() => mockService.hasPermission()).called(1);
    verify(() => mockService.startRecording(any())).called(1);

    // Tap 2: detiene grabación
    await tester.tap(find.byType(IconButton));
    await tester.pump(); // 🔑 deja que procese el cambio de estado
    await stopCompleter.future;

    verify(() => mockService.stopRecording()).called(1);
  });
}
