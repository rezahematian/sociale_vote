import '../entities/geo_point.dart';
import '../entities/resolved_scope.dart';
import '../repositories/geo_resolver.dart';

class ResolveScopeFromPoint {
  final GeoResolver _resolver;

  ResolveScopeFromPoint(this._resolver);

  Future<ResolvedScope> call(GeoPoint point) {
    return _resolver.resolveScopeFromPoint(point);
  }
}