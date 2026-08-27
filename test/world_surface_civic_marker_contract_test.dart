import 'package:flutter_test/flutter_test.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/features/map/application/civic_map_controller.dart';

CivicMapItem _item({
  required String id,
  required CivicMapItemType type,
  required double latitude,
  required double longitude,
}) {
  final targetRef = switch (type) {
    CivicMapItemType.poll => TargetRef.poll(id),
    CivicMapItemType.post => TargetRef.post(id),
    CivicMapItemType.news => TargetRef.news(id),
  };

  return CivicMapItem(
    id: id,
    targetRef: targetRef,
    type: type,
    title: id,
    latitude: latitude,
    longitude: longitude,
    createdAt: DateTime.utc(2026, 8, 27),
  );
}

void main() {
  test('single Voce filter keeps the real post marker', () {
    final voce = _item(
      id: 'merano-voce',
      type: CivicMapItemType.post,
      latitude: 46.6713536,
      longitude: 11.1646348,
    );

    final selected = CivicMapMarkerSelectionRules.select(
      items: <CivicMapItem>[voce],
      totalLimit: 24,
      newsLimit: 3,
    );

    expect(selected, hasLength(1));
    expect(selected.single.id, 'merano-voce');
    expect(selected.single.latitude, 46.6713536);
    expect(selected.single.longitude, 11.1646348);
  });

  test('mixed World marker budget retains Vote Voce and News', () {
    final vote = _item(
      id: 'merano-vote',
      type: CivicMapItemType.poll,
      latitude: 46.6713536,
      longitude: 11.1646348,
    );
    final voce = _item(
      id: 'merano-voce',
      type: CivicMapItemType.post,
      latitude: 46.6713536,
      longitude: 11.1646348,
    );
    final news = _item(
      id: 'tehran-news',
      type: CivicMapItemType.news,
      latitude: 35.6892,
      longitude: 51.3890,
    );

    final selected = CivicMapMarkerSelectionRules.select(
      items: <CivicMapItem>[vote, voce, news],
      totalLimit: 9,
      newsLimit: 3,
    );

    expect(selected.map((item) => item.type).toSet(), <CivicMapItemType>{
      CivicMapItemType.poll,
      CivicMapItemType.post,
      CivicMapItemType.news,
    });
  });
}
