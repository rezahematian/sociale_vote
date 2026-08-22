enum LiveSessionAccessMode { openAnonymous, controlledTokenPool }
enum LiveSessionResultsVisibility { live, afterVote, afterClose, organizerOnly }
enum LiveQuestionType { yesNo, singleChoice, multipleChoice }

typedef JsonMap = Map<String, dynamic>;

extension LiveSessionAccessModeX on LiveSessionAccessMode {
  String get storageKey => switch (this) {
        LiveSessionAccessMode.openAnonymous => 'open_anonymous',
        LiveSessionAccessMode.controlledTokenPool => 'controlled_token_pool',
      };

  static LiveSessionAccessMode fromStorageKey(String? value) =>
      value == 'open_anonymous'
          ? LiveSessionAccessMode.openAnonymous
          : LiveSessionAccessMode.controlledTokenPool;
}

extension LiveSessionResultsVisibilityX on LiveSessionResultsVisibility {
  String get storageKey => switch (this) {
        LiveSessionResultsVisibility.live => 'live',
        LiveSessionResultsVisibility.afterVote => 'after_vote',
        LiveSessionResultsVisibility.afterClose => 'after_close',
        LiveSessionResultsVisibility.organizerOnly => 'organizer_only',
      };

  static LiveSessionResultsVisibility fromStorageKey(String? value) {
    return switch (value) {
      'live' => LiveSessionResultsVisibility.live,
      'after_vote' => LiveSessionResultsVisibility.afterVote,
      'organizer_only' => LiveSessionResultsVisibility.organizerOnly,
      _ => LiveSessionResultsVisibility.afterClose,
    };
  }
}

extension LiveQuestionTypeX on LiveQuestionType {
  String get storageKey => switch (this) {
        LiveQuestionType.yesNo => 'yes_no',
        LiveQuestionType.singleChoice => 'single_choice',
        LiveQuestionType.multipleChoice => 'multiple_choice',
      };

  static LiveQuestionType fromStorageKey(String? value) {
    return switch (value) {
      'yes_no' => LiveQuestionType.yesNo,
      'multiple_choice' => LiveQuestionType.multipleChoice,
      _ => LiveQuestionType.singleChoice,
    };
  }
}

class LiveOption {
  final String id;
  final String? optionKey;
  final String? label;
  final int position;
  final int votes;

  const LiveOption({
    required this.id,
    required this.optionKey,
    required this.label,
    required this.position,
    this.votes = 0,
  });

  factory LiveOption.fromJson(JsonMap json) => LiveOption(
        id: _string(json['id']) ?? '',
        optionKey: _string(json['option_key']),
        label: _string(json['label']),
        position: _int(json['position']),
        votes: _int(json['votes']),
      );
}

class LiveQuestion {
  final String id;
  final String title;
  final LiveQuestionType type;
  final int position;
  final int minSelections;
  final int maxSelections;
  final String status;
  final int responseCount;
  final List<LiveOption> options;

  const LiveQuestion({
    required this.id,
    required this.title,
    required this.type,
    required this.position,
    required this.minSelections,
    required this.maxSelections,
    required this.status,
    required this.responseCount,
    required this.options,
  });

  factory LiveQuestion.fromJson(JsonMap json) => LiveQuestion(
        id: _string(json['id']) ?? '',
        title: _string(json['title']) ?? '',
        type: LiveQuestionTypeX.fromStorageKey(_string(json['question_type'])),
        position: _int(json['position']),
        minSelections: _int(json['min_selections'], fallback: 1),
        maxSelections: _int(json['max_selections'], fallback: 1),
        status: _string(json['status']) ?? 'draft',
        responseCount: _int(json['response_count']),
        options: _list(json['options'])
            .map((item) => LiveOption.fromJson(_map(item)))
            .toList(growable: false),
      );

  bool get isOpen => status == 'open';
}

class LiveSessionSummary {
  final String id;
  final String title;
  final String joinCode;
  final String status;
  final String? organizationName;
  final String? organizationLogoUrl;
  final String? organizationCoverUrl;
  final LiveSessionAccessMode accessMode;
  final LiveSessionResultsVisibility resultsVisibility;
  final String rawRetention;
  final int expectedParticipants;
  final int tokenCount;
  final int responseCount;
  final DateTime createdAt;
  final DateTime? openedAt;
  final DateTime? closedAt;
  final String? reportId;

