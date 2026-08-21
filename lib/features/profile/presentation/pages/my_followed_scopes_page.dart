import 'package:flutter/material.dart';
import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/geo/entities/follow_scope.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/app/localization/de_fallback.dart';

class MyFollowedScopesPage extends StatefulWidget {
  const MyFollowedScopesPage({super.key});

  @override
  State<MyFollowedScopesPage> createState() => _MyFollowedScopesPageState();
}

class _MyFollowedScopesPageState extends State<MyFollowedScopesPage> {
  bool _isLoading = true;
  List<GeoScope> _scopes = [];

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

    final List<FollowScope> result =
        await AppDI.instance.getFollowedScopesForUser(userId);

    setState(() {
      _scopes = result.map((e) => e.scope).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = AppDI.instance.currentUserId;
    final l10n = AppLocalizations.of(context)!;
    final isItalian = Localizations.localeOf(context).languageCode == 'it';

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.profileMyFollowedScopesTitle),
        ),
        body: Center(
          child: Text(isItalian
              ? 'Devi accedere.'
              : deOrEnglish(context,
                  english: 'You must be logged in.',
                  german: 'Du musst angemeldet sein.')),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileMyFollowedScopesTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _scopes.isEmpty
              ? Center(
                  child: Text(
                    isItalian
                        ? 'Non stai ancora seguendo nessuna area.'
                        : deOrEnglish(context,
                            english: 'You are not following any areas yet.',
                            german: 'Du folgst noch keinen Bereichen.'),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _scopes.length,
                  itemBuilder: (context, index) {
                    final scope = _scopes[index];

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.public),
                        title: Text(_buildScopeLabel(context, scope)),
                      ),
                    );
                  },
                ),
    );
  }

  String _buildScopeLabel(BuildContext context, GeoScope scope) {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';
    switch (scope.level.name) {
      case 'world':
        return isItalian
            ? 'Mondo'
            : deOrEnglish(context, english: 'World', german: 'Welt');

      case 'country':
        return '${isItalian ? 'Paese' : deOrEnglish(context, english: 'Country', german: 'Land')}: ${scope.countryCode}';

      case 'city':
        return '${isItalian ? 'Città' : deOrEnglish(context, english: 'City', german: 'Stadt')}: ${scope.cityId}';

      case 'area':
        return '${isItalian ? 'Area' : deOrEnglish(context, english: 'Area', german: 'Gebiet')} (${scope.radiusKm} km)';

      default:
        return scope.level.name;
    }
  }
}
