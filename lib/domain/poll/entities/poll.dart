import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/institution_level.dart';

import '../value_objects/poll_configuration.dart';
import '../value_objects/poll_id.dart';
import '../value_objects/poll_status.dart';
import '../value_objects/poll_type.dart';
import 'poll_option.dart';

/// Entità di dominio principale per una votazione / poll.
///
/// Non contiene logica di persistenza o di presentazione.
/// Qui definiamo solo i dati e qualche helper base.
class Poll {
  final PollId id;
  final String title;
  final String? description;

  /// Tipo di poll (single, multi, yes/no, etc.).
  final PollType type;

  /// Stato corrente del poll (draft, scheduled, open, closed).
  final PollStatus status;

  /// Opzioni disponibili.
  final List<PollOption> options;

  /// Configurazione delle regole di voto (min/max selezioni, ecc.).
  final PollConfiguration configuration;

  /// Timestamp di creazione del contenuto poll.
  ///
  /// È opzionale per compatibilità con codice legacy già esistente,
  /// ma dovrebbe essere valorizzato dalle repository reali.
  final DateTime? createdAt;

  /// Data/ora di inizio (opzionale).
  final DateTime? startAt;

  /// Data/ora di fine (opzionale).
  final DateTime? endAt;

  /// Informazioni geografiche legacy / compatibilità.
  final String? countryCode;
  final String? cityId;

  /// Località completa del contenuto.
  final ContentLocation? contentLocation;

  /// Utente che ha creato tecnicamente il poll.
  final String? createdByUserId;

  /// Snapshot dell'identità rappresentativa usata in pubblicazione.
  ///
  /// - null = poll pubblicato come utente normale
  /// - publicOfficial = poll pubblicato come official verificato
  /// - institution = poll pubblicato come ente verificato
  ///
  /// NON sostituisce [createdByUserId]:
  /// quello resta il creatore tecnico reale.
  final ActorType? publishedAsActorType;

  /// Livello istituzionale snapshot se il poll è pubblicato come institution.
  final InstitutionLevel? publishedAsInstitutionLevel;

  /// Etichetta rappresentativa snapshot da mostrare nel prodotto.
  ///
  /// Esempi:
  /// - officialTitle per public official
  /// - institutionName per institution
  final String? publishedAsDisplayName;

  /// Numero totale di partecipanti (aggregato backend).
  final int voteCount;

  const Poll({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.status,
    required this.options,
    required this.configuration,
    this.createdAt,
    this.startAt,
    this.endAt,
    this.countryCode,
    this.cityId,
    this.contentLocation,
    this.createdByUserId,
    this.publishedAsActorType,
    this.publishedAsInstitutionLevel,
    this.publishedAsDisplayName,
    this.voteCount = 0,
  }) : assert(
          publishedAsActorType != ActorType.citizen,
          'publishedAsActorType non può essere citizen: usare null per pubblicazione standard.',
        ),
        assert(
          publishedAsActorType == ActorType.institution ||
              publishedAsInstitutionLevel == null,
          'publishedAsInstitutionLevel è valido solo per poll pubblicati come institution.',
        );

  bool get isOpen => status == PollStatus.open;

  bool get isClosed => status == PollStatus.closed;

  bool get isScheduled => status == PollStatus.scheduled;

  bool get isPublishedAsRepresentative {
    final normalized = publishedAsDisplayName?.trim();
    return (publishedAsActorType == ActorType.publicOfficial ||
            publishedAsActorType == ActorType.institution) &&
        normalized != null &&
        normalized.isNotEmpty;
  }

  bool get isPublishedAsPublicOfficial {
    return publishedAsActorType == ActorType.publicOfficial;
  }

  bool get isPublishedAsInstitution {
    return publishedAsActorType == ActorType.institution;
  }

  String? get representativeDisplayName {
    final normalized = publishedAsDisplayName?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  String? get representativeActorTypeLabel {
    switch (publishedAsActorType) {
      case ActorType.publicOfficial:
        return 'Public Official';
      case ActorType.institution:
        return 'Institution';
      case ActorType.citizen:
      case null:
        return null;
    }
  }

  /// Data coerente da usare nei ranking discovery/trending.
  ///
  /// Ordine di fallback:
  /// 1. [createdAt]
  /// 2. [startAt]
  /// 3. [endAt]
  /// 4. epoch UTC (fallback difensivo)
  DateTime get rankingDate {
    return createdAt ??
        startAt ??
        endAt ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  /// Ritorna true se ora è tra startAt ed endAt (se presenti).
  bool isActiveAt(DateTime now) {
    if (startAt != null && now.isBefore(startAt!)) {
      return false;
    }
    if (endAt != null && now.isAfter(endAt!)) {
      return false;
    }
    return true;
  }

  Poll copyWith({
    PollId? id,
    String? title,
    String? description,
    PollType? type,
    PollStatus? status,
    List<PollOption>? options,
    PollConfiguration? configuration,
    DateTime? createdAt,
    DateTime? startAt,
    DateTime? endAt,
    String? countryCode,
    String? cityId,
    ContentLocation? contentLocation,
    String? createdByUserId,
    ActorType? publishedAsActorType,
    InstitutionLevel? publishedAsInstitutionLevel,
    String? publishedAsDisplayName,
    int? voteCount,
  }) {
    return Poll(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      options: options ?? this.options,
      configuration: configuration ?? this.configuration,
      createdAt: createdAt ?? this.createdAt,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      countryCode: countryCode ?? this.countryCode,
      cityId: cityId ?? this.cityId,
      contentLocation: contentLocation ?? this.contentLocation,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      publishedAsActorType: publishedAsActorType ?? this.publishedAsActorType,
      publishedAsInstitutionLevel: publishedAsInstitutionLevel ??
          this.publishedAsInstitutionLevel,
      publishedAsDisplayName:
          publishedAsDisplayName ?? this.publishedAsDisplayName,
      voteCount: voteCount ?? this.voteCount,
    );
  }

  @override
  String toString() {
    return 'Poll(id: $id, title: $title, createdAt: $createdAt, votes: $voteCount, type: $type, status: $status, options: ${options.length}, countryCode: $countryCode, cityId: $cityId, contentLocation: $contentLocation, createdBy: $createdByUserId, publishedAsActorType: $publishedAsActorType, publishedAsInstitutionLevel: $publishedAsInstitutionLevel, publishedAsDisplayName: $publishedAsDisplayName)';
  }
}