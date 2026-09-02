import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('WebGL route lifecycle pauses renderer behind inactive Flutter routes',
      () {
    final dartSource = File(
      'lib/features/map/presentation/widgets/web_world_globe_surface_web.dart',
    ).readAsStringSync();
    final jsSource = File('web/social_vote_globe.js').readAsStringSync();

    expect(dartSource, contains('TickerMode.valuesOf(context).enabled'));
    expect(dartSource, isNot(contains('TickerMode.of(context)')));
    expect(dartSource, contains('ModalRoute.of(context)?.isCurrent'));
    expect(dartSource, contains("data-route-active"));

    expect(jsSource, contains("'data-route-active'"));
    expect(jsSource, contains('!this.isConnected'));
    expect(jsSource, contains('!this._routeActive'));
    expect(jsSource, contains('this._routeActive &&'));
    expect(jsSource, isNot(contains('forceContextLoss')));
  });
}
