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

  /// Data/ora di inizio (opzionale).
  final DateTime? startAt;

  /// Data/ora di fine (opzionale).
  final DateTime? endAt;

  /// Informazioni geografiche di alto livello (es. codice paese, città).
  final String? countryCode;
  final String? cityId;

  /// Utente che ha creato il poll.
  final String? createdByUserId;

  const Poll({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.status,
    required this.options,
    required this.configuration,
    this.startAt,
    this.endAt,
    this.countryCode,
    this.cityId,
    this.createdByUserId,
  });

  bool get isOpen => status == PollStatus.open;

  bool get isClosed => status == PollStatus.closed;

  bool get isScheduled => status == PollStatus.scheduled;

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
    DateTime? startAt,
    DateTime? endAt,
    String? countryCode,
    String? cityId,
    String? createdByUserId,
  }) {
    return Poll(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      options: options ?? this.options,
      configuration: configuration ?? this.configuration,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      countryCode: countryCode ?? this.countryCode,
      cityId: cityId ?? this.cityId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
    );
  }

  @override
  String toString() {
    return 'Poll(id: $id, title: $title, type: $type, status: $status, options: ${options.length}, createdBy: $createdByUserId)';
  }
}