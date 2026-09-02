import 'package:flutter_test/flutter_test.dart';
import 'package:translation_api/src/service/suggestion/suggestion_impl.dart';
import 'package:translation_api/translation_api.dart';

void main() {
  late final ISuggestionService suggestionService;
  setUpAll(() {
    suggestionService = SuggestionService();
  });

  test("Check if suggestions are being returned", () async {
    final res = await suggestionService.getSuggestion(
      sourceLanguage: "bn",
      text: "Hi",
    );
    expect(res.result, isNotEmpty);
  });
}
