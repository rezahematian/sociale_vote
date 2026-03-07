import 'package:flutter/material.dart';
import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/engagement/entities/favorite.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';

import 'package:sociale_vote/features/poll/presentation/pages/poll_detail_page.dart';
import 'package:sociale_vote/features/news/presentation/pages/news_detail_page.dart';
import 'package:sociale_vote/features/social/presentation/pages/post_detail_page.dart';

class MyFavoritesPage extends StatefulWidget {
  const MyFavoritesPage({super.key});

  @override
  State<MyFavoritesPage> createState() => _MyFavoritesPageState();
}

class _MyFavoritesPageState extends State<MyFavoritesPage> {
  bool _isLoading = true;
  List<Favorite> _favorites = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = AppDI.instance.currentUserId;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final result = await AppDI.instance.favoriteRepository
        .getFavoritesForUser(userId);

    setState(() {
      _favorites = result;
      _isLoading = false;
    });
  }

  Future<void> _openDetail(BuildContext context, TargetRef target) async {
    switch (target.type) {
      case TargetType.poll:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                PollDetailPage(pollId: PollId(target.id)),
          ),
        );
        break;

      case TargetType.post:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                PostDetailPage(postId: target.id),
          ),
        );
        break;

      case TargetType.news:
        final news = await AppDI.instance
            .getNewsDetail(EntityId(target.id));

        if (!mounted) return;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NewsDetailPage(news: news),
          ),
        );
        break;

      default:
        break;
    }
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
          : _favorites.isEmpty
              ? const Center(
                  child: Text('No favorites yet.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final favorite = _favorites[index];
                    final target = favorite.target;

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.star),
                        title: Text(
                          '${target.type.name.toUpperCase()} - ${target.id}',
                        ),
                        subtitle: Text(
                          'Saved at: ${favorite.createdAt}',
                        ),
                        onTap: () => _openDetail(context, target),
                      ),
                    );
                  },
                ),
    );
  }
}