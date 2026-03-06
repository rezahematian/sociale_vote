import 'rate_limit_record.dart';
import 'rate_limit_rule.dart';

class RateLimitService {
  final Map<String, RateLimitRecord> _records = {};

  void enforce({
    required String key,
    required RateLimitRule rule,
  }) {
    final now = DateTime.now();
    final record = _records[key] ?? RateLimitRecord([]);

    record.timestamps.removeWhere(
      (t) => now.difference(t) > rule.window,
    );

    if (record.timestamps.length >= rule.maxActions) {
      throw Exception('Rate limit exceeded');
    }

    record.timestamps.add(now);
    _records[key] = record;
  }
}
