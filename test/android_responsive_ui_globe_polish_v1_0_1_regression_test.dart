import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/shared/services/world_appearance_service.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('narrow guest header keeps utility actions beside the brand', () {
    final source = _read(
      'lib/features/home/presentation/widgets/home_top_bar.dart',
    );

    final narrowStart = source.indexOf('if (constraints.maxWidth < 430)');
    final wideStart = source.indexOf('return Row(', narrowStart + 1);
    expect(narrowStart, greaterThanOrEqualTo(0));
    expect(wideStart, greaterThan(narrowStart));

    final narrowBlock = source.substring(narrowStart, wideStart);
    expect(narrowBlock, contains('guestUtilityActions.isNotEmpty'));
    expect(narrowBlock, contains('children: guestUtilityActions'));
    expect(narrowBlock, contains('child: guestAuthActions'));
    expect(
      narrowBlock.indexOf('children: guestUtilityActions'),
      lessThan(narrowBlock.indexOf('child: guestAuthActions')),
    );
  });

  test('Vote and Voce list controls use compact responsive mobile groups', () {
    final vote = _read(
      'lib/features/poll/presentation/pages/poll_list_page.dart',
    );
    final voce = _read(
      'lib/features/social/presentation/pages/social_feed_page.dart',
    );

    expect(vote, contains('if (constraints.maxWidth < 560)'));
    expect(vote, contains('_buildCompactFilterRow('));
    expect(vote, contains('compact: true'));
    expect(vote, contains('AlignmentDirectional.centerEnd'));
    expect(
      vote,
      contains('constraints.maxWidth >= _singleRowFiltersMinWidth'),
      reason: 'wide Web filter layout must remain available',
    );

    expect(voce, contains('final compactFilters = Row('));
    expect(voce, contains('compact: true'));
    expect(voce, contains('AlignmentDirectional.centerEnd'));
    expect(
      voce,
      contains('constraints.maxWidth >= _singleRowMinWidth'),
      reason: 'wide Web toolbar layout must remain available',
    );
  });

  test('public profile and Account organization actions are compact on mobile',
      () {
    final publicProfile = _read(
      'lib/features/profile/presentation/pages/public_user_profile_page.dart',
    );
    final account = _read(
      'lib/features/profile/presentation/pages/my_profile_page.dart',
    );

    expect(
        publicProfile, contains('final compact = constraints.maxWidth < 560'));
    expect(publicProfile, contains('compact: compact'));
    expect(publicProfile, contains('...actions'));
    expect(publicProfile, contains('compact ? 34 : 38'));

    expect(account, contains('margin: EdgeInsets.zero'));
    expect(account, contains('constraints.maxWidth >= 340'));
    expect(account, contains('Expanded(child: actions[0])'));
    expect(account, contains('Expanded(child: actions[1])'));
  });

  test('Civic Map keeps compact filters in one horizontal mobile strip', () {
    final source = _read(
      'lib/features/map/presentation/pages/civic_map_page.dart',
    );

    expect(source, contains('horizontal: constraints.maxWidth < 440'));
    expect(source, contains('final bool horizontal'));
    expect(source, contains('if (horizontal)'));
    expect(source, contains('scrollDirection: Axis.horizontal'));
    expect(source, contains('children: chips'));
  });

  test(
      'native bright Globe uses high resolution texture and faster gesture handoff',
      () {
    final source = _read(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    );

    expect(
      source,
      contains('GlobePresetVisual.forStyle(style).asset'),
    );
    expect(source, contains('_approvedPanSensitivity = 0.58'));
    expect(source, contains('_gestureIntentThreshold = 7.0'));
    expect(source, contains('_gestureFallbackThreshold = 16.0'));
    expect(source, contains('_axisDominance = 1.08'));
  });

  test(
      'Web Globe preserves high-resolution appearance mapping and desktop renderer while improving touch',
      () {
    final source = _read('web/social_vote_globe.js');
    final webSurface = _read(
      'lib/features/map/presentation/widgets/web_world_globe_surface_web.dart',
    );

    // The JS renderer intentionally consumes appearance.textureUrl and keeps a
    // 2048 local fallback. The authoritative Web 4096 texture is supplied by
    // the Flutter Web surface; guard that contract instead of requiring the
    // 4096 filename to be duplicated in the JS implementation.
    expect(
        source, contains('const configuredDay = this._appearance.textureUrl;'));
    expect(
      GlobePresetVisual.forStyle(GlobeVisualStyle.bright).asset,
      'assets/globe/earth_day_nasa_bmng_august_4096.jpg',
      reason: 'Both renderers retain the high-resolution Earth source',
    );
    expect(
        webSurface, contains('GlobePresetVisual.forName(widget.visualStyle)'));
    expect(
      source,
      contains('Math.min(window.devicePixelRatio || 1, 2.0)'),
      reason: 'do not raise Web DPR and destabilize the existing desktop gate',
    );
    expect(source, contains("powerPreference: 'default'"));
    expect(
      source,
      contains("this._config.profile === 'home'"),
    );
    expect(source, contains("? 'pan-y'"));
    expect(source, contains('isTouch ? 0.32 : 0.38'));
    expect(source, contains('isTouch ? 0.46 : 0.52'));
  });
}
