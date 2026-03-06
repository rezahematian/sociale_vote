import 'package:flutter/foundation.dart';

@immutable
class EntityId {
  final String value;

  const EntityId(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntityId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}