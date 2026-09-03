import 'package:flutter/widgets.dart';

bool _isRtlStrongRune(int rune) {
  return (rune >= 0x0590 && rune <= 0x08FF) ||
      (rune >= 0xFB1D && rune <= 0xFDFF) ||
      (rune >= 0xFE70 && rune <= 0xFEFF) ||
      (rune >= 0x1EE00 && rune <= 0x1EEFF);
}

bool _isLtrStrongRune(int rune) {
  return (rune >= 0x0041 && rune <= 0x005A) ||
      (rune >= 0x0061 && rune <= 0x007A) ||
      (rune >= 0x00C0 && rune <= 0x02AF) ||
      (rune >= 0x0370 && rune <= 0x052F);
}

/// Resolves the base paragraph direction from the first strong script.
///
/// Neutral characters, emoji, punctuation and numbers do not decide the base
/// direction. Therefore a value such as `سلام 99999` remains an RTL paragraph,
/// while the digits keep their normal left-to-right numeric order through the
/// Unicode BiDi algorithm. A value that starts with Latin text remains LTR even
/// when the app locale is Persian.
TextDirection socialVoteContentDirection(
  String value, {
  TextDirection fallback = TextDirection.ltr,
}) {
  for (final rune in value.runes) {
    if (_isRtlStrongRune(rune)) {
      return TextDirection.rtl;
    }
    if (_isLtrStrongRune(rune)) {
      return TextDirection.ltr;
    }
  }
  return fallback;
}

TextAlign socialVoteContentTextAlign(
  String value, {
  TextDirection fallback = TextDirection.ltr,
}) {
  return socialVoteContentDirection(value, fallback: fallback) == TextDirection.rtl
      ? TextAlign.right
      : TextAlign.left;
}

/// Locale-owned UI text direction only. It never wraps the parent application
/// and therefore cannot mirror rows, controls, navigation or page geometry.
TextDirection socialVoteLocaleTextDirection(BuildContext context) {
  final languageCode = Localizations.localeOf(context).languageCode.toLowerCase();
  return languageCode == 'fa' || languageCode == 'ar'
      ? TextDirection.rtl
      : TextDirection.ltr;
}

TextAlign socialVoteLocaleTextAlign(BuildContext context) {
  return socialVoteLocaleTextDirection(context) == TextDirection.rtl
      ? TextAlign.right
      : TextAlign.left;
}

/// Authored input follows the first strong character. Empty input falls back
/// to the current locale so an empty Persian/Arabic editor starts from the right.
/// Once the user types Latin text the field becomes LTR on the next rebuild.
TextDirection socialVoteEditableTextDirection(
  BuildContext context,
  String value,
) {
  return socialVoteContentDirection(
    value,
    fallback: socialVoteLocaleTextDirection(context),
  );
}

TextAlign socialVoteEditableTextAlign(
  BuildContext context,
  String value,
) {
  return socialVoteEditableTextDirection(context, value) == TextDirection.rtl
      ? TextAlign.right
      : TextAlign.left;
}

/// Full-width authored text. The full parent width is intentional: it keeps
/// every wrapped RTL line anchored to the right instead of letting a short
/// final line appear visually detached on the left.
class SocialVoteDirectionalText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  const SocialVoteDirectionalText(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  @override
  Widget build(BuildContext context) {
    final direction = socialVoteContentDirection(data);
    return SizedBox(
      width: double.infinity,
      child: Text(
        data,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
        textDirection: direction,
        textAlign: direction == TextDirection.rtl
            ? TextAlign.right
            : TextAlign.left,
        textWidthBasis: TextWidthBasis.parent,
      ),
    );
  }
}
