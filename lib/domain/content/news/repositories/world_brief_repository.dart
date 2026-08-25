import 'package:sociale_vote/domain/content/news/entities/world_brief.dart';

abstract class WorldBriefRepository {
  Future<List<WorldBrief>> listPublished({
    String? languageCode,
    String? countryCode,
    String? cityId,
    int limit = 50,
  });

  Future<WorldBrief?> getPublishedById(String id);

  Future<List<WorldBrief>> listForAdmin({
    WorldBriefStatus? status,
    int limit = 100,
  });

  Future<WorldBrief> saveDraft(WorldBriefDraft draft);

  Future<WorldBrief> publish(String id);

  Future<WorldBrief> withdraw(String id);

  Future<void> deleteDraft(String id);
}
