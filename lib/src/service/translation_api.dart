import 'package:translation_api/src/service/suggestion/suggestion_contract.dart';
import 'package:translation_api/src/service/suggestion/suggestion_impl.dart';
import 'package:translation_api/src/service/transcription/transcription_contract.dart';
import 'package:translation_api/src/service/transcription/transcription_impl.dart';
import 'package:translation_api/src/service/translation/translation_contract.dart';
import 'package:translation_api/src/service/translation/translation_impl.dart';

class TranslationApi {
  static TranslationApi? _instance;
  late final ISuggestionService suggestionService;
  late final ITranscriptionService transcriptionService;
  late final ITranslationService translationService;

  TranslationApi._createInstance();
  factory TranslationApi() {
    if (_instance == null) {
      _instance = TranslationApi._createInstance();
      _instance!.suggestionService = SuggestionService();
      _instance!.transcriptionService = TranscriptionService();
      _instance!.translationService = TranslationService();
    }
    return _instance!;
  }
}
