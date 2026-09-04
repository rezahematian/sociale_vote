import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/shared/services/world_appearance_service.dart';

void main() {
  test('world appearance defaults remain curated', () {
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
      GlobeRotationVisualStyle.classic,
    );
  });

  test('selectable globe styles include terrain relief and exclude legacy day',
      () {
    expect(
      WorldAppearanceService.selectableGlobeStyles,
      equals(<GlobeVisualStyle>[
        GlobeVisualStyle.classic,
        GlobeVisualStyle.realistic,
        GlobeVisualStyle.bright,
        GlobeVisualStyle.nightLights,
        GlobeVisualStyle.techNeon,
        GlobeVisualStyle.terrainRelief,
      ]),
    );
    expect(
      WorldAppearanceService.selectableGlobeStyles,
      isNot(contains(GlobeVisualStyle.minimalDay)),
    );
  });
}
