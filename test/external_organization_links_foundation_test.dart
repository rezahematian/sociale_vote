import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/domain/organization/entities/organization_models.dart';

void main() {
  group('Organization external link validation', () {
    test('normalizes official provider URLs to HTTPS', () {
      expect(
        OrganizationExternalLinkProvider.youtube
            .normalizeUrl('www.youtube.com/@socialvote'),
        'https://www.youtube.com/@socialvote',
      );
      expect(
        OrganizationExternalLinkProvider.linkedin.normalizeUrl(
          'https://www.linkedin.com/company/social-vote',
        ),
        'https://www.linkedin.com/company/social-vote',
      );
      expect(
        OrganizationExternalLinkProvider.whatsapp
            .normalizeUrl('https://wa.me/390000000000'),
        'https://wa.me/390000000000',
      );
      expect(
        OrganizationExternalLinkProvider.instagram
            .normalizeUrl('instagram.com/socialvote'),
        'https://instagram.com/socialvote',
      );
      expect(
        OrganizationExternalLinkProvider.telegram
            .normalizeUrl('t.me/socialvote'),
        'https://t.me/socialvote',
      );
    });

    test('rejects HTTP, phishing hosts and provider mismatches', () {
      expect(
        () => OrganizationExternalLinkProvider.youtube
            .normalizeUrl('http://youtube.com/@socialvote'),
        throwsFormatException,
      );
      expect(
        () => OrganizationExternalLinkProvider.youtube
            .normalizeUrl('https://youtube.com.evil.example/@socialvote'),
        throwsFormatException,
      );
      expect(
        () => OrganizationExternalLinkProvider.youtube
            .normalizeUrl('https://www.linkedin.com/company/social-vote'),
        throwsFormatException,
      );
      expect(
        () => OrganizationExternalLinkProvider.instagram
            .normalizeUrl('https://user:secret@instagram.com/socialvote'),
        throwsFormatException,
      );
      expect(
        () => OrganizationExternalLinkProvider.telegram
            .normalizeUrl('https://t.me:444/socialvote'),
        throwsFormatException,
      );
    });

    test('empty values remove a provider without inventing a link', () {
      expect(
        OrganizationExternalLinkProvider.youtube.normalizeUrl(null),
        isNull,
      );
      expect(
        OrganizationExternalLinkProvider.youtube.normalizeUrl('   '),
        isNull,
      );
    });

    test('backend rows preserve declared versus ownership verified state', () {
      final declared = OrganizationExternalLink.fromJson(<String, dynamic>{
        'id': 'link-1',
        'organization_id': 'org-1',
        'provider': 'youtube',
        'canonical_url': 'https://www.youtube.com/@socialvote',
        'connection_mode': 'declared',
        'visibility': 'public',
        'status': 'active',
      });

      expect(declared.provider, OrganizationExternalLinkProvider.youtube);
      expect(declared.isPublic, isTrue);
      expect(declared.isOwnershipVerified, isFalse);
    });
  });

  group('External links SQL security contract', () {
    test('migration keeps direct tables closed and mutations behind RPC', () {
      final sql = File(
        'supabase/migration/20260831_external_organization_links_v1.sql',
      ).readAsStringSync();

      expect(sql, contains('force row level security'));
      expect(
        sql,
        contains(
          'on table public.external_account_links\n'
          'from public, anon, authenticated;',
        ),
      );
      expect(sql, contains('security definer'));
      expect(sql, contains("v_role not in ('owner', 'manager')"));
      expect(sql, contains('organization_external_links_replace'));
      expect(sql, contains('organization_external_links_public'));
      expect(sql, contains('organization_external_links_list_mine'));
      expect(sql, contains('organization_external_links_replaced'));
    });

    test('migration does not couple links to verification or entitlement', () {
      final sql = File(
        'supabase/migration/20260831_external_organization_links_v1.sql',
      ).readAsStringSync();
      final replaceStart = sql.indexOf(
        'create or replace function public.organization_external_links_replace',
      );
      final replaceBody = sql.substring(replaceStart);

      expect(replaceBody, isNot(contains('entitlement_status')));
      expect(replaceBody, isNot(contains('billing_enabled')));
      expect(replaceBody, isNot(contains('verification_status =')));
      expect(replaceBody, isNot(contains('service_role')));
    });
  });
}
