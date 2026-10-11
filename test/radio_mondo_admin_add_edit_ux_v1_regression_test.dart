import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Radio Mondo Admin add/edit keeps a clear in-form preview', () {
    final admin = File(
      'lib/features/admin/presentation/widgets/admin_radio_mondo_control_section.dart',
    ).readAsStringSync();

    expect(admin, contains("'Anteprima audio'"));
    expect(admin, contains("'Riproduci anteprima'"));
    expect(admin, contains("'Ferma anteprima'"));
    expect(admin, contains('Future<void> _togglePreview() async'));
    expect(admin, contains('playPreviewStation(station)'));
    expect(admin, contains("'admin-form-preview-"));
    expect(admin, contains('if (!context.mounted) return;'));
    expect(
      admin,
      contains('Il file selezionato verrà caricato con Salva.'),
    );
  });

  test('Radio Mondo Admin add/edit exposes a simple primary workflow', () {
    final admin = File(
      'lib/features/admin/presentation/widgets/admin_radio_mondo_control_section.dart',
    ).readAsStringSync();

    expect(admin, contains("'Campi essenziali'"));
    expect(admin, contains("'Titolo pubblico'"));
    expect(admin, contains("'Categoria musicale'"));
    expect(admin, contains("'Ordine categoria'"));
    expect(admin, contains("'Carica / sostituisci file audio'"));
    expect(admin, contains("'Pubblicazione'"));
    expect(admin, contains("'Visibile / abilitata nella Radio Mondo'"));
    expect(admin, contains("'Diritti / attribuzione'"));
    expect(admin, contains("'Motivo amministrativo'"));
    expect(admin, contains("'Salva e ricarica'"));

    expect(
      admin.indexOf("'Campi essenziali'"),
      lessThan(admin.indexOf("'Opzioni avanzate'")),
    );
    expect(
      admin.indexOf("'Carica / sostituisci file audio'"),
      lessThan(admin.indexOf("'Opzioni avanzate'")),
    );
  });

  test('Radio Mondo Admin keeps technical controls under advanced options', () {
    final admin = File(
      'lib/features/admin/presentation/widgets/admin_radio_mondo_control_section.dart',
    ).readAsStringSync();

    expect(admin, contains("'Opzioni avanzate'"));
    expect(admin, contains("'Sorgente audio'"));
    expect(admin, contains("'Tipo canale'"));
    expect(admin, contains("'Lingua (opzionale)'"));
    expect(admin, contains("'World Brief collegato (opzionale)'"));
    expect(admin, contains("'URL licenza (opzionale)'"));
    expect(admin, contains("'Stazione predefinita World Live'"));
    expect(admin, contains("'LIVE adesso'"));
  });

  test('Radio Mondo Admin upload and backend contracts stay in place', () {
    final admin = File(
      'lib/features/admin/presentation/widgets/admin_radio_mondo_control_section.dart',
    ).readAsStringSync();

    expect(
      admin,
      contains('RadioMondoAdminStorageService.instance.upload('),
    );
    expect(admin, contains('widget.repository.upsertRadioMondoTrack('));
    expect(
      admin,
      contains('await RadioMondoService.instance.reloadCatalog();'),
    );
    expect(admin, contains('controller: _attribution'));
    expect(admin, contains('validator: _required'));
    expect(admin, isNot(contains('service_role')));
  });
}
