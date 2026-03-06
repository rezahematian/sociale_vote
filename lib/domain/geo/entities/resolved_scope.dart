import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';

class ResolvedScope {
  final GeoScope scope;
  final String displayName;

  const ResolvedScope({
    required this.scope,
    required this.displayName,
  });
}