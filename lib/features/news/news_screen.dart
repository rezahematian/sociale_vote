import 'package:flutter/material.dart';
import 'news_controller.dart';
import 'news_card.dart';
import 'news_item.dart';

class NewsScreen extends StatefulWidget {
  final NewsController controller;
  final String languageCode;
  final String countryCode;

  /// Ambito geografico
  final NewsScope scope;

  /// Usato solo per city
  final String? locationId;

  const NewsScreen({
    super.key,
    required this.controller,
    required this.languageCode,
    required this.countryCode,
    required this.scope,
    this.locationId,
  });

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadOnce();
  }

  @override
  void didUpdateWidget(covariant NewsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final scopeChanged = oldWidget.scope != widget.scope;
    final locationChanged =
        oldWidget.locationId != widget.locationId;

    if (scopeChanged || locationChanged) {
      _loaded = false;
      _loadOnce();
    }
  }

  void _loadOnce() {
    if (_loaded) return;
    _loaded = true;

    switch (widget.scope) {
      case NewsScope.city:
        assert(
          widget.locationId != null && widget.locationId!.isNotEmpty,
          'NewsScreen: locationId è obbligatorio per scope city',
        );
        widget.controller.loadCityNews(
          languageCode: widget.languageCode,
          countryCode: widget.countryCode,
          cityId: widget.locationId!,
        );
        break;

      case NewsScope.country:
        widget.controller.loadCountryNews(
          languageCode: widget.languageCode,
          countryCode: widget.countryCode,
        );
        break;

      case NewsScope.global:
      default:
        widget.controller.loadGlobalNews(
          languageCode: widget.languageCode,
          countryCode: widget.countryCode,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final items = widget.controller.items;

        return Scaffold(
          backgroundColor: const Color(0xFFF2F3F5),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.white,
            title: Text(
              _title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            leading: const BackButton(color: Colors.black),
          ),
          body: SafeArea(
            child: !_loaded
                ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : items.isEmpty
                    ? const _EmptyState()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                20, 12, 20, 8),
                            child: Text(
                              _subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                  0, 8, 0, 32),
                              itemCount: items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 6),
                              itemBuilder: (context, index) {
                                final item = items[index];

                                return NewsCard(
                                  news: item,
                                  onHot: () => widget.controller
                                      .toggleHot(item),
                                  onCold: () => widget.controller
                                      .toggleCold(item),
                                  onReset: () => widget.controller
                                      .resetVote(item),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
          ),
        );
      },
    );
  }

  // =========================================================
  // COPY
  // =========================================================

  String get _title {
    switch (widget.scope) {
      case NewsScope.city:
        return 'News locali';
      case NewsScope.country:
        return 'News nazionali';
      case NewsScope.global:
      default:
        return 'News dal mondo';
    }
  }

  String get _subtitle {
    switch (widget.scope) {
      case NewsScope.city:
        return 'Aggiornamenti civici della città';
      case NewsScope.country:
        return 'Aggiornamenti civici del paese';
      case NewsScope.global:
      default:
        return 'Aggiornamenti civici globali';
    }
  }
}

// ================= EMPTY STATE =================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.public_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Nessuna news disponibile',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Non ci sono ancora notizie civiche\nper quest’area geografica.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
