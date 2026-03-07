import 'package:flutter/material.dart';
import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/geo/entities/follow_scope.dart';

class MyFollowedScopesPage extends StatefulWidget {
  const MyFollowedScopesPage({super.key});

  @override
  State<MyFollowedScopesPage> createState() =>
      _MyFollowedScopesPageState();
}

class _MyFollowedScopesPageState
    extends State<MyFollowedScopesPage> {
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

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Followed Scopes'),
        ),
        body: const Center(
          child: Text('You must be logged in.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Followed Scopes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _scopes.isEmpty
              ? const Center(
                  child: Text('You are not following any scopes yet.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _scopes.length,
                  itemBuilder: (context, index) {
                    final scope = _scopes[index];

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.public),
                        title: Text(_buildScopeLabel(scope)),
                      ),
                    );
                  },
                ),
    );
  }

  String _buildScopeLabel(GeoScope scope) {
    switch (scope.level.name) {
      case 'world':
        return 'World';

      case 'country':
        return 'Country: ${scope.countryCode}';

      case 'city':
        return 'City: ${scope.cityId}';

      case 'area':
        return 'Area (${scope.radiusKm} km)';

      default:
        return scope.level.name;
    }
  }
}