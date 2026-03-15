import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';

abstract class DeviceLocationRepository {
  Future<bool> isLocationServiceEnabled();

  Future<bool> hasPermission();

  Future<bool> requestPermission();

  Future<ContentLocation?> getCurrentContentLocation();
}
