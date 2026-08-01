import 'package:supabase_flutter/supabase_flutter.dart';

class ContentVisibilityFilter {
  static const int maximumIdsPerRequest = 200;

  final SupabaseClient _client;

  const ContentVisibilityFilter(this._client);

  Future<Set<String>> filterVisibleIds({
    required String targetType,
    required Iterable<String> targetIds,
  }) async {
    final normalizedTargetType = targetType.trim().toLowerCase();

    if (normalizedTargetType != 'poll' &&
        normalizedTargetType != 'post' &&
        normalizedTargetType != 'news') {
      throw ArgumentError.value(
        targetType,
        'targetType',
        'Target type must be poll, post, or news.',
      );
    }

    final normalizedIds = <String>[];
    final seenIds = <String>{};

    for (final targetId in targetIds) {
      final normalizedId = targetId.trim();

      if (normalizedId.isEmpty || normalizedId.length > 320) {
        throw ArgumentError.value(
          targetId,
          'targetIds',
          'Every target ID must contain between 1 and 320 characters.',
        );
      }

      if (seenIds.add(normalizedId)) {
        normalizedIds.add(normalizedId);
      }
    }

    if (normalizedIds.isEmpty) {
      return <String>{};
    }

    final visibleIds = <String>{};

    for (var start = 0;
        start < normalizedIds.length;
        start += maximumIdsPerRequest) {
      final end = (start + maximumIdsPerRequest < normalizedIds.length)
          ? start + maximumIdsPerRequest
          : normalizedIds.length;
      final batch = normalizedIds.sublist(start, end);

      final response = await _client.rpc(
        'filter_visible_content_ids',
        params: <String, Object?>{
          'p_target_type': normalizedTargetType,
          'p_target_ids': batch,
        },
      );

      if (response is! List) {
        throw const ContentVisibilityFilterException(
          'Invalid visibility-filter response.',
        );
      }

      for (final row in response) {
        if (row is! Map) {
          throw const ContentVisibilityFilterException(
            'Invalid visibility-filter row.',
          );
        }

        final value = row['target_id'];
        if (value is! String || value.trim().isEmpty) {
          throw const ContentVisibilityFilterException(
            'Invalid visible target ID.',
          );
        }

        visibleIds.add(value.trim());
      }
    }

    return visibleIds;
  }
}

class ContentVisibilityFilterException implements Exception {
  final String message;

  const ContentVisibilityFilterException(this.message);

  @override
  String toString() => 'ContentVisibilityFilterException: $message';
}
