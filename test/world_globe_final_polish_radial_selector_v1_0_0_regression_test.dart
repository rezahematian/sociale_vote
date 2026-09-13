import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/shared/services/world_appearance_service.dart';

void main() {
  test('Elias and Elena are fixed branded globe names', () {
    expect(
      WorldAppearanceService.brandedGlobeName(GlobeVisualStyle.nightLights),
      'Elias',
    );
    expect(
      WorldAppearanceService.brandedGlobeName(GlobeVisualStyle.techNeon),
      'Elena',
    );
  });

  test('radial selector and long press contracts exist on native and Web', () {
    final globe = File(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    ).readAsStringSync();
    final webSurface = File(
      'lib/features/map/presentation/widgets/web_world_globe_surface_web.dart',
    ).readAsStringSync();
    final webRuntime = File('web/social_vote_globe.js').readAsStringSync();

    expect(globe, contains('_GlobeStyleRadialPicker'));
    expect(globe, contains('_styleLongPressDuration'));
    expect(globe, contains('onSurfaceLongPress: _openGlobeStylePicker'));
    expect(webSurface, contains('socialvote-surface-long-press'));
    expect(webRuntime, contains("'socialvote-surface-long-press'"));
    expect(webRuntime, contains('_scheduleLongPress'));
  });

  test('Web and native preset texture families are aligned', () {
    final webSurface = File(
      'lib/features/map/presentation/widgets/web_world_globe_surface_web.dart',
    ).readAsStringSync();
    final globe = File(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    ).readAsStringSync();

    expect(webSurface, contains('GlobePresetVisual.forName(widget.visualStyle)'));
    expect(globe, contains('GlobePresetVisual.forStyle(style).asset'));
    for (final style in WorldAppearanceService.selectableGlobeStyles) {
      final preset = GlobePresetVisual.forStyle(style);
      expect(preset.webAppearance(style.name)['textureUrl'],
          'assets/${preset.asset}');
    }
    expect(globe, contains('_isHomeProfile ? 0.0080 : _nativeApprovedRotationSpeed'));
  });

  test('Home brand remains static and only slightly larger', () {
    final brand = File(
      'lib/shared/widgets/social_vote_brand_lockup.dart',
    ).readAsStringSync();
    final topBar = File(
      'lib/features/home/presentation/widgets/home_top_bar.dart',
    ).readAsStringSync();

    expect(brand, contains('this.height = 48'));
    expect(brand, contains('One static, canonical lockup'));
        expect(topBar, contains('SocialVoteHeaderBrand(height: 50)'));
    expect(topBar, contains('const height = 38.0;'));
    expect(topBar, contains('_buildGuestUtilityActions(size: 38)'));
    expect(topBar, contains('guestUtilityActions.isNotEmpty'));
    expect(topBar, contains('children: guestUtilityActions'));
    expect(topBar, contains('child: guestAuthActions'));
  });
}
