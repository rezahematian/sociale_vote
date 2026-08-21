import 'package:flutter/material.dart';
import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/engagement/entities/favorite.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/features/news/presentation/pages/news_detail_page.dart';
import 'package:sociale_vote/features/poll/presentation/pages/poll_detail_page.dart';
import 'package:sociale_vote/features/social/presentation/pages/post_detail_page.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/app/localization/de_fallback.dart';

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

  bool get _isItalian =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'it';

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
        _errorMessage = _isItalian
            ? 'Impossibile caricare i preferiti.'
            : deOrEnglish(context,
                english: 'Unable to load favorites.',
                german: 'Favoriten konnten nicht geladen werden.');
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
        SnackBar(
            content: Text(_isItalian
                ? 'Rimosso dai preferiti'
                : deOrEnglish(context,
                    english: 'Removed from favorites',
                    german: 'Aus Favoriten entfernt'))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_isItalian
                ? 'Impossibile rimuovere il preferito'
                : deOrEnglish(context,
                    english: 'Unable to remove favorite',
                    german: 'Favorit konnte nicht entfernt werden'))),
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
            SnackBar(
                content: Text(_isItalian
                    ? 'Impossibile aprire il dettaglio della notizia'
                    : deOrEnglish(context,
                        english: 'Unable to open news detail',
                        german:
                            'Nachrichtendetails konnten nicht geöffnet werden.'))),
          );
        }
        break;

      case TargetType.video:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_isItalian
                  ? 'Il dettaglio video non è ancora disponibile'
                  : deOrEnglish(context,
                      english: 'Video detail is not available yet',
                      german: 'Videodetails sind noch nicht verfügbar.'))),
        );
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_isItalian
                  ? 'Tipo di preferito non supportato'
                  : deOrEnglish(context,
                      english: 'Unsupported favorite type',
                      german: 'Nicht unterstützter Favoritentyp'))),
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
        return _isItalian
            ? 'Sondaggio'
            : deOrEnglish(context, english: 'Poll', german: 'Umfrage');
      case TargetType.post:
        return 'Post';
      case TargetType.news:
        return _isItalian
            ? 'Notizia'
            : deOrEnglish(context, english: 'News', german: 'Nachrichten');
      case TargetType.video:
        return 'Video';
      default:
        return target.type.name.toUpperCase();
    }
  }

  String _formatDateTime(BuildContext context, DateTime value) {
    final local = value.toLocal();
    final material = MaterialLocalizations.of(context);
    final date = material.formatMediumDate(local);
    final time = material.formatTimeOfDay(
      TimeOfDay.fromDateTime(local),
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );
    return '$date $time';
  }

  @override
  Widget build(BuildContext context) {
    final userId = AppDI.instance.currentUserId;
    final l10n = AppLocalizations.of(context)!;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.profileMyFavoritesTitle)),
        body: Center(
          child: Text(_isItalian
              ? 'Devi accedere.'
              : deOrEnglish(context,
                  english: 'You must be logged in.',
                  german: 'Du musst angemeldet sein.')),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileMyFavoritesTitle)),
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
                          child: Text(_isItalian
                              ? 'Riprova'
                              : deOrEnglish(context,
                                  english: 'Retry',
                                  german: 'Erneut versuchen')),
                        ),
                      ],
                    ),
                  ),
                )
              : _favorites.isEmpty
                  ? RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        children: [
                          const SizedBox(height: 180),
                          Center(
                            child: Text(
                              _isItalian
                                  ? 'Non hai ancora preferiti.'
                                  : deOrEnglish(context,
                                      english: 'No favorites yet.',
                                      german: 'Noch keine Favoriten.'),
                            ),
                          ),
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
                                'ID: ${target.id}\n${_isItalian ? 'Salvato il' : deOrEnglish(context, english: 'Saved at', german: 'Gespeichert am')}: ${_formatDateTime(context, favorite.createdAt)}',
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
                                      tooltip: _isItalian
                                          ? 'Rimuovi preferito'
                                          : deOrEnglish(context,
                                              english: 'Remove favorite',
                                              german: 'Favorit entfernen'),
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
