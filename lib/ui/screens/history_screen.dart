import 'package:flutter/material.dart';
import 'package:speech_translator/service/storage/storage_service.dart';
import 'package:speech_translator/service/voice/voice_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StorageService _storageService = StorageService();
  final VoiceService _voiceService = VoiceService();

  List<HistoryItem> _allHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final items = await _storageService.getHistory();
    setState(() {
      _allHistory = items;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final favorites = _allHistory.where((x) => x.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("History & Favorites"),
        actions: [
          IconButton(
            tooltip: "Clear History",
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Clear History?"),
                  content: const Text("This will remove all recent translation history."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Clear")),
                  ],
                ),
              );
              if (confirm == true) {
                await _storageService.clearHistory();
                _loadHistory();
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primary,
          indicatorColor: primary,
          tabs: [
            Tab(text: "Recent (${_allHistory.length})", icon: const Icon(Icons.history)),
            Tab(text: "Favorites (${favorites.length})", icon: const Icon(Icons.star)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_allHistory, "No translation history yet"),
                _buildList(favorites, "No favorites saved yet. Star items on the translation card to save them."),
              ],
            ),
    );
  }

  Widget _buildList(List<HistoryItem> items, String emptyMessage) {
    final primary = Theme.of(context).colorScheme.primary;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) async {
            await _storageService.deleteHistoryItem(item.id);
            _loadHistory();
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${item.sourceLang == 'hi' ? 'Hindi' : 'Santali'} ➔ ${item.targetLang == 'sat' ? 'Santali' : 'Hindi'}",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              item.isFavorite ? Icons.star : Icons.star_border,
                              color: item.isFavorite ? Colors.amber : Colors.grey,
                              size: 20,
                            ),
                            onPressed: () async {
                              await _storageService.toggleFavorite(item.id);
                              _loadHistory();
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.volume_up, color: primary, size: 20),
                            onPressed: () {
                              _voiceService.speak(
                                text: item.translatedText,
                                langCode: item.targetLang,
                                phoneticFallback: item.phonetic,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    item.sourceText,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.translatedText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                  if (item.phonetic.isNotEmpty)
                    Text(
                      item.phonetic,
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
