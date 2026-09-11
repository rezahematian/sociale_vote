import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/shared/branding/social_vote_brand_assets.dart';
import 'package:sociale_vote/shared/widgets/social_vote_brand_lockup.dart';

void main() {
  testWidgets('header stays a single static master for every legacy effect',
      (tester) async {
    for (final effect in [null, ...SocialVoteBrandEffect.values]) {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: SocialVoteHeaderBrand(effect: effect)),
      ));
      await tester.pumpAndSettle();
      final images = find.descendant(
        of: find.byType(SocialVoteHeaderBrand),
        matching: find.byType(Image),
      );
      expect(images, findsOneWidget);
      final image = tester.widget<Image>(images);
      expect((image.image as AssetImage).assetName,
          SocialVoteBrandAssets.headerLockup);
      await tester.pump(const Duration(seconds: 4));
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
    }
  });
}
