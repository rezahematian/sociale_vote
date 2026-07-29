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

  /// No description provided for @searchPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchPageTitle;

  /// No description provided for @searchInputHint.
  ///
  /// In en, this message translates to:
  /// **'Search polls, news, posts...'**
  String get searchInputHint;

  /// No description provided for @searchClearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get searchClearTooltip;

  /// No description provided for @searchTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchTypeAll;

  /// No description provided for @searchTypePolls.
  ///
  /// In en, this message translates to:
  /// **'Polls'**
  String get searchTypePolls;

  /// No description provided for @searchTypeNews.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get searchTypeNews;

  /// No description provided for @searchTypePosts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get searchTypePosts;

  /// No description provided for @searchSortHottest.
  ///
  /// In en, this message translates to:
  /// **'Hottest'**
  String get searchSortHottest;

  /// No description provided for @searchSortLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get searchSortLatest;

  /// No description provided for @searchPollStatusAll.
  ///
  /// In en, this message translates to:
  /// **'All polls'**
  String get searchPollStatusAll;

  /// No description provided for @searchPollStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get searchPollStatusOpen;

  /// No description provided for @searchPollStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get searchPollStatusClosed;

  /// No description provided for @searchIdleMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a term to start searching.'**
  String get searchIdleMessage;

  /// No description provided for @searchErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while searching.'**
  String get searchErrorMessage;

  /// No description provided for @searchRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get searchRetryButton;

  /// No description provided for @searchEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No results found for this search.'**
  String get searchEmptyMessage;

  /// No description provided for @searchContentUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Content unavailable'**
  String get searchContentUnavailable;

  /// No description provided for @searchResultTypePoll.
  ///
  /// In en, this message translates to:
  /// **'Poll'**
  String get searchResultTypePoll;

  /// No description provided for @searchResultTypeNews.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get searchResultTypeNews;

  /// No description provided for @searchResultTypePost.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get searchResultTypePost;

  /// No description provided for @searchResultTypeMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get searchResultTypeMixed;

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
  /// **'Score voting'**
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

  /// Compact PollCard label used when results are always visible
  ///
  /// In en, this message translates to:
  /// **'Results visible'**
  String get pollCard_resultsVisibleChip;

  /// Compact PollCard label used when results are visible after voting
  ///
  /// In en, this message translates to:
  /// **'After vote'**
  String get pollCard_resultsAfterVoteChip;

  /// Compact PollCard label used when results are visible after the poll closes
  ///
  /// In en, this message translates to:
  /// **'After close'**
  String get pollCard_resultsAfterCloseChip;

  /// PollCard label for a poll published by a public official
  ///
  /// In en, this message translates to:
  /// **'Public Official'**
  String get pollCard_publicOfficialPublisher;

  /// PollCard label for a poll published by an institution
  ///
  /// In en, this message translates to:
  /// **'Institution'**
  String get pollCard_institutionPublisher;

  /// Fallback PollCard label for representative publishing
  ///
  /// In en, this message translates to:
  /// **'Representative'**
  String get pollCard_representativePublisher;

  /// Singular or plural label shown below the vote count in PollCard
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {vote} other {votes}}'**
  String pollCard_voteCountLabel(int count);

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

  /// Title of the main social feed page
  ///
  /// In en, this message translates to:
  /// **'Social Feed'**
  String get socialFeedTitle;

  /// Button that opens the post creation flow
  ///
  /// In en, this message translates to:
  /// **'Create post'**
  String get socialFeedCreatePostButton;

  /// Generic Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancelButton;

  /// Generic Apply button label
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApplyButton;

  /// Title and action for choosing the Home scope country
  ///
  /// In en, this message translates to:
  /// **'Choose country'**
  String get homeScopeChooseCountry;

  /// Hint shown in the country search field
  ///
  /// In en, this message translates to:
  /// **'Search country or code...'**
  String get homeScopeCountrySearchHint;

  /// Title and action for choosing the Home scope city
  ///
  /// In en, this message translates to:
  /// **'Choose city'**
  String get homeScopeChooseCity;

  /// Selected country shown in the city selection dialog
  ///
  /// In en, this message translates to:
  /// **'Country: {code}'**
  String homeScopeCountryWithCode(String code);

  /// City field label in the Home scope selector
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get homeScopeCityFieldLabel;

  /// Examples shown in the city field
  ///
  /// In en, this message translates to:
  /// **'E.g. Rome, São Paulo, Tehran'**
  String get homeScopeCityExampleHint;

  /// Error shown when the city field is empty
  ///
  /// In en, this message translates to:
  /// **'Enter a city.'**
  String get homeScopeCityRequiredError;

  /// Error shown when the city does not belong to the selected country
  ///
  /// In en, this message translates to:
  /// **'City not found in the selected country.'**
  String get homeScopeCityNotFoundError;

  /// Generic error shown while verifying the city
  ///
  /// In en, this message translates to:
  /// **'Unable to verify the city. Try again.'**
  String get homeScopeCityVerificationError;

  /// Label shown while the city is being verified
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get homeScopeVerifyingButton;

  /// Button label that opens the full Civic Map from Home
  ///
  /// In en, this message translates to:
  /// **'Open map'**
  String get homeMapOpenButton;

  /// Main headline shown in the Home hero
  ///
  /// In en, this message translates to:
  /// **'Shape the future.\nTogether.'**
  String get homeHeroHeadline;

  /// Label and tooltip for the Account entry in the Home top bar
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get homeAccountMenuLabel;

  /// Account menu item for using the system theme
  ///
  /// In en, this message translates to:
  /// **'Theme: system'**
  String get homeThemeSystemMenuItem;

  /// Account menu item for using the light theme
  ///
  /// In en, this message translates to:
  /// **'Theme: light'**
  String get homeThemeLightMenuItem;

  /// Account menu item for using the dark theme
  ///
  /// In en, this message translates to:
  /// **'Theme: dark'**
  String get homeThemeDarkMenuItem;

  /// Tooltip for the notifications button in the Home top bar
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get homeNotificationsTooltip;

  /// Fallback author name shown in the PostCard when no name is available
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get postCard_authorFallback;

  /// Global location label shown in the PostCard
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get postCard_globalLocation;

  /// Generic Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSaveButton;

  /// Generic Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDeleteButton;

  /// Menu action used to report content
  ///
  /// In en, this message translates to:
  /// **'Report content'**
  String get contentReport_menuAction;

  /// Content report dialog title
  ///
  /// In en, this message translates to:
  /// **'Report content'**
  String get contentReport_dialogTitle;

  /// Message shown to a signed-out user
  ///
  /// In en, this message translates to:
  /// **'You must be signed in to report content'**
  String get contentReport_authenticationRequired;

  /// Report submission confirmation
  ///
  /// In en, this message translates to:
  /// **'Report submitted'**
  String get contentReport_submittedMessage;

  /// Message shown when the content was already reported
  ///
  /// In en, this message translates to:
  /// **'You have already reported this content'**
  String get contentReport_alreadySubmittedMessage;

  /// Generic error while submitting a report
  ///
  /// In en, this message translates to:
  /// **'Unable to submit the report'**
  String get contentReport_submitError;

  /// Report submission button
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get contentReport_sendButton;

  /// Spam report reason
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get contentReport_reasonSpam;

  /// Harassment or abuse report reason
  ///
  /// In en, this message translates to:
  /// **'Harassment or abuse'**
  String get contentReport_reasonHarassment;

  /// Hate speech report reason
  ///
  /// In en, this message translates to:
  /// **'Hate speech'**
  String get contentReport_reasonHateSpeech;

  /// Misinformation report reason
  ///
  /// In en, this message translates to:
  /// **'Misinformation'**
  String get contentReport_reasonMisinformation;

  /// Violence report reason
  ///
  /// In en, this message translates to:
  /// **'Violence'**
  String get contentReport_reasonViolence;

  /// Other report reason
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get contentReport_reasonOther;

  /// Post detail page title
  ///
  /// In en, this message translates to:
  /// **'Post detail'**
  String get postDetail_title;

  /// Favorites update error on the post detail page
  ///
  /// In en, this message translates to:
  /// **'Unable to update favorites'**
  String get postDetail_favoriteUpdateError;

  /// Text appended when sharing a post
  ///
  /// In en, this message translates to:
  /// **'Open Sociale_Vote to view this post.'**
  String get postDetail_shareMessage;

  /// Post sharing error
  ///
  /// In en, this message translates to:
  /// **'Unable to share the post'**
  String get postDetail_shareError;

  /// Edit post dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit post'**
  String get postDetail_editDialogTitle;

  /// Title field label in the edit post dialog
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get postDetail_editTitleFieldLabel;

  /// Content field label in the edit post dialog
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get postDetail_editContentFieldLabel;

  /// Required fields error in the edit post dialog
  ///
  /// In en, this message translates to:
  /// **'Title and content are required.'**
  String get postDetail_editRequiredError;

  /// Post update confirmation
  ///
  /// In en, this message translates to:
  /// **'Post updated'**
  String get postDetail_updateSuccess;

  /// Post update error
  ///
  /// In en, this message translates to:
  /// **'Unable to update the post'**
  String get postDetail_updateError;

  /// Post deletion confirmation title
  ///
  /// In en, this message translates to:
  /// **'Delete this post?'**
  String get postDetail_deleteDialogTitle;

  /// Post deletion confirmation message
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get postDetail_deleteDialogMessage;

  /// Post deletion error
  ///
  /// In en, this message translates to:
  /// **'Unable to delete the post'**
  String get postDetail_deleteError;

  /// Edit post menu item
  ///
  /// In en, this message translates to:
  /// **'Edit post'**
  String get postDetail_editMenuItem;

  /// Delete post menu item
  ///
  /// In en, this message translates to:
  /// **'Delete post'**
  String get postDetail_deleteMenuItem;

  /// Generic post detail loading error
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading the post.'**
  String get postDetail_loadError;

  /// Post not found message
  ///
  /// In en, this message translates to:
  /// **'Post not found.'**
  String get postDetail_notFound;

  /// Post detail error state title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get postDetail_errorTitle;

  /// Fallback author name on the post detail page
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get postDetail_authorFallback;

  /// Share action on the post detail page
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get postDetail_shareAction;

  /// Save action on the post detail page
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get postDetail_saveAction;

  /// Add to favorites tooltip on the post detail page
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get postDetail_addToFavoritesTooltip;

  /// Remove from favorites tooltip on the post detail page
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get postDetail_removeFromFavoritesTooltip;

  /// Favorites update error on the news detail page
  ///
  /// In en, this message translates to:
  /// **'Unable to update favorites'**
  String get newsDetail_favoriteUpdateError;

  /// Text appended when sharing a news item
  ///
  /// In en, this message translates to:
  /// **'Open Sociale_Vote to view this news item.'**
  String get newsDetail_shareMessage;

  /// News sharing error
  ///
  /// In en, this message translates to:
  /// **'Unable to share the news item'**
  String get newsDetail_shareError;

  /// Share tooltip on the news detail page
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get newsDetail_shareTooltip;

  /// Auth UI: authLoginPageTitle
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLoginPageTitle;

  /// Auth UI: authLoginHeadline
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authLoginHeadline;

  /// Auth UI: authEmailLabel
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// Auth UI: authPasswordLabel
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// Auth UI: authRememberMeLabel
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get authRememberMeLabel;

  /// Auth UI: authForgotPasswordAction
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPasswordAction;

  /// Auth UI: authLoginButton
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLoginButton;

  /// Auth UI: authRegisterPrompt
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authRegisterPrompt;

  /// Auth UI: authRegisterAction
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authRegisterAction;

  /// Auth UI: authRegisterPageTitle
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authRegisterPageTitle;

  /// Auth UI: authRegisterHeadline
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get authRegisterHeadline;

  /// Auth UI: authDisplayNameLabel
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get authDisplayNameLabel;

  /// Auth UI: authUsernameLabel
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authUsernameLabel;

  /// Auth UI: authCountryOfResidenceLabel
  ///
  /// In en, this message translates to:
  /// **'Country of residence'**
  String get authCountryOfResidenceLabel;

  /// Auth UI: authCityOfResidenceLabel
  ///
  /// In en, this message translates to:
  /// **'City of residence'**
  String get authCityOfResidenceLabel;

  /// Auth UI: authConfirmPasswordLabel
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPasswordLabel;

  /// Auth UI: authLegalConsentPrefix
  ///
  /// In en, this message translates to:
  /// **'I have read and accept'**
  String get authLegalConsentPrefix;

  /// Auth UI: authTermsOfServiceAction
  ///
  /// In en, this message translates to:
  /// **'the Terms of Service'**
  String get authTermsOfServiceAction;

  /// Auth UI: authPrivacyPolicyAction
  ///
  /// In en, this message translates to:
  /// **'the Privacy Policy'**
  String get authPrivacyPolicyAction;

  /// Auth UI: authRegisterButton
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authRegisterButton;

  /// Auth UI: authLoginPrompt
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authLoginPrompt;

  /// Auth UI: authLoginAction
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLoginAction;

  /// Auth UI: authForgotPasswordDialogTitle
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authForgotPasswordDialogTitle;

  /// Auth UI: authForgotPasswordDialogBody
  ///
  /// In en, this message translates to:
  /// **'Enter the email address linked to your account. We will send you a link to choose a new password.'**
  String get authForgotPasswordDialogBody;

  /// Auth UI: authForgotPasswordSendButton
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get authForgotPasswordSendButton;

  /// Auth UI: authPasswordResetEmailSent
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Check your inbox.'**
  String get authPasswordResetEmailSent;

  /// Auth UI: authResetPasswordPageTitle
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authResetPasswordPageTitle;

  /// Auth UI: authResetPasswordHeadline
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get authResetPasswordHeadline;

  /// Auth UI: authNewPasswordLabel
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authNewPasswordLabel;

  /// Auth UI: authConfirmNewPasswordLabel
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get authConfirmNewPasswordLabel;

  /// Auth UI: authUpdatePasswordButton
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get authUpdatePasswordButton;

  /// Auth UI: authPasswordUpdated
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully.'**
  String get authPasswordUpdated;

  /// Auth UI: authEmailConfirmationTitle
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get authEmailConfirmationTitle;

  /// Auth UI: authEmailConfirmationIntro
  ///
  /// In en, this message translates to:
  /// **'We sent a confirmation link to:'**
  String get authEmailConfirmationIntro;

  /// Auth UI: authEmailConfirmationInstructions
  ///
  /// In en, this message translates to:
  /// **'Open the link in the message to verify your address. After confirmation, return to the app and log in.'**
  String get authEmailConfirmationInstructions;

  /// Auth UI: authBackToLoginButton
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get authBackToLoginButton;

  /// Auth UI: authUseAnotherEmailButton
  ///
  /// In en, this message translates to:
  /// **'Use another email address'**
  String get authUseAnotherEmailButton;

  /// Auth UI: authEmailRequiredError
  ///
  /// In en, this message translates to:
  /// **'Enter your email.'**
  String get authEmailRequiredError;

  /// Auth UI: authEmailInvalidError
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get authEmailInvalidError;

  /// Auth UI: authPasswordRequiredError
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get authPasswordRequiredError;

  /// Auth UI: authPasswordTooShortError
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get authPasswordTooShortError;

  /// Auth UI: authDisplayNameRequiredError
  ///
  /// In en, this message translates to:
  /// **'Enter your display name.'**
  String get authDisplayNameRequiredError;

  /// Auth UI: authDisplayNameTooShortError
  ///
  /// In en, this message translates to:
  /// **'Display name is too short.'**
  String get authDisplayNameTooShortError;

  /// Auth UI: authUsernameRequiredError
  ///
  /// In en, this message translates to:
  /// **'Enter a username.'**
  String get authUsernameRequiredError;

  /// Auth UI: authUsernameInvalidError
  ///
  /// In en, this message translates to:
  /// **'Use 3 to 20 characters: lowercase letters, numbers and underscores.'**
  String get authUsernameInvalidError;

  /// Auth UI: authCountryRequiredError
  ///
  /// In en, this message translates to:
  /// **'Select your country of residence.'**
  String get authCountryRequiredError;

  /// Auth UI: authCityRequiredError
  ///
  /// In en, this message translates to:
  /// **'Enter your city of residence.'**
  String get authCityRequiredError;

  /// Auth UI: authConfirmPasswordRequiredError
  ///
  /// In en, this message translates to:
  /// **'Confirm your password.'**
  String get authConfirmPasswordRequiredError;

  /// Auth UI: authPasswordsDoNotMatchError
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get authPasswordsDoNotMatchError;

  /// Auth UI: authLegalConsentRequiredError
  ///
  /// In en, this message translates to:
  /// **'You must read and accept the Terms of Service and Privacy Policy.'**
  String get authLegalConsentRequiredError;

  /// Auth UI: authForgotPasswordEmailRequiredError
  ///
  /// In en, this message translates to:
  /// **'Enter the email for the account you want to recover.'**
  String get authForgotPasswordEmailRequiredError;

  /// Auth UI: authInvalidCredentialsError
  ///
  /// In en, this message translates to:
  /// **'Email or password is not valid.'**
  String get authInvalidCredentialsError;

  /// Auth UI: authEmailAlreadyRegisteredError
  ///
  /// In en, this message translates to:
  /// **'This email is already registered.'**
  String get authEmailAlreadyRegisteredError;

  /// Auth UI: authEmailNotConfirmedError
  ///
  /// In en, this message translates to:
  /// **'Email not confirmed. Check your inbox before logging in.'**
  String get authEmailNotConfirmedError;

  /// Auth UI: authTooManyAttemptsError
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a few minutes and try again.'**
  String get authTooManyAttemptsError;

  /// Auth UI: authNetworkError
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection and try again.'**
  String get authNetworkError;

  /// Auth UI: authLoginGenericError
  ///
  /// In en, this message translates to:
  /// **'Login failed. Try again.'**
  String get authLoginGenericError;

  /// Auth UI: authRegisterGenericError
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Try again.'**
  String get authRegisterGenericError;

  /// Auth UI: authPasswordResetGenericError
  ///
  /// In en, this message translates to:
  /// **'Unable to send the reset link. Try again.'**
  String get authPasswordResetGenericError;

  /// Auth UI: authPasswordUpdateGenericError
  ///
  /// In en, this message translates to:
  /// **'Unable to update the password. Try again.'**
  String get authPasswordUpdateGenericError;

  /// Auth UI: authShowPasswordTooltip
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPasswordTooltip;

  /// Auth UI: authHidePasswordTooltip
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePasswordTooltip;

  /// Auth UI: authTermsPageTitle
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get authTermsPageTitle;

  /// Auth UI: authPrivacyPageTitle
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get authPrivacyPageTitle;

  /// Auth UI: authCloseButton
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get authCloseButton;

  /// Poll detail UI: pollDetail_favoriteUpdateError
  ///
  /// In en, this message translates to:
  /// **'Unable to update favorites'**
  String get pollDetail_favoriteUpdateError;

  /// Poll detail UI: pollDetail_shareMessage
  ///
  /// In en, this message translates to:
  /// **'Open Sociale_Vote to view and vote in this poll.'**
  String get pollDetail_shareMessage;

  /// Poll detail UI: pollDetail_shareError
  ///
  /// In en, this message translates to:
  /// **'Unable to share the poll'**
  String get pollDetail_shareError;

  /// Poll detail UI: pollDetail_editPermissionError
  ///
  /// In en, this message translates to:
  /// **'You can edit only your own polls that have no votes'**
  String get pollDetail_editPermissionError;

  /// Poll detail UI: pollDetail_editSuccessMessage
  ///
  /// In en, this message translates to:
  /// **'Poll updated'**
  String get pollDetail_editSuccessMessage;

  /// Poll detail UI: pollDetail_editMenuItem
  ///
  /// In en, this message translates to:
  /// **'Edit poll'**
  String get pollDetail_editMenuItem;

  /// Poll detail UI: pollDetail_editSavingMenuItem
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get pollDetail_editSavingMenuItem;

  /// Poll detail UI: pollDetail_deletePermissionError
  ///
  /// In en, this message translates to:
  /// **'You can delete only your own polls'**
  String get pollDetail_deletePermissionError;

  /// Poll detail UI: pollDetail_deleteError
  ///
  /// In en, this message translates to:
  /// **'Unable to delete the poll'**
  String get pollDetail_deleteError;

  /// Poll detail UI: pollDetail_deleteDialogTitle
  ///
  /// In en, this message translates to:
  /// **'Delete poll'**
  String get pollDetail_deleteDialogTitle;

  /// Poll detail UI: pollDetail_deleteDialogMessage
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete \"{title}\"? This action cannot be undone.'**
  String pollDetail_deleteDialogMessage(String title);

  /// Poll detail UI: pollDetail_deleteMenuItem
  ///
  /// In en, this message translates to:
  /// **'Delete poll'**
  String get pollDetail_deleteMenuItem;

  /// Poll detail UI: pollDetail_deleteDeletingMenuItem
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get pollDetail_deleteDeletingMenuItem;

  /// Poll detail UI: pollDetail_publicVotesAvailableTitle
  ///
  /// In en, this message translates to:
  /// **'Public votes available'**
  String get pollDetail_publicVotesAvailableTitle;

  /// Poll detail UI: pollDetail_publicVotesAvailableMessage
  ///
  /// In en, this message translates to:
  /// **'This poll allows you to see who voted for each option.'**
  String get pollDetail_publicVotesAvailableMessage;

  /// Poll detail UI: pollDetail_publicVotesAction
  ///
  /// In en, this message translates to:
  /// **'View public votes'**
  String get pollDetail_publicVotesAction;

  /// Poll detail UI: pollDetail_retryButton
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get pollDetail_retryButton;

  /// Poll detail UI: pollDetail_voteErrorNoOption
  ///
  /// In en, this message translates to:
  /// **'Select at least one option'**
  String get pollDetail_voteErrorNoOption;

  /// Poll detail UI: pollDetail_voteErrorAuthenticationRequired
  ///
  /// In en, this message translates to:
  /// **'You must be signed in to vote'**
  String get pollDetail_voteErrorAuthenticationRequired;

  /// Poll detail UI: pollDetail_voteErrorClosed
  ///
  /// In en, this message translates to:
  /// **'This poll is closed'**
  String get pollDetail_voteErrorClosed;

  /// Poll detail UI: pollDetail_voteErrorAlreadyVoted
  ///
  /// In en, this message translates to:
  /// **'You have already voted in this poll'**
  String get pollDetail_voteErrorAlreadyVoted;

  /// Poll detail UI: pollDetail_voteErrorGeneric
  ///
  /// In en, this message translates to:
  /// **'Unable to submit the vote'**
  String get pollDetail_voteErrorGeneric;

  /// Poll detail UI: pollDetail_publicVotesSheetTitle
  ///
  /// In en, this message translates to:
  /// **'Public votes'**
  String get pollDetail_publicVotesSheetTitle;

  /// Poll detail UI: pollDetail_publicVotesSheetDescription
  ///
  /// In en, this message translates to:
  /// **'Here you can see who voted for each option in this poll.'**
  String get pollDetail_publicVotesSheetDescription;

  /// Poll detail UI: pollDetail_publicVotesSearchHint
  ///
  /// In en, this message translates to:
  /// **'Search users'**
  String get pollDetail_publicVotesSearchHint;

  /// Poll detail UI: pollDetail_publicVotesLoadError
  ///
  /// In en, this message translates to:
  /// **'Unable to load public votes'**
  String get pollDetail_publicVotesLoadError;

  /// Poll detail UI: pollDetail_publicVotesEmpty
  ///
  /// In en, this message translates to:
  /// **'No public votes available'**
  String get pollDetail_publicVotesEmpty;

  /// Poll detail UI: pollDetail_publicVotesSearchEmpty
  ///
  /// In en, this message translates to:
  /// **'No users found for this search'**
  String get pollDetail_publicVotesSearchEmpty;

  /// Poll detail UI: pollDetail_publicVotesResultsCount
  ///
  /// In en, this message translates to:
  /// **'{count} results loaded'**
  String pollDetail_publicVotesResultsCount(int count);

  /// Poll detail UI: pollDetail_publicVotesLoadMore
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get pollDetail_publicVotesLoadMore;

  /// Poll detail UI: pollDetail_publicVotesUserFallback
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get pollDetail_publicVotesUserFallback;

  /// Poll detail UI: pollDetail_editDialogTitle
  ///
  /// In en, this message translates to:
  /// **'Edit poll'**
  String get pollDetail_editDialogTitle;

  /// Poll detail UI: pollDetail_editTitleFieldLabel
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get pollDetail_editTitleFieldLabel;

  /// Poll detail UI: pollDetail_editTitleRequired
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get pollDetail_editTitleRequired;

  /// Poll detail UI: pollDetail_editDescriptionFieldLabel
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get pollDetail_editDescriptionFieldLabel;

  /// Poll detail UI: pollDetail_editError
  ///
  /// In en, this message translates to:
  /// **'Unable to update the poll'**
  String get pollDetail_editError;

  /// Poll detail UI: pollDetail_loadError
  ///
  /// In en, this message translates to:
  /// **'Unable to load the poll'**
  String get pollDetail_loadError;

  /// Poll detail UI: pollDetail_notFound
  ///
  /// In en, this message translates to:
  /// **'Poll not found'**
  String get pollDetail_notFound;

  /// Edit profile UI: profileEditPageTitle
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditPageTitle;

  /// Edit profile UI: profileLoginRequiredMessage
  ///
  /// In en, this message translates to:
  /// **'You must be signed in to edit your profile.'**
  String get profileLoginRequiredMessage;

  /// Edit profile UI: profileAvatarUploading
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get profileAvatarUploading;

  /// Edit profile UI: profileUploadAvatarButton
  ///
  /// In en, this message translates to:
  /// **'Upload avatar'**
  String get profileUploadAvatarButton;

  /// Edit profile UI: profileDisplayNameLabel
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get profileDisplayNameLabel;

  /// Edit profile UI: profileDisplayNameRequiredError
  ///
  /// In en, this message translates to:
  /// **'Display name is required.'**
  String get profileDisplayNameRequiredError;

  /// Edit profile UI: profileUsernameHint
  ///
  /// In en, this message translates to:
  /// **'e.g. mario_roma'**
  String get profileUsernameHint;

  /// Edit profile UI: profileUsernameHelper
  ///
  /// In en, this message translates to:
  /// **'3–20 characters: lowercase letters, numbers and underscores'**
  String get profileUsernameHelper;

  /// Edit profile UI: profileAvatarUrlLabel
  ///
  /// In en, this message translates to:
  /// **'Avatar URL'**
  String get profileAvatarUrlLabel;

  /// Edit profile UI: profileBioLabel
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get profileBioLabel;

  /// Edit profile UI: profileClearCountryButton
  ///
  /// In en, this message translates to:
  /// **'Clear country'**
  String get profileClearCountryButton;

  /// Edit profile UI: profileCityResidenceHelper
  ///
  /// In en, this message translates to:
  /// **'The city of residence is checked against the selected country before saving.'**
  String get profileCityResidenceHelper;

  /// Edit profile UI: profileCityNotFoundError
  ///
  /// In en, this message translates to:
  /// **'City not found in the selected country.'**
  String get profileCityNotFoundError;

  /// Edit profile UI: profileCityVerificationError
  ///
  /// In en, this message translates to:
  /// **'Unable to verify the city right now.'**
  String get profileCityVerificationError;

  /// Edit profile UI: profileAvatarUploadError
  ///
  /// In en, this message translates to:
  /// **'Unable to upload the avatar.'**
  String get profileAvatarUploadError;

  /// Edit profile UI: profileAccountSectionTitle
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccountSectionTitle;

  /// Edit profile UI: profileAccountEmailHelper
  ///
  /// In en, this message translates to:
  /// **'The account email address cannot be changed from this screen.'**
  String get profileAccountEmailHelper;

  /// Edit profile UI: profileChangePasswordAction
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profileChangePasswordAction;

  /// Edit profile UI: profileChangePasswordDescription
  ///
  /// In en, this message translates to:
  /// **'Set a new password for this account.'**
  String get profileChangePasswordDescription;

  /// Notifications UI: notificationsPageTitle
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsPageTitle;

  /// Notifications UI: notificationsMarkAllReadAction
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationsMarkAllReadAction;

  /// Notifications UI: notificationsNoTargetMessage
  ///
  /// In en, this message translates to:
  /// **'This notification does not have an available destination.'**
  String get notificationsNoTargetMessage;

  /// Notifications UI: notificationsTargetUnavailableMessage
  ///
  /// In en, this message translates to:
  /// **'The content linked to this notification is unavailable.'**
  String get notificationsTargetUnavailableMessage;

  /// Notifications UI: notificationsLoadError
  ///
  /// In en, this message translates to:
  /// **'Unable to load notifications.'**
  String get notificationsLoadError;

  /// Notifications UI: notificationsRetryButton
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get notificationsRetryButton;

  /// Notifications UI: notificationsEmptyMessage
  ///
  /// In en, this message translates to:
  /// **'No notifications available.'**
  String get notificationsEmptyMessage;

  /// Notifications UI: notificationsCommentReplyTitle
  ///
  /// In en, this message translates to:
  /// **'New reply to your comment'**
  String get notificationsCommentReplyTitle;

  /// Notifications UI: notificationsMentionTitle
  ///
  /// In en, this message translates to:
  /// **'You were mentioned'**
  String get notificationsMentionTitle;

  /// Notifications UI: notificationsPollResultTitle
  ///
  /// In en, this message translates to:
  /// **'Poll update'**
  String get notificationsPollResultTitle;

  /// Notifications UI: notificationsCommentReplySubtitle
  ///
  /// In en, this message translates to:
  /// **'User {actor} replied in {target}'**
  String notificationsCommentReplySubtitle(String actor, String target);

  /// Notifications UI: notificationsMentionSubtitle
  ///
  /// In en, this message translates to:
  /// **'User {actor} mentioned you in {target}'**
  String notificationsMentionSubtitle(String actor, String target);

  /// Notifications UI: notificationsPollResultSubtitle
  ///
  /// In en, this message translates to:
  /// **'A new result is available in {target}'**
  String notificationsPollResultSubtitle(String target);

  /// Notifications UI: notificationsTargetPost
  ///
  /// In en, this message translates to:
  /// **'a post'**
  String get notificationsTargetPost;

  /// Notifications UI: notificationsTargetNews
  ///
  /// In en, this message translates to:
  /// **'a news article'**
  String get notificationsTargetNews;

  /// Notifications UI: notificationsTargetPoll
  ///
  /// In en, this message translates to:
  /// **'a poll'**
  String get notificationsTargetPoll;

  /// Notifications UI: notificationsTargetVideo
  ///
  /// In en, this message translates to:
  /// **'a video'**
  String get notificationsTargetVideo;

  /// Notifications UI: notificationsTargetContent
  ///
  /// In en, this message translates to:
  /// **'some content'**
  String get notificationsTargetContent;

  /// Notifications UI: notificationsUserFallback
  ///
  /// In en, this message translates to:
  /// **'user'**
  String get notificationsUserFallback;

  /// Account hub: destructive action used to permanently delete the current account
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get profileDeleteAccountAction;

  /// Account hub: short description below the delete-account action
  ///
  /// In en, this message translates to:
  /// **'Permanently delete the account and access'**
  String get profileDeleteAccountDescription;

  /// Delete-account confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get profileDeleteAccountDialogTitle;

  /// Delete-account confirmation dialog warning
  ///
  /// In en, this message translates to:
  /// **'This action is permanent. The account cannot be recovered. Type DELETE to confirm.'**
  String get profileDeleteAccountDialogMessage;

  /// Label for the typed delete-account confirmation field
  ///
  /// In en, this message translates to:
  /// **'Deletion confirmation'**
  String get profileDeleteAccountConfirmationLabel;

  /// Hint for the typed delete-account confirmation field
  ///
  /// In en, this message translates to:
  /// **'Type DELETE'**
  String get profileDeleteAccountConfirmationHint;

  /// Validation error when the delete-account confirmation is incorrect
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to continue.'**
  String get profileDeleteAccountConfirmationError;

  /// Cancel button in the delete-account dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileDeleteAccountCancelButton;

  /// Destructive confirmation button in the delete-account dialog
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get profileDeleteAccountConfirmButton;

  /// Fallback message shown when account deletion fails
  ///
  /// In en, this message translates to:
  /// **'Unable to delete the account. Try again.'**
  String get profileDeleteAccountFailureMessage;
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
