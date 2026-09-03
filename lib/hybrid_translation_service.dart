import 'package:speech_translator/service/offline/offline_translator.dart';
import 'package:speech_translator/service/offline/ol_chiki_converter.dart';
import 'package:translation_api/translation_api.dart';

class HybridTranslationService {
  static final HybridTranslationService _instance = HybridTranslationService._internal();
  factory HybridTranslationService() => _instance;
  HybridTranslationService._internal();

  final TranslationApi _onlineService = TranslationApi();
  bool isOfflineMode = false;

  /// Translate with smart online / offline hybrid routing
  Future<TranslationResult> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    final clean = text.trim();
    if (clean.isEmpty) {
      return TranslationResult(
        sourceText: text,
        translatedText: '',
        sourceLang: sourceLang,
        targetLang: targetLang,
        phonetic: '',
        olChiki: '',
        devanagari: '',
      );
    }

    // If user selected offline mode, directly use local offline translator
    if (isOfflineMode) {
      return OfflineTranslator.translate(
        text: clean,
        fromLang: sourceLang,
        toLang: targetLang,
      );
    }

    // Try online AI4Bharat API with 1.5s timeout
    try {
      final onlineInput = (sourceLang == 'sat' && !OlChikiConverter.isOlChiki(clean))
          ? (RegExp(r'[\u0900-\u097F]').hasMatch(clean)
              ? OlChikiConverter.devanagariToOlChikiScript(clean)
              : OlChikiConverter.toOlChiki(clean))
          : clean;

      final res = await _onlineService
          .translationService.translate(
            sourceLanguage: sourceLang == 'sat' ? 'sat_Ol_Chiki' : sourceLang,
            targetLanguage: targetLang == 'sat' ? 'sat_Ol_Chiki' : targetLang,
            input: onlineInput,
          )
          .timeout(const Duration(milliseconds: 1500));

      if (res.output.isNotEmpty && res.output.first.target.isNotEmpty) {
        final targetText = res.output.first.target;
        return TranslationResult(
          sourceText: clean,
          translatedText: targetText,
          sourceLang: sourceLang,
          targetLang: targetLang,
          phonetic: targetLang == 'sat' ? OlChikiConverter.olChikiToLatinPhonetic(targetText) : clean,
          olChiki: targetLang == 'sat' ? targetText : OlChikiConverter.toOlChiki(clean),
          devanagari: targetLang == 'hi' ? targetText : clean,
          confidence: 1.0,
          isExactMatch: true,
        );
      }
    } catch (_) {
      // Immediate fallback to offline engine when internet is disconnected or timed out
    }

    // Fallback to offline engine
    return OfflineTranslator.translate(
      text: clean,
      fromLang: sourceLang,
      toLang: targetLang,
    );
  }
}
