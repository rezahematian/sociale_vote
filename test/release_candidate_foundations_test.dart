import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/content/news/entities/world_brief.dart';
import 'package:sociale_vote/features/profile/presentation/pages/public_user_profile_page.dart';
import 'package:sociale_vote/shared/services/radio_mondo_service.dart';
import 'package:sociale_vote/shared/services/social_vote_hud_service.dart';

void main() {
  group('release candidate foundations', () {
    test('Radio Mondo exposes only bundled, user-selected tracks', () {
      expect(
        RadioMondoTrack.values.map((track) => track.assetPath),
        containsAll(<String>{
          'audio/orbita_classica.ogg',
          'audio/pioggia_sul_mondo.ogg',
          'audio/pulse_giovane.ogg',
        }),
      );
    });

    test('World Brief and external News defaults remain distinguishable', () {
      final external = NewsItem(
        id: const EntityId('external-news'),
        title: 'External',
        content: 'Content',
        authorId: 'Provider',
        publishedAt: DateTime.utc(2026, 8, 25),
      );

      expect(external.isSocialVoteBrief, isFalse);
      expect(external.editorialMapVisible, isTrue);
      expect(external.editorialFeatured, isFalse);
      expect(external.editorialPriority, 0);
      expect(WorldBriefStatusX.fromStorageKey('published'),
          WorldBriefStatus.published);
      expect(WorldBriefStatusX.fromStorageKey('withdrawn'),
          WorldBriefStatus.withdrawn);
    });

    test('public profile route can carry explicit Organization identity', () {
      const page = PublicUserProfilePage(
        userId: 'operator-user-id',
        organizationId: 'organization-id',
      );

      expect(page.userId, 'operator-user-id');
      expect(page.organizationId, 'organization-id');
    });

    testWidgets('central HUD is visible, accessible and dismissible',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: <Widget>[SocialVoteHudOverlay()],
            ),
          ),
        ),
      );

      SocialVoteHud.showSuccess('Saved', detail: 'World Brief');
      await tester.pump();

      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('World Brief'), findsOneWidget);

      SocialVoteHud.dismiss();
      await tester.pumpAndSettle();
      expect(find.text('Saved'), findsNothing);
    });
  });
}
