import 'package:flutter/material.dart';
import 'package:speech_translator/ui/screens/conversation_screen.dart';
import 'package:speech_translator/ui/screens/dictionary_screen.dart';
import 'package:speech_translator/ui/screens/history_screen.dart';
import 'package:speech_translator/ui/screens/home_screen.dart';
import 'package:speech_translator/ui/screens/phrasebook_screen.dart';
import 'package:speech_translator/ui/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SantaliTranslatorApp());
}

class SantaliTranslatorApp extends StatefulWidget {
  const SantaliTranslatorApp({super.key});

  @override
  State<SantaliTranslatorApp> createState() => _SantaliTranslatorAppState();
}

class _SantaliTranslatorAppState extends State<SantaliTranslatorApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Santali Hindi Translator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: MainNavigationContainer(onToggleTheme: _toggleTheme),
    );
  }
}

class MainNavigationContainer extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const MainNavigationContainer({super.key, required this.onToggleTheme});

  @override
  State<MainNavigationContainer> createState() => _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ConversationScreen(),
    PhrasebookScreen(),
    DictionaryScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
        final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() => _currentIndex = idx);
        },
        indicatorColor: primary.withValues(alpha: 0.18),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.translate_outlined),
            selectedIcon: Icon(Icons.translate),
            label: "Translate",
          ),
          NavigationDestination(
            icon: Icon(Icons.record_voice_over_outlined),
            selectedIcon: Icon(Icons.record_voice_over),
            label: "Conversation",
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: "Phrasebook",
          ),
          NavigationDestination(
            icon: Icon(Icons.spellcheck_outlined),
            selectedIcon: Icon(Icons.spellcheck),
            label: "Dictionary",
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: "History",
          ),
        ],
      ),
    );
  }
}
