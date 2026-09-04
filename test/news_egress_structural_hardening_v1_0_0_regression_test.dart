import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/shared/services/egress_policy_service.dart';

String _segment(String source, String startMarker, String endMarker) {
  final start = source.indexOf(startMarker);
  final end = source.indexOf(endMarker, start + startMarker.length);
  expect(start, greaterThanOrEqualTo(0), reason: 'Missing $startMarker');
  expect(end, greaterThan(start), reason: 'Missing $endMarker');
  return source.substring(start, end);
}

void main() {
  test('news memory cache TTLs protect large payloads from rapid refetch', () {
    expect(
      EgressPolicyService.newsMemoryCacheTtlFor(EgressMode.normal),
      const Duration(minutes: 30),
    );
    expect(
      EgressPolicyService.newsMemoryCacheTtlFor(EgressMode.conservative),
      const Duration(hours: 2),
    );
    expect(
      EgressPolicyService.newsMemoryCacheTtlFor(EgressMode.emergency),
      const Duration(hours: 6),
    );
  });

  test('Flutter fallback selects metadata before one exact payload read', () {
    final source = File(
      'lib/infrastructure/news/repositories/news_repository_impl.dart',
    ).readAsStringSync();

    final metadataScan = _segment(
      source,
      '// NEWS_EGRESS_V1_METADATA_SCAN_START',
      '// NEWS_EGRESS_V1_METADATA_SCAN_END',
    );

    expect(metadataScan, contains('cache_key, country_code, city_id, topic, language'));
    expect(metadataScan, contains('refreshed_at, item_count, resolved_location_count'));
    expect(metadataScan, isNot(contains("'payload")));

    final fallbackMethodStart = source.indexOf(
      'Future<_CachedNewsFeed?> _readBestFallbackCacheRemote',
    );
    final fallbackMethodEnd = source.indexOf(
      '_CachedNewsFeed? _buildCachedNewsFeedFromRow',
      fallbackMethodStart,
    );
    expect(fallbackMethodStart, greaterThanOrEqualTo(0));
    expect(fallbackMethodEnd, greaterThan(fallbackMethodStart));
    final fallbackMethod = source.substring(fallbackMethodStart, fallbackMethodEnd);

    expect(fallbackMethod, contains(".eq('language', requestedLanguage)"));
    expect(fallbackMethod, contains('_readExactCache('));
    expect(fallbackMethod, isNot(contains('_buildCachedNewsFeedFromRow(')));
  });

  test('scheduled Edge refresh scans metadata and hydrates only selected payload', () {
    final source = File(
      'supabase/functions/news-cache-refresh/index.ts',
    ).readAsStringSync();

    final metadataScan = _segment(
      source,
      '// NEWS_EGRESS_V1_METADATA_SCAN_START',
      '// NEWS_EGRESS_V1_METADATA_SCAN_END',
    );

    expect(metadataScan, contains('payload_version'));
    expect(metadataScan, isNot(contains('payload\n')));
    expect(metadataScan, isNot(contains('payload,')));

    expect(source, contains('NEWS_EGRESS_V1_SELECTED_PAYLOAD_HYDRATION'));
    expect(source, contains(".select('payload,payload_version')"));
    expect(source, contains('const hydratedCandidate = await hydrateCandidatePayload('));
    expect(source, contains('refreshSingleCandidate(\n        supabase,\n        hydratedCandidate,'));
  });
}
