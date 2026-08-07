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
  String get profileAppLanguageTitle => 'App language';

  @override
  String get profileAppLanguageSystem => 'System';

  @override
  String get profileAppLanguageSystemDescription => 'Uses your device language';

  @override
  String get profileAppLanguageItalian => 'Italian';

  @override
  String get profileAppLanguageEnglish => 'English';

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
  String get authUsernameAlreadyTakenError => 'Username is already in use.';

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

  @override
  String get identityActorTypePerson => 'Person';

  @override
  String get identityActorTypePublicOfficial => 'Public official';

  @override
  String get identityActorTypePublicInstitution => 'Public institution';

  @override
  String get identityActorTypeVerifiedOrganization => 'Verified organization';

  @override
  String get identityVerificationNotVerified => 'Not verified';

  @override
  String get identityVerificationLevel1 => 'Verified identity';

  @override
  String get identityVerificationLevel2 => 'Advanced verified identity';

  @override
  String get identityBadgeLevel1 => 'Verified identity';

  @override
  String get identityBadgeLevel2 => 'Advanced verified identity';

  @override
  String get identityBadgePublicOfficial => 'Public official';

  @override
  String get identityBadgePublicInstitution => 'Public institution';

  @override
  String get identityBadgeVerifiedOrganization => 'Verified organization';

  @override
  String get identityOrganizationNameLabel => 'Organization name';

  @override
  String get identityOrganizationNameRequired => 'Enter the organization name.';

  @override
  String get identityInstitutionLevelMunicipality => 'Municipal';

  @override
  String get identityInstitutionLevelProvince => 'Provincial';

  @override
  String get identityInstitutionLevelRegion => 'Regional';

  @override
  String get identityInstitutionLevelMinistry => 'Ministry';

  @override
  String get identityInstitutionLevelGovernment => 'Government';

  @override
  String get identityInstitutionLevelPublicAgency => 'Public agency';

  @override
  String get identityInstitutionLevelOtherPublicBody => 'Other public body';

  @override
  String get verificationRequestPersonLevel1 => 'Person verification — Level 1';

  @override
  String get verificationRequestPersonLevel2 => 'Person verification — Level 2';

  @override
  String get verificationRequestPublicOfficial => 'Public official verification';

  @override
  String get verificationRequestPublicInstitution => 'Public institution verification';

  @override
  String get verificationRequestVerifiedOrganization => 'Organization verification';

  @override
  String get verificationCenterTitle => 'Verification and account type';

  @override
  String get verificationCurrentAccountSection => 'Current account';

  @override
  String verificationAccountTypeValue(String accountType) {
    return 'Account type: $accountType';
  }

  @override
  String verificationLevelValue(String level) {
    return 'Verification level: $level';
  }

  @override
  String verificationOfficialTitleValue(String title) {
    return 'Official title: $title';
  }

  @override
  String verificationInstitutionNameValue(String name) {
    return 'Institution: $name';
  }

  @override
  String verificationOrganizationNameValue(String name) {
    return 'Organization: $name';
  }

  @override
  String verificationInstitutionLevelValue(String level) {
    return 'Institution level: $level';
  }

  @override
  String get verificationActiveRequestSection => 'Active request';

  @override
  String get verificationProfileUnchangedUntilApproval => 'Your current profile will not change until the request is approved.';

  @override
  String get verificationCancelPendingAction => 'Cancel pending request';

  @override
  String get verificationPendingBlocksNewRequests => 'You cannot submit a new request while another request is pending.';

  @override
  String get verificationNoActiveRequestSection => 'No active request';

  @override
  String get verificationNoActiveRequestDescription => 'You currently have no requests under review.';

  @override
  String get verificationLastRejectedSection => 'Last rejected request';

  @override
  String get verificationLastRejectedDescription => 'Your last request was rejected.';

  @override
  String get verificationRejectedCanResubmit => 'Your current profile has not changed. You can correct the information and submit a new request.';

  @override
  String get verificationAvailableRequestsSection => 'Available requests';

  @override
  String get verificationRequestLevel1Title => 'Request person verification — Level 1';

  @override
  String get verificationRequestLevel1Subtitle => 'Basic personal identity verification';

  @override
  String get verificationRequestLevel2Title => 'Request person verification — Level 2';

  @override
  String get verificationRequestLevel2Subtitle => 'Advanced personal identity verification';

  @override
  String get verificationRequestPublicOfficialTitle => 'Request a Public official account';

  @override
  String get verificationRequestPublicOfficialSubtitle => 'Requires an official title and review';

  @override
  String get verificationRequestPublicInstitutionTitle => 'Request a Public institution account';

  @override
  String get verificationRequestPublicInstitutionSubtitle => 'Requires the institution name, institution level, and review';

  @override
  String get verificationRequestOrganizationTitle => 'Request a Verified organization account';

  @override
  String get verificationRequestOrganizationSubtitle => 'Requires the organization name and review';

  @override
  String get verificationNoSelfServiceUpgrade => 'No verification options are available for your current account status.';

  @override
  String get verificationRequestSubmitSuccess => 'Request submitted successfully.';

  @override
  String get verificationRequestSubmitFailure => 'Unable to submit the request.';

  @override
  String get verificationOfficialTitleDialogTitle => 'Public official verification';

  @override
  String get verificationOfficialTitleLabel => 'Official title';

  @override
  String get verificationOfficialTitleHint => 'e.g. Mayor, Councillor, Minister';

  @override
  String get verificationInstitutionDialogTitle => 'Public institution verification';

  @override
  String get verificationInstitutionNameLabel => 'Institution name';

  @override
  String get verificationInstitutionNameHint => 'e.g. City of Rome';

  @override
  String get verificationInstitutionLevelLabel => 'Institution level';

  @override
  String get verificationOrganizationDialogTitle => 'Organization verification';

  @override
  String get verificationOrganizationNameHint => 'e.g. Environment Italy Association';

  @override
  String get verificationSubmitRequestAction => 'Submit request';

  @override
  String get verificationCancelDialogTitle => 'Cancel request';

  @override
  String get verificationCancelDialogBody => 'Are you sure you want to cancel the pending verification request?';

  @override
  String get verificationCancelSuccess => 'Request cancelled.';

  @override
  String get verificationCancelFailure => 'Unable to cancel the request.';

  @override
  String get verificationStatusPendingSuffix => 'request under review';

  @override
  String get verificationStatusRejectedSuffix => 'last request rejected';

  @override
  String get verificationReviewPageTitle => 'Verification review';

  @override
  String get verificationReviewLoginRequired => 'You must sign in to review verification requests.';

  @override
  String verificationReviewPendingCount(int count) {
    return 'Pending requests: $count';
  }

  @override
  String get verificationReviewNoPendingRequests => 'There are no pending verification requests.';

  @override
  String get verificationReviewUserIdLabel => 'User ID';

  @override
  String get verificationReviewSubmittedLabel => 'Submitted';

  @override
  String get verificationReviewOfficialTitleLabel => 'Official title';

  @override
  String get verificationReviewInstitutionLabel => 'Institution';

  @override
  String get verificationReviewOrganizationLabel => 'Organization';

  @override
  String get verificationReviewNoteLabel => 'Review note';

  @override
  String get verificationReviewRejectAction => 'Reject';

  @override
  String get verificationReviewApproveAction => 'Approve';

  @override
  String get verificationReviewApproveDialogTitle => 'Approve request';

  @override
  String get verificationReviewRejectDialogTitle => 'Reject request';

  @override
  String get verificationReviewApproveConfirmation => 'Confirm approval of this request?';

  @override
  String get verificationReviewRejectConfirmation => 'Confirm rejection of this request?';

  @override
  String get verificationReviewOptionalNoteLabel => 'Optional review note';

  @override
  String get verificationReviewRequiredNoteLabel => 'Reason for rejection';

  @override
  String get verificationReviewOptionalHelper => 'Optional';

  @override
  String get verificationReviewRequiredHelper => 'Required when rejecting';

  @override
  String get verificationReviewRequiredNoteError => 'Enter the reason for rejection.';

  @override
  String get verificationReviewApprovedSuccess => 'Request approved.';

  @override
  String get verificationReviewRejectedSuccess => 'Request rejected.';

  @override
  String get verificationReviewOperationFailure => 'Operation failed.';

  @override
  String get adminCenterTitle => 'Admin Center';

  @override
  String get adminCenterDashboardNavigation => 'Dashboard';

  @override
  String get adminCenterUsersNavigation => 'Users';

  @override
  String get adminCenterVerificationNavigation => 'Verification';

  @override
  String get adminCenterReportsNavigation => 'Reports';

  @override
  String get adminCenterAuditNavigation => 'Audit';

  @override
  String get adminCenterAccountDetailsTitle => 'Account details';

  @override
  String get adminCenterTryAgainAction => 'Try again';

  @override
  String get adminCenterRetryAction => 'Retry';

  @override
  String get adminCenterClearAction => 'Clear';

  @override
  String get adminCenterApplyFiltersAction => 'Apply filters';

  @override
  String get adminCenterAllDates => 'All dates';

  @override
  String get adminCenterAuditDateFilterHelp => 'Filter audit by date';

  @override
  String get adminCenterActorUserIdLabel => 'Actor user ID';

  @override
  String get adminCenterActionLabel => 'Action';

  @override
  String get adminCenterAuditActionHint => 'resolve_escalated_report';

  @override
  String get adminCenterTargetIdLabel => 'Target ID';

  @override
  String get adminCenterOutcomeLabel => 'Outcome';

  @override
  String get adminCenterAllOutcomes => 'All outcomes';

  @override
  String get adminCenterOutcomeSuccess => 'Success';

  @override
  String get adminCenterOutcomeFailure => 'Failure';

  @override
  String get adminCenterOutcomeDenied => 'Denied';

  @override
  String get adminCenterOutcomeNoChange => 'No change';

  @override
  String get adminCenterOutcomeUnknown => 'Unknown';

  @override
  String get adminCenterAuditUnavailableTitle => 'Audit unavailable';

  @override
  String get adminCenterAuditUnavailableMessage => 'Check your connection and permissions, then try again.';

  @override
  String get adminCenterNoAuditEntriesTitle => 'No audit entries';

  @override
  String get adminCenterNoAuditEntriesMessage => 'There are no entries matching the selected filters.';

  @override
  String get adminCenterAuditIdLabel => 'Audit ID';

  @override
  String get adminCenterActorLabel => 'Actor';

  @override
  String get adminCenterReasonLabel => 'Reason';

  @override
  String get adminCenterTimestampLabel => 'Timestamp';

  @override
  String get adminCenterErrorLabel => 'Error';

  @override
  String get adminCenterRecordedValuesTitle => 'Recorded values';

  @override
  String get adminCenterPreviousValueLabel => 'Previous';

  @override
  String get adminCenterNewValueLabel => 'New';

  @override
  String get adminCenterContentTypeLabel => 'Content type';

  @override
  String get adminCenterAllContent => 'All content';

  @override
  String get adminCenterPolls => 'Polls';

  @override
  String get adminCenterPosts => 'Posts';

  @override
  String get adminCenterNews => 'News';

  @override
  String get adminCenterAwaitingAdminDecision => 'Awaiting admin decision';

  @override
  String get adminCenterStatusLabel => 'Status';

  @override
  String get adminCenterAllStatuses => 'All statuses';

  @override
  String get adminCenterStatusOpen => 'Open';

  @override
  String get adminCenterStatusInReview => 'In review';

  @override
  String get adminCenterStatusResolved => 'Resolved';

  @override
  String get adminCenterStatusDismissed => 'Dismissed';

  @override
  String get adminCenterAdminQueueUnavailableTitle => 'Admin escalation queue unavailable';

  @override
  String get adminCenterReportsUnavailableTitle => 'Reports unavailable';

  @override
  String get adminCenterConnectionTryAgainMessage => 'Check your connection and try again.';

  @override
  String get adminCenterNoAdminReportsTitle => 'No reports awaiting admin decision';

  @override
  String get adminCenterNoReportsTitle => 'No reports';

  @override
  String get adminCenterNoAdminReportsMessage => 'There are no escalated reports requiring administrator review.';

  @override
  String get adminCenterNoReportsMessage => 'There are no reports matching the selected filters.';

  @override
  String get adminCenterSearchUsersHint => 'Search by name, username, email or ID';

  @override
  String get adminCenterClearSearchTooltip => 'Clear search';

  @override
  String get adminCenterUsersUnavailableTitle => 'Users unavailable';

  @override
  String get adminCenterNoUsersFoundTitle => 'No users found';

  @override
  String get adminCenterNoUsersTitle => 'No users';

  @override
  String get adminCenterNoUsersFoundMessage => 'Try a different name, username, email or ID.';

  @override
  String get adminCenterNoUsersMessage => 'There are no accounts to display.';

  @override
  String get adminCenterAccountUnavailableTitle => 'Account unavailable';

  @override
  String get adminCenterBackToUsersAction => 'Back to users';

  @override
  String get adminCenterPublicIdentitySection => 'Public identity';

  @override
  String get adminCenterDisplayNameLabel => 'Display name';

  @override
  String get adminCenterNotProvided => 'Not provided';

  @override
  String get adminCenterUsernameLabel => 'Username';

  @override
  String get adminCenterUserIdLabel => 'User ID';

  @override
  String get adminCenterIdentityTypeLabel => 'Identity type';

  @override
  String get adminCenterAccountSection => 'Account';

  @override
  String get adminCenterTechnicalRoleLabel => 'Technical role';

  @override
  String get adminCenterRoleMirrorLabel => 'Profile role mirror';

  @override
  String get adminCenterRoleSynchronizationLabel => 'Role synchronization';

  @override
  String get adminCenterSynchronized => 'Synchronized';

  @override
  String get adminCenterNotSynchronized => 'Not synchronized';

  @override
  String get adminCenterRoleNotSynchronized => 'Role not synchronized';

  @override
  String get adminCenterAccountStatusLabel => 'Account status';

  @override
  String get adminCenterSuspendedUntilLabel => 'Suspended until';

  @override
  String get adminCenterAccountManagementSection => 'Account management';

  @override
  String get adminCenterDangerZoneSection => 'Danger zone';

  @override
  String get adminCenterRoleManagementSection => 'Role management';

  @override
  String get adminCenterVerificationLevelLabel => 'Verification level';

  @override
  String get adminCenterVerificationStatusLabel => 'Verification status';

  @override
  String get adminCenterAccessInformationSection => 'Access information';

  @override
  String get adminCenterEmailLabel => 'Email';

  @override
  String get adminCenterNotAvailable => 'Not available';

  @override
  String get adminCenterEmailConfirmationLabel => 'Email confirmation';

  @override
  String get adminCenterNotConfirmed => 'Not confirmed';

  @override
  String get adminCenterRegisteredLabel => 'Registered';

  @override
  String get adminCenterLastAccessLabel => 'Last access';

  @override
  String get adminCenterLoadingDashboardTitle => 'Loading dashboard';

  @override
  String get adminCenterLoadingDashboardMessage => 'Retrieving the latest indicators.';

  @override
  String get adminCenterDashboardUnavailableTitle => 'Dashboard unavailable';

  @override
  String get adminCenterIndicatorsUnavailableMessage => 'The indicators could not be loaded.';

  @override
  String get adminCenterVerificationPendingIndicator => 'Verification pending';

  @override
  String get adminCenterOpenReportsIndicator => 'Open reports';

  @override
  String get adminCenterSuspendedAccountsIndicator => 'Suspended accounts';

  @override
  String get adminCenterStaffIndicator => 'Staff';

  @override
  String get adminCenterNoPendingWorkTitle => 'No pending work';

  @override
  String get adminCenterNoPendingWorkMessage => 'Verification, reports, and suspended accounts are clear.';

  @override
  String get adminCenterCouldNotUpdateUsers => 'Could not update the user list.';

  @override
  String get adminCenterCouldNotUpdateReports => 'Could not update the report queue.';

  @override
  String get adminCenterUnnamedUser => 'Unnamed user';

  @override
  String get adminCenterTemporarySuspensionTitle => 'Temporary suspension';

  @override
  String get adminCenterReactivateDescription => 'Remove the suspension immediately and allow a new login.';

  @override
  String get adminCenterSuspendDescription => 'Block access for a limited time and end all current sessions.';

  @override
  String get adminCenterSuspensionUnavailableDescription => 'Suspension requires a synchronized, non-admin account.';

  @override
  String get adminCenterReactivateAccountAction => 'Reactivate account';

  @override
  String get adminCenterSuspendAccountAction => 'Suspend account';

  @override
  String get adminCenterForceLogoutAction => 'Force logout';

  @override
  String get adminCenterSuspendedForceLogoutDescription => 'The suspension has already ended current sessions. Reactivate the account before testing a separate logout.';

  @override
  String get adminCenterForceLogoutDescription => 'End every current session without suspending the account.';

  @override
  String get adminCenterForceLogoutUnavailableDescription => 'Forced logout requires a synchronized, non-admin account.';

  @override
  String get adminCenterPermanentDeletionTitle => 'Permanent account deletion';

  @override
  String get adminCenterPermanentDeletionDescription => 'Delete authentication data, end every session and anonymize the retained public record.';

  @override
  String get adminCenterDeletionUnavailableDescription => 'Deletion requires a synchronized, non-admin account.';

  @override
  String get adminCenterDeleteAccountPermanentlyAction => 'Delete account permanently';

  @override
  String get adminCenterDurationOneHour => '1 hour';

  @override
  String get adminCenterDurationOneDay => '24 hours';

  @override
  String get adminCenterDurationSevenDays => '7 days';

  @override
  String get adminCenterDurationThirtyDays => '30 days';

  @override
  String get adminCenterSuspendImmediateEffect => 'The account will lose access immediately and every current session will be ended.';

  @override
  String get adminCenterDurationLabel => 'Duration';

  @override
  String get adminCenterSuspendReasonHint => 'Explain why this account must be suspended';

  @override
  String get adminCenterReactivateReasonHint => 'Explain why this account can be reactivated';

  @override
  String get adminCenterReactivateConfirmation => 'I confirm that this account can regain access.';

  @override
  String get adminCenterReactivateFailure => 'The account could not be reactivated. Check its role and status, then try again.';

  @override
  String get adminCenterReactivateSuccess => 'Account reactivated. A new login is now allowed.';

  @override
  String get adminCenterForceLogoutFullDescription => 'End every current session for this account. The account remains active and can sign in again.';

  @override
  String get adminCenterForceLogoutReasonHint => 'Explain why current sessions must be ended';

  @override
  String get adminCenterForceLogoutConfirmation => 'I confirm the immediate termination of all current sessions for this account.';

  @override
  String get adminCenterForceLogoutFailure => 'The account could not be signed out. Check its role and status, then try again.';

  @override
  String get adminCenterForceLogoutSuccess => 'Current sessions ended. The account can sign in again.';

  @override
  String get adminCenterSuspendFailure => 'The account could not be suspended. Check its role and status, then try again.';

  @override
  String get adminCenterDeleteReasonHint => 'Explain why this account must be deleted';

  @override
  String get adminCenterTypeDeleteLabel => 'Type DELETE';

  @override
  String get adminCenterTypeAccountIdLabel => 'Type the complete Account ID';

  @override
  String get adminCenterDeletePermanentlyAction => 'Delete permanently';

  @override
  String get adminCenterDeleteIrreversibleWarning => 'This action is irreversible. Authentication data and current sessions will be removed, the avatar will be deleted and the retained public record will be anonymized. The audit record will remain.';

  @override
  String get adminCenterDeleteFailure => 'The account could not be deleted. Check its role, status and confirmation values, then try again.';

  @override
  String get adminCenterDeleteSuccess => 'Account permanently deleted and personal data anonymized.';

  @override
  String get adminCenterChangeTechnicalRoleTitle => 'Change technical role';

  @override
  String get adminCenterChangeRoleDescription => 'Review the current and requested role before confirming.';

  @override
  String get adminCenterChangeRoleUnavailableDescription => 'Role changes require a synchronized, non-deleted account.';

  @override
  String get adminCenterChangeRoleAction => 'Change role';

  @override
  String get adminCenterChangePublicIdentityTitle => 'Change public identity';

  @override
  String get adminCenterChangeIdentityDescription => 'Update the public account type and verification level.';

  @override
  String get adminCenterChangeIdentityUnavailableDescription => 'Identity changes require a synchronized, non-admin account.';

  @override
  String get adminCenterChangeIdentityAction => 'Change identity';

  @override
  String get adminCenterChoosePublicIdentityMessage => 'Choose the public account type and its verification state.';

  @override
  String get adminCenterPublicAccountTypeLabel => 'Public account type';

  @override
  String get adminCenterPersonVerificationHelper => 'Level 1 and Level 2 are available only for Persona.';

  @override
  String get adminCenterNonPersonVerificationHelper => 'Non-Persona accounts do not use Level 1 or Level 2.';

  @override
  String get adminCenterBeforeLabel => 'Before';

  @override
  String get adminCenterAfterLabel => 'After';

  @override
  String get adminCenterIdentityReasonHint => 'Explain why the public identity must change';

  @override
  String get adminCenterIdentityConfirmation => 'I confirm the public identity and verification level shown above.';

  @override
  String get adminCenterIdentityChangeFailure => 'The public identity could not be changed. Check the account state and try again.';

  @override
  String get adminCenterChooseTechnicalRoleMessage => 'Choose the new technical role and record why this change is required.';

  @override
  String get adminCenterNewTechnicalRoleLabel => 'New technical role';

  @override
  String get adminCenterSelectRole => 'Select a role';

  @override
  String get adminCenterRoleSessionWarning => 'This change ends the recipient’s active session. They must sign in again before continuing to use the account.';

  @override
  String get adminCenterRoleReasonHint => 'Explain why the technical role must change';

  @override
  String get adminCenterRoleConfirmation => 'I confirm the role shown above and understand that the recipient must sign in again.';

  @override
  String get adminCenterRoleChangeFailure => 'The role change could not be completed. Check the account state and try again.';

  @override
  String get adminCenterChangingRole => 'Changing role';

  @override
  String get adminCenterConfirmRoleChange => 'Confirm role change';

  @override
  String get adminCenterRoleUser => 'User';

  @override
  String get adminCenterRoleModerator => 'Moderator';

  @override
  String get adminCenterRoleAdmin => 'Admin';

  @override
  String get adminCenterAccountStatusActive => 'Active';

  @override
  String get adminCenterAccountStatusSuspended => 'Suspended';

  @override
  String get adminCenterAccountStatusDeleted => 'Deleted';

  @override
  String get adminCenterVerificationStatusNone => 'None';

  @override
  String get adminCenterVerificationStatusPending => 'Pending';

  @override
  String get adminCenterVerificationStatusRejected => 'Rejected';

  @override
  String get adminCenterVerificationNotVerified => 'Not verified';

  @override
  String get adminCenterVerificationLevel1 => 'Level 1';

  @override
  String get adminCenterVerificationLevel2 => 'Level 2';

  @override
  String get adminCenterReportSingular => 'report';

  @override
  String get adminCenterReportPlural => 'reports';

  @override
  String get adminCenterUserSingular => 'user';

  @override
  String get adminCenterUserPlural => 'users';

  @override
  String get adminCenterPoll => 'Poll';

  @override
  String get adminCenterPost => 'Post';

  @override
  String get adminCenterUnknown => 'Unknown';

  @override
  String get adminCenterContentHidden => 'Content hidden';

  @override
  String get adminCenterContentVisible => 'Content visible';

  @override
  String get adminCenterReportedByLabel => 'Reported by';

  @override
  String get adminCenterContentOwnerLabel => 'Content owner';

  @override
  String get adminCenterReviewReportAction => 'Review report';

  @override
  String get adminCenterAdminDecisionAction => 'Admin decision';

  @override
  String get adminCenterRestoreContentAction => 'Restore content';

  @override
  String get adminCenterHideContentAction => 'Hide content';

  @override
  String get adminCenterOpenProfileAction => 'Open profile';

  @override
  String get adminCenterOpenContentAction => 'Open content';

  @override
  String get adminCenterDecisionNoViolation => 'No violation';

  @override
  String get adminCenterDecisionViolationConfirmed => 'Violation confirmed';

  @override
  String get adminCenterDecisionEscalateToAdmin => 'Escalate to admin';

  @override
  String get adminCenterResolutionNoAccountAction => 'No account action';

  @override
  String get adminCenterResolutionAccountSuspended => 'Account suspended';

  @override
  String get adminCenterResolutionLogoutForced => 'Logout forced';

  @override
  String get adminCenterResolutionAccountDeleted => 'Account deleted';

  @override
  String get adminCenterReviewerLabel => 'Reviewer';

  @override
  String get adminCenterDecisionDescriptionNoViolation => 'Dismisses the report because the content does not violate the current rules.';

  @override
  String get adminCenterDecisionDescriptionViolation => 'Confirms a violation and keeps the case in review for the content action handled in AC8.5.';

  @override
  String get adminCenterDecisionDescriptionEscalation => 'Escalates the case for an administrator account-level review.';

  @override
  String get adminCenterChooseModerationOutcome => 'Choose the moderation outcome for this report.';

  @override
  String get adminCenterDecisionAlreadyRecordedFailure => 'The decision could not be recorded. The report may already have been reviewed. Refresh the queue and try again.';

  @override
  String get adminCenterDecisionLabel => 'Decision';

  @override
  String get adminCenterReportReasonLabel => 'Report reason';

  @override
  String get adminCenterReviewNoteLabel => 'Review note';

  @override
  String get adminCenterReviewNoteHint => 'Explain the evidence and the moderation decision';

  @override
  String get adminCenterRecordingDecision => 'Recording decision';

  @override
  String get adminCenterConfirmDecision => 'Confirm decision';

  @override
  String get adminCenterAdministratorDecisionTitle => 'Administrator decision';

  @override
  String get adminCenterResolutionDescriptionNoAction => 'Closes the escalated report without changing the account.';

  @override
  String get adminCenterResolutionDescriptionSuspended => 'Closes the report after a successful account suspension has already been recorded in the audit log.';

  @override
  String get adminCenterResolutionDescriptionLogout => 'Closes the report after a successful forced logout has already been recorded in the audit log.';

  @override
  String get adminCenterResolutionDescriptionDeleted => 'Closes the report after a successful account deletion has already been recorded in the audit log.';

  @override
  String get adminCenterChooseFinalOutcome => 'Choose the final administrator outcome for this escalation.';

  @override
  String get adminCenterAdminResolutionFailure => 'The administrator decision could not be recorded. Refresh the queue and try again.';

  @override
  String get adminCenterAdminResolutionRequiresAction => 'Complete the matching account action first, then return to this report and record the final administrator decision.';

  @override
  String get adminCenterEscalationNoteLabel => 'Escalation note';

  @override
  String get adminCenterFinalOutcomeLabel => 'Final outcome';

  @override
  String get adminCenterAdministratorNoteLabel => 'Administrator note';

  @override
  String get adminCenterAdministratorNoteHint => 'Explain the final account-level decision';

  @override
  String get adminCenterHideContentFailure => 'The content could not be hidden. Refresh the report queue and try again.';

  @override
  String get adminCenterRestoreContentFailure => 'The content could not be restored. Refresh the report queue and try again.';

  @override
  String get adminCenterHideContentWarning => 'This removes the reported content from public access. The action can later be reversed from the Resolved reports filter.';

  @override
  String get adminCenterRestoreContentWarning => 'This makes the reported content publicly available again.';

  @override
  String get adminCenterActionReasonLabel => 'Action reason';

  @override
  String get adminCenterHideContentReasonHint => 'Explain why the content must be hidden';

  @override
  String get adminCenterRestoreContentReasonHint => 'Explain why the content can be restored';

  @override
  String get adminCenterHidingContent => 'Hiding content';

  @override
  String get adminCenterRestoringContent => 'Restoring content';

  @override
  String get adminCenterReportedProfileTitle => 'Reported profile';

  @override
  String get adminCenterReportedProfileNotice => 'This profile context comes from the protected report queue. Administrative account actions remain separate.';

  @override
  String get adminCenterCouldNotRefreshIndicators => 'Could not refresh the indicators.';

  @override
  String get adminCenterCouldNotRefreshAccount => 'Could not refresh the account details.';

  @override
  String get adminCenterReportAlreadyReviewed => 'This report has already been reviewed or is no longer pending.';

  @override
  String get adminCenterReportNotAwaitingAdmin => 'This report is not awaiting an administrator decision.';

  @override
  String get adminCenterConfirmedViolationRequired => 'A confirmed violation is required before changing content visibility.';

  @override
  String get adminCenterContentHiddenSuccess => 'The reported content was hidden.';

  @override
  String get adminCenterContentRestoredSuccess => 'The reported content was restored.';

  @override
  String get adminCenterMissingContentId => 'The original content identifier is missing.';

  @override
  String get adminCenterUnsupportedTargetType => 'This report has an unsupported target type.';

  @override
  String get adminCenterOriginalContentUnavailable => 'The original content is no longer available.';

  @override
  String get adminCenterNoReportedProfile => 'No reported profile is associated with this content.';

  @override
  String adminCenterRoleChangedSuccess(String previousRole, String newRole) {
    return 'Technical role changed from $previousRole to $newRole. The recipient was signed out and must sign in again.';
  }

  @override
  String adminCenterIdentityChangedSuccess(String actorType, String verificationLevel) {
    return 'Public identity changed to $actorType with $verificationLevel.';
  }

  @override
  String adminCenterAccountSuspendedSuccess(String dateTime) {
    return 'Account suspended until $dateTime. The recipient was signed out.';
  }

  @override
  String adminCenterReportDecisionRecorded(String decision) {
    return 'Report decision recorded: $decision.';
  }

  @override
  String adminCenterAdministratorDecisionRecorded(String decision) {
    return 'Administrator decision recorded: $decision.';
  }

  @override
  String adminCenterUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count users',
      one: '$count user',
    );
    return '$_temp0';
  }

  @override
  String adminCenterReportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reports',
      one: '$count report',
    );
    return '$_temp0';
  }

  @override
  String adminCenterAccountValue(String account) {
    return 'Account: $account';
  }

  @override
  String adminCenterSuspendedUntilValue(String dateTime) {
    return 'Suspended until: $dateTime';
  }

  @override
  String adminCenterSuspendConfirmation(String dateTime) {
    return 'I confirm the suspension until $dateTime and the immediate termination of current sessions.';
  }

  @override
  String adminCenterAccountIdValue(String accountId) {
    return 'Account ID: $accountId';
  }

  @override
  String adminCenterCurrentRoleValue(String role) {
    return 'Current: $role';
  }

  @override
  String adminCenterTargetFallback(String targetType, String targetId) {
    return '$targetType $targetId';
  }

  @override
  String adminCenterMinimumCharactersRequired(int count) {
    return 'A note of at least $count characters is required.';
  }

  @override
  String adminCenterMinimumReasonCharactersRequired(int count) {
    return 'A reason of at least $count characters is required.';
  }

  @override
  String adminCenterPageOf(int currentPage, int totalPages) {
    return 'Page $currentPage of $totalPages';
  }
}
