import 'package:speech_translator/service/offline/ol_chiki_converter.dart';
import 'package:speech_translator/service/offline/santali_dictionary.dart';

class TranslationResult {
  final String sourceText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final String phonetic;
  final String olChiki;
  final String devanagari;
  final double confidence;
  final bool isExactMatch;

  const TranslationResult({
    required this.sourceText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    required this.phonetic,
    required this.olChiki,
    required this.devanagari,
    this.confidence = 1.0,
    this.isExactMatch = false,
  });
}

class OfflineTranslator {
  static final Map<String, SantaliPhrase> _hindiPhraseMap = {};
  static final Map<String, SantaliPhrase> _santaliPhraseMap = {};
  static final Map<String, SantaliWord> _hindiWordMap = {};
  static final Map<String, SantaliWord> _santaliWordMap = {};

  static bool _initialized = false;

  static void _ensureInitialized() {
    if (_initialized) return;

    for (var phrase in SantaliDictionary.phrases) {
      _hindiPhraseMap.putIfAbsent(_normalize(phrase.hindi), () => phrase);
      _santaliPhraseMap.putIfAbsent(_normalize(phrase.santaliOlChiki), () => phrase);
      _santaliPhraseMap.putIfAbsent(_normalize(phrase.santaliLatin), () => phrase);
      _santaliPhraseMap.putIfAbsent(_normalize(phrase.santaliDevanagari), () => phrase);
    }

    for (var word in SantaliDictionary.vocabulary) {
      _hindiWordMap.putIfAbsent(_normalize(word.hindi), () => word);
      _santaliWordMap.putIfAbsent(_normalize(word.santaliOlChiki), () => word);
      _santaliWordMap.putIfAbsent(_normalize(word.santaliLatin), () => word);
      _santaliWordMap.putIfAbsent(_normalize(word.santaliDevanagari), () => word);
    }

    _initialized = true;
  }

