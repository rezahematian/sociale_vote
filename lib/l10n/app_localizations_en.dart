// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sociale Vote';

  @override
  String get voteButton => 'Vote';

  @override
  String get createPollPageTitle => 'Create Poll';

  @override
  String get createPollPageSubtitle => 'Define a new civic vote';

  @override
  String get createPollBasicInfoTitle => 'Basic information';

  @override
  String get createPollBasicInfoSubtitle => 'Define the main details of the poll.';

  @override
  String get createPollTitleFieldLabel => 'Title *';

  @override
  String get createPollTitleFieldHelper => 'A clear, concise question or statement.';

  @override
  String get createPollDescriptionFieldLabel => 'Description (optional)';

  @override
  String get createPollVotingModelTitle => 'Voting model';

  @override
  String get createPollVotingModelSubtitle => 'Choose how people will express their vote and basic rules.';

  @override
  String get createPollTypeFieldLabel => 'Poll type';

  @override
  String createPollSelectionRules(int min, int max) {
    return 'Selection rules: minimum $min, maximum $max selections (automatically adjusted based on poll type and options).';
  }

  @override
  String get createPollAllowVoteChangeTitle => 'Allow voters to change their vote';

  @override
  String get createPollAllowVoteChangeSubtitle => 'Until the poll is closed.';

  @override
  String get createPollOptionsTitle => 'Options';

  @override
  String get createPollOptionsSubtitle => 'Add at least two options for voters to choose from. Fields marked with * are mandatory.';

  @override
  String createPollOptionLabel(int index, Object requiredMarker) {
    return 'Option $index$requiredMarker';
  }

  @override
  String get createPollRemoveOptionTooltip => 'Remove option';

  @override
  String get createPollAddOptionButton => 'Add option';

  @override
  String get createPollParticipationPrivacyTitle => 'Participation & privacy';

  @override
  String get createPollParticipationPrivacySubtitle => 'Decide who can vote and how private the votes should be.';

  @override
  String get createPollWhoCanVoteLabel => 'Who can vote?';

  @override
  String get createPollParticipationEveryoneSubtitle => 'Any registered user can participate.';

  @override
  String get createPollParticipationGeoScopeSubtitle => 'Limit this poll to people from a specific country.';

  @override
  String get createPollCountryFieldLabel => 'Country for this poll';

  @override
  String get createPollCountryFieldHelper => 'This country will define who is allowed to participate in this poll (future backend integration).';

  @override
  String get createPollVoteAnonymityTitle => 'Vote anonymity';

  @override
  String get createPollAnonymityAnonymousSubtitle => 'Recommended default for civic voting platforms.';

  @override
  String get createPollAnonymityPublicSubtitle => 'Use with caution: votes may be associated with identities (future feature).';

  @override
  String get createPollResultsValidityTitle => 'Results & validity';

  @override
  String get createPollResultsValiditySubtitle => 'Control when results are visible and define minimum quorum if needed.';

  @override
  String get createPollResultsVisibilityFieldLabel => 'Results visibility';

  @override
  String get createPollQuorumTitle => 'Quorum (optional)';

  @override
  String get createPollQuorumSubtitle => 'If set, the poll is considered valid only if at least this number of votes is reached. Leave empty for no quorum.';

  @override
  String get createPollQuorumMinVotesFieldLabel => 'Minimum number of votes';

  @override
  String get createPollTimingTitle => 'Timing';

  @override
  String get createPollTimingSubtitle => 'Define when the poll should be open for voting.';

  @override
  String get createPollStartDateLabel => 'Start date';

  @override
  String get createPollEndDateLabel => 'End date';

  @override
  String get createPollChangeDateButtonLabel => 'Change';

  @override
  String get createPollTimingStatusInfo => 'The initial status (open/scheduled/closed) will be determined automatically based on these dates.';

  @override
  String get createPollSuccessMessage => 'Poll created successfully';

  @override
  String get createPollSubmitCreatingLabel => 'Creating...';

  @override
  String get createPollSubmitLabel => 'Create poll';

  @override
  String get createPollPollTypeYesNoLabel => 'Yes / No';

  @override
  String get createPollPollTypeSingleChoiceLabel => 'Single choice';

  @override
  String get createPollPollTypeMultipleChoiceLabel => 'Multiple choice';

  @override
  String get createPollPollTypeApprovalLabel => 'Approval voting';

  @override
  String get createPollPollTypeRankedLabel => 'Ranked choice';

  @override
  String get createPollPollTypeScoreLabel => 'Score / Rating';

  @override
  String get createPollParticipationScopeEveryoneLabel => 'Everyone can vote';

  @override
  String get createPollParticipationScopeGeoScopeOnlyLabel => 'Only users in a specific country';

  @override
  String get createPollAnonymityLevelAnonymousLabel => 'Votes are anonymous';

  @override
  String get createPollAnonymityLevelPublicLabel => 'Votes are public (advanced / restricted use)';

  @override
  String get createPollResultsVisibilityAlwaysLabel => 'Always visible (while poll is open)';

  @override
  String get createPollResultsVisibilityAfterVoteLabel => 'Only visible after voting';

  @override
  String get createPollResultsVisibilityAfterCloseLabel => 'Only visible after poll is closed';

  @override
  String get homeLoginButton => 'Log in';

  @override
  String get homeRegisterButton => 'Sign up';

  @override
  String get homeProfileButton => 'Profile';

  @override
  String get homeLogoutButton => 'Logout';

  @override
  String get homeLogoutMessage => 'Logout completed. You are now using the app as a guest (read-only).';

  @override
  String get homeSearchHint => 'Search city, country, polls, news, posts...';

  @override
  String get searchPageTitle => 'Search';

  @override
  String get searchInputHint => 'Search polls, news, posts...';

  @override
  String get searchClearTooltip => 'Clear search';

  @override
  String get searchTypeAll => 'All';

  @override
  String get searchTypePolls => 'Polls';

  @override
  String get searchTypeNews => 'News';

  @override
  String get searchTypePosts => 'Posts';

  @override
  String get searchSortHottest => 'Hottest';

  @override
  String get searchSortLatest => 'Latest';

  @override
  String get searchPollStatusAll => 'All polls';

  @override
  String get searchPollStatusOpen => 'Open';

  @override
  String get searchPollStatusClosed => 'Closed';

  @override
  String get searchIdleMessage => 'Enter a term to start searching.';

  @override
  String get searchErrorMessage => 'Something went wrong while searching.';

  @override
  String get searchRetryButton => 'Try again';

  @override
  String get searchEmptyMessage => 'No results found for this search.';

  @override
  String get searchContentUnavailable => 'Content unavailable';

  @override
  String get searchResultTypePoll => 'Poll';

  @override
  String get searchResultTypeNews => 'News';

  @override
  String get searchResultTypePost => 'Post';

  @override
  String get searchResultTypeMixed => 'Mixed';

  @override
  String homeUserStatusLoggedIn(Object userId) {
    return 'Logged in as: $userId';
  }

  @override
  String get homeUserStatusGuest => 'Guest mode: you can only read. Log in or register to vote, comment and react.';

  @override
  String get homeScopeLabelWorld => 'World – Global votes and news';

  @override
  String get homeScopeLabelCountry => 'Country – National votes and news';

  @override
  String get homeScopeLabelCity => 'City – Local city votes and news';

  @override
  String get homeScopeShortWorld => 'World';

  @override
  String get homeScopeShortCountry => 'Country';

  @override
  String get homeScopeShortCity => 'City';

  @override
  String get homeScopeChipWorld => 'World';

  @override
  String get homeScopeChipItaly => 'Italy';

  @override
  String get homeScopeChipTorino => 'Torino';

  @override
  String get homeScopeChangedWorld => 'Scope changed to World';

  @override
  String get homeScopeChangedItaly => 'Scope changed to Italy';

  @override
  String get homeScopeChangedTorino => 'Scope changed to Torino';

  @override
  String get followScopeButtonFollowed => 'Following';

  @override
  String get followScopeButtonFollow => 'Follow this area';

  @override
  String get homeTrendingTitle => 'Trending now';

  @override
  String get homeTrendingError => 'Unable to load trending content for this area.';

  @override
  String get homeTrendingEmpty => 'No trending content for this scope at the moment.';

  @override
  String homeForYouTitle(Object scope) {
    return 'For You ($scope)';
  }

  @override
  String get homeForYouError => 'Unable to load the \"For You\" feed for this area.';

  @override
  String get homeForYouEmpty => 'No suggested \"For You\" content for this scope at the moment.';

  @override
  String homePollsTitle(Object scope) {
    return 'Highlighted Polls ($scope)';
  }

  @override
  String get homePollsEmptyTitle => 'No polls for this area';

  @override
  String get homePollsEmptySubtitle => 'There are no polls for this scope.';

  @override
  String get homePollsViewAllButton => 'View all polls';

  @override
  String homeNewsTitle(Object scope) {
    return 'Top News ($scope)';
  }

  @override
  String get homeNewsErrorTitle => 'Unable to load news';

  @override
  String get homeNewsErrorSubtitle => 'There was a problem loading the news for this area.';

  @override
  String get homeNewsEmptyTitle => 'No news for this area';

  @override
  String get homeNewsEmptySubtitle => 'There are no news items for this scope at the moment.';

  @override
  String get homeNewsViewAllButton => 'View all news';

  @override
  String get homeNewsBreakingBadge => 'BREAKING';

  @override
  String homeSocialTitle(Object scope) {
    return 'Discussions / Feed ($scope)';
  }

  @override
  String get homeSocialErrorTitle => 'Unable to load discussions';

  @override
  String get homeSocialErrorSubtitle => 'There was a problem loading the social feed for this area.';

  @override
  String get homeSocialEmptyTitle => 'No discussions for this area';

  @override
  String get homeSocialEmptySubtitle => 'There are no discussions for this scope at the moment.';

  @override
  String get homeSocialViewFeedButton => 'View social feed';

  @override
  String get pollDetail_title => 'Poll detail';

  @override
  String get pollDetail_removeFromFavoritesTooltip => 'Remove from favorites';

  @override
  String get pollDetail_addToFavoritesTooltip => 'Add to favorites';

  @override
  String get pollDetail_chipAnonymous => 'Anonymous vote';

  @override
  String get pollDetail_chipPublic => 'Public vote';

  @override
  String get pollDetail_chipRestrictedGeo => 'Restricted to geographic scope';

  @override
  String pollDetail_quorumReached(int currentVotes, int requiredVotes) {
    return 'Quorum reached ($currentVotes / $requiredVotes)';
  }

  @override
  String pollDetail_quorumNotReached(int currentVotes, int requiredVotes) {
    return 'Quorum not reached ($currentVotes / $requiredVotes)';
  }

  @override
  String get pollDetail_optionsTitle => 'Options';

  @override
  String get pollDetail_statusClosedMessage => 'This poll is closed.';

  @override
  String get pollDetail_statusScheduledMessage => 'This poll is not yet open.';

  @override
  String get pollDetail_statusNotAvailableMessage => 'Voting is not available.';

  @override
  String get pollDetail_voteSubmitted => 'Vote submitted successfully!';

  @override
  String get pollDetail_voteButton => 'Vote';

  @override
  String get pollDetail_resultsTitle => 'Results';

  @override
  String pollDetail_outcomePrefix(Object label) {
    return 'Outcome: $label';
  }

  @override
  String get pollDetail_noResults => 'No results available yet.';

  @override
  String get pollDetail_resultsAfterVote => 'Results will be visible after you vote.';

  @override
  String get pollDetail_resultsWhenClosed => 'Results will be visible when the poll is closed.';

  @override
  String get pollType_yesNo => 'Yes / No';

  @override
  String get pollType_singleChoice => 'Single choice';

  @override
  String get pollType_multipleChoice => 'Multiple choice';

  @override
  String get pollType_approval => 'Approval';

  @override
  String get pollStatus_draft => 'Draft';

  @override
  String get pollStatus_open => 'Open';

  @override
  String get pollStatus_closed => 'Closed';

  @override
  String get pollStatus_scheduled => 'Scheduled';

  @override
  String get pollGeo_global => 'Global';

  @override
  String get pollGeo_local => 'Local';

  @override
  String get pollOutcome_approved => 'Approved';

  @override
  String get pollOutcome_rejected => 'Rejected';

  @override
  String get pollOutcome_tie => 'Tie';

  @override
  String get pollOutcome_noMajority => 'No majority';

  @override
  String get pollOutcome_notApplicable => 'Not applicable';

  @override
  String get pollList_title => 'Polls';

  @override
  String get pollList_scopeWorld => 'World';

  @override
  String get pollList_scopeCountryFallback => 'Country';

  @override
  String get pollList_scopeCityFallback => 'City';

  @override
  String get pollList_scopeDescriptionGlobal => 'Showing global polls.';

  @override
  String get pollList_scopeDescriptionCountry => 'Showing polls for this country.';

  @override
  String get pollList_scopeDescriptionCity => 'Showing polls for this city.';

  @override
  String get pollList_filterStatus_all => 'All';

  @override
  String get pollList_filterStatus_open => 'Open';

  @override
  String get pollList_filterStatus_closed => 'Closed';

  @override
  String get pollList_sort_latest => 'Latest';

  @override
  String get pollList_sort_hottest => 'Hottest';

  @override
  String get pollList_filterScope_currentArea => 'Current area';

  @override
  String pollList_headerTitle(Object scopeLabel, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count polls found',
      one: '1 poll found',
      zero: 'no polls found',
    );
    return '$scopeLabel · $_temp0';
  }

  @override
  String get pollList_createPollButton => 'Create poll';

  @override
  String get pollList_paginationHint => 'Scroll to load more polls…';

  @override
  String get pollList_emptyMessage => 'No polls matching this filter for this area.';

  @override
  String get pollType_ranked => 'Ranked choice';

  @override
  String get pollType_score => 'Score voting';

  @override
  String get pollVisibility_whileOpen => 'Results visible while open';

  @override
  String get pollVisibility_afterVote => 'Results visible after vote';

  @override
  String get pollVisibility_afterClose => 'Results visible after close';

  @override
  String get pollCard_countryRestricted => 'Country restricted';

  @override
  String pollCard_restrictedToCountry(Object countryName) {
    return 'Restricted to $countryName';
  }

  @override
  String pollCard_quorumLabel(int minVotes) {
    return 'Quorum $minVotes';
  }

  @override
  String get pollCard_resultsVisibleChip => 'Results visible';

  @override
  String get pollCard_resultsAfterVoteChip => 'After vote';

  @override
  String get pollCard_resultsAfterCloseChip => 'After close';

  @override
  String get pollCard_publicOfficialPublisher => 'Public Official';

  @override
  String get pollCard_institutionPublisher => 'Institution';

  @override
  String get pollCard_representativePublisher => 'Representative';

  @override
  String pollCard_voteCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'votes',
      one: 'vote',
    );
    return '$_temp0';
  }

  @override
  String get pollCard_viewDetails => 'View details';

  @override
  String pollResult_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Results ($count votes)',
      one: 'Results (1 vote)',
      zero: 'Results (no votes)',
    );
    return '$_temp0';
  }

  @override
  String get voteError_noSelection => 'Please select at least one option.';

  @override
  String get voteError_unauthorized => 'You are not allowed to vote in this poll.';

  @override
  String get voteError_generic => 'Failed to submit vote. Please try again.';

  @override
  String get commentSection_title => 'Comments';

  @override
  String get commentSection_sortLabel => 'Sort:';

  @override
  String get commentSection_sortOldest => 'Oldest';

  @override
  String get commentSection_sortNewest => 'Newest';

  @override
  String get commentSection_errorGeneric => 'An error occurred while loading comments.';

  @override
  String get commentSection_empty => 'No comments yet. Be the first to comment.';

  @override
  String get commentSection_loadMore => 'Load more comments';

  @override
  String commentSection_replyingTo(Object snippet) {
    return 'Replying to: $snippet';
  }

  @override
  String get commentSection_cancelReply => 'Cancel';

  @override
  String get commentSection_inputHintRoot => 'Add a comment...';

  @override
  String get commentSection_inputHintReply => 'Write a reply...';

  @override
  String get commentSection_deleteAction => 'Delete';

  @override
  String get commentSection_replyAction => 'Reply';

  @override
  String get commentSection_youBadge => 'You';

  @override
  String get newsDetail_title => 'News detail';

  @override
  String get newsDetail_breakingBadge => 'BREAKING';

  @override
  String get newsDetail_removeFromFavoritesTooltip => 'Remove from favorites';

  @override
  String get newsDetail_addToFavoritesTooltip => 'Add to favorites';

  @override
  String get newsDetail_bodyFallback => 'No additional text is available for this news item.';

  @override
  String get newsDetail_footerMoreContext => 'More context and sources coming soon.';

  @override
  String get newsFeed_title => 'News';

  @override
  String get newsFeed_scopeWorld => 'World';

  @override
  String get newsFeed_scopeCountry => 'Country';

  @override
  String get newsFeed_scopeCity => 'City';

  @override
  String newsFeed_scopeLabel(Object scope) {
    return 'Scope: $scope';
  }

  @override
  String get newsFeed_scopeGlobalDescription => 'Showing global news.';

  @override
  String get newsFeed_scopeCountryDescription => 'Showing news for this country.';

  @override
  String get newsFeed_scopeCityDescription => 'Showing news for this city.';

  @override
  String get newsFeed_emptyTitle => 'No news available for this area.';

  @override
  String get newsFeed_emptySubtitle => 'Pull to refresh or try again later.';

  @override
  String newsFeed_itemsFound(int count) {
    return '$count news item(s) found';
  }

  @override
  String get newsFeed_loadingMoreHint => 'Scroll to load more news…';

  @override
  String get newsFeed_errorTitle => 'Unable to load news';

  @override
  String get newsFeed_errorGeneric => 'An unexpected error occurred while loading news.';

  @override
  String get newsFeed_retryButton => 'Retry';

  @override
  String get newsCard_headerTitle => 'News';

  @override
  String get newsFeed_errorUnauthorized => 'News configuration is invalid (API key).';

  @override
  String get newsFeed_errorRateLimited => 'Too many requests. Please try again shortly.';

  @override
  String get newsFeed_errorServerUnavailable => 'News service is temporarily unavailable. Please try again later.';

  @override
  String get newsFeed_errorTimeout => 'The request is taking too long. Please try again.';

  @override
  String get newsFeed_errorNetwork => 'No connection. Check your internet and try again.';

  @override
  String get newsFeed_moreTooltip => 'More';

  @override
  String get newsFeed_actionCopyTitle => 'Copy title';

  @override
  String get newsFeed_actionRefreshFeed => 'Refresh feed';

  @override
  String get newsFeed_copiedTitleToast => 'Title copied';

  @override
  String get newsFeed_languageTooltip => 'News language';

  @override
  String get newsFeed_languageAuto => 'AUTO';

  @override
  String get newsFeed_languageIt => 'IT';

  @override
  String get newsFeed_languageEn => 'EN';

  @override
  String get newsFeed_languageEs => 'ES';

  @override
  String get newsFeed_languageFr => 'FR';

  @override
  String get newsFeed_languageDe => 'DE';

  @override
  String get newsFeed_languageAr => 'AR';

  @override
  String get newsFeed_languageFa => 'FA';

  @override
  String get newsFeed_languageLimitedHint => 'Limited sources in this language. Try AUTO.';

  @override
  String get newsTopic_all => 'All';

  @override
  String get newsTopic_world => 'World';

  @override
  String get newsTopic_nation => 'Nation';

  @override
  String get newsTopic_business => 'Business';

  @override
  String get newsTopic_technology => 'Technology';

  @override
  String get newsTopic_science => 'Science';

  @override
  String get newsTopic_health => 'Health';

  @override
  String get newsTopic_sports => 'Sports';

  @override
  String get newsTopic_entertainment => 'Entertainment';

  @override
  String get newsDetail_openSource => 'Open source article';

  @override
  String get newsDetail_openSourceUnavailable => 'Unable to open the source article';

  @override
  String get socialFeedTitle => 'Social Feed';

  @override
  String get socialFeedCreatePostButton => 'Create post';

  @override
  String get commonCancelButton => 'Cancel';

  @override
  String get commonApplyButton => 'Apply';

  @override
  String get homeScopeChooseCountry => 'Choose country';

  @override
  String get homeScopeCountrySearchHint => 'Search country or code...';

  @override
  String get homeScopeChooseCity => 'Choose city';

  @override
  String homeScopeCountryWithCode(String code) {
    return 'Country: $code';
  }

  @override
  String get homeScopeCityFieldLabel => 'City';

  @override
  String get homeScopeCityExampleHint => 'E.g. Rome, São Paulo, Tehran';

  @override
  String get homeScopeCityRequiredError => 'Enter a city.';

  @override
  String get homeScopeCityNotFoundError => 'City not found in the selected country.';

  @override
  String get homeScopeCityVerificationError => 'Unable to verify the city. Try again.';

  @override
  String get homeScopeVerifyingButton => 'Verifying...';

  @override
  String get homeMapOpenButton => 'Open map';

  @override
  String get homeHeroHeadline => 'Shape the future.\nTogether.';

  @override
  String get homeAccountMenuLabel => 'Account';

  @override
  String get homeThemeSystemMenuItem => 'Theme: system';

  @override
  String get homeThemeLightMenuItem => 'Theme: light';

  @override
  String get homeThemeDarkMenuItem => 'Theme: dark';

  @override
  String get homeNotificationsTooltip => 'Notifications';

  @override
  String get postCard_authorFallback => 'Author';

  @override
  String get postCard_globalLocation => 'Global';

  @override
  String get commonSaveButton => 'Save';

  @override
  String get commonDeleteButton => 'Delete';

  @override
  String get contentReport_menuAction => 'Report content';

  @override
  String get contentReport_dialogTitle => 'Report content';

  @override
  String get contentReport_authenticationRequired => 'You must be signed in to report content';

  @override
  String get contentReport_submittedMessage => 'Report submitted';

  @override
  String get contentReport_alreadySubmittedMessage => 'You have already reported this content';

  @override
  String get contentReport_submitError => 'Unable to submit the report';

  @override
  String get contentReport_sendButton => 'Submit';

  @override
  String get contentReport_reasonSpam => 'Spam';

  @override
  String get contentReport_reasonHarassment => 'Harassment or abuse';

  @override
  String get contentReport_reasonHateSpeech => 'Hate speech';

  @override
  String get contentReport_reasonMisinformation => 'Misinformation';

  @override
  String get contentReport_reasonViolence => 'Violence';

  @override
  String get contentReport_reasonOther => 'Other';

  @override
  String get postDetail_title => 'Post detail';

  @override
  String get postDetail_favoriteUpdateError => 'Unable to update favorites';

  @override
  String get postDetail_shareMessage => 'Open Sociale_Vote to view this post.';

  @override
  String get postDetail_shareError => 'Unable to share the post';

  @override
  String get postDetail_editDialogTitle => 'Edit post';

  @override
  String get postDetail_editTitleFieldLabel => 'Title';

  @override
  String get postDetail_editContentFieldLabel => 'Content';

  @override
  String get postDetail_editRequiredError => 'Title and content are required.';

  @override
  String get postDetail_updateSuccess => 'Post updated';

  @override
  String get postDetail_updateError => 'Unable to update the post';

  @override
  String get postDetail_deleteDialogTitle => 'Delete this post?';

  @override
  String get postDetail_deleteDialogMessage => 'This action cannot be undone.';

  @override
  String get postDetail_deleteError => 'Unable to delete the post';

  @override
  String get postDetail_editMenuItem => 'Edit post';

  @override
  String get postDetail_deleteMenuItem => 'Delete post';

  @override
  String get postDetail_loadError => 'An error occurred while loading the post.';

  @override
  String get postDetail_notFound => 'Post not found.';

  @override
  String get postDetail_errorTitle => 'Error';

  @override
  String get postDetail_authorFallback => 'Author';

  @override
  String get postDetail_shareAction => 'Share';

  @override
  String get postDetail_saveAction => 'Save';

  @override
  String get postDetail_addToFavoritesTooltip => 'Add to favorites';

  @override
  String get postDetail_removeFromFavoritesTooltip => 'Remove from favorites';

  @override
  String get newsDetail_favoriteUpdateError => 'Unable to update favorites';

  @override
  String get newsDetail_shareMessage => 'Open Sociale_Vote to view this news item.';

  @override
  String get newsDetail_shareError => 'Unable to share the news item';

  @override
  String get newsDetail_shareTooltip => 'Share';

  @override
  String get authLoginPageTitle => 'Log in';

  @override
  String get authLoginHeadline => 'Welcome back';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authRememberMeLabel => 'Remember me';

  @override
  String get authForgotPasswordAction => 'Forgot password?';

  @override
  String get authLoginButton => 'Log in';

  @override
  String get authRegisterPrompt => 'Don\'t have an account?';

  @override
  String get authRegisterAction => 'Sign up';

  @override
  String get authRegisterPageTitle => 'Sign up';

  @override
  String get authRegisterHeadline => 'Create an account';

  @override
  String get authDisplayNameLabel => 'Display name';

  @override
  String get authUsernameLabel => 'Username';

  @override
  String get authCountryOfResidenceLabel => 'Country of residence';

  @override
  String get authCityOfResidenceLabel => 'City of residence';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authLegalConsentPrefix => 'I have read and accept';

  @override
  String get authTermsOfServiceAction => 'the Terms of Service';

  @override
  String get authPrivacyPolicyAction => 'the Privacy Policy';

  @override
  String get authRegisterButton => 'Sign up';

  @override
  String get authLoginPrompt => 'Already have an account?';

  @override
  String get authLoginAction => 'Log in';

  @override
  String get authForgotPasswordDialogTitle => 'Reset password';

  @override
  String get authForgotPasswordDialogBody => 'Enter the email address linked to your account. We will send you a link to choose a new password.';

  @override
  String get authForgotPasswordSendButton => 'Send link';

  @override
  String get authPasswordResetEmailSent => 'Password reset email sent. Check your inbox.';

  @override
  String get authResetPasswordPageTitle => 'Reset password';

  @override
  String get authResetPasswordHeadline => 'Choose a new password';

  @override
  String get authNewPasswordLabel => 'New password';

  @override
  String get authConfirmNewPasswordLabel => 'Confirm new password';

  @override
  String get authUpdatePasswordButton => 'Update password';

  @override
  String get authPasswordUpdated => 'Password updated successfully.';

  @override
  String get authEmailConfirmationTitle => 'Check your email';

  @override
  String get authEmailConfirmationIntro => 'We sent a confirmation link to:';

  @override
  String get authEmailConfirmationInstructions => 'Open the link in the message to verify your address. After confirmation, return to the app and log in.';

  @override
  String get authBackToLoginButton => 'Back to login';

  @override
  String get authUseAnotherEmailButton => 'Use another email address';

  @override
  String get authEmailRequiredError => 'Enter your email.';

  @override
  String get authEmailInvalidError => 'Enter a valid email address.';

  @override
  String get authPasswordRequiredError => 'Enter your password.';

  @override
  String get authPasswordTooShortError => 'Password must be at least 8 characters.';

  @override
  String get authDisplayNameRequiredError => 'Enter your display name.';

  @override
  String get authDisplayNameTooShortError => 'Display name is too short.';

  @override
  String get authUsernameRequiredError => 'Enter a username.';

  @override
  String get authUsernameInvalidError => 'Use 3 to 20 characters: lowercase letters, numbers and underscores.';

  @override
  String get authCountryRequiredError => 'Select your country of residence.';

  @override
  String get authCityRequiredError => 'Enter your city of residence.';

  @override
  String get authConfirmPasswordRequiredError => 'Confirm your password.';

  @override
  String get authPasswordsDoNotMatchError => 'Passwords do not match.';

  @override
  String get authLegalConsentRequiredError => 'You must read and accept the Terms of Service and Privacy Policy.';

  @override
  String get authForgotPasswordEmailRequiredError => 'Enter the email for the account you want to recover.';

  @override
  String get authInvalidCredentialsError => 'Email or password is not valid.';

  @override
  String get authEmailAlreadyRegisteredError => 'This email is already registered.';

  @override
  String get authEmailNotConfirmedError => 'Email not confirmed. Check your inbox before logging in.';

  @override
  String get authTooManyAttemptsError => 'Too many attempts. Wait a few minutes and try again.';

  @override
  String get authNetworkError => 'Network error. Check your connection and try again.';

  @override
  String get authLoginGenericError => 'Login failed. Try again.';

  @override
  String get authRegisterGenericError => 'Registration failed. Try again.';

  @override
  String get authPasswordResetGenericError => 'Unable to send the reset link. Try again.';

  @override
  String get authPasswordUpdateGenericError => 'Unable to update the password. Try again.';

  @override
  String get authShowPasswordTooltip => 'Show password';

  @override
  String get authHidePasswordTooltip => 'Hide password';

  @override
  String get authTermsPageTitle => 'Terms of Service';

  @override
  String get authPrivacyPageTitle => 'Privacy Policy';

  @override
  String get authCloseButton => 'Close';

  @override
  String get pollDetail_favoriteUpdateError => 'Unable to update favorites';

  @override
  String get pollDetail_shareMessage => 'Open Sociale_Vote to view and vote in this poll.';

  @override
  String get pollDetail_shareError => 'Unable to share the poll';

  @override
  String get pollDetail_editPermissionError => 'You can edit only your own polls that have no votes';

  @override
  String get pollDetail_editSuccessMessage => 'Poll updated';

  @override
  String get pollDetail_editMenuItem => 'Edit poll';

  @override
  String get pollDetail_editSavingMenuItem => 'Saving...';

  @override
  String get pollDetail_deletePermissionError => 'You can delete only your own polls';

  @override
  String get pollDetail_deleteError => 'Unable to delete the poll';

  @override
  String get pollDetail_deleteDialogTitle => 'Delete poll';

  @override
  String pollDetail_deleteDialogMessage(String title) {
    return 'Do you really want to delete \"$title\"? This action cannot be undone.';
  }

  @override
  String get pollDetail_deleteMenuItem => 'Delete poll';

  @override
  String get pollDetail_deleteDeletingMenuItem => 'Deleting...';

  @override
  String get pollDetail_publicVotesAvailableTitle => 'Public votes available';

  @override
  String get pollDetail_publicVotesAvailableMessage => 'This poll allows you to see who voted for each option.';

  @override
  String get pollDetail_publicVotesAction => 'View public votes';

  @override
  String get pollDetail_retryButton => 'Try again';

  @override
  String get pollDetail_voteErrorNoOption => 'Select at least one option';

  @override
  String get pollDetail_voteErrorAuthenticationRequired => 'You must be signed in to vote';

  @override
  String get pollDetail_voteErrorClosed => 'This poll is closed';

  @override
  String get pollDetail_voteErrorAlreadyVoted => 'You have already voted in this poll';

  @override
  String get pollDetail_voteErrorGeneric => 'Unable to submit the vote';

  @override
  String get pollDetail_publicVotesSheetTitle => 'Public votes';

  @override
  String get pollDetail_publicVotesSheetDescription => 'Here you can see who voted for each option in this poll.';

  @override
  String get pollDetail_publicVotesSearchHint => 'Search users';

  @override
  String get pollDetail_publicVotesLoadError => 'Unable to load public votes';

  @override
  String get pollDetail_publicVotesEmpty => 'No public votes available';

  @override
  String get pollDetail_publicVotesSearchEmpty => 'No users found for this search';

  @override
  String pollDetail_publicVotesResultsCount(int count) {
    return '$count results loaded';
  }

  @override
  String get pollDetail_publicVotesLoadMore => 'Load more';

  @override
  String get pollDetail_publicVotesUserFallback => 'User';

  @override
  String get pollDetail_editDialogTitle => 'Edit poll';

  @override
  String get pollDetail_editTitleFieldLabel => 'Title';

  @override
  String get pollDetail_editTitleRequired => 'Title is required';

  @override
  String get pollDetail_editDescriptionFieldLabel => 'Description';

  @override
  String get pollDetail_editError => 'Unable to update the poll';

  @override
  String get pollDetail_loadError => 'Unable to load the poll';

  @override
  String get pollDetail_notFound => 'Poll not found';

  @override
  String get profileEditPageTitle => 'Edit profile';

  @override
  String get profileLoginRequiredMessage => 'You must be signed in to edit your profile.';

  @override
  String get profileAvatarUploading => 'Uploading...';

  @override
  String get profileUploadAvatarButton => 'Upload avatar';

  @override
  String get profileDisplayNameLabel => 'Display name';

  @override
  String get profileDisplayNameRequiredError => 'Display name is required.';

  @override
  String get profileUsernameHint => 'e.g. mario_roma';

  @override
  String get profileUsernameHelper => '3–20 characters: lowercase letters, numbers and underscores';

  @override
  String get profileAvatarUrlLabel => 'Avatar URL';

  @override
  String get profileBioLabel => 'Bio';

  @override
  String get profileClearCountryButton => 'Clear country';

  @override
  String get profileCityResidenceHelper => 'The city of residence is checked against the selected country before saving.';

  @override
  String get profileCityNotFoundError => 'City not found in the selected country.';

  @override
  String get profileCityVerificationError => 'Unable to verify the city right now.';

  @override
  String get profileAvatarUploadError => 'Unable to upload the avatar.';

  @override
  String get profileAccountSectionTitle => 'Account';

  @override
  String get profileAccountEmailHelper => 'The account email address cannot be changed from this screen.';

  @override
  String get profileChangePasswordAction => 'Change password';

  @override
  String get profileChangePasswordDescription => 'Set a new password for this account.';

  @override
  String get notificationsPageTitle => 'Notifications';

  @override
  String get notificationsMarkAllReadAction => 'Mark all as read';

  @override
  String get notificationsNoTargetMessage => 'This notification does not have an available destination.';

  @override
  String get notificationsTargetUnavailableMessage => 'The content linked to this notification is unavailable.';

  @override
  String get notificationsLoadError => 'Unable to load notifications.';

  @override
  String get notificationsRetryButton => 'Try again';

  @override
  String get notificationsEmptyMessage => 'No notifications available.';

  @override
  String get notificationsCommentReplyTitle => 'New reply to your comment';

  @override
  String get notificationsMentionTitle => 'You were mentioned';

  @override
  String get notificationsPollResultTitle => 'Poll update';

  @override
  String notificationsCommentReplySubtitle(String actor, String target) {
    return 'User $actor replied in $target';
  }

  @override
  String notificationsMentionSubtitle(String actor, String target) {
    return 'User $actor mentioned you in $target';
  }

  @override
  String notificationsPollResultSubtitle(String target) {
    return 'A new result is available in $target';
  }

  @override
  String get notificationsTargetPost => 'a post';

  @override
  String get notificationsTargetNews => 'a news article';

  @override
  String get notificationsTargetPoll => 'a poll';

  @override
  String get notificationsTargetVideo => 'a video';

  @override
  String get notificationsTargetContent => 'some content';

  @override
  String get notificationsUserFallback => 'user';

  @override
  String get profileDeleteAccountAction => 'Delete account';

  @override
  String get profileDeleteAccountDescription => 'Permanently delete the account and access';

  @override
  String get profileDeleteAccountDialogTitle => 'Delete account';

  @override
  String get profileDeleteAccountDialogMessage => 'This action is permanent. The account cannot be recovered. Type DELETE to confirm.';

  @override
  String get profileDeleteAccountConfirmationLabel => 'Deletion confirmation';

  @override
  String get profileDeleteAccountConfirmationHint => 'Type DELETE';

  @override
  String get profileDeleteAccountConfirmationError => 'Type DELETE to continue.';

  @override
  String get profileDeleteAccountCancelButton => 'Cancel';

  @override
  String get profileDeleteAccountConfirmButton => 'Delete permanently';

  @override
  String get profileDeleteAccountFailureMessage => 'Unable to delete the account. Try again.';
}
