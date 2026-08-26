import 'package:flutter/material.dart';
import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/geo/entities/follow_scope.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

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

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.profileMyFollowedScopesTitle),
        ),
        body: Center(
          child: Text(l10n.profileFollowedScopesLoginRequired),
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
                    l10n.profileFollowedScopesEmpty,
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
    final l10n = AppLocalizations.of(context)!;
    switch (scope.level.name) {
      case 'world':
        return l10n.profileFollowedScopeWorld;
      case 'country':
        return l10n.profileFollowedScopeCountry(scope.countryCode ?? '');
      case 'city':
        return l10n.profileFollowedScopeCity(scope.cityId ?? '');
      case 'area':
        return l10n.profileFollowedScopeArea(scope.radiusKm ?? 0);
      default:
        return scope.level.name;
    }
  }
}