  static const Map<String, String> _hinglishToHindi = {
    'namaste': 'नमस्ते',
    'namaskar': 'नमस्कार',
    'pranam': 'प्रणाम',
    'shubhratri': 'शुभ रात्रि',
    'shubh prabhat': 'सुप्रभात',
    'aap kaise hain': 'आप कैसे हैं?',
    'aap kaise ho': 'आप कैसे हैं?',
    'tum kaise ho': 'तुम कैसे हो?',
    'kya haal hai': 'क्या हाल है?',
    'kya hal hai': 'क्या हाल है?',
    'aapka naam kya hai': 'आपका नाम क्या है?',
    'tumhara naam kya hai': 'तुम्हारा नाम क्या है?',
    'mera naam': 'मेरा नाम',
    'aapse milkar khushi hui': 'आपसे मिलकर खुशी हुई',
    'phir milenge': 'फिर मिलेंगे',
    'alvida': 'अलविदा',
    'maaf kijiye': 'माफ़ कीजिए',
    'haan': 'हाँ',
    'han': 'हाँ',
    'nahin': 'नहीं',
    'nahi': 'नहीं',
    'achha': 'अच्छा',
    'achha hai': 'अच्छा',
    'bahut achha': 'बहुत अच्छा',
    'theek hai': 'ठीक है',
    'meri madad karo': 'मेरी मदद करो',
    'madad kijiye': 'मदद कीजिए',
    'madad chahiye': 'मदद चाहिए',
    'mujhe dawai chahiye': 'मुझे दवा चाहिए',
    'mujhe doctor ke paas jana hai': 'मुझे डॉक्टर के पास जाना है',
    'mujhe dard ho raha hai': 'मुझे दर्द हो रहा है',
    'mujhe bukhar hai': 'मुझे बुखार है',
    'ambulance bulaiye': 'एम्बुलेंस बुलाइए',
    'kripya madad karein': 'कृपया मेरी मदद करें',
    'police ko bulao': 'पुलिस को बुलाओ',
    'mujhe bhookh lagi hai': 'मुझे भूख लगी है',
    'mujhe pyaas lagi hai': 'मुझे प्यास लगी है',
    'mujhe khana chahiye': 'मुझे खाना चाहिए',
    'mujhe pani chahiye': 'मुझे पानी चाहिए',
    'pani chahiye': 'मुझे पानी चाहिए',
    'yeh kitne ka hai': 'यह कितने का है?',
    'iska daam kya hai': 'इसका दाम क्या है?',
    'kahan ja rahe ho': 'कहाँ जा रहे हो?',
    'ghar kahan hai': 'घर कहाँ है?',
    'station kahan hai': 'स्टेशन कहाँ है?',
    'kitna dur hai': 'कितना दूर है?',
    'aap kahan se hain': 'आप कहाँ से हैं?',
    'chalo': 'चलो',
    'ruko': 'रुको',
    'aao': 'आओ',
    'jao': 'जाओ',
    'khao': 'खाओ',
    'piyo': 'पियो',
    'bolo': 'बोलो',
    'suno': 'सुनो',
    'dekho': 'देखो',
    'pani': 'पानी',
    'paani': 'पानी',
    'khana': 'खाना',
    'dawa': 'दवा',
    'dawai': 'दवा',
    'doctor': 'डॉक्टर',
    'ghar': 'घर',
    'bhai': 'भाई',
    'behen': 'बहन',
    'dost': 'दोस्त',
    'yeh': 'यह',
    'ye': 'यह',
    'woh': 'वह',
    'wo': 'वह',
    'mein': 'में',
    'me': 'में',
    'se': 'से',
    'par': 'पर',
    'dikkat': 'दिक्कत',
    'samashya': 'समस्या',
    'pareshani': 'परेशानी',
    'kyon': 'क्यों',
    'kyu': 'क्यों',
    'kyun': 'क्यों',
    'kaise': 'कैसे',
    'kab': 'कब',
    'kahan': 'कहाँ',
    'kaha': 'कहाँ',
    'kya': 'क्या',
    'online': 'ऑनलाइन',
    'offline': 'ऑफलाइन',
    'internet': 'इंटरनेट',
    'network': 'नेटवर्क',
    'mobile': 'मोबाइल',
    'phone': 'फ़ोन',
    'aawaz': 'आवाज',
    'awaz': 'आवाज',
    'bhasha': 'भाषा',
    'kaam': 'काम',
    'kam': 'काम',
    'baat': 'बात',
  };

