import 'package:flutter/material.dart';

import 'package:sociale_vote/l10n/app_localizations.dart';

class ContentLanguageOption {
  final String code;
  final String label;

  const ContentLanguageOption({
    required this.code,
    required this.label,
  });
}

const List<ContentLanguageOption> supportedContentLanguages = [
  ContentLanguageOption(code: 'it', label: 'Italiano'),
  ContentLanguageOption(code: 'en', label: 'English'),
  ContentLanguageOption(code: 'es', label: 'Español'),
  ContentLanguageOption(code: 'fr', label: 'Français'),
  ContentLanguageOption(code: 'de', label: 'Deutsch'),
  ContentLanguageOption(code: 'pt', label: 'Português'),
  ContentLanguageOption(code: 'ro', label: 'Română'),
  ContentLanguageOption(code: 'ar', label: 'العربية'),
  ContentLanguageOption(code: 'fa', label: 'فارسی'),
  ContentLanguageOption(code: 'tr', label: 'Türkçe'),
  ContentLanguageOption(code: 'ru', label: 'Русский'),
  ContentLanguageOption(code: 'uk', label: 'Українська'),
  ContentLanguageOption(code: 'zh', label: '中文'),
  ContentLanguageOption(code: 'ja', label: '日本語'),
  ContentLanguageOption(code: 'ko', label: '한국어'),
  ContentLanguageOption(code: 'hi', label: 'हिन्दी'),
];

String normalizeContentLanguageCode(
  String? value, {
  String fallback = 'und',
}) {
  final normalized = value?.trim().toLowerCase().replaceAll('_', '-');
  if (normalized == null || normalized.isEmpty) {
    return fallback;
  }

  final valid = RegExp(r'^[a-z]{2,3}(-[a-z0-9]{2,8})*$');
  if (normalized == 'und' || valid.hasMatch(normalized)) {
    return normalized;
  }

  return fallback;
}

String defaultContentLanguageCodeForLocale(Locale locale) {
  final languageCode = normalizeContentLanguageCode(
    locale.languageCode,
  );

  final supported = supportedContentLanguages.any(
    (option) => option.code == languageCode,
  );

  return supported ? languageCode : 'und';
}

class ContentLanguageField extends StatelessWidget {
  final String selectedCode;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final bool includeUndetermined;

  const ContentLanguageField({
    super.key,
    required this.selectedCode,
    required this.onChanged,
    this.enabled = true,
    this.includeUndetermined = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final normalizedSelected = normalizeContentLanguageCode(selectedCode);

    final options = <ContentLanguageOption>[
      if (includeUndetermined)
        ContentLanguageOption(
          code: 'und',
          label: l10n.contentLanguageUndetermined,
        ),
      ...supportedContentLanguages,
    ];

    if (!options.any((option) => option.code == normalizedSelected)) {
      options.add(
        ContentLanguageOption(
          code: normalizedSelected,
          label: normalizedSelected.toUpperCase(),
        ),
      );
    }

    return InputDecorator(
      decoration: InputDecoration(
        labelText: l10n.contentLanguageFieldLabel,
        helperText: l10n.contentLanguageFieldHelper,
        border: const OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: normalizedSelected,
          isExpanded: true,
          onChanged: enabled
              ? (value) {
                  if (value != null) {
                    onChanged(value);
                  }
                }
              : null,
          items: options
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option.code,
                  child: Text(
                    '${option.label} · ${option.code.toUpperCase()}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}
