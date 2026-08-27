import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/shared/services/world_marker_policy_service.dart';

void main() {
  group('WorldMarkerPolicyService Home marker budget', () {
    test('zero density produces an empty Home Globe', () {
      expect(WorldMarkerPolicyService.homeMarkerLimitFor(0), 0);
    });

    test('positive density always produces at least one marker slot', () {
      expect(WorldMarkerPolicyService.homeMarkerLimitFor(1), 1);
    });

    test('default density preserves the previous nine-marker baseline', () {
      expect(
        WorldMarkerPolicyService.homeMarkerLimitFor(
          WorldMarkerPolicyService.defaultDensity,
        ),
        9,
      );
    });

    test('full density respects the hard Home safety ceiling', () {
      expect(
        WorldMarkerPolicyService.homeMarkerLimitFor(100),
        WorldMarkerPolicyService.maxHomeMarkerBudget,
      );
    });
  });
}
