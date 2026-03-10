import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/content/social/repositories/post_repository.dart';

/// Implementazione in-memory del [PostRepository].
///
/// v1:
/// - contiene alcuni post mock iniziali
/// - filtra per GeoScope
/// - supporta paginazione base
class PostRepositoryImpl implements PostRepository {
  final List<Post> _posts = [];

  PostRepositoryImpl() {
    _seedMockPosts();
  }

  void _seedMockPosts() {
    final now = DateTime.now();

    _posts.addAll([
      // 🌍 Global
      Post(
        id: const EntityId('post_global_1'),
        authorName: 'Global Citizen',
        title: 'Climate Action Worldwide',
        content:
            'We should coordinate globally to reduce emissions and support renewable energy initiatives.',
        createdAt: now.subtract(const Duration(days: 1)),
        commentCount: 0,
      ),
      Post(
        id: const EntityId('post_global_2'),
        authorName: 'International Observer',
        title: 'Global Education Reform',
        content:
            'Education systems worldwide need modernization and equal access to digital tools.',
        createdAt: now.subtract(const Duration(days: 2)),
        commentCount: 0,
      ),

      // 🇮🇹 Italy
      Post(
        id: const EntityId('post_it_1'),
        authorName: 'Mario Rossi',
        title: 'Sanità pubblica in Italia',
        content:
            'Dovremmo investire di più nella sanità territoriale e nella prevenzione.',
        createdAt: now.subtract(const Duration(hours: 10)),
        commentCount: 0,
        countryCode: 'IT',
      ),

      // 🏙 Torino
      Post(
        id: const EntityId('post_torino_1'),
        authorName: 'Giulia Bianchi',
        title: 'Trasporti pubblici a Torino',
        content:
            'Il trasporto pubblico dovrebbe essere potenziato nelle ore serali.',
        createdAt: now.subtract(const Duration(hours: 3)),
        commentCount: 0,
        countryCode: 'IT',
        cityId: 'TORINO',
      ),
    ]);
  }

  @override
  Future<List<Post>> getFeed({
    String? countryCode,
    String? cityId,
    int limit = 20,
    int offset = 0,
  }) async {
    if (_posts.isEmpty) {
      return const [];
    }

    final scoped = _posts
        .where(
          (post) => post.matchesScope(
            countryCode: countryCode,
            cityId: cityId,
          ),
        )
        .toList();

    if (scoped.isEmpty) {
      return const [];
    }

    // Ordiniamo per data decrescente (più recenti prima)
    scoped.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final int start = offset.clamp(0, scoped.length);
    final int end = (start + limit).clamp(0, scoped.length);

    if (start >= end) {
      return const [];
    }

    return List<Post>.unmodifiable(scoped.sublist(start, end));
  }

  @override
  Future<Post?> getPostById(String postId) async {
    try {
      return _posts.firstWhere(
        (post) => post.id.value == postId,
      );
    } on StateError {
      return null;
    }
  }

  @override
  Future<Post> createPost(Post post) async {
    _posts.add(post);
    return post;
  }

  @override
  Future<void> deletePost(String postId) async {
    _posts.removeWhere((post) => post.id.value == postId);
  }
}