  static String _normalize(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'''[?।,!।.'"-]'''), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Translate between Hindi and Santali offline
  static TranslationResult translate({
    required String text,
    required String fromLang,
    required String toLang,
  }) {
    _ensureInitialized();
    final cleanInput = text.trim();
    if (cleanInput.isEmpty) {
      return TranslationResult(
        sourceText: text,
        translatedText: '',
        sourceLang: fromLang,
        targetLang: toLang,
        phonetic: '',
        olChiki: '',
        devanagari: '',
      );
    }

    final normalized = _normalize(cleanInput);

    // 1. Exact phrase match
    if (fromLang == 'hi') {
      SantaliPhrase? phrase = _hindiPhraseMap[normalized];
      if (phrase == null && _hinglishToHindi.containsKey(normalized)) {
        final hiText = _hinglishToHindi[normalized]!;
        phrase = _hindiPhraseMap[_normalize(hiText)];
      }

      if (phrase != null) {
        return TranslationResult(
          sourceText: cleanInput,
          translatedText: phrase.santaliOlChiki,
          sourceLang: fromLang,
          targetLang: toLang,
          phonetic: phrase.santaliLatin,
          olChiki: phrase.santaliOlChiki,
          devanagari: phrase.santaliDevanagari,
          confidence: 1.0,
          isExactMatch: true,
        );
      }
    } else {
      // Santali to Hindi: check raw, Ol Chiki, Devanagari, and Latin phonetic representations
      SantaliPhrase? phrase = _santaliPhraseMap[normalized];
      phrase ??= _santaliPhraseMap[_normalize(OlChikiConverter.toOlChiki(cleanInput))];
      phrase ??= _santaliPhraseMap[_normalize(OlChikiConverter.devanagariToOlChikiScript(cleanInput))];
      phrase ??= _santaliPhraseMap[_normalize(OlChikiConverter.olChikiToLatinPhonetic(cleanInput))];

      if (phrase != null) {
        return TranslationResult(
          sourceText: cleanInput,
          translatedText: phrase.hindi,
          sourceLang: fromLang,
          targetLang: toLang,
          phonetic: phrase.santaliLatin,
          olChiki: phrase.santaliOlChiki,
          devanagari: phrase.hindi,
          confidence: 1.0,
          isExactMatch: true,
        );
      }
    }

    // 2. Tokenized multi-word and word-by-word translation
    final words = cleanInput.split(RegExp(r'\s+'));
    List<String> outputTokens = [];
    List<String> phoneticTokens = [];
    List<String> devanagariTokens = [];
    int matchCount = 0;

    int i = 0;
    while (i < words.length) {
      bool matchedSpan = false;

      // Try 3-gram, 2-gram
      for (int span = 3; span >= 2; span--) {
        if (i + span <= words.length) {
          final chunk = words.sublist(i, i + span).join(' ');
          final normChunk = _normalize(chunk);

          if (fromLang == 'hi') {
            String targetChunk = normChunk;
            if (_hinglishToHindi.containsKey(normChunk)) {
              targetChunk = _normalize(_hinglishToHindi[normChunk]!);
            }

            if (_hindiPhraseMap.containsKey(targetChunk)) {
              final p = _hindiPhraseMap[targetChunk]!;
              outputTokens.add(p.santaliOlChiki);
              phoneticTokens.add(p.santaliLatin);
              devanagariTokens.add(p.santaliDevanagari);
              i += span;
              matchCount += span;
              matchedSpan = true;
              break;
            }
            if (_hindiWordMap.containsKey(targetChunk)) {
              final w = _hindiWordMap[targetChunk]!;
              outputTokens.add(w.santaliOlChiki);
              phoneticTokens.add(w.santaliLatin);
              devanagariTokens.add(w.santaliDevanagari);
              i += span;
              matchCount += span;
              matchedSpan = true;
              break;
            }
          } else {
            SantaliPhrase? p = _santaliPhraseMap[normChunk];
            p ??= _santaliPhraseMap[_normalize(OlChikiConverter.toOlChiki(chunk))];
            p ??= _santaliPhraseMap[_normalize(OlChikiConverter.devanagariToOlChikiScript(chunk))];
            p ??= _santaliPhraseMap[_normalize(OlChikiConverter.olChikiToLatinPhonetic(chunk))];

            if (p != null) {
              outputTokens.add(p.hindi);
              phoneticTokens.add(p.santaliLatin);
              devanagariTokens.add(p.hindi);
              i += span;
              matchCount += span;
              matchedSpan = true;
              break;
            }

            SantaliWord? w = _santaliWordMap[normChunk];
            w ??= _santaliWordMap[_normalize(OlChikiConverter.toOlChiki(chunk))];
            w ??= _santaliWordMap[_normalize(OlChikiConverter.devanagariToOlChikiScript(chunk))];
            w ??= _santaliWordMap[_normalize(OlChikiConverter.olChikiToLatinPhonetic(chunk))];

            if (w != null) {
              outputTokens.add(w.hindi);
              phoneticTokens.add(w.santaliLatin);
              devanagariTokens.add(w.hindi);
              i += span;
              matchCount += span;
              matchedSpan = true;
              break;
            }
          }
        }
      }

      if (matchedSpan) continue;

      // Single word lookup
      final currentWord = words[i];
      final normWord = _normalize(currentWord);

      if (fromLang == 'hi') {
        String targetWord = normWord;
        if (_hinglishToHindi.containsKey(normWord)) {
          targetWord = _normalize(_hinglishToHindi[normWord]!);
        }

        if (_hindiWordMap.containsKey(targetWord)) {
          final w = _hindiWordMap[targetWord]!;
          outputTokens.add(w.santaliOlChiki);
          phoneticTokens.add(w.santaliLatin);
          devanagariTokens.add(w.santaliDevanagari);
          matchCount++;
        } else {
          // Check common suffix removal
          String root = targetWord;
          if (root.endsWith('ों') || root.endsWith('ें')) {
            root = root.substring(0, root.length - 2);
          } else if (root.endsWith('ा') || root.endsWith('ी') || root.endsWith('े')) {
            root = root.substring(0, root.length - 1);
          }

          if (_hindiWordMap.containsKey(root)) {
            final w = _hindiWordMap[root]!;
            outputTokens.add(w.santaliOlChiki);
            phoneticTokens.add(w.santaliLatin);
            devanagariTokens.add(w.santaliDevanagari);
            matchCount++;
          } else {
            // Transliterate directly to Ol Chiki for names/untranslated tokens
            final translit = OlChikiConverter.isOlChiki(currentWord)
                ? currentWord
                : (RegExp(r'[\u0900-\u097F]').hasMatch(currentWord)
                    ? OlChikiConverter.devanagariToOlChikiScript(currentWord)
                    : OlChikiConverter.toOlChiki(currentWord));
            outputTokens.add(translit);
            phoneticTokens.add(currentWord);
            devanagariTokens.add(currentWord);
          }
        }
      } else {
        // Santali to Hindi: multi-representation & suffix matching
        SantaliWord? matchedWord = _santaliWordMap[normWord];
        matchedWord ??= _santaliWordMap[_normalize(OlChikiConverter.toOlChiki(currentWord))];
        matchedWord ??= _santaliWordMap[_normalize(OlChikiConverter.devanagariToOlChikiScript(currentWord))];
        matchedWord ??= _santaliWordMap[_normalize(OlChikiConverter.olChikiToLatinPhonetic(currentWord))];

        // Suffix stripping for Santali
        if (matchedWord == null) {
          final suffixes = [
            'ᱟᱜ', 'ᱛᱮ', 'ᱨᱮ', 'ᱠᱷᱚᱱ', 'ᱠᱟᱱᱟ', 'ᱠᱮᱫᱟ', 'ᱢᱮ', 'ᱵᱤᱱ', 'ᱟ',
            'ag', 'te', 're', 'khon', 'kana', 'keda', 'me', 'bin', 'a',
            'आक', 'ते', 'रे', 'खोन', 'काना', 'केदा', 'मे', 'बिन'
          ];
          for (var suf in suffixes) {
            if (normWord.endsWith(suf) && normWord.length > suf.length + 1) {
              final stem = normWord.substring(0, normWord.length - suf.length);
              if (_santaliWordMap.containsKey(stem)) {
                matchedWord = _santaliWordMap[stem];
                break;
              }
              final stemOl = _normalize(OlChikiConverter.toOlChiki(stem));
              if (_santaliWordMap.containsKey(stemOl)) {
                matchedWord = _santaliWordMap[stemOl];
                break;
              }
            }
          }
        }

        if (matchedWord != null) {
          outputTokens.add(matchedWord.hindi);
          phoneticTokens.add(matchedWord.santaliLatin);
          devanagariTokens.add(matchedWord.hindi);
          matchCount++;
        } else {
          // If word was in Ol Chiki and unmapped, produce phonetic equivalent
          if (OlChikiConverter.isOlChiki(currentWord)) {
            outputTokens.add(OlChikiConverter.olChikiToLatinPhonetic(currentWord));
          } else {
            outputTokens.add(currentWord);
          }
          phoneticTokens.add(currentWord);
          devanagariTokens.add(currentWord);
        }
      }
      i++;
    }

    final resultTranslated = outputTokens.join(' ');
    final resultPhonetic = phoneticTokens.join(' ');
    final resultDevanagari = devanagariTokens.join(' ');
    final confidence = words.isNotEmpty ? (matchCount / words.length).clamp(0.4, 0.95) : 0.5;

    return TranslationResult(
      sourceText: cleanInput,
      translatedText: resultTranslated,
      sourceLang: fromLang,
      targetLang: toLang,
      phonetic: resultPhonetic,
      olChiki: fromLang == 'hi' ? resultTranslated : OlChikiConverter.toOlChiki(cleanInput),
      devanagari: fromLang == 'hi' ? resultDevanagari : resultTranslated,
      confidence: confidence,
      isExactMatch: matchCount == words.length,
    );
  }
}
