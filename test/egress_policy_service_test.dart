import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/shared/services/egress_policy_service.dart';

void main() {
  group('EgressPolicyService policy contracts', () {
    test('automatic daily budgets are bounded and emergency is zero', () {
      expect(
        EgressPolicyService.dailyBudgetBytesFor(EgressMode.normal),
        20 * 1024 * 1024,
      );
      expect(
        EgressPolicyService.dailyBudgetBytesFor(EgressMode.conservative),
        8 * 1024 * 1024,
      );
      expect(
        EgressPolicyService.dailyBudgetBytesFor(EgressMode.emergency),
        0,
      );
    });

    test('news fallback never scans the former sixty payloads', () {
      expect(
        EgressPolicyService.newsFallbackScanLimitFor(EgressMode.normal),
        6,
      );
      expect(
        EgressPolicyService.newsFallbackScanLimitFor(
          EgressMode.conservative,
        ),
        3,
      );
      expect(
        EgressPolicyService.newsFallbackScanLimitFor(EgressMode.emergency),
        1,
      );
    });

    test('session polling is adaptive and disabled in emergency', () {
      expect(
        EgressPolicyService.sessionRefreshDelayFor(
          mode: EgressMode.normal,
          activity: EgressSessionActivity.active,
        ),
        const Duration(seconds: 5),
      );
      expect(
        EgressPolicyService.sessionRefreshDelayFor(
          mode: EgressMode.conservative,
          activity: EgressSessionActivity.waiting,
        ),
        const Duration(seconds: 30),
      );
      expect(
        EgressPolicyService.sessionRefreshDelayFor(
          mode: EgressMode.emergency,
          activity: EgressSessionActivity.active,
        ),
        isNull,
      );
    });
  });
}
