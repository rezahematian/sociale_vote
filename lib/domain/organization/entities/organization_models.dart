enum OrganizationEntityType {
  association,
  nonprofit,
  company,
  cooperative,
  sports,
  publicBody,
  committee,
  other,
}

extension OrganizationEntityTypeX on OrganizationEntityType {
  String get storageKey => switch (this) {
        OrganizationEntityType.association => 'association',
        OrganizationEntityType.nonprofit => 'nonprofit',
        OrganizationEntityType.company => 'company',
        OrganizationEntityType.cooperative => 'cooperative',
        OrganizationEntityType.sports => 'sports',
        OrganizationEntityType.publicBody => 'public_body',
        OrganizationEntityType.committee => 'committee',
        OrganizationEntityType.other => 'other',
      };

  static OrganizationEntityType fromStorageKey(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'association' => OrganizationEntityType.association,
      'nonprofit' => OrganizationEntityType.nonprofit,
      'company' => OrganizationEntityType.company,
      'cooperative' => OrganizationEntityType.cooperative,
      'sports' => OrganizationEntityType.sports,
      'public_body' => OrganizationEntityType.publicBody,
      'committee' => OrganizationEntityType.committee,
      _ => OrganizationEntityType.other,
    };
  }
}

class OrganizationProfile {
  final String id;
  final String legalName;
  final String publicName;
  final String slug;
  final OrganizationEntityType entityType;
  final String? countryCode;
  final String? city;
  final String? websiteUrl;
  final String? description;
  final String? logoUrl;
  final String? coverUrl;
  final String verificationStatus;
  final DateTime? verifiedAt;

  const OrganizationProfile({
    required this.id,
    required this.legalName,
    required this.publicName,
    required this.slug,
    required this.entityType,
    required this.countryCode,
    required this.city,
    required this.websiteUrl,
    required this.description,
    required this.logoUrl,
    required this.coverUrl,
    required this.verificationStatus,
    required this.verifiedAt,
  });

  factory OrganizationProfile.fromJson(Map<String, dynamic> json) {
    return OrganizationProfile(
      id: _string(json['id']) ?? '',
      legalName: _string(json['legal_name']) ?? '',
      publicName: _string(json['public_name']) ?? '',
      slug: _string(json['slug']) ?? '',
      entityType: OrganizationEntityTypeX.fromStorageKey(
        _string(json['entity_type']),
      ),
      countryCode: _string(json['country_code'])?.toUpperCase(),
      city: _string(json['city']),
      websiteUrl: _string(json['website_url']),
      description: _string(json['description']),
      logoUrl: _string(json['logo_url']),
      coverUrl: _string(json['cover_url']),
      verificationStatus: _string(json['verification_status']) ?? 'verified',
      verifiedAt: _date(json['verified_at']),
    );
  }

  bool get isVerified => verificationStatus == 'verified';
}

class OrganizationFollowState {
  final bool isFollowing;
  final int followerCount;
  final bool canFollow;

  const OrganizationFollowState({
    required this.isFollowing,
    required this.followerCount,
    required this.canFollow,
  });

  factory OrganizationFollowState.fromJson(Map<String, dynamic> json) {
    return OrganizationFollowState(
      isFollowing: json['is_following'] == true,
      followerCount: _int(json['follower_count']),
      canFollow: json['can_follow'] == true,
    );
  }
}

enum WorkspaceEntitlementStatus {
  none,
  pilot,
  active,
  suspended,
  expired,
}

extension WorkspaceEntitlementStatusX on WorkspaceEntitlementStatus {
  String get storageKey => switch (this) {
        WorkspaceEntitlementStatus.none => 'none',
        WorkspaceEntitlementStatus.pilot => 'pilot',
        WorkspaceEntitlementStatus.active => 'active',
        WorkspaceEntitlementStatus.suspended => 'suspended',
        WorkspaceEntitlementStatus.expired => 'expired',
      };

  static WorkspaceEntitlementStatus fromStorageKey(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'pilot' => WorkspaceEntitlementStatus.pilot,
      'active' => WorkspaceEntitlementStatus.active,
      'suspended' => WorkspaceEntitlementStatus.suspended,
      'expired' => WorkspaceEntitlementStatus.expired,
      _ => WorkspaceEntitlementStatus.none,
    };
  }
}

class OrganizationTeamMember {
  final String userId;
  final String? username;
  final String? displayName;
  final String? email;
  final String membershipRole;
  final String membershipStatus;
  final DateTime? createdAt;

