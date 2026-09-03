import 'package:flutter_test/flutter_test.dart';
import 'package:speech_translator/service/offline/offline_translator.dart';
import 'package:speech_translator/service/offline/ol_chiki_converter.dart';
import 'package:speech_translator/service/offline/santali_dictionary.dart';

void main() {
  group('Offline Translator Tests', () {
    test('Translates common Hindi greetings to Santali Ol Chiki', () {
      final res = OfflineTranslator.translate(
        text: 'नमस्ते',
        fromLang: 'hi',
        toLang: 'sat',
      );

      expect(res.translatedText, equals('ᱡᱚᱦᱟᱨ'));
      expect(res.phonetic, equals('Johar'));
      expect(res.isExactMatch, isTrue);
    });

    test('Translates "आप कैसे हैं?" accurately', () {
      final res = OfflineTranslator.translate(
        text: 'आप कैसे हैं?',
        fromLang: 'hi',
        toLang: 'sat',
      );

      expect(res.translatedText, equals('ᱪᱮᱫ ᱞᱮᱠᱟ ᱢᱮᱱᱟᱜ ᱵᱤᱱᱟ?'));
      expect(res.isExactMatch, isTrue);
    });

    test('Translates "मुझे पानी चाहिए" accurately', () {
      final res = OfflineTranslator.translate(
        text: 'मुझे पानी चाहिए',
        fromLang: 'hi',
        toLang: 'sat',
      );

      expect(res.translatedText, equals('ᱤᱧ ᱫᱟᱜ ᱫᱚᱨᱠᱟᱨ'));
      expect(res.phonetic.toLowerCase(), contains('dag'));
    });

    test('Translates Santali Ol Chiki, Latin and Devanagari to Hindi', () {
      final res1 = OfflineTranslator.translate(
        text: 'ᱡᱚᱦᱟᱨ',
        fromLang: 'sat',
        toLang: 'hi',
      );
      expect(res1.translatedText, equals('नमस्ते'));

      final res2 = OfflineTranslator.translate(
        text: 'Johar',
        fromLang: 'sat',
        toLang: 'hi',
      );
      expect(res2.translatedText, equals('नमस्ते'));

      final res3 = OfflineTranslator.translate(
        text: 'Chet leka menag bina?',
        fromLang: 'sat',
        toLang: 'hi',
      );
      expect(res3.translatedText, equals('आप कैसे हैं?'));

      final res4 = OfflineTranslator.translate(
        text: 'ᱫᱟᱜ',
        fromLang: 'sat',
        toLang: 'hi',
      );
      expect(res4.translatedText, equals('पानी'));
    });

    test('Translates word by word tokenization for compound input', () {
      final res = OfflineTranslator.translate(
        text: 'मैं घर जा रहा हूँ',
        fromLang: 'hi',
        toLang: 'sat',
      );

      expect(res.translatedText, contains('ᱚᱲᱟᱜ'));
    });
  });

  group('Ol Chiki Converter Tests', () {
    test('Detects Ol Chiki Unicode script', () {
      expect(OlChikiConverter.isOlChiki('ᱡᱚᱦᱟᱨ'), isTrue);
      expect(OlChikiConverter.isOlChiki('नमस्ते'), isFalse);
      expect(OlChikiConverter.isOlChiki('Hello'), isFalse);
    });

    test('Converts Latin Santali to Ol Chiki', () {
      final converted = OlChikiConverter.toOlChiki('johar');
      expect(converted, equals('ᱡᱚᱦᱟᱨ'));
    });

    test('Converts Ol Chiki to Latin phonetic', () {
      final phonetic = OlChikiConverter.olChikiToLatinPhonetic('ᱡᱚᱦᱟᱨ');
      expect(phonetic.toLowerCase(), equals('johar'));
    });
  });

  group('Santali Dictionary Verification', () {
    test('Contains essential categories', () {
      final categories = SantaliDictionary.phrases.map((p) => p.category).toSet();
      expect(categories, contains('Greetings'));
      expect(categories, contains('Emergency'));
      expect(categories, contains('Food & Water'));
      expect(categories, contains('Travel'));
      expect(categories, contains('Shopping'));
      expect(categories, contains('Family'));
    });

    test('Has complete Ol Chiki alphabet list', () {
      expect(SantaliDictionary.olChikiAlphabet.length, greaterThanOrEqualTo(30));
    });
  });
}
