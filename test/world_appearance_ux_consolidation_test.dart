import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sociale_vote/features/profile/presentation/pages/world_appearance_settings_page.dart';
import 'package:sociale_vote/shared/services/world_appearance_service.dart';
import 'package:sociale_vote/shared/widgets/world_control_visuals.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('release appearance choices are curated and defaults are intentional', () {
    expect(
      WorldAppearanceService.selectableGlobeStyles,
      equals(const <GlobeVisualStyle>[
        GlobeVisualStyle.classic,
        GlobeVisualStyle.realistic,
        GlobeVisualStyle.bright,
        GlobeVisualStyle.nightLights,
        GlobeVisualStyle.techNeon,
      ]),
    );
    expect(WorldAppearanceService.selectableGlobeStyles, hasLength(5));
    expect(WorldAppearanceService.selectableRadioStyles, hasLength(4));
    expect(WorldAppearanceService.selectableRotationStyles, hasLength(4));

    expect(
      WorldAppearanceService.defaultGlobeStyle,
      GlobeVisualStyle.bright,
    );
    expect(
      WorldAppearanceService.defaultRadioStyle,
      RadioVisualStyle.oldStyle,
    );
    expect(
      WorldAppearanceService.defaultRotationStyle,
      GlobeRotationVisualStyle.minimal,
    );

    expect(
      WorldAppearanceService.selectableGlobeStyles,
      contains(GlobeVisualStyle.nightLights),
    );
    expect(
      WorldAppearanceService.selectableGlobeStyles,
      isNot(contains(GlobeVisualStyle.minimalDay)),
    );
  });

  test('selected appearance is stored locally and reset returns new defaults',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final appearance = WorldAppearanceService.instance;
    await appearance.ensureLoaded();

    expect(appearance.globeStyle, WorldAppearanceService.defaultGlobeStyle);
    expect(appearance.radioStyle, WorldAppearanceService.defaultRadioStyle);
    expect(
      appearance.rotationStyle,
      WorldAppearanceService.defaultRotationStyle,
    );

    await appearance.setGlobeStyle(GlobeVisualStyle.nightLights);
    await appearance.setRadioStyle(RadioVisualStyle.woodMinimal);
    await appearance.setRotationStyle(GlobeRotationVisualStyle.premium);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('world_appearance_globe_v1'), 'nightLights');
    expect(prefs.getString('world_appearance_radio_v1'), 'woodMinimal');
    expect(prefs.getString('world_appearance_rotation_v1'), 'premium');

    await appearance.reset();
    expect(appearance.globeStyle, GlobeVisualStyle.bright);
    expect(appearance.radioStyle, RadioVisualStyle.oldStyle);
    expect(appearance.rotationStyle, GlobeRotationVisualStyle.minimal);
    expect(prefs.getString('world_appearance_globe_v1'), isNull);
    expect(prefs.getString('world_appearance_radio_v1'), isNull);
    expect(prefs.getString('world_appearance_rotation_v1'), isNull);
  });

  testWidgets('settings page is compacted to five globe and four control choices',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      const MaterialApp(
        home: WorldAppearanceSettingsPage(),
      ),
    );
    await tester.pumpAndSettle();

    // One live preview plus the selectable cards.
    expect(find.byType(PremiumGlobePreview), findsNWidgets(6));
    expect(find.byType(PremiumRadioControlVisual), findsNWidgets(5));
    expect(find.byType(PremiumRotationPreview), findsNWidgets(5));

    expect(find.textContaining('Modern'), findsWidgets);
    expect(find.textContaining('Night'), findsWidgets);
  });
}
