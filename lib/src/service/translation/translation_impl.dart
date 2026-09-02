import 'package:translation_api/src/model/translation_payload.dart';
import 'package:translation_api/src/model/translation_response.dart';
import 'package:translation_api/src/service/http_client/dio_client.dart';
import 'package:translation_api/src/service/translation/translation_contract.dart';

class TranslationService implements ITranslationService {
  final DioClient _dioClient = DioClient();

  ///{@macro translation_contract_docs}
  @override
  Future<TranslationResponse> translate({
    required String sourceLanguage,
    required String targetLanguage,
    required String input,
  }) async {
    final res = await _dioClient.dio.post(
      _dioClient.translationApiUrl,
      data: TranslationPayload(
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        input: input,
        task: "translation",
        serviceId: _dioClient.translateServiceId,
        track: true,
      ).toJson(),
    );
    return TranslationResponse.fromJson(res.data);
  }
}
