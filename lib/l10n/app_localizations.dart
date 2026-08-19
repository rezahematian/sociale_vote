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
  /// **'Social Vote'**
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
  /// **'Search cities, countries, accounts and content...'**
  String get homeSearchHint;

  /// No description provided for @searchPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchPageTitle;

  /// No description provided for @searchInputHint.
  ///
  /// In en, this message translates to:
  /// **'Search accounts, polls, news, posts...'**
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

  /// No description provided for @searchTypeAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get searchTypeAccounts;

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

  /// No description provided for @searchResultTypeAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get searchResultTypeAccount;

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
  /// **'Type a city, e.g. Merano'**
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

  /// Compact Home dashboard action that opens polls
  ///
  /// In en, this message translates to:
  /// **'Polls'**
  String get homeHeroPollsAction;

  /// Compact Home dashboard action that opens news
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get homeHeroNewsAction;

  /// Compact Home dashboard action for creating a poll or post
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get homeHeroCreateAction;

  /// Compact Home dashboard action that opens the full Civic Map
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get homeHeroExploreAction;

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

  /// Title of the app language setting
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get profileAppLanguageTitle;

  /// Option that follows the device language
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get profileAppLanguageSystem;

  /// Description of the system language option
  ///
  /// In en, this message translates to:
  /// **'Uses your device language'**
  String get profileAppLanguageSystemDescription;

  /// Italian app language option
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get profileAppLanguageItalian;

  /// English app language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profileAppLanguageEnglish;

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
  /// **'Open Social Vote to view this post.'**
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
  /// **'Open Social Vote to view this news item.'**
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
  /// **'Public name'**
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
  /// **'City of residence (optional)'**
  String get authCityOfResidenceLabel;

  /// Auth UI: authConfirmPasswordLabel
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPasswordLabel;

  /// Auth UI: authLegalConsentPrefix
  ///
  /// In en, this message translates to:
  /// **'I confirm that I am at least 18 years old. I accept the Terms of Service and confirm that I have read the Privacy Policy.'**
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
  /// **'Enter your public name.'**
  String get authDisplayNameRequiredError;

  /// Auth UI: authDisplayNameTooShortError
  ///
  /// In en, this message translates to:
  /// **'Public name is too short.'**
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

  /// Auth UI: username already in use
  ///
  /// In en, this message translates to:
  /// **'Username is already in use.'**
  String get authUsernameAlreadyTakenError;

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
  /// **'To sign up, confirm that you are at least 18, accept the Terms of Service, and confirm that you have read the Privacy Policy.'**
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
  /// **'Open Social Vote to view and vote in this poll.'**
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

  /// Public identity type label for a personal account
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get identityActorTypePerson;

  /// Public identity type label for a verified public official
  ///
  /// In en, this message translates to:
  /// **'Public official'**
  String get identityActorTypePublicOfficial;

  /// Public identity type label for a verified public institution
  ///
  /// In en, this message translates to:
  /// **'Public institution'**
  String get identityActorTypePublicInstitution;

  /// Public identity type label for a verified non-governmental organization
  ///
  /// In en, this message translates to:
  /// **'Verified organization'**
  String get identityActorTypeVerifiedOrganization;

  /// Verification state label for a personal account without verification
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get identityVerificationNotVerified;

  /// Public label for personal identity verification level 1
  ///
  /// In en, this message translates to:
  /// **'Verified identity'**
  String get identityVerificationLevel1;

  /// Public label for personal identity verification level 2
  ///
  /// In en, this message translates to:
  /// **'Advanced verified identity'**
  String get identityVerificationLevel2;

  /// Tooltip and badge label for personal verification level 1
  ///
  /// In en, this message translates to:
  /// **'Verified identity'**
  String get identityBadgeLevel1;

  /// Tooltip and badge label for personal verification level 2
  ///
  /// In en, this message translates to:
  /// **'Advanced verified identity'**
  String get identityBadgeLevel2;

  /// Tooltip and badge label for a verified public official
  ///
  /// In en, this message translates to:
  /// **'Public official'**
  String get identityBadgePublicOfficial;

  /// Tooltip and badge label for a verified public institution
  ///
  /// In en, this message translates to:
  /// **'Public institution'**
  String get identityBadgePublicInstitution;

  /// Tooltip and badge label for a verified organization
  ///
  /// In en, this message translates to:
  /// **'Verified organization'**
  String get identityBadgeVerifiedOrganization;

  /// Field label for the verified organization name
  ///
  /// In en, this message translates to:
  /// **'Organization name'**
  String get identityOrganizationNameLabel;

  /// Validation error when the organization name is missing
  ///
  /// In en, this message translates to:
  /// **'Enter the organization name.'**
  String get identityOrganizationNameRequired;

  /// Institution level label for a municipality
  ///
  /// In en, this message translates to:
  /// **'Municipal'**
  String get identityInstitutionLevelMunicipality;

  /// Institution level label for a province
  ///
  /// In en, this message translates to:
  /// **'Provincial'**
  String get identityInstitutionLevelProvince;

  /// Institution level label for a region
  ///
  /// In en, this message translates to:
  /// **'Regional'**
  String get identityInstitutionLevelRegion;

  /// Institution level label for a ministry
  ///
  /// In en, this message translates to:
  /// **'Ministry'**
  String get identityInstitutionLevelMinistry;

  /// Institution level label for a government
  ///
  /// In en, this message translates to:
  /// **'Government'**
  String get identityInstitutionLevelGovernment;

  /// Institution level label for a public agency
  ///
  /// In en, this message translates to:
  /// **'Public agency'**
  String get identityInstitutionLevelPublicAgency;

  /// Institution level label for another public body
  ///
  /// In en, this message translates to:
  /// **'Other public body'**
  String get identityInstitutionLevelOtherPublicBody;

  /// Verification request type label for personal verification level 1
  ///
  /// In en, this message translates to:
  /// **'Person verification — Level 1'**
  String get verificationRequestPersonLevel1;

  /// Verification request type label for personal verification level 2
  ///
  /// In en, this message translates to:
  /// **'Person verification — Level 2'**
  String get verificationRequestPersonLevel2;

  /// Verification request type label for a public official
  ///
  /// In en, this message translates to:
  /// **'Public official verification'**
  String get verificationRequestPublicOfficial;

  /// Verification request type label for a public institution
  ///
  /// In en, this message translates to:
  /// **'Public institution verification'**
  String get verificationRequestPublicInstitution;

  /// Verification request type label for a verified organization
  ///
  /// In en, this message translates to:
  /// **'Organization verification'**
  String get verificationRequestVerifiedOrganization;

  /// Title of the verification and account type bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Verification and account type'**
  String get verificationCenterTitle;

  /// Section title for the current verified identity state
  ///
  /// In en, this message translates to:
  /// **'Current account'**
  String get verificationCurrentAccountSection;

  /// Current public account type row
  ///
  /// In en, this message translates to:
  /// **'Account type: {accountType}'**
  String verificationAccountTypeValue(String accountType);

  /// Current personal verification level row
  ///
  /// In en, this message translates to:
  /// **'Verification level: {level}'**
  String verificationLevelValue(String level);

  /// Current official title row
  ///
  /// In en, this message translates to:
  /// **'Official title: {title}'**
  String verificationOfficialTitleValue(String title);

  /// Current public institution name row
  ///
  /// In en, this message translates to:
  /// **'Institution: {name}'**
  String verificationInstitutionNameValue(String name);

  /// Current verified organization name row
  ///
  /// In en, this message translates to:
  /// **'Organization: {name}'**
  String verificationOrganizationNameValue(String name);

  /// Current institution level row
  ///
  /// In en, this message translates to:
  /// **'Institution level: {level}'**
  String verificationInstitutionLevelValue(String level);

  /// Section title for an active verification request
  ///
  /// In en, this message translates to:
  /// **'Active request'**
  String get verificationActiveRequestSection;

  /// Explanation shown while a verification request is pending
  ///
  /// In en, this message translates to:
  /// **'Your current profile will not change until the request is approved.'**
  String get verificationProfileUnchangedUntilApproval;

  /// Button label to cancel a pending verification request
  ///
  /// In en, this message translates to:
  /// **'Cancel pending request'**
  String get verificationCancelPendingAction;

  /// Message explaining that only one pending request is allowed
  ///
  /// In en, this message translates to:
  /// **'You cannot submit a new request while another request is pending.'**
  String get verificationPendingBlocksNewRequests;

  /// Section title when there is no active verification request
  ///
  /// In en, this message translates to:
  /// **'No active request'**
  String get verificationNoActiveRequestSection;

  /// Message shown when there is no active verification request
  ///
  /// In en, this message translates to:
  /// **'You currently have no requests under review.'**
  String get verificationNoActiveRequestDescription;

  /// Section title for the most recently rejected request
  ///
  /// In en, this message translates to:
  /// **'Last rejected request'**
  String get verificationLastRejectedSection;

  /// Message shown after a rejected verification request
  ///
  /// In en, this message translates to:
  /// **'Your last request was rejected.'**
  String get verificationLastRejectedDescription;

  /// Explanation shown after a rejected request
  ///
  /// In en, this message translates to:
  /// **'Your current profile has not changed. You can correct the information and submit a new request.'**
  String get verificationRejectedCanResubmit;

  /// Section title for verification request actions
  ///
  /// In en, this message translates to:
  /// **'Available requests'**
  String get verificationAvailableRequestsSection;

  /// Action title for personal verification level 1
  ///
  /// In en, this message translates to:
  /// **'Request person verification — Level 1'**
  String get verificationRequestLevel1Title;

  /// Action subtitle for personal verification level 1
  ///
  /// In en, this message translates to:
  /// **'Basic personal identity verification'**
  String get verificationRequestLevel1Subtitle;

  /// Action title for personal verification level 2
  ///
  /// In en, this message translates to:
  /// **'Request person verification — Level 2'**
  String get verificationRequestLevel2Title;

  /// Action subtitle for personal verification level 2
  ///
  /// In en, this message translates to:
  /// **'Advanced personal identity verification'**
  String get verificationRequestLevel2Subtitle;

  /// Action title for public official verification
  ///
  /// In en, this message translates to:
  /// **'Request a Public official account'**
  String get verificationRequestPublicOfficialTitle;

  /// Action subtitle for public official verification
  ///
  /// In en, this message translates to:
  /// **'Requires an official title and review'**
  String get verificationRequestPublicOfficialSubtitle;

  /// Action title for public institution verification
  ///
  /// In en, this message translates to:
  /// **'Request a Public institution account'**
  String get verificationRequestPublicInstitutionTitle;

  /// Action subtitle for public institution verification
  ///
  /// In en, this message translates to:
  /// **'Requires the institution name, institution level, and review'**
  String get verificationRequestPublicInstitutionSubtitle;

  /// Action title for verified organization verification
  ///
  /// In en, this message translates to:
  /// **'Request a Verified organization account'**
  String get verificationRequestOrganizationTitle;

  /// Action subtitle for verified organization verification
  ///
  /// In en, this message translates to:
  /// **'Requires the organization name and review'**
  String get verificationRequestOrganizationSubtitle;

  /// Message when no self-service verification action is available
  ///
  /// In en, this message translates to:
  /// **'No verification options are available for your current account status.'**
  String get verificationNoSelfServiceUpgrade;

  /// Success message after submitting a verification request
  ///
  /// In en, this message translates to:
  /// **'Request submitted successfully.'**
  String get verificationRequestSubmitSuccess;

  /// Fallback error message after submitting a verification request
  ///
  /// In en, this message translates to:
  /// **'Unable to submit the request.'**
  String get verificationRequestSubmitFailure;

  /// Dialog title for a public official verification request
  ///
  /// In en, this message translates to:
  /// **'Public official verification'**
  String get verificationOfficialTitleDialogTitle;

  /// Field label for a public official title
  ///
  /// In en, this message translates to:
  /// **'Official title'**
  String get verificationOfficialTitleLabel;

  /// Hint for the public official title field
  ///
  /// In en, this message translates to:
  /// **'e.g. Mayor, Councillor, Minister'**
  String get verificationOfficialTitleHint;

  /// Dialog title for a public institution verification request
  ///
  /// In en, this message translates to:
  /// **'Public institution verification'**
  String get verificationInstitutionDialogTitle;

  /// Field label for the public institution name
  ///
  /// In en, this message translates to:
  /// **'Institution name'**
  String get verificationInstitutionNameLabel;

  /// Hint for the public institution name field
  ///
  /// In en, this message translates to:
  /// **'e.g. City of Rome'**
  String get verificationInstitutionNameHint;

  /// Field label for the public institution level
  ///
  /// In en, this message translates to:
  /// **'Institution level'**
  String get verificationInstitutionLevelLabel;

  /// Dialog title for a verified organization request
  ///
  /// In en, this message translates to:
  /// **'Organization verification'**
  String get verificationOrganizationDialogTitle;

  /// Hint for the verified organization name field
  ///
  /// In en, this message translates to:
  /// **'e.g. Environment Italy Association'**
  String get verificationOrganizationNameHint;

  /// Button label to submit a verification request
  ///
  /// In en, this message translates to:
  /// **'Submit request'**
  String get verificationSubmitRequestAction;

  /// Title of the pending verification cancellation dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get verificationCancelDialogTitle;

  /// Confirmation message for cancelling a pending verification request
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel the pending verification request?'**
  String get verificationCancelDialogBody;

  /// Success message after cancelling a verification request
  ///
  /// In en, this message translates to:
  /// **'Request cancelled.'**
  String get verificationCancelSuccess;

  /// Fallback error after cancelling a verification request
  ///
  /// In en, this message translates to:
  /// **'Unable to cancel the request.'**
  String get verificationCancelFailure;

  /// Status suffix shown when a verification request is pending
  ///
  /// In en, this message translates to:
  /// **'request under review'**
  String get verificationStatusPendingSuffix;

  /// Status suffix shown when the last verification request was rejected
  ///
  /// In en, this message translates to:
  /// **'last request rejected'**
  String get verificationStatusRejectedSuffix;

  /// Title of the administrator verification review page
  ///
  /// In en, this message translates to:
  /// **'Verification review'**
  String get verificationReviewPageTitle;

  /// Message shown when the reviewer is not logged in
  ///
  /// In en, this message translates to:
  /// **'You must sign in to review verification requests.'**
  String get verificationReviewLoginRequired;

  /// Number of pending verification requests
  ///
  /// In en, this message translates to:
  /// **'Pending requests: {count}'**
  String verificationReviewPendingCount(int count);

  /// Message shown when there are no pending verification requests
  ///
  /// In en, this message translates to:
  /// **'There are no pending verification requests.'**
  String get verificationReviewNoPendingRequests;

  /// Label for the user identifier in a verification review card
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get verificationReviewUserIdLabel;

  /// Label for the submission date of a verification request
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get verificationReviewSubmittedLabel;

  /// Label for the public official title in a review card
  ///
  /// In en, this message translates to:
  /// **'Official title'**
  String get verificationReviewOfficialTitleLabel;

  /// Label for the institution name in a review card
  ///
  /// In en, this message translates to:
  /// **'Institution'**
  String get verificationReviewInstitutionLabel;

  /// Label for the organization name in a review card
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get verificationReviewOrganizationLabel;

  /// Label for an existing review note
  ///
  /// In en, this message translates to:
  /// **'Review note'**
  String get verificationReviewNoteLabel;

  /// Button label to reject a verification request
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get verificationReviewRejectAction;

  /// Button label to approve a verification request
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get verificationReviewApproveAction;

  /// Title of the approve verification request dialog
  ///
  /// In en, this message translates to:
  /// **'Approve request'**
  String get verificationReviewApproveDialogTitle;

  /// Title of the reject verification request dialog
  ///
  /// In en, this message translates to:
  /// **'Reject request'**
  String get verificationReviewRejectDialogTitle;

  /// Confirmation message before approving a verification request
  ///
  /// In en, this message translates to:
  /// **'Confirm approval of this request?'**
  String get verificationReviewApproveConfirmation;

  /// Confirmation message before rejecting a verification request
  ///
  /// In en, this message translates to:
  /// **'Confirm rejection of this request?'**
  String get verificationReviewRejectConfirmation;

  /// Field label for an optional review note
  ///
  /// In en, this message translates to:
  /// **'Optional review note'**
  String get verificationReviewOptionalNoteLabel;

  /// Field label for the required rejection reason
  ///
  /// In en, this message translates to:
  /// **'Reason for rejection'**
  String get verificationReviewRequiredNoteLabel;

  /// Helper text for an optional review note
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get verificationReviewOptionalHelper;

  /// Helper text for the required rejection reason
  ///
  /// In en, this message translates to:
  /// **'Required when rejecting'**
  String get verificationReviewRequiredHelper;

  /// Validation error when the rejection reason is missing
  ///
  /// In en, this message translates to:
  /// **'Enter the reason for rejection.'**
  String get verificationReviewRequiredNoteError;

  /// Success message after approving a verification request
  ///
  /// In en, this message translates to:
  /// **'Request approved.'**
  String get verificationReviewApprovedSuccess;

  /// Success message after rejecting a verification request
  ///
  /// In en, this message translates to:
  /// **'Request rejected.'**
  String get verificationReviewRejectedSuccess;

  /// Fallback error message for a failed review operation
  ///
  /// In en, this message translates to:
  /// **'Operation failed.'**
  String get verificationReviewOperationFailure;

  /// No description provided for @adminCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Center'**
  String get adminCenterTitle;

  /// No description provided for @adminCenterDashboardNavigation.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get adminCenterDashboardNavigation;

  /// No description provided for @adminCenterUsersNavigation.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminCenterUsersNavigation;

  /// No description provided for @adminCenterVerificationNavigation.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get adminCenterVerificationNavigation;

  /// No description provided for @adminCenterReportsNavigation.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get adminCenterReportsNavigation;

  /// No description provided for @adminCenterAuditNavigation.
  ///
  /// In en, this message translates to:
  /// **'Audit'**
  String get adminCenterAuditNavigation;

  /// No description provided for @adminCenterAccountDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Account details'**
  String get adminCenterAccountDetailsTitle;

  /// No description provided for @adminCenterTryAgainAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get adminCenterTryAgainAction;

  /// No description provided for @adminCenterRetryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get adminCenterRetryAction;

  /// No description provided for @adminCenterClearAction.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get adminCenterClearAction;

  /// No description provided for @adminCenterApplyFiltersAction.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get adminCenterApplyFiltersAction;

  /// No description provided for @adminCenterAllDates.
  ///
  /// In en, this message translates to:
  /// **'All dates'**
  String get adminCenterAllDates;

  /// No description provided for @adminCenterAuditDateFilterHelp.
  ///
  /// In en, this message translates to:
  /// **'Filter audit by date'**
  String get adminCenterAuditDateFilterHelp;

  /// No description provided for @adminCenterActorUserIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Actor user ID'**
  String get adminCenterActorUserIdLabel;

  /// No description provided for @adminCenterActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get adminCenterActionLabel;

  /// No description provided for @adminCenterAuditActionHint.
  ///
  /// In en, this message translates to:
  /// **'resolve_escalated_report'**
  String get adminCenterAuditActionHint;

  /// No description provided for @adminCenterTargetIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Target ID'**
  String get adminCenterTargetIdLabel;

  /// No description provided for @adminCenterOutcomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Outcome'**
  String get adminCenterOutcomeLabel;

  /// No description provided for @adminCenterAllOutcomes.
  ///
  /// In en, this message translates to:
  /// **'All outcomes'**
  String get adminCenterAllOutcomes;

  /// No description provided for @adminCenterOutcomeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get adminCenterOutcomeSuccess;

  /// No description provided for @adminCenterOutcomeFailure.
  ///
  /// In en, this message translates to:
  /// **'Failure'**
  String get adminCenterOutcomeFailure;

  /// No description provided for @adminCenterOutcomeDenied.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get adminCenterOutcomeDenied;

  /// No description provided for @adminCenterOutcomeNoChange.
  ///
  /// In en, this message translates to:
  /// **'No change'**
  String get adminCenterOutcomeNoChange;

  /// No description provided for @adminCenterOutcomeUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get adminCenterOutcomeUnknown;

  /// No description provided for @adminCenterAuditUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Audit unavailable'**
  String get adminCenterAuditUnavailableTitle;

  /// No description provided for @adminCenterAuditUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and permissions, then try again.'**
  String get adminCenterAuditUnavailableMessage;

  /// No description provided for @adminCenterNoAuditEntriesTitle.
  ///
  /// In en, this message translates to:
  /// **'No audit entries'**
  String get adminCenterNoAuditEntriesTitle;

  /// No description provided for @adminCenterNoAuditEntriesMessage.
  ///
  /// In en, this message translates to:
  /// **'There are no entries matching the selected filters.'**
  String get adminCenterNoAuditEntriesMessage;

  /// No description provided for @adminCenterAuditIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Audit ID'**
  String get adminCenterAuditIdLabel;

  /// No description provided for @adminCenterActorLabel.
  ///
  /// In en, this message translates to:
  /// **'Actor'**
  String get adminCenterActorLabel;

  /// No description provided for @adminCenterReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get adminCenterReasonLabel;

  /// No description provided for @adminCenterTimestampLabel.
  ///
  /// In en, this message translates to:
  /// **'Timestamp'**
  String get adminCenterTimestampLabel;

  /// No description provided for @adminCenterErrorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get adminCenterErrorLabel;

  /// No description provided for @adminCenterRecordedValuesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recorded values'**
  String get adminCenterRecordedValuesTitle;

  /// No description provided for @adminCenterPreviousValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get adminCenterPreviousValueLabel;

  /// No description provided for @adminCenterNewValueLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get adminCenterNewValueLabel;

  /// No description provided for @adminCenterContentTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Content type'**
  String get adminCenterContentTypeLabel;

  /// No description provided for @adminCenterAllContent.
  ///
  /// In en, this message translates to:
  /// **'All content'**
  String get adminCenterAllContent;

  /// No description provided for @adminCenterPolls.
  ///
  /// In en, this message translates to:
  /// **'Polls'**
  String get adminCenterPolls;

  /// No description provided for @adminCenterPosts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get adminCenterPosts;

  /// No description provided for @adminCenterNews.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get adminCenterNews;

  /// No description provided for @adminCenterAwaitingAdminDecision.
  ///
  /// In en, this message translates to:
  /// **'Awaiting admin decision'**
  String get adminCenterAwaitingAdminDecision;

  /// No description provided for @adminCenterStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get adminCenterStatusLabel;

  /// No description provided for @adminCenterAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get adminCenterAllStatuses;

  /// No description provided for @adminCenterStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get adminCenterStatusOpen;

  /// No description provided for @adminCenterStatusInReview.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get adminCenterStatusInReview;

  /// No description provided for @adminCenterStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get adminCenterStatusResolved;

  /// No description provided for @adminCenterStatusDismissed.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get adminCenterStatusDismissed;

  /// No description provided for @adminCenterAdminQueueUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin escalation queue unavailable'**
  String get adminCenterAdminQueueUnavailableTitle;

  /// No description provided for @adminCenterReportsUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports unavailable'**
  String get adminCenterReportsUnavailableTitle;

  /// No description provided for @adminCenterConnectionTryAgainMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get adminCenterConnectionTryAgainMessage;

  /// No description provided for @adminCenterNoAdminReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'No reports awaiting admin decision'**
  String get adminCenterNoAdminReportsTitle;

  /// No description provided for @adminCenterNoReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'No reports'**
  String get adminCenterNoReportsTitle;

  /// No description provided for @adminCenterNoAdminReportsMessage.
  ///
  /// In en, this message translates to:
  /// **'There are no escalated reports requiring administrator review.'**
  String get adminCenterNoAdminReportsMessage;

  /// No description provided for @adminCenterNoReportsMessage.
  ///
  /// In en, this message translates to:
  /// **'There are no reports matching the selected filters.'**
  String get adminCenterNoReportsMessage;

  /// No description provided for @adminCenterSearchUsersHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, username, email or ID'**
  String get adminCenterSearchUsersHint;

  /// No description provided for @adminCenterClearSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get adminCenterClearSearchTooltip;

  /// No description provided for @adminCenterUsersUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Users unavailable'**
  String get adminCenterUsersUnavailableTitle;

  /// No description provided for @adminCenterNoUsersFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get adminCenterNoUsersFoundTitle;

  /// No description provided for @adminCenterNoUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'No users'**
  String get adminCenterNoUsersTitle;

  /// No description provided for @adminCenterNoUsersFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a different name, username, email or ID.'**
  String get adminCenterNoUsersFoundMessage;

  /// No description provided for @adminCenterNoUsersMessage.
  ///
  /// In en, this message translates to:
  /// **'There are no accounts to display.'**
  String get adminCenterNoUsersMessage;

  /// No description provided for @adminCenterAccountUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Account unavailable'**
  String get adminCenterAccountUnavailableTitle;

  /// No description provided for @adminCenterBackToUsersAction.
  ///
  /// In en, this message translates to:
  /// **'Back to users'**
  String get adminCenterBackToUsersAction;

  /// No description provided for @adminCenterPublicIdentitySection.
  ///
  /// In en, this message translates to:
  /// **'Public identity'**
  String get adminCenterPublicIdentitySection;

  /// No description provided for @adminCenterDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get adminCenterDisplayNameLabel;

  /// No description provided for @adminCenterNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get adminCenterNotProvided;

  /// No description provided for @adminCenterUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get adminCenterUsernameLabel;

  /// No description provided for @adminCenterUserIdLabel.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get adminCenterUserIdLabel;

  /// No description provided for @adminCenterIdentityTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Identity type'**
  String get adminCenterIdentityTypeLabel;

  /// No description provided for @adminCenterAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get adminCenterAccountSection;

  /// No description provided for @adminCenterTechnicalRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Technical role'**
  String get adminCenterTechnicalRoleLabel;

  /// No description provided for @adminCenterRoleMirrorLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile role mirror'**
  String get adminCenterRoleMirrorLabel;

  /// No description provided for @adminCenterRoleSynchronizationLabel.
  ///
  /// In en, this message translates to:
  /// **'Role synchronization'**
  String get adminCenterRoleSynchronizationLabel;

  /// No description provided for @adminCenterSynchronized.
  ///
  /// In en, this message translates to:
  /// **'Synchronized'**
  String get adminCenterSynchronized;

  /// No description provided for @adminCenterNotSynchronized.
  ///
  /// In en, this message translates to:
  /// **'Not synchronized'**
  String get adminCenterNotSynchronized;

  /// No description provided for @adminCenterRoleNotSynchronized.
  ///
  /// In en, this message translates to:
  /// **'Role not synchronized'**
  String get adminCenterRoleNotSynchronized;

  /// No description provided for @adminCenterAccountStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Account status'**
  String get adminCenterAccountStatusLabel;

  /// No description provided for @adminCenterSuspendedUntilLabel.
  ///
  /// In en, this message translates to:
  /// **'Suspended until'**
  String get adminCenterSuspendedUntilLabel;

  /// No description provided for @adminCenterAccountManagementSection.
  ///
  /// In en, this message translates to:
  /// **'Account management'**
  String get adminCenterAccountManagementSection;

  /// No description provided for @adminCenterDangerZoneSection.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get adminCenterDangerZoneSection;

  /// No description provided for @adminCenterRoleManagementSection.
  ///
  /// In en, this message translates to:
  /// **'Role management'**
  String get adminCenterRoleManagementSection;

  /// No description provided for @adminCenterVerificationLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification level'**
  String get adminCenterVerificationLevelLabel;

  /// No description provided for @adminCenterVerificationStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification status'**
  String get adminCenterVerificationStatusLabel;

  /// No description provided for @adminCenterAccessInformationSection.
  ///
  /// In en, this message translates to:
  /// **'Access information'**
  String get adminCenterAccessInformationSection;

  /// No description provided for @adminCenterEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get adminCenterEmailLabel;

  /// No description provided for @adminCenterNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get adminCenterNotAvailable;

  /// No description provided for @adminCenterEmailConfirmationLabel.
  ///
  /// In en, this message translates to:
  /// **'Email confirmation'**
  String get adminCenterEmailConfirmationLabel;

  /// No description provided for @adminCenterNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Not confirmed'**
  String get adminCenterNotConfirmed;

  /// No description provided for @adminCenterRegisteredLabel.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get adminCenterRegisteredLabel;

  /// No description provided for @adminCenterLastAccessLabel.
  ///
  /// In en, this message translates to:
  /// **'Last access'**
  String get adminCenterLastAccessLabel;

  /// No description provided for @adminCenterLoadingDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading dashboard'**
  String get adminCenterLoadingDashboardTitle;

  /// No description provided for @adminCenterLoadingDashboardMessage.
  ///
  /// In en, this message translates to:
  /// **'Retrieving the latest indicators.'**
  String get adminCenterLoadingDashboardMessage;

  /// No description provided for @adminCenterDashboardUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard unavailable'**
  String get adminCenterDashboardUnavailableTitle;

  /// No description provided for @adminCenterIndicatorsUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'The indicators could not be loaded.'**
  String get adminCenterIndicatorsUnavailableMessage;

  /// No description provided for @adminCenterVerificationPendingIndicator.
  ///
  /// In en, this message translates to:
  /// **'Verification pending'**
  String get adminCenterVerificationPendingIndicator;

  /// No description provided for @adminCenterOpenReportsIndicator.
  ///
  /// In en, this message translates to:
  /// **'Open reports'**
  String get adminCenterOpenReportsIndicator;

  /// No description provided for @adminCenterSuspendedAccountsIndicator.
  ///
  /// In en, this message translates to:
  /// **'Suspended accounts'**
  String get adminCenterSuspendedAccountsIndicator;

  /// No description provided for @adminCenterStaffIndicator.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get adminCenterStaffIndicator;

  /// No description provided for @adminCenterNoPendingWorkTitle.
  ///
  /// In en, this message translates to:
  /// **'No pending work'**
  String get adminCenterNoPendingWorkTitle;

  /// No description provided for @adminCenterNoPendingWorkMessage.
  ///
  /// In en, this message translates to:
  /// **'Verification, reports, and suspended accounts are clear.'**
  String get adminCenterNoPendingWorkMessage;

  /// No description provided for @adminCenterCouldNotUpdateUsers.
  ///
  /// In en, this message translates to:
  /// **'Could not update the user list.'**
  String get adminCenterCouldNotUpdateUsers;

  /// No description provided for @adminCenterCouldNotUpdateReports.
  ///
  /// In en, this message translates to:
  /// **'Could not update the report queue.'**
  String get adminCenterCouldNotUpdateReports;

  /// No description provided for @adminCenterUnnamedUser.
  ///
  /// In en, this message translates to:
  /// **'Unnamed user'**
  String get adminCenterUnnamedUser;

  /// No description provided for @adminCenterTemporarySuspensionTitle.
  ///
  /// In en, this message translates to:
  /// **'Temporary suspension'**
  String get adminCenterTemporarySuspensionTitle;

  /// No description provided for @adminCenterReactivateDescription.
  ///
  /// In en, this message translates to:
  /// **'Remove the suspension immediately and allow a new login.'**
  String get adminCenterReactivateDescription;

  /// No description provided for @adminCenterSuspendDescription.
  ///
  /// In en, this message translates to:
  /// **'Block access for a limited time and end all current sessions.'**
  String get adminCenterSuspendDescription;

  /// No description provided for @adminCenterSuspensionUnavailableDescription.
  ///
  /// In en, this message translates to:
  /// **'Suspension requires a synchronized, non-admin account.'**
  String get adminCenterSuspensionUnavailableDescription;

  /// No description provided for @adminCenterReactivateAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Reactivate account'**
  String get adminCenterReactivateAccountAction;

  /// No description provided for @adminCenterSuspendAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Suspend account'**
  String get adminCenterSuspendAccountAction;

  /// No description provided for @adminCenterForceLogoutAction.
  ///
  /// In en, this message translates to:
  /// **'Force logout'**
  String get adminCenterForceLogoutAction;

  /// No description provided for @adminCenterSuspendedForceLogoutDescription.
  ///
  /// In en, this message translates to:
  /// **'The suspension has already ended current sessions. Reactivate the account before testing a separate logout.'**
  String get adminCenterSuspendedForceLogoutDescription;

  /// No description provided for @adminCenterForceLogoutDescription.
  ///
  /// In en, this message translates to:
  /// **'End every current session without suspending the account.'**
  String get adminCenterForceLogoutDescription;

  /// No description provided for @adminCenterForceLogoutUnavailableDescription.
  ///
  /// In en, this message translates to:
  /// **'Forced logout requires a synchronized, non-admin account.'**
  String get adminCenterForceLogoutUnavailableDescription;

  /// No description provided for @adminCenterPermanentDeletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Permanent account deletion'**
  String get adminCenterPermanentDeletionTitle;

  /// No description provided for @adminCenterPermanentDeletionDescription.
  ///
  /// In en, this message translates to:
  /// **'Delete authentication data, end every session and anonymize the retained public record.'**
  String get adminCenterPermanentDeletionDescription;

  /// No description provided for @adminCenterDeletionUnavailableDescription.
  ///
  /// In en, this message translates to:
  /// **'Deletion requires a synchronized, non-admin account.'**
  String get adminCenterDeletionUnavailableDescription;

  /// No description provided for @adminCenterDeleteAccountPermanentlyAction.
  ///
  /// In en, this message translates to:
  /// **'Delete account permanently'**
  String get adminCenterDeleteAccountPermanentlyAction;

  /// No description provided for @adminCenterDurationOneHour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get adminCenterDurationOneHour;

  /// No description provided for @adminCenterDurationOneDay.
  ///
  /// In en, this message translates to:
  /// **'24 hours'**
  String get adminCenterDurationOneDay;

  /// No description provided for @adminCenterDurationSevenDays.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get adminCenterDurationSevenDays;

  /// No description provided for @adminCenterDurationThirtyDays.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get adminCenterDurationThirtyDays;

  /// No description provided for @adminCenterSuspendImmediateEffect.
  ///
  /// In en, this message translates to:
  /// **'The account will lose access immediately and every current session will be ended.'**
  String get adminCenterSuspendImmediateEffect;

  /// No description provided for @adminCenterDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get adminCenterDurationLabel;

  /// No description provided for @adminCenterSuspendReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Explain why this account must be suspended'**
  String get adminCenterSuspendReasonHint;

  /// No description provided for @adminCenterReactivateReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Explain why this account can be reactivated'**
  String get adminCenterReactivateReasonHint;

  /// No description provided for @adminCenterReactivateConfirmation.
  ///
  /// In en, this message translates to:
  /// **'I confirm that this account can regain access.'**
  String get adminCenterReactivateConfirmation;

  /// No description provided for @adminCenterReactivateFailure.
  ///
  /// In en, this message translates to:
  /// **'The account could not be reactivated. Check its role and status, then try again.'**
  String get adminCenterReactivateFailure;

  /// No description provided for @adminCenterReactivateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account reactivated. A new login is now allowed.'**
  String get adminCenterReactivateSuccess;

  /// No description provided for @adminCenterForceLogoutFullDescription.
  ///
  /// In en, this message translates to:
  /// **'End every current session for this account. The account remains active and can sign in again.'**
  String get adminCenterForceLogoutFullDescription;

  /// No description provided for @adminCenterForceLogoutReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Explain why current sessions must be ended'**
  String get adminCenterForceLogoutReasonHint;

  /// No description provided for @adminCenterForceLogoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'I confirm the immediate termination of all current sessions for this account.'**
  String get adminCenterForceLogoutConfirmation;

  /// No description provided for @adminCenterForceLogoutFailure.
  ///
  /// In en, this message translates to:
  /// **'The account could not be signed out. Check its role and status, then try again.'**
  String get adminCenterForceLogoutFailure;

  /// No description provided for @adminCenterForceLogoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Current sessions ended. The account can sign in again.'**
  String get adminCenterForceLogoutSuccess;

  /// No description provided for @adminCenterSuspendFailure.
  ///
  /// In en, this message translates to:
  /// **'The account could not be suspended. Check its role and status, then try again.'**
  String get adminCenterSuspendFailure;

  /// No description provided for @adminCenterDeleteReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Explain why this account must be deleted'**
  String get adminCenterDeleteReasonHint;

  /// No description provided for @adminCenterTypeDeleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE'**
  String get adminCenterTypeDeleteLabel;

  /// No description provided for @adminCenterTypeAccountIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Type the complete Account ID'**
  String get adminCenterTypeAccountIdLabel;

  /// No description provided for @adminCenterDeletePermanentlyAction.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get adminCenterDeletePermanentlyAction;

  /// No description provided for @adminCenterDeleteIrreversibleWarning.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible. Authentication data and current sessions will be removed, the avatar will be deleted and the retained public record will be anonymized. The audit record will remain.'**
  String get adminCenterDeleteIrreversibleWarning;

  /// No description provided for @adminCenterDeleteFailure.
  ///
  /// In en, this message translates to:
  /// **'The account could not be deleted. Check its role, status and confirmation values, then try again.'**
  String get adminCenterDeleteFailure;

  /// No description provided for @adminCenterDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account permanently deleted and personal data anonymized.'**
  String get adminCenterDeleteSuccess;

  /// No description provided for @adminCenterChangeTechnicalRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Change technical role'**
  String get adminCenterChangeTechnicalRoleTitle;

  /// No description provided for @adminCenterChangeRoleDescription.
  ///
  /// In en, this message translates to:
  /// **'Review the current and requested role before confirming.'**
  String get adminCenterChangeRoleDescription;

  /// No description provided for @adminCenterChangeRoleUnavailableDescription.
  ///
  /// In en, this message translates to:
  /// **'Role changes require a synchronized, non-deleted account.'**
  String get adminCenterChangeRoleUnavailableDescription;

  /// No description provided for @adminCenterChangeRoleAction.
  ///
  /// In en, this message translates to:
  /// **'Change role'**
  String get adminCenterChangeRoleAction;

  /// No description provided for @adminCenterChangePublicIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'Change public identity'**
  String get adminCenterChangePublicIdentityTitle;

  /// No description provided for @adminCenterChangeIdentityDescription.
  ///
  /// In en, this message translates to:
  /// **'Update the public account type and verification level.'**
  String get adminCenterChangeIdentityDescription;

  /// No description provided for @adminCenterChangeIdentityUnavailableDescription.
  ///
  /// In en, this message translates to:
  /// **'Identity changes require a synchronized, non-admin account.'**
  String get adminCenterChangeIdentityUnavailableDescription;

  /// No description provided for @adminCenterChangeIdentityAction.
  ///
  /// In en, this message translates to:
  /// **'Change identity'**
  String get adminCenterChangeIdentityAction;

  /// No description provided for @adminCenterChoosePublicIdentityMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose the public account type and its verification state.'**
  String get adminCenterChoosePublicIdentityMessage;

  /// No description provided for @adminCenterPublicAccountTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Public account type'**
  String get adminCenterPublicAccountTypeLabel;

  /// No description provided for @adminCenterPersonVerificationHelper.
  ///
  /// In en, this message translates to:
  /// **'Level 1 and Level 2 are available only for Persona.'**
  String get adminCenterPersonVerificationHelper;

  /// No description provided for @adminCenterNonPersonVerificationHelper.
  ///
  /// In en, this message translates to:
  /// **'Non-Persona accounts do not use Level 1 or Level 2.'**
  String get adminCenterNonPersonVerificationHelper;

  /// No description provided for @adminCenterBeforeLabel.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get adminCenterBeforeLabel;

  /// No description provided for @adminCenterAfterLabel.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get adminCenterAfterLabel;

  /// No description provided for @adminCenterIdentityReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Explain why the public identity must change'**
  String get adminCenterIdentityReasonHint;

  /// No description provided for @adminCenterIdentityConfirmation.
  ///
  /// In en, this message translates to:
  /// **'I confirm the public identity and verification level shown above.'**
  String get adminCenterIdentityConfirmation;

  /// No description provided for @adminCenterIdentityChangeFailure.
  ///
  /// In en, this message translates to:
  /// **'The public identity could not be changed. Check the account state and try again.'**
  String get adminCenterIdentityChangeFailure;

  /// No description provided for @adminCenterChooseTechnicalRoleMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose the new technical role and record why this change is required.'**
  String get adminCenterChooseTechnicalRoleMessage;

  /// No description provided for @adminCenterNewTechnicalRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'New technical role'**
  String get adminCenterNewTechnicalRoleLabel;

  /// No description provided for @adminCenterSelectRole.
  ///
  /// In en, this message translates to:
  /// **'Select a role'**
  String get adminCenterSelectRole;

  /// No description provided for @adminCenterRoleSessionWarning.
  ///
  /// In en, this message translates to:
  /// **'This change ends the recipient’s active session. They must sign in again before continuing to use the account.'**
  String get adminCenterRoleSessionWarning;

  /// No description provided for @adminCenterRoleReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Explain why the technical role must change'**
  String get adminCenterRoleReasonHint;

  /// No description provided for @adminCenterRoleConfirmation.
  ///
  /// In en, this message translates to:
  /// **'I confirm the role shown above and understand that the recipient must sign in again.'**
  String get adminCenterRoleConfirmation;

  /// No description provided for @adminCenterRoleChangeFailure.
  ///
  /// In en, this message translates to:
  /// **'The role change could not be completed. Check the account state and try again.'**
  String get adminCenterRoleChangeFailure;

  /// No description provided for @adminCenterChangingRole.
  ///
  /// In en, this message translates to:
  /// **'Changing role'**
  String get adminCenterChangingRole;

  /// No description provided for @adminCenterConfirmRoleChange.
  ///
  /// In en, this message translates to:
  /// **'Confirm role change'**
  String get adminCenterConfirmRoleChange;

  /// No description provided for @adminCenterRoleUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get adminCenterRoleUser;

  /// No description provided for @adminCenterRoleModerator.
  ///
  /// In en, this message translates to:
  /// **'Moderator'**
  String get adminCenterRoleModerator;

  /// No description provided for @adminCenterRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminCenterRoleAdmin;

  /// No description provided for @adminCenterAccountStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminCenterAccountStatusActive;

  /// No description provided for @adminCenterAccountStatusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get adminCenterAccountStatusSuspended;

  /// No description provided for @adminCenterAccountStatusDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get adminCenterAccountStatusDeleted;

  /// No description provided for @adminCenterVerificationStatusNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get adminCenterVerificationStatusNone;

  /// No description provided for @adminCenterVerificationStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get adminCenterVerificationStatusPending;

  /// No description provided for @adminCenterVerificationStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get adminCenterVerificationStatusRejected;

  /// No description provided for @adminCenterVerificationNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get adminCenterVerificationNotVerified;

  /// No description provided for @adminCenterVerificationLevel1.
  ///
  /// In en, this message translates to:
  /// **'Level 1'**
  String get adminCenterVerificationLevel1;

  /// No description provided for @adminCenterVerificationLevel2.
  ///
  /// In en, this message translates to:
  /// **'Level 2'**
  String get adminCenterVerificationLevel2;

  /// No description provided for @adminCenterReportSingular.
  ///
  /// In en, this message translates to:
  /// **'report'**
  String get adminCenterReportSingular;

  /// No description provided for @adminCenterReportPlural.
  ///
  /// In en, this message translates to:
  /// **'reports'**
  String get adminCenterReportPlural;

  /// No description provided for @adminCenterUserSingular.
  ///
  /// In en, this message translates to:
  /// **'user'**
  String get adminCenterUserSingular;

  /// No description provided for @adminCenterUserPlural.
  ///
  /// In en, this message translates to:
  /// **'users'**
  String get adminCenterUserPlural;

  /// No description provided for @adminCenterPoll.
  ///
  /// In en, this message translates to:
  /// **'Poll'**
  String get adminCenterPoll;

  /// No description provided for @adminCenterPost.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get adminCenterPost;

  /// No description provided for @adminCenterUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get adminCenterUnknown;

  /// No description provided for @adminCenterContentHidden.
  ///
  /// In en, this message translates to:
  /// **'Content hidden'**
  String get adminCenterContentHidden;

  /// No description provided for @adminCenterContentVisible.
  ///
  /// In en, this message translates to:
  /// **'Content visible'**
  String get adminCenterContentVisible;

  /// No description provided for @adminCenterReportedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Reported by'**
  String get adminCenterReportedByLabel;

  /// No description provided for @adminCenterContentOwnerLabel.
  ///
  /// In en, this message translates to:
  /// **'Content owner'**
  String get adminCenterContentOwnerLabel;

  /// No description provided for @adminCenterReviewReportAction.
  ///
  /// In en, this message translates to:
  /// **'Review report'**
  String get adminCenterReviewReportAction;

  /// No description provided for @adminCenterAdminDecisionAction.
  ///
  /// In en, this message translates to:
  /// **'Admin decision'**
  String get adminCenterAdminDecisionAction;

  /// No description provided for @adminCenterRestoreContentAction.
  ///
  /// In en, this message translates to:
  /// **'Restore content'**
  String get adminCenterRestoreContentAction;

  /// No description provided for @adminCenterHideContentAction.
  ///
  /// In en, this message translates to:
  /// **'Hide content'**
  String get adminCenterHideContentAction;

  /// No description provided for @adminCenterOpenProfileAction.
  ///
  /// In en, this message translates to:
  /// **'Open profile'**
  String get adminCenterOpenProfileAction;

  /// No description provided for @adminCenterOpenContentAction.
  ///
  /// In en, this message translates to:
  /// **'Open content'**
  String get adminCenterOpenContentAction;

  /// No description provided for @adminCenterDecisionNoViolation.
  ///
  /// In en, this message translates to:
  /// **'No violation'**
  String get adminCenterDecisionNoViolation;

  /// No description provided for @adminCenterDecisionViolationConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Violation confirmed'**
  String get adminCenterDecisionViolationConfirmed;

  /// No description provided for @adminCenterDecisionEscalateToAdmin.
  ///
  /// In en, this message translates to:
  /// **'Escalate to admin'**
  String get adminCenterDecisionEscalateToAdmin;

  /// No description provided for @adminCenterResolutionNoAccountAction.
  ///
  /// In en, this message translates to:
  /// **'No account action'**
  String get adminCenterResolutionNoAccountAction;

  /// No description provided for @adminCenterResolutionAccountSuspended.
  ///
  /// In en, this message translates to:
  /// **'Account suspended'**
  String get adminCenterResolutionAccountSuspended;

  /// No description provided for @adminCenterResolutionLogoutForced.
  ///
  /// In en, this message translates to:
  /// **'Logout forced'**
  String get adminCenterResolutionLogoutForced;

  /// No description provided for @adminCenterResolutionAccountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get adminCenterResolutionAccountDeleted;

  /// No description provided for @adminCenterReviewerLabel.
  ///
  /// In en, this message translates to:
  /// **'Reviewer'**
  String get adminCenterReviewerLabel;

  /// No description provided for @adminCenterDecisionDescriptionNoViolation.
  ///
  /// In en, this message translates to:
  /// **'Dismisses the report because the content does not violate the current rules.'**
  String get adminCenterDecisionDescriptionNoViolation;

  /// No description provided for @adminCenterDecisionDescriptionViolation.
  ///
  /// In en, this message translates to:
  /// **'Confirms a violation and keeps the case in review for the content action handled in AC8.5.'**
  String get adminCenterDecisionDescriptionViolation;

  /// No description provided for @adminCenterDecisionDescriptionEscalation.
  ///
  /// In en, this message translates to:
  /// **'Escalates the case for an administrator account-level review.'**
  String get adminCenterDecisionDescriptionEscalation;

  /// No description provided for @adminCenterChooseModerationOutcome.
  ///
  /// In en, this message translates to:
  /// **'Choose the moderation outcome for this report.'**
  String get adminCenterChooseModerationOutcome;

  /// No description provided for @adminCenterDecisionAlreadyRecordedFailure.
  ///
  /// In en, this message translates to:
  /// **'The decision could not be recorded. The report may already have been reviewed. Refresh the queue and try again.'**
  String get adminCenterDecisionAlreadyRecordedFailure;

  /// No description provided for @adminCenterDecisionLabel.
  ///
  /// In en, this message translates to:
  /// **'Decision'**
  String get adminCenterDecisionLabel;

  /// No description provided for @adminCenterReportReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Report reason'**
  String get adminCenterReportReasonLabel;

  /// No description provided for @adminCenterReviewNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Review note'**
  String get adminCenterReviewNoteLabel;

  /// No description provided for @adminCenterReviewNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Explain the evidence and the moderation decision'**
  String get adminCenterReviewNoteHint;

  /// No description provided for @adminCenterRecordingDecision.
  ///
  /// In en, this message translates to:
  /// **'Recording decision'**
  String get adminCenterRecordingDecision;

  /// No description provided for @adminCenterConfirmDecision.
  ///
  /// In en, this message translates to:
  /// **'Confirm decision'**
  String get adminCenterConfirmDecision;

  /// No description provided for @adminCenterAdministratorDecisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Administrator decision'**
  String get adminCenterAdministratorDecisionTitle;

  /// No description provided for @adminCenterResolutionDescriptionNoAction.
  ///
  /// In en, this message translates to:
  /// **'Closes the escalated report without changing the account.'**
  String get adminCenterResolutionDescriptionNoAction;

  /// No description provided for @adminCenterResolutionDescriptionSuspended.
  ///
  /// In en, this message translates to:
  /// **'Closes the report after a successful account suspension has already been recorded in the audit log.'**
  String get adminCenterResolutionDescriptionSuspended;

  /// No description provided for @adminCenterResolutionDescriptionLogout.
  ///
  /// In en, this message translates to:
  /// **'Closes the report after a successful forced logout has already been recorded in the audit log.'**
  String get adminCenterResolutionDescriptionLogout;

  /// No description provided for @adminCenterResolutionDescriptionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Closes the report after a successful account deletion has already been recorded in the audit log.'**
  String get adminCenterResolutionDescriptionDeleted;

  /// No description provided for @adminCenterChooseFinalOutcome.
  ///
  /// In en, this message translates to:
  /// **'Choose the final administrator outcome for this escalation.'**
  String get adminCenterChooseFinalOutcome;

  /// No description provided for @adminCenterAdminResolutionFailure.
  ///
  /// In en, this message translates to:
  /// **'The administrator decision could not be recorded. Refresh the queue and try again.'**
  String get adminCenterAdminResolutionFailure;

  /// No description provided for @adminCenterAdminResolutionRequiresAction.
  ///
  /// In en, this message translates to:
  /// **'Complete the matching account action first, then return to this report and record the final administrator decision.'**
  String get adminCenterAdminResolutionRequiresAction;

  /// No description provided for @adminCenterEscalationNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Escalation note'**
  String get adminCenterEscalationNoteLabel;

  /// No description provided for @adminCenterFinalOutcomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Final outcome'**
  String get adminCenterFinalOutcomeLabel;

  /// No description provided for @adminCenterAdministratorNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Administrator note'**
  String get adminCenterAdministratorNoteLabel;

  /// No description provided for @adminCenterAdministratorNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Explain the final account-level decision'**
  String get adminCenterAdministratorNoteHint;

  /// No description provided for @adminCenterHideContentFailure.
  ///
  /// In en, this message translates to:
  /// **'The content could not be hidden. Refresh the report queue and try again.'**
  String get adminCenterHideContentFailure;

  /// No description provided for @adminCenterRestoreContentFailure.
  ///
  /// In en, this message translates to:
  /// **'The content could not be restored. Refresh the report queue and try again.'**
  String get adminCenterRestoreContentFailure;

  /// No description provided for @adminCenterHideContentWarning.
  ///
  /// In en, this message translates to:
  /// **'This removes the reported content from public access. The action can later be reversed from the Resolved reports filter.'**
  String get adminCenterHideContentWarning;

  /// No description provided for @adminCenterRestoreContentWarning.
  ///
  /// In en, this message translates to:
  /// **'This makes the reported content publicly available again.'**
  String get adminCenterRestoreContentWarning;

  /// No description provided for @adminCenterActionReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Action reason'**
  String get adminCenterActionReasonLabel;

  /// No description provided for @adminCenterHideContentReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Explain why the content must be hidden'**
  String get adminCenterHideContentReasonHint;

  /// No description provided for @adminCenterRestoreContentReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Explain why the content can be restored'**
  String get adminCenterRestoreContentReasonHint;

  /// No description provided for @adminCenterHidingContent.
  ///
  /// In en, this message translates to:
  /// **'Hiding content'**
  String get adminCenterHidingContent;

  /// No description provided for @adminCenterRestoringContent.
  ///
  /// In en, this message translates to:
  /// **'Restoring content'**
  String get adminCenterRestoringContent;

  /// No description provided for @adminCenterReportedProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Reported profile'**
  String get adminCenterReportedProfileTitle;

  /// No description provided for @adminCenterReportedProfileNotice.
  ///
  /// In en, this message translates to:
  /// **'This profile context comes from the protected report queue. Administrative account actions remain separate.'**
  String get adminCenterReportedProfileNotice;

  /// No description provided for @adminCenterCouldNotRefreshIndicators.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh the indicators.'**
  String get adminCenterCouldNotRefreshIndicators;

  /// No description provided for @adminCenterCouldNotRefreshAccount.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh the account details.'**
  String get adminCenterCouldNotRefreshAccount;

  /// No description provided for @adminCenterReportAlreadyReviewed.
  ///
  /// In en, this message translates to:
  /// **'This report has already been reviewed or is no longer pending.'**
  String get adminCenterReportAlreadyReviewed;

  /// No description provided for @adminCenterReportNotAwaitingAdmin.
  ///
  /// In en, this message translates to:
  /// **'This report is not awaiting an administrator decision.'**
  String get adminCenterReportNotAwaitingAdmin;

  /// No description provided for @adminCenterConfirmedViolationRequired.
  ///
  /// In en, this message translates to:
  /// **'A confirmed violation is required before changing content visibility.'**
  String get adminCenterConfirmedViolationRequired;

  /// No description provided for @adminCenterContentHiddenSuccess.
  ///
  /// In en, this message translates to:
  /// **'The reported content was hidden.'**
  String get adminCenterContentHiddenSuccess;

  /// No description provided for @adminCenterContentRestoredSuccess.
  ///
  /// In en, this message translates to:
  /// **'The reported content was restored.'**
  String get adminCenterContentRestoredSuccess;

  /// No description provided for @adminCenterMissingContentId.
  ///
  /// In en, this message translates to:
  /// **'The original content identifier is missing.'**
  String get adminCenterMissingContentId;

  /// No description provided for @adminCenterUnsupportedTargetType.
  ///
  /// In en, this message translates to:
  /// **'This report has an unsupported target type.'**
  String get adminCenterUnsupportedTargetType;

  /// No description provided for @adminCenterOriginalContentUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The original content is no longer available.'**
  String get adminCenterOriginalContentUnavailable;

  /// No description provided for @adminCenterNoReportedProfile.
  ///
  /// In en, this message translates to:
  /// **'No reported profile is associated with this content.'**
  String get adminCenterNoReportedProfile;

  /// No description provided for @adminCenterRoleChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Technical role changed from {previousRole} to {newRole}. The recipient was signed out and must sign in again.'**
  String adminCenterRoleChangedSuccess(String previousRole, String newRole);

  /// No description provided for @adminCenterIdentityChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Public identity changed to {actorType} with {verificationLevel}.'**
  String adminCenterIdentityChangedSuccess(String actorType, String verificationLevel);

  /// No description provided for @adminCenterAccountSuspendedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account suspended until {dateTime}. The recipient was signed out.'**
  String adminCenterAccountSuspendedSuccess(String dateTime);

  /// No description provided for @adminCenterReportDecisionRecorded.
  ///
  /// In en, this message translates to:
  /// **'Report decision recorded: {decision}.'**
  String adminCenterReportDecisionRecorded(String decision);

  /// No description provided for @adminCenterAdministratorDecisionRecorded.
  ///
  /// In en, this message translates to:
  /// **'Administrator decision recorded: {decision}.'**
  String adminCenterAdministratorDecisionRecorded(String decision);

  /// No description provided for @adminCenterUsersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {{count} user} other {{count} users}}'**
  String adminCenterUsersCount(int count);

  /// No description provided for @adminCenterReportsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {{count} report} other {{count} reports}}'**
  String adminCenterReportsCount(int count);

  /// No description provided for @adminCenterAccountValue.
  ///
  /// In en, this message translates to:
  /// **'Account: {account}'**
  String adminCenterAccountValue(String account);

  /// No description provided for @adminCenterSuspendedUntilValue.
  ///
  /// In en, this message translates to:
  /// **'Suspended until: {dateTime}'**
  String adminCenterSuspendedUntilValue(String dateTime);

  /// No description provided for @adminCenterSuspendConfirmation.
  ///
  /// In en, this message translates to:
  /// **'I confirm the suspension until {dateTime} and the immediate termination of current sessions.'**
  String adminCenterSuspendConfirmation(String dateTime);

  /// No description provided for @adminCenterAccountIdValue.
  ///
  /// In en, this message translates to:
  /// **'Account ID: {accountId}'**
  String adminCenterAccountIdValue(String accountId);

  /// No description provided for @adminCenterCurrentRoleValue.
  ///
  /// In en, this message translates to:
  /// **'Current: {role}'**
  String adminCenterCurrentRoleValue(String role);

  /// No description provided for @adminCenterTargetFallback.
  ///
  /// In en, this message translates to:
  /// **'{targetType} {targetId}'**
  String adminCenterTargetFallback(String targetType, String targetId);

  /// No description provided for @adminCenterMinimumCharactersRequired.
  ///
  /// In en, this message translates to:
  /// **'A note of at least {count} characters is required.'**
  String adminCenterMinimumCharactersRequired(int count);

  /// No description provided for @adminCenterMinimumReasonCharactersRequired.
  ///
  /// In en, this message translates to:
  /// **'A reason of at least {count} characters is required.'**
  String adminCenterMinimumReasonCharactersRequired(int count);

  /// No description provided for @adminCenterPageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {currentPage} of {totalPages}'**
  String adminCenterPageOf(int currentPage, int totalPages);

  /// No description provided for @profilePublicProfileSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Public profile'**
  String get profilePublicProfileSectionTitle;

  /// No description provided for @profileIdentityVerificationSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity and verification'**
  String get profileIdentityVerificationSectionTitle;

  /// No description provided for @profilePreferencesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profilePreferencesSectionTitle;

  /// No description provided for @profileNotificationsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotificationsSectionTitle;

  /// No description provided for @profileActivitySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal activity'**
  String get profileActivitySectionTitle;

  /// No description provided for @profileSecurityAccountSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Security and account'**
  String get profileSecurityAccountSectionTitle;

  /// No description provided for @profileThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get profileThemeTitle;

  /// No description provided for @profileThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get profileThemeSystem;

  /// No description provided for @profileThemeSystemDescription.
  ///
  /// In en, this message translates to:
  /// **'Follows the device theme'**
  String get profileThemeSystemDescription;

  /// No description provided for @profileThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get profileThemeLight;

  /// No description provided for @profileThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get profileThemeDark;

  /// No description provided for @profileMyPollsTitle.
  ///
  /// In en, this message translates to:
  /// **'My polls'**
  String get profileMyPollsTitle;

  /// No description provided for @profileMyPostsTitle.
  ///
  /// In en, this message translates to:
  /// **'My posts'**
  String get profileMyPostsTitle;

  /// No description provided for @profileMyCommentsTitle.
  ///
  /// In en, this message translates to:
  /// **'My comments'**
  String get profileMyCommentsTitle;

  /// No description provided for @profileMyFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'My favorites'**
  String get profileMyFavoritesTitle;

  /// No description provided for @profileAccountConnectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Following and followers'**
  String get profileAccountConnectionsTitle;

  /// No description provided for @accountConnectionsFollowingTab.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get accountConnectionsFollowingTab;

  /// No description provided for @accountConnectionsFollowersTab.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get accountConnectionsFollowersTab;

  /// No description provided for @accountConnectionsEmptyFollowing.
  ///
  /// In en, this message translates to:
  /// **'You are not following any accounts yet.'**
  String get accountConnectionsEmptyFollowing;

  /// No description provided for @accountConnectionsEmptyFollowers.
  ///
  /// In en, this message translates to:
  /// **'You do not have any followers yet.'**
  String get accountConnectionsEmptyFollowers;

  /// No description provided for @accountConnectionsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load accounts. Try again.'**
  String get accountConnectionsLoadError;

  /// No description provided for @profileMyFollowedScopesTitle.
  ///
  /// In en, this message translates to:
  /// **'My followed areas'**
  String get profileMyFollowedScopesTitle;

  /// No description provided for @profileLogoutAction.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogoutAction;

  /// No description provided for @profileLogoutDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign out of the current account'**
  String get profileLogoutDescription;

  /// No description provided for @profileLogoutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogoutDialogTitle;

  /// No description provided for @profileLogoutDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get profileLogoutDialogMessage;

  /// No description provided for @profileLogoutCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileLogoutCancelButton;

  /// No description provided for @profileLogoutConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogoutConfirmButton;

  /// No description provided for @publicProfilePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Public profile'**
  String get publicProfilePageTitle;

  /// No description provided for @publicProfileUserFallback.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get publicProfileUserFallback;

  /// No description provided for @publicProfileNoBio.
  ///
  /// In en, this message translates to:
  /// **'No bio available.'**
  String get publicProfileNoBio;

  /// No description provided for @publicProfileResidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Residence'**
  String get publicProfileResidenceLabel;

  /// No description provided for @publicProfileResidenceUnknown.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get publicProfileResidenceUnknown;

  /// No description provided for @publicProfileMemberSinceLabel.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get publicProfileMemberSinceLabel;

  /// No description provided for @publicProfileContentSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Public content'**
  String get publicProfileContentSectionTitle;

  /// No description provided for @publicProfilePollsAction.
  ///
  /// In en, this message translates to:
  /// **'Polls'**
  String get publicProfilePollsAction;

  /// No description provided for @publicProfilePostsAction.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get publicProfilePostsAction;

  /// No description provided for @publicProfileBlockUserAction.
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get publicProfileBlockUserAction;

  /// No description provided for @publicProfileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load the profile.'**
  String get publicProfileLoadError;

  /// No description provided for @publicProfileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Profile unavailable.'**
  String get publicProfileNotFound;

  /// No description provided for @publicProfileUnblockUserAction.
  ///
  /// In en, this message translates to:
  /// **'Unblock user'**
  String get publicProfileUnblockUserAction;

  /// No description provided for @publicProfileBlockDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Block this user?'**
  String get publicProfileBlockDialogTitle;

  /// No description provided for @publicProfileBlockDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'You can unblock them later from their public profile.'**
  String get publicProfileBlockDialogMessage;

  /// No description provided for @publicProfileUnblockDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Unblock this user?'**
  String get publicProfileUnblockDialogTitle;

  /// No description provided for @publicProfileUnblockDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'The user will no longer be in your block list.'**
  String get publicProfileUnblockDialogMessage;

  /// No description provided for @publicProfileBlockSuccess.
  ///
  /// In en, this message translates to:
  /// **'User blocked.'**
  String get publicProfileBlockSuccess;

  /// No description provided for @publicProfileUnblockSuccess.
  ///
  /// In en, this message translates to:
  /// **'User unblocked.'**
  String get publicProfileUnblockSuccess;

  /// No description provided for @publicProfileBlockError.
  ///
  /// In en, this message translates to:
  /// **'Unable to update the block. Try again.'**
  String get publicProfileBlockError;

  /// No description provided for @publicProfileFollowersLabel.
  String get publicProfileFollowersLabel;

  /// No description provided for @publicProfileFollowingLabel.
  String get publicProfileFollowingLabel;

  /// No description provided for @publicProfileFollowAction.
  String get publicProfileFollowAction;

  /// No description provided for @publicProfileUnfollowAction.
  String get publicProfileUnfollowAction;

  /// No description provided for @publicProfileFollowSuccess.
  String get publicProfileFollowSuccess;

  /// No description provided for @publicProfileUnfollowSuccess.
  String get publicProfileUnfollowSuccess;

  /// No description provided for @publicProfileFollowError.
  String get publicProfileFollowError;

  /// No description provided for @publicProfileFollowRetry.
  String get publicProfileFollowRetry;

  /// No description provided for @contentLanguageFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Content language'**
  String get contentLanguageFieldLabel;

  /// No description provided for @contentLanguageFieldHelper.
  ///
  /// In en, this message translates to:
  /// **'Select the language in which you wrote the content.'**
  String get contentLanguageFieldHelper;

  /// No description provided for @contentLanguageUndetermined.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get contentLanguageUndetermined;

  /// No description provided for @createPollAdvancedOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced options'**
  String get createPollAdvancedOptionsTitle;

  /// No description provided for @createPollAdvancedOptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Anonymity, results visibility, vote changes, and quorum.'**
  String get createPollAdvancedOptionsSubtitle;

  /// No description provided for @onboardingSkipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkipButton;

  /// No description provided for @onboardingNextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNextButton;

  /// No description provided for @onboardingStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingStartButton;

  /// No description provided for @onboardingPollTitle.
  ///
  /// In en, this message translates to:
  /// **'Polls'**
  String get onboardingPollTitle;

  /// No description provided for @onboardingPollDescription.
  ///
  /// In en, this message translates to:
  /// **'Vote on topics you care about and create polls to collect the community\'s opinion.'**
  String get onboardingPollDescription;

  /// No description provided for @onboardingHeatIceTitle.
  ///
  /// In en, this message translates to:
  /// **'Heat and Ice'**
  String get onboardingHeatIceTitle;

  /// No description provided for @onboardingHeatIceDescription.
  ///
  /// In en, this message translates to:
  /// **'Use Heat and Ice to show how strongly a piece of content is attracting your interest.'**
  String get onboardingHeatIceDescription;

  /// No description provided for @onboardingCivicMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Civic Map'**
  String get onboardingCivicMapTitle;

  /// No description provided for @onboardingCivicMapDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore polls, posts, and news on the map and discover what is happening across different areas.'**
  String get onboardingCivicMapDescription;

  /// No description provided for @onboardingGeoScopeTitle.
  ///
  /// In en, this message translates to:
  /// **'GeoScope'**
  String get onboardingGeoScopeTitle;

  /// No description provided for @onboardingGeoScopeDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the geographic level you want to follow: world, country, or city.'**
  String get onboardingGeoScopeDescription;

  /// No description provided for @onboardingVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity verification'**
  String get onboardingVerificationTitle;

  /// No description provided for @onboardingVerificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Some Polls may require a verification level to protect voting integrity.'**
  String get onboardingVerificationDescription;

  /// No description provided for @pollDetail_voteReceiptButton.
  ///
  /// In en, this message translates to:
  /// **'Vote receipt'**
  String get pollDetail_voteReceiptButton;

  /// No description provided for @pollDetail_voteReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Vote receipt'**
  String get pollDetail_voteReceiptTitle;

  /// No description provided for @pollDetail_voteReceiptIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Receipt ID'**
  String get pollDetail_voteReceiptIdLabel;

  /// No description provided for @pollDetail_voteReceiptDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get pollDetail_voteReceiptDateLabel;

  /// No description provided for @pollDetail_voteReceiptPrivacy.
  ///
  /// In en, this message translates to:
  /// **'This receipt confirms that your vote was recorded without showing the choice you made.'**
  String get pollDetail_voteReceiptPrivacy;

  /// No description provided for @pollDetail_voteReceiptCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get pollDetail_voteReceiptCloseButton;

  /// No description provided for @profileBiometricUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock'**
  String get profileBiometricUnlockTitle;

  /// No description provided for @profileBiometricUnlockDescription.
  ///
  /// In en, this message translates to:
  /// **'Protects your remembered session with the device fingerprint or biometric recognition.'**
  String get profileBiometricUnlockDescription;

  /// No description provided for @profileBiometricRequiresRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Requires Remember Me to be enabled.'**
  String get profileBiometricRequiresRememberMe;

  /// No description provided for @profileBiometricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometrics are unavailable or not configured on this device.'**
  String get profileBiometricUnavailable;

  /// No description provided for @profileBiometricEnableReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm your biometrics to enable Social Vote unlock.'**
  String get profileBiometricEnableReason;

  /// No description provided for @profileBiometricEnabledMessage.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock enabled.'**
  String get profileBiometricEnabledMessage;

  /// No description provided for @profileBiometricDisabledMessage.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock disabled.'**
  String get profileBiometricDisabledMessage;

  /// No description provided for @profileBiometricAuthFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication was not completed.'**
  String get profileBiometricAuthFailedMessage;

  /// No description provided for @biometricLockTitle.
  ///
  /// In en, this message translates to:
  /// **'Social Vote is locked'**
  String get biometricLockTitle;

  /// No description provided for @biometricLockMessage.
  ///
  /// In en, this message translates to:
  /// **'Use your device biometrics to unlock the remembered session.'**
  String get biometricLockMessage;

  /// No description provided for @biometricUnlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get biometricUnlockButton;

  /// No description provided for @biometricUsePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Use password'**
  String get biometricUsePasswordButton;

  /// No description provided for @biometricUnlockReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock your Social Vote session.'**
  String get biometricUnlockReason;

  /// No description provided for @biometricUnlockFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Unlock failed. Try again or use your password.'**
  String get biometricUnlockFailedMessage;

  /// No description provided for @adminCenterOperationalActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Operational activity'**
  String get adminCenterOperationalActivityTitle;

  /// No description provided for @adminCenterOperationalActivitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Aggregate counters. No real-time online presence tracking.'**
  String get adminCenterOperationalActivitySubtitle;

  /// No description provided for @adminCenterLast24HoursLabel.
  ///
  /// In en, this message translates to:
  /// **'24 hours'**
  String get adminCenterLast24HoursLabel;

  /// No description provided for @adminCenterLast7DaysLabel.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get adminCenterLast7DaysLabel;

  /// No description provided for @adminCenterNewUsersMetric.
  ///
  /// In en, this message translates to:
  /// **'New registrations'**
  String get adminCenterNewUsersMetric;

  /// No description provided for @adminCenterRecentSignInsMetric.
  ///
  /// In en, this message translates to:
  /// **'Recent sign-ins'**
  String get adminCenterRecentSignInsMetric;

  /// No description provided for @adminCenterPollsCreatedMetric.
  ///
  /// In en, this message translates to:
  /// **'Polls created'**
  String get adminCenterPollsCreatedMetric;

  /// No description provided for @adminCenterPostsCreatedMetric.
  ///
  /// In en, this message translates to:
  /// **'Posts created'**
  String get adminCenterPostsCreatedMetric;

  /// No description provided for @adminCenterAdminActionsMetric.
  ///
  /// In en, this message translates to:
  /// **'Admin actions'**
  String get adminCenterAdminActionsMetric;

  /// Auth UI: explains public name and automatic username generation
  ///
  /// In en, this message translates to:
  /// **'This is the name other users will see. Your username is created automatically.'**
  String get authPublicNameHelper;
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
