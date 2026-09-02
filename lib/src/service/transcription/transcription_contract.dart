import 'package:translation_api/src/model/transcription_response.dart';

abstract class ITranscriptionService {
  /// {@template transcription_service_docs}
  /// Get transcription of audio content
  ///
  /// The [audioContent] must be base64 encoded
  ///{@endtemplate}
  Future<TranscriptionResponse> getTranscription({
    required String sourceLanguage,
    required String audioContent,
    required int samplingRate,
  });
}
