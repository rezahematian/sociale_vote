import 'dart:typed_data';

import 'package:sociale_vote/domain/organization/entities/live_session_models.dart';
import 'package:sociale_vote/domain/organization/entities/organization_models.dart';

abstract class OrganizationRepository {
  Future<OrganizationContext?> getMyOrganization();
  Future<OrganizationContext> bootstrapFromVerifiedProfile();
  Future<OrganizationProfile?> getPublicOrganizationByOperator(String userId);
  Future<OrganizationProfile?> getPublicOrganizationById(
    String organizationId,
  );
  Future<OrganizationFollowState> getOrganizationFollowState(
    String organizationId,
  );
  Future<OrganizationFollowState> toggleOrganizationFollow(
    String organizationId,
  );
  Future<Set<String>> getMyFollowedOrganizationIds();
  Future<OrganizationContext> updateOrganizationProfile({
    required OrganizationEntityType entityType,
    required String legalName,
    required String publicName,
    String? countryCode,
    String? city,
    String? websiteUrl,
    String? description,
  });
  Future<String> uploadOrganizationMedia({
    required String organizationId,
    required Uint8List bytes,
    required String fileName,
    required bool isCover,
  });

  Future<List<LiveSessionSummary>> listSessions();
  Future<String> createSession({
    required String title,
    required LiveSessionAccessMode accessMode,
    required LiveSessionResultsVisibility resultsVisibility,
    required String rawRetention,
    required int expectedParticipants,
  });
  Future<LiveSessionDetail> getOrganizerSession(String sessionId);
  Future<String> addQuestion({
    required String sessionId,
    required String title,
    required LiveQuestionType type,
    required List<String> options,
    required int minSelections,
    required int maxSelections,
  });
  Future<void> deleteQuestion(String questionId);
  Future<List<String>> generateTokens({
    required String sessionId,
    required int count,
  });
  Future<void> openSession(String sessionId);
  Future<void> openQuestion(String questionId);
  Future<void> closeQuestion(String questionId);
  Future<String> closeSession(String sessionId);

  Future<ParticipantJoinResult> joinPublicSession({
    required String joinCode,
    String? token,
  });
  Future<LiveSessionDetail> getPublicSessionState({
    required String joinCode,
    String? participantSecret,
  });
  Future<String> submitPublicVote({
    required String joinCode,
    required String participantSecret,
    required String questionId,
    required List<String> optionIds,
  });
  Future<LiveQuestion?> getPublicResults({
    required String joinCode,
    required String participantSecret,
    required String questionId,
  });
  Future<VerifiedSessionReport> getVerifiedReport(String reportId);
}
