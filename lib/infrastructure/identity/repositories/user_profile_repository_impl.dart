import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/identity/entities/user_profile.dart';
import 'package:sociale_vote/domain/identity/repositories/user_profile_repository.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/institution_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_status.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  static const String _table = 'user_profiles';

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      throw ArgumentError('User id non valido.');
    }

    final rows = await AppSupabase.client
        .from(_table)
        .select()
        .eq('id', normalizedUserId)
        .limit(1);

    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;
    return _mapProfile(row);
  }

  @override
  Future<UserProfile?> getUserProfileByUsername(String username) async {
    final normalizedUsername = _normalizeUsername(username);
    if (normalizedUsername == null) {
      return null;
    }

    final rows = await AppSupabase.client
        .from(_table)
        .select()
        .eq('username', normalizedUsername)
        .limit(1);

    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;
    return _mapProfile(row);
  }

  @override
  Future<UserProfile> createUserProfile({
    required String userId,
    String? displayName,
    String? username,
    String? avatarUrl,
    String? bio,
    String? country,
    String? city,
  }) async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      throw ArgumentError('User id non valido.');
    }

    final now = DateTime.now().toUtc().toIso8601String();

    final payload = <String, dynamic>{
      'id': normalizedUserId,
      'display_name': _normalizeNullable(displayName),
      'username': _normalizeUsername(username),
      'avatar_url': _normalizeNullable(avatarUrl),
      'bio': _normalizeNullable(bio),
      'country': _normalizeNullable(country),
      'city': _normalizeNullable(city),

      // Nuovo modello identity
      'actor_type': ActorType.citizen.storageKey,
      'verification_level': VerificationLevel.none.storageKey,
      'institution_level': null,
      'verification_status': VerificationStatus.none.storageKey,
      'verification_requested_at': null,
      'verified_at': null,
      'official_title': null,
      'institution_name': null,

      // Bridge legacy temporaneo
      'account_type': 'citizen',
      'is_verified': false,

      'created_at': now,
      'updated_at': now,
    };

    final rows =
        await AppSupabase.client.from(_table).insert(payload).select().limit(1);

    if (rows.isEmpty) {
      throw Exception('Creazione profilo fallita.');
    }

    final row = rows.first;
    return _mapProfile(row);
  }

  @override
  Future<UserProfile> updateUserProfile({
    required String userId,
    String? displayName,
    String? username,
    String? avatarUrl,
    String? bio,
    String? country,
    String? city,
  }) async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      throw ArgumentError('User id non valido.');
    }

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    if (displayName != null) {
      updates['display_name'] = _normalizeNullable(displayName);
    }
    if (username != null) {
      updates['username'] = _normalizeUsername(username);
    }
    if (avatarUrl != null) {
      updates['avatar_url'] = _normalizeNullable(avatarUrl);
    }
    if (bio != null) {
      updates['bio'] = _normalizeNullable(bio);
    }
    if (country != null) {
      updates['country'] = _normalizeNullable(country);
    }
    if (city != null) {
      updates['city'] = _normalizeNullable(city);
    }

    final rows = await AppSupabase.client
        .from(_table)
        .update(updates)
        .eq('id', normalizedUserId)
        .select()
        .limit(1);

    if (rows.isEmpty) {
      throw Exception('Aggiornamento profilo fallito.');
    }

    final row = rows.first;
    return _mapProfile(row);
  }

  @override
  Future<UserProfile> updateIdentityState({
    required String userId,
    required ActorType actorType,
    required VerificationLevel verificationLevel,
    required VerificationStatus verificationStatus,
    InstitutionLevel? institutionLevel,
    String? officialTitle,
    String? institutionName,
    DateTime? verificationRequestedAt,
    DateTime? verifiedAt,
  }) async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      throw ArgumentError('User id non valido.');
    }

    final normalizedInstitutionLevel =
        actorType == ActorType.institution ? institutionLevel : null;
    final normalizedOfficialTitle = actorType == ActorType.publicOfficial
        ? _normalizeNullable(officialTitle)
        : null;
    final normalizedInstitutionName = actorType == ActorType.institution
        ? _normalizeNullable(institutionName)
        : null;

    final updates = <String, dynamic>{
      'actor_type': actorType.storageKey,
      'verification_level': verificationLevel.storageKey,
      'institution_level': normalizedInstitutionLevel?.storageKey,
      'verification_status': verificationStatus.storageKey,
      'verification_requested_at':
          _toNullableUtcIsoString(verificationRequestedAt),
      'verified_at': _toNullableUtcIsoString(verifiedAt),
      'official_title': normalizedOfficialTitle,
      'institution_name': normalizedInstitutionName,

      // Bridge legacy temporaneo
      'account_type': actorType.storageKey,
      'is_verified': verificationLevel != VerificationLevel.none,

      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    final rows = await AppSupabase.client
        .from(_table)
        .update(updates)
        .eq('id', normalizedUserId)
        .select()
        .limit(1);

    if (rows.isEmpty) {
      throw Exception('Aggiornamento stato identità fallito.');
    }

    final row = rows.first;
    return _mapProfile(row);
  }

  UserProfile _mapProfile(Map<String, dynamic> row) {
    return UserProfile(
      id: _readRequiredString(row, 'id'),
      displayName: _normalizeNullable(row['display_name'] as String?),
      username: _normalizeUsername(row['username'] as String?),
      avatarUrl: _normalizeNullable(row['avatar_url'] as String?),
      bio: _normalizeNullable(row['bio'] as String?),
      country: _normalizeNullable(row['country'] as String?),
      city: _normalizeNullable(row['city'] as String?),
      actorType: _readActorType(row),
      verificationLevel: _readVerificationLevel(row),
      institutionLevel: _readInstitutionLevel(row),
      verificationStatus: _readVerificationStatus(row),
      verificationRequestedAt: _parseNullableDateTime(
        row['verification_requested_at'],
      ),
      verifiedAt: _parseNullableDateTime(row['verified_at']),
      officialTitle: _normalizeNullable(row['official_title'] as String?),
      institutionName: _normalizeNullable(row['institution_name'] as String?),
      createdAt: _parseRequiredDateTime(row['created_at'], 'created_at'),
      updatedAt: _parseRequiredDateTime(row['updated_at'], 'updated_at'),
    );
  }

  String _readRequiredString(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    throw StateError('Campo obbligatorio mancante o non valido: $key');
  }

  ActorType _readActorType(Map<String, dynamic> row) {
    final rawActorType = row['actor_type'] as String?;
    if (rawActorType != null && rawActorType.trim().isNotEmpty) {
      return ActorTypeX.fromStorageKey(rawActorType);
    }

    final legacyAccountType = row['account_type'] as String?;
    return ActorTypeX.fromStorageKey(legacyAccountType);
  }

  VerificationLevel _readVerificationLevel(Map<String, dynamic> row) {
    final rawVerificationLevel = row['verification_level'] as String?;
    if (rawVerificationLevel != null &&
        rawVerificationLevel.trim().isNotEmpty) {
      return VerificationLevelX.fromStorageKey(rawVerificationLevel);
    }

    final legacyIsVerified = row['is_verified'] as bool?;
    return legacyIsVerified == true
        ? VerificationLevel.level1
        : VerificationLevel.none;
  }

  InstitutionLevel? _readInstitutionLevel(Map<String, dynamic> row) {
    final rawInstitutionLevel = row['institution_level'] as String?;
    if (rawInstitutionLevel == null || rawInstitutionLevel.trim().isEmpty) {
      return null;
    }

    return InstitutionLevelX.fromStorageKey(rawInstitutionLevel);
  }

  VerificationStatus _readVerificationStatus(Map<String, dynamic> row) {
    final rawVerificationStatus = row['verification_status'] as String?;
    if (rawVerificationStatus == null || rawVerificationStatus.trim().isEmpty) {
      return VerificationStatus.none;
    }

    return VerificationStatusX.fromStorageKey(rawVerificationStatus);
  }

  String? _normalizeUsername(String? value) {
    if (value == null) {
      return null;
    }

    var normalized = value.trim().toLowerCase();
    if (normalized.startsWith('@')) {
      normalized = normalized.substring(1);
    }

    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  String? _normalizeNullable(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  String? _toNullableUtcIsoString(DateTime? value) {
    if (value == null) {
      return null;
    }
    return value.toUtc().toIso8601String();
  }

  DateTime? _parseNullableDateTime(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal();
    }

    if (value is DateTime) {
      return value.toLocal();
    }

    return null;
  }

  DateTime _parseRequiredDateTime(dynamic value, String fieldName) {
    final parsed = _parseNullableDateTime(value);
    if (parsed == null) {
      throw StateError('Campo datetime obbligatorio non valido: $fieldName');
    }
    return parsed;
  }
}
