import 'package:flutter/material.dart';
import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/engagement/entities/favorite.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/features/news/presentation/pages/news_detail_page.dart';
import 'package:sociale_vote/features/poll/presentation/pages/poll_detail_page.dart';
import 'package:sociale_vote/features/social/presentation/pages/post_detail_page.dart';

class MyFavoritesPage extends StatefulWidget {
  const MyFavoritesPage({super.key});

  @override
  State<MyFavoritesPage> createState() => _MyFavoritesPageState();
}

class _MyFavoritesPageState extends State<MyFavoritesPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Favorite> _favorites = [];
  final Set<String> _removingKeys = <String>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = AppDI.instance.currentUserId;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _favorites = [];
        _isLoading = false;
      });
      return;
    }

    try {
      final result =
          await AppDI.instance.favoriteRepository.getFavoritesForUser(userId);

      if (!mounted) return;
      setState(() {
        _favorites = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _favorites = [];
        _isLoading = false;
        _errorMessage = 'Unable to load favorites.';
      });
    }
  }

  Future<void> _removeFavorite(Favorite favorite) async {
    final userId = AppDI.instance.currentUserId;
    if (userId == null) {
      return;
    }

    final key = _favoriteKey(favorite);

    if (!mounted) return;
    setState(() {
      _removingKeys.add(key);
    });

    try {
      await AppDI.instance.favoriteRepository.removeFavorite(
        userId: userId,
        target: favorite.target,
      );

      if (!mounted) return;
      setState(() {
        _favorites.removeWhere((item) => _favoriteKey(item) == key);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from favorites')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to remove favorite')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _removingKeys.remove(key);
        });
      }
    }
  }

  Future<void> _openDetail(BuildContext context, TargetRef target) async {
    switch (target.type) {
      case TargetType.poll:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PollDetailPage(pollId: PollId(target.id)),
          ),
        );
        break;

      case TargetType.post:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PostDetailPage(postId: target.id),
          ),
        );
        break;

      case TargetType.news:
        try {
          final news = await AppDI.instance.getNewsDetail(EntityId(target.id));

          if (!context.mounted) return;

          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NewsDetailPage(news: news),
            ),
          );
        } catch (_) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to open news detail')),
          );
        }
        break;

      case TargetType.video:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video detail is not available yet')),
        );
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unsupported favorite type')),
        );
        break;
    }

    await _load();
  }

  String _favoriteKey(Favorite favorite) {
    return '${favorite.target.type.name}:${favorite.target.id}';
  }

  String _targetLabel(TargetRef target) {
    switch (target.type) {
      case TargetType.poll:
        return 'Poll';
      case TargetType.post:
        return 'Post';
      case TargetType.news:
        return 'News';
      case TargetType.video:
        return 'Video';
      default:
        return target.type.name.toUpperCase();
    }
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/$year  $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final userId = AppDI.instance.currentUserId;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Favorites')),
        body: const Center(
          child: Text('You must be logged in.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_errorMessage!),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _load,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _favorites.isEmpty
                  ? RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        children: const [
                          SizedBox(height: 180),
                          Center(child: Text('No favorites yet.')),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _favorites.length,
                        itemBuilder: (context, index) {
                          final favorite = _favorites[index];
                          final target = favorite.target;
                          final key = _favoriteKey(favorite);
                          final isRemoving = _removingKeys.contains(key);

                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.star),
                              title: Text(_targetLabel(target)),
                              subtitle: Text(
                                'ID: ${target.id}\nSaved at: ${_formatDateTime(favorite.createdAt)}',
                              ),
                              isThreeLine: true,
                              onTap: isRemoving
                                  ? null
                                  : () => _openDetail(context, target),
                              trailing: isRemoving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : IconButton(
                                      tooltip: 'Remove favorite',
                                      onPressed: () =>
                                          _removeFavorite(favorite),
                                      icon: const Icon(Icons.star_border),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
