import 'package:flutter/foundation.dart';

import 'package:sociale_vote/domain/organization/entities/live_session_models.dart';
import 'package:sociale_vote/domain/organization/entities/organization_models.dart';
import 'package:sociale_vote/domain/organization/repositories/organization_repository.dart';

class OrganizationWorkspaceController extends ChangeNotifier {
  final OrganizationRepository repository;

  OrganizationWorkspaceController({required this.repository});

  OrganizationContext? context;
  List<LiveSessionSummary> sessions = const [];
  List<OrganizationExternalLink> externalLinks = const [];
  bool isLoading = false;
  bool isSaving = false;
  Object? error;

  Future<void> load({bool bootstrapIfNeeded = true}) async {
    if (isLoading) return;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      context = await repository.getMyOrganization();
      if (context == null && bootstrapIfNeeded) {
        context = await repository.bootstrapFromVerifiedProfile();
      }
      if (context == null) {
        sessions = const [];
        externalLinks = const [];
      } else {
        sessions = await repository.listSessions();
        externalLinks = await repository.listMyExternalLinks();
      }
    } catch (e) {
      error = e;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshSessions() async {
    if (context == null) return;
    sessions = await repository.listSessions();
    notifyListeners();
  }

  Future<void> updateProfile({
    required OrganizationEntityType entityType,
    required String legalName,
    required String publicName,
    String? countryCode,
    String? city,
    String? websiteUrl,
    String? description,
  }) async {
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      context = await repository.updateOrganizationProfile(
        entityType: entityType,
        legalName: legalName,
        publicName: publicName,
        countryCode: countryCode,
        city: city,
        websiteUrl: websiteUrl,
        description: description,
      );
    } catch (e) {
      error = e;
      rethrow;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> replaceExternalLinks(
    Map<OrganizationExternalLinkProvider, String?> links,
  ) async {
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      externalLinks = await repository.replaceExternalLinks(links);
    } catch (e) {
      error = e;
      rethrow;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
