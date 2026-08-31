import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/domain/organization/entities/organization_models.dart';

OrganizationContext ctx(String verification, String status, String role) =>
    OrganizationContext(
        organization: OrganizationProfile(
            id: 'o',
            legalName: 'L',
            publicName: 'P',
            slug: 'p',
            entityType: OrganizationEntityType.company,
            countryCode: 'IT',
            city: null,
            websiteUrl: null,
            description: null,
            logoUrl: null,
            coverUrl: null,
            verificationStatus: verification,
            verifiedAt: null),
        workspace: OrganizationWorkspace(
            id: 'w',
            organizationId: 'o',
            planKey: 'pilot',
            status: status,
            commercialMode: 'pilot_free',
            billingEnabled: false,
            entitlementStatus: WorkspaceEntitlementStatus.pilot),
        membershipRole: role);

void main() {
  test('verified + active required', () {
    expect(ctx('pending', 'active', 'owner').canUseBusinessServices, false);
    expect(ctx('verified', 'suspended', 'owner').canUseBusinessServices, false);
    expect(ctx('verified', 'active', 'owner').canUseBusinessServices, true);
  });
  test('roles fail closed', () {
    expect(ctx('verified', 'active', 'owner').canPublishOfficial, true);
    expect(ctx('verified', 'active', 'operator').canPublishOfficial, false);
    expect(ctx('verified', 'active', 'operator').canOperateSessions, true);
    expect(ctx('verified', 'active', 'viewer').canOperateSessions, false);
  });
  test('pilot is free', () {
    expect(ctx('verified', 'active', 'owner').isFreePilot, true);
  });

  test('missing entitlement fails closed instead of inventing pilot access',
      () {
    final workspace = OrganizationWorkspace.fromJson(<String, dynamic>{
      'id': 'w',
      'organization_id': 'o',
      'plan_key': 'pilot',
      'status': 'active',
      'commercial_mode': 'pilot_free',
      'billing_enabled': false,
    });

    expect(workspace.entitlementStatus, WorkspaceEntitlementStatus.none);
  });
}
