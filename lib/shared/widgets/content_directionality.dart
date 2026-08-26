import 'package:flutter/widgets.dart';

/// Resolves the base direction of authored/editorial content from its first
/// strong script. This is deliberately independent from the app locale: an
/// Italian News title stays LTR while the UI language is Persian, and Persian
/// authored content stays RTL inside the same stable card geometry.
TextDirection socialVoteContentDirection(
  String value, {
  TextDirection fallback = TextDirection.ltr,
}) {
  for (final rune in value.runes) {
    final isRtl = (rune >= 0x0590 && rune <= 0x08FF) ||
        (rune >= 0xFB1D && rune <= 0xFDFF) ||
        (rune >= 0xFE70 && rune <= 0xFEFF);
    if (isRtl) {
      return TextDirection.rtl;
    }

    final isLatin = (rune >= 0x0041 && rune <= 0x005A) ||
        (rune >= 0x0061 && rune <= 0x007A);
    if (isLatin) {
      return TextDirection.ltr;
    }
  }
  return fallback;
}

TextAlign socialVoteContentTextAlign(String value) {
  return socialVoteContentDirection(value) == TextDirection.rtl
      ? TextAlign.right
      : TextAlign.left;
}
