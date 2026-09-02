class TranslationPayload {
  final String sourceLanguage;
  final String targetLanguage;
  final String input;
  final String task;
  final String serviceId;
  final bool track;
  const TranslationPayload({
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.input,
    required this.task,
    required this.serviceId,
    required this.track,
  });

  Map<String, dynamic> toJson() => {
    "sourceLanguage": sourceLanguage,
    "targetLanguage": targetLanguage,
    "input": input,
    "task": task,
    "serviceId": serviceId,
    "track": track,
  };
}
