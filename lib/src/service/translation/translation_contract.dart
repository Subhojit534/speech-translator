import 'package:translation_api/src/model/translation_response.dart';

abstract class ITranslationService {
  ///{@template translation_contract_docs}
  /// Translates one language to another
  ///
  /// [input] is the text you want to translate
  /// {@endtemplate}
  Future<TranslationResponse> translate({
    required String sourceLanguage,
    required String targetLanguage,
    required String input,
  });
}
