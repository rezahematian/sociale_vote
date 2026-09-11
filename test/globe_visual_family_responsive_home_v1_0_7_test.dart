import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_top_bar.dart';
import 'package:sociale_vote/features/map/presentation/widgets/world_globe_widget.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/world_appearance_service.dart';
import 'package:sociale_vote/shared/widgets/social_vote_brand_lockup.dart';
import 'package:sociale_vote/shared/widgets/world_control_visuals.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('six stable IDs have the requested names and the same source on Web', () {
    const names = ['Natural', 'Relief', 'Civic Blue', 'Elias', 'Elena', 'Satellite'];
    const codes = ['A', 'B', 'C', 'D', 'E', 'F'];
    const assets = [
      GlobePresetVisual.dayAsset, GlobePresetVisual.satelliteAsset,
      GlobePresetVisual.satelliteAsset, GlobePresetVisual.nightAsset,
      GlobePresetVisual.dayAsset, GlobePresetVisual.satelliteAsset,
    ];
    const styles = WorldAppearanceService.selectableGlobeStyles;
    expect(styles, hasLength(6));
    for (var i = 0; i < styles.length; i++) {
      final preset = GlobePresetVisual.forStyle(styles[i]);
      expect(preset.name, names[i]);
      expect(preset.code, codes[i]);
      expect(preset.asset, assets[i]);
      expect(File(preset.asset).existsSync(), isTrue);
      final web = preset.webAppearance(styles[i].name);
      expect(web['textureUrl'], 'assets/${assets[i]}');
      final material = web['material']! as Map<String, Object?>;
      expect(material['atmosphereColor'], preset.atmosphereRgb);
      expect(material['atmosphereStrength'], preset.atmosphereOpacity);
      expect(material['emissive'], 0xFFFFFF);
    }
    final elias = GlobePresetVisual.forStyle(GlobeVisualStyle.nightLights);
    expect(elias.unlit, isTrue);
    expect(elias.webEmissiveIntensity, 1);
    final elena = GlobePresetVisual.forStyle(GlobeVisualStyle.techNeon);
    expect(elena.unlit, isFalse);
    expect(elena.asset, isNot(elias.asset));
    expect(elena.atmosphereRgb,
        isNot(GlobePresetVisual.forStyle(GlobeVisualStyle.bright).atmosphereRgb));
  });

  test('Home and Civic Map observe the same stored preference in both directions', () async {
    SharedPreferences.setMockInitialValues({});
    final home = WorldAppearanceService.instance;
    final civic = WorldAppearanceService.instance;
    await home.ensureLoaded();
    final observed = <GlobeVisualStyle>[];
    void listener() => observed.add(civic.globeStyle);
    civic.addListener(listener);
    try {
      await home.setGlobeStyle(GlobeVisualStyle.techNeon);
      expect(civic.globeStyle, GlobeVisualStyle.techNeon);
      await civic.setGlobeStyle(GlobeVisualStyle.nightLights);
      expect(home.globeStyle, GlobeVisualStyle.nightLights);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('world_appearance_globe_v1'), 'nightLights');
      expect(observed, [GlobeVisualStyle.techNeon, GlobeVisualStyle.nightLights]);
      expect(prefs.getKeys(), {'world_appearance_globe_v1'});
    } finally {
      civic.removeListener(listener);
      await home.reset();
    }
  });

  for (final width in [320.0, 360.0, 390.0, 412.0, 750.0]) {
    test('Home geometry at $width keeps controls outside the sphere', () {
      final padding = width < 480 ? 16.0 : 30.0;
      final contentWidth = width - 2 * padding;
      final height = width < 720 ? 328.0 : 398.0;
      final frame = WorldHomeGlobeGeometry.frameSize(contentWidth, height);
      final diameter = WorldHomeGlobeGeometry.sphereDiameter(contentWidth, frame);
      final canvas = diameter / WorldHomeGlobeGeometry.webSphereFraction;
      expect(canvas, lessThanOrEqualTo(frame));
      expect(diameter, inInclusiveRange(218, 390));
      const controlRadius = WorldHomeGlobeGeometry.controlSize / 2;
      final offset = frame / 2 - WorldHomeGlobeGeometry.controlInset - controlRadius;
      final distance = math.sqrt(2 * offset * offset);
      // Also leave room for the native Home's approved maximum zoom.
      expect(distance - controlRadius - diameter / 2 * 1.08, greaterThan(6));
      expect((contentWidth - frame) / 2 + frame / 2 + padding, width / 2);
    });
  }

  test('V1.0.8 Home Globe is modestly larger without becoming oversized', () {
    final mobileFrame = WorldHomeGlobeGeometry.frameSize(328.0, 328.0);
    final mobileDiameter =
        WorldHomeGlobeGeometry.sphereDiameter(328.0, mobileFrame);
    expect(mobileDiameter, inInclusiveRange(235.0, 238.0));

    final narrowWebFrame = WorldHomeGlobeGeometry.frameSize(700.0, 500.0);
    final narrowWebDiameter =
        WorldHomeGlobeGeometry.sphereDiameter(700.0, narrowWebFrame);
    expect(narrowWebDiameter, greaterThan(360.0));
    expect(narrowWebDiameter, lessThanOrEqualTo(390.0));
  });

  for (final diameter in [236.0, 276.0, 316.0, 346.0, 386.0, 548.0]) {
    testWidgets('radial at $diameter fits and selects Elena with one tap', (tester) async {
      GlobeVisualStyle? selected;
      var dismissed = false;
      var open = true;
      await tester.pumpWidget(MaterialApp(home: Center(
        child: SizedBox.square(dimension: diameter, child: StatefulBuilder(
          builder: (context, setState) => open
              ? worldGlobeStylePickerForTest(
                  selectedStyle: GlobeVisualStyle.classic,
                  diameter: diameter,
                  onSelected: (value) => setState(() { selected = value; open = false; }),
                  onDismiss: () => setState(() { dismissed = true; open = false; }),
                )
              : const Text('Home remains open'),
        )),
      )));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final previews = find.byType(PremiumGlobePreview);
      expect(previews, findsNWidgets(6));
      final center = tester.getCenter(find.byType(StatefulBuilder));
      final bounds = Rect.fromCenter(center: center, width: diameter, height: diameter);
      for (var i = 0; i < 6; i++) {
        final preview = tester.getRect(previews.at(i));
        expect(bounds.contains(preview.topLeft), isTrue);
        expect(bounds.contains(preview.bottomRight), isTrue);
      }
      await tester.tap(find.text('Elena'));
      await tester.pumpAndSettle();
      expect(selected, GlobeVisualStyle.techNeon);
      expect(dismissed, isFalse);
      expect(find.text('Home remains open'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Radio and Rotate share size, shape and independent actions', (tester) async {
    var radioTaps = 0;
    var rotateTaps = 0;
    await tester.pumpWidget(MaterialApp(home: Center(child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        WorldRoundControl(icon: Icons.radio_rounded, label: 'Radio', active: false,
          globeStyle: GlobeVisualStyle.techNeon,
          visualStyle: GlobeRotationVisualStyle.classic,
          onTap: () => radioTaps++),
        WorldRoundControl(icon: Icons.rotate_right_rounded, label: 'Rotate', active: false,
          globeStyle: GlobeVisualStyle.techNeon,
          visualStyle: GlobeRotationVisualStyle.classic,
          onTap: () => rotateTaps++),
      ],
    ))));
    final controls = find.byType(WorldRoundControl);
    expect(tester.getSize(controls.at(0)), const Size(48, 48));
    expect(tester.getSize(controls.at(1)), const Size(48, 48));
    final icons = tester.widgetList<Icon>(find.descendant(of: controls, matching: find.byType(Icon))).toList();
    expect(icons.map((icon) => icon.size), everyElement(24));
    await tester.tap(controls.at(0));
    expect(radioTaps, 1);
    expect(rotateTaps, 0);
    await tester.tap(controls.at(1));
    expect(rotateTaps, 1);
  });

  for (final width in [360.0, 390.0, 412.0, 750.0, 1280.0]) {
    for (final language in ['it', 'fa', 'ar', 'zh']) {
      for (final loggedIn in [false, true]) {
        testWidgets('one static header at $width / $language / login=$loggedIn', (tester) async {
          tester.view.physicalSize = Size(width, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(MaterialApp(
            locale: Locale(language),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Directionality(
              textDirection: TextDirection.ltr,
              child: Scaffold(
                appBar: AppBar(
                  toolbarHeight: 74,
                  titleSpacing: 16,
                  title: HomeTopBar(
                    scopeShortLabel: 'World',
                    isLoggedIn: loggedIn,
                    unreadNotificationsCount: 0,
                    onLoginPressed: () {},
                    onRegisterPressed: () {},
                    onProfilePressed: () {},
                    onLogoutPressed: () {},
                    onDiscoveryPressed: () {},
                    onHowItWorksPressed: () {},
                    onNotificationsPressed: () {},
                  ),
                ),
                body: const SizedBox.shrink(),
              ),
            ),
          ));

          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.byType(SocialVoteHeaderBrand), findsOneWidget);

          final appBarRect = tester.getRect(find.byType(AppBar));
          final brandRect = tester.getRect(find.byType(SocialVoteHeaderBrand));
          expect(appBarRect.overlaps(brandRect), isTrue);

          if (!loggedIn) {
            final login = find.byType(OutlinedButton);
            final register = find.byType(FilledButton);
            expect(login, findsOneWidget);
            expect(register, findsOneWidget);

            final loginRect = tester.getRect(login);
            final registerRect = tester.getRect(register);
            expect((loginRect.center.dy - registerRect.center.dy).abs(), lessThan(1.0));
            expect(appBarRect.overlaps(loginRect), isTrue);
            expect(appBarRect.overlaps(registerRect), isTrue);
          } else {
            expect(find.byType(OutlinedButton), findsNothing);
            expect(find.byType(FilledButton), findsNothing);
          }
        });
      }
    }
  }

  test('call sites preserve shared state, speeds and the Web tap guard', () {
    String source(String path) => File(path).readAsStringSync();
    final home = source('lib/features/home/presentation/pages/public_home_screen.dart');
    expect(home, contains('appBarToolbarHeight = 74.0;'));
    expect(home, isNot(contains('104.0')));

    final globe = source('lib/features/map/presentation/widgets/world_globe_widget.dart');
    expect(globe, contains('_isHomeProfile ? 0.0080 : _nativeApprovedRotationSpeed'));
    expect(globe, contains('_nativeApprovedRotationSpeed = 0.0065'));
    expect(globe, contains('Duration(milliseconds: 420)'));
    expect(globe, contains('onSurfaceLongPress: _openGlobeStylePicker'));
    expect(globe, contains('WorldRoundControl('));
    expect(source('lib/shared/widgets/radio_mondo_dock.dart'), contains('WorldRoundControl('));
    for (final file in [
      'lib/features/home/presentation/widgets/home_map_section.dart',
      'lib/features/map/presentation/pages/civic_map_page.dart',
    ]) {
      expect(source(file), contains('animation: WorldAppearanceService.instance'));
      expect(source(file), contains('visualStyle: appearance.globeStyle'));
    }
  });
}
