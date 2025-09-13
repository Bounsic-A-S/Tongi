import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/widgets/audio/record_button.dart';
import 'package:frontend/services/record_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class MockRecordService extends Mock implements RecordService {}

class FakePathProvider extends PathProviderPlatform {
  @override
  Future<String> getApplicationDocumentsPath() async => '/tmp';
}

void main() {
  late MockRecordService mockService;

  setUpAll(() {
    PathProviderPlatform.instance = FakePathProvider();
  });

  setUp(() {
    mockService = MockRecordService();
  });

  testWidgets('Start and stop recording when tapping button', (
    WidgetTester tester,
  ) async {
    // Arrange
    when(() => mockService.hasPermission()).thenAnswer((_) async => true);
    when(
      () => mockService.startRecording(any()),
    ).thenAnswer((_) async => Future.value());
    when(
      () => mockService.stopRecording(),
    ).thenAnswer((_) async => Future.value());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RecordButton(service: mockService)),
      ),
    );

    // Mic al inicio
    expect(find.byIcon(Icons.mic), findsOneWidget);

    // Tap para grabar
    await tester.tap(find.byType(IconButton));
    await tester.pump();

    verify(() => mockService.hasPermission()).called(1);
    verify(() => mockService.startRecording(any())).called(1);

    expect(find.byIcon(Icons.stop), findsOneWidget);

    // Tap para detener
    await tester.tap(find.byType(IconButton));
    await tester.pump();

    verify(() => mockService.stopRecording()).called(1);

    expect(find.byIcon(Icons.mic), findsOneWidget);
  });
}
