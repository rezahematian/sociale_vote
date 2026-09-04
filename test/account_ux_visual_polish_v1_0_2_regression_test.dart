import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_profile_page.dart'
    as profile_page;
import 'package:sociale_vote/shared/services/world_appearance_service.dart';

String _functionBlock(String source, String startMarker, String endMarker) {
  final start = source.indexOf(startMarker);
  final end = source.indexOf(endMarker, start + startMarker.length);
  expect(start, greaterThanOrEqualTo(0), reason: 'Missing $startMarker');
  expect(end, greaterThan(start), reason: 'Missing $endMarker after $startMarker');
  return source.substring(start, end);
}

void main() {
  test('Account visual polish target page compiles', () {
    const Type pageType = profile_page.MyProfilePage;
    expect(pageType.toString(), 'MyProfilePage');
  });

  test('quick Globe selector shows a visual preview for every selectable style', () {
    final source = File(
      'lib/features/profile/presentation/pages/my_profile_page.dart',
    ).readAsStringSync();

    expect(source, contains("shared/widgets/world_control_visuals.dart"));
    expect(source, contains('WorldAppearanceService.selectableGlobeStyles'));
    expect(source, contains('PremiumGlobePreview('));
    expect(source, contains('style: style,'));
    expect(source, contains('size: 54,'));
    expect(WorldAppearanceService.selectableGlobeStyles, hasLength(6));
  });

  test('Globe sheet does not retain BuildContext across its async load', () {
    final source = File(
      'lib/features/profile/presentation/pages/my_profile_page.dart',
    ).readAsStringSync();

    final globeBlock = _functionBlock(
      source,
      'Future<void> _showGlobeStyleSheet() async',
      'Future<void> _openAccountSection({',
    );

    expect(globeBlock, isNot(contains('BuildContext? sourceContext')));
    expect(globeBlock, isNot(contains('final hostContext =')));
    expect(globeBlock, contains('await appearance.ensureLoaded();'));
    expect(globeBlock, contains('if (!mounted) return;'));
    expect(globeBlock, contains('context: context,'));
  });

  test('unrelated sourceContext helpers remain allowed outside Globe sheet', () {
    final source = File(
      'lib/features/profile/presentation/pages/my_profile_page.dart',
    ).readAsStringSync();

    expect(source, contains('_showAppLanguageSheet([BuildContext? sourceContext])'));
    expect(source, contains('_showAppearanceModeSheet([BuildContext? sourceContext])'));
  });

  test('public profile card uses compact edit action instead of full-width button', () {
    final source = File(
      'lib/features/profile/presentation/pages/my_profile_page.dart',
    ).readAsStringSync();

    final marker = source.indexOf('ACCOUNT_PROFILE_COMPACT_HEADER_V1_0_1');
    final workspace = source.indexOf('FutureBuilder<OrganizationContext?>', marker);
    expect(marker, greaterThanOrEqualTo(0));
    expect(workspace, greaterThan(marker));

    final profileBlock = source.substring(marker, workspace);
    expect(profileBlock, contains('IconButton('));
    expect(profileBlock, contains('tooltip: l10n.profileEditPageTitle'));
    expect(profileBlock, isNot(contains('OutlinedButton.icon(')));
    expect(profileBlock, contains('size: 60,'));
    expect(profileBlock, contains('Divider('));
  });
}
