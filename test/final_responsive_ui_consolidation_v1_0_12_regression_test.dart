import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('native globe resolves overlapping marker hits by nearest visible center', () {
    final source = _read(
      'third_party/flutter_earth_globe_social_vote/lib/rotating_globe.dart',
    );

    expect(source, contains('String? nearestPointId;'));
    expect(source, contains('var nearestDistanceSquared = double.infinity;'));
    expect(source, contains('final rendererLocalPosition = localPosition + _viewportToRendererOffset;'));
    expect(source, contains('final hitCenter = point.position2D + point.point.hitTestOffset;'));
    expect(source, contains('final distanceSquared = delta.dx * delta.dx + delta.dy * delta.dy;'));
    expect(source, contains('return nearestPointId;'));
    expect(
      source,
      contains("point.id.startsWith('social-vote:') ? 34.0 : 18.0"),
      reason: 'keep the approved expanded Social Vote touch target',
    );
  });

  test('public profile uses a compact showcase and labelled official channels', () {
    final profile = _read(
      'lib/features/profile/presentation/pages/public_user_profile_page.dart',
    );
    final cover = _read(
      'lib/features/organization/presentation/widgets/organization_cover_header.dart',
    );

    expect(profile, contains('label: l10n.organizationOfficialWebsiteAction'));
    expect(profile, contains('label: link.provider.label'));
    expect(profile, contains('Icons.open_in_new_rounded'));
    expect(profile, contains('color: colors.surfaceContainerLow'));
    expect(profile, contains('size: compact ? 60 : 76'));
    expect(profile, contains('label: l10n.publicProfileResidenceLabel'));
    expect(profile, contains('label: l10n.publicProfileMemberSinceLabel'));
    expect(cover, contains('widget.compact ? 108.0 : 174.0'));
    expect(cover, contains('widget.compact ? 31.0 : 40.0'));
  });

  test('workspace mobile density keeps metrics actions and sessions compact', () {
    final source = _read(
      'lib/features/organization/presentation/pages/organization_workspace_page.dart',
    );

    expect(source, contains('constraints.maxWidth >= 320'));
    expect(source, contains('compact: columns == 2 && constraints.maxWidth < 520'));
    expect(source, contains('final compact = MediaQuery.sizeOf(context).width < 600;'));
    expect(source, contains('alignment: AlignmentDirectional.centerEnd'));
    expect(source, contains('minimumSize: Size(0, compact ? 36 : 40)'));
    expect(source, contains('final compact = constraints.maxWidth < 600;'));
    expect(source, contains('class _SessionMetaPill extends StatelessWidget'));
  });

  test('Vote and Voce detail compact widths reduce mobile visual bulk only', () {
    final pollPage = _read(
      'lib/features/poll/presentation/pages/poll_detail_page.dart',
    );
    final pollHeader = _read(
      'lib/features/poll/presentation/widgets/poll_detail_header.dart',
    );
    final postPage = _read(
      'lib/features/social/presentation/pages/post_detail_page.dart',
    );

    expect(pollPage, contains('SizedBox(height: isCompactLayout ? 12 : 20)'));
    expect(pollPage, contains('isCompactLayout ? 12 : AppSpacing.l'));
    expect(pollHeader, contains('fontSize: isMobileLayout ? 21.0'));
    expect(pollHeader, contains('height: isMobileLayout ? 1.38 : 1.48'));
    expect(postPage, contains('final isPhoneWidth = MediaQuery.sizeOf(context).width < 600;'));
    expect(postPage, contains('maxWidth: isCompact'));
    expect(postPage, contains('? constraints.maxWidth * 0.54'));
    expect(postPage, contains('height: isCompact ? 1.48 : 1.56'));
  });
}
