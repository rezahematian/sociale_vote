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
    expect(source, contains('SocialVoteHeaderBrand(height: 50)'));
    expect(source, contains('_buildGuestAuthActions(compact: true)'));
    expect(
        source, contains('guestUtilityActions =\n                _buildGuestUtilityActions(size: 38)'));
    expect(source, isNot(contains('const SizedBox(height: 7)')));
    expect(source, contains('const height = 38.0;'));
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

  test(
      'Verified Result UI uses centralized certificate assets and no organizer logo in header',
      () {
    final source = File(
      'lib/features/organization/presentation/pages/verified_session_report_page.dart',
    ).readAsStringSync();
    final assets = File(
      'lib/shared/branding/social_vote_certificate_brand_assets.dart',
    ).readAsStringSync();
    final registry = File(
      'lib/shared/branding/social_vote_brand_assets.dart',
    ).readAsStringSync();

    expect(
      registry,
      contains('assets/branding/social_vote_official_signature_master.png'),
    );
    expect(
      registry,
      contains('assets/branding/social_vote_verified_result_seal_master.png'),
    );
    expect(assets, contains('SocialVoteBrandAssets.officialSignature'));
    expect(assets, contains('SocialVoteBrandAssets.verifiedResultSeal'));
    expect(
      source,
      contains('SocialVoteCertificateBrandAssets.officialSignature'),
    );
    expect(
      source,
      contains('SocialVoteCertificateBrandAssets.verifiedResultSeal'),
    );
    expect(
      source,
      contains('SOCIAL VOTE VERIFIED CERTIFICATE BRAND LAYOUT V1.0.1'),
    );
    expect(source, contains('if (valid)'));
    expect(source, contains('verifiedCertificateIntegrityFailed'));

    final headerStart = source.indexOf('class _CertificateHeader');
    final headerEnd = source.indexOf('class _SectionTitle', headerStart);
    final header = source.substring(headerStart, headerEnd);
    expect(header, isNot(contains('organizationLogoUrl')));
    expect(header, isNot(contains('NetworkImage')));
    expect(header, isNot(contains('CircleAvatar')));
    expect(header, isNot(contains('organizationName')));
  });

  test('Verified Result PDF uses the same centralized two-mark header', () {
    final source = File(
      'lib/shared/services/session_pdf_service.dart',
    ).readAsStringSync();

    expect(source, contains("import 'package:flutter/services.dart';"));
    expect(
      source,
      contains('SocialVoteCertificateBrandAssets.officialSignature'),
    );
    expect(
      source,
      contains('SocialVoteCertificateBrandAssets.verifiedResultSeal'),
    );
    expect(source, contains('report.hashValid'));
    expect(source, contains('pw.MemoryImage'));
    expect(
      source,
      contains('SOCIAL VOTE VERIFIED CERTIFICATE BRAND LAYOUT V1.0.1'),
    );
    expect(source, isNot(contains('organizationLogo = await networkImage')));
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
