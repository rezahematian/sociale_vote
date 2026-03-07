import 'package:flutter/material.dart';
import 'package:sociale_vote/shared/data/countries.dart' as data;

/// Campo riutilizzabile per selezionare un paese.
/// Usa i dati definiti in [lib/shared/data/countries.dart].
class CountrySelectorField extends StatelessWidget {
  final String? selectedCountryCode;
  final ValueChanged<String> onCountrySelected;
  final String label;
  final bool required;

  const CountrySelectorField({
    super.key,
    required this.selectedCountryCode,
    required this.onCountrySelected,
    this.label = 'Country',
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final countries = data.Countries.all;
    final effectiveLabel = required ? '$label *' : label;

    // Trova il paese selezionato (se esiste)
    final selected = countries.firstWhere(
      (c) =>
          c.code.toUpperCase() == (selectedCountryCode ?? '').toUpperCase(),
      orElse: () => data.Country(code: '', name: ''),
    );

    final hasSelected =
        selected.code.isNotEmpty && selected.name.isNotEmpty;

    final textValue =
        hasSelected ? '${selected.name} (${selected.code})' : '';

    return GestureDetector(
      onTap: () => _openCountryPicker(context),
      child: AbsorbPointer(
        child: TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: effectiveLabel,
            border: const OutlineInputBorder(),
            helperText: 'Tap to search and choose a country.',
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          controller: TextEditingController(text: textValue),
        ),
      ),
    );
  }

  Future<void> _openCountryPicker(BuildContext context) async {
    final countries = data.Countries.all;

    String query = '';
    String? resultCode = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final filtered = countries.where((c) {
              if (query.isEmpty) return true;
              final q = query.toLowerCase();

              // 🔹 FILTRO: solo paesi che COMINCIANO con la query
              return c.name.toLowerCase().startsWith(q) ||
                  c.code.toLowerCase().startsWith(q);
            }).toList();

            return AlertDialog(
              title: const Text('Select country'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Type to filter countries...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          query = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Scrollbar(
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final country = filtered[index];
                            return ListTile(
                              title: Text(country.name),
                              subtitle: Text(country.code),
                              onTap: () {
                                Navigator.of(dialogContext)
                                    .pop(country.code);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
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