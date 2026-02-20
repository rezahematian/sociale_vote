import '../value_objects/poll_configuration.dart';
import '../poll_type.dart';
import '../../poll_option_dto.dart';

enum HeatVote {
  hot,
  cold,
}

class PollEntity {
  final String id;
  final String locationId;
  final String title;
  final String description;
  final DateTime createdAt;

  final PollType type;
  final PollConfiguration configuration;

  final List<PollOptionDto> options;
  final int totalVotes;
  final bool isClosed;

  final List<String>? userSelectedOptionIds;

  // =========================
  // 🔥 HEAT SYSTEM
  // =========================
  final int heatHotCount;
  final int heatColdCount;
  final HeatVote? userHeatVote;

  const PollEntity({
    required this.id,
    required this.locationId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.type,
    required this.configuration,
    required this.options,
    required this.totalVotes,
    required this.isClosed,
    this.userSelectedOptionIds,
    this.heatHotCount = 0,
    this.heatColdCount = 0,
    this.userHeatVote,
  });

  // =========================
  // DOMAIN HELPERS
  // =========================

  bool get isExpired {
    final end = configuration.endDate;
    if (end == null) return false;
    return DateTime.now().isAfter(end);
  }

  bool get isOpen {
    if (isClosed) return false;
    if (isExpired) return false;
    return configuration.isActive;
  }

  bool get userHasVoted =>
      userSelectedOptionIds != null &&
      userSelectedOptionIds!.isNotEmpty;

  double getOptionPercentage(int optionVotes) {
    if (totalVotes == 0) return 0;
    return (optionVotes / totalVotes) * 100;
  }

  // =========================
  // 🔥 HEAT LOGIC (UPGRADED)
  // =========================

  /// Totale interazioni heat
  int get heatTotal => heatHotCount + heatColdCount;

  /// Punteggio reale (cold pesa meno)
  int get heatScore => (heatHotCount * 2) - heatColdCount;

  /// Rapporto hot su totale
  double get heatRatio {
    if (heatTotal == 0) return 0;
    return heatHotCount / heatTotal;
  }

  /// Fattore freschezza
  int get ageInHours =>
      DateTime.now().difference(createdAt).inHours;

  /// Boost per poll recenti
  int get recencyBoost {
    if (ageInHours < 6) return 30;
    if (ageInHours < 24) return 15;
    if (ageInHours < 72) return 5;
    return 0;
  }

  /// Score finale per ranking feed / home map
  int get trendingScore =>
      heatScore + recencyBoost + (totalVotes ~/ 5);

  /// Trending dinamico
  bool get isTrending => trendingScore > 25;

  bool get isHot => heatRatio >= 0.7 && heatTotal > 10;

  bool get isControversial =>
      heatTotal > 15 && heatRatio > 0.4 && heatRatio < 0.6;

  // =========================
  // IMMUTABILITY
  // =========================

  PollEntity copyWith({
    String? locationId,
    PollType? type,
    PollConfiguration? configuration,
    int? totalVotes,
    bool? isClosed,
    List<PollOptionDto>? options,
    List<String>? userSelectedOptionIds,
    int? heatHotCount,
    int? heatColdCount,
    HeatVote? userHeatVote,
  }) {
    return PollEntity(
      id: id,
      locationId: locationId ?? this.locationId,
      title: title,
      description: description,
      createdAt: createdAt,
      type: type ?? this.type,
      configuration: configuration ?? this.configuration,
      options: options ?? this.options,
      totalVotes: totalVotes ?? this.totalVotes,
      isClosed: isClosed ?? this.isClosed,
      userSelectedOptionIds:
          userSelectedOptionIds ?? this.userSelectedOptionIds,
      heatHotCount: heatHotCount ?? this.heatHotCount,
      heatColdCount: heatColdCount ?? this.heatColdCount,
      userHeatVote: userHeatVote ?? this.userHeatVote,
    );
  }
}
