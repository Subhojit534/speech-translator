import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:translation_api/src/offline/santali_dictionary.dart';
import 'package:translation_api/src/service/hybrid_translation_service.dart';
import 'package:translation_api/src/service/voice/voice_service.dart';

class ConversationMessage {
  final String text;
  final String translated;
  final String phonetic;
  final String speakerLang; // 'hi' or 'sat'
  final DateTime time;

  ConversationMessage({
    required this.text,
    required this.translated,
    required this.phonetic,
    required this.speakerLang,
    required this.time,
  });
}

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> with SingleTickerProviderStateMixin {
  final HybridTranslationService _hybridService = HybridTranslationService();
  final VoiceService _voiceService = VoiceService();
  final List<ConversationMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  String _liveTranscript = '';
  String _currentSpeaker = ''; // 'hi' or 'sat' or ''

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startListening(String speakerLang) async {
    HapticFeedback.heavyImpact();
    if (_voiceService.isListening) {
      await _voiceService.stopListening();
      final text = _liveTranscript.trim();
      setState(() {
        _currentSpeaker = '';
        _liveTranscript = '';
      });
      if (text.isNotEmpty) {
        _processCompletedSentence(text, speakerLang);
      }
      return;
    }

    setState(() {
      _currentSpeaker = speakerLang;
      _liveTranscript = '';
    });

    await _voiceService.startListening(
      languageCode: 'hi_IN',
      onError: (err) {
        setState(() {
          _currentSpeaker = '';
          _liveTranscript = '';
        });
        if (mounted) {
          _showOfflineAssistant(speakerLang);
        }
      },
      onResult: (recognized, isFinal) async {
        if (!mounted) return;

        if (!isFinal) {
          // While speaking, only update live transient transcript without adding cards or speaking audio
          setState(() {
            _liveTranscript = recognized;
          });
        } else {
          // When line is completed, process the full sentence once
          final text = recognized.trim();
          setState(() {
            _liveTranscript = '';
            _currentSpeaker = '';
          });
          if (text.isNotEmpty) {
            _processCompletedSentence(text, speakerLang);
          }
        }
      },
    );
  }

  void _showOfflineAssistant(String speakerLang) {
    final isHindi = speakerLang == 'hi';
    final TextEditingController customController = TextEditingController();

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
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                Row(
                  children: [
                    Icon(
                      Icons.offline_bolt,
                      color: isHindi ? const Color(0xFF1F4068) : const Color(0xFF2D6A4F),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isHindi ? "Offline Hindi Phrases & Input" : "Offline Santali Phrases & Input",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Select a common phrase or type below. It will translate and speak aloud offline.",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                // Custom input field
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: customController,
                        decoration: InputDecoration(
                          hintText: isHindi ? "Type Hindi (e.g. आप कैसे हैं?)..." : "Type Santali (e.g. ᱡᱚᱦᱟᱨ / Johar)...",
                          filled: true,
                          fillColor: isDark ? const Color(0xFF121826) : Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        final text = customController.text.trim();
                        if (text.isNotEmpty) {
                          Navigator.pop(context);
                          _processCompletedSentence(text, speakerLang);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Quick Tap & Speak Phrases:",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: SantaliDictionary.phrases.take(10).map((phrase) {
                    final label = isHindi ? phrase.hindi : phrase.santaliOlChiki;
                    return ActionChip(
                      label: Text(label, style: const TextStyle(fontSize: 13)),
                      avatar: const Icon(Icons.volume_up, size: 14),
                      onPressed: () {
                        Navigator.pop(context);
                        _processCompletedSentence(label, speakerLang);
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

  void _processCompletedSentence(String text, String speakerLang) async {
    final targetLang = speakerLang == 'hi' ? 'sat' : 'hi';
    final result = await _hybridService.translate(
      text: text,
      sourceLang: speakerLang,
      targetLang: targetLang,
    );

    if (mounted) {
      setState(() {
        _messages.add(ConversationMessage(
          text: text,
          translated: result.translatedText,
          phonetic: result.phonetic,
          speakerLang: speakerLang,
          time: DateTime.now(),
        ));
      });

      // Speak final translation exactly ONCE
      _voiceService.speak(
        text: result.translatedText,
        langCode: targetLang,
        phoneticFallback: result.phonetic,
      );

      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Face-to-Face Conversation"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() => _messages.clear());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Live status header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: primary.withValues(alpha: 0.08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _currentSpeaker.isEmpty ? Icons.record_voice_over : Icons.mic,
                  size: 18,
                  color: _currentSpeaker.isNotEmpty ? Colors.red : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentSpeaker.isEmpty
                        ? "Tap microphone below to start speaking"
                        : (_liveTranscript.isNotEmpty
                            ? "Listening (${_currentSpeaker == 'hi' ? 'Hindi' : 'Santali'}): \"$_liveTranscript\""
                            : "Listening to ${_currentSpeaker == 'hi' ? 'Hindi' : 'Santali'} Speaker..."),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: _currentSpeaker.isNotEmpty ? primary : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.forum_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          "Two-Way Voice Translation",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Press Hindi mic or Santali mic to speak in real-time.",
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isHindi = msg.speakerLang == 'hi';

                      return Align(
                        alignment: isHindi ? Alignment.centerLeft : Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.82,
                          ),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isHindi
                                ? (isDark ? const Color(0xFF233044) : const Color(0xFFEBF3FF))
                                : (isDark ? const Color(0xFF382A24) : const Color(0xFFFFF0EA)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isHindi ? Colors.blue.withValues(alpha: 0.3) : primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isHindi ? "Hindi Speaker" : "Santali Speaker",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isHindi ? Colors.blue.shade700 : primary,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.volume_up, size: 18),
                                    onPressed: () {
                                      _voiceService.speak(
                                        text: msg.translated,
                                        langCode: isHindi ? 'sat' : 'hi',
                                        phoneticFallback: msg.phonetic,
                                      );
                                    },
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                              Text(
                                msg.text,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                              const Divider(height: 12),
                              Text(
                                msg.translated,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isHindi ? primary : const Color(0xFF2D6A4F),
                                ),
                              ),
                              if (msg.phonetic.isNotEmpty)
                                Text(
                                  msg.phonetic,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom Dual Mic Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2638) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Hindi Speaker Button
                Expanded(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      final active = _currentSpeaker == 'hi';
                      return ElevatedButton.icon(
                        onPressed: () => _startListening('hi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: active ? Colors.red : const Color(0xFF1F4068),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: Icon(active ? Icons.mic : Icons.mic_none),
                        label: Text(
                          active ? "Listening..." : "Speak Hindi",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: "Offline Phrases & Keyboard",
                  icon: const Icon(Icons.offline_bolt),
                  onPressed: () => _showOfflineAssistant(_currentSpeaker.isNotEmpty ? _currentSpeaker : 'hi'),
                ),
                const SizedBox(width: 8),
                // Santali Speaker Button
                Expanded(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      final active = _currentSpeaker == 'sat';
                      return ElevatedButton.icon(
                        onPressed: () => _startListening('sat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: active ? Colors.red : primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: Icon(active ? Icons.mic : Icons.mic_none),
                        label: Text(
                          active ? "Listening..." : "Speak Santali",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
