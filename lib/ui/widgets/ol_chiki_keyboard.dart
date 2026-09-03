import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OlChikiKeyboard extends StatelessWidget {
  final Function(String char) onKeyTap;
  final VoidCallback onBackspace;
  final VoidCallback onSpace;
  final VoidCallback? onClear;
  final VoidCallback? onClose;

  const OlChikiKeyboard({
    super.key,
    required this.onKeyTap,
    required this.onBackspace,
    required this.onSpace,
    this.onClear,
    this.onClose,
  });

  static const List<List<String>> rows = [
    ['ᱚ', 'ᱛ', 'ᱜ', 'ᱝ', 'ᱞ', 'ᱟ', 'ᱠ', 'ᱡ'],
    ['ᱢ', 'ᱣ', 'ᱤ', 'ᱥ', 'ᱦ', 'ᱧ', 'ᱨ', 'ᱩ'],
    ['ᱪ', 'ᱫ', 'ᱬ', 'ᱭ', 'ᱮ', 'ᱯ', 'ᱰ', 'ᱱ'],
    ['ᱲ', 'ᱳ', 'ᱴ', 'ᱵ', 'ᱶ', 'ᱷ', 'ᱸ', 'ᱹ'],
    ['ᱺ', 'ᱻ', 'ᱼ', '᱾', '᱿', '᱐', '᱑', '᱒'],
    ['᱓', '᱔', '᱕', '᱖', '᱗', '᱘', '᱙', '0'],
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kbBg = isDark ? const Color(0xFF1B2232) : const Color(0xFFE5E7EB);
    final keyBg = isDark ? const Color(0xFF28334A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: kbBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "ᱚᱞ ᱪᱤᱠᱤ ᱠᱤᱵᱳᱨᱰ (Ol Chiki)",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Row(
                    children: [
                      if (onClear != null)
                        TextButton(
                          onPressed: onClear,
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text("Clear", style: TextStyle(fontSize: 12)),
                        ),
                      if (onClose != null)
                        IconButton(
                          icon: const Icon(Icons.keyboard_hide, size: 20),
                          onPressed: onClose,
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            for (var row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.map((char) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Material(
                          color: keyBg,
                          borderRadius: BorderRadius.circular(6),
                          elevation: 1,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onKeyTap(char);
                            },
                            child: Container(
                              height: 38,
                              alignment: Alignment.center,
                              child: Text(
                                char,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: onSpace,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: keyBg,
                        foregroundColor: textColor,
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      icon: const Icon(Icons.space_bar, size: 18),
                      label: const Text("Space"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: onBackspace,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC84B31),
                        foregroundColor: Colors.white,
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Icon(Icons.backspace_outlined, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
