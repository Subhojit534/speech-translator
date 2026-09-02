class SuggestionResponse {
  final String input;
  final String? error;
  final List<String> result;
  final bool success;

  const SuggestionResponse({
    required this.error,
    required this.input,
    required this.result,
    required this.success,
  });

  factory SuggestionResponse.fromJson(Map<String, dynamic> map) {
    return SuggestionResponse(
      error: map["error"],
      input: map["input"],
      result: (map["result"] as List).cast<String>(),
      success: map["success"],
    );
  }
}