  const OrganizationTeamMember({
    required this.userId,
    required this.username,
    required this.displayName,
    required this.email,
    required this.membershipRole,
    required this.membershipStatus,
    required this.createdAt,
  });

  factory OrganizationTeamMember.fromJson(Map<String, dynamic> json) {
    return OrganizationTeamMember(
      userId: _string(json['user_id']) ?? '',
      username: _string(json['username']),
      displayName: _string(json['display_name']),
      email: _string(json['email']),
      membershipRole: _string(json['membership_role']) ?? 'viewer',
      membershipStatus: _string(json['membership_status']) ?? 'active',
      createdAt: _date(json['created_at']),
    );
  }

  String get label {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final handle = username?.trim();
    if (handle != null && handle.isNotEmpty) return '@$handle';
    final mail = email?.trim();
    if (mail != null && mail.isNotEmpty) return mail;
    return userId;
  }
}

class OrganizationWorkspace {
  final String id;
  final String organizationId;
  final String planKey;
  final String status;
  final String commercialMode;
  final bool billingEnabled;
  final WorkspaceEntitlementStatus entitlementStatus;
  final DateTime? entitlementStartedAt;
  final DateTime? entitlementExpiresAt;

  const OrganizationWorkspace({
    required this.id,
    required this.organizationId,
    required this.planKey,
    required this.status,
    required this.commercialMode,
    required this.billingEnabled,
    this.entitlementStatus = WorkspaceEntitlementStatus.pilot,
    this.entitlementStartedAt,
    this.entitlementExpiresAt,
  });

  factory OrganizationWorkspace.fromJson(Map<String, dynamic> json) {
    return OrganizationWorkspace(
      id: _string(json['id']) ?? '',
      organizationId: _string(json['organization_id']) ?? '',
      planKey: _string(json['plan_key']) ?? 'pilot',
      status: _string(json['status']) ?? 'active',
      commercialMode: _string(json['commercial_mode']) ?? 'pilot_free',
      billingEnabled: json['billing_enabled'] == true,
      entitlementStatus: WorkspaceEntitlementStatusX.fromStorageKey(
        _string(json['entitlement_status']) ??
            ((_string(json['plan_key']) ?? 'pilot') == 'pilot'
                ? 'pilot'
                : 'active'),
      ),
      entitlementStartedAt: _date(json['entitlement_started_at']),
      entitlementExpiresAt: _date(json['entitlement_expires_at']),
    );
  }
}

class OrganizationContext {
  final OrganizationProfile organization;
  final OrganizationWorkspace workspace;
  final String membershipRole;

  const OrganizationContext({
    required this.organization,
    required this.workspace,
    required this.membershipRole,
  });

  factory OrganizationContext.fromJson(Map<String, dynamic> json) {
    return OrganizationContext(
      organization: OrganizationProfile.fromJson(
        _map(json['organization']),
      ),
      workspace: OrganizationWorkspace.fromJson(
        _map(json['workspace']),
      ),
      membershipRole: _string(json['membership_role']) ?? 'viewer',
    );
  }

  bool get canManageProfile =>
      membershipRole == 'owner' || membershipRole == 'manager';
  bool get isWorkspaceActive =>
      workspace.status.trim().toLowerCase() == 'active' &&
      (workspace.entitlementStatus == WorkspaceEntitlementStatus.pilot ||
          workspace.entitlementStatus == WorkspaceEntitlementStatus.active) &&
      (workspace.entitlementExpiresAt == null ||
          workspace.entitlementExpiresAt!.isAfter(DateTime.now()));
  bool get canUseBusinessServices =>
      organization.isVerified && isWorkspaceActive;
  bool get canPublishOfficial => canUseBusinessServices && canManageProfile;
  bool get canOperateSessions =>
      canUseBusinessServices &&
      (canManageProfile || membershipRole == 'operator');
  bool get isFreePilot =>
      workspace.entitlementStatus == WorkspaceEntitlementStatus.pilot;
  bool get hasWorkspaceEntitlement =>
      workspace.entitlementStatus == WorkspaceEntitlementStatus.pilot ||
      workspace.entitlementStatus == WorkspaceEntitlementStatus.active;
}

String? _string(dynamic value) {
  if (value is! String) return null;
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _date(dynamic value) {
  if (value is DateTime) return value.toLocal();
  final raw = _string(value);
  return raw == null ? null : DateTime.tryParse(raw)?.toLocal();
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}
