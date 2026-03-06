import '../entities/geo_point.dart';
import '../entities/resolved_scope.dart';

abstract class GeoResolver {
  Future<ResolvedScope> resolveScopeFromPoint(GeoPoint point);
}