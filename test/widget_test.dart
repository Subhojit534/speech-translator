import 'package:flutter_test/flutter_test.dart';
import 'package:speech_translator/main.dart';

void main() {
  testWidgets('App smoke test loads main navigation and home screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SantaliTranslatorApp());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Santali Translator'), findsOneWidget);
    expect(find.text('Translate'), findsOneWidget);
    expect(find.text('Conversation'), findsOneWidget);
    expect(find.text('Phrasebook'), findsOneWidget);
    expect(find.text('Dictionary'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
  });
}
