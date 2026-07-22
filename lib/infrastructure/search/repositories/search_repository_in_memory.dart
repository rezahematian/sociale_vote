import 'dart:math' as math;

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/content/news/repositories/news_repository.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/content/social/repositories/post_repository.dart';
import 'package:sociale_vote/domain/discussion/repositories/comment_repository.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/repositories/poll_repository.dart';
import 'package:sociale_vote/domain/search/entities/search_result_item.dart';
import 'package:sociale_vote/domain/search/repositories/search_repository.dart';
import 'package:sociale_vote/domain/search/value_objects/search_filters.dart';
import 'package:sociale_vote/domain/search/value_objects/search_query.dart';

/// Implementazione in-memory di [SearchRepository].
///
/// V1:
/// - legge i dati direttamente dai repository Poll/News/Post già esistenti
///   filtrati per [GeoScope] attraverso i metodi standard.
/// - esegue il matching full-text molto semplice:
///   - lower-case
///   - contains() su titolo + snippet/contenuto
/// - popola segnali generici per ranking/filtri:
///   - [SearchResultItem.createdAt] dove possibile
///   - [SearchResultItem.heat] se l’entità espone un campo compatibile
///   - [SearchResultItem.pollStatus] per i Poll (se disponibile)
/// - ordina i risultati prima della paginazione:
///   - latest per data decrescente
///   - hottest per segnale engagement, con data come spareggio.
class SearchRepositoryInMemory implements SearchRepository {
  final PollRepository _pollRepository;
  final NewsRepository _newsRepository;
  final PostRepository _postRepository;
  final CommentRepository _commentRepository;

  SearchRepositoryInMemory({
    required PollRepository pollRepository,
    required NewsRepository newsRepository,
    required PostRepository postRepository,
    required CommentRepository commentRepository,
  })  : _pollRepository = pollRepository,
        _newsRepository = newsRepository,
        _postRepository = postRepository,
        _commentRepository = commentRepository;

  @override
  Future<List<SearchResultItem>> search({
    required SearchQuery query,
    required SearchFilters filters,
  }) async {
    // Se query vuota → per v1 non restituiamo nulla.
    if (query.isEmpty) {
      return [];
    }

    final normalized = query.normalizedText;
    final GeoScope scope = filters.scope;

    final List<SearchResultItem> results = [];

    // Decidiamo quali tipi includere in base al contentType.
    final includePolls = query.type == SearchContentType.all ||
        query.type == SearchContentType.poll;
    final includeNews = query.type == SearchContentType.all ||
        query.type == SearchContentType.news;
    final includePosts = query.type == SearchContentType.all ||
        query.type == SearchContentType.post;

    // Parametri di scope per i repository.
    final String? countryCode = scope.countryCode;
    final String? cityId = scope.cityId;

    // 🔍 POLL
    if (includePolls) {
      final polls = await _pollRepository.getPolls(
        countryCode: countryCode,
        cityId: cityId,
      );

      for (final poll in polls) {
        final text = _buildPollSearchText(poll);
        if (text.contains(normalized)) {
          final createdAt = _extractCreatedAt(poll);
          final heat = _extractHeat(poll);
          final pollStatus = _extractPollStatus(poll);

          results.add(
            SearchResultItem(
              target: TargetRef.poll(poll.id.value),
              contentType: SearchContentType.poll,
              title: poll.title,
              snippet: _pollSnippet(poll),
              // Manteniamo [date] per compatibilità storica.
              date: createdAt,
              createdAt: createdAt,
              heat: heat,
              pollStatus: pollStatus,
            ),
          );
        }
      }
    }

    // 🔍 NEWS
    if (includeNews) {
      final newsItems = await _newsRepository.getNewsFeed(
        countryCode: countryCode,
        cityId: cityId,
      );

      for (final news in newsItems) {
        final text = _buildNewsSearchText(news);
        if (text.contains(normalized)) {
          final createdAt = news.publishedAt;
          final heat = _extractHeat(news);

          results.add(
            SearchResultItem(
              target: TargetRef.news(news.id.value),
              contentType: SearchContentType.news,
              title: news.title,
              snippet: _newsSnippet(news),
              date: createdAt,
              createdAt: createdAt,
              heat: heat,
            ),
          );
        }
      }
    }

    // 🔍 POST (social)
    if (includePosts) {
      final posts = await _postRepository.getFeed(
        countryCode: countryCode,
        cityId: cityId,
      );

      final matchingPosts = posts
          .where((post) => _buildPostSearchText(post).contains(normalized))
          .toList(growable: false);
      final commentCounts = await _loadPostCommentCounts(matchingPosts);

      for (final post in matchingPosts) {
        final createdAt = post.createdAt;
        final target = TargetRef.post(post.id.value);
        final heat =
            commentCounts[_targetBatchKey(target)] ?? post.commentCount;

        results.add(
          SearchResultItem(
            target: target,
            contentType: SearchContentType.post,
            title: post.title,
            snippet: _postSnippet(post),
            date: createdAt,
            createdAt: createdAt,
            heat: heat,
          ),
        );
      }
    }

    // Ordinamento applicato sull'intero dataset prima di offset/limit.
    // In questo modo Hottest e Latest non lavorano solo sui primi risultati
    // già tagliati dalla paginazione.
    switch (filters.sort) {
      case SearchSort.hottest:
        results.sort((a, b) {
          final heatComparison = (b.heat ?? 0).compareTo(a.heat ?? 0);
          if (heatComparison != 0) {
            return heatComparison;
          }
          return _compareByDateDescending(a, b);
        });
        break;

      case SearchSort.latest:
        results.sort(_compareByDateDescending);
        break;
    }

    // Applichiamo offset + limit in memoria solo dopo l'ordinamento.
    final start = filters.offset;
    if (start >= results.length) {
      return [];
    }
    final end = math.min(start + filters.limit, results.length);

    return results.sublist(start, end);
  }

