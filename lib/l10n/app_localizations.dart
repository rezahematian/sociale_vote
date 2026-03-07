import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Sociale Vote'**
  String get appTitle;

  /// No description provided for @voteButton.
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get voteButton;

  /// No description provided for @createPollPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Poll'**
  String get createPollPageTitle;

  /// No description provided for @createPollPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Define a new civic vote'**
  String get createPollPageSubtitle;

  /// No description provided for @createPollBasicInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Basic information'**
  String get createPollBasicInfoTitle;

  /// No description provided for @createPollBasicInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Define the main details of the poll.'**
  String get createPollBasicInfoSubtitle;

  /// No description provided for @createPollTitleFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get createPollTitleFieldLabel;

  /// No description provided for @createPollTitleFieldHelper.
  ///
  /// In en, this message translates to:
  /// **'A clear, concise question or statement.'**
  String get createPollTitleFieldHelper;

  /// No description provided for @createPollDescriptionFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get createPollDescriptionFieldLabel;

  /// No description provided for @createPollVotingModelTitle.
  ///
  /// In en, this message translates to:
  /// **'Voting model'**
  String get createPollVotingModelTitle;

  /// No description provided for @createPollVotingModelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how people will express their vote and basic rules.'**
  String get createPollVotingModelSubtitle;

  /// No description provided for @createPollTypeFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Poll type'**
  String get createPollTypeFieldLabel;

  /// No description provided for @createPollSelectionRules.
  ///
  /// In en, this message translates to:
  /// **'Selection rules: minimum {min}, maximum {max} selections (automatically adjusted based on poll type and options).'**
  String createPollSelectionRules(int min, int max);

  /// No description provided for @createPollAllowVoteChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow voters to change their vote'**
  String get createPollAllowVoteChangeTitle;

  /// No description provided for @createPollAllowVoteChangeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Until the poll is closed.'**
  String get createPollAllowVoteChangeSubtitle;

  /// No description provided for @createPollOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get createPollOptionsTitle;

  /// No description provided for @createPollOptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add at least two options for voters to choose from. Fields marked with * are mandatory.'**
  String get createPollOptionsSubtitle;

  /// No description provided for @createPollOptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Option {index}{requiredMarker}'**
  String createPollOptionLabel(int index, Object requiredMarker);

  /// No description provided for @createPollRemoveOptionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove option'**
  String get createPollRemoveOptionTooltip;

  /// No description provided for @createPollAddOptionButton.
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get createPollAddOptionButton;

  /// No description provided for @createPollParticipationPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Participation & privacy'**
  String get createPollParticipationPrivacyTitle;

  /// No description provided for @createPollParticipationPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Decide who can vote and how private the votes should be.'**
  String get createPollParticipationPrivacySubtitle;

  /// No description provided for @createPollWhoCanVoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Who can vote?'**
  String get createPollWhoCanVoteLabel;

  /// No description provided for @createPollParticipationEveryoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Any registered user can participate.'**
  String get createPollParticipationEveryoneSubtitle;

  /// No description provided for @createPollParticipationGeoScopeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Limit this poll to people from a specific country.'**
  String get createPollParticipationGeoScopeSubtitle;

  /// No description provided for @createPollCountryFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Country for this poll'**
  String get createPollCountryFieldLabel;

  /// No description provided for @createPollCountryFieldHelper.
  ///
  /// In en, this message translates to:
  /// **'This country will define who is allowed to participate in this poll (future backend integration).'**
  String get createPollCountryFieldHelper;

  /// No description provided for @createPollVoteAnonymityTitle.
  ///
  /// In en, this message translates to:
  /// **'Vote anonymity'**
  String get createPollVoteAnonymityTitle;

  /// No description provided for @createPollAnonymityAnonymousSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended default for civic voting platforms.'**
  String get createPollAnonymityAnonymousSubtitle;

  /// No description provided for @createPollAnonymityPublicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use with caution: votes may be associated with identities (future feature).'**
  String get createPollAnonymityPublicSubtitle;

  /// No description provided for @createPollResultsValidityTitle.
  ///
  /// In en, this message translates to:
  /// **'Results & validity'**
  String get createPollResultsValidityTitle;

  /// No description provided for @createPollResultsValiditySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Control when results are visible and define minimum quorum if needed.'**
  String get createPollResultsValiditySubtitle;

  /// No description provided for @createPollResultsVisibilityFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Results visibility'**
  String get createPollResultsVisibilityFieldLabel;

  /// No description provided for @createPollQuorumTitle.
  ///
  /// In en, this message translates to:
  /// **'Quorum (optional)'**
  String get createPollQuorumTitle;

  /// No description provided for @createPollQuorumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If set, the poll is considered valid only if at least this number of votes is reached. Leave empty for no quorum.'**
  String get createPollQuorumSubtitle;

  /// No description provided for @createPollQuorumMinVotesFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum number of votes'**
  String get createPollQuorumMinVotesFieldLabel;

  /// No description provided for @createPollTimingTitle.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
  String get createPollTimingTitle;

  /// No description provided for @createPollTimingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Define when the poll should be open for voting.'**
  String get createPollTimingSubtitle;

  /// No description provided for @createPollStartDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get createPollStartDateLabel;

  /// No description provided for @createPollEndDateLabel.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get createPollEndDateLabel;

  /// No description provided for @createPollChangeDateButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get createPollChangeDateButtonLabel;

  /// No description provided for @createPollTimingStatusInfo.
  ///
  /// In en, this message translates to:
  /// **'The initial status (open/scheduled/closed) will be determined automatically based on these dates.'**
  String get createPollTimingStatusInfo;

  /// No description provided for @createPollSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Poll created successfully'**
  String get createPollSuccessMessage;

  /// No description provided for @createPollSubmitCreatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get createPollSubmitCreatingLabel;

  /// No description provided for @createPollSubmitLabel.
  ///
  /// In en, this message translates to:
  /// **'Create poll'**
  String get createPollSubmitLabel;

  /// No description provided for @createPollPollTypeYesNoLabel.
  ///
  /// In en, this message translates to:
  /// **'Yes / No'**
  String get createPollPollTypeYesNoLabel;

  /// No description provided for @createPollPollTypeSingleChoiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Single choice'**
  String get createPollPollTypeSingleChoiceLabel;

  /// No description provided for @createPollPollTypeMultipleChoiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Multiple choice'**
  String get createPollPollTypeMultipleChoiceLabel;

  /// No description provided for @createPollPollTypeApprovalLabel.
  ///
  /// In en, this message translates to:
  /// **'Approval voting'**
  String get createPollPollTypeApprovalLabel;

  /// No description provided for @createPollPollTypeRankedLabel.
  ///
  /// In en, this message translates to:
  /// **'Ranked choice'**
  String get createPollPollTypeRankedLabel;

  /// No description provided for @createPollPollTypeScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score / Rating'**
  String get createPollPollTypeScoreLabel;

  /// No description provided for @createPollParticipationScopeEveryoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Everyone can vote'**
  String get createPollParticipationScopeEveryoneLabel;

  /// No description provided for @createPollParticipationScopeGeoScopeOnlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Only users in a specific country'**
  String get createPollParticipationScopeGeoScopeOnlyLabel;

  /// No description provided for @createPollAnonymityLevelAnonymousLabel.
  ///
  /// In en, this message translates to:
  /// **'Votes are anonymous'**
  String get createPollAnonymityLevelAnonymousLabel;

  /// No description provided for @createPollAnonymityLevelPublicLabel.
  ///
  /// In en, this message translates to:
  /// **'Votes are public (advanced / restricted use)'**
  String get createPollAnonymityLevelPublicLabel;

  /// No description provided for @createPollResultsVisibilityAlwaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Always visible (while poll is open)'**
  String get createPollResultsVisibilityAlwaysLabel;

  /// No description provided for @createPollResultsVisibilityAfterVoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Only visible after voting'**
  String get createPollResultsVisibilityAfterVoteLabel;

  /// No description provided for @createPollResultsVisibilityAfterCloseLabel.
  ///
  /// In en, this message translates to:
  /// **'Only visible after poll is closed'**
  String get createPollResultsVisibilityAfterCloseLabel;

  /// No description provided for @homeLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get homeLoginButton;

  /// No description provided for @homeRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get homeRegisterButton;

  /// No description provided for @homeProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get homeProfileButton;

  /// No description provided for @homeLogoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get homeLogoutButton;

  /// No description provided for @homeLogoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Logout completed. You are now using the app as a guest (read-only).'**
  String get homeLogoutMessage;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search city, country, polls, news, posts...'**
  String get homeSearchHint;

  /// No description provided for @homeUserStatusLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Logged in as: {userId}'**
  String homeUserStatusLoggedIn(Object userId);

  /// No description provided for @homeUserStatusGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest mode: you can only read. Log in or register to vote, comment and react.'**
  String get homeUserStatusGuest;

  /// No description provided for @homeScopeLabelWorld.
  ///
  /// In en, this message translates to:
  /// **'World – Global votes and news'**
  String get homeScopeLabelWorld;

  /// No description provided for @homeScopeLabelCountry.
  ///
  /// In en, this message translates to:
  /// **'Country – National votes and news'**
  String get homeScopeLabelCountry;

  /// No description provided for @homeScopeLabelCity.
  ///
  /// In en, this message translates to:
  /// **'City – Local city votes and news'**
  String get homeScopeLabelCity;

  /// No description provided for @homeScopeShortWorld.
  ///
  /// In en, this message translates to:
  /// **'World'**
  String get homeScopeShortWorld;

  /// No description provided for @homeScopeShortCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get homeScopeShortCountry;

  /// No description provided for @homeScopeShortCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get homeScopeShortCity;

  /// No description provided for @homeScopeChipWorld.
  ///
  /// In en, this message translates to:
  /// **'World'**
  String get homeScopeChipWorld;

  /// No description provided for @homeScopeChipItaly.
  ///
  /// In en, this message translates to:
  /// **'Italy'**
  String get homeScopeChipItaly;

  /// No description provided for @homeScopeChipTorino.
  ///
  /// In en, this message translates to:
  /// **'Torino'**
  String get homeScopeChipTorino;

  /// No description provided for @homeScopeChangedWorld.
  ///
  /// In en, this message translates to:
  /// **'Scope changed to World'**
  String get homeScopeChangedWorld;

  /// No description provided for @homeScopeChangedItaly.
  ///
  /// In en, this message translates to:
  /// **'Scope changed to Italy'**
  String get homeScopeChangedItaly;

  /// No description provided for @homeScopeChangedTorino.
  ///
  /// In en, this message translates to:
  /// **'Scope changed to Torino'**
  String get homeScopeChangedTorino;

  /// No description provided for @followScopeButtonFollowed.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followScopeButtonFollowed;

  /// No description provided for @followScopeButtonFollow.
  ///
  /// In en, this message translates to:
  /// **'Follow this area'**
  String get followScopeButtonFollow;

  /// No description provided for @homeTrendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Trending now'**
  String get homeTrendingTitle;

  /// No description provided for @homeTrendingError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load trending content for this area.'**
  String get homeTrendingError;

  /// No description provided for @homeTrendingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No trending content for this scope at the moment.'**
  String get homeTrendingEmpty;

  /// No description provided for @homeForYouTitle.
  ///
  /// In en, this message translates to:
  /// **'For You ({scope})'**
  String homeForYouTitle(Object scope);

  /// No description provided for @homeForYouError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load the \"For You\" feed for this area.'**
  String get homeForYouError;

  /// No description provided for @homeForYouEmpty.
  ///
  /// In en, this message translates to:
  /// **'No suggested \"For You\" content for this scope at the moment.'**
  String get homeForYouEmpty;

  /// No description provided for @homePollsTitle.
  ///
  /// In en, this message translates to:
  /// **'Highlighted Polls ({scope})'**
  String homePollsTitle(Object scope);

  /// No description provided for @homePollsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No polls for this area'**
  String get homePollsEmptyTitle;

  /// No description provided for @homePollsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'There are no polls for this scope.'**
  String get homePollsEmptySubtitle;

  /// No description provided for @homePollsViewAllButton.
  ///
  /// In en, this message translates to:
  /// **'View all polls'**
  String get homePollsViewAllButton;

  /// No description provided for @homeNewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Top News ({scope})'**
  String homeNewsTitle(Object scope);

  /// No description provided for @homeNewsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load news'**
  String get homeNewsErrorTitle;

  /// No description provided for @homeNewsErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'There was a problem loading the news for this area.'**
  String get homeNewsErrorSubtitle;

  /// No description provided for @homeNewsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No news for this area'**
  String get homeNewsEmptyTitle;

  /// No description provided for @homeNewsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'There are no news items for this scope at the moment.'**
  String get homeNewsEmptySubtitle;

  /// No description provided for @homeNewsViewAllButton.
  ///
  /// In en, this message translates to:
  /// **'View all news'**
  String get homeNewsViewAllButton;

  /// No description provided for @homeNewsBreakingBadge.
  ///
  /// In en, this message translates to:
  /// **'BREAKING'**
  String get homeNewsBreakingBadge;

  /// No description provided for @homeSocialTitle.
  ///
  /// In en, this message translates to:
  /// **'Discussions / Feed ({scope})'**
  String homeSocialTitle(Object scope);

  /// No description provided for @homeSocialErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load discussions'**
  String get homeSocialErrorTitle;

  /// No description provided for @homeSocialErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'There was a problem loading the social feed for this area.'**
  String get homeSocialErrorSubtitle;

  /// No description provided for @homeSocialEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No discussions for this area'**
  String get homeSocialEmptyTitle;

  /// No description provided for @homeSocialEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'There are no discussions for this scope at the moment.'**
  String get homeSocialEmptySubtitle;

  /// No description provided for @homeSocialViewFeedButton.
  ///
  /// In en, this message translates to:
  /// **'View social feed'**
  String get homeSocialViewFeedButton;

  /// No description provided for @pollDetail_title.
  ///
  /// In en, this message translates to:
  /// **'Poll detail'**
  String get pollDetail_title;

  /// No description provided for @pollDetail_removeFromFavoritesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get pollDetail_removeFromFavoritesTooltip;

  /// No description provided for @pollDetail_addToFavoritesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get pollDetail_addToFavoritesTooltip;

  /// No description provided for @pollDetail_chipAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous vote'**
  String get pollDetail_chipAnonymous;

  /// No description provided for @pollDetail_chipPublic.
  ///
  /// In en, this message translates to:
  /// **'Public vote'**
  String get pollDetail_chipPublic;

  /// No description provided for @pollDetail_chipRestrictedGeo.
  ///
  /// In en, this message translates to:
  /// **'Restricted to geographic scope'**
  String get pollDetail_chipRestrictedGeo;

  /// No description provided for @pollDetail_quorumReached.
  ///
  /// In en, this message translates to:
  /// **'Quorum reached ({currentVotes} / {requiredVotes})'**
  String pollDetail_quorumReached(int currentVotes, int requiredVotes);

  /// No description provided for @pollDetail_quorumNotReached.
  ///
  /// In en, this message translates to:
  /// **'Quorum not reached ({currentVotes} / {requiredVotes})'**
  String pollDetail_quorumNotReached(int currentVotes, int requiredVotes);

  /// No description provided for @pollDetail_optionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get pollDetail_optionsTitle;

  /// No description provided for @pollDetail_statusClosedMessage.
  ///
  /// In en, this message translates to:
  /// **'This poll is closed.'**
  String get pollDetail_statusClosedMessage;

  /// No description provided for @pollDetail_statusScheduledMessage.
  ///
  /// In en, this message translates to:
  /// **'This poll is not yet open.'**
  String get pollDetail_statusScheduledMessage;

  /// No description provided for @pollDetail_statusNotAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Voting is not available.'**
  String get pollDetail_statusNotAvailableMessage;

  /// No description provided for @pollDetail_voteSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Vote submitted successfully!'**
  String get pollDetail_voteSubmitted;

  /// No description provided for @pollDetail_voteButton.
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get pollDetail_voteButton;

  /// No description provided for @pollDetail_resultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get pollDetail_resultsTitle;

  /// No description provided for @pollDetail_outcomePrefix.
  ///
  /// In en, this message translates to:
  /// **'Outcome: {label}'**
  String pollDetail_outcomePrefix(Object label);

  /// No description provided for @pollDetail_noResults.
  ///
  /// In en, this message translates to:
  /// **'No results available yet.'**
  String get pollDetail_noResults;

  /// No description provided for @pollDetail_resultsAfterVote.
  ///
  /// In en, this message translates to:
  /// **'Results will be visible after you vote.'**
  String get pollDetail_resultsAfterVote;

  /// No description provided for @pollDetail_resultsWhenClosed.
  ///
  /// In en, this message translates to:
  /// **'Results will be visible when the poll is closed.'**
  String get pollDetail_resultsWhenClosed;

  /// No description provided for @pollType_yesNo.
  ///
  /// In en, this message translates to:
  /// **'Yes / No'**
  String get pollType_yesNo;

  /// No description provided for @pollType_singleChoice.
  ///
  /// In en, this message translates to:
  /// **'Single choice'**
  String get pollType_singleChoice;

  /// No description provided for @pollType_multipleChoice.
  ///
  /// In en, this message translates to:
  /// **'Multiple choice'**
  String get pollType_multipleChoice;

  /// No description provided for @pollType_approval.
  ///
  /// In en, this message translates to:
  /// **'Approval'**
  String get pollType_approval;

  /// No description provided for @pollStatus_draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get pollStatus_draft;

  /// No description provided for @pollStatus_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get pollStatus_open;

  /// No description provided for @pollStatus_closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get pollStatus_closed;

  /// No description provided for @pollStatus_scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get pollStatus_scheduled;

  /// No description provided for @pollGeo_global.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get pollGeo_global;

  /// No description provided for @pollGeo_local.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get pollGeo_local;

  /// No description provided for @pollOutcome_approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get pollOutcome_approved;

  /// No description provided for @pollOutcome_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get pollOutcome_rejected;

  /// No description provided for @pollOutcome_tie.
  ///
  /// In en, this message translates to:
  /// **'Tie'**
  String get pollOutcome_tie;

  /// No description provided for @pollOutcome_noMajority.
  ///
  /// In en, this message translates to:
  /// **'No majority'**
  String get pollOutcome_noMajority;

  /// No description provided for @pollOutcome_notApplicable.
  ///
  /// In en, this message translates to:
  /// **'Not applicable'**
  String get pollOutcome_notApplicable;

  /// No description provided for @pollList_title.
  ///
  /// In en, this message translates to:
  /// **'Polls'**
  String get pollList_title;

  /// No description provided for @pollList_scopeWorld.
  ///
  /// In en, this message translates to:
  /// **'World'**
  String get pollList_scopeWorld;

  /// No description provided for @pollList_scopeCountryFallback.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get pollList_scopeCountryFallback;

  /// No description provided for @pollList_scopeCityFallback.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get pollList_scopeCityFallback;

  /// No description provided for @pollList_scopeDescriptionGlobal.
  ///
  /// In en, this message translates to:
  /// **'Showing global polls.'**
  String get pollList_scopeDescriptionGlobal;

  /// No description provided for @pollList_scopeDescriptionCountry.
  ///
  /// In en, this message translates to:
  /// **'Showing polls for this country.'**
  String get pollList_scopeDescriptionCountry;

  /// No description provided for @pollList_scopeDescriptionCity.
  ///
  /// In en, this message translates to:
  /// **'Showing polls for this city.'**
  String get pollList_scopeDescriptionCity;

  /// No description provided for @pollList_filterStatus_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get pollList_filterStatus_all;

  /// No description provided for @pollList_filterStatus_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get pollList_filterStatus_open;

  /// No description provided for @pollList_filterStatus_closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get pollList_filterStatus_closed;

  /// No description provided for @pollList_sort_latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get pollList_sort_latest;

  /// No description provided for @pollList_sort_hottest.
  ///
  /// In en, this message translates to:
  /// **'Hottest'**
  String get pollList_sort_hottest;

  /// No description provided for @pollList_filterScope_currentArea.
  ///
  /// In en, this message translates to:
  /// **'Current area'**
  String get pollList_filterScope_currentArea;

  /// No description provided for @pollList_headerTitle.
  ///
  /// In en, this message translates to:
  /// **'{scopeLabel} · {count, plural, =0 {no polls found} =1 {1 poll found} other {{count} polls found}}'**
  String pollList_headerTitle(Object scopeLabel, int count);

  /// No description provided for @pollList_createPollButton.
  ///
  /// In en, this message translates to:
  /// **'Create poll'**
  String get pollList_createPollButton;

  /// No description provided for @pollList_paginationHint.
  ///
  /// In en, this message translates to:
  /// **'Scroll to load more polls…'**
  String get pollList_paginationHint;

  /// No description provided for @pollList_emptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No polls matching this filter for this area.'**
  String get pollList_emptyMessage;

  /// No description provided for @pollType_ranked.
  ///
  /// In en, this message translates to:
  /// **'Ranked choice'**
  String get pollType_ranked;

  /// No description provided for @pollType_score.
  ///
  /// In en, this message translates to:
  /// **'Score / Rating'**
  String get pollType_score;

  /// No description provided for @pollVisibility_whileOpen.
  ///
  /// In en, this message translates to:
  /// **'Results visible while open'**
  String get pollVisibility_whileOpen;

  /// No description provided for @pollVisibility_afterVote.
  ///
  /// In en, this message translates to:
  /// **'Results visible after vote'**
  String get pollVisibility_afterVote;

  /// No description provided for @pollVisibility_afterClose.
  ///
  /// In en, this message translates to:
  /// **'Results visible after close'**
  String get pollVisibility_afterClose;

  /// No description provided for @pollCard_countryRestricted.
  ///
  /// In en, this message translates to:
  /// **'Country restricted'**
  String get pollCard_countryRestricted;

  /// No description provided for @pollCard_restrictedToCountry.
  ///
  /// In en, this message translates to:
  /// **'Restricted to {countryName}'**
  String pollCard_restrictedToCountry(Object countryName);

  /// No description provided for @pollCard_quorumLabel.
  ///
  /// In en, this message translates to:
  /// **'Quorum {minVotes}'**
  String pollCard_quorumLabel(int minVotes);

  /// No description provided for @pollCard_viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get pollCard_viewDetails;

  /// No description provided for @pollResult_title.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {Results (no votes)} =1 {Results (1 vote)} other {Results ({count} votes)}}'**
  String pollResult_title(int count);

  /// No description provided for @voteError_noSelection.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one option.'**
  String get voteError_noSelection;

  /// No description provided for @voteError_unauthorized.
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to vote in this poll.'**
  String get voteError_unauthorized;

  /// No description provided for @voteError_generic.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit vote. Please try again.'**
  String get voteError_generic;

  /// No description provided for @commentSection_title.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentSection_title;

  /// No description provided for @commentSection_sortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort:'**
  String get commentSection_sortLabel;

  /// No description provided for @commentSection_sortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get commentSection_sortOldest;

  /// No description provided for @commentSection_sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get commentSection_sortNewest;

  /// No description provided for @commentSection_errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading comments.'**
  String get commentSection_errorGeneric;

  /// No description provided for @commentSection_empty.
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Be the first to comment.'**
  String get commentSection_empty;

  /// No description provided for @commentSection_loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more comments'**
  String get commentSection_loadMore;

  /// No description provided for @commentSection_replyingTo.
  ///
  /// In en, this message translates to:
  /// **'Replying to: {snippet}'**
  String commentSection_replyingTo(Object snippet);

  /// No description provided for @commentSection_cancelReply.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commentSection_cancelReply;

  /// No description provided for @commentSection_inputHintRoot.
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get commentSection_inputHintRoot;

  /// No description provided for @commentSection_inputHintReply.
  ///
  /// In en, this message translates to:
  /// **'Write a reply...'**
  String get commentSection_inputHintReply;

  /// No description provided for @commentSection_deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commentSection_deleteAction;

  /// No description provided for @commentSection_replyAction.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get commentSection_replyAction;

  /// No description provided for @commentSection_youBadge.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get commentSection_youBadge;

  /// No description provided for @newsDetail_title.
  ///
  /// In en, this message translates to:
  /// **'News detail'**
  String get newsDetail_title;

  /// No description provided for @newsDetail_breakingBadge.
  ///
  /// In en, this message translates to:
  /// **'BREAKING'**
  String get newsDetail_breakingBadge;

  /// No description provided for @newsDetail_removeFromFavoritesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get newsDetail_removeFromFavoritesTooltip;

  /// No description provided for @newsDetail_addToFavoritesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get newsDetail_addToFavoritesTooltip;

  /// No description provided for @newsDetail_bodyFallback.
  ///
  /// In en, this message translates to:
  /// **'No additional text is available for this news item.'**
  String get newsDetail_bodyFallback;

  /// No description provided for @newsDetail_footerMoreContext.
  ///
  /// In en, this message translates to:
  /// **'More context and sources coming soon.'**
  String get newsDetail_footerMoreContext;

  /// No description provided for @newsFeed_title.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get newsFeed_title;

  /// No description provided for @newsFeed_scopeWorld.
  ///
  /// In en, this message translates to:
  /// **'World'**
  String get newsFeed_scopeWorld;

  /// No description provided for @newsFeed_scopeCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get newsFeed_scopeCountry;

  /// No description provided for @newsFeed_scopeCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get newsFeed_scopeCity;

  /// No description provided for @newsFeed_scopeLabel.
  ///
  /// In en, this message translates to:
  /// **'Scope: {scope}'**
  String newsFeed_scopeLabel(Object scope);

  /// No description provided for @newsFeed_scopeGlobalDescription.
  ///
  /// In en, this message translates to:
  /// **'Showing global news.'**
  String get newsFeed_scopeGlobalDescription;

  /// No description provided for @newsFeed_scopeCountryDescription.
  ///
  /// In en, this message translates to:
  /// **'Showing news for this country.'**
  String get newsFeed_scopeCountryDescription;

  /// No description provided for @newsFeed_scopeCityDescription.
  ///
  /// In en, this message translates to:
  /// **'Showing news for this city.'**
  String get newsFeed_scopeCityDescription;

  /// No description provided for @newsFeed_emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No news available for this area.'**
  String get newsFeed_emptyTitle;

  /// No description provided for @newsFeed_emptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh or try again later.'**
  String get newsFeed_emptySubtitle;

  /// No description provided for @newsFeed_itemsFound.
  ///
  /// In en, this message translates to:
  /// **'{count} news item(s) found'**
  String newsFeed_itemsFound(int count);

  /// No description provided for @newsFeed_loadingMoreHint.
  ///
  /// In en, this message translates to:
  /// **'Scroll to load more news…'**
  String get newsFeed_loadingMoreHint;

  /// No description provided for @newsFeed_errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load news'**
  String get newsFeed_errorTitle;

  /// No description provided for @newsFeed_errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred while loading news.'**
  String get newsFeed_errorGeneric;

  /// No description provided for @newsFeed_retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get newsFeed_retryButton;

  /// No description provided for @newsCard_headerTitle.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get newsCard_headerTitle;

  /// No description provided for @newsFeed_errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'News configuration is invalid (API key).'**
  String get newsFeed_errorUnauthorized;

  /// No description provided for @newsFeed_errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please try again shortly.'**
  String get newsFeed_errorRateLimited;

  /// No description provided for @newsFeed_errorServerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'News service is temporarily unavailable. Please try again later.'**
  String get newsFeed_errorServerUnavailable;

  /// No description provided for @newsFeed_errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request is taking too long. Please try again.'**
  String get newsFeed_errorTimeout;

  /// No description provided for @newsFeed_errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet and try again.'**
  String get newsFeed_errorNetwork;

  /// No description provided for @newsFeed_moreTooltip.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get newsFeed_moreTooltip;

  /// No description provided for @newsFeed_actionCopyTitle.
  ///
  /// In en, this message translates to:
  /// **'Copy title'**
  String get newsFeed_actionCopyTitle;

  /// No description provided for @newsFeed_actionRefreshFeed.
  ///
  /// In en, this message translates to:
  /// **'Refresh feed'**
  String get newsFeed_actionRefreshFeed;

  /// No description provided for @newsFeed_copiedTitleToast.
  ///
  /// In en, this message translates to:
  /// **'Title copied'**
  String get newsFeed_copiedTitleToast;

  /// No description provided for @newsFeed_languageTooltip.
  ///
  /// In en, this message translates to:
  /// **'News language'**
  String get newsFeed_languageTooltip;

  /// No description provided for @newsFeed_languageAuto.
  ///
  /// In en, this message translates to:
  /// **'AUTO'**
  String get newsFeed_languageAuto;

  /// No description provided for @newsFeed_languageIt.
  ///
  /// In en, this message translates to:
  /// **'IT'**
  String get newsFeed_languageIt;

  /// No description provided for @newsFeed_languageEn.
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get newsFeed_languageEn;

  /// No description provided for @newsFeed_languageEs.
  ///
  /// In en, this message translates to:
  /// **'ES'**
  String get newsFeed_languageEs;

  /// No description provided for @newsFeed_languageFr.
  ///
  /// In en, this message translates to:
  /// **'FR'**
  String get newsFeed_languageFr;

  /// No description provided for @newsFeed_languageDe.
  ///
  /// In en, this message translates to:
  /// **'DE'**
  String get newsFeed_languageDe;

  /// No description provided for @newsFeed_languageAr.
  ///
  /// In en, this message translates to:
  /// **'AR'**
  String get newsFeed_languageAr;

  /// No description provided for @newsFeed_languageFa.
  ///
  /// In en, this message translates to:
  /// **'FA'**
  String get newsFeed_languageFa;

  /// No description provided for @newsFeed_languageLimitedHint.
  ///
  /// In en, this message translates to:
  /// **'Limited sources in this language. Try AUTO.'**
  String get newsFeed_languageLimitedHint;

  /// No description provided for @newsTopic_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get newsTopic_all;

  /// No description provided for @newsTopic_world.
  ///
  /// In en, this message translates to:
  /// **'World'**
  String get newsTopic_world;

  /// No description provided for @newsTopic_nation.
  ///
  /// In en, this message translates to:
  /// **'Nation'**
  String get newsTopic_nation;

  /// No description provided for @newsTopic_business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get newsTopic_business;

  /// No description provided for @newsTopic_technology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get newsTopic_technology;

  /// No description provided for @newsTopic_science.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get newsTopic_science;

  /// No description provided for @newsTopic_health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get newsTopic_health;

  /// No description provided for @newsTopic_sports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get newsTopic_sports;

  /// No description provided for @newsTopic_entertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get newsTopic_entertainment;

  /// Button to open the original article from the source website
  ///
  /// In en, this message translates to:
  /// **'Open source article'**
  String get newsDetail_openSource;

  /// Shown when the source link cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Unable to open the source article'**
  String get newsDetail_openSourceUnavailable;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'it': return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
