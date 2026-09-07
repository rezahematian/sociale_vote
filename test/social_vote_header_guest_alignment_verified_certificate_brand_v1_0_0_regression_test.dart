import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('narrow guest header keeps all guest actions on one line', () {
    final source = File(
      'lib/features/home/presentation/widgets/home_top_bar.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('SOCIAL VOTE GUEST HEADER ONE-LINE CONTRACT V1.0.0'),
    );
    expect(source, contains('SocialVoteHeaderBrand(height: 40)'));
    expect(source, contains('guestAuthActions(compact: true)'));
    expect(source, contains('compactUtilities = guestUtilityActions(size: 34)'));
    expect(source, isNot(contains('const SizedBox(height: 7)')));
  });

  test('authenticated Home header uses centered optical baseline', () {
    final source = File(
      'lib/features/home/presentation/widgets/home_top_bar.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('SOCIAL VOTE AUTHENTICATED HEADER OPTICAL ALIGNMENT V1.0.0'),
    );
    final marker = source.indexOf(
      'SOCIAL VOTE AUTHENTICATED HEADER OPTICAL ALIGNMENT V1.0.0',
    );
    final loggedInSection = source.substring(marker, marker + 260);
    expect(
      loggedInSection,
      contains('crossAxisAlignment: CrossAxisAlignment.center'),
    );
  });

  test('Verified Result UI uses both approved seals only for valid integrity', () {
    final source = File(
      'lib/features/organization/presentation/pages/verified_session_report_page.dart',
    ).readAsStringSync();

    expect(source, contains('assets/branding/social_vote_official_signature.png'));
    expect(source, contains('assets/branding/social_vote_verified_result_seal.png'));
    expect(source, contains('if (valid)'));
    expect(source, contains('verifiedCertificateIntegrityFailed'));
  });

  test('Verified Result PDF automatically embeds both approved seals', () {
    final source = File(
      'lib/shared/services/session_pdf_service.dart',
    ).readAsStringSync();

    expect(source, contains("import 'package:flutter/services.dart';"));
    expect(source, contains('_loadBundledPdfImage(_officialSignatureAsset)'));
    expect(source, contains('_loadBundledPdfImage(_verifiedResultSealAsset)'));
    expect(source, contains('report.hashValid'));
    expect(source, contains('pw.MemoryImage'));
  });

  test('approved seal asset files are bundled and non-trivial', () {
    final official = File(
      'assets/branding/social_vote_official_signature.png',
    );
    final verified = File(
      'assets/branding/social_vote_verified_result_seal.png',
    );

    expect(official.existsSync(), isTrue);
    expect(verified.existsSync(), isTrue);
    expect(official.lengthSync(), greaterThan(500000));
    expect(verified.lengthSync(), greaterThan(1000000));
  });
}
