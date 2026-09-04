import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_profile_page.dart'
    as profile_page;
import 'package:sociale_vote/shared/services/world_appearance_service.dart';

void main() {
  test('Account UX V1.0.0 target page compiles', () {
    const Type pageType = profile_page.MyProfilePage;
    expect(pageType.toString(), 'MyProfilePage');
  });

  test('Account landing order is profile, Workspace, quick settings, sections', () {
    final source = File(
      'lib/features/profile/presentation/pages/my_profile_page.dart',
    ).readAsStringSync();

    final profileIndex = source.indexOf(
      '_SectionTitle(l10n.profilePublicProfileSectionTitle)',
    );
    final workspaceIndex = source.indexOf(
      'FutureBuilder<OrganizationContext?>',
      profileIndex,
    );
    final quickIndex = source.indexOf(
      '_SectionTitle(_quickSettingsSectionTitle(context))',
      workspaceIndex,
    );
    final sectionsIndex = source.indexOf(
      '_SectionTitle(_accountSectionsTitle(context))',
      quickIndex,
    );
    final howItWorksIndex = source.indexOf(
      'l10n.profileHowItWorksTitle',
      sectionsIndex,
    );

    expect(profileIndex, greaterThanOrEqualTo(0));
    expect(workspaceIndex, greaterThan(profileIndex));
    expect(quickIndex, greaterThan(workspaceIndex));
    expect(sectionsIndex, greaterThan(quickIndex));
    expect(howItWorksIndex, greaterThan(sectionsIndex));
  });

  test('Language and Globe have direct quick selectors', () {
    final source = File(
      'lib/features/profile/presentation/pages/my_profile_page.dart',
    ).readAsStringSync();

    expect(source, contains('Future<void> _showGlobeStyleSheet('));
    expect(source, contains('WorldAppearanceService.selectableGlobeStyles'));
    expect(source, contains('onTap: () => _showAppLanguageSheet(),'));
    expect(source, contains('onTap: () => _showGlobeStyleSheet(),'));
    expect(source, contains('class _AccountSectionPage extends StatelessWidget'));

    expect(WorldAppearanceService.selectableGlobeStyles, hasLength(6));
    expect(
      WorldAppearanceService.selectableGlobeStyles,
      contains(WorldAppearanceService.defaultGlobeStyle),
    );
  });

  test('Account section index keeps the five requested groups', () {
    final source = File(
      'lib/features/profile/presentation/pages/my_profile_page.dart',
    ).readAsStringSync();

    for (final marker in <String>[
      'onTap: _openActivitySection',
      'onTap: () => _openVerificationSection(',
      'onTap: _openPreferencesSection',
      'onTap: _openNotificationsSection',
      'onTap: () => _openSecuritySection(accountEmail)',
    ]) {
      expect(source, contains(marker), reason: marker);
    }
  });

  test('nine ARB catalogs remain exactly aligned at 1309 messages', () {
    const languageCodes = <String>[
      'en',
      'it',
      'de',
      'fa',
      'es',
      'pt',
      'fr',
      'ar',
      'ro',
    ];

    Set<String>? referenceKeys;

    for (final code in languageCodes) {
      final file = File('lib/l10n/app_$code.arb');
      expect(file.existsSync(), isTrue, reason: code);

      final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final keys = decoded.keys.where((key) => !key.startsWith('@')).toSet();
      final emptyValues = decoded.entries
          .where((entry) => !entry.key.startsWith('@'))
          .where((entry) => entry.value is String)
          .where((entry) => (entry.value as String).trim().isEmpty)
          .map((entry) => entry.key)
          .toList();

      expect(keys, hasLength(1309), reason: code);
      expect(emptyValues, isEmpty, reason: '$code empty values');

      referenceKeys ??= keys;
      expect(keys, referenceKeys, reason: '$code key parity');

      expect(
        File('lib/l10n/app_localizations_$code.dart').existsSync(),
        isTrue,
        reason: '$code generated localization',
      );
    }
  });

  test('Account language selector still exposes System plus all nine languages', () {
    final source = File(
      'lib/features/profile/presentation/pages/my_profile_page.dart',
    ).readAsStringSync();

    for (final value in <String>[
      'system',
      'it',
      'en',
      'de',
      'fa',
      'es',
      'pt',
      'fr',
      'ar',
      'ro',
    ]) {
      expect(source, contains("value: '$value'"), reason: value);
    }

    expect(source, contains('isScrollControlled: true'));
    expect(source, contains('SingleChildScrollView'));
    expect(source, contains('textDirection: TextDirection.ltr'));
    expect(source, contains("label: 'فارسی'"));
    expect(source, contains("label: 'العربية'"));
  });
}
