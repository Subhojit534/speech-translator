class TranscriptionResponse {
  final String taskType;
  final List<TranscriptionOutput> output;

  const TranscriptionResponse({required this.taskType, required this.output});

  factory TranscriptionResponse.fromJson(Map<String, dynamic> map) {
    return TranscriptionResponse(
      taskType: map["taskType"],
      output: (map["output"] as List)
          .map((item) => TranscriptionOutput.fromJson(item))
          .toList(),
    );
  }
}

class TranscriptionOutput {
  String source;

  TranscriptionOutput({required this.source});

  factory TranscriptionOutput.fromJson(Map<String, dynamic> map) {
    return TranscriptionOutput(source: map["source"]);
  }
}
