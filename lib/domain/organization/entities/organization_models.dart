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

class OrganizationWorkspace {
  final String id;
  final String organizationId;
  final String planKey;
  final String status;
  final String commercialMode;
  final bool billingEnabled;

  const OrganizationWorkspace({
    required this.id,
    required this.organizationId,
    required this.planKey,
    required this.status,
    required this.commercialMode,
    required this.billingEnabled,
  });

  factory OrganizationWorkspace.fromJson(Map<String, dynamic> json) {
    return OrganizationWorkspace(
      id: _string(json['id']) ?? '',
      organizationId: _string(json['organization_id']) ?? '',
      planKey: _string(json['plan_key']) ?? 'pilot',
      status: _string(json['status']) ?? 'active',
      commercialMode: _string(json['commercial_mode']) ?? 'pilot_free',
      billingEnabled: json['billing_enabled'] == true,
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
  bool get canOperateSessions => canManageProfile || membershipRole == 'operator';
}

String? _string(dynamic value) {
  if (value is! String) return null;
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
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
