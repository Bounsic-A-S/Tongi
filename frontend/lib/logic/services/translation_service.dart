import 'package:frontend/logic/services/text/text_translation.dart';

class TranslationService {
  Future<String> translateText(
    String text, {
    String from = '',
    String to = 'es',
  }) async {
    String result = await ApiTranslationService.translateTextAzure(
      text,
      from,
      to,
    );
    return result;
  }

  Future<String> translateWithRealAPI(String text) async {
    throw UnimplementedError('Método real no implementado aún');
  }
}
