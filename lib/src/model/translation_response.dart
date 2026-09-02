class TranslationResponse {
  final String taskType;
  final List<TranslationOutput> output;
  const TranslationResponse({required this.output, required this.taskType});

  factory TranslationResponse.fromJson(Map<String, dynamic> map) {
    return TranslationResponse(
      output: (map["output"] as List)
          .map((item) => TranslationOutput.fromJson(item))
          .toList(),
      taskType: map["taskType"],
    );
  }
}

class TranslationOutput {
  String source;
  String target;
  TranslationOutput({required this.source, required this.target});

  factory TranslationOutput.fromJson(Map<String, dynamic> map) {
    return TranslationOutput(source: map["source"], target: map["target"]);
  }
}
