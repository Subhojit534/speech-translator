/// Ol Chiki script utilities and transliterators for Santali language.
class OlChikiConverter {
  // Ol Chiki Unicode range: U+1C50 - U+1C7F
  static const Map<String, String> latinToOlChiki = {
    // Digits
    '0': '᱐',
    '1': '᱑',
    '2': '᱒',
    '3': '᱓',
    '4': '᱔',
    '5': '᱕',
    '6': '᱖',
    '7': '᱗',
    '8': '᱘',
    '9': '᱙',
    
    // Multi-character sequences first
    'ch': 'ᱪ',
    'ng': 'ᱝ',
    'ny': 'ᱧ',
    'ñ': 'ᱧ',
    'aa': 'ᱟ',
    'ee': 'ᱮ',
    'oo': 'ᱳ',
    'th': 'ᱛᱷ',
    'gh': 'ᱜᱷ',
    'jh': 'ᱡᱷ',
    'dh': 'ᱫᱷ',
    'bh': 'ᱵᱷ',
    'kh': 'ᱠᱷ',
    'ph': 'ᱯᱷ',
    'rh': 'ᱲᱷ',
    
    // Single characters
    'a': 'ᱟ',
    'b': 'ᱵ',
    'c': 'ᱪ',
    'd': 'ᱫ',
    'e': 'ᱮ',
    'g': 'ᱜ',
    'h': 'ᱦ',
    'i': 'ᱤ',
    'j': 'ᱡ',
    'k': 'ᱠ',
    'l': 'ᱞ',
    'm': 'ᱢ',
    'n': 'ᱱ',
    'o': 'ᱚ',
    'p': 'ᱯ',
    'r': 'ᱨ',
    's': 'ᱥ',
    't': 'ᱛ',
    'u': 'ᱩ',
    'v': 'ᱶ',
    'w': 'ᱣ',
    'y': 'ᱭ',
    'z': 'ᱡ',
    
    // Punctuations
    '.': '᱾',
    '|': '᱾',
    '||': '᱿',
  };

  static const Map<String, String> olChikiToLatin = {
    '᱐': '0',
    '᱑': '1',
    '᱒': '2',
    '᱓': '3',
    '᱔': '4',
    '᱕': '5',
    '᱖': '6',
    '᱗': '7',
    '᱘': '8',
    '᱙': '9',
    
    'ᱚ': 'o',
    'ᱛ': 't',
    'ᱜ': 'g',
    'ᱝ': 'ng',
    'ᱞ': 'l',
    'ᱟ': 'a',
    'ᱠ': 'k',
    'ᱡ': 'j',
    'ᱢ': 'm',
    'ᱣ': 'w',
    'ᱤ': 'i',
    'ᱥ': 's',
    'ᱦ': 'h',
    'ᱧ': 'ny',
    'ᱨ': 'r',
    'ᱩ': 'u',
    'ᱪ': 'c',
    'ᱫ': 'd',
    'ᱬ': 'n',
    'ᱭ': 'y',
    'ᱮ': 'e',
    'ᱯ': 'p',
    'ᱰ': 'd',
    'ᱱ': 'n',
    'ᱲ': 'r',
    'ᱳ': 'o',
    'ᱴ': 't',
    'ᱵ': 'b',
    'ᱶ': 'w',
    'ᱷ': 'h',
    
    'ᱸ': 'n', // Mu Ttudag (nasal)
    'ᱹ': '',  // Gaahlaa Ttudag (low vowel)
    'ᱺ': 'n', // Mu-Gaahlaa Ttudag
    'ᱻ': "'", // Ahath (glottal stop)
    'ᱼ': '-', // Pharka (pause)
    
    '᱾': '.',
    '᱿': '.',
  };

