import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/identity/entities/user_profile.dart';
import 'package:sociale_vote/domain/identity/repositories/user_profile_repository.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  static const String _table = 'user_profiles';

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    final rows = await AppSupabase.client
        .from(_table)
        .select()
        .eq('id', userId)
        .limit(1);

    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first as Map<String, dynamic>;
    return _mapProfile(row);
  }

  @override
  Future<UserProfile> updateUserProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
    String? bio,
    String? country,
    String? city,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    if (displayName != null) updates['display_name'] = displayName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (bio != null) updates['bio'] = bio;
    if (country != null) updates['country'] = country;
    if (city != null) updates['city'] = city;

    final rows = await AppSupabase.client
        .from(_table)
        .update(updates)
        .eq('id', userId)
        .select()
        .limit(1);

    if (rows.isEmpty) {
      throw Exception('Aggiornamento profilo fallito.');
    }

    final row = rows.first as Map<String, dynamic>;
    return _mapProfile(row);
  }

  UserProfile _mapProfile(Map<String, dynamic> row) {
    return UserProfile(
      id: (row['id'] as String?) ?? '',
      displayName: row['display_name'] as String?,
      avatarUrl: row['avatar_url'] as String?,
      bio: row['bio'] as String?,
      country: row['country'] as String?,
      city: row['city'] as String?,
      accountType: (row['account_type'] as String?) ?? 'citizen',
      isVerified: (row['is_verified'] as bool?) ?? false,
      createdAt: _parseDateTime(row['created_at']),
      updatedAt: _parseDateTime(row['updated_at']),
    );
  }

  DateTime _parseDateTime(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
    }
    return DateTime.now();
  }
}