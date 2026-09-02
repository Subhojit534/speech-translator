class TranscriptionPayload {
  final String sourceLanguage;
  final String audioContent;
  final int samplingRate;
  final String task;
  final String domain;
  final String serviceId;

  const TranscriptionPayload({
    required this.sourceLanguage,
    required this.audioContent,
    required this.domain,
    required this.samplingRate,
    required this.serviceId,
    required this.task,
  });

  Map<String, dynamic> toJson() => {
    "sourceLanguage": sourceLanguage,
    "audioContent": audioContent,
    "samplingRate": samplingRate,
    "serviceId": serviceId,
    "task": task,
  };
}
