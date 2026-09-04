import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/features/map/application/civic_map_controller.dart';
import 'package:sociale_vote/shared/services/world_appearance_service.dart';

void main() {
  group('world appearance', () {
    test('exposes the approved independent style counts', () {
      expect(GlobeVisualStyle.values, hasLength(7));
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

    test(
        'background partial reload keeps missing Poll/Voce until explicit refresh',
        () async {
      final world = GeoScope.world();
      var backgroundPartial = false;

      final pollA = _item(
        id: 'poll-a',
        type: CivicMapItemType.poll,
        latitude: 46.67,
        longitude: 11.16,
      );
      final pollB = _item(
        id: 'poll-b',
        type: CivicMapItemType.poll,
        latitude: 45.46,
        longitude: 9.19,
      );
      final postA = _item(
        id: 'post-a',
        type: CivicMapItemType.post,
        latitude: 41.90,
        longitude: 12.49,
      );
      final postB = _item(
        id: 'post-b',
        type: CivicMapItemType.post,
        latitude: 43.77,
        longitude: 11.25,
      );

      final controller = CivicMapController(
        loadPollItems: (_) => Future.value(
          backgroundPartial
              ? <CivicMapItem>[pollA]
              : <CivicMapItem>[pollA, pollB],
        ),
        loadPostItems: (_) => Future.value(
          backgroundPartial
              ? <CivicMapItem>[postA]
              : <CivicMapItem>[postA, postB],
        ),
        loadNewsItems: (_) => Future.value(const <CivicMapItem>[]),
      );
      addTearDown(controller.dispose);

      await controller.loadForScope(world);
      expect(controller.visibleItems.map((item) => item.id).toSet(), {
        pollA.id,
        pollB.id,
        postA.id,
        postB.id,
      });

      backgroundPartial = true;
      await controller.loadForScope(world, clearSelection: false);

      expect(
        controller.visibleItems.map((item) => item.id).toSet(),
        {pollA.id, pollB.id, postA.id, postB.id},
        reason:
            'automatic partial responses must not make stable civic markers vanish',
      );

      await controller.refresh();
      expect(
        controller.visibleItems.map((item) => item.id).toSet(),
        {pollA.id, postA.id},
        reason:
            'manual refresh remains authoritative and may clean stale items',
      );
    });
  });
  group('marker selection grammar', () {
    test('mixed Home budget keeps News Vote and Voce represented', () {
      final items = <CivicMapItem>[
        for (var i = 0; i < 8; i++)
          _item(
            id: 'poll-$i',
            type: CivicMapItemType.poll,
            latitude: 40 + i.toDouble(),
            longitude: 10,
          ),
        for (var i = 0; i < 8; i++)
          _item(
            id: 'post-$i',
            type: CivicMapItemType.post,
            latitude: 30 + i.toDouble(),
            longitude: 20,
          ),
        for (var i = 0; i < 8; i++)
          _item(
            id: 'news-$i',
            type: CivicMapItemType.news,
            latitude: 20 + i.toDouble(),
            longitude: 30,
          ),
      ];

      final selected = CivicMapMarkerSelectionRules.select(
        items: items,
        totalLimit: 9,
        newsLimit: 3,
      );

      expect(selected, hasLength(9));
      expect(
        selected.where((item) => item.type == CivicMapItemType.news),
        hasLength(3),
      );
      expect(
        selected.where((item) => item.type == CivicMapItemType.poll),
        isNotEmpty,
      );
      expect(
        selected.where((item) => item.type == CivicMapItemType.post),
        isNotEmpty,
      );
    });

    test('single Civic Map filter can use the whole marker budget', () {
      final news = <CivicMapItem>[
        for (var i = 0; i < 12; i++)
          _item(
            id: 'news-$i',
            type: CivicMapItemType.news,
            latitude: i.toDouble(),
            longitude: i.toDouble(),
          ),
      ];

      final selected = CivicMapMarkerSelectionRules.select(
        items: news,
        totalLimit: 9,
        newsLimit: 3,
      );

      expect(selected, hasLength(9));
      expect(
          selected.every((item) => item.type == CivicMapItemType.news), isTrue);
    });

    test('importance resolves to only three visual size tiers', () {
      expect(
        CivicMapImportanceRules.resolveMarkerSizeTier(0),
        CivicMapMarkerSizeTier.small,
      );
      expect(
        CivicMapImportanceRules.resolveMarkerSizeTier(28),
        CivicMapMarkerSizeTier.medium,
      );
      expect(
        CivicMapImportanceRules.resolveMarkerSizeTier(58),
        CivicMapMarkerSizeTier.large,
      );
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
