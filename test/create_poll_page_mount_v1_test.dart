import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sociale_vote/features/poll/application/create_poll_controller.dart';
import 'package:sociale_vote/features/poll/presentation/pages/create_poll_page.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/widgets/content_language_field.dart';

// Mounts the actual page, provider, controller and publishing-identity loader.
// Supabase HTTP and preferences are local fakes; no remote data is read/written.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final unexpectedRequests = <String>[];

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://create-page-test.invalid',
      anonKey: 'test-only-public-key',
      debug: false,
      httpClient: MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.path == '/rest/v1/rpc/organization_get_mine') {
          return http.Response('null', 200,
              headers: {'content-type': 'application/json'}, request: request);
        }
        unexpectedRequests.add('${request.method} ${request.url.path}');
        return http.Response('{"message":"Unexpected mock request"}', 500,
            headers: {'content-type': 'application/json'}, request: request);
      }),
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: false,
        detectSessionInUri: false,
      ),
    );
  });
  tearDownAll(() async => Supabase.instance.dispose());

  testWidgets('real CreatePollPage mounts and keeps language through rebuilds',
      (tester) async {
    final previousPlatform = foundation.debugDefaultTargetPlatformOverride;
    foundation.debugDefaultTargetPlatformOverride = foundation.TargetPlatform.linux;
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    try {
      Widget app(String language) => MaterialApp(
            locale: Locale(language),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const CreatePollPage(),
          );

      await tester.pumpWidget(app('it'));
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(CreatePollPage), findsOneWidget);
      expect(find.byType(ErrorWidget), findsNothing);

      final languageField = find.byType(ContentLanguageField);
      expect(languageField, findsOneWidget);
      final controller = tester.element(languageField).read<CreatePollController>();
      expect(controller.languageCode, 'it');

      // A user's choice must survive page and localization rebuilds.
      controller.setLanguageCode('fa');
      await tester.pumpAndSettle();
      await tester.pumpWidget(app('en'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.widget<ContentLanguageField>(languageField).selectedCode, 'fa');
      expect(identical(
          tester.element(languageField).read<CreatePollController>(), controller), isTrue);

      // A fresh page initializes from the current locale again.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(app('en'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.widget<ContentLanguageField>(languageField).selectedCode, 'en');
      expect(unexpectedRequests, isEmpty);
    } finally {
      try {
        await tester.pumpWidget(const SizedBox.shrink());
      } finally {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        foundation.debugDefaultTargetPlatformOverride = previousPlatform;
      }
    }
  });
}