  const LiveSessionSummary({
    required this.id,
    required this.title,
    required this.joinCode,
    required this.status,
    required this.organizationName,
    required this.organizationLogoUrl,
    required this.organizationCoverUrl,
    required this.accessMode,
    required this.resultsVisibility,
    required this.rawRetention,
    required this.expectedParticipants,
    required this.tokenCount,
    required this.responseCount,
    required this.createdAt,
    required this.openedAt,
    required this.closedAt,
    required this.reportId,
  });

  factory LiveSessionSummary.fromJson(JsonMap json) => LiveSessionSummary(
        id: _string(json['id']) ?? '',
        title: _string(json['title']) ?? '',
        joinCode: _string(json['join_code']) ?? '',
        status: _string(json['status']) ?? 'draft',
        organizationName: _string(json['organization_name']),
        organizationLogoUrl: _string(json['organization_logo_url']),
        organizationCoverUrl: _string(json['organization_cover_url']),
        accessMode:
            LiveSessionAccessModeX.fromStorageKey(_string(json['access_mode'])),
        resultsVisibility: LiveSessionResultsVisibilityX.fromStorageKey(
          _string(json['results_visibility']),
        ),
        rawRetention: _string(json['raw_retention']) ?? '7d',
        expectedParticipants: _int(json['expected_participants']),
        tokenCount: _int(json['token_count']),
        responseCount: _int(json['response_count']),
        createdAt: _date(json['created_at']) ?? DateTime.now(),
        openedAt: _date(json['opened_at']),
        closedAt: _date(json['closed_at']),
        reportId: _string(json['report_id']),
      );
}

class LiveSessionDetail {
  final LiveSessionSummary session;
  final List<LiveQuestion> questions;
  final bool hasVotedOpenQuestion;

  const LiveSessionDetail({
    required this.session,
    required this.questions,
    this.hasVotedOpenQuestion = false,
  });

  factory LiveSessionDetail.fromJson(JsonMap json) => LiveSessionDetail(
        session: LiveSessionSummary.fromJson(_map(json['session'])),
        questions: _list(json['questions'])
            .map((item) => LiveQuestion.fromJson(_map(item)))
            .toList(growable: false),
        hasVotedOpenQuestion: json['has_voted_open_question'] == true,
      );

  LiveQuestion? get openQuestion {
    for (final question in questions) {
      if (question.isOpen) return question;
    }
    return null;
  }
}

class ParticipantJoinResult {
  final String participantSecret;
  final LiveSessionDetail detail;

  const ParticipantJoinResult({
    required this.participantSecret,
    required this.detail,
  });

  factory ParticipantJoinResult.fromJson(JsonMap json) => ParticipantJoinResult(
        participantSecret: _string(json['participant_secret']) ?? '',
        detail: LiveSessionDetail.fromJson(json),
      );
}

class VerifiedSessionReport {
  final String reportId;
  final String sha256;
  final bool hashValid;
  final JsonMap snapshot;
  final DateTime createdAt;

  const VerifiedSessionReport({
    required this.reportId,
    required this.sha256,
    required this.hashValid,
    required this.snapshot,
    required this.createdAt,
  });

  factory VerifiedSessionReport.fromJson(JsonMap json) => VerifiedSessionReport(
        reportId: _string(json['report_id']) ?? '',
        sha256: _string(json['sha256']) ?? '',
        hashValid: json['hash_valid'] == true,
        snapshot: _map(json['snapshot']),
        createdAt: _date(json['created_at']) ?? DateTime.now(),
      );
}

String? _string(dynamic value) {
  if (value is! String) return null;
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

int _int(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

DateTime? _date(dynamic value) {
  if (value is DateTime) return value.toLocal();
  final raw = _string(value);
  return raw == null ? null : DateTime.tryParse(raw)?.toLocal();
}

JsonMap _map(dynamic value) {
  if (value is JsonMap) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<dynamic> _list(dynamic value) => value is List ? value : const [];
