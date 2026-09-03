import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_translator/service/offline/offline_translator.dart';
import 'package:speech_translator/service/offline/santali_dictionary.dart';
import 'package:speech_translator/hybrid_translation_service.dart';
import 'package:speech_translator/service/storage/storage_service.dart';
import 'package:speech_translator/service/voice/voice_service.dart';
import 'package:speech_translator/ui/widgets/ol_chiki_keyboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final HybridTranslationService _hybridService = HybridTranslationService();
  final VoiceService _voiceService = VoiceService();
  final StorageService _storageService = StorageService();

  String _sourceLang = 'hi'; // 'hi' or 'sat'
  String _targetLang = 'sat';
  bool _isOffline = true;
  bool _showKeyboard = false;
  bool _isLoading = false;
  bool _isFavorite = false;

  TranslationResult? _currentResult;
  Timer? _debounceTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initSettings();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _inputController.addListener(_onTextChanged);
  }

  Future<void> _initSettings() async {
    final offline = await _storageService.getOfflineMode();
    if (mounted) {
      setState(() {
        _isOffline = offline;
        _hybridService.isOfflineMode = offline;
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _inputController.removeListener(_onTextChanged);
    _inputController.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _currentResult = null;
        _isFavorite = false;
        _isLoading = false;
      });
    } else {
      _debounceTimer = Timer(const Duration(milliseconds: 350), () {
        if (mounted && _inputController.text.trim().isNotEmpty) {
          _performTranslation(_inputController.text.trim());
        }
      });
    }
  }

  Future<void> _performTranslation(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;

    setState(() => _isLoading = true);
    final result = await _hybridService.translate(
      text: clean,
      sourceLang: _sourceLang,
      targetLang: _targetLang,
    );

    if (mounted) {
      setState(() {
        _currentResult = result;
        _isLoading = false;
      });

      // Save to history only for full meaningful inputs
      if (result.translatedText.isNotEmpty && clean.length >= 2) {
        final historyItem = HistoryItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sourceText: result.sourceText,
          translatedText: result.translatedText,
          sourceLang: result.sourceLang,
          targetLang: result.targetLang,
          phonetic: result.phonetic,
          timestamp: DateTime.now(),
        );
        await _storageService.addHistoryItem(historyItem);
      }
    }
  }

  void _swapLanguages() {
    HapticFeedback.selectionClick();
    _debounceTimer?.cancel();
    _inputController.removeListener(_onTextChanged);

    final prevTranslation = _currentResult?.translatedText;

    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;

      if (prevTranslation != null && prevTranslation.isNotEmpty) {
        _inputController.text = prevTranslation;
      } else {
        _inputController.clear();
      }
      _showKeyboard = _sourceLang == 'sat';
      _currentResult = null;
    });

    _inputController.addListener(_onTextChanged);

    if (_inputController.text.trim().isNotEmpty) {
      _performTranslation(_inputController.text.trim());
    }
  }

  void _toggleVoiceInput() async {
    HapticFeedback.heavyImpact();
    if (_voiceService.isListening) {
      await _voiceService.stopListening();
      if (_inputController.text.trim().isNotEmpty) {
        _performTranslation(_inputController.text.trim());
      }
      setState(() {});
    } else {
      setState(() {});
      await _voiceService.startListening(
        languageCode: 'hi_IN',
        onResult: (recognized, isFinal) {
          if (!mounted) return;
          setState(() {
            _inputController.text = recognized;
            _inputController.selection = TextSelection.fromPosition(
              TextPosition(offset: recognized.length),
            );
          });
          if (isFinal && recognized.trim().isNotEmpty) {
            _performTranslation(recognized.trim());
          }
        },
        onError: (err) {
          setState(() {});
          if (mounted) {
            _showOfflineVoiceSheet();
          }
        },
      );
      setState(() {});
    }
  }

  void _showOfflineVoiceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2638) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.offline_bolt, color: Color(0xFF2D6A4F)),
                    SizedBox(width: 8),
                    Text(
                      "Offline Speech & Quick Phrases",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Tap any phrase below for instant offline translation and spoken audio, or type in the text box.",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: SantaliDictionary.phrases.take(12).map((phrase) {
                    final label = _sourceLang == 'hi' ? phrase.hindi : phrase.santaliOlChiki;
                    return ActionChip(
                      label: Text(label, style: const TextStyle(fontSize: 13)),
                      avatar: const Icon(Icons.volume_up, size: 14),
                      onPressed: () {
                        Navigator.pop(context);
                        _inputController.text = label;
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _speakText(String text, String lang, {String? phonetic}) {
    HapticFeedback.lightImpact();
    _voiceService.speak(
      text: text,
      langCode: lang,
      phoneticFallback: phonetic,
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Copied to clipboard"),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleFavorite() {
    if (_currentResult == null) return;
    setState(() {
      _isFavorite = !_isFavorite;
    });
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? "Saved to Favorites" : "Removed from Favorites"),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Santali Translator"),
        actions: [
          // Offline mode switch badge
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              avatar: Icon(
                _isOffline ? Icons.cloud_off : Icons.cloud_done,
                size: 16,
                color: _isOffline ? const Color(0xFFC84B31) : const Color(0xFF2D6A4F),
              ),
              label: Text(
                _isOffline ? "Offline" : "Online",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _isOffline ? const Color(0xFFC84B31) : const Color(0xFF2D6A4F),
                ),
              ),
              selected: _isOffline,
              onSelected: (val) async {
                setState(() {
                  _isOffline = val;
                  _hybridService.isOfflineMode = val;
                });
                await _storageService.setOfflineMode(val);
                if (_inputController.text.isNotEmpty) {
                  _performTranslation(_inputController.text);
                }
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Language Switcher Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2638) : Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      _sourceLang == 'hi' ? "हिंदी (Hindi)" : "ᱥᱟᱱᱛᱟᱲᱤ (Santali)",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.swap_horiz_rounded, color: primary, size: 22),
                  ),
                  onPressed: _swapLanguages,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      _targetLang == 'sat' ? "ᱥᱟᱱᱛᱟᱲᱤ (Santali)" : "हिंदी (Hindi)",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable input / output cards
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Source Input Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _sourceLang == 'hi' ? "Enter Hindi Text" : "Santali (Ol Chiki)",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Row(
                                children: [
                                  if (_sourceLang == 'sat')
                                    IconButton(
                                      tooltip: "Virtual Ol Chiki Keyboard",
                                      icon: Icon(
                                        _showKeyboard ? Icons.keyboard_hide : Icons.keyboard,
                                        size: 20,
                                        color: _showKeyboard ? primary : Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() => _showKeyboard = !_showKeyboard);
                                      },
                                    ),
                                  if (_inputController.text.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed: () {
                                        _inputController.clear();
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _inputController,
                            focusNode: _focusNode,
                            maxLines: 4,
                            minLines: 2,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: _sourceLang == 'sat' ? null : null,
                            ),
                            decoration: InputDecoration(
                              hintText: _sourceLang == 'hi'
                                  ? "यहाँ लिखें या बोलें (उदा. आप कैसे हैं?)..."
                                  : "ᱱᱚᱰᱮ ᱚᱞ ᱢᱮ (e.g. ᱪᱮᱫ ᱞᱮᱠᱟ ᱢᱮᱱᱟᱜ ᱵᱤᱱᱟ)...",
                              border: InputBorder.none,
                            ),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    tooltip: "Paste",
                                    icon: const Icon(Icons.paste, size: 20),
                                    onPressed: () async {
                                      final data = await Clipboard.getData('text/plain');
                                      if (data?.text != null) {
                                        _inputController.text = data!.text!;
                                      }
                                    },
                                  ),
                                  if (_inputController.text.isNotEmpty)
                                    IconButton(
                                      tooltip: "Listen",
                                      icon: const Icon(Icons.volume_up_outlined, size: 20),
                                      onPressed: () {
                                        _speakText(_inputController.text, _sourceLang);
                                      },
                                    ),
                                ],
                              ),
                              // Microphone Button
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  final isListening = _voiceService.isListening;
                                  return Transform.scale(
                                    scale: isListening ? _pulseAnimation.value : 1.0,
                                    child: FloatingActionButton.small(
                                      backgroundColor: isListening ? Colors.red : primary,
                                      foregroundColor: Colors.white,
                                      elevation: isListening ? 6 : 2,
                                      onPressed: _toggleVoiceInput,
                                      child: Icon(
                                        isListening ? Icons.mic : Icons.mic_none,
                                        size: 22,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Translation Output Card
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    )
                  else if (_currentResult != null && _currentResult!.translatedText.isNotEmpty)
                    Card(
                      color: isDark ? const Color(0xFF1E2638) : const Color(0xFFFFF9F5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: primary.withValues(alpha: 0.3), width: 1.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _targetLang == 'sat' ? "Santali (ᱚᱞ ᱪᱤᱠᱤ)" : "Hindi (हिंदी)",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (_currentResult!.isExactMatch)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2D6A4F).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          "Exact",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2D6A4F),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(
                                    _isFavorite ? Icons.star : Icons.star_border,
                                    color: _isFavorite ? Colors.amber : Colors.grey,
                                  ),
                                  onPressed: _toggleFavorite,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Primary translation output (Ol Chiki if target is Santali)
                            SelectableText(
                              _currentResult!.translatedText,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1F2937),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Phonetic transliteration subtitle
                            if (_currentResult!.phonetic.isNotEmpty &&
                                _currentResult!.phonetic != _currentResult!.translatedText)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Pronunciation: ${_currentResult!.phonetic}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            // Devanagari transliteration
                            if (_targetLang == 'sat' &&
                                _currentResult!.devanagari.isNotEmpty &&
                                _currentResult!.devanagari != _currentResult!.translatedText)
                              Text(
                                "संथाली (देवनागरी): ${_currentResult!.devanagari}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            const Divider(height: 24),
                            // Action toolbar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      tooltip: "Speak Audio",
                                      icon: Icon(Icons.volume_up, color: primary, size: 24),
                                      onPressed: () {
                                        _speakText(
                                          _currentResult!.translatedText,
                                          _targetLang,
                                          phonetic: _currentResult!.phonetic,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      tooltip: "Copy",
                                      icon: const Icon(Icons.copy, size: 20),
                                      onPressed: () {
                                        _copyToClipboard(_currentResult!.translatedText);
                                      },
                                    ),
                                    IconButton(
                                      tooltip: "Full Screen",
                                      icon: const Icon(Icons.fullscreen, size: 22),
                                      onPressed: () {
                                        _showFullscreenDialog(_currentResult!);
                                      },
                                    ),
                                  ],
                                ),
                                Text(
                                  _isOffline ? "Offline Engine" : "AI4Bharat Online",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Quick phrases preview
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Quick Common Phrases",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: SantaliDictionary.phrases.take(8).map((phrase) {
                      return ActionChip(
                        label: Text(
                          _sourceLang == 'hi' ? phrase.hindi : phrase.santaliOlChiki,
                          style: const TextStyle(fontSize: 13),
                        ),
                        avatar: const Icon(Icons.translate, size: 14),
                        onPressed: () {
                          _inputController.text = _sourceLang == 'hi' ? phrase.hindi : phrase.santaliOlChiki;
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Virtual Ol Chiki Keyboard
          if (_showKeyboard)
            OlChikiKeyboard(
              onKeyTap: (char) {
                final text = _inputController.text;
                final selection = _inputController.selection;
                final newText = text.replaceRange(
                  selection.start < 0 ? text.length : selection.start,
                  selection.end < 0 ? text.length : selection.end,
                  char,
                );
                final newCursorPos = (selection.start < 0 ? text.length : selection.start) + char.length;
                _inputController.value = TextEditingValue(
                  text: newText,
                  selection: TextSelection.collapsed(offset: newCursorPos),
                );
              },
              onSpace: () {
                final text = _inputController.text;
                final selection = _inputController.selection;
                final newText = text.replaceRange(
                  selection.start < 0 ? text.length : selection.start,
                  selection.end < 0 ? text.length : selection.end,
                  ' ',
                );
                _inputController.value = TextEditingValue(
                  text: newText,
                  selection: TextSelection.collapsed(offset: (selection.start < 0 ? text.length : selection.start) + 1),
                );
              },
              onBackspace: () {
                final text = _inputController.text;
                final selection = _inputController.selection;
                if (text.isEmpty) return;
                if (selection.start > 0) {
                  final newText = text.replaceRange(selection.start - 1, selection.end, '');
                  _inputController.value = TextEditingValue(
                    text: newText,
                    selection: TextSelection.collapsed(offset: selection.start - 1),
                  );
                } else if (selection.start < 0 && text.isNotEmpty) {
                  _inputController.text = text.substring(0, text.length - 1);
                }
              },
              onClear: () {
                _inputController.clear();
              },
              onClose: () {
                setState(() => _showKeyboard = false);
              },
            ),
        ],
      ),
    );
  }

  void _showFullscreenDialog(TranslationResult result) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(ctx),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: () {
                  _speakText(result.translatedText, result.targetLang, phonetic: result.phonetic);
                },
              ),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    result.sourceText,
                    style: const TextStyle(fontSize: 20, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SelectableText(
                    result.translatedText,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (result.phonetic.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      result.phonetic,
                      style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: Colors.blueGrey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
