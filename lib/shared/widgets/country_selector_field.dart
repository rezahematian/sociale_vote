import 'package:flutter/material.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/data/countries.dart' as data;

/// Campo riutilizzabile per selezionare un paese.
/// Usa i dati definiti in [lib/shared/data/countries.dart].
class CountrySelectorField extends StatelessWidget {
  final String? selectedCountryCode;
  final ValueChanged<String> onCountrySelected;
  final String? label;
  final bool required;

  const CountrySelectorField({
    super.key,
    required this.selectedCountryCode,
    required this.onCountrySelected,
    this.label,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    const countries = data.Countries.all;
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final baseLabel = label ?? l10n.homeScopeShortCountry;
    final effectiveLabel = required ? '$baseLabel *' : baseLabel;

    final selected = countries.firstWhere(
      (c) => c.code.toUpperCase() == (selectedCountryCode ?? '').toUpperCase(),
      orElse: () => const data.Country(code: '', name: ''),
    );

    final hasSelected = selected.code.isNotEmpty && selected.name.isNotEmpty;
    final selectedName = selected.localizedName(languageCode);
    final textValue = hasSelected ? '$selectedName (${selected.code})' : '';

    return GestureDetector(
      onTap: () => _openCountryPicker(context),
      child: AbsorbPointer(
        child: TextFormField(
          key: ValueKey(textValue),
          readOnly: true,
          initialValue: textValue,
          decoration: InputDecoration(
            labelText: effectiveLabel,
            helperText: l10n.homeScopeChooseCountry,
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
        ),
      ),
    );
  }

  Future<void> _openCountryPicker(BuildContext context) async {
    const countries = data.Countries.all;
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;

    String query = '';
    final String? resultCode = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final normalizedQuery = query.trim().toLowerCase();

            int matchPriority(data.Country country) {
              if (normalizedQuery.isEmpty) {
                return 0;
              }

              final localizedName =
                  country.localizedName(languageCode).toLowerCase();
              final englishName = country.name.toLowerCase();
              final countryCode = country.code.toLowerCase();

              if (localizedName.startsWith(normalizedQuery)) return 0;
              if (englishName.startsWith(normalizedQuery)) return 1;
              if (countryCode.startsWith(normalizedQuery)) return 2;
              if (localizedName.contains(normalizedQuery)) return 3;
              if (englishName.contains(normalizedQuery)) return 4;
              return 5;
            }

            final filtered = countries.where((country) {
              if (normalizedQuery.isEmpty) {
                return true;
              }

              final localizedName =
                  country.localizedName(languageCode).toLowerCase();
              final englishName = country.name.toLowerCase();
              final countryCode = country.code.toLowerCase();

              return localizedName.startsWith(normalizedQuery) ||
                  englishName.startsWith(normalizedQuery) ||
                  countryCode.startsWith(normalizedQuery);
            }).toList()
              ..sort((a, b) {
                final priorityComparison =
                    matchPriority(a).compareTo(matchPriority(b));

                if (priorityComparison != 0) {
                  return priorityComparison;
                }

                return a
                    .localizedName(languageCode)
                    .compareTo(b.localizedName(languageCode));
              });

            return AlertDialog(
              title: Text(l10n.homeScopeChooseCountry),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: l10n.homeScopeCountrySearchHint,
                      ),
                      onChanged: (value) {
                        setState(() {
                          query = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final country = filtered[index];
                          return ListTile(
                            title: Text(country.localizedName(languageCode)),
                            subtitle: Text(country.code),
                            onTap: () {
                              Navigator.of(dialogContext).pop(country.code);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.commonCancelButton),
                ),
              ],
            );
          },
        );
      },
    );

    if (resultCode != null) {
      onCountrySelected(resultCode);
    }
  }
}
