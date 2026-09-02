import 'package:translation_api/src/model/suggestion_response.dart';
import 'package:translation_api/src/service/http_client/dio_client.dart';
import 'package:translation_api/src/service/suggestion/suggestion_contract.dart';

class SuggestionService implements ISuggestionService {
  final DioClient _dioClient = DioClient();
  final RegExp _regex = RegExp(r'[^a-zA-Z\s]');
  final RegExp _spaceRegex = RegExp(r'\s');
  @override
  Future<SuggestionResponse> getSuggestion({
    required String text,
    required String sourceLanguage,
  }) async {
    if (text.trim().contains(_spaceRegex)) {
      throw Exception("Text must have one word only for it to work");
    }
    text = text.trim().replaceAll(_regex, '');
    if (text.trim().replaceAll(_spaceRegex, '') == "") {
      throw Exception("A word must be present");
    }
    final res = await _dioClient.dio.get(
      Uri.encodeFull("${_dioClient.suggestionApiUrl}/$sourceLanguage/$text"),
    );
    return SuggestionResponse.fromJson(res.data);
  }
}
