import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/features/poll/presentation/widgets/create_poll_selection_limits.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

void main() {
  test('multiple choice max follows filled answer inputs', () {
    final source = File(
      'lib/features/poll/presentation/pages/create_poll_page.dart',
    ).readAsStringSync();

    final form = source.indexOf('child: Consumer<CreatePollController>(');
    final votingModel = source.indexOf('l10n.createPollVotingModelTitle', form);
    final answers = source.indexOf('l10n.createPollOptionsTitle', votingModel);
    final addOption = source.indexOf('l10n.createPollAddOptionButton', answers);
    final selector = source.indexOf('CreatePollSelectionLimits(', answers);
    final participation =
        source.indexOf("_formMessage('stepParticipation')", answers);

    expect(form, greaterThanOrEqualTo(0));
    expect(votingModel, greaterThan(form));
    expect(answers, greaterThan(votingModel));
    expect(addOption, greaterThan(answers));
    expect(selector, greaterThan(addOption));
    expect(selector, lessThan(participation));
    expect(
        source
            .substring(votingModel, answers)
            .contains('CreatePollSelectionLimits('),
        isFalse);
    expect(
        source
            .substring(answers, participation)
            .contains('!controller.canConfigureSelectionLimits'),
        isTrue);
    expect(
        source
            .substring(answers, participation)
            .contains('controller.selectionLimit == 2'),
        isTrue);
    expect(
        source
            .substring(answers, participation)
            .contains("_formMessage('optionsMissing')"),
        isTrue);
    expect(
        source
            .substring(answers, participation)
            .contains('_selectionSummary(controller)'),
        isTrue);
  });

  testWidgets('with three responses, maximum 2 or 3 remains selectable',
      (tester) async {
    var maximum = 2;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => CreatePollSelectionLimits(
              maxSelections: maximum,
              selectionLimit: 3,
              enabled: true,
              onMaxChanged: (value) => setState(() => maximum = value),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('poll_max_selections')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3').last);
    await tester.pumpAndSettle();
    expect(maximum, 3);
  });
}
