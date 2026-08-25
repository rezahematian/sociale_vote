// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'Social Vote';

  @override
  String get voteButton => 'رأی بدهید';

  @override
  String get createPollPageTitle => 'ایجاد Vote';

  @override
  String get createPollPageSubtitle => 'یک رأی‌گیری مدنی جدید تعریف کنید';

  @override
  String get createPollBasicInfoTitle => 'اطلاعات پایه';

  @override
  String get createPollBasicInfoSubtitle => 'جزئیات اصلی Vote را تعریف کنید.';

  @override
  String get createPollTitleFieldLabel => 'عنوان *';

  @override
  String get createPollTitleFieldHelper => 'یک پرسش یا بیانیه روشن و کوتاه.';

  @override
  String get createPollDescriptionFieldLabel => 'توضیحات (اختیاری)';

  @override
  String get createPollVotingModelTitle => 'نحوه رأی‌دادن';

  @override
  String get createPollVotingModelSubtitle => 'انتخاب کنید که هر فرد بتواند یک پاسخ یا چند پاسخ را انتخاب کند.';

  @override
  String get createPollTypeFieldLabel => 'نوع Vote';

  @override
  String createPollSelectionRules(int min, int max) {
    return 'قواعد انتخاب: حداقل $min و حداکثر $max انتخاب (بر اساس نوع Vote و گزینه‌ها خودکار تنظیم می‌شود).';
  }

  @override
  String get createPollAllowVoteChangeTitle => 'اجازه تغییر رأی به رأی‌دهندگان';

  @override
  String get createPollAllowVoteChangeSubtitle => 'تا زمان بسته‌شدن Vote.';

  @override
  String get createPollOptionsTitle => 'پاسخ‌ها';

  @override
  String get createPollOptionsSubtitle => 'حداقل دو پاسخ برای انتخاب رأی‌دهندگان وارد کنید. فیلدهای علامت‌خورده با * الزامی هستند.';

  @override
  String createPollOptionLabel(int index, Object requiredMarker) {
    return 'گزینه $index$requiredMarker';
  }

  @override
  String get createPollRemoveOptionTooltip => 'حذف گزینه';

  @override
  String get createPollAddOptionButton => 'افزودن گزینه';

  @override
  String get createPollParticipationPrivacyTitle => 'مشارکت و حریم خصوصی';

  @override
  String get createPollParticipationPrivacySubtitle => 'مشخص کنید چه کسانی می‌توانند رأی بدهند و رأی‌ها تا چه اندازه محرمانه باشند.';

  @override
  String get createPollWhoCanVoteLabel => 'چه کسی می‌تواند رأی بدهد؟';

  @override
  String get createPollParticipationEveryoneSubtitle => 'هر کاربر ثبت‌نام‌شده می‌تواند شرکت کند.';

  @override
  String get createPollParticipationGeoScopeSubtitle => 'این Vote را به افراد یک کشور مشخص محدود کنید.';

  @override
  String get createPollCountryFieldLabel => 'کشور این Vote';

  @override
  String get createPollCountryFieldHelper => 'این کشور مشخص می‌کند چه کسانی مجاز به مشارکت در Vote هستند (اتصال آینده به بک‌اند).';

  @override
  String get createPollVoteAnonymityTitle => 'ناشناس‌بودن رأی';

  @override
  String get createPollAnonymityAnonymousSubtitle => 'گزینه پیش‌فرض پیشنهادی برای پلتفرم‌های رأی‌گیری مدنی.';

  @override
  String get createPollAnonymityPublicSubtitle => 'با احتیاط استفاده کنید: ممکن است رأی‌ها به هویت‌ها مرتبط شوند (قابلیت آینده).';

  @override
  String get createPollResultsValidityTitle => 'نتایج و اعتبار';

  @override
  String get createPollResultsValiditySubtitle => 'زمان نمایش نتایج را کنترل کنید و در صورت نیاز حداقل نصاب را تعیین کنید.';

  @override
  String get createPollResultsVisibilityFieldLabel => 'قابلیت مشاهده نتایج';

  @override
  String get createPollQuorumTitle => 'حداقل نصاب (اختیاری)';

  @override
  String get createPollQuorumSubtitle => 'در صورت تنظیم، Vote فقط زمانی معتبر است که حداقل این تعداد رأی ثبت شود. برای نداشتن حداقل نصاب، خالی بگذارید.';

  @override
  String get createPollQuorumMinVotesFieldLabel => 'حداقل تعداد رأی';

  @override
  String get createPollTimingTitle => 'زمان‌بندی';

  @override
  String get createPollTimingSubtitle => 'مشخص کنید Vote چه زمانی برای رأی‌دادن باز باشد.';

  @override
  String get createPollStartDateLabel => 'تاریخ شروع';

  @override
  String get createPollEndDateLabel => 'تاریخ پایان';

  @override
  String get createPollChangeDateButtonLabel => 'تغییر';

  @override
  String get createPollTimingStatusInfo => 'وضعیت اولیه (باز/زمان‌بندی‌شده/بسته) بر اساس این تاریخ‌ها خودکار تعیین می‌شود.';

  @override
  String get createPollSuccessMessage => 'Vote با موفقیت ایجاد شد';

  @override
  String get createPollSubmitCreatingLabel => 'در حال ایجاد...';

  @override
  String get createPollSubmitLabel => 'ایجاد Vote';

  @override
  String get createPollPollTypeYesNoLabel => 'بله / خیر';

  @override
  String get createPollPollTypeSingleChoiceLabel => 'یک پاسخ';

  @override
  String get createPollPollTypeMultipleChoiceLabel => 'چند پاسخ';

  @override
  String get createPollPollTypeApprovalLabel => 'رأی‌گیری تأییدی';

  @override
  String get createPollPollTypeRankedLabel => 'انتخاب رتبه‌بندی‌شده';

  @override
  String get createPollPollTypeScoreLabel => 'امتیاز / رتبه‌بندی';

  @override
  String get createPollParticipationScopeEveryoneLabel => 'همه می‌توانند رأی بدهند';

  @override
  String get createPollParticipationScopeGeoScopeOnlyLabel => 'فقط کاربران یک کشور مشخص';

  @override
  String get createPollAnonymityLevelAnonymousLabel => 'رأی‌ها ناشناس هستند';

  @override
  String get createPollAnonymityLevelPublicLabel => 'رأی‌ها عمومی هستند (کاربرد پیشرفته / محدود)';

  @override
  String get createPollResultsVisibilityAlwaysLabel => 'همیشه قابل مشاهده (هنگام بازبودن Vote)';

  @override
  String get createPollResultsVisibilityAfterVoteLabel => 'فقط پس از رأی‌دادن قابل مشاهده';

  @override
  String get createPollResultsVisibilityAfterCloseLabel => 'فقط پس از بسته‌شدن Vote قابل مشاهده';

  @override
  String get homeLoginButton => 'ورود';

  @override
  String get homeRegisterButton => 'ثبت‌نام';

  @override
  String get homeProfileButton => 'پروفایل';

  @override
  String get homeLogoutButton => 'خروج';

  @override
  String get homeLogoutMessage => 'خروج انجام شد. اکنون به‌عنوان مهمان و فقط برای مشاهده از برنامه استفاده می‌کنید.';

  @override
  String get homeSearchHint => 'جست‌وجوی شهرها، کشورها، حساب‌ها و محتوا...';

  @override
  String get searchPageTitle => 'جست‌وجو';

  @override
  String get searchInputHint => 'جست‌وجوی حساب‌ها، Vote، News و Voce...';

  @override
  String get searchClearTooltip => 'پاک کردن جست‌وجو';

  @override
  String get searchTypeAll => 'همه';

  @override
  String get searchTypePolls => 'Vote';

  @override
  String get searchTypeNews => 'News';

  @override
  String get searchTypePosts => 'Voce';

  @override
  String get searchTypeAccounts => 'حساب‌ها';

  @override
  String get searchSortHottest => 'پرتب‌وتاب‌ترین';

  @override
  String get searchSortLatest => 'تازه‌ترین';

  @override
  String get searchPollStatusAll => 'همه Vote‌ها';

  @override
  String get searchPollStatusOpen => 'باز';

  @override
  String get searchPollStatusClosed => 'بسته';

  @override
  String get searchIdleMessage => 'برای شروع جست‌وجو، یک واژه وارد کنید.';

  @override
  String get searchErrorMessage => 'هنگام جست‌وجو مشکلی پیش آمد.';

  @override
  String get searchRetryButton => 'تلاش دوباره';

  @override
  String get searchEmptyMessage => 'نتیجه‌ای برای این جست‌وجو پیدا نشد.';

  @override
  String get searchContentUnavailable => 'محتوا در دسترس نیست';

  @override
  String get searchResultTypePoll => 'Vote';

  @override
  String get searchResultTypeNews => 'News';

  @override
  String get searchResultTypePost => 'Voce';

  @override
  String get searchResultTypeAccount => 'حساب';

  @override
  String get searchResultTypeMixed => 'ترکیبی';

  @override
  String homeUserStatusLoggedIn(Object userId) {
    return 'واردشده به‌عنوان: $userId';
  }

  @override
  String get homeUserStatusGuest => 'حالت مهمان: فقط می‌توانید مطالعه کنید. برای رأی‌دادن، نوشتن دیدگاه و واکنش، وارد شوید یا ثبت‌نام کنید.';

  @override
  String get homeScopeLabelWorld => 'جهان – رأی‌گیری‌ها و خبرهای جهانی';

  @override
  String get homeScopeLabelCountry => 'کشور – رأی‌گیری‌ها و خبرهای ملی';

  @override
  String get homeScopeLabelCity => 'شهر – رأی‌گیری‌ها و خبرهای محلی';

  @override
  String get homeScopeShortWorld => 'جهان';

  @override
  String get homeScopeShortCountry => 'کشور';

  @override
  String get homeScopeShortCity => 'شهر';

  @override
  String get homeScopeChipWorld => 'جهان';

  @override
  String get homeScopeChipItaly => 'ایتالیا';

  @override
  String get homeScopeChipTorino => 'تورین';

  @override
  String get homeScopeChangedWorld => 'محدوده به جهان تغییر کرد';

  @override
  String get homeScopeChangedItaly => 'محدوده به ایتالیا تغییر کرد';

  @override
  String get homeScopeChangedTorino => 'محدوده به تورین تغییر کرد';

  @override
  String get followScopeButtonFollowed => 'در حال دنبال‌کردن';

  @override
  String get followScopeButtonFollow => 'دنبال‌کردن این منطقه';

  @override
  String get homeTrendingTitle => 'Pulse · اکنون';

  @override
  String get homeTrendingError => 'بارگذاری محتوای داغ این منطقه ممکن نیست.';

  @override
  String get homeTrendingEmpty => 'در حال حاضر محتوای داغی برای این منطقه نیست.';

  @override
  String homeForYouTitle(Object scope) {
    return 'Pulse · $scope';
  }

  @override
  String get homeForYouError => 'بارگذاری پیشنهادهای این منطقه ممکن نیست.';

  @override
  String get homeForYouEmpty => 'در حال حاضر محتوای پیشنهادی برای این منطقه نیست.';

  @override
  String homePollsTitle(Object scope) {
    return 'Vote · برگزیده ($scope)';
  }

  @override
  String get homePollsEmptyTitle => 'رأی‌گیری‌ای برای این منطقه نیست';

  @override
  String get homePollsEmptySubtitle => 'در حال حاضر رأی‌گیری‌ای برای این منطقه در دسترس نیست.';

  @override
  String get homePollsViewAllButton => 'مشاهده Vote';

  @override
  String homeNewsTitle(Object scope) {
    return 'مهم‌ترین خبرها ($scope)';
  }

  @override
  String get homeNewsErrorTitle => 'بارگذاری خبرها ممکن نیست';

  @override
  String get homeNewsErrorSubtitle => 'در بارگذاری خبرهای این منطقه مشکلی پیش آمد.';

  @override
  String get homeNewsEmptyTitle => 'خبری برای این منطقه نیست';

  @override
  String get homeNewsEmptySubtitle => 'در حال حاضر خبری برای این محدوده نیست.';

  @override
  String get homeNewsViewAllButton => 'مشاهده همه خبرها';

  @override
  String get homeNewsBreakingBadge => 'فوری';

  @override
  String homeSocialTitle(Object scope) {
    return 'Voce · $scope';
  }

  @override
  String get homeSocialErrorTitle => 'بارگذاری دیدگاه‌ها ممکن نیست';

  @override
  String get homeSocialErrorSubtitle => 'در بارگذاری دیدگاه‌های این منطقه مشکلی پیش آمد.';

  @override
  String get homeSocialEmptyTitle => 'دیدگاهی برای این منطقه نیست';

  @override
  String get homeSocialEmptySubtitle => 'در حال حاضر دیدگاهی برای این منطقه نیست.';

  @override
  String get homeSocialViewFeedButton => 'مشاهده همه دیدگاه‌ها';

  @override
  String get pollDetail_title => 'جزئیات Vote';

  @override
  String get pollDetail_removeFromFavoritesTooltip => 'حذف از ذخیره‌شده‌ها';

  @override
  String get pollDetail_addToFavoritesTooltip => 'ذخیره';

  @override
  String get pollDetail_chipAnonymous => 'رأی‌گیری ناشناس';

  @override
  String get pollDetail_chipPublic => 'رأی‌گیری عمومی';

  @override
  String get pollDetail_chipRestrictedGeo => 'محدود به محدوده جغرافیایی';

  @override
  String pollDetail_quorumReached(int currentVotes, int requiredVotes) {
    return 'حداقل نصاب حاصل شد ($currentVotes / $requiredVotes)';
  }

  @override
  String pollDetail_quorumNotReached(int currentVotes, int requiredVotes) {
    return 'حداقل نصاب حاصل نشد ($currentVotes / $requiredVotes)';
  }

  @override
  String get pollDetail_optionsTitle => 'گزینه‌ها';

  @override
  String get pollDetail_statusClosedMessage => 'این Vote بسته شده است.';

  @override
  String get pollDetail_statusScheduledMessage => 'این Vote هنوز باز نشده است.';

  @override
  String get pollDetail_statusNotAvailableMessage => 'رأی‌دادن در دسترس نیست.';

  @override
  String get pollDetail_voteSubmitted => 'رأی با موفقیت ثبت شد!';

  @override
  String get pollDetail_voteButton => 'رأی بدهید';

  @override
  String get pollDetail_resultsTitle => 'نتایج';

  @override
  String pollDetail_outcomePrefix(Object label) {
    return 'نتیجه: $label';
  }

  @override
  String get pollDetail_noResults => 'هنوز نتیجه‌ای در دسترس نیست.';

  @override
  String get pollDetail_resultsAfterVote => 'نتایج پس از رأی‌دادن شما نمایش داده می‌شود.';

  @override
  String get pollDetail_resultsWhenClosed => 'نتایج پس از بسته‌شدن Vote نمایش داده می‌شود.';

  @override
  String get pollType_yesNo => 'بله / خیر';

  @override
  String get pollType_singleChoice => 'تک‌انتخابی';

  @override
  String get pollType_multipleChoice => 'چندانتخابی';

  @override
  String get pollType_approval => 'تأییدی';

  @override
  String get pollStatus_draft => 'پیش‌نویس';

  @override
  String get pollStatus_open => 'باز';

  @override
  String get pollStatus_closed => 'بسته';

  @override
  String get pollStatus_scheduled => 'زمان‌بندی‌شده';

  @override
  String get pollGeo_global => 'جهانی';

  @override
  String get pollGeo_local => 'محلی';

  @override
  String get pollOutcome_approved => 'تأییدشده';

  @override
  String get pollOutcome_rejected => 'ردشده';

  @override
  String get pollOutcome_tie => 'مساوی';

  @override
  String get pollOutcome_noMajority => 'بدون اکثریت';

  @override
  String get pollOutcome_notApplicable => 'نامربوط';

  @override
  String get pollList_title => 'Vote';

  @override
  String get pollList_scopeWorld => 'جهان';

  @override
  String get pollList_scopeCountryFallback => 'کشور';

  @override
  String get pollList_scopeCityFallback => 'شهر';

  @override
  String get pollList_scopeDescriptionGlobal => 'نمایش Vote‌های جهانی.';

  @override
  String get pollList_scopeDescriptionCountry => 'نمایش Vote‌های این کشور.';

  @override
  String get pollList_scopeDescriptionCity => 'نمایش Vote‌های این شهر.';

  @override
  String get pollList_filterStatus_all => 'همه';

  @override
  String get pollList_filterStatus_open => 'باز';

  @override
  String get pollList_filterStatus_closed => 'بسته';

  @override
  String get pollList_sort_latest => 'تازه‌ترین';

  @override
  String get pollList_sort_hottest => 'پرتب‌وتاب‌ترین';

  @override
  String get pollList_filterScope_currentArea => 'منطقه فعلی';

  @override
  String pollList_headerTitle(Object scopeLabel, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Vote پیدا شد',
      one: '۱ Vote پیدا شد',
      zero: 'هیچ Vote پیدا نشد',
    );
    return '$scopeLabel · $_temp0';
  }

  @override
  String get pollList_createPollButton => 'ایجاد Vote';

  @override
  String get pollList_paginationHint => 'برای بارگذاری Vote‌های بیشتر پیمایش کنید…';

  @override
  String get pollList_emptyMessage => 'در این منطقه Vote‌ای مطابق این فیلتر نیست.';

  @override
  String get pollType_ranked => 'انتخاب رتبه‌بندی‌شده';

  @override
  String get pollType_score => 'رأی‌گیری امتیازی';

  @override
  String get pollVisibility_whileOpen => 'نتایج در زمان بازبودن قابل مشاهده';

  @override
  String get pollVisibility_afterVote => 'نتایج پس از رأی‌دادن قابل مشاهده';

  @override
  String get pollVisibility_afterClose => 'نتایج پس از بسته‌شدن قابل مشاهده';

  @override
  String get pollCard_countryRestricted => 'محدود به کشور';

  @override
  String pollCard_restrictedToCountry(Object countryName) {
    return 'محدود به $countryName';
  }

  @override
  String pollCard_quorumLabel(int minVotes) {
    return 'حداقل نصاب $minVotes';
  }

  @override
  String get pollCard_resultsVisibleChip => 'نتایج قابل مشاهده';

  @override
  String get pollCard_resultsAfterVoteChip => 'پس از رأی';

  @override
  String get pollCard_resultsAfterCloseChip => 'پس از بسته‌شدن';

  @override
  String get pollCard_publicOfficialPublisher => 'مقام عمومی';

  @override
  String get pollCard_institutionPublisher => 'نهاد';

  @override
  String get pollCard_representativePublisher => 'نماینده';

  @override
  String pollCard_voteCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'رأی',
      one: 'رأی',
    );
    return '$_temp0';
  }

  @override
  String get pollCard_viewDetails => 'مشاهده جزئیات';

  @override
  String pollResult_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'نتایج ($count رأی)',
      one: 'نتایج (۱ رأی)',
      zero: 'نتایج (بدون رأی)',
    );
    return '$_temp0';
  }

  @override
  String get voteError_noSelection => 'لطفاً حداقل یک گزینه انتخاب کنید.';

  @override
  String get voteError_unauthorized => 'شما مجاز به رأی‌دادن در این Vote نیستید.';

  @override
  String get voteError_generic => 'ثبت رأی ناموفق بود. لطفاً دوباره تلاش کنید.';

  @override
  String get commentSection_title => 'دیدگاه‌ها';

  @override
  String get commentSection_sortLabel => 'مرتب‌سازی:';

  @override
  String get commentSection_sortOldest => 'قدیمی‌ترین';

  @override
  String get commentSection_sortNewest => 'جدیدترین';

  @override
  String get commentSection_errorGeneric => 'هنگام بارگذاری دیدگاه‌ها خطایی رخ داد.';

  @override
  String get commentSection_empty => 'هنوز دیدگاهی نیست. اولین دیدگاه را شما بنویسید.';

  @override
  String get commentSection_loadMore => 'بارگذاری دیدگاه‌های بیشتر';

  @override
  String commentSection_replyingTo(Object snippet) {
    return 'در پاسخ به: $snippet';
  }

  @override
  String get commentSection_cancelReply => 'لغو';

  @override
  String get commentSection_inputHintRoot => 'افزودن دیدگاه...';

  @override
  String get commentSection_inputHintReply => 'نوشتن پاسخ...';

  @override
  String get commentSection_deleteAction => 'حذف';

  @override
  String get commentSection_replyAction => 'پاسخ';

  @override
  String get commentSection_youBadge => 'شما';

  @override
  String get newsDetail_title => 'جزئیات خبر';

  @override
  String get newsDetail_breakingBadge => 'فوری';

  @override
  String get newsDetail_removeFromFavoritesTooltip => 'حذف از ذخیره‌شده‌ها';

  @override
  String get newsDetail_addToFavoritesTooltip => 'ذخیره';

  @override
  String get newsDetail_bodyFallback => 'متن بیشتری برای این خبر در دسترس نیست.';

  @override
  String get newsDetail_footerMoreContext => 'زمینه و منابع بیشتر به‌زودی اضافه می‌شود.';

  @override
  String get newsFeed_title => 'خبرها';

  @override
  String get newsFeed_scopeWorld => 'جهان';

  @override
  String get newsFeed_scopeCountry => 'کشور';

  @override
  String get newsFeed_scopeCity => 'شهر';

  @override
  String newsFeed_scopeLabel(Object scope) {
    return 'محدوده: $scope';
  }

  @override
  String get newsFeed_scopeGlobalDescription => 'نمایش خبرهای جهانی.';

  @override
  String get newsFeed_scopeCountryDescription => 'نمایش خبرهای این کشور.';

  @override
  String get newsFeed_scopeCityDescription => 'نمایش خبرهای این شهر.';

  @override
  String get newsFeed_emptyTitle => 'خبری برای این منطقه نیست.';

  @override
  String get newsFeed_emptySubtitle => 'برای نوسازی بکشید یا بعداً دوباره تلاش کنید.';

  @override
  String newsFeed_itemsFound(int count) {
    return '$count خبر پیدا شد';
  }

  @override
  String get newsFeed_loadingMoreHint => 'برای بارگذاری خبرهای بیشتر پیمایش کنید…';

  @override
  String get newsFeed_errorTitle => 'بارگذاری خبرها ممکن نیست';

  @override
  String get newsFeed_errorGeneric => 'هنگام بارگذاری خبرها خطای غیرمنتظره‌ای رخ داد.';

  @override
  String get newsFeed_retryButton => 'تلاش دوباره';

  @override
  String get newsCard_headerTitle => 'News';

  @override
  String get newsFeed_errorUnauthorized => 'پیکربندی خبر نامعتبر است (API key).';

  @override
  String get newsFeed_errorRateLimited => 'درخواست‌ها بیش از حد است. لطفاً کمی بعد دوباره تلاش کنید.';

  @override
  String get newsFeed_errorServerUnavailable => 'سرویس خبر موقتاً در دسترس نیست. لطفاً بعداً دوباره تلاش کنید.';

  @override
  String get newsFeed_errorTimeout => 'درخواست بیش از حد طول کشید. دوباره تلاش کنید.';

  @override
  String get newsFeed_errorNetwork => 'اتصالی نیست. اینترنت خود را بررسی کنید و دوباره تلاش کنید.';

  @override
  String get newsFeed_moreTooltip => 'بیشتر';

  @override
  String get newsFeed_actionCopyTitle => 'کپی عنوان';

  @override
  String get newsFeed_actionRefreshFeed => 'نوسازی خوراک';

  @override
  String get newsFeed_copiedTitleToast => 'عنوان کپی شد';

  @override
  String get newsFeed_languageTooltip => 'زبان خبر';

  @override
  String get newsFeed_languageAuto => 'خودکار';

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
  String get newsFeed_languageFa => 'فا';

  @override
  String get newsFeed_languageLimitedHint => 'منابع این زبان محدود است. حالت خودکار را امتحان کنید.';

  @override
  String get newsTopic_all => 'همه';

  @override
  String get newsTopic_world => 'جهان';

  @override
  String get newsTopic_nation => 'کشور';

  @override
  String get newsTopic_business => 'کسب‌وکار';

  @override
  String get newsTopic_technology => 'فناوری';

  @override
  String get newsTopic_science => 'علم';

  @override
  String get newsTopic_health => 'سلامت';

  @override
  String get newsTopic_sports => 'ورزش';

  @override
  String get newsTopic_entertainment => 'سرگرمی';

  @override
  String get newsDetail_openSource => 'باز کردن مقاله منبع';

  @override
  String get newsDetail_openSourceUnavailable => 'باز کردن مقاله منبع ممکن نیست';

  @override
  String get socialFeedTitle => 'Voce';

  @override
  String get socialFeedCreatePostButton => 'ایجاد Voce';

  @override
  String get commonCancelButton => 'لغو';

  @override
  String get commonApplyButton => 'اعمال';

  @override
  String get homeScopeChooseCountry => 'انتخاب کشور';

  @override
  String get homeScopeCountrySearchHint => 'جست‌وجوی کشور یا کد...';

  @override
  String get homeScopeChooseCity => 'انتخاب شهر';

  @override
  String homeScopeCountryWithCode(String code) {
    return 'کشور: $code';
  }

  @override
  String get homeScopeCityFieldLabel => 'شهر';

  @override
  String get homeScopeCityExampleHint => 'نام شهری مثل مرانو را وارد کنید';

  @override
  String get homeScopeCityRequiredError => 'یک شهر وارد کنید.';

  @override
  String get homeScopeCityNotFoundError => 'شهر در کشور انتخاب‌شده پیدا نشد.';

  @override
  String get homeScopeCityVerificationError => 'تأیید شهر ممکن نیست. دوباره تلاش کنید.';

  @override
  String get homeScopeVerifyingButton => 'در حال تأیید...';

  @override
  String get homeMapOpenButton => 'باز کردن نقشه';

  @override
  String get homeHeroHeadline => 'آینده را شکل دهید.\nبا هم.';

  @override
  String get homeHeroPollsAction => 'Vote';

  @override
  String get homeHeroNewsAction => 'خبرها';

  @override
  String get homeHeroCreateAction => 'ایجاد';

  @override
  String get homeHeroExploreAction => 'کاوش';

  @override
  String get homeAccountMenuLabel => 'حساب';

  @override
  String get homeThemeSystemMenuItem => 'نما: سیستم';

  @override
  String get homeThemeLightMenuItem => 'نما: روشن';

  @override
  String get homeThemeDarkMenuItem => 'نما: تیره';

  @override
  String get profileAppLanguageTitle => 'زبان برنامه';

  @override
  String get profileAppLanguageSystem => 'سیستم';

  @override
  String get profileAppLanguageSystemDescription => 'از زبان دستگاه شما استفاده می‌کند';

  @override
  String get profileAppLanguageItalian => 'ایتالیایی';

  @override
  String get profileAppLanguageEnglish => 'انگلیسی';

  @override
  String get homeNotificationsTooltip => 'اعلان‌ها';

  @override
  String get postCard_authorFallback => 'نویسنده';

  @override
  String get postCard_globalLocation => 'جهانی';

  @override
  String get commonSaveButton => 'ذخیره';

  @override
  String get commonDeleteButton => 'حذف';

  @override
  String get contentReport_menuAction => 'گزارش محتوا';

  @override
  String get contentReport_dialogTitle => 'گزارش محتوا';

  @override
  String get contentReport_authenticationRequired => 'برای گزارش محتوا باید وارد شوید';

  @override
  String get contentReport_submittedMessage => 'گزارش ارسال شد';

  @override
  String get contentReport_alreadySubmittedMessage => 'شما قبلاً این محتوا را گزارش کرده‌اید';

  @override
  String get contentReport_submitError => 'ارسال گزارش ممکن نیست';

  @override
  String get contentReport_sendButton => 'ارسال';

  @override
  String get contentReport_reasonSpam => 'هرزنامه';

  @override
  String get contentReport_reasonHarassment => 'آزار یا سوءاستفاده';

  @override
  String get contentReport_reasonHateSpeech => 'نفرت‌پراکنی';

  @override
  String get contentReport_reasonMisinformation => 'اطلاعات نادرست';

  @override
  String get contentReport_reasonViolence => 'خشونت';

  @override
  String get contentReport_reasonOther => 'سایر';

  @override
  String get postDetail_title => 'جزئیات Voce';

  @override
  String get postDetail_favoriteUpdateError => 'به‌روزرسانی موارد ذخیره‌شده ممکن نیست';

  @override
  String get postDetail_shareMessage => 'برای مشاهده این Voce، Social Vote را باز کنید.';

  @override
  String get postDetail_shareError => 'همرسانی Voce ممکن نیست';

  @override
  String get postDetail_editDialogTitle => 'ویرایش Voce';

  @override
  String get postDetail_editTitleFieldLabel => 'عنوان';

  @override
  String get postDetail_editContentFieldLabel => 'محتوا';

  @override
  String get postDetail_editRequiredError => 'عنوان و محتوا الزامی هستند.';

  @override
  String get postDetail_updateSuccess => 'Voce به‌روز شد';

  @override
  String get postDetail_updateError => 'به‌روزرسانی Voce ممکن نیست';

  @override
  String get postDetail_deleteDialogTitle => 'این Voce حذف شود؟';

  @override
  String get postDetail_deleteDialogMessage => 'این عمل قابل بازگشت نیست.';

  @override
  String get postDetail_deleteError => 'حذف Voce ممکن نیست';

  @override
  String get postDetail_editMenuItem => 'ویرایش Voce';

  @override
  String get postDetail_deleteMenuItem => 'حذف Voce';

  @override
  String get postDetail_loadError => 'هنگام بارگذاری Voce خطایی رخ داد.';

  @override
  String get postDetail_notFound => 'Voce پیدا نشد.';

  @override
  String get postDetail_errorTitle => 'خطا';

  @override
  String get postDetail_authorFallback => 'نویسنده';

  @override
  String get postDetail_shareAction => 'همرسانی';

  @override
  String get postDetail_saveAction => 'ذخیره';

  @override
  String get postDetail_addToFavoritesTooltip => 'ذخیره';

  @override
  String get postDetail_removeFromFavoritesTooltip => 'حذف از ذخیره‌شده‌ها';

  @override
  String get newsDetail_favoriteUpdateError => 'به‌روزرسانی موارد ذخیره‌شده ممکن نیست';

  @override
  String get newsDetail_shareMessage => 'برای مشاهده این خبر، Social Vote را باز کنید.';

  @override
  String get newsDetail_shareError => 'همرسانی خبر ممکن نیست';

  @override
  String get newsDetail_shareTooltip => 'همرسانی';

  @override
  String get authLoginPageTitle => 'ورود';

  @override
  String get authLoginHeadline => 'خوش آمدید';

  @override
  String get authEmailLabel => 'ایمیل';

  @override
  String get authPasswordLabel => 'رمز عبور';

  @override
  String get authRememberMeLabel => 'مرا به خاطر بسپار';

  @override
  String get authForgotPasswordAction => 'رمز عبور را فراموش کرده‌اید؟';

  @override
  String get authLoginButton => 'ورود';

  @override
  String get authRegisterPrompt => 'حساب ندارید؟';

  @override
  String get authRegisterAction => 'ثبت‌نام';

  @override
  String get authRegisterPageTitle => 'ثبت‌نام';

  @override
  String get authRegisterHeadline => 'ایجاد حساب';

  @override
  String get authPersonalAccountOwnershipTitle => 'ورود همیشه متعلق به یک شخص است';

  @override
  String get authPersonalAccountOwnershipBody => 'اگر نماینده یک سازمان هستید، ابتدا حساب شخصی خود را بسازید. پس از ورود، می‌توانید درخواست سازمان تأییدشده بدهید و آن را از Workspace مدیریت کنید.';

  @override
  String get authOrganizationPathAction => 'روش کار برای سازمان‌ها';

  @override
  String get authDisplayNameLabel => 'نام عمومی';

  @override
  String get authUsernameLabel => 'نام کاربری';

  @override
  String get authCountryOfResidenceLabel => 'کشور محل اقامت';

  @override
  String get authCityOfResidenceLabel => 'شهر محل اقامت (اختیاری)';

  @override
  String get authConfirmPasswordLabel => 'تکرار رمز عبور';

  @override
  String get authLegalConsentPrefix => 'تأیید می‌کنم حداقل ۱۸ سال دارم. شرایط استفاده را می‌پذیرم و تأیید می‌کنم سیاست حریم خصوصی را خوانده‌ام.';

  @override
  String get authTermsOfServiceAction => 'شرایط استفاده';

  @override
  String get authPrivacyPolicyAction => 'سیاست حریم خصوصی';

  @override
  String get authRegisterButton => 'ثبت‌نام';

  @override
  String get authLoginPrompt => 'از قبل حساب دارید؟';

  @override
  String get authLoginAction => 'ورود';

  @override
  String get authForgotPasswordDialogTitle => 'بازنشانی رمز عبور';

  @override
  String get authForgotPasswordDialogBody => 'ایمیل متصل به حساب خود را وارد کنید. پیوندی برای انتخاب رمز عبور جدید برایتان می‌فرستیم.';

  @override
  String get authForgotPasswordSendButton => 'ارسال پیوند';

  @override
  String get authPasswordResetEmailSent => 'ایمیل بازنشانی رمز عبور ارسال شد. صندوق ورودی خود را بررسی کنید.';

  @override
  String get authResetPasswordPageTitle => 'بازنشانی رمز عبور';

  @override
  String get authResetPasswordHeadline => 'یک رمز عبور جدید انتخاب کنید';

  @override
  String get authNewPasswordLabel => 'رمز عبور جدید';

  @override
  String get authConfirmNewPasswordLabel => 'تکرار رمز عبور جدید';

  @override
  String get authUpdatePasswordButton => 'به‌روزرسانی رمز عبور';

  @override
  String get authPasswordUpdated => 'رمز عبور با موفقیت به‌روز شد.';

  @override
  String get authEmailConfirmationTitle => 'ایمیل خود را بررسی کنید';

  @override
  String get authEmailConfirmationIntro => 'پیوند تأیید را ارسال کردیم به:';

  @override
  String get authEmailConfirmationInstructions => 'برای تأیید نشانی، پیوند درون پیام را باز کنید. سپس به برنامه برگردید و وارد شوید.';

  @override
  String get authBackToLoginButton => 'بازگشت به ورود';

  @override
  String get authUseAnotherEmailButton => 'استفاده از ایمیلی دیگر';

  @override
  String get authEmailRequiredError => 'ایمیل خود را وارد کنید.';

  @override
  String get authEmailInvalidError => 'یک ایمیل معتبر وارد کنید.';

  @override
  String get authPasswordRequiredError => 'رمز عبور خود را وارد کنید.';

  @override
  String get authPasswordTooShortError => 'رمز عبور باید حداقل ۸ نویسه باشد.';

  @override
  String get authDisplayNameRequiredError => 'نام عمومی خود را وارد کنید.';

  @override
  String get authDisplayNameTooShortError => 'نام عمومی بیش از حد کوتاه است.';

  @override
  String get authUsernameRequiredError => 'یک نام کاربری وارد کنید.';

  @override
  String get authUsernameInvalidError => 'از ۳ تا ۲۰ نویسه شامل حروف کوچک، اعداد و زیرخط استفاده کنید.';

  @override
  String get authUsernameAlreadyTakenError => 'این نام کاربری قبلاً استفاده شده است.';

  @override
  String get authCountryRequiredError => 'کشور محل اقامت خود را انتخاب کنید.';

  @override
  String get authCityRequiredError => 'شهر محل اقامت خود را وارد کنید.';

  @override
  String get authConfirmPasswordRequiredError => 'رمز عبور خود را تکرار کنید.';

  @override
  String get authPasswordsDoNotMatchError => 'رمزهای عبور یکسان نیستند.';

  @override
  String get authLegalConsentRequiredError => 'برای ثبت‌نام، داشتن حداقل ۱۸ سال، پذیرش شرایط استفاده و مطالعه سیاست حریم خصوصی را تأیید کنید.';

  @override
  String get authForgotPasswordEmailRequiredError => 'ایمیل حسابی را که می‌خواهید بازیابی کنید وارد کنید.';

  @override
  String get authInvalidCredentialsError => 'ایمیل یا رمز عبور معتبر نیست.';

  @override
  String get authEmailAlreadyRegisteredError => 'این ایمیل قبلاً ثبت شده است.';

  @override
  String get authEmailNotConfirmedError => 'ایمیل تأیید نشده است. پیش از ورود، صندوق ورودی خود را بررسی کنید.';

  @override
  String get authTooManyAttemptsError => 'تعداد تلاش‌ها بیش از حد است. چند دقیقه صبر کنید و دوباره تلاش کنید.';

  @override
  String get authNetworkError => 'خطای شبکه. اتصال خود را بررسی کنید و دوباره تلاش کنید.';

  @override
  String get authLoginGenericError => 'ورود ناموفق بود. دوباره تلاش کنید.';

  @override
  String get authRegisterGenericError => 'ثبت‌نام ناموفق بود. دوباره تلاش کنید.';

  @override
  String get authPasswordResetGenericError => 'ارسال پیوند بازنشانی ممکن نیست. دوباره تلاش کنید.';

  @override
  String get authPasswordUpdateGenericError => 'به‌روزرسانی رمز عبور ممکن نیست. دوباره تلاش کنید.';

  @override
  String get authShowPasswordTooltip => 'نمایش رمز عبور';

  @override
  String get authHidePasswordTooltip => 'پنهان کردن رمز عبور';

  @override
  String get authTermsPageTitle => 'شرایط استفاده';

  @override
  String get authPrivacyPageTitle => 'سیاست حریم خصوصی';

  @override
  String get authCloseButton => 'بستن';

  @override
  String get pollDetail_favoriteUpdateError => 'به‌روزرسانی موارد ذخیره‌شده ممکن نیست';

  @override
  String get pollDetail_shareMessage => 'برای مشاهده و رأی‌دادن در این Vote، Social Vote را باز کنید.';

  @override
  String get pollDetail_shareError => 'همرسانی Vote ممکن نیست';

  @override
  String get pollDetail_editPermissionError => 'فقط Vote خودتان را، آن هم در صورتی که هیچ رأیی ثبت نشده باشد، می‌توانید ویرایش کنید';

  @override
  String get pollDetail_editSuccessMessage => 'Vote به‌روز شد';

  @override
  String get pollDetail_editMenuItem => 'ویرایش Vote';

  @override
  String get pollDetail_editSavingMenuItem => 'در حال ذخیره...';

  @override
  String get pollDetail_deletePermissionError => 'فقط Vote خودتان را می‌توانید حذف کنید';

  @override
  String get pollDetail_deleteError => 'حذف Vote ممکن نیست';

  @override
  String get pollDetail_deleteDialogTitle => 'حذف Vote';

  @override
  String pollDetail_deleteDialogMessage(String title) {
    return 'آیا واقعاً می‌خواهید «$title» را حذف کنید؟ این عمل قابل بازگشت نیست.';
  }

  @override
  String get pollDetail_deleteMenuItem => 'حذف Vote';

  @override
  String get pollDetail_deleteDeletingMenuItem => 'در حال حذف...';

  @override
  String get pollDetail_publicVotesAvailableTitle => 'رأی‌های عمومی در دسترس';

  @override
  String get pollDetail_publicVotesAvailableMessage => 'این Vote به شما اجازه می‌دهد ببینید چه کسی به هر گزینه رأی داده است.';

  @override
  String get pollDetail_publicVotesAction => 'مشاهده رأی‌های عمومی';

  @override
  String get pollDetail_retryButton => 'تلاش دوباره';

  @override
  String get pollDetail_voteErrorNoOption => 'حداقل یک گزینه انتخاب کنید';

  @override
  String get pollDetail_voteErrorAuthenticationRequired => 'برای رأی‌دادن باید وارد شوید';

  @override
  String get pollDetail_voteErrorClosed => 'این Vote بسته شده است';

  @override
  String get pollDetail_voteErrorAlreadyVoted => 'شما قبلاً در این Vote رأی داده‌اید';

  @override
  String get pollDetail_voteErrorGeneric => 'ثبت رأی ممکن نیست';

  @override
  String get pollDetail_publicVotesSheetTitle => 'رأی‌های عمومی';

  @override
  String get pollDetail_publicVotesSheetDescription => 'در اینجا می‌توانید ببینید چه کسی به هر گزینه در این Vote رأی داده است.';

  @override
  String get pollDetail_publicVotesSearchHint => 'جست‌وجوی کاربران';

  @override
  String get pollDetail_publicVotesLoadError => 'بارگذاری رأی‌های عمومی ممکن نیست';

  @override
  String get pollDetail_publicVotesEmpty => 'رأی عمومی در دسترس نیست';

  @override
  String get pollDetail_publicVotesSearchEmpty => 'کاربری برای این جست‌وجو پیدا نشد';

  @override
  String pollDetail_publicVotesResultsCount(int count) {
    return '$count نتیجه بارگذاری شد';
  }

  @override
  String get pollDetail_publicVotesLoadMore => 'بارگذاری بیشتر';

  @override
  String get pollDetail_publicVotesUserFallback => 'کاربر';

  @override
  String get pollDetail_editDialogTitle => 'ویرایش Vote';

  @override
  String get pollDetail_editTitleFieldLabel => 'عنوان';

  @override
  String get pollDetail_editTitleRequired => 'عنوان الزامی است';

  @override
  String get pollDetail_editDescriptionFieldLabel => 'توضیحات';

  @override
  String get pollDetail_editError => 'به‌روزرسانی Vote ممکن نیست';

  @override
  String get pollDetail_loadError => 'بارگذاری Vote ممکن نیست';

  @override
  String get pollDetail_notFound => 'Vote پیدا نشد';

  @override
  String get profileEditPageTitle => 'ویرایش پروفایل';

  @override
  String get profileLoginRequiredMessage => 'برای ویرایش پروفایل باید وارد شوید.';

  @override
  String get profileAvatarUploading => 'در حال بارگذاری...';

  @override
  String get profileUploadAvatarButton => 'بارگذاری آواتار';

  @override
  String get profileDisplayNameLabel => 'نام نمایشی';

  @override
  String get profileDisplayNameRequiredError => 'نام نمایشی الزامی است.';

  @override
  String get profileUsernameHint => 'مثلاً mario_roma';

  @override
  String get profileUsernameHelper => '۳ تا ۲۰ نویسه: حروف کوچک، اعداد و زیرخط';

  @override
  String get profileAvatarUrlLabel => 'نشانی آواتار';

  @override
  String get profileBioLabel => 'درباره';

  @override
  String get profileClearCountryButton => 'پاک کردن کشور';

  @override
  String get profileCityResidenceHelper => 'پیش از ذخیره، شهر محل اقامت با کشور انتخاب‌شده بررسی می‌شود.';

  @override
  String get profileCityNotFoundError => 'شهر در کشور انتخاب‌شده پیدا نشد.';

  @override
  String get profileCityVerificationError => 'در حال حاضر تأیید شهر ممکن نیست.';

  @override
  String get profileAvatarUploadError => 'بارگذاری آواتار ممکن نیست.';

  @override
  String get profileAccountSectionTitle => 'حساب';

  @override
  String get profileAccountEmailHelper => 'ایمیل حساب از این صفحه قابل تغییر نیست.';

  @override
  String get profileChangePasswordAction => 'تغییر رمز عبور';

  @override
  String get profileChangePasswordDescription => 'یک رمز عبور جدید برای این حساب تنظیم کنید.';

  @override
  String get notificationsPageTitle => 'اعلان‌ها';

  @override
  String get notificationsMarkAllReadAction => 'علامت‌گذاری همه به‌عنوان خوانده‌شده';

  @override
  String get notificationsNoTargetMessage => 'این اعلان مقصد قابل دسترسی ندارد.';

  @override
  String get notificationsTargetUnavailableMessage => 'محتوای مرتبط با این اعلان در دسترس نیست.';

  @override
  String get notificationsLoadError => 'بارگذاری اعلان‌ها ممکن نیست.';

  @override
  String get notificationsRetryButton => 'تلاش دوباره';

  @override
  String get notificationsEmptyMessage => 'اعلانی در دسترس نیست.';

  @override
  String get notificationsCommentReplyTitle => 'پاسخ جدید به دیدگاه شما';

  @override
  String get notificationsMentionTitle => 'از شما نام برده شد';

  @override
  String get notificationsPollResultTitle => 'به‌روزرسانی Vote';

  @override
  String notificationsCommentReplySubtitle(String actor, String target) {
    return 'کاربر $actor در $target پاسخ داد';
  }

  @override
  String notificationsMentionSubtitle(String actor, String target) {
    return 'کاربر $actor در $target از شما نام برد';
  }

  @override
  String notificationsPollResultSubtitle(String target) {
    return 'یک نتیجه جدید در $target موجود است';
  }

  @override
  String get notificationsTargetPost => 'یک Voce';

  @override
  String get notificationsTargetNews => 'یک مقاله خبری';

  @override
  String get notificationsTargetPoll => 'یک Vote';

  @override
  String get notificationsTargetVideo => 'یک ویدیو';

  @override
  String get notificationsTargetContent => 'یک محتوا';

  @override
  String get notificationsUserFallback => 'کاربر';

  @override
  String get profileDeleteAccountAction => 'حذف حساب';

  @override
  String get profileDeleteAccountDescription => 'حذف دائمی حساب و دسترسی';

  @override
  String get profileDeleteAccountDialogTitle => 'حذف حساب';

  @override
  String get profileDeleteAccountDialogMessage => 'این عمل دائمی است و حساب قابل بازیابی نیست. برای تأیید، DELETE را بنویسید.';

  @override
  String get profileDeleteAccountConfirmationLabel => 'تأیید حذف';

  @override
  String get profileDeleteAccountConfirmationHint => 'DELETE را بنویسید';

  @override
  String get profileDeleteAccountConfirmationError => 'برای ادامه DELETE را بنویسید.';

  @override
  String get profileDeleteAccountCancelButton => 'لغو';

  @override
  String get profileDeleteAccountConfirmButton => 'حذف دائمی';

  @override
  String get profileDeleteAccountFailureMessage => 'حذف حساب ممکن نیست. دوباره تلاش کنید.';

  @override
  String get identityActorTypePerson => 'شخص';

  @override
  String get identityActorTypePublicOfficial => 'مقام عمومی';

  @override
  String get identityActorTypePublicInstitution => 'نهاد عمومی';

  @override
  String get identityActorTypeVerifiedOrganization => 'سازمان تأییدشده';

  @override
  String get identityVerificationNotVerified => 'تأییدنشده';

  @override
  String get identityVerificationLevel1 => 'هویت تأییدشده';

  @override
  String get identityVerificationLevel2 => 'هویت تأییدشده پیشرفته';

  @override
  String get identityBadgeLevel1 => 'هویت تأییدشده';

  @override
  String get identityBadgeLevel2 => 'هویت تأییدشده پیشرفته';

  @override
  String get identityBadgePublicOfficial => 'مقام عمومی';

  @override
  String get identityBadgePublicInstitution => 'نهاد عمومی';

  @override
  String get identityBadgeVerifiedOrganization => 'سازمان تأییدشده';

  @override
  String get identityOrganizationNameLabel => 'نام سازمان';

  @override
  String get identityOrganizationNameRequired => 'نام سازمان را وارد کنید.';

  @override
  String get identityInstitutionLevelMunicipality => 'شهرداری';

  @override
  String get identityInstitutionLevelProvince => 'استانی';

  @override
  String get identityInstitutionLevelRegion => 'منطقه‌ای';

  @override
  String get identityInstitutionLevelMinistry => 'وزارتخانه';

  @override
  String get identityInstitutionLevelGovernment => 'دولت';

  @override
  String get identityInstitutionLevelPublicAgency => 'سازمان عمومی';

  @override
  String get identityInstitutionLevelOtherPublicBody => 'سایر نهادهای عمومی';

  @override
  String get verificationRequestPersonLevel1 => 'تأیید شخص — سطح ۱';

  @override
  String get verificationRequestPersonLevel2 => 'تأیید شخص — سطح ۲';

  @override
  String get verificationRequestPublicOfficial => 'تأیید مقام عمومی';

  @override
  String get verificationRequestPublicInstitution => 'تأیید نهاد عمومی';

  @override
  String get verificationRequestVerifiedOrganization => 'تأیید سازمان';

  @override
  String get verificationCenterTitle => 'تأیید و نوع حساب';

  @override
  String get verificationCurrentAccountSection => 'حساب فعلی';

  @override
  String verificationAccountTypeValue(String accountType) {
    return 'نوع حساب: $accountType';
  }

  @override
  String verificationLevelValue(String level) {
    return 'سطح تأیید: $level';
  }

  @override
  String verificationOfficialTitleValue(String title) {
    return 'عنوان رسمی: $title';
  }

  @override
  String verificationInstitutionNameValue(String name) {
    return 'نهاد: $name';
  }

  @override
  String verificationOrganizationNameValue(String name) {
    return 'سازمان: $name';
  }

  @override
  String verificationInstitutionLevelValue(String level) {
    return 'سطح نهاد: $level';
  }

  @override
  String get verificationActiveRequestSection => 'درخواست فعال';

  @override
  String get verificationProfileUnchangedUntilApproval => 'پروفایل فعلی شما تا زمان تأیید درخواست تغییر نمی‌کند.';

  @override
  String get verificationCancelPendingAction => 'لغو درخواست در انتظار';

  @override
  String get verificationPendingBlocksNewRequests => 'تا زمانی که درخواستی در انتظار است، نمی‌توانید درخواست جدیدی ارسال کنید.';

  @override
  String get verificationNoActiveRequestSection => 'بدون درخواست فعال';

  @override
  String get verificationNoActiveRequestDescription => 'در حال حاضر درخواستی در حال بررسی ندارید.';

  @override
  String get verificationLastRejectedSection => 'آخرین درخواست ردشده';

  @override
  String get verificationLastRejectedDescription => 'آخرین درخواست شما رد شد.';

  @override
  String get verificationRejectedCanResubmit => 'پروفایل فعلی شما تغییر نکرده است. می‌توانید اطلاعات را اصلاح کرده و درخواست جدیدی بفرستید.';

  @override
  String get verificationAvailableRequestsSection => 'درخواست‌های موجود';

  @override
  String get verificationRequestLevel1Title => 'درخواست تأیید شخص — سطح ۱';

  @override
  String get verificationRequestLevel1Subtitle => 'تأیید پایه هویت شخصی';

  @override
  String get verificationRequestLevel2Title => 'درخواست تأیید شخص — سطح ۲';

  @override
  String get verificationRequestLevel2Subtitle => 'تأیید پیشرفته هویت شخصی';

  @override
  String get verificationRequestPublicOfficialTitle => 'درخواست حساب مقام عمومی';

  @override
  String get verificationRequestPublicOfficialSubtitle => 'نیازمند عنوان رسمی و بررسی';

  @override
  String get verificationRequestPublicInstitutionTitle => 'درخواست حساب نهاد عمومی';

  @override
  String get verificationRequestPublicInstitutionSubtitle => 'نیازمند نام نهاد، سطح نهاد و بررسی';

  @override
  String get verificationRequestOrganizationTitle => 'درخواست حساب سازمان تأییدشده';

  @override
  String get verificationRequestOrganizationSubtitle => 'نیازمند جزئیات سازمان، نقش نماینده و بررسی Admin';

  @override
  String get verificationNoSelfServiceUpgrade => 'برای وضعیت فعلی حساب شما گزینه تأییدی موجود نیست.';

  @override
  String get verificationRequestSubmitSuccess => 'درخواست با موفقیت ارسال شد.';

  @override
  String get verificationRequestSubmitFailure => 'ارسال درخواست ممکن نیست.';

  @override
  String get verificationOfficialTitleDialogTitle => 'تأیید مقام عمومی';

  @override
  String get verificationOfficialTitleLabel => 'عنوان رسمی';

  @override
  String get verificationOfficialTitleHint => 'مثلاً شهردار، عضو شورا، وزیر';

  @override
  String get verificationInstitutionDialogTitle => 'تأیید نهاد عمومی';

  @override
  String get verificationInstitutionNameLabel => 'نام نهاد';

  @override
  String get verificationInstitutionNameHint => 'مثلاً شهرداری رم';

  @override
  String get verificationInstitutionLevelLabel => 'سطح نهاد';

  @override
  String get verificationOrganizationDialogTitle => 'تأیید سازمان';

  @override
  String get verificationOrganizationNameHint => 'مثلاً انجمن محیط زیست ایتالیا';

  @override
  String get verificationSubmitRequestAction => 'ارسال درخواست';

  @override
  String get verificationCancelDialogTitle => 'لغو درخواست';

  @override
  String get verificationCancelDialogBody => 'آیا مطمئنید می‌خواهید درخواست تأیید در انتظار را لغو کنید؟';

  @override
  String get verificationCancelSuccess => 'درخواست لغو شد.';

  @override
  String get verificationCancelFailure => 'لغو درخواست ممکن نیست.';

  @override
  String get verificationStatusPendingSuffix => 'درخواست در حال بررسی';

  @override
  String get verificationStatusRejectedSuffix => 'آخرین درخواست رد شده';

  @override
  String get verificationReviewPageTitle => 'بررسی تأیید';

  @override
  String get verificationReviewLoginRequired => 'برای بررسی درخواست‌های تأیید باید وارد شوید.';

  @override
  String verificationReviewPendingCount(int count) {
    return 'درخواست‌های در انتظار: $count';
  }

  @override
  String get verificationReviewNoPendingRequests => 'درخواست تأییدی در انتظار نیست.';

  @override
  String get verificationReviewUserIdLabel => 'شناسه کاربر';

  @override
  String get verificationReviewSubmittedLabel => 'ارسال‌شده';

  @override
  String get verificationReviewOfficialTitleLabel => 'عنوان رسمی';

  @override
  String get verificationReviewInstitutionLabel => 'نهاد';

  @override
  String get verificationReviewOrganizationLabel => 'سازمان';

  @override
  String get verificationReviewNoteLabel => 'یادداشت بررسی';

  @override
  String get verificationReviewRejectAction => 'رد';

  @override
  String get verificationReviewApproveAction => 'تأیید';

  @override
  String get verificationReviewApproveDialogTitle => 'تأیید درخواست';

  @override
  String get verificationReviewRejectDialogTitle => 'رد درخواست';

  @override
  String get verificationReviewApproveConfirmation => 'تأیید این درخواست را تأیید می‌کنید؟';

  @override
  String get verificationReviewRejectConfirmation => 'رد این درخواست را تأیید می‌کنید؟';

  @override
  String get verificationReviewOptionalNoteLabel => 'یادداشت اختیاری بررسی';

  @override
  String get verificationReviewRequiredNoteLabel => 'دلیل رد';

  @override
  String get verificationReviewOptionalHelper => 'اختیاری';

  @override
  String get verificationReviewRequiredHelper => 'هنگام رد الزامی است';

  @override
  String get verificationReviewRequiredNoteError => 'دلیل رد را وارد کنید.';

  @override
  String get verificationReviewApprovedSuccess => 'درخواست تأیید شد.';

  @override
  String get verificationReviewRejectedSuccess => 'درخواست رد شد.';

  @override
  String get verificationReviewOperationFailure => 'عملیات ناموفق بود.';

  @override
  String get adminCenterTitle => 'مرکز Admin';

  @override
  String get adminCenterDashboardNavigation => 'داشبورد';

  @override
  String get adminCenterUsersNavigation => 'کاربران';

  @override
  String get adminCenterVerificationNavigation => 'تأیید';

  @override
  String get adminCenterReportsNavigation => 'گزارش‌ها';

  @override
  String get adminCenterAuditNavigation => 'حسابرسی';

  @override
  String get adminCenterAccountDetailsTitle => 'جزئیات حساب';

  @override
  String get adminCenterTryAgainAction => 'تلاش دوباره';

  @override
  String get adminCenterRetryAction => 'تلاش مجدد';

  @override
  String get adminCenterClearAction => 'پاک کردن';

  @override
  String get adminCenterApplyFiltersAction => 'اعمال فیلترها';

  @override
  String get adminCenterAllDates => 'همه تاریخ‌ها';

  @override
  String get adminCenterAuditDateFilterHelp => 'فیلتر حسابرسی بر اساس تاریخ';

  @override
  String get adminCenterActorUserIdLabel => 'شناسه کاربر انجام‌دهنده';

  @override
  String get adminCenterActionLabel => 'عمل';

  @override
  String get adminCenterAuditActionHint => 'resolve_escalated_report';

  @override
  String get adminCenterTargetIdLabel => 'شناسه هدف';

  @override
  String get adminCenterOutcomeLabel => 'نتیجه';

  @override
  String get adminCenterAllOutcomes => 'همه نتایج';

  @override
  String get adminCenterOutcomeSuccess => 'موفق';

  @override
  String get adminCenterOutcomeFailure => 'ناموفق';

  @override
  String get adminCenterOutcomeDenied => 'ردشده';

  @override
  String get adminCenterOutcomeNoChange => 'بدون تغییر';

  @override
  String get adminCenterOutcomeUnknown => 'ناشناخته';

  @override
  String get adminCenterAuditUnavailableTitle => 'حسابرسی در دسترس نیست';

  @override
  String get adminCenterAuditUnavailableMessage => 'اتصال و مجوزهای خود را بررسی کنید و دوباره تلاش کنید.';

  @override
  String get adminCenterNoAuditEntriesTitle => 'هیچ رکورد حسابرسی نیست';

  @override
  String get adminCenterNoAuditEntriesMessage => 'رکوردی مطابق فیلترهای انتخاب‌شده نیست.';

  @override
  String get adminCenterAuditIdLabel => 'شناسه حسابرسی';

  @override
  String get adminCenterActorLabel => 'انجام‌دهنده';

  @override
  String get adminCenterReasonLabel => 'دلیل';

  @override
  String get adminCenterTimestampLabel => 'زمان';

  @override
  String get adminCenterErrorLabel => 'خطا';

  @override
  String get adminCenterRecordedValuesTitle => 'مقادیر ثبت‌شده';

  @override
  String get adminCenterPreviousValueLabel => 'مقدار قبلی';

  @override
  String get adminCenterNewValueLabel => 'مقدار جدید';

  @override
  String get adminCenterContentTypeLabel => 'نوع محتوا';

  @override
  String get adminCenterAllContent => 'همه محتوا';

  @override
  String get adminCenterPolls => 'Vote';

  @override
  String get adminCenterPosts => 'Voce';

  @override
  String get adminCenterNews => 'News';

  @override
  String get adminCenterAwaitingAdminDecision => 'در انتظار تصمیم Admin';

  @override
  String get adminCenterStatusLabel => 'وضعیت';

  @override
  String get adminCenterAllStatuses => 'همه وضعیت‌ها';

  @override
  String get adminCenterStatusOpen => 'باز';

  @override
  String get adminCenterStatusInReview => 'در حال بررسی';

  @override
  String get adminCenterStatusResolved => 'حل‌شده';

  @override
  String get adminCenterStatusDismissed => 'ردشده';

  @override
  String get adminCenterAdminQueueUnavailableTitle => 'صف ارجاع Admin در دسترس نیست';

  @override
  String get adminCenterReportsUnavailableTitle => 'گزارش‌ها در دسترس نیست';

  @override
  String get adminCenterConnectionTryAgainMessage => 'اتصال خود را بررسی کنید و دوباره تلاش کنید.';

  @override
  String get adminCenterNoAdminReportsTitle => 'گزارشی در انتظار تصمیم Admin نیست';

  @override
  String get adminCenterNoReportsTitle => 'گزارشی نیست';

  @override
  String get adminCenterNoAdminReportsMessage => 'گزارش ارجاع‌شده‌ای که نیاز به بررسی مدیر داشته باشد وجود ندارد.';

  @override
  String get adminCenterNoReportsMessage => 'گزارشی مطابق فیلترهای انتخاب‌شده نیست.';

  @override
  String get adminCenterSearchUsersHint => 'جست‌وجو بر اساس نام، نام کاربری، ایمیل یا شناسه';

  @override
  String get adminCenterClearSearchTooltip => 'پاک کردن جست‌وجو';

  @override
  String get adminCenterUsersUnavailableTitle => 'کاربران در دسترس نیستند';

  @override
  String get adminCenterNoUsersFoundTitle => 'کاربری پیدا نشد';

  @override
  String get adminCenterNoUsersTitle => 'کاربری نیست';

  @override
  String get adminCenterNoUsersFoundMessage => 'نام، نام کاربری، ایمیل یا شناسه دیگری را امتحان کنید.';

  @override
  String get adminCenterNoUsersMessage => 'حسابی برای نمایش نیست.';

  @override
  String get adminCenterAccountUnavailableTitle => 'حساب در دسترس نیست';

  @override
  String get adminCenterBackToUsersAction => 'بازگشت به کاربران';

  @override
  String get adminCenterPublicIdentitySection => 'هویت عمومی';

  @override
  String get adminCenterDisplayNameLabel => 'نام نمایشی';

  @override
  String get adminCenterNotProvided => 'ارائه نشده';

  @override
  String get adminCenterUsernameLabel => 'نام کاربری';

  @override
  String get adminCenterUserIdLabel => 'شناسه کاربر';

  @override
  String get adminCenterIdentityTypeLabel => 'نوع هویت';

  @override
  String get adminCenterAccountSection => 'حساب';

  @override
  String get adminCenterTechnicalRoleLabel => 'نقش فنی';

  @override
  String get adminCenterRoleMirrorLabel => 'آینه نقش پروفایل';

  @override
  String get adminCenterRoleSynchronizationLabel => 'همگام‌سازی نقش';

  @override
  String get adminCenterSynchronized => 'همگام‌شده';

  @override
  String get adminCenterNotSynchronized => 'همگام‌نشده';

  @override
  String get adminCenterRoleNotSynchronized => 'نقش همگام نیست';

  @override
  String get adminCenterAccountStatusLabel => 'وضعیت حساب';

  @override
  String get adminCenterSuspendedUntilLabel => 'تعلیق تا';

  @override
  String get adminCenterAccountManagementSection => 'مدیریت حساب';

  @override
  String get adminCenterDangerZoneSection => 'ناحیه خطر';

  @override
  String get adminCenterRoleManagementSection => 'مدیریت نقش';

  @override
  String get adminCenterVerificationLevelLabel => 'سطح تأیید';

  @override
  String get adminCenterVerificationStatusLabel => 'وضعیت تأیید';

  @override
  String get adminCenterAccessInformationSection => 'اطلاعات دسترسی';

  @override
  String get adminCenterEmailLabel => 'ایمیل';

  @override
  String get adminCenterNotAvailable => 'در دسترس نیست';

  @override
  String get adminCenterEmailConfirmationLabel => 'تأیید ایمیل';

  @override
  String get adminCenterNotConfirmed => 'تأییدنشده';

  @override
  String get adminCenterRegisteredLabel => 'ثبت‌نام‌شده';

  @override
  String get adminCenterLastAccessLabel => 'آخرین دسترسی';

  @override
  String get adminCenterLoadingDashboardTitle => 'در حال بارگذاری داشبورد';

  @override
  String get adminCenterLoadingDashboardMessage => 'در حال دریافت آخرین شاخص‌ها.';

  @override
  String get adminCenterDashboardUnavailableTitle => 'داشبورد در دسترس نیست';

  @override
  String get adminCenterIndicatorsUnavailableMessage => 'بارگذاری شاخص‌ها ممکن نشد.';

  @override
  String get adminCenterVerificationPendingIndicator => 'تأییدهای در انتظار';

  @override
  String get adminCenterOpenReportsIndicator => 'گزارش‌های باز';

  @override
  String get adminCenterSuspendedAccountsIndicator => 'حساب‌های تعلیق‌شده';

  @override
  String get adminCenterStaffIndicator => 'کارکنان';

  @override
  String get adminCenterNoPendingWorkTitle => 'کاری در انتظار نیست';

  @override
  String get adminCenterNoPendingWorkMessage => 'بخش‌های تأیید، گزارش‌ها و حساب‌های تعلیق‌شده خالی هستند.';

  @override
  String get adminCenterCouldNotUpdateUsers => 'به‌روزرسانی فهرست کاربران ممکن نشد.';

  @override
  String get adminCenterCouldNotUpdateReports => 'به‌روزرسانی صف گزارش‌ها ممکن نشد.';

  @override
  String get adminCenterUnnamedUser => 'کاربر بدون نام';

  @override
  String get adminCenterTemporarySuspensionTitle => 'تعلیق موقت';

  @override
  String get adminCenterReactivateDescription => 'تعلیق را فوراً بردارید و اجازه ورود جدید بدهید.';

  @override
  String get adminCenterSuspendDescription => 'دسترسی را برای مدتی محدود مسدود کنید و همه نشست‌های فعلی را پایان دهید.';

  @override
  String get adminCenterSuspensionUnavailableDescription => 'تعلیق نیازمند حسابی همگام‌شده و غیر Admin است.';

  @override
  String get adminCenterReactivateAccountAction => 'فعال‌سازی دوباره حساب';

  @override
  String get adminCenterSuspendAccountAction => 'تعلیق حساب';

  @override
  String get adminCenterForceLogoutAction => 'اجبار به خروج';

  @override
  String get adminCenterSuspendedForceLogoutDescription => 'تعلیق، نشست‌های فعلی را قبلاً پایان داده است. پیش از آزمایش خروج جداگانه، حساب را دوباره فعال کنید.';

  @override
  String get adminCenterForceLogoutDescription => 'همه نشست‌های فعلی را بدون تعلیق حساب پایان دهید.';

  @override
  String get adminCenterForceLogoutUnavailableDescription => 'خروج اجباری نیازمند حسابی همگام‌شده و غیر Admin است.';

  @override
  String get adminCenterPermanentDeletionTitle => 'حذف دائمی حساب';

  @override
  String get adminCenterPermanentDeletionDescription => 'داده‌های احراز هویت را حذف، همه نشست‌ها را پایان و رکورد عمومی نگهداری‌شده را ناشناس کنید.';

  @override
  String get adminCenterDeletionUnavailableDescription => 'حذف نیازمند حسابی همگام‌شده و غیر Admin است.';

  @override
  String get adminCenterDeleteAccountPermanentlyAction => 'حذف دائمی حساب';

  @override
  String get adminCenterDurationOneHour => '۱ ساعت';

  @override
  String get adminCenterDurationOneDay => '۲۴ ساعت';

  @override
  String get adminCenterDurationSevenDays => '۷ روز';

  @override
  String get adminCenterDurationThirtyDays => '۳۰ روز';

  @override
  String get adminCenterSuspendImmediateEffect => 'حساب فوراً دسترسی را از دست می‌دهد و همه نشست‌های فعلی پایان می‌یابند.';

  @override
  String get adminCenterDurationLabel => 'مدت';

  @override
  String get adminCenterSuspendReasonHint => 'توضیح دهید چرا این حساب باید تعلیق شود';

  @override
  String get adminCenterReactivateReasonHint => 'توضیح دهید چرا این حساب می‌تواند دوباره فعال شود';

  @override
  String get adminCenterReactivateConfirmation => 'تأیید می‌کنم که این حساب می‌تواند دوباره دسترسی پیدا کند.';

  @override
  String get adminCenterReactivateFailure => 'فعال‌سازی دوباره حساب ممکن نشد. نقش و وضعیت آن را بررسی کنید و دوباره تلاش کنید.';

  @override
  String get adminCenterReactivateSuccess => 'حساب دوباره فعال شد. اکنون ورود جدید مجاز است.';

  @override
  String get adminCenterForceLogoutFullDescription => 'همه نشست‌های فعلی این حساب را پایان دهید. حساب فعال می‌ماند و می‌تواند دوباره وارد شود.';

  @override
  String get adminCenterForceLogoutReasonHint => 'توضیح دهید چرا نشست‌های فعلی باید پایان یابند';

  @override
  String get adminCenterForceLogoutConfirmation => 'پایان فوری همه نشست‌های فعلی این حساب را تأیید می‌کنم.';

  @override
  String get adminCenterForceLogoutFailure => 'خروج حساب ممکن نشد. نقش و وضعیت آن را بررسی کنید و دوباره تلاش کنید.';

  @override
  String get adminCenterForceLogoutSuccess => 'نشست‌های فعلی پایان یافتند. حساب می‌تواند دوباره وارد شود.';

  @override
  String get adminCenterSuspendFailure => 'تعلیق حساب ممکن نشد. نقش و وضعیت آن را بررسی کنید و دوباره تلاش کنید.';

  @override
  String get adminCenterDeleteReasonHint => 'توضیح دهید چرا این حساب باید حذف شود';

  @override
  String get adminCenterTypeDeleteLabel => 'DELETE را بنویسید';

  @override
  String get adminCenterTypeAccountIdLabel => 'شناسه کامل حساب را بنویسید';

  @override
  String get adminCenterDeletePermanentlyAction => 'حذف دائمی';

  @override
  String get adminCenterDeleteIrreversibleWarning => 'این عمل برگشت‌ناپذیر است. داده‌های احراز هویت و نشست‌های فعلی حذف، آواتار پاک و رکورد عمومی نگهداری‌شده ناشناس می‌شود. رکورد حسابرسی باقی می‌ماند.';

  @override
  String get adminCenterDeleteFailure => 'حذف حساب ممکن نشد. نقش، وضعیت و مقادیر تأیید را بررسی کنید و دوباره تلاش کنید.';

  @override
  String get adminCenterDeleteSuccess => 'حساب به‌طور دائمی حذف و داده‌های شخصی ناشناس شدند.';

  @override
  String get adminCenterChangeTechnicalRoleTitle => 'تغییر نقش فنی';

  @override
  String get adminCenterChangeRoleDescription => 'پیش از تأیید، نقش فعلی و درخواستی را بررسی کنید.';

  @override
  String get adminCenterChangeRoleUnavailableDescription => 'تغییر نقش نیازمند حسابی همگام‌شده و حذف‌نشده است.';

  @override
  String get adminCenterChangeRoleAction => 'تغییر نقش';

  @override
  String get adminCenterChangePublicIdentityTitle => 'تغییر هویت عمومی';

  @override
  String get adminCenterChangeIdentityDescription => 'نوع حساب عمومی و سطح تأیید را به‌روز کنید.';

  @override
  String get adminCenterChangeIdentityUnavailableDescription => 'تغییر هویت نیازمند حسابی همگام‌شده و غیر Admin است.';

  @override
  String get adminCenterChangeIdentityAction => 'تغییر هویت';

  @override
  String get adminCenterChoosePublicIdentityMessage => 'نوع حساب عمومی و وضعیت تأیید آن را انتخاب کنید.';

  @override
  String get adminCenterPublicAccountTypeLabel => 'نوع حساب عمومی';

  @override
  String get adminCenterPersonVerificationHelper => 'سطح ۱ و سطح ۲ فقط برای شخص در دسترس هستند.';

  @override
  String get adminCenterNonPersonVerificationHelper => 'حساب‌های غیرشخصی از سطح ۱ یا ۲ استفاده نمی‌کنند.';

  @override
  String get adminCenterBeforeLabel => 'پیش از';

  @override
  String get adminCenterAfterLabel => 'پس از';

  @override
  String get adminCenterIdentityReasonHint => 'توضیح دهید چرا هویت عمومی باید تغییر کند';

  @override
  String get adminCenterIdentityConfirmation => 'هویت عمومی و سطح تأیید نشان‌داده‌شده در بالا را تأیید می‌کنم.';

  @override
  String get adminCenterIdentityChangeFailure => 'تغییر هویت عمومی ممکن نشد. وضعیت حساب را بررسی کنید و دوباره تلاش کنید.';

  @override
  String get adminCenterChooseTechnicalRoleMessage => 'نقش فنی جدید را انتخاب و دلیل نیاز به این تغییر را ثبت کنید.';

  @override
  String get adminCenterNewTechnicalRoleLabel => 'نقش فنی جدید';

  @override
  String get adminCenterSelectRole => 'یک نقش انتخاب کنید';

  @override
  String get adminCenterRoleSessionWarning => 'این تغییر، نشست فعال گیرنده را پایان می‌دهد. او باید پیش از ادامه استفاده از حساب، دوباره وارد شود.';

  @override
  String get adminCenterRoleReasonHint => 'توضیح دهید چرا نقش فنی باید تغییر کند';

  @override
  String get adminCenterRoleConfirmation => 'نقش نشان‌داده‌شده در بالا را تأیید می‌کنم و می‌دانم گیرنده باید دوباره وارد شود.';

  @override
  String get adminCenterRoleChangeFailure => 'انجام تغییر نقش ممکن نشد. وضعیت حساب را بررسی کنید و دوباره تلاش کنید.';

  @override
  String get adminCenterChangingRole => 'در حال تغییر نقش';

  @override
  String get adminCenterConfirmRoleChange => 'تأیید تغییر نقش';

  @override
  String get adminCenterRoleUser => 'کاربر';

  @override
  String get adminCenterRoleModerator => 'ناظر';

  @override
  String get adminCenterRoleAdmin => 'مدیر';

  @override
  String get adminCenterAccountStatusActive => 'فعال';

  @override
  String get adminCenterAccountStatusSuspended => 'تعلیق‌شده';

  @override
  String get adminCenterAccountStatusDeleted => 'حذف‌شده';

  @override
  String get adminCenterVerificationStatusNone => 'هیچ‌کدام';

  @override
  String get adminCenterVerificationStatusPending => 'در انتظار';

  @override
  String get adminCenterVerificationStatusRejected => 'ردشده';

  @override
  String get adminCenterVerificationNotVerified => 'تأییدنشده';

  @override
  String get adminCenterVerificationLevel1 => 'سطح ۱';

  @override
  String get adminCenterVerificationLevel2 => 'سطح ۲';

  @override
  String get adminCenterReportSingular => 'گزارش';

  @override
  String get adminCenterReportPlural => 'گزارش‌ها';

  @override
  String get adminCenterUserSingular => 'کاربر';

  @override
  String get adminCenterUserPlural => 'کاربران';

  @override
  String get adminCenterPoll => 'Vote';

  @override
  String get adminCenterPost => 'Voce';

  @override
  String get adminCenterUnknown => 'ناشناخته';

  @override
  String get adminCenterContentHidden => 'محتوا پنهان است';

  @override
  String get adminCenterContentVisible => 'محتوا قابل مشاهده است';

  @override
  String get adminCenterReportedByLabel => 'گزارش‌دهنده';

  @override
  String get adminCenterContentOwnerLabel => 'مالک محتوا';

  @override
  String get adminCenterReviewReportAction => 'بررسی گزارش';

  @override
  String get adminCenterAdminDecisionAction => 'تصمیم Admin';

  @override
  String get adminCenterRestoreContentAction => 'بازگرداندن محتوا';

  @override
  String get adminCenterHideContentAction => 'پنهان کردن محتوا';

  @override
  String get adminCenterOpenProfileAction => 'باز کردن پروفایل';

  @override
  String get adminCenterOpenContentAction => 'باز کردن محتوا';

  @override
  String get adminCenterDecisionNoViolation => 'بدون تخلف';

  @override
  String get adminCenterDecisionViolationConfirmed => 'تخلف تأییدشده';

  @override
  String get adminCenterDecisionEscalateToAdmin => 'ارجاع به Admin';

  @override
  String get adminCenterResolutionNoAccountAction => 'بدون اقدام روی حساب';

  @override
  String get adminCenterResolutionAccountSuspended => 'حساب تعلیق شد';

  @override
  String get adminCenterResolutionLogoutForced => 'خروج اجباری انجام شد';

  @override
  String get adminCenterResolutionAccountDeleted => 'حساب حذف شد';

  @override
  String get adminCenterReviewerLabel => 'بررسی‌کننده';

  @override
  String get adminCenterDecisionDescriptionNoViolation => 'گزارش را به دلیل عدم نقض قواعد فعلی توسط محتوا رد می‌کند.';

  @override
  String get adminCenterDecisionDescriptionViolation => 'یک تخلف را تأیید می‌کند و پرونده را برای اقدام روی محتوا که در AC8.5 انجام می‌شود، در حال بررسی نگه می‌دارد.';

  @override
  String get adminCenterDecisionDescriptionEscalation => 'پرونده را برای بررسی در سطح حساب به مدیر ارجاع می‌دهد.';

  @override
  String get adminCenterChooseModerationOutcome => 'نتیجه نظارت بر این گزارش را انتخاب کنید.';

  @override
  String get adminCenterDecisionAlreadyRecordedFailure => 'ثبت تصمیم ممکن نشد. ممکن است گزارش قبلاً بررسی شده باشد. صف را نوسازی و دوباره تلاش کنید.';

  @override
  String get adminCenterDecisionLabel => 'تصمیم';

  @override
  String get adminCenterReportReasonLabel => 'دلیل گزارش';

  @override
  String get adminCenterReviewNoteLabel => 'یادداشت بررسی';

  @override
  String get adminCenterReviewNoteHint => 'شواهد و تصمیم نظارتی را توضیح دهید';

  @override
  String get adminCenterRecordingDecision => 'در حال ثبت تصمیم';

  @override
  String get adminCenterConfirmDecision => 'تأیید تصمیم';

  @override
  String get adminCenterAdministratorDecisionTitle => 'تصمیم مدیر';

  @override
  String get adminCenterResolutionDescriptionNoAction => 'گزارش ارجاع‌شده را بدون تغییر حساب می‌بندد.';

  @override
  String get adminCenterResolutionDescriptionSuspended => 'گزارش را پس از ثبت موفق تعلیق حساب در وقایع حسابرسی می‌بندد.';

  @override
  String get adminCenterResolutionDescriptionLogout => 'گزارش را پس از ثت موفق خروج اجباری در وقایع حسابرسی می‌بندد.';

  @override
  String get adminCenterResolutionDescriptionDeleted => 'گزارش را پس از ثبت موفق حذف حساب در وقایع حسابرسی می‌بندد.';

  @override
  String get adminCenterChooseFinalOutcome => 'نتیجه نهایی مدیر را برای این ارجاع انتخاب کنید.';

  @override
  String get adminCenterAdminResolutionFailure => 'ثبت تصمیم مدیر ممکن نشد. صف را نوسازی و دوباره تلاش کنید.';

  @override
  String get adminCenterAdminResolutionRequiresAction => 'ابتدا اقدام مربوط به حساب را انجام دهید، سپس به این گزارش برگردید و تصمیم نهایی مدیر را ثبت کنید.';

  @override
  String get adminCenterEscalationNoteLabel => 'یادداشت ارجاع';

  @override
  String get adminCenterFinalOutcomeLabel => 'نتیجه نهایی';

  @override
  String get adminCenterAdministratorNoteLabel => 'یادداشت مدیر';

  @override
  String get adminCenterAdministratorNoteHint => 'تصمیم نهایی در سطح حساب را توضیح دهید';

  @override
  String get adminCenterHideContentFailure => 'پنهان کردن محتوا ممکن نشد. صف گزارش‌ها را نوسازی و دوباره تلاش کنید.';

  @override
  String get adminCenterRestoreContentFailure => 'بازگرداندن محتوا ممکن نشد. صف گزارش‌ها را نوسازی و دوباره تلاش کنید.';

  @override
  String get adminCenterHideContentWarning => 'این کار، محتوای گزارش‌شده را از دسترسی عمومی حذف می‌کند. این عمل بعداً از فیلتر گزارش‌های حل‌شده قابل بازگشت است.';

  @override
  String get adminCenterRestoreContentWarning => 'این کار، محتوای گزارش‌شده را دوباره در دسترس عموم قرار می‌دهد.';

  @override
  String get adminCenterActionReasonLabel => 'دلیل اقدام';

  @override
  String get adminCenterHideContentReasonHint => 'توضیح دهید چرا محتوا باید پنهان شود';

  @override
  String get adminCenterRestoreContentReasonHint => 'توضیح دهید چرا محتوا می‌تواند بازگردانده شود';

  @override
  String get adminCenterHidingContent => 'در حال پنهان کردن محتوا';

  @override
  String get adminCenterRestoringContent => 'در حال بازگرداندن محتوا';

  @override
  String get adminCenterReportedProfileTitle => 'پروفایل گزارش‌شده';

  @override
  String get adminCenterReportedProfileNotice => 'اطلاعات این پروفایل از صف محافظت‌شده گزارش‌ها می‌آید. اقدامات اداری روی حساب جدا می‌مانند.';

  @override
  String get adminCenterCouldNotRefreshIndicators => 'نوسازی شاخص‌ها ممکن نشد.';

  @override
  String get adminCenterCouldNotRefreshAccount => 'نوسازی جزئیات حساب ممکن نشد.';

  @override
  String get adminCenterReportAlreadyReviewed => 'این گزارش قبلاً بررسی شده یا دیگر در انتظار نیست.';

  @override
  String get adminCenterReportNotAwaitingAdmin => 'این گزارش در انتظار تصمیم مدیر نیست.';

  @override
  String get adminCenterConfirmedViolationRequired => 'پیش از تغییر قابلیت مشاهده محتوا، یک تخلف تأییدشده لازم است.';

  @override
  String get adminCenterContentHiddenSuccess => 'محتوای گزارش‌شده پنهان شد.';

  @override
  String get adminCenterContentRestoredSuccess => 'محتوای گزارش‌شده بازگردانده شد.';

  @override
  String get adminCenterMissingContentId => 'شناسه محتوای اصلی موجود نیست.';

  @override
  String get adminCenterUnsupportedTargetType => 'این گزارش نوع هدف پشتیبانی‌نشده دارد.';

  @override
  String get adminCenterOriginalContentUnavailable => 'محتوای اصلی دیگر در دسترس نیست.';

  @override
  String get adminCenterNoReportedProfile => 'پروفایل گزارش‌شده‌ای به این محتوا مرتبط نیست.';

  @override
  String adminCenterRoleChangedSuccess(String previousRole, String newRole) {
    return 'نقش فنی از $previousRole به $newRole تغییر کرد. گیرنده خارج شد و باید دوباره وارد شود.';
  }

  @override
  String adminCenterIdentityChangedSuccess(String actorType, String verificationLevel) {
    return 'هویت عمومی به $actorType با $verificationLevel تغییر کرد.';
  }

  @override
  String adminCenterAccountSuspendedSuccess(String dateTime) {
    return 'حساب تا $dateTime تعلیق شد. گیرنده خارج شد.';
  }

  @override
  String adminCenterReportDecisionRecorded(String decision) {
    return 'تصمیم گزارش ثبت شد: $decision.';
  }

  @override
  String adminCenterAdministratorDecisionRecorded(String decision) {
    return 'تصمیم مدیر ثبت شد: $decision.';
  }

  @override
  String adminCenterUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کاربر',
      one: '$count کاربر',
    );
    return '$_temp0';
  }

  @override
  String adminCenterReportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count گزارش',
      one: '$count گزارش',
    );
    return '$_temp0';
  }

  @override
  String adminCenterAccountValue(String account) {
    return 'حساب: $account';
  }

  @override
  String adminCenterSuspendedUntilValue(String dateTime) {
    return 'تعلیق تا: $dateTime';
  }

  @override
  String adminCenterSuspendConfirmation(String dateTime) {
    return 'تعلیق تا $dateTime و پایان فوری نشست‌های فعلی را تأیید می‌کنم.';
  }

  @override
  String adminCenterAccountIdValue(String accountId) {
    return 'شناسه حساب: $accountId';
  }

  @override
  String adminCenterCurrentRoleValue(String role) {
    return 'فعلی: $role';
  }

  @override
  String adminCenterTargetFallback(String targetType, String targetId) {
    return '$targetType $targetId';
  }

  @override
  String adminCenterMinimumCharactersRequired(int count) {
    return 'یادداشتی با حداقل $count نویسه لازم است.';
  }

  @override
  String adminCenterMinimumReasonCharactersRequired(int count) {
    return 'دلیلی با حداقل $count نویسه لازم است.';
  }

  @override
  String adminCenterPageOf(int currentPage, int totalPages) {
    return 'صفحه $currentPage از $totalPages';
  }

  @override
  String get profilePublicProfileSectionTitle => 'پروفایل عمومی';

  @override
  String get profileIdentityVerificationSectionTitle => 'هویت و تأیید';

  @override
  String get profilePreferencesSectionTitle => 'ترجیحات';

  @override
  String get profileNotificationsSectionTitle => 'اعلان‌ها';

  @override
  String get profileActivitySectionTitle => 'فعالیت شخصی';

  @override
  String get profileSecurityAccountSectionTitle => 'امنیت و حساب';

  @override
  String get profileThemeTitle => 'نما';

  @override
  String get profileThemeSystem => 'سیستم';

  @override
  String get profileThemeSystemDescription => 'از نمای دستگاه پیروی می‌کند';

  @override
  String get profileThemeLight => 'روشن';

  @override
  String get profileThemeDark => 'تیره';

  @override
  String get profileMyPollsTitle => 'Vote';

  @override
  String get profileMyPostsTitle => 'Voce';

  @override
  String get profileMyCommentsTitle => 'دیدگاه‌های من';

  @override
  String get profileMyFavoritesTitle => 'ذخیره‌شده‌های من';

  @override
  String get profileAccountConnectionsTitle => 'دنبال‌شوندگان و دنبال‌کرده‌ها';

  @override
  String get accountConnectionsFollowingTab => 'دنبال‌شده‌ها';

  @override
  String get accountConnectionsFollowersTab => 'دنبال‌کنندگان';

  @override
  String get accountConnectionsEmptyFollowing => 'هنوز هیچ حسابی را دنبال نمی‌کنید.';

  @override
  String get accountConnectionsEmptyFollowers => 'هنوز دنبال‌کننده‌ای ندارید.';

  @override
  String get accountConnectionsLoadError => 'بارگذاری حساب‌ها ممکن نیست. دوباره تلاش کنید.';

  @override
  String get profileMyFollowedScopesTitle => 'مناطق دنبال‌شده من';

  @override
  String get profileLogoutAction => 'خروج';

  @override
  String get profileLogoutDescription => 'خروج از حساب فعلی';

  @override
  String get profileLogoutDialogTitle => 'خروج';

  @override
  String get profileLogoutDialogMessage => 'آیا مطمئنید می‌خواهید از حساب خود خارج شوید؟';

  @override
  String get profileLogoutCancelButton => 'لغو';

  @override
  String get profileLogoutConfirmButton => 'خروج';

  @override
  String get publicProfilePageTitle => 'پروفایل عمومی';

  @override
  String get publicProfileUserFallback => 'کاربر';

  @override
  String get publicProfileNoBio => 'توضیحی در دسترس نیست.';

  @override
  String get publicProfileResidenceLabel => 'محل اقامت';

  @override
  String get publicProfileResidenceUnknown => 'مشخص نشده';

  @override
  String get publicProfileMemberSinceLabel => 'عضویت از';

  @override
  String get publicProfileContentSectionTitle => 'محتوای عمومی';

  @override
  String get publicProfilePollsAction => 'Vote';

  @override
  String get publicProfilePostsAction => 'Voce';

  @override
  String get publicProfileBlockUserAction => 'مسدود کردن کاربر';

  @override
  String get publicProfileLoadError => 'بارگذاری پروفایل ممکن نیست.';

  @override
  String get publicProfileNotFound => 'پروفایل در دسترس نیست.';

  @override
  String get publicProfileUnblockUserAction => 'رفع مسدودیت کاربر';

  @override
  String get publicProfileBlockDialogTitle => 'این کاربر مسدود شود؟';

  @override
  String get publicProfileBlockDialogMessage => 'بعداً می‌توانید از پروفایل عمومی آن‌ها مسدودیت را بردارید.';

  @override
  String get publicProfileUnblockDialogTitle => 'مسدودیت این کاربر برداشته شود؟';

  @override
  String get publicProfileUnblockDialogMessage => 'کاربر دیگر در فهرست مسدودهای شما نخواهد بود.';

  @override
  String get publicProfileBlockSuccess => 'کاربر مسدود شد.';

  @override
  String get publicProfileUnblockSuccess => 'مسدودیت کاربر برداشته شد.';

  @override
  String get publicProfileBlockError => 'به‌روزرسانی مسدودیت ممکن نیست. دوباره تلاش کنید.';

  @override
  String get publicProfileFollowersLabel => 'دنبال‌کننده';

  @override
  String get publicProfileFollowingLabel => 'دنبال‌شده';

  @override
  String get publicProfileFollowAction => 'دنبال کردن';

  @override
  String get publicProfileUnfollowAction => 'لغو دنبال‌کردن';

  @override
  String get publicProfileFollowSuccess => 'حساب دنبال شد.';

  @override
  String get publicProfileUnfollowSuccess => 'دنبال‌کردن حساب لغو شد.';

  @override
  String get publicProfileFollowError => 'به‌روزرسانی دنبال‌کردن ممکن نیست. دوباره تلاش کنید.';

  @override
  String get publicProfileFollowRetry => 'بارگذاری دوباره اطلاعات دنبال‌کردن';

  @override
  String get contentLanguageFieldLabel => 'زبان محتوا';

  @override
  String get contentLanguageFieldHelper => 'زبانی را که محتوا را به آن نوشته‌اید انتخاب کنید.';

  @override
  String get contentLanguageUndetermined => 'مشخص نشده';

  @override
  String get createPollAdvancedOptionsTitle => 'گزینه‌های پیشرفته';

  @override
  String get createPollAdvancedOptionsSubtitle => 'ناشناس‌بودن، نمایش نتایج، تغییر رأی و حداقل نصاب.';

  @override
  String get onboardingSkipButton => 'رد کردن';

  @override
  String get onboardingNextButton => 'بعدی';

  @override
  String get onboardingStartButton => 'شروع';

  @override
  String get onboardingPollTitle => 'Vote';

  @override
  String get onboardingPollDescription => 'در Vote‌های موضوعات مهم برای شما شرکت کنید، یا برای جمع‌آوری نظر جامعه یکی بسازید.';

  @override
  String get onboardingHeatIceTitle => 'Heat و Ice';

  @override
  String get onboardingHeatIceDescription => 'از Heat و Ice برای نشان‌دادن شدت توجه شما به یک محتوا استفاده کنید.';

  @override
  String get onboardingCivicMapTitle => 'نقشه مدنی';

  @override
  String get onboardingCivicMapDescription => 'Vote، Voce و News را روی نقشه کاوش کنید و ببینید در مناطق مختلف چه خبر است.';

  @override
  String get onboardingGeoScopeTitle => 'GeoScope';

  @override
  String get onboardingGeoScopeDescription => 'سطح جغرافیایی مورد نظر را انتخاب کنید: جهان، کشور یا شهر.';

  @override
  String get onboardingVerificationTitle => 'تأیید هویت';

  @override
  String get onboardingVerificationDescription => 'برخی Vote‌ها برای حفظ صحت رأی‌گیری ممکن است به سطحی از تأیید هویت نیاز داشته باشند.';

  @override
  String get pollDetail_voteReceiptButton => 'رسید رأی';

  @override
  String get pollDetail_voteReceiptTitle => 'رسید رأی';

  @override
  String get pollDetail_voteReceiptIdLabel => 'شناسه رسید';

  @override
  String get pollDetail_voteReceiptDateLabel => 'ثبت‌شده';

  @override
  String get pollDetail_voteReceiptPrivacy => 'این رسید تأیید می‌کند که رأی شما بدون نمایش گزینه انتخابی‌تان ثبت شده است.';

  @override
  String get pollDetail_voteReceiptCloseButton => 'بستن';

  @override
  String get profileBiometricUnlockTitle => 'بازکردن با زیست‌سنجی';

  @override
  String get profileBiometricUnlockDescription => 'نشست به‌خاطرسپرده‌شده شما را با اثر انگشت یا شناسایی زیست‌سنجی دستگاه محافظت می‌کند.';

  @override
  String get profileBiometricRequiresRememberMe => 'نیازمند فعال‌بودن «مرا به خاطر بسپار» است.';

  @override
  String get profileBiometricUnavailable => 'زیست‌سنجی در این دستگاه در دسترس نیست یا پیکربندی نشده است.';

  @override
  String get profileBiometricEnableReason => 'برای فعال‌کردن بازکردن Social Vote، زیست‌سنجی خود را تأیید کنید.';

  @override
  String get profileBiometricEnabledMessage => 'بازکردن با زیست‌سنجی فعال شد.';

  @override
  String get profileBiometricDisabledMessage => 'بازکردن با زیست‌سنجی غیرفعال شد.';

  @override
  String get profileBiometricAuthFailedMessage => 'احراز هویت زیست‌سنجی کامل نشد.';

  @override
  String get biometricLockTitle => 'Social Vote قفل است';

  @override
  String get biometricLockMessage => 'برای بازکردن نشست به‌خاطرسپرده‌شده، از زیست‌سنجی دستگاه استفاده کنید.';

  @override
  String get biometricUnlockButton => 'باز کردن';

  @override
  String get biometricUsePasswordButton => 'استفاده از رمز عبور';

  @override
  String get biometricUnlockReason => 'نشست Social Vote خود را باز کنید.';

  @override
  String get biometricUnlockFailedMessage => 'بازکردن ناموفق بود. دوباره تلاش کنید یا از رمز عبور خود استفاده کنید.';

  @override
  String get adminCenterOperationalActivityTitle => 'فعالیت عملیاتی';

  @override
  String get adminCenterOperationalActivitySubtitle => 'شمارنده‌های تجمیعی. بدون ردیابی آنلاین‌بودن بلادرنگ.';

  @override
  String get adminCenterLast24HoursLabel => '۲۴ ساعت';

  @override
  String get adminCenterLast7DaysLabel => '۷ روز';

  @override
  String get adminCenterNewUsersMetric => 'ثبت‌نام‌های جدید';

  @override
  String get adminCenterRecentSignInsMetric => 'ورودهای اخیر';

  @override
  String get adminCenterPollsCreatedMetric => 'Vote‌های ایجادشده';

  @override
  String get adminCenterPostsCreatedMetric => 'Voce‌های ایجادشده';

  @override
  String get adminCenterAdminActionsMetric => 'اقدامات Admin';

  @override
  String get authPublicNameHelper => 'این نامی است که کاربران دیگر می‌بینند. نام کاربری شما به‌طور خودکار ساخته می‌شود.';

  @override
  String get adminCenterRefreshMarkersTooltip => 'نوسازی نشانگرهای کره زمین';

  @override
  String get adminCenterQuickActionsTitle => 'اقدامات سریع حساب';

  @override
  String get adminCenterModerationSnapshotTitle => 'خلاصه نظارت و فعالیت';

  @override
  String get adminCenterReportsReceivedMetric => 'گزارش‌های دریافت‌شده';

  @override
  String get adminCenterPendingReportsMetric => 'گزارش‌های در انتظار';

  @override
  String get adminCenterConfirmedViolationsMetric => 'تخلف‌های تأییدشده';

  @override
  String get adminCenterReportsFiledMetric => 'گزارش‌های ارسال‌شده';

  @override
  String get adminCenterCommentsCreatedMetric => 'دیدگاه‌های ایجادشده';

  @override
  String get adminCenterAdminActionsOnAccountMetric => 'اقدامات Admin روی حساب';

  @override
  String get adminCenterLastReportReceivedLabel => 'آخرین گزارش دریافت‌شده';

  @override
  String get adminCenterOpenFullAccountAction => 'باز کردن کنترل‌های کامل حساب';

  @override
  String get profileAppLanguageGerman => 'آلمانی';

  @override
  String get profileAppLanguagePersian => 'فارسی';

  @override
  String get discoveryPageTitle => 'کاوش';

  @override
  String get organizationWorkspaceTitle => 'Workspace سازمان';

  @override
  String get organizationPilotBannerTitle => 'دوره آزمایشی رایگان';

  @override
  String get organizationPilotBannerBody => 'Sessions در دوره آزمایشی رایگان هستند. ممکن است برخی قابلیت‌های حرفه‌ای در آینده پولی شوند؛ اکنون صورت‌حساب فعال نیست.';

  @override
  String get organizationVerifiedLabel => 'سازمان تأییدشده';

  @override
  String get organizationEditProfile => 'ویرایش پروفایل سازمان';

  @override
  String get organizationCreateSession => 'Session جدید';

  @override
  String get organizationNoSessions => 'هنوز Session‌ای نیست. اولین Session را برای جلسه، کارگاه یا رویداد ایجاد کنید.';

  @override
  String get organizationSessionsTitle => 'Sessions زنده';

  @override
  String get organizationRequiresVerificationTitle => 'سازمان تأییدشده لازم است';

  @override
  String get organizationRequiresVerificationBody => 'این Workspace فقط برای حساب‌هایی در دسترس است که Social Vote آن‌ها را به‌عنوان سازمان تأییدشده پذیرفته باشد.';

  @override
  String get organizationProfileEditorTitle => 'پروفایل سازمان';

  @override
  String get organizationLegalName => 'نام قانونی';

  @override
  String get organizationPublicName => 'نام عمومی';

  @override
  String get organizationType => 'نوع سازمان';

  @override
  String get organizationCountryCode => 'کد کشور';

  @override
  String get organizationCity => 'شهر';

  @override
  String get organizationWebsite => 'وب‌سایت رسمی';

  @override
  String get organizationDescription => 'توضیحات';

  @override
  String get organizationUploadCover => 'تغییر تصویر روی جلد';

  @override
  String get organizationUploadLogo => 'تغییر نشان';

  @override
  String get organizationMediaUpdated => 'تصویر سازمان به‌روز شد.';

  @override
  String get organizationNamesRequired => 'نام قانونی و عمومی الزامی هستند.';

  @override
  String get organizationTypeAssociation => 'انجمن';

  @override
  String get organizationTypeNonprofit => 'غیرانتفاعی';

  @override
  String get organizationTypeCompany => 'شرکت';

  @override
  String get organizationTypeCooperative => 'تعاونی';

  @override
  String get organizationTypeSports => 'سازمان ورزشی';

  @override
  String get organizationTypePublicBody => 'نهاد عمومی';

  @override
  String get organizationTypeCommittee => 'کمیته / گروه';

  @override
  String get organizationTypeOther => 'سایر';

  @override
  String get sessionCreateTitle => 'ایجاد Session زنده';

  @override
  String get sessionTitleLabel => 'عنوان Session';

  @override
  String get sessionExpectedParticipants => 'شرکت‌کنندگان مورد انتظار';

  @override
  String get sessionAccessMode => 'دسترسی شرکت‌کننده';

  @override
  String get sessionAccessOpen => 'ناشناس باز';

  @override
  String get sessionAccessOpenHint => 'هر کسی که پیوند/کد را داشته باشد می‌تواند وارد شود. پیشگیری از تکراری‌ها به‌صورت حداکثری است؛ این حالت اصل یک نفر-یک رأی را تضمین نمی‌کند.';

  @override
  String get sessionAccessControlled => 'ناشناس کنترل‌شده';

  @override
  String get sessionAccessControlledHint => 'از Access Pass‌های ناشناس یک‌بارمصرف استفاده کنید. Social Vote فقط هش Access Pass را ذخیره می‌کند و گزینه‌های رأی را به اعتبارنامه شرکت‌کننده مرتبط نمی‌کند.';

  @override
  String get sessionResultsVisibility => 'قابلیت مشاهده نتیجه';

  @override
  String get sessionResultsLive => 'زنده';

  @override
  String get sessionResultsAfterVote => 'پس از رأی شرکت‌کننده';

  @override
  String get sessionResultsAfterClose => 'پس از بسته‌شدن پرسش';

  @override
  String get sessionResultsOrganizerOnly => 'فقط برگزارکننده';

  @override
  String get sessionCreateAction => 'ایجاد Session';

  @override
  String get sessionPilotLimit => 'محدودیت آزمایشی: از ۱ تا ۲۵۰ شرکت‌کننده در هر Session.';

  @override
  String get sessionStatusDraft => 'پیش‌نویس';

  @override
  String get sessionStatusOpen => 'باز';

  @override
  String get sessionStatusClosed => 'بسته';

  @override
  String get sessionJoinCode => 'کد پیوستن';

  @override
  String get sessionShareJoin => 'همرسانی پیوند پیوستن';

  @override
  String get sessionCopyJoinLink => 'کپی پیوند';

  @override
  String get sessionGenerateTokens => 'ایجاد Access Pass‌ها';

  @override
  String get sessionGenerateTokensCount => 'تعداد Access Pass‌ها';

  @override
  String get sessionTokensOneTimeTitle => 'این اعتبارنامه‌ها را همین حالا ذخیره کنید';

  @override
  String get sessionTokensOneTimeBody => 'Access Pass‌های متن‌ساده فقط در نتیجه این دسته نمایش داده می‌شوند. Social Vote فقط هش آن‌ها را ذخیره می‌کند. آن‌ها را با امنیت کپی و توزیع کنید.';

  @override
  String get sessionCopyTokens => 'کپی همه پیوندها';

  @override
  String get sessionTokensSavedAction => 'ذخیره‌شان کردم';

  @override
  String get sessionOpenAction => 'باز کردن Session';

  @override
  String get sessionCloseAction => 'بستن Session';

  @override
  String get sessionCloseConfirm => 'رأی‌گیری بسته شود و نسخه ثابت Verified Result ایجاد شود؟';

  @override
  String get sessionQuestionsTitle => 'پرسش‌ها';

  @override
  String get sessionAddQuestion => 'افزودن پرسش';

  @override
  String get sessionQuestionTitle => 'پرسش';

  @override
  String get sessionQuestionType => 'نوع پرسش';

  @override
  String get sessionTypeYesNo => 'بله / خیر';

  @override
  String get sessionTypeSingle => 'تک‌انتخابی';

  @override
  String get sessionTypeMultiple => 'چندانتخابی';

  @override
  String get sessionOptions => 'گزینه‌ها';

  @override
  String get sessionOptionHint => 'در هر خط یک گزینه.';

  @override
  String get sessionMinSelections => 'حداقل انتخاب‌ها';

  @override
  String get sessionMaxSelections => 'حداکثر انتخاب‌ها';

  @override
  String get sessionAddAction => 'افزودن';

  @override
  String get sessionOpenQuestion => 'باز کردن پرسش';

  @override
  String get sessionCloseQuestion => 'بستن پرسش';

  @override
  String get sessionNoQuestions => 'هنوز پرسشی نیست.';

  @override
  String get sessionPresenterTitle => 'ارائه‌دهنده';

  @override
  String get sessionParticipantTitle => 'Social Vote Live';

  @override
  String get sessionJoinAction => 'پیوستن به Session';

  @override
  String get sessionTokenLabel => 'توکن شرکت‌کننده';

  @override
  String get sessionTokenHint => 'SV-…';

  @override
  String get sessionWaitingQuestion => 'در انتظار برگزارکننده برای باز کردن یک پرسش…';

  @override
  String get sessionVoteAction => 'ثبت رأی';

  @override
  String get sessionVoteReceived => 'رأی دریافت شد';

  @override
  String get sessionResultsUnavailable => 'نتایج هنوز طبق سیاست این Session قابل مشاهده نیستند.';

  @override
  String get sessionPrivacyNotice => 'برگزارکننده، هدف عملیاتی و پرسش‌های Session را تعیین می‌کند. Social Vote داده‌های فنی لازم برای ارائه و محافظت از خدمت را پردازش می‌کند. حالت‌های ناشناس، ارتباط بین اعتبارنامه شرکت‌کننده و گزینه رأی را به برگزارکننده نشان نمی‌دهند. نقش‌های حریم خصوصی ممکن است به زمینه و توافق‌های قابل اجرا بستگی داشته باشند.';

  @override
  String get sessionNonBindingNotice => 'Sessions آزمایشی برای مشورت و مشارکت هستند. آن‌ها انتخابات قانونی، رأی مجمع رسمی یا گواهی الزام‌آور قانونی نیستند.';

  @override
  String get sessionOptionYes => 'بله';

  @override
  String get sessionOptionNo => 'خیر';

  @override
  String get verifiedResultTitle => 'نتیجه تأییدشده';

  @override
  String get verifiedResultValid => 'بررسی یکپارچگی موفق بود';

  @override
  String get verifiedResultInvalid => 'بررسی یکپارچگی ناموفق بود';

  @override
  String get verifiedResultReportId => 'شناسه گزارش';

  @override
  String get verifiedResultHash => 'هش SHA-256 نتیجه';

  @override
  String get verifiedResultGeneratedBy => 'ایجاد و مهر یکپارچگی توسط Social Vote';

  @override
  String get verifiedResultNotLegalCertificate => 'این یک گزارش نتیجه تجمیعی قابل راستی‌آزمایی است، نه گواهی قانونی یا تصدیق یک انتخابات الزام‌آور قانونی.';

  @override
  String get verifiedResultShare => 'همرسانی پیوند راستی‌آزمایی';

  @override
  String sessionResponses(int count) {
    return '$count پاسخ';
  }

  @override
  String sessionResultVotes(int count) {
    return '$count رأی';
  }

  @override
  String get organizationVerifiedIdentityLocked => 'نام و کشور بخشی از هویت تأییدشده سازمان هستند. تغییر آن‌ها نیازمند تأیید دوباره است. تصویر روی جلد، نشان، نوع، شهر، وب‌سایت و توضیحات را آزادانه می‌توانید تغییر دهید.';

  @override
  String get verifiedResultOpenedAt => 'Session باز شد';

  @override
  String get verifiedResultEligibleCredentials => 'اعتبارنامه‌های مجاز';

  @override
  String get verifiedResultIntegritySeal => 'مهر یکپارچگی Social Vote';

  @override
  String get organizationVerifiedNameLocked => 'نام و کشور تأییدشده قفل هستند. تغییر آن‌ها نیازمند بررسی تأیید دوباره است.';

  @override
  String get sessionRetentionLabel => 'نگهداری برگه‌های رأی خام';

  @override
  String get sessionRetention24h => '۲۴ ساعت';

  @override
  String get sessionRetention7d => '۷ روز';

  @override
  String get sessionRetention30d => '۳۰ روز';

  @override
  String sessionRetentionValue(String value) {
    return 'نگهداری برگه‌های رأی خام: $value';
  }

  @override
  String get verifiedResultPrintPdf => 'دانلود PDF';

  @override
  String get verifiedResultPdfError => 'دانلود PDF ممکن نیست. دوباره تلاش کنید.';

  @override
  String get verifiedResultRestrictedTitle => 'نتیجه محدود';

  @override
  String get verifiedResultRestrictedBody => 'این نتیجه تأییدشده به‌صورت عمومی در دسترس نیست. برای مشاهده آن با یک حساب سازمانی مجاز وارد شوید.';

  @override
  String get verifiedResultPrivateVerificationTitle => 'راستی‌آزمایی عمومی در دسترس نیست';

  @override
  String get verifiedResultPrivateVerificationBody => 'این نتیجه به برگزارکننده محدود است. شناسه گزارش، SHA-256 و بررسی یکپارچگی در گزارش مجاز باقی می‌مانند.';

  @override
  String get organizationAccountSectionTitle => 'سازمان‌های شما';

  @override
  String get organizationManageAction => 'مدیریت';

  @override
  String get organizationViewPublicProfileAction => 'مشاهده پروفایل';

  @override
  String get organizationOfficialWebsiteAction => 'وب‌سایت رسمی';

  @override
  String get organizationVerificationIntro => 'تأیید، هم وجود سازمان و هم اختیار شما برای نمایندگی آن را پوشش می‌دهد. Social Vote پیش از تأیید، اطلاعات ارسال‌شده را بررسی می‌کند.';

  @override
  String get organizationVerificationLegalName => 'نام قانونی';

  @override
  String get organizationVerificationPublicName => 'نام عمومی';

  @override
  String get organizationVerificationType => 'نوع سازمان';

  @override
  String get organizationVerificationCountry => 'کشور';

  @override
  String get organizationVerificationCountryRequired => 'کشور سازمان را انتخاب کنید.';

  @override
  String get organizationVerificationCity => 'شهر';

  @override
  String get organizationVerificationWebsite => 'وب‌سایت رسمی';

  @override
  String get organizationVerificationRepresentativeRole => 'نقش شما در سازمان';

  @override
  String get organizationVerificationRegistryId => 'شناسه ثبتی / مالیاتی / سازمانی';

  @override
  String get organizationVerificationAuthorityNote => 'چگونه می‌توانیم اختیار شما برای نمایندگی آن را بررسی کنیم؟';

  @override
  String get organizationVerificationAuthorityHelper => 'نقش خود یا مدرکی را که Admin می‌تواند در دوره آزمایشی بررسی کند، کوتاه بیان کنید.';

  @override
  String get organizationVerificationRequired => 'فیلد الزامی.';

  @override
  String get sessionControlRoomTitle => 'اتاق کنترل Session';

  @override
  String get sessionSectionLive => 'زنده';

  @override
  String get sessionSectionQuestions => 'پرسش‌ها';

  @override
  String get sessionSectionAccess => 'دسترسی';

  @override
  String get sessionSectionSettings => 'تنظیمات';

  @override
  String get sessionStageAction => 'باز کردن صحنه';

  @override
  String get sessionAccessPassesTitle => 'Access Pass‌های شرکت‌کنندگان';

  @override
  String get sessionAccessPassesSubtitle => 'هر Pass، این Session ناشناس کنترل‌شده را بدون نیاز به تایپ اعتبارنامه طولانی باز می‌کند. Social Vote متن ساده Pass را ذخیره نمی‌کند.';

  @override
  String get sessionAccessPass => 'Access Pass';

  @override
  String get sessionAccessPassDetected => 'Access Pass شناسایی شد';

  @override
  String get sessionAccessPassAutomatic => 'Pass شخصی شما آماده است. برای ورود ناشناس به Session ادامه دهید.';

  @override
  String get sessionAccessPassFallback => 'واردکردن دستی Pass';

  @override
  String get sessionAccessPassInvalid => 'این Access Pass نامعتبر یا دیگر موجود نیست، یا Session باز نیست.';

  @override
  String get sessionAccessPassPrintWarning => 'این Pass‌ها را همین حالا چاپ، ذخیره یا توزیع کنید. پس از ترک این صفحه، Social Vote نمی‌تواند متن ساده Pass‌ها را دوباره نشان دهد.';

  @override
  String get sessionExistingPassesHidden => 'به دلایل امنیتی، Pass‌های قبلی دوباره به‌صورت متن ساده نمایش داده نمی‌شوند. برای دریافت پیوندها یا QR Code‌های شخصی جدید، Access Pass‌های جدید بسازید.';

  @override
  String get sessionCopyPassLinks => 'کپی همه پیوندها';

  @override
  String get sessionCopyPassLink => 'کپی این پیوند';

  @override
  String get sessionControlledNeedsAccessPass => 'پیش از باز کردن Session کنترل‌شده، حداقل یک Access Pass ایجاد کنید.';

  @override
  String get sessionJoinedParticipants => 'اعتبارنامه‌های واردشده';

  @override
  String get sessionAccessesUsed => 'دسترسی‌هایی که رأی دادند';

  @override
  String get sessionBallotsRecorded => 'برگه‌های رأی ثبت‌شده';

  @override
  String get sessionQuestionsCompleted => 'پرسش‌های کامل‌شده';

  @override
  String get sessionCurrentQuestion => 'پرسش فعلی';

  @override
  String get sessionNoOpenQuestionTitle => 'هیچ پرسشی باز نیست';

  @override
  String get sessionNoOpenQuestionBody => 'شرکت‌کنندگان متصل و منتظر هستند. هر زمان آماده بودید، پرسش بعدی را باز کنید.';

  @override
  String get sessionNotStartedTitle => 'Session هنوز شروع نشده است';

  @override
  String get sessionNotStartedBody => 'این Session وجود دارد اما هنوز باز نیست. این صفحه را باز نگه دارید و منتظر شروع برگزارکننده بمانید.';

  @override
  String get sessionNoAccountRequired => 'به حساب Social Vote نیازی نیست';

  @override
  String get sessionReceiptDetails => 'جزئیات رسید';

  @override
  String get sessionOpenAccessInstructions => 'این QR را نمایش دهید یا همرسانی کنید. هر کسی که پیوند را داشته باشد، تا زمانی که Session باز است می‌تواند وارد شود.';

  @override
  String get sessionControlledAccessInstructions => 'Access Pass‌های شخصی ایجاد کنید و به هر شرکت‌کننده یکی بدهید. QR هر Pass اعتبارنامه را خودکار در خود دارد.';

  @override
  String get sessionControlRoomHint => 'دسترسی، پرسش‌ها، صحنه پخش‌شده و نتیجه تأییدشده نهایی را از یک مکان مدیریت کنید.';

  @override
  String get sessionPresenterScreenTitle => 'صحنه زنده';

  @override
  String get sessionStageWaiting => 'در انتظار پرسش بعدی';

  @override
  String get sessionStageScan => 'برای پیوستن به Session اسکن کنید';

  @override
  String get sessionConfigurationTitle => 'پیکربندی Session';

  @override
  String get sessionAccessRecommended => 'پیشنهادشده برای جلسات کنترل‌شده';

  @override
  String get sessionCreateIntroTitle => 'جلسه را تنظیم کنید';

  @override
  String get sessionCreateIntroBody => 'نحوه ورود شرکت‌کنندگان، زمان نمایش نتایج و مدت نگهداری برگه‌های رأی خام را انتخاب کنید. این تنظیمات توسط بک‌اند اجرا می‌شوند.';

  @override
  String get verifiedCertificateNumber => 'شماره گواهی';

  @override
  String get verifiedCertificateStatus => 'وضعیت یکپارچگی';

  @override
  String get verifiedCertificateIntegrityVerified => 'یکپارچگی تأیید شد';

  @override
  String get verifiedCertificateIntegrityFailed => 'بررسی یکپارچگی ناموفق بود';

  @override
  String get verifiedCertificateOrganizationSection => 'سازمان';

  @override
  String get verifiedCertificateSessionSection => 'جلسه';

  @override
  String get verifiedCertificateParticipationSection => 'مشارکت';

  @override
  String get verifiedCertificateResultsSection => 'نتایج تأییدشده';

  @override
  String get verifiedCertificateIntegritySection => 'یکپارچگی نتیجه';

  @override
  String get verifiedCertificateLegalName => 'نام قانونی';

  @override
  String get verifiedCertificateOrganizationType => 'نوع سازمان';

  @override
  String get verifiedCertificateLocation => 'مکان';

  @override
  String get verifiedCertificateWebsite => 'وب‌سایت';

  @override
  String get verifiedCertificateVerification => 'تأیید';

  @override
  String get verifiedCertificateIssuedAt => 'زمان صدور گواهی';

  @override
  String get verifiedCertificateAlgorithm => 'الگوریتم یکپارچگی';

  @override
  String get verifiedCertificateSchema => 'طرحواره گزارش';

  @override
  String get verifiedCertificateJoinedCredentials => 'اعتبارنامه‌های واردشده';

  @override
  String get verifiedCertificateBallotsTotal => 'برگه‌های رأی ثبت‌شده';

  @override
  String get verifiedCertificateQuestionsTotal => 'پرسش‌ها';

  @override
  String get verifiedCertificatePrivacyModel => 'مدل نتیجه ناشناس';

  @override
  String get verifiedCertificatePrivacyText => 'نسخه ثابت فقط حاوی نتایج تجمیعی است. هویت شرکت‌کننده، Access Pass متن‌ساده، راز شرکت‌کننده یا هرگونه نگاشت اعتبارنامه شرکت‌کننده به گزینه رأی را شامل نمی‌شود.';

  @override
  String get verifiedCertificateVerifyQr => 'برای راستی‌آزمایی آنلاین گزارش، این QR را اسکن کنید.';

  @override
  String get organizationDashboardTitle => 'نمای کلی سازمان';

  @override
  String get organizationActiveSessions => 'Sessions زنده';

  @override
  String get organizationVerifiedReports => 'گزارش‌های تأییدشده';

  @override
  String get organizationTotalSessions => 'مجموع Sessions';

  @override
  String get sessionPrivacyPolicyAction => 'مطالعه سیاست حریم خصوصی';

  @override
  String get radioMondoTitle => 'رادیوی جهان';

  @override
  String get radioMondoDescription => 'سه فضای صوتی اصیل برای کاوش در Social Vote. پخش فقط زمانی آغاز می‌شود که خودتان یک قطعه را انتخاب کنید.';

  @override
  String get radioMondoTrackClassical => 'مدار کلاسیک';

  @override
  String get radioMondoTrackRain => 'باران بر فراز جهان';

  @override
  String get radioMondoTrackYoung => 'پالس جوان';

  @override
  String get radioMondoPlaying => 'در حال پخش';

  @override
  String get radioMondoStopped => 'رادیوی جهان متوقف شد';

  @override
  String get radioMondoStopAction => 'توقف';

  @override
  String get radioMondoPlaybackError => 'پخش صدا امکان‌پذیر نبود';

  @override
  String get radioMondoForegroundOnly => 'با بستن Social Vote، رفتن برنامه به پس‌زمینه یا پنهان شدن زبانه مرورگر، پخش متوقف می‌شود.';

  @override
  String get adminCenterEditorialNavigation => 'گزارش‌های جهان';

  @override
  String get worldBriefEditorTitle => 'گزارش‌های جهان Social Vote';

  @override
  String get worldBriefEditorDescription => 'گزارش‌های مستند آماده کنید، موارد نامطمئن را آشکار نگه دارید و تعیین کنید چه چیزی در اخبار و روی کره نمایش داده شود.';

  @override
  String get worldBriefAllStatuses => 'همه وضعیت‌ها';

  @override
  String get worldBriefCreateAction => 'ایجاد گزارش';

  @override
  String get worldBriefDraftSaved => 'پیش‌نویس ذخیره شد';

  @override
  String get worldBriefPublished => 'گزارش منتشر شد';

  @override
  String get worldBriefWithdrawn => 'گزارش پس گرفته شد';

  @override
  String get worldBriefSaveError => 'ذخیره گزارش ممکن نبود';

  @override
  String get worldBriefPublishError => 'انتشار گزارش ممکن نبود';

  @override
  String get worldBriefDraftDeleted => 'پیش‌نویس حذف شد';

  @override
  String get worldBriefDeleteDraft => 'حذف پیش‌نویس';

  @override
  String get worldBriefDeleteDraftConfirm => 'این پیش‌نویس منتشرنشده برای همیشه حذف شود؟';

  @override
  String get worldBriefRetry => 'تلاش دوباره';

  @override
  String get worldBriefStatusDraft => 'پیش‌نویس';

  @override
  String get worldBriefStatusPublished => 'منتشرشده';

  @override
  String get worldBriefStatusWithdrawn => 'پس‌گرفته‌شده';

  @override
  String get worldBriefSetupRequired => 'بخش فنی تحریریه آماده نیست';

  @override
  String get worldBriefSetupRequiredBody => 'پیش از استفاده از این بخش، مهاجرت پایگاه داده World Brief موجود در بسته را اجرا کنید.';

  @override
  String get worldBriefEmptyTitle => 'هنوز گزارشی وجود ندارد';

  @override
  String get worldBriefEmptyBody => 'یک پیش‌نویس بسازید، دست‌کم دو منبع را ثبت کنید و تنها پس از بازبینی تحریریه منتشر کنید.';

  @override
  String get worldBriefFeatured => 'برگزیده';

  @override
  String get worldBriefOnGlobe => 'نمایش روی کره';

  @override
  String get worldBriefPriority => 'اولویت';

  @override
  String get worldBriefEditAction => 'ویرایش';

  @override
  String get worldBriefPublishAction => 'انتشار';

  @override
  String get worldBriefWithdrawAction => 'پس گرفتن';

  @override
  String get worldBriefSaveDraftAction => 'ذخیره پیش‌نویس';

  @override
  String get worldBriefLanguage => 'زبان گزارش';

  @override
  String get worldBriefTitleField => 'تیتر';

  @override
  String get worldBriefWhatHappened => 'چه اتفاقی افتاده است';

  @override
  String get worldBriefWhyItMatters => 'چرا اهمیت دارد';

  @override
  String get worldBriefWhatIsUncertain => 'چه چیزی هنوز قطعی نیست';

  @override
  String get worldBriefSources => 'نشانی منابع';

  @override
  String get worldBriefSourcesHint => 'در هر خط یک نشانی HTTPS؛ دست‌کم دو منبع مستقل.';

  @override
  String get worldBriefTwoSourcesRequired => 'دست‌کم دو منبع اضافه کنید.';

  @override
  String get worldBriefHttpsSourcesRequired => 'همه منابع باید از HTTPS استفاده کنند.';

  @override
  String get worldBriefGlobeSection => 'جایگاه روی کره';

  @override
  String get worldBriefGlobeRequiresPoint => 'نمایش روی کره به عرض و طول جغرافیایی معتبر نیاز دارد.';

  @override
  String get worldBriefCountryCode => 'کد کشور';

  @override
  String get worldBriefCityId => 'شناسه شهر';

  @override
  String get worldBriefLocationLabel => 'نام مکان';

  @override
  String get worldBriefLatitude => 'عرض جغرافیایی';

  @override
  String get worldBriefLongitude => 'طول جغرافیایی';

  @override
  String get worldBriefBreaking => 'خبر فوری';

  @override
  String get worldBriefExpiry => 'بازه بازبینی یا انقضا';

  @override
  String worldBriefExpiryDays(int days) {
    return '$days روز';
  }

  @override
  String get worldBriefRequiredField => 'این فیلد الزامی است.';

  @override
  String get worldBriefCoordinatesRequired => 'یک مختصات معتبر وارد کنید.';
}
