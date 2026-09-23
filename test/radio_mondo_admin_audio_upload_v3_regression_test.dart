import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Radio Mondo Admin Audio Upload V3 source contract', () {
    final service = File(
      'lib/shared/services/radio_mondo_admin_storage_service.dart',
    ).readAsStringSync();

    final web = File(
      'lib/shared/services/radio_mondo_web_audio_picker_html.dart',
    ).readAsStringSync();

    final admin = File(
      'lib/features/admin/presentation/widgets/admin_radio_mondo_control_section.dart',
    ).readAsStringSync();

    expect(
      service,
      contains('static const int maxBytes = 200 * 1024 * 1024;'),
    );

    for (final ext in <String>[
      'mp3',
      'm4a',
      'mp4',
      'aac',
      'ogg',
      'oga',
      'opus',
      'wav',
      'wave',
      'flac',
      'webm',
    ]) {
      expect(service, contains("'$ext'"));
    }

    expect(service, contains("'wav': 'audio/wav'"));
    expect(service, contains("'flac': 'audio/flac'"));
    expect(service, contains("'webm': 'audio/webm'"));

    expect(service, contains("hasAscii(0, 'RIFF')"));
    expect(service, contains("hasAscii(8, 'WAVE')"));
    expect(service, contains("hasAscii(0, 'fLaC')"));
    expect(service, contains("hasAscii(0, 'OggS')"));

    expect(
      web,
      contains(
        'audio/*,.mp3,.m4a,.mp4,.aac,.ogg,.oga,.opus,.wav,.wave,.flac,.webm',
      ),
    );

    expect(admin, contains('massimo 200 MB'));
    expect(admin, contains('maximum 200 MB'));
    expect(admin, contains('WAV'));
    expect(admin, contains('FLAC'));
    expect(admin, contains('WEBM'));

    expect(service, isNot(contains('service_role')));
  });
}
