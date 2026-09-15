import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('native external hit testing maps viewport coordinates into renderer', () {
    final source = _read(
      'third_party/flutter_earth_globe_social_vote/lib/rotating_globe.dart',
    );

    expect(source, contains('Offset _viewportToRendererOffset = Offset.zero;'));
    expect(source, contains('left - panOffsetX'));
    expect(source, contains('top - panOffsetY'));
    expect(
      source,
      contains(
        'final rendererLocalPosition = localPosition + _viewportToRendererOffset;',
      ),
    );
    expect(source, contains('String? nearestPointId;'));
  });

  test('Home native globe avoids passive marker-focus recovery while rotating', () {
    final source = _read(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    );

    expect(source, isNot(contains('_homeMarkerVisibilityCheckInterval')));
    expect(source, isNot(contains('_homeMarkerHiddenGrace')));
    expect(source, isNot(contains('_homeMarkerRecoveryCooldown')));
    expect(source, isNot(contains('void _recoverHomeMarkersIfNeeded()')));
    expect(source, contains('Timer? _homeRouteReturnWatchTimer;'));
    expect(source, contains('onOpen: _openHomeMarkerDetail,'));
    expect(source, contains('_lastNativeMarkerInputSignature = null;'));
    expect(source, contains('_syncGlobeContentPoints();'));
  });

  test('Voce compact detail keeps publisher and dates in one header row', () {
    final source = _read(
      'lib/features/social/presentation/pages/post_detail_page.dart',
    );

    expect(source, contains('maxWidth: isCompact'));
    expect(source, contains('? constraints.maxWidth * 0.54'));
    expect(source, contains('maxWidth: isCompact ? 156 : 240'));
    expect(source, contains('FittedBox('));
  });

  test('Vote compact detail removes duplicate time rule and tightens options', () {
    final header = _read(
      'lib/features/poll/presentation/widgets/poll_detail_header.dart',
    );
    final page = _read(
      'lib/features/poll/presentation/pages/poll_detail_page.dart',
    );

    expect(header, contains('height: 28'));
    expect(header, contains('fontSize: 10.75'));
    expect(header, contains('fontSize: isMobileLayout ? 21.0'));
    expect(header, contains('if (isMobileLayout)'));
    expect(header, isNot(contains('if (timeWindowLabel != null) timeWindowLabel,\n          if (verificationRequirementLabel')));
    expect(page, contains('isCompactLayout ? 12 : AppSpacing.l'));
    expect(page, contains('minHeight: isPhoneWidth ? 52 : 68'));
    expect(page, contains('vertical: isPhoneWidth ? 7 : 14'));
  });

  test('public follow controls and workspace CTAs use restrained pills', () {
    final profile = _read(
      'lib/features/profile/presentation/pages/public_user_profile_page.dart',
    );
    final workspace = _read(
      'lib/features/organization/presentation/pages/organization_workspace_page.dart',
    );

    expect(profile, contains('borderRadius: BorderRadius.circular(999)'));
    expect(profile, contains('if (compact) {'));
    expect(profile, contains('Flexible(child: action)'));
    expect(profile, contains('AlignmentDirectional.centerEnd'));
    expect(workspace, contains('alignment: AlignmentDirectional.centerEnd'));
    expect(workspace, contains('minimumSize: Size(0, compact ? 36 : 40)'));
    expect(workspace, isNot(contains('width: double.infinity,\n                  child: FilledButton.tonalIcon(')));
  });
}