  // ----------------------------------------------------------
  // Helpers di normalizzazione testo
  // ----------------------------------------------------------

  String _buildPollSearchText(Poll poll) {
    final buffer = StringBuffer();
    buffer.write(poll.title);
    // Se hai una descrizione o corpo principale del poll, aggiungilo qui.
    // Evitiamo di assumere campi che non conosciamo con certezza.
    return buffer.toString().toLowerCase();
  }

  String? _pollSnippet(Poll poll) {
    // V1: usiamo semplicemente il titolo come "snippet".
    // In futuro potremo usare descrizione o body.
    return poll.title;
  }

  String _buildNewsSearchText(NewsItem news) {
    final buffer = StringBuffer();
    buffer.write(news.title);
    if (news.summary != null && news.summary!.trim().isNotEmpty) {
      buffer.write(' ');
      buffer.write(news.summary);
    }
    return buffer.toString().toLowerCase();
  }

  String? _newsSnippet(NewsItem news) {
    if (news.summary != null && news.summary!.trim().isNotEmpty) {
      return news.summary!;
    }
    return news.title;
  }

  String _buildPostSearchText(Post post) {
    final buffer = StringBuffer();
    buffer.write(post.title);
    if (post.content.trim().isNotEmpty) {
      buffer.write(' ');
      buffer.write(post.content);
    }
    return buffer.toString().toLowerCase();
  }

  String? _postSnippet(Post post) {
    if (post.content.trim().isNotEmpty) {
      return post.content;
    }
    return post.title;
  }

  Future<Map<String, int>> _loadPostCommentCounts(
    List<Post> posts,
  ) async {
    if (posts.isEmpty) {
      return const <String, int>{};
    }

    final targets = posts
        .map((post) => TargetRef.post(post.id.value))
        .toList(growable: false);

    try {
      return await _commentRepository.countCommentsForTargets(targets);
    } catch (_) {
      // Il conteggio commenti è un segnale di ranking secondario.
      // Se non è disponibile, la ricerca resta utilizzabile e usa il
      // valore già presente sul Post come fallback.
      return const <String, int>{};
    }
  }

  String _targetBatchKey(TargetRef target) {
    return '${target.type.name}|${target.id.trim()}';
  }

  // ----------------------------------------------------------
  // Helpers generici per segnali di ranking (heat, createdAt, pollStatus)
  // ----------------------------------------------------------

  /// Estrae un segnale di "heat" generico dall'entità, se presente.
  ///
  /// Ordine:
  /// - field `heat` (int / double), se disponibile
  /// - field `heatScore.value`, se disponibile
  /// - Poll: numero voti
  /// - Post: numero commenti
  ///
  /// News non espone ancora un segnale engagement nel modello corrente:
  /// in quel caso il valore resta null e la data viene usata come spareggio.
  int? _extractHeat(Object entity) {
    try {
      // ignore: avoid_dynamic_calls
      final dynamic heatField = (entity as dynamic).heat;
      if (heatField is int) return heatField;
      if (heatField is double) return heatField.round();
    } catch (_) {
      // Getter non presente sull'entità.
    }

    try {
      // ignore: avoid_dynamic_calls
      final dynamic heatScore = (entity as dynamic).heatScore;
      if (heatScore != null) {
        // ignore: avoid_dynamic_calls
        final dynamic value = heatScore.value;
        if (value is int) return value;
        if (value is double) return value.round();
      }
    } catch (_) {
      // Value object non presente sull'entità.
    }

    if (entity is Poll) {
      return entity.voteCount;
    }

    if (entity is Post) {
      return entity.commentCount;
    }

    return null;
  }

  int _compareByDateDescending(
    SearchResultItem a,
    SearchResultItem b,
  ) {
    final ad = a.createdAt ?? a.date;
    final bd = b.createdAt ?? b.date;

    if (ad == null && bd == null) return 0;
    if (ad == null) return 1;
    if (bd == null) return -1;

    return bd.compareTo(ad);
  }

  /// Estrae una data di creazione/pubblicazione generica, se possibile.
  ///
  /// Prova in ordine:
  /// - field `createdAt`
  /// - field `publishedAt`
  DateTime? _extractCreatedAt(Object entity) {
    try {
      // ignore: avoid_dynamic_calls
      final dynamic any = entity;

      final dynamic createdAt = any.createdAt;
      if (createdAt is DateTime) return createdAt;

      final dynamic publishedAt = any.publishedAt;
      if (publishedAt is DateTime) return publishedAt;
    } catch (_) {
      // Nessuna data disponibile.
    }
    return null;
  }

  /// Estrae uno stato Poll generico (open/closed) se presente.
  ///
  /// Prova in ordine:
  /// - field `status`
  /// - field `pollStatus`
  ///
  /// Il tipo concreto può essere una enum o altro: viene passato
  /// come [Object] e interpretato lato controller.
  Object? _extractPollStatus(Object entity) {
    try {
      // ignore: avoid_dynamic_calls
      final dynamic any = entity;

      final dynamic status = any.status;
      if (status != null) return status;

      final dynamic pollStatus = any.pollStatus;
      if (pollStatus != null) return pollStatus;
    } catch (_) {
      // Nessuno stato disponibile (non è un Poll o campo diverso).
    }
    return null;
  }
}
