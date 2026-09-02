import 'package:translation_api/src/model/suggestion_response.dart';

abstract class ISuggestionService {
  Future<SuggestionResponse> getSuggestion({
    required String text,
    required String sourceLanguage,
  });
}
