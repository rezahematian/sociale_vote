import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/services/poll_results_visibility_resolver.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_configuration.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';
import 'package:sociale_vote/domain/poll/value_objects/visibility_rules.dart';

void main() {
  const resolver = PollResultsVisibilityResolver();

  Poll poll(PollStatus status, ResultsVisibilityMode mode) => Poll(
        id: const PollId('closed-guest-aggregate-test'),
        title: 'Test visibility',
        type: PollType.singleChoice,
        status: status,
        options: const [],
        configuration: PollConfiguration(
          visibilityRules: VisibilityRules(resultsVisibility: mode),
        ),
      );

  test('afterVote: guest cannot see aggregates while open', () {
    expect(
      resolver.canShowResults(
        poll: poll(PollStatus.open, ResultsVisibilityMode.afterVote),
        userHasVoted: false,
      ),
      isFalse,
    );
  });

  test('afterVote: participant can see aggregates while open', () {
    expect(
      resolver.canShowResults(
        poll: poll(PollStatus.open, ResultsVisibilityMode.afterVote),
        userHasVoted: true,
      ),
      isTrue,
    );
  });

  test('afterVote: guest sees aggregates after closure', () {
    expect(
      resolver.canShowResults(
        poll: poll(PollStatus.closed, ResultsVisibilityMode.afterVote),
        userHasVoted: false,
      ),
      isTrue,
    );
  });

  test('afterVote: scheduled and draft remain hidden from non-voters', () {
    for (final status in [PollStatus.scheduled, PollStatus.draft]) {
      expect(
        resolver.canShowResults(
          poll: poll(status, ResultsVisibilityMode.afterVote),
          userHasVoted: false,
        ),
        isFalse,
      );
    }
  });

  test('afterClose: open hidden and closed visible as before', () {
    expect(
      resolver.canShowResults(
        poll: poll(PollStatus.open, ResultsVisibilityMode.afterClose),
        userHasVoted: false,
      ),
      isFalse,
    );
    expect(
      resolver.canShowResults(
        poll: poll(PollStatus.closed, ResultsVisibilityMode.afterClose),
        userHasVoted: false,
      ),
      isTrue,
    );
  });

  test('always: open remains visible', () {
    expect(
      resolver.canShowResults(
        poll: poll(PollStatus.open, ResultsVisibilityMode.always),
        userHasVoted: false,
      ),
      isTrue,
    );
  });

  test('afterVote: closed with participant also remains visible', () {
    expect(
      resolver.canShowResults(
        poll: poll(PollStatus.closed, ResultsVisibilityMode.afterVote),
        userHasVoted: true,
      ),
      isTrue,
    );
  });

  test('afterClose: nonclosed states remain hidden', () {
    for (final status in [PollStatus.draft, PollStatus.scheduled]) {
      expect(
        resolver.canShowResults(
          poll: poll(status, ResultsVisibilityMode.afterClose),
          userHasVoted: false,
        ),
        isFalse,
      );
    }
  });
}
