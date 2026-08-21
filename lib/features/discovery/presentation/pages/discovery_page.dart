import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/features/discovery/application/for_you_feed_controller.dart';
import 'package:sociale_vote/features/discovery/application/trending_controller.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_for_you_section.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_trending_section.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_account_connections_page.dart';
import 'package:sociale_vote/features/search/presentation/pages/search_page.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/app/localization/de_fallback.dart';

class DiscoveryPage extends StatefulWidget {
  final String scopeShortLabel;

  const DiscoveryPage({
    super.key,
    required this.scopeShortLabel,
  });

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  late final TrendingController _trendingController;
  ForYouFeedController? _forYouController;
  String? _userId;

  bool get _isAuthenticated => _userId != null;

  @override
  void initState() {
    super.initState();

    final rawUserId = AppDI.instance.currentUserId?.trim();
    _userId = rawUserId == null || rawUserId.isEmpty ? null : rawUserId;
    _trendingController = AppDI.instance.createTrendingController();

    if (_isAuthenticated) {
      _forYouController = AppDI.instance.createForYouFeedController()
        ..load(userId: _userId);
    }
  }

  @override
  void dispose() {
    _forYouController?.dispose();
    _trendingController.dispose();
    super.dispose();
  }

  Future<void> _openSearch() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const SearchPage(),
      ),
    );

    if (!mounted || !_isAuthenticated) {
      return;
    }

    await _forYouController?.load(userId: _userId);
  }

  Future<void> _openConnections() async {
    if (!_isAuthenticated) {
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const MyAccountConnectionsPage(),
      ),
    );

    if (!mounted) {
      return;
    }

    await _forYouController?.load(userId: _userId);
  }

  bool _isItalian(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'it';
  }

  String _forYouTabLabel(BuildContext context) {
    return _isItalian(context)
        ? 'Per te'
        : deOrEnglish(context, english: 'For You', german: 'Für dich');
  }

  String _forYouExplanation(BuildContext context) {
    if (_isItalian(context)) {
      return 'Combina account e aree che segui con attività, qualità e '
          'freschezza dei contenuti. Seguire un account aggiorna questo feed.';
    }

    return deOrEnglish(
      context,
      english:
          'Combines accounts and areas you follow with content activity, quality and freshness. Following an account updates this feed.',
      german:
          'Kombiniert Konten und Bereiche, denen du folgst, mit Aktivität, Qualität und Aktualität der Inhalte. Wenn du einem Konto folgst, wird dieser Feed aktualisiert.',
    );
  }

  String _trendingExplanation(BuildContext context) {
    if (_isItalian(context)) {
      return 'Mostra i contenuti con più attività nello scope '
          '${widget.scopeShortLabel}. I follow account non modificano questa '
          'classifica.';
    }

    return deOrEnglish(
      context,
      english:
          'Shows the most active content in ${widget.scopeShortLabel}. Account follows do not change this ranking.',
      german:
          'Zeigt die aktivsten Inhalte in ${widget.scopeShortLabel}. Gefolgte Konten verändern diese Rangfolge nicht.',
    );
  }

  Widget _buildForYouTab() {
    return ChangeNotifierProvider<ForYouFeedController>.value(
      value: _forYouController!,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: HomeForYouSection(
          scopeShortLabel: widget.scopeShortLabel,
          maxItems: null,
          explanation: _forYouExplanation(context),
        ),
      ),
    );
  }

  Widget _buildTrendingTab() {
    return ChangeNotifierProvider<TrendingController>.value(
      value: _trendingController,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: HomeTrendingSection(
          maxItems: null,
          explanation: _trendingExplanation(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final appBarTitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(l10n.discoveryPageTitle),
        Text(
          widget.scopeShortLabel,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );

    final actions = <Widget>[
      IconButton(
        tooltip: l10n.searchPageTitle,
        onPressed: _openSearch,
        icon: const Icon(Icons.person_search_outlined),
      ),
      if (_isAuthenticated)
        IconButton(
          tooltip: l10n.profileAccountConnectionsTitle,
          onPressed: _openConnections,
          icon: const Icon(Icons.people_outline_rounded),
        ),
    ];

    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: appBarTitle,
          actions: actions,
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: _buildTrendingTab(),
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: appBarTitle,
          actions: actions,
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                icon: const Icon(Icons.auto_awesome_outlined),
                text: _forYouTabLabel(context),
              ),
              Tab(
                icon: const Icon(Icons.local_fire_department_outlined),
                text: l10n.homeTrendingTitle,
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: TabBarView(
                children: <Widget>[
                  _buildForYouTab(),
                  _buildTrendingTab(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
