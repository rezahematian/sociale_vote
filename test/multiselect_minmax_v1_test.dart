import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sociale_vote/domain/geo/repositories/geocoding_repository.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/poll_option.dart';
import 'package:sociale_vote/domain/poll/entities/vote.dart';
import 'package:sociale_vote/domain/poll/errors/unauthorized_vote_exception.dart';
import 'package:sociale_vote/domain/poll/repositories/poll_repository.dart';
import 'package:sociale_vote/domain/poll/repositories/vote_repository.dart';
import 'package:sociale_vote/domain/poll/usecases/create_poll.dart';
import 'package:sociale_vote/domain/poll/usecases/submit_vote.dart';
import 'package:sociale_vote/domain/poll/usecases/submit_vote_and_notify.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_configuration.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';
import 'package:sociale_vote/features/poll/application/create_poll_controller.dart';
import 'package:sociale_vote/features/poll/application/vote_controller.dart';
import 'package:sociale_vote/features/poll/presentation/widgets/create_poll_selection_limits.dart';
import 'package:sociale_vote/infrastructure/poll/mappers/poll_mapper.dart';
import 'package:sociale_vote/infrastructure/poll/models/poll_dto.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    foundation.debugDefaultTargetPlatformOverride =
        foundation.TargetPlatform.linux;
  });
  tearDown(() => foundation.debugDefaultTargetPlatformOverride = null);

  for (final maximum in [2, 3, 4]) {
    test('create and DTO reload preserve fixed 1..$maximum', () async {
      final repository = _PollStore();
      final controller = _creator(repository: repository);
      controller.setMaxSelections(maximum);
      final now = DateTime.now();
      controller.setTitle('Selection range');
      controller.setStartAt(now);
      controller.setEndAt(now.add(const Duration(days: 2)));
      expect(controller.canSubmit, isTrue);
      final id = await controller.submit();
      expect(id, isNotNull, reason: controller.errorMessage);
      final reloaded = await repository.getPollDetail(id!);
      expect(reloaded!.configuration.minSelections, 1);
      expect(reloaded.configuration.maxSelections, maximum);
    });
  }

  test('multiple-choice keeps minimum at 1 and rejects invalid maximums', () {
    final controller = _creator();
    controller.setMaxSelections(3);
    for (final attemptedMinimum in [0, -1, 2, 4, 8]) {
      controller.setMinSelections(attemptedMinimum);
      expect(controller.minSelections, 1);
      expect(controller.maxSelections, 3);
    }
    for (final invalidMaximum in [0, 1, 6]) {
      controller.setMaxSelections(invalidMaximum);
      expect(controller.minSelections, 1);
      expect(controller.maxSelections, 3);
    }
  });

  test('adding/removing/editing options preserves max and clamps shrink', () {
    final controller = _creator(optionCount: 4);
    controller.setMaxSelections(3);
    controller.setMinSelections(2);
    controller.addOption();
    expect((controller.minSelections, controller.maxSelections), (1, 3));
    controller.setOptionText(4, 'Fifth answer');
    controller.setOptionText(0, 'Renamed answer');
    controller.setType(PollType.multipleChoice);
    expect((controller.minSelections, controller.maxSelections), (1, 3));
    controller.removeOption(4);
    controller.removeOption(3);
    expect((controller.minSelections, controller.maxSelections), (1, 3));
    controller.removeOption(2);
    expect((controller.minSelections, controller.maxSelections), (1, 2));
    controller.setOptionText(1, '   ');
    expect((controller.minSelections, controller.maxSelections), (1, 1));
    expect(controller.canConfigureSelectionLimits, isFalse);
    expect(controller.canSubmit, isFalse);
    controller.setOptionText(1, 'Restored answer');
    expect((controller.minSelections, controller.maxSelections), (1, 2));
  });

  test('yes/no and single-choice stay 1..1', () {
    final controller = _creator();
    controller.setMinSelections(2);
    for (final type in [PollType.singleChoice, PollType.yesNo]) {
      controller.setType(type);
      controller.setMinSelections(2);
      controller.setMaxSelections(4);
      controller.addOption();
      expect((controller.minSelections, controller.maxSelections), (1, 1));
    }
  });

  test('voter cannot add above max, can deselect, and needs min for submit',
      () {
    final controller = VoteController(_NoSubmit());
    addTearDown(controller.dispose);
    final poll = _poll(2, 4);
    controller.toggleOption('a', allowMultiple: true, maxSelections: 4);
    expect(controller.hasValidSelectionCount(poll), isFalse);
    for (final id in ['b', 'c', 'd', 'e']) {
      controller.toggleOption(id, allowMultiple: true, maxSelections: 4);
    }
    expect(controller.selectedOptionIds, {'a', 'b', 'c', 'd'});
    expect(controller.hasValidSelectionCount(poll), isTrue);
    expect(
        controller.canSelectOption('e', allowMultiple: true, maxSelections: 4),
        isFalse);
    expect(
        controller.canSelectOption('a', allowMultiple: true, maxSelections: 4),
        isTrue);
    controller.toggleOption('a', allowMultiple: true, maxSelections: 4);
    controller.toggleOption('e', allowMultiple: true, maxSelections: 4);
    expect(controller.selectedOptionIds, {'b', 'c', 'd', 'e'});
    controller.reset();
    controller.toggleOption('a', allowMultiple: false, maxSelections: 1);
    controller.toggleOption('b', allowMultiple: false, maxSelections: 1);
    expect(controller.selectedOptionIds, {'b'});
  });

  for (final existing in [false, true]) {
    test(
        'domain blocks invalid selections before ${existing ? 'update' : 'insert'}',
        () async {
      final repository = _VoteStore()..alreadyVoted = existing;
      final submit = SubmitVote(repository);
      final poll = _poll(2, 4);
      for (final ids in <List<String>>[
        [],
        ['a'],
        ['a', 'b', 'c', 'd', 'e'],
        ['a', 'a'],
        ['a', 'unknown'],
      ]) {
        await expectLater(
          submit(Vote.now(pollId: poll.id, optionIds: ids),
              poll: poll, userId: 'voter', userCountryCode: null),
          throwsA(isA<UnauthorizedVoteException>()),
        );
      }
      expect(repository.writes, 0);
      for (final ids in <List<String>>[
        ['a', 'b'],
        ['a', 'b', 'c', 'd']
      ]) {
        await submit(Vote.now(pollId: poll.id, optionIds: ids),
            poll: poll, userId: 'voter', userCountryCode: null);
      }
      expect(repository.writes, 2);
      final single = _poll(1, 1, type: PollType.singleChoice);
      await submit(Vote.now(pollId: single.id, optionIds: ['a']),
          poll: single, userId: 'voter', userCountryCode: null);
      await expectLater(
        submit(Vote.now(pollId: single.id, optionIds: ['a', 'b']),
            poll: single, userId: 'voter', userCountryCode: null),
        throwsA(isA<UnauthorizedVoteException>()),
      );
      expect(repository.writes, 3);
    });
  }

  test('all 11 locales have parity and render the chosen limits', () {
    const locales = [
      'en',
      'it',
      'de',
      'fa',
      'ar',
      'es',
      'pt',
      'fr',
      'ro',
      'ru',
      'zh'
    ];
    Set<String>? reference;
    for (final language in locales) {
      final arb =
          jsonDecode(File('lib/l10n/app_$language.arb').readAsStringSync())
              as Map<String, dynamic>;
      final keys = arb.keys.where((key) => !key.startsWith('@')).toSet();
      reference ??= keys;
      expect(keys, reference, reason: language);
      final l10n = lookupAppLocalizations(Locale(language));
      expect(l10n.createPollMinimumAnswersLabel,
          arb['createPollMinimumAnswersLabel']);
      expect(l10n.createPollMaximumAnswersLabel,
          arb['createPollMaximumAnswersLabel']);
      expect(
          l10n.createPollSelectionRules(1, 4),
          (arb['createPollSelectionRules'] as String)
              .replaceAll('{min}', '1')
              .replaceAll('{max}', '4'));
    }
  });

  testWidgets('narrow creator UI keeps minimum fixed and changes maximum',
      (tester) async {
    try {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = _creator(optionCount: 4);
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
            body: Padding(
          padding: const EdgeInsets.all(16),
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) => Column(children: [
              CreatePollSelectionLimits(
                maxSelections: controller.maxSelections,
                selectionLimit: controller.selectionLimit,
                enabled: true,
                onMaxChanged: controller.setMaxSelections,
              ),
              Text(AppLocalizations.of(context)!.createPollSelectionRules(
                  controller.minSelections, controller.maxSelections)),
            ]),
          ),
        )),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Minimo risposte'), findsNothing);
      expect(find.byKey(const ValueKey('poll_min_selections')), findsNothing);
      expect(find.text('Massimo risposte'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('poll_max_selections')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('3').last);
      await tester.pumpAndSettle();
      expect((controller.minSelections, controller.maxSelections), (1, 3));
      expect(find.text('Chi vota può selezionare da 1 a 3 risposte.'),
          findsOneWidget);
      controller.removeOption(3);
      controller.removeOption(2);
      await tester.pumpAndSettle();
      expect((controller.minSelections, controller.maxSelections), (1, 2));
      expect(find.text('Chi vota può selezionare da 1 a 2 risposte.'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    } finally {
      // Flutter verifies foundation globals before the outer tearDown runs.
      foundation.debugDefaultTargetPlatformOverride = null;
    }
  });
}