  static const Map<String, String> devanagariToOlChiki = {
    '०': '᱐',
    '१': '᱑',
    '२': '᱒',
    '३': '᱓',
    '४': '᱔',
    '५': '᱕',
    '६': '᱖',
    '७': '᱗',
    '८': '᱘',
    '९': '᱙',

    'अ': 'ᱚ',
    'आ': 'ᱟ',
    'इ': 'ᱤ',
    'ई': 'ᱤ',
    'उ': 'ᱩ',
    'ऊ': 'ᱩ',
    'ए': 'ᱮ',
    'ऐ': 'ᱮ',
    'ओ': 'ᱳ',
    'औ': 'ᱳ',
    
    'ा': 'ᱟ',
    'ि': 'ᱤ',
    'ी': 'ᱤ',
    'ु': 'ᱩ',
    'ू': 'ᱩ',
    'े': 'ᱮ',
    'ै': 'ᱮ',
    'ो': 'ᱳ',
    'ौ': 'ᱳ',
    'ं': 'ᱸ',
    '्': '',

    'क': 'ᱠ',
    'ख': 'ᱠᱷ',
    'ग': 'ᱜ',
    'घ': 'ᱜᱷ',
    'ङ': 'ᱝ',
    'च': 'ᱪ',
    'छ': 'ᱪᱷ',
    'ज': 'ᱡ',
    'झ': 'ᱡᱷ',
    'ञ': 'ᱧ',
    'ट': 'ᱴ',
    'ठ': 'ᱴᱷ',
    'ड': 'ᱰ',
    'ढ': 'ᱰᱷ',
    'ण': 'ᱬ',
    'त': 'ᱛ',
    'थ': 'ᱛᱷ',
    'द': 'ᱫ',
    'ध': 'ᱫᱷ',
    'न': 'ᱱ',
    'प': 'ᱯ',
    'फ': 'ᱯᱷ',
    'ब': 'ᱵ',
    'भ': 'ᱵᱷ',
    'म': 'ᱢ',
    'य': 'ᱭ',
    'र': 'ᱨ',
    'ल': 'ᱞ',
    'व': 'ᱣ',
    'श': 'ᱥ',
    'ष': 'ᱥ',
    'स': 'ᱥ',
    'ह': 'ᱦ',
    'ड़': 'ᱲ',
    'ढ़': 'ᱲᱷ',
    '।': '᱾',
    '॥': '᱿',
  };

  /// Check if text contains Ol Chiki characters
  static bool isOlChiki(String text) {
    for (int rune in text.runes) {
      if (rune >= 0x1C50 && rune <= 0x1C7F) {
        return true;
      }
    }
    return false;
  }

  /// Transliterate Latin Santali to Ol Chiki
  static String toOlChiki(String text) {
    if (text.isEmpty) return text;
    String lower = text.toLowerCase();
    String result = '';
    int i = 0;
    while (i < lower.length) {
      // Check 2-char sequences
      if (i + 1 < lower.length) {
        String twoChars = lower.substring(i, i + 2);
        if (latinToOlChiki.containsKey(twoChars)) {
          result += latinToOlChiki[twoChars]!;
          i += 2;
          continue;
        }
      }
      String oneChar = lower[i];
      if (latinToOlChiki.containsKey(oneChar)) {
        result += latinToOlChiki[oneChar]!;
      } else {
        result += lower[i];
      }
      i++;
    }
    return result;
  }

  /// Transliterate Ol Chiki to Latin Phonetics
  static String olChikiToLatinPhonetic(String text) {
    if (text.isEmpty) return text;
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      if (olChikiToLatin.containsKey(char)) {
        sb.write(olChikiToLatin[char]);
      } else {
        sb.write(char);
      }
    }
    return sb.toString();
  }

  /// Transliterate Devanagari to Ol Chiki
  static String devanagariToOlChikiScript(String text) {
    if (text.isEmpty) return text;
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      if (devanagariToOlChiki.containsKey(char)) {
        sb.write(devanagariToOlChiki[char]);
      } else {
        sb.write(char);
      }
    }
    return sb.toString();
  }
}
