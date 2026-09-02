import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryItem {
  final String id;
  final String sourceText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final String phonetic;
  final DateTime timestamp;
  bool isFavorite;

  HistoryItem({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    required this.phonetic,
    required this.timestamp,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'sourceText': sourceText,
    'translatedText': translatedText,
    'sourceLang': sourceLang,
    'targetLang': targetLang,
    'phonetic': phonetic,
    'timestamp': timestamp.toIso8601String(),
    'isFavorite': isFavorite,
  };

  factory HistoryItem.fromJson(Map<String, dynamic> map) => HistoryItem(
    id: map['id'] ?? '',
    sourceText: map['sourceText'] ?? '',
    translatedText: map['translatedText'] ?? '',
    sourceLang: map['sourceLang'] ?? 'hi',
    targetLang: map['targetLang'] ?? 'sat',
    phonetic: map['phonetic'] ?? '',
    timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
    isFavorite: map['isFavorite'] ?? false,
  );
}

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _historyKey = 'santali_translation_history';
  static const String _offlineModeKey = 'santali_offline_mode';

  Future<List<HistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_historyKey) ?? [];
    return data
        .map((item) => HistoryItem.fromJson(jsonDecode(item)))
        .toList();
  }

  Future<void> addHistoryItem(HistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getHistory();

    // Prevent duplicate adjacent entries
    items.removeWhere((x) => x.sourceText.trim() == item.sourceText.trim() && x.sourceLang == item.sourceLang);
    items.insert(0, item);

    // Keep top 100 entries
    if (items.length > 100) {
      items.removeRange(100, items.length);
    }

    final raw = items.map((x) => jsonEncode(x.toJson())).toList();
    await prefs.setStringList(_historyKey, raw);
  }

  Future<void> toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getHistory();
    for (var it in items) {
      if (it.id == id) {
        it.isFavorite = !it.isFavorite;
        break;
      }
    }
    final raw = items.map((x) => jsonEncode(x.toJson())).toList();
    await prefs.setStringList(_historyKey, raw);
  }

  Future<void> deleteHistoryItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getHistory();
    items.removeWhere((x) => x.id == id);
    final raw = items.map((x) => jsonEncode(x.toJson())).toList();
    await prefs.setStringList(_historyKey, raw);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<bool> getOfflineMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_offlineModeKey) ?? true; // Default to offline-first
  }

  Future<void> setOfflineMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineModeKey, value);
  }
}
