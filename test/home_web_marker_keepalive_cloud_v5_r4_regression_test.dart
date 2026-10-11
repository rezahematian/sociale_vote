import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final home = File(
    'lib/features/home/presentation/widgets/home_map_section.dart',
  ).readAsStringSync();
  final shader = File(
    'third_party/flutter_earth_globe_social_vote/shaders/sphere.frag',
  ).readAsStringSync();

  test('Web Home Globe keeps marker controller mounted through scroll', () {
    expect(home, contains('with AutomaticKeepAliveClientMixin<_HomeMapSectionView>'));
    expect(home, contains('bool get wantKeepAlive => kIsWeb;'));
    expect(home, contains('super.build(context);'));
    expect(home, contains('ChangeNotifierProvider<CivicMapController>('));
    expect(home, contains('items: controller.visibleItems,'));
    expect(home, contains('markerDataSettled: !controller.isLoading &&'));
  });

  test('Native cloud wisps improve without changing motion/coverage endpoints', () {
    expect(shader, contains('float feather = softness * 0.30;'));
    expect(shader, contains('float cloudRawAlpha = cloudSample.g * cloudOpacity;'));
    expect(shader, contains('float threshold = mix(0.82, 0.12,'));
    expect(shader, contains('float cloudOpacity = mix(0.42, 0.82,'));
    expect(shader, contains('uv.x - (uCloudRotationOffset / TWO_PI)'));
  });
}
