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

  test('Radio Mondo Admin add/edit labels the current management fields', () {
    final admin = File(
      'lib/features/admin/presentation/widgets/admin_radio_mondo_control_section.dart',
    ).readAsStringSync();

    expect(admin, contains("'Identità, sorgente e classificazione'"));
    expect(admin, contains("'Sorgente audio'"));
    expect(admin, contains("'Categoria musicale'"));
    expect(admin, contains("'Tipo canale'"));
    expect(admin, contains("'Posizione nella categoria (0–1000)'"));
    expect(admin, contains('Ogni categoria può ripartire da 10.'));
    expect(admin, contains(r"'Ordine ${track.sortOrder}'"));
    expect(admin, contains("'Visibile / abilitata nella Radio Mondo'"));
    expect(admin, contains("'Pubblicazione e diritti'"));
    expect(admin, contains("'Salva e ricarica'"));
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
        admin, contains('await RadioMondoService.instance.reloadCatalog();'));
    expect(admin, contains('controller: _attribution'));
    expect(admin, contains('validator: _required'));
    expect(admin, isNot(contains('service_role')));
  });
}
