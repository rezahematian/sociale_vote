import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/identity/entities/account_discovery_item.dart';
import 'package:sociale_vote/domain/identity/entities/account_follow_state.dart';
import 'package:sociale_vote/domain/identity/entities/user_profile.dart';
import 'package:sociale_vote/domain/identity/repositories/account_follow_repository.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/institution_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_status.dart';

class AccountFollowRepositoryImpl implements AccountFollowRepository {
  @override
  Future<List<AccountDiscoveryItem>> getFollowers({
    int limit = 50,
    int offset = 0,
  }) {
    return _getConnections(
      direction: 'followers',
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<Set<String>> getFollowedAccountIds() async {
    final response = await AppSupabase.client.rpc(
      'get_my_followed_account_ids',
    );

    if (response is! List) {
      return const <String>{};
    }

    return response
        .whereType<Map>()
        .map((row) => row['user_id']?.toString().trim() ?? '')
        .where((userId) => userId.isNotEmpty)
        .toSet();
  }

  @override
  Future<List<AccountDiscoveryItem>> getFollowing({
    int limit = 50,
    int offset = 0,
  }) {
    return _getConnections(
      direction: 'following',
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<AccountFollowState> getState(String targetUserId) async {
    final normalizedTargetUserId = targetUserId.trim();
    if (normalizedTargetUserId.isEmpty) {
      throw ArgumentError('Target user id non valido.');
    }

    final response = await AppSupabase.client.rpc(
      'get_account_follow_state',
      params: <String, dynamic>{
        'p_target_user_id': normalizedTargetUserId,
      },
    );

    return _mapState(_firstRow(response));
  }

  @override
  Future<AccountFollowState> toggleFollow(String targetUserId) async {
    final normalizedTargetUserId = targetUserId.trim();
    if (normalizedTargetUserId.isEmpty) {
      throw ArgumentError('Target user id non valido.');
    }

    final response = await AppSupabase.client.rpc(
      'toggle_account_follow',
      params: <String, dynamic>{
        'p_target_user_id': normalizedTargetUserId,
      },
    );

    return _mapState(_firstRow(response));
  }

  Future<List<AccountDiscoveryItem>> _getConnections({
    required String direction,
    required int limit,
    required int offset,
  }) async {
    if (limit <= 0) {
      return const <AccountDiscoveryItem>[];
    }

    final response = await AppSupabase.client.rpc(
      'list_my_account_connections',
      params: <String, dynamic>{
        'p_direction': direction,
        'p_limit': limit.clamp(1, 100),
        'p_offset': offset < 0 ? 0 : offset,
      },
    );

    if (response is! List) {
      return const <AccountDiscoveryItem>[];
    }

    return response
        .whereType<Map>()
        .map((row) => _mapConnection(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  AccountDiscoveryItem _mapConnection(Map<String, dynamic> row) {
    final profile = UserProfile(
      id: _readRequiredString(row, 'user_id'),
      displayName: _normalizeNullable(row['display_name']),
      username: _normalizeNullable(row['username']),
      avatarUrl: _normalizeNullable(row['avatar_url']),
      bio: _normalizeNullable(row['bio']),
      country: _normalizeNullable(row['country']),
      city: _normalizeNullable(row['city']),
      actorType: ActorTypeX.fromStorageKey(row['actor_type']?.toString()),
      verificationLevel: VerificationLevelX.fromStorageKey(
        row['verification_level']?.toString(),
      ),
      institutionLevel: _readInstitutionLevel(row['institution_level']),
      verificationStatus: VerificationStatus.none,
      officialTitle: _normalizeNullable(row['official_title']),
      institutionName: _normalizeNullable(row['institution_name']),
      organizationName: _normalizeNullable(row['organization_name']),
      createdAt: _readDateTime(row['created_at'], 'created_at'),
      updatedAt: _readDateTime(row['updated_at'], 'updated_at'),
    );

    return AccountDiscoveryItem(
      profile: profile,
      followerCount: _readInt(row['follower_count']),
      isFollowing: row['is_following'] == true,
    );
  }

  Map<String, dynamic> _firstRow(dynamic response) {
    if (response is List && response.isNotEmpty && response.first is Map) {
      return Map<String, dynamic>.from(response.first as Map);
    }

    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    throw StateError('Risposta follow account non valida.');
  }

  AccountFollowState _mapState(Map<String, dynamic> row) {
    return AccountFollowState(
      isFollowing: row['is_following'] == true,
      followerCount: _readInt(row['follower_count']),
      followingCount: _readInt(row['following_count']),
      canFollow: row['can_follow'] == true,
    );
  }

  int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  InstitutionLevel? _readInstitutionLevel(dynamic value) {
    final normalized = value?.toString().trim() ?? '';
    if (normalized.isEmpty) {
      return null;
    }
    return InstitutionLevelX.fromStorageKey(normalized);
  }

  String _readRequiredString(Map<String, dynamic> row, String key) {
    final value = row[key]?.toString().trim() ?? '';
    if (value.isEmpty) {
      throw StateError('Campo account follow non valido: $key');
    }
    return value;
  }

  DateTime _readDateTime(dynamic value, String key) {
    final parsed = value is DateTime
        ? value.toLocal()
        : DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    if (parsed == null) {
      throw StateError('Campo datetime account follow non valido: $key');
    }
    return parsed;
  }

  String? _normalizeNullable(dynamic value) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
