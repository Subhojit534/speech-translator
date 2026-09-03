import 'package:flutter/material.dart';
import 'package:speech_translator/service/offline/santali_dictionary.dart';
import 'package:speech_translator/service/voice/voice_service.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final VoiceService _voiceService = VoiceService();
  String _search = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredVocab = SantaliDictionary.vocabulary.where((w) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      return w.hindi.toLowerCase().contains(q) ||
          w.santaliOlChiki.contains(q) ||
          w.santaliLatin.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dictionary & Ol Chiki"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primary,
          indicatorColor: primary,
          tabs: const [
            Tab(text: "Vocabulary", icon: Icon(Icons.menu_book)),
            Tab(text: "Ol Chiki Alphabet", icon: Icon(Icons.spellcheck)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Vocabulary Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  onChanged: (val) => setState(() => _search = val),
                  decoration: InputDecoration(
                    hintText: "Search word in Hindi or Santali...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E2638) : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredVocab.length,
                  itemBuilder: (context, index) {
                    final word = filteredVocab[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Row(
                          children: [
                            Text(
                              word.hindi,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                word.partOfSpeech,
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(
                              word.santaliOlChiki,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: primary,
                              ),
                            ),
                            Text(
                              "Phonetic: ${word.santaliLatin}  |  Devanagari: ${word.santaliDevanagari}",
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.volume_up, color: primary),
                          onPressed: () {
                            _voiceService.speak(
                              text: word.santaliOlChiki,
                              langCode: 'sat',
                              phoneticFallback: word.santaliLatin,
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Ol Chiki Alphabet Chart
          GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.6,
            ),
            itemCount: SantaliDictionary.olChikiAlphabet.length,
            itemBuilder: (context, index) {
              final letter = SantaliDictionary.olChikiAlphabet[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          letter["char"]!,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              letter["name"]!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              letter["ipa"]!,
                              style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                            ),
                            Text(
                              letter["meaning"]!,
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
