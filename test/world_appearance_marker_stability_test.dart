import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/features/map/application/civic_map_controller.dart';
import 'package:sociale_vote/shared/services/world_appearance_service.dart';

void main() {
  group('world appearance', () {
    test('exposes the approved independent style counts', () {
      expect(GlobeVisualStyle.values, hasLength(6));
      expect(RadioVisualStyle.values, hasLength(7));
      expect(GlobeRotationVisualStyle.values, hasLength(7));
    });
  });

  group('live marker stability', () {
    test('manual refresh keeps the stable snapshot until all sources settle',
        () async {
      final world = GeoScope.world();
      var refreshing = false;

      late Completer<List<CivicMapItem>> pollRefresh;
      late Completer<List<CivicMapItem>> postRefresh;
      late Completer<List<CivicMapItem>> newsRefresh;

      final poll = _item(
        id: 'poll-1',
        type: CivicMapItemType.poll,
        latitude: 46.67,
        longitude: 11.16,
      );
      final post = _item(
        id: 'post-1',
        type: CivicMapItemType.post,
        latitude: 45.46,
        longitude: 9.19,
      );
      final news = _item(
        id: 'news-1',
        type: CivicMapItemType.news,
        latitude: 41.90,
        longitude: 12.49,
      );

      final controller = CivicMapController(
        loadPollItems: (_) {
          if (!refreshing) return Future.value([poll]);
          return pollRefresh.future;
        },
        loadPostItems: (_) {
          if (!refreshing) return Future.value([post]);
          return postRefresh.future;
        },
        loadNewsItems: (_) {
          if (!refreshing) return Future.value([news]);
          return newsRefresh.future;
        },
      );
      addTearDown(controller.dispose);

      await controller.loadForScope(world);
      expect(controller.visibleItems, hasLength(3));

      refreshing = true;
      pollRefresh = Completer<List<CivicMapItem>>();
      postRefresh = Completer<List<CivicMapItem>>();
      newsRefresh = Completer<List<CivicMapItem>>();

      final refreshFuture = controller.refresh();
      await Future<void>.delayed(Duration.zero);

      expect(controller.isRefreshing, isTrue);
      expect(controller.visibleItems, hasLength(3));

      pollRefresh.complete(const <CivicMapItem>[]);
      await Future<void>.delayed(Duration.zero);
      expect(
        controller.visibleItems,
        hasLength(3),
        reason: 'one empty source must not blank live markers mid-refresh',
      );

      postRefresh.complete([post]);
      await Future<void>.delayed(Duration.zero);
      expect(controller.visibleItems, hasLength(3));

      newsRefresh.complete(const <CivicMapItem>[]);
      await refreshFuture;

      expect(controller.isRefreshing, isFalse);
      expect(controller.visibleItems, hasLength(1));
      expect(controller.visibleItems.single.id, post.id);
    });

    test(
        'background reload does not wipe a stable snapshot on transient empty results',
        () async {
      final world = GeoScope.world();
      var backgroundReload = false;

      final poll = _item(
        id: 'poll-1',
        type: CivicMapItemType.poll,
        latitude: 46.67,
        longitude: 11.16,
      );
      final post = _item(
        id: 'post-1',
        type: CivicMapItemType.post,
        latitude: 45.46,
        longitude: 9.19,
      );
      final news = _item(
        id: 'news-1',
        type: CivicMapItemType.news,
        latitude: 41.90,
        longitude: 12.49,
      );

      final controller = CivicMapController(
        loadPollItems: (_) => Future.value(
          backgroundReload ? const <CivicMapItem>[] : <CivicMapItem>[poll],
        ),
        loadPostItems: (_) => Future.value(
          backgroundReload ? const <CivicMapItem>[] : <CivicMapItem>[post],
        ),
        loadNewsItems: (_) => Future.value(
          backgroundReload ? const <CivicMapItem>[] : <CivicMapItem>[news],
        ),
      );
      addTearDown(controller.dispose);

      await controller.loadForScope(world);
      expect(controller.visibleItems, hasLength(3));

      backgroundReload = true;
      await controller.loadForScope(world, clearSelection: false);

      expect(
        controller.visibleItems,
        hasLength(3),
        reason:
            'automatic same-scope reload must preserve the last good markers on transient empty results',
      );
      expect(controller.visibleItems.map((item) => item.id).toSet(), {
        poll.id,
        post.id,
        news.id,
      });
    });
  });
}

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
  );
}
