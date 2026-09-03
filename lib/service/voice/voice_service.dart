import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isSpeechInitialized = false;
  bool _isTtsInitialized = false;
  bool isListening = false;
  bool isSpeaking = false;

  List<LocaleName> _availableLocales = [];
  String? _systemLocaleId;

  Function(String error)? _currentOnErrorCallback;
  Function(String text, bool isFinal)? _lastOnResult;
  bool _isRetryingLocale = false;

  Future<bool> initializeSpeech() async {
    if (_isSpeechInitialized) return true;
    try {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        if (kDebugMode) print('Microphone permission not granted: $status');
      }

      _isSpeechInitialized = await _speechToText.initialize(
        onError: (val) async {
          isListening = false;
          if (kDebugMode) print('Speech onError: ${val.errorMsg}');

          // If language was unavailable or network error, attempt fallback to en_IN once!
          if ((val.errorMsg == 'error_language_unavailable' || val.errorMsg == 'error_network') && !_isRetryingLocale) {
            _isRetryingLocale = true;
            try {
              isListening = true;
              await _speechToText.listen(
                onResult: (result) {
                  _lastOnResult?.call(result.recognizedWords, result.finalResult);
                },
                listenOptions: SpeechListenOptions(
                  localeId: 'en_IN',
                  listenFor: const Duration(seconds: 30),
                  pauseFor: const Duration(seconds: 3),
                  partialResults: true,
                  cancelOnError: false,
                  listenMode: ListenMode.confirmation,
                ),
              );
              return;
            } catch (_) {}
          }

          _isRetryingLocale = false;
          String message = val.errorMsg;
          if (val.errorMsg == 'error_language_unavailable' || val.errorMsg == 'error_network') {
            message = "Offline voice requires speech recognition model. Please use keyboard or phrase chips.";
          }
          _currentOnErrorCallback?.call(message);
        },
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            isListening = false;
          }
          if (kDebugMode) print('Speech onStatus: $val');
        },
        debugLogging: false,
      );

      if (_isSpeechInitialized) {
        try {
          _availableLocales = await _speechToText.locales();
          final sys = await _speechToText.systemLocale();
          _systemLocaleId = sys?.localeId;
          if (kDebugMode) {
            print('Speech available locales: ${_availableLocales.map((e) => e.localeId).toList()}');
            print('System locale: $_systemLocaleId');
          }
        } catch (e) {
          if (kDebugMode) print('Failed to fetch speech locales: $e');
        }
      }

      return _isSpeechInitialized;
    } catch (e) {
      if (kDebugMode) print('Speech initialize failed: $e');
      return false;
    }
  }

  /// Resolve the best supported locale ID from device locales
  String? _resolveLocaleId(String preferredLang) {
    if (_availableLocales.isEmpty) return 'en_IN';

    final target = preferredLang.toLowerCase().replaceAll('-', '_');
    final prefix = target.split('_').first; // 'hi' or 'en'

    // 1. Exact match (e.g. 'hi_IN')
    for (var loc in _availableLocales) {
      final id = loc.localeId.toLowerCase().replaceAll('-', '_');
      if (id == target) return loc.localeId;
    }

    // 2. Language prefix match (e.g. starts with 'hi')
    for (var loc in _availableLocales) {
      final id = loc.localeId.toLowerCase().replaceAll('-', '_');
      if (id.startsWith(prefix)) return loc.localeId;
    }

    // 3. Indian English fallback (downloaded offline on Android in India)
    for (var loc in _availableLocales) {
      final id = loc.localeId.toLowerCase().replaceAll('-', '_');
      if (id == 'en_in') return loc.localeId;
    }

    // 4. Any English fallback
    for (var loc in _availableLocales) {
      final id = loc.localeId.toLowerCase().replaceAll('-', '_');
      if (id.startsWith('en')) return loc.localeId;
    }

    // 5. Fallback to system locale
    return _systemLocaleId ?? (_availableLocales.isNotEmpty ? _availableLocales.first.localeId : 'en_IN');
  }

  Future<void> initializeTts() async {
    if (_isTtsInitialized) return;
    try {
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setCompletionHandler(() {
        isSpeaking = false;
      });

      _flutterTts.setErrorHandler((msg) {
        isSpeaking = false;
        if (kDebugMode) print('TTS error: $msg');
      });

      _isTtsInitialized = true;
    } catch (e) {
      if (kDebugMode) print('TTS initialize failed: $e');
    }
  }

  Future<void> startListening({
    required Function(String text, bool isFinal) onResult,
    Function(String error)? onError,
    String languageCode = 'hi_IN',
  }) async {
    _currentOnErrorCallback = onError;
    _lastOnResult = onResult;
    _isRetryingLocale = false;
    final available = await initializeSpeech();
    if (!available) {
      onError?.call("Microphone or speech service not available on this device");
      return;
    }

    final resolvedLocale = _resolveLocaleId(languageCode);

    try {
      isListening = true;
      await _speechToText.listen(
        onResult: (result) {
          onResult(result.recognizedWords, result.finalResult);
        },
        listenOptions: SpeechListenOptions(
          localeId: resolvedLocale,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          cancelOnError: false,
          listenMode: ListenMode.confirmation,
        ),
      );
    } catch (e) {
      isListening = false;
      if (kDebugMode) print('startListening error: $e');

      // Retry with en_IN (which is pre-downloaded on Indian Android devices)
      try {
        isListening = true;
        await _speechToText.listen(
          onResult: (result) {
            onResult(result.recognizedWords, result.finalResult);
          },
          listenOptions: SpeechListenOptions(
            localeId: 'en_IN',
            listenFor: const Duration(seconds: 30),
            pauseFor: const Duration(seconds: 3),
            partialResults: true,
            cancelOnError: false,
            listenMode: ListenMode.confirmation,
          ),
        );
        return;
      } catch (_) {}

      onError?.call(e.toString());
    }
  }

  Future<void> stopListening() async {
    if (isListening) {
      isListening = false;
      await _speechToText.stop();
    }
  }

  Future<void> speak({
    required String text,
    required String langCode,
    String? phoneticFallback,
  }) async {
    await initializeTts();
    await stopSpeaking();

    if (text.trim().isEmpty) return;

    try {
      isSpeaking = true;
      if (langCode == 'hi') {
        await _flutterTts.setLanguage("hi-IN");
        await _flutterTts.speak(text);
      } else {
        // Santali: use Hindi/English phonetic voice for clear acoustic pronunciation
        await _flutterTts.setLanguage("hi-IN");
        final speakText = (phoneticFallback != null && phoneticFallback.isNotEmpty)
            ? phoneticFallback
            : text;
        await _flutterTts.speak(speakText);
      }
    } catch (e) {
      isSpeaking = false;
      if (kDebugMode) print('TTS speak error: $e');
    }
  }

  Future<void> stopSpeaking() async {
    if (isSpeaking) {
      isSpeaking = false;
      await _flutterTts.stop();
    }
  }
}