CreatePollController _creator({int optionCount = 5, _PollStore? repository}) {
  final scope = GeoScopeController();
  final controller = CreatePollController(
    createPollUseCase: CreatePoll(repository ?? _PollStore()),
    geoScopeController: scope,
    createdByUserId: 'creator',
    geocodingRepository: _Geocoder(),
  );
  addTearDown(controller.dispose);
  addTearDown(scope.dispose);
  while (controller.options.length < optionCount) {
    controller.addOption();
  }
  for (var index = 0; index < optionCount; index++) {
    controller.setOptionText(index, 'Answer ${index + 1}');
  }
  controller.setType(PollType.multipleChoice);
  return controller;
}

Poll _poll(int min, int max, {PollType type = PollType.multipleChoice}) => Poll(
      id: const PollId('test-poll'),
      title: 'Test',
      type: type,
      status: PollStatus.open,
      options: [
        for (final id in ['a', 'b', 'c', 'd', 'e'])
          PollOption(id: id, label: id)
      ],
      configuration: PollConfiguration(
          minSelections: min, maxSelections: max, allowVoteChange: true),
    );

class _PollStore implements PollRepository {
  Map<String, dynamic>? stored;
  @override
  Future<bool> hasUserCreatedPollSince(
          {required String userId, required DateTime since}) async =>
      false;
  @override
  Future<Poll> createPoll(Poll poll) async {
    stored = jsonDecode(jsonEncode(PollMapper.toDto(poll).toJson()))
        as Map<String, dynamic>;
    return (await getPollDetail(poll.id))!;
  }

  @override
  Future<Poll?> getPollDetail(PollId pollId) async =>
      stored == null ? null : PollMapper.fromDto(PollDto.fromJson(stored!));
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Geocoder implements GeocodingRepository {
  @override
  Future<ContentLocation?> geocodeContentLocation(
          ContentLocation location) async =>
      location;
}

class _VoteStore implements VoteRepository {
  bool alreadyVoted = false;
  int writes = 0;
  @override
  Future<bool> hasCurrentUserVoted(PollId pollId) async => alreadyVoted;
  @override
  Future<void> submitVote(Vote vote) async {
    writes++;
  }

  @override
  Future<void> updateVote(Vote vote) async {
    writes++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoSubmit implements SubmitVoteAndNotify {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
