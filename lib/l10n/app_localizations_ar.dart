// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Social Vote';

  @override
  String get voteButton => 'Vote';

  @override
  String get createPollPageTitle => 'إنشاء Vote';

  @override
  String get createPollPageSubtitle => 'عرّف تصويتًا مدنيًا جديدًا';

  @override
  String get createPollBasicInfoTitle => 'المعلومات الأساسية';

  @override
  String get createPollBasicInfoSubtitle => 'حدّد التفاصيل الرئيسية للـ Vote.';

  @override
  String get createPollTitleFieldLabel => 'العنوان *';

  @override
  String get createPollTitleFieldHelper => 'سؤال أو عبارة واضحة وموجزة.';

  @override
  String get createPollDescriptionFieldLabel => 'الوصف (اختياري)';

  @override
  String get createPollVotingModelTitle => 'طريقة التصويت';

  @override
  String get createPollVotingModelSubtitle => 'اختر ما إذا كان بإمكان كل شخص تحديد إجابة واحدة أو عدة إجابات.';

  @override
  String get createPollTypeFieldLabel => 'نوع Vote';

  @override
  String createPollSelectionRules(int min, int max) {
    return 'قواعد الاختيار: حد أدنى $min وحد أقصى $max من الاختيارات (يتم ضبطها تلقائيًا وفقًا لنوع Vote والخيارات).';
  }

  @override
  String get createPollAllowVoteChangeTitle => 'السماح للمصوّتين بتغيير تصويتهم';

  @override
  String get createPollAllowVoteChangeSubtitle => 'حتى إغلاق Vote.';

  @override
  String get createPollOptionsTitle => 'الإجابات';

  @override
  String get createPollOptionsSubtitle => 'أدخل إجابتين على الأقل ليختار المصوّتون من بينها. الحقول المعلّمة بـ * إلزامية.';

  @override
  String createPollOptionLabel(int index, Object requiredMarker) {
    return 'الخيار $index$requiredMarker';
  }

  @override
  String get createPollRemoveOptionTooltip => 'إزالة الخيار';

  @override
  String get createPollAddOptionButton => 'إضافة خيار';

  @override
  String get createPollParticipationPrivacyTitle => 'المشاركة والخصوصية';

  @override
  String get createPollParticipationPrivacySubtitle => 'حدّد من يمكنه التصويت ومدى خصوصية الأصوات.';

  @override
  String get createPollWhoCanVoteLabel => 'من يمكنه التصويت؟';

  @override
  String get createPollParticipationEveryoneSubtitle => 'يمكن لأي مستخدم مسجّل المشاركة.';

  @override
  String get createPollParticipationGeoScopeSubtitle => 'حصر هذا الـ Vote بالأشخاص من بلد محدد.';

  @override
  String get createPollCountryFieldLabel => 'بلد هذا الـ Vote';

  @override
  String get createPollCountryFieldHelper => 'سيحدد هذا البلد من يُسمح له بالمشاركة في هذا الـ Vote (تكامل مستقبلي مع الخلفية).';

  @override
  String get createPollVoteAnonymityTitle => 'إخفاء هوية Vote';

  @override
  String get createPollAnonymityAnonymousSubtitle => 'الإعداد الافتراضي الموصى به لمنصات التصويت المدني.';

  @override
  String get createPollAnonymityPublicSubtitle => 'استخدم بحذر: قد ترتبط الأصوات بالهويات (ميزة مستقبلية).';

  @override
  String get createPollResultsValidityTitle => 'النتائج والصلاحية';

  @override
  String get createPollResultsValiditySubtitle => 'تحكّم في وقت ظهور النتائج وحدد حدًا أدنى للنصاب إذا لزم الأمر.';

  @override
  String get createPollResultsVisibilityFieldLabel => 'ظهور النتائج';

  @override
  String get createPollQuorumTitle => 'النصاب (اختياري)';

  @override
  String get createPollQuorumSubtitle => 'إذا تم تحديده، يُعتبر الـ Vote صالحًا فقط عند بلوغ هذا العدد الأدنى من الأصوات. اتركه فارغًا لعدم اشتراط نصاب.';

  @override
  String get createPollQuorumMinVotesFieldLabel => 'الحد الأدنى لعدد الأصوات';

  @override
  String get createPollTimingTitle => 'التوقيت';

  @override
  String get createPollTimingSubtitle => 'حدّد الفترة التي يجب أن يكون فيها الـ Vote مفتوحًا للتصويت.';

  @override
  String get createPollStartDateLabel => 'تاريخ البدء';

  @override
  String get createPollEndDateLabel => 'تاريخ الانتهاء';

  @override
  String get createPollChangeDateButtonLabel => 'تغيير';

  @override
  String get createPollTimingStatusInfo => 'سيتم تحديد الحالة الأولية (مفتوح/مجدول/مغلق) تلقائيًا بناءً على هذه التواريخ.';

  @override
  String get createPollSuccessMessage => 'تم إنشاء Vote بنجاح';

  @override
  String get createPollSubmitCreatingLabel => 'جارٍ الإنشاء...';

  @override
  String get createPollSubmitLabel => 'إنشاء Vote';

  @override
  String get createPollPollTypeYesNoLabel => 'نعم / لا';

  @override
  String get createPollPollTypeSingleChoiceLabel => 'إجابة واحدة';

  @override
  String get createPollPollTypeMultipleChoiceLabel => 'عدة إجابات';

  @override
  String get createPollPollTypeApprovalLabel => 'تصويت بالموافقة';

  @override
  String get createPollPollTypeRankedLabel => 'اختيار ترتيبي';

  @override
  String get createPollPollTypeScoreLabel => 'نقاط / تقييم';

  @override
  String get createPollParticipationScopeEveryoneLabel => 'يمكن للجميع التصويت';

  @override
  String get createPollParticipationScopeGeoScopeOnlyLabel => 'فقط المستخدمون في بلد محدد';

  @override
  String get createPollAnonymityLevelAnonymousLabel => 'الأصوات مجهولة الهوية';

  @override
  String get createPollAnonymityLevelPublicLabel => 'الأصوات علنية (استخدام متقدم / مقيّد)';

  @override
  String get createPollResultsVisibilityAlwaysLabel => 'ظاهرة دائمًا (أثناء فتح Vote)';

  @override
  String get createPollResultsVisibilityAfterVoteLabel => 'تظهر فقط بعد التصويت';

  @override
  String get createPollResultsVisibilityAfterCloseLabel => 'تظهر فقط بعد إغلاق Vote';

  @override
  String get homeLoginButton => 'تسجيل الدخول';

  @override
  String get homeRegisterButton => 'إنشاء حساب';

  @override
  String get homeProfileButton => 'الملف الشخصي';

  @override
  String get homeLogoutButton => 'تسجيل الخروج';

  @override
  String get homeLogoutMessage => 'تم تسجيل الخروج. أنت الآن تستخدم التطبيق كضيف (للقراءة فقط).';

  @override
  String get homeSearchHint => 'ابحث عن مدن وبلدان وحسابات ومحتوى...';

  @override
  String get searchPageTitle => 'بحث';

  @override
  String get searchInputHint => 'ابحث في الحسابات وVote وNews وVoce...';

  @override
  String get searchClearTooltip => 'مسح البحث';

  @override
  String get searchTypeAll => 'الكل';

  @override
  String get searchTypePolls => 'Vote';

  @override
  String get searchTypeNews => 'News';

  @override
  String get searchTypePosts => 'Voce';

  @override
  String get searchTypeAccounts => 'الحسابات';

  @override
  String get searchSortHottest => 'الأكثر رواجًا';

  @override
  String get searchSortLatest => 'الأحدث';

  @override
  String get searchPollStatusAll => 'كل Vote';

  @override
  String get searchPollStatusOpen => 'مفتوح';

  @override
  String get searchPollStatusClosed => 'مغلق';

  @override
  String get searchIdleMessage => 'أدخل كلمة لبدء البحث.';

  @override
  String get searchErrorMessage => 'حدث خطأ أثناء البحث.';

  @override
  String get searchRetryButton => 'حاول مرة أخرى';

  @override
  String get searchEmptyMessage => 'لم يتم العثور على نتائج لهذا البحث.';

  @override
  String get searchContentUnavailable => 'المحتوى غير متاح';

  @override
  String get searchResultTypePoll => 'Vote';

  @override
  String get searchResultTypeNews => 'News';

  @override
  String get searchResultTypePost => 'Voce';

  @override
  String get searchResultTypeAccount => 'حساب';

  @override
  String get searchResultTypeMixed => 'مختلط';

  @override
  String homeUserStatusLoggedIn(Object userId) {
    return 'تم تسجيل الدخول باسم: $userId';
  }

  @override
  String get homeUserStatusGuest => 'وضع الضيف: يمكنك القراءة فقط. سجّل الدخول أو أنشئ حسابًا للتصويت والتعليق والتفاعل.';

  @override
  String get homeScopeLabelWorld => 'العالم – تصويتات وأخبار عالمية';

  @override
  String get homeScopeLabelCountry => 'البلد – تصويتات وأخبار وطنية';

  @override
  String get homeScopeLabelCity => 'المدينة – تصويتات وأخبار محلية';

  @override
  String get homeScopeShortWorld => 'العالم';

  @override
  String get homeScopeShortCountry => 'البلد';

  @override
  String get homeScopeShortCity => 'المدينة';

  @override
  String get homeScopeChipWorld => 'العالم';

  @override
  String get homeScopeChipItaly => 'إيطاليا';

  @override
  String get homeScopeChipTorino => 'تورينو';

  @override
  String get homeScopeChangedWorld => 'تم تغيير النطاق إلى العالم';

  @override
  String get homeScopeChangedItaly => 'تم تغيير النطاق إلى إيطاليا';

  @override
  String get homeScopeChangedTorino => 'تم تغيير النطاق إلى تورينو';

  @override
  String get followScopeButtonFollowed => 'تتابعها';

  @override
  String get followScopeButtonFollow => 'متابعة هذه المنطقة';

  @override
  String get homeTrendingTitle => 'Pulse الآن';

  @override
  String get homeTrendingError => 'تعذر تحميل Pulse الآن لهذه المنطقة.';

  @override
  String get homeTrendingEmpty => 'لا يوجد محتوى في Pulse الآن لهذه المنطقة حاليًا.';

  @override
  String homeForYouTitle(Object scope) {
    return 'Pulse ($scope)';
  }

  @override
  String get homeForYouError => 'تعذر تحميل Pulse لهذه المنطقة.';

  @override
  String get homeForYouEmpty => 'لا يوجد محتوى مقترح في Pulse لهذه المنطقة حاليًا.';

  @override
  String homePollsTitle(Object scope) {
    return 'Vote في الواجهة ($scope)';
  }

  @override
  String get homePollsEmptyTitle => 'لا يوجد Vote لهذه المنطقة';

  @override
  String get homePollsEmptySubtitle => 'لا توجد Vote متاحة لهذه المنطقة.';

  @override
  String get homePollsViewAllButton => 'عرض Vote';

  @override
  String homeNewsTitle(Object scope) {
    return 'أهم News ($scope)';
  }

  @override
  String get homeNewsErrorTitle => 'تعذر تحميل News';

  @override
  String get homeNewsErrorSubtitle => 'حدثت مشكلة أثناء تحميل News لهذه المنطقة.';

  @override
  String get homeNewsEmptyTitle => 'لا توجد News لهذه المنطقة';

  @override
  String get homeNewsEmptySubtitle => 'لا توجد عناصر News لهذا النطاق حاليًا.';

  @override
  String get homeNewsViewAllButton => 'عرض كل News';

  @override
  String get homeNewsBreakingBadge => 'عاجل';

  @override
  String homeSocialTitle(Object scope) {
    return 'Voce ($scope)';
  }

  @override
  String get homeSocialErrorTitle => 'تعذر تحميل Voce';

  @override
  String get homeSocialErrorSubtitle => 'حدثت مشكلة أثناء تحميل Voce لهذه المنطقة.';

  @override
  String get homeSocialEmptyTitle => 'لا توجد Voce لهذه المنطقة';

  @override
  String get homeSocialEmptySubtitle => 'لا يوجد محتوى Voce لهذه المنطقة حاليًا.';

  @override
  String get homeSocialViewFeedButton => 'عرض كل Voce';

  @override
  String get pollDetail_title => 'تفاصيل Vote';

  @override
  String get pollDetail_removeFromFavoritesTooltip => 'إزالة من المحفوظات';

  @override
  String get pollDetail_addToFavoritesTooltip => 'حفظ';

  @override
  String get pollDetail_chipAnonymous => 'Vote مجهول الهوية';

  @override
  String get pollDetail_chipPublic => 'Vote علني';

  @override
  String get pollDetail_chipRestrictedGeo => 'مقيّد بالنطاق الجغرافي';

  @override
  String pollDetail_quorumReached(int currentVotes, int requiredVotes) {
    return 'تم بلوغ النصاب ($currentVotes / $requiredVotes)';
  }

  @override
  String pollDetail_quorumNotReached(int currentVotes, int requiredVotes) {
    return 'لم يتم بلوغ النصاب ($currentVotes / $requiredVotes)';
  }

  @override
  String get pollDetail_optionsTitle => 'الخيارات';

  @override
  String get pollDetail_statusClosedMessage => 'هذا الـ Vote مغلق.';

  @override
  String get pollDetail_statusScheduledMessage => 'هذا الـ Vote لم يفتح بعد.';

  @override
  String get pollDetail_statusNotAvailableMessage => 'التصويت غير متاح.';

  @override
  String get pollDetail_voteSubmitted => 'تم إرسال التصويت بنجاح!';

  @override
  String get pollDetail_voteButton => 'تصويت';

  @override
  String get pollDetail_resultsTitle => 'النتائج';

  @override
  String pollDetail_outcomePrefix(Object label) {
    return 'النتيجة: $label';
  }

  @override
  String get pollDetail_noResults => 'لا توجد نتائج متاحة بعد.';

  @override
  String get pollDetail_resultsAfterVote => 'ستظهر النتائج بعد تصويتك.';

  @override
  String get pollDetail_resultsWhenClosed => 'ستظهر النتائج عند إغلاق Vote.';

  @override
  String get pollType_yesNo => 'نعم / لا';

  @override
  String get pollType_singleChoice => 'اختيار واحد';

  @override
  String get pollType_multipleChoice => 'اختيارات متعددة';

  @override
  String get pollType_approval => 'موافقة';

  @override
  String get pollStatus_draft => 'مسودة';

  @override
  String get pollStatus_open => 'مفتوح';

  @override
  String get pollStatus_closed => 'مغلق';

  @override
  String get pollStatus_scheduled => 'مجدول';

  @override
  String get pollGeo_global => 'عالمي';

  @override
  String get pollGeo_local => 'محلي';

  @override
  String get pollOutcome_approved => 'مقبول';

  @override
  String get pollOutcome_rejected => 'مرفوض';

  @override
  String get pollOutcome_tie => 'تعادل';

  @override
  String get pollOutcome_noMajority => 'لا توجد أغلبية';

  @override
  String get pollOutcome_notApplicable => 'غير منطبق';

  @override
  String get pollList_title => 'Vote';

  @override
  String get pollList_scopeWorld => 'العالم';

  @override
  String get pollList_scopeCountryFallback => 'البلد';

  @override
  String get pollList_scopeCityFallback => 'المدينة';

  @override
  String get pollList_scopeDescriptionGlobal => 'عرض Vote العالمية.';

  @override
  String get pollList_scopeDescriptionCountry => 'عرض Vote لهذا البلد.';

  @override
  String get pollList_scopeDescriptionCity => 'عرض Vote لهذه المدينة.';

  @override
  String get pollList_filterStatus_all => 'الكل';

  @override
  String get pollList_filterStatus_open => 'مفتوحة';

  @override
  String get pollList_filterStatus_closed => 'مغلقة';

  @override
  String get pollList_sort_latest => 'الأحدث';

  @override
  String get pollList_sort_hottest => 'الأكثر رواجًا';

  @override
  String get pollList_filterScope_currentArea => 'المنطقة الحالية';

  @override
  String pollList_headerTitle(Object scopeLabel, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم العثور على $count Vote',
      one: 'تم العثور على Vote واحد',
      zero: 'لم يتم العثور على Vote',
    );
    return '$scopeLabel · $_temp0';
  }

  @override
  String get pollList_createPollButton => 'إنشاء Vote';

  @override
  String get pollList_paginationHint => 'مرّر لتحميل المزيد من Vote…';

  @override
  String get pollList_emptyMessage => 'لا توجد Vote تطابق هذا الفلتر لهذه المنطقة.';

  @override
  String get pollType_ranked => 'اختيار ترتيبي';

  @override
  String get pollType_score => 'تصويت بالنقاط';

  @override
  String get pollVisibility_whileOpen => 'النتائج ظاهرة أثناء الفتح';

  @override
  String get pollVisibility_afterVote => 'النتائج ظاهرة بعد التصويت';

  @override
  String get pollVisibility_afterClose => 'النتائج ظاهرة بعد الإغلاق';

  @override
  String get pollCard_countryRestricted => 'مقيّد بالبلد';

  @override
  String pollCard_restrictedToCountry(Object countryName) {
    return 'مقيّد إلى $countryName';
  }

  @override
  String pollCard_quorumLabel(int minVotes) {
    return 'النصاب $minVotes';
  }

  @override
  String get pollCard_resultsVisibleChip => 'النتائج ظاهرة';

  @override
  String get pollCard_resultsAfterVoteChip => 'بعد التصويت';

  @override
  String get pollCard_resultsAfterCloseChip => 'بعد الإغلاق';

  @override
  String get pollCard_publicOfficialPublisher => 'مسؤول عام';

  @override
  String get pollCard_institutionPublisher => 'مؤسسة';

  @override
  String get pollCard_representativePublisher => 'ممثل';

  @override
  String pollCard_voteCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أصوات',
      one: 'صوت',
    );
    return '$_temp0';
  }

  @override
  String get pollCard_viewDetails => 'عرض التفاصيل';

  @override
  String pollResult_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'النتائج ($count أصوات)',
      one: 'النتائج (صوت واحد)',
      zero: 'النتائج (لا أصوات)',
    );
    return '$_temp0';
  }

  @override
  String get voteError_noSelection => 'يرجى تحديد خيار واحد على الأقل.';

  @override
  String get voteError_unauthorized => 'غير مسموح لك بالتصويت في هذا الـ Vote.';

  @override
  String get voteError_generic => 'تعذر إرسال التصويت. يرجى المحاولة مرة أخرى.';

  @override
  String get commentSection_title => 'التعليقات';

  @override
  String get commentSection_sortLabel => 'ترتيب:';

  @override
  String get commentSection_sortOldest => 'الأقدم';

  @override
  String get commentSection_sortNewest => 'الأحدث';

  @override
  String get commentSection_errorGeneric => 'حدث خطأ أثناء تحميل التعليقات.';

  @override
  String get commentSection_empty => 'لا توجد تعليقات بعد. كن أول من يعلّق.';

  @override
  String get commentSection_loadMore => 'تحميل المزيد من التعليقات';

  @override
  String commentSection_replyingTo(Object snippet) {
    return 'الرد على: $snippet';
  }

  @override
  String get commentSection_cancelReply => 'إلغاء';

  @override
  String get commentSection_inputHintRoot => 'أضف تعليقًا...';

  @override
  String get commentSection_inputHintReply => 'اكتب ردًا...';

  @override
  String get commentSection_deleteAction => 'حذف';

  @override
  String get commentSection_replyAction => 'رد';

  @override
  String get commentSection_youBadge => 'أنت';

  @override
  String get newsDetail_title => 'تفاصيل News';

  @override
  String get newsDetail_breakingBadge => 'عاجل';

  @override
  String get newsDetail_removeFromFavoritesTooltip => 'إزالة من المحفوظات';

  @override
  String get newsDetail_addToFavoritesTooltip => 'حفظ';

  @override
  String get newsDetail_bodyFallback => 'لا يوجد نص إضافي متاح لهذا العنصر من News.';

  @override
  String get newsDetail_footerMoreContext => 'سيتم إضافة المزيد من السياق والمصادر قريبًا.';

  @override
  String get newsFeed_title => 'News';

  @override
  String get newsFeed_scopeWorld => 'العالم';

  @override
  String get newsFeed_scopeCountry => 'البلد';

  @override
  String get newsFeed_scopeCity => 'المدينة';

  @override
  String newsFeed_scopeLabel(Object scope) {
    return 'النطاق: $scope';
  }

  @override
  String get newsFeed_scopeGlobalDescription => 'عرض News العالمية.';

  @override
  String get newsFeed_scopeCountryDescription => 'عرض News لهذا البلد.';

  @override
  String get newsFeed_scopeCityDescription => 'عرض News لهذه المدينة.';

  @override
  String get newsFeed_emptyTitle => 'لا توجد News متاحة لهذه المنطقة.';

  @override
  String get newsFeed_emptySubtitle => 'اسحب للتحديث أو حاول مرة أخرى لاحقًا.';

  @override
  String newsFeed_itemsFound(int count) {
    return 'تم العثور على $count عنصر من News';
  }

  @override
  String get newsFeed_loadingMoreHint => 'مرّر لتحميل المزيد من News…';

  @override
  String get newsFeed_errorTitle => 'تعذر تحميل News';

  @override
  String get newsFeed_errorGeneric => 'حدث خطأ غير متوقع أثناء تحميل News.';

  @override
  String get newsFeed_retryButton => 'إعادة المحاولة';

  @override
  String get newsCard_headerTitle => 'News';

  @override
  String get newsFeed_errorUnauthorized => 'إعداد News غير صالح (مفتاح API).';

  @override
  String get newsFeed_errorRateLimited => 'طلبات كثيرة جدًا. يرجى المحاولة مرة أخرى بعد قليل.';

  @override
  String get newsFeed_errorServerUnavailable => 'خدمة News غير متاحة مؤقتًا. يرجى المحاولة مرة أخرى لاحقًا.';

  @override
  String get newsFeed_errorTimeout => 'يستغرق الطلب وقتًا طويلًا. يرجى المحاولة مرة أخرى.';

  @override
  String get newsFeed_errorNetwork => 'لا يوجد اتصال. تحقق من الإنترنت وحاول مرة أخرى.';

  @override
  String get newsFeed_moreTooltip => 'المزيد';

  @override
  String get newsFeed_actionCopyTitle => 'نسخ العنوان';

  @override
  String get newsFeed_actionRefreshFeed => 'تحديث الموجز';

  @override
  String get newsFeed_copiedTitleToast => 'تم نسخ العنوان';

  @override
  String get newsFeed_languageTooltip => 'لغة News';

  @override
  String get newsFeed_languageAuto => 'تلقائي';

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
  String get newsFeed_languageLimitedHint => 'المصادر محدودة بهذه اللغة. جرّب الوضع التلقائي.';

  @override
  String get newsTopic_all => 'الكل';

  @override
  String get newsTopic_world => 'العالم';

  @override
  String get newsTopic_nation => 'وطني';

  @override
  String get newsTopic_business => 'الأعمال';

  @override
  String get newsTopic_technology => 'التكنولوجيا';

  @override
  String get newsTopic_science => 'العلوم';

  @override
  String get newsTopic_health => 'الصحة';

  @override
  String get newsTopic_sports => 'الرياضة';

  @override
  String get newsTopic_entertainment => 'الترفيه';

  @override
  String get newsDetail_openSource => 'فتح المقال المصدر';

  @override
  String get newsDetail_openSourceUnavailable => 'تعذر فتح المقال المصدر';

  @override
  String get socialFeedTitle => 'Voce';

  @override
  String get socialFeedCreatePostButton => 'إنشاء Voce';

  @override
  String get commonCancelButton => 'إلغاء';

  @override
  String get commonApplyButton => 'تطبيق';

  @override
  String get homeScopeChooseCountry => 'اختر بلدًا';

  @override
  String get homeScopeCountrySearchHint => 'ابحث عن بلد أو رمز...';

  @override
  String get homeScopeChooseCity => 'اختر مدينة';

  @override
  String homeScopeCountryWithCode(String code) {
    return 'البلد: $code';
  }

  @override
  String get homeScopeCityFieldLabel => 'المدينة';

  @override
  String get homeScopeCityExampleHint => 'اكتب اسم مدينة، مثل Merano';

  @override
  String get homeScopeCityRequiredError => 'أدخل مدينة.';

  @override
  String get homeScopeCityNotFoundError => 'لم يتم العثور على المدينة في البلد المحدد.';

  @override
  String get homeScopeCityVerificationError => 'تعذر التحقق من المدينة. حاول مرة أخرى.';

  @override
  String get homeScopeVerifyingButton => 'جارٍ التحقق...';

  @override
  String get homeMapOpenButton => 'فتح الخريطة';

  @override
  String get homeHeroHeadline => 'شكّلوا المستقبل.\nمعًا.';

  @override
  String get homeHeroPollsAction => 'Vote';

  @override
  String get homeHeroNewsAction => 'News';

  @override
  String get homeHeroCreateAction => 'إنشاء';

  @override
  String get homeHeroExploreAction => 'استكشاف';

  @override
  String get homeAccountMenuLabel => 'الحساب';

  @override
  String get homeThemeSystemMenuItem => 'السمة: النظام';

  @override
  String get homeThemeLightMenuItem => 'السمة: فاتحة';

  @override
  String get homeThemeDarkMenuItem => 'السمة: داكنة';

  @override
  String get profileAppLanguageTitle => 'لغة التطبيق';

  @override
  String get profileAppLanguageSystem => 'النظام';

  @override
  String get profileAppLanguageSystemDescription => 'يستخدم لغة جهازك';

  @override
  String get profileAppLanguageItalian => 'الإيطالية';

  @override
  String get profileAppLanguageEnglish => 'الإنجليزية';

  @override
  String get homeNotificationsTooltip => 'الإشعارات';

  @override
  String get postCard_authorFallback => 'الكاتب';

  @override
  String get postCard_globalLocation => 'عالمي';

  @override
  String get commonSaveButton => 'حفظ';

  @override
  String get commonDeleteButton => 'حذف';

  @override
  String get contentReport_menuAction => 'الإبلاغ عن المحتوى';

  @override
  String get contentReport_dialogTitle => 'الإبلاغ عن المحتوى';

  @override
  String get contentReport_authenticationRequired => 'يجب تسجيل الدخول للإبلاغ عن المحتوى';

  @override
  String get contentReport_submittedMessage => 'تم إرسال البلاغ';

  @override
  String get contentReport_alreadySubmittedMessage => 'لقد أبلغت عن هذا المحتوى بالفعل';

  @override
  String get contentReport_submitError => 'تعذر إرسال البلاغ';

  @override
  String get contentReport_sendButton => 'إرسال';

  @override
  String get contentReport_reasonSpam => 'محتوى مزعج';

  @override
  String get contentReport_reasonHarassment => 'تحرش أو إساءة';

  @override
  String get contentReport_reasonHateSpeech => 'خطاب كراهية';

  @override
  String get contentReport_reasonMisinformation => 'معلومات مضللة';

  @override
  String get contentReport_reasonViolence => 'عنف';

  @override
  String get contentReport_reasonOther => 'أخرى';

  @override
  String get postDetail_title => 'تفاصيل Voce';

  @override
  String get postDetail_favoriteUpdateError => 'تعذر تحديث العناصر المحفوظة';

  @override
  String get postDetail_shareMessage => 'افتح Social Vote لعرض هذه الـ Voce.';

  @override
  String get postDetail_shareError => 'تعذر مشاركة Voce';

  @override
  String get postDetail_editDialogTitle => 'تعديل Voce';

  @override
  String get postDetail_editTitleFieldLabel => 'العنوان';

  @override
  String get postDetail_editContentFieldLabel => 'المحتوى';

  @override
  String get postDetail_editRequiredError => 'العنوان والمحتوى مطلوبان.';

  @override
  String get postDetail_updateSuccess => 'تم تحديث Voce';

  @override
  String get postDetail_updateError => 'تعذر تحديث Voce';

  @override
  String get postDetail_deleteDialogTitle => 'حذف هذه الـ Voce؟';

  @override
  String get postDetail_deleteDialogMessage => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get postDetail_deleteError => 'تعذر حذف Voce';

  @override
  String get postDetail_editMenuItem => 'تعديل Voce';

  @override
  String get postDetail_deleteMenuItem => 'حذف Voce';

  @override
  String get postDetail_loadError => 'حدث خطأ أثناء تحميل Voce.';

  @override
  String get postDetail_notFound => 'لم يتم العثور على Voce.';

  @override
  String get postDetail_errorTitle => 'خطأ';

  @override
  String get postDetail_authorFallback => 'الكاتب';

  @override
  String get postDetail_shareAction => 'مشاركة';

  @override
  String get postDetail_saveAction => 'حفظ';

  @override
  String get postDetail_addToFavoritesTooltip => 'حفظ';

  @override
  String get postDetail_removeFromFavoritesTooltip => 'إزالة من المحفوظات';

  @override
  String get newsDetail_favoriteUpdateError => 'تعذر تحديث العناصر المحفوظة';

  @override
  String get newsDetail_shareMessage => 'افتح Social Vote لعرض عنصر News هذا.';

  @override
  String get newsDetail_shareError => 'تعذر مشاركة News';

  @override
  String get newsDetail_shareTooltip => 'مشاركة';

  @override
  String get authLoginPageTitle => 'تسجيل الدخول';

  @override
  String get authLoginHeadline => 'مرحبًا بعودتك';

  @override
  String get authEmailLabel => 'البريد الإلكتروني';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authRememberMeLabel => 'تذكرني';

  @override
  String get authForgotPasswordAction => 'هل نسيت كلمة المرور؟';

  @override
  String get authLoginButton => 'تسجيل الدخول';

  @override
  String get authRegisterPrompt => 'ليس لديك حساب؟';

  @override
  String get authRegisterAction => 'إنشاء حساب';

  @override
  String get authRegisterPageTitle => 'إنشاء حساب';

  @override
  String get authRegisterHeadline => 'إنشاء حساب';

  @override
  String get authPersonalAccountOwnershipTitle => 'تسجيل الدخول يعود دائمًا إلى شخص';

  @override
  String get authPersonalAccountOwnershipBody => 'إذا كنت تمثل منظمة، فأنشئ حسابك الشخصي. بعد تسجيل الدخول، يمكنك طلب منظمة موثقة وإدارتها من Workspace.';

  @override
  String get authOrganizationPathAction => 'كيف يعمل الأمر للمنظمات';

  @override
  String get authDisplayNameLabel => 'الاسم العام';

  @override
  String get authUsernameLabel => 'اسم المستخدم';

  @override
  String get authCountryOfResidenceLabel => 'بلد الإقامة';

  @override
  String get authCityOfResidenceLabel => 'مدينة الإقامة (اختياري)';

  @override
  String get authConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get authLegalConsentPrefix => 'أؤكد أن عمري لا يقل عن 18 عامًا. أوافق على شروط الخدمة وأؤكد أنني قرأت سياسة الخصوصية.';

  @override
  String get authTermsOfServiceAction => 'شروط الخدمة';

  @override
  String get authPrivacyPolicyAction => 'سياسة الخصوصية';

  @override
  String get authRegisterButton => 'إنشاء حساب';

  @override
  String get authLoginPrompt => 'لديك حساب بالفعل؟';

  @override
  String get authLoginAction => 'تسجيل الدخول';

  @override
  String get authForgotPasswordDialogTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get authForgotPasswordDialogBody => 'أدخل عنوان البريد الإلكتروني المرتبط بحسابك. سنرسل لك رابطًا لاختيار كلمة مرور جديدة.';

  @override
  String get authForgotPasswordSendButton => 'إرسال الرابط';

  @override
  String get authPasswordResetEmailSent => 'تم إرسال بريد إعادة تعيين كلمة المرور. تحقق من صندوق الوارد.';

  @override
  String get authResetPasswordPageTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get authResetPasswordHeadline => 'اختر كلمة مرور جديدة';

  @override
  String get authNewPasswordLabel => 'كلمة المرور الجديدة';

  @override
  String get authConfirmNewPasswordLabel => 'تأكيد كلمة المرور الجديدة';

  @override
  String get authUpdatePasswordButton => 'تحديث كلمة المرور';

  @override
  String get authPasswordUpdated => 'تم تحديث كلمة المرور بنجاح.';

  @override
  String get authEmailConfirmationTitle => 'تحقق من بريدك الإلكتروني';

  @override
  String get authEmailConfirmationIntro => 'أرسلنا رابط تأكيد إلى:';

  @override
  String get authEmailConfirmationInstructions => 'افتح الرابط في الرسالة للتحقق من عنوانك. بعد التأكيد، عد إلى التطبيق وسجّل الدخول.';

  @override
  String get authBackToLoginButton => 'العودة لتسجيل الدخول';

  @override
  String get authUseAnotherEmailButton => 'استخدام عنوان بريد إلكتروني آخر';

  @override
  String get authEmailRequiredError => 'أدخل بريدك الإلكتروني.';

  @override
  String get authEmailInvalidError => 'أدخل عنوان بريد إلكتروني صالحًا.';

  @override
  String get authPasswordRequiredError => 'أدخل كلمة المرور.';

  @override
  String get authPasswordTooShortError => 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل.';

  @override
  String get authDisplayNameRequiredError => 'أدخل اسمك العام.';

  @override
  String get authDisplayNameTooShortError => 'الاسم العام قصير جدًا.';

  @override
  String get authUsernameRequiredError => 'أدخل اسم مستخدم.';

  @override
  String get authUsernameInvalidError => 'استخدم من 3 إلى 20 حرفًا: أحرف إنجليزية صغيرة وأرقام وشرطة سفلية.';

  @override
  String get authUsernameAlreadyTakenError => 'اسم المستخدم مستخدم بالفعل.';

  @override
  String get authCountryRequiredError => 'اختر بلد إقامتك.';

  @override
  String get authCityRequiredError => 'أدخل مدينة إقامتك.';

  @override
  String get authConfirmPasswordRequiredError => 'أكد كلمة المرور.';

  @override
  String get authPasswordsDoNotMatchError => 'كلمتا المرور غير متطابقتين.';

  @override
  String get authLegalConsentRequiredError => 'لإنشاء حساب، أكد أن عمرك لا يقل عن 18 عامًا، ووافق على شروط الخدمة، وأكد أنك قرأت سياسة الخصوصية.';

  @override
  String get authForgotPasswordEmailRequiredError => 'أدخل البريد الإلكتروني للحساب الذي تريد استعادته.';

  @override
  String get authInvalidCredentialsError => 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get authEmailAlreadyRegisteredError => 'هذا البريد الإلكتروني مسجّل بالفعل.';

  @override
  String get authEmailNotConfirmedError => 'لم يتم تأكيد البريد الإلكتروني. تحقق من صندوق الوارد قبل تسجيل الدخول.';

  @override
  String get authTooManyAttemptsError => 'محاولات كثيرة جدًا. انتظر بضع دقائق وحاول مرة أخرى.';

  @override
  String get authNetworkError => 'خطأ في الشبكة. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get authLoginGenericError => 'فشل تسجيل الدخول. حاول مرة أخرى.';

  @override
  String get authRegisterGenericError => 'فشل إنشاء الحساب. حاول مرة أخرى.';

  @override
  String get authPasswordResetGenericError => 'تعذر إرسال رابط إعادة التعيين. حاول مرة أخرى.';

  @override
  String get authPasswordUpdateGenericError => 'تعذر تحديث كلمة المرور. حاول مرة أخرى.';

  @override
  String get authShowPasswordTooltip => 'إظهار كلمة المرور';

  @override
  String get authHidePasswordTooltip => 'إخفاء كلمة المرور';

  @override
  String get authTermsPageTitle => 'شروط الخدمة';

  @override
  String get authPrivacyPageTitle => 'سياسة الخصوصية';

  @override
  String get authCloseButton => 'إغلاق';

  @override
  String get pollDetail_favoriteUpdateError => 'تعذر تحديث العناصر المحفوظة';

  @override
  String get pollDetail_shareMessage => 'افتح Social Vote لعرض هذا الـ Vote والتصويت فيه.';

  @override
  String get pollDetail_shareError => 'تعذر مشاركة Vote';

  @override
  String get pollDetail_editPermissionError => 'يمكنك تعديل Vote الخاصة بك فقط إذا لم تُسجل فيها أصوات';

  @override
  String get pollDetail_editSuccessMessage => 'تم تحديث Vote';

  @override
  String get pollDetail_editMenuItem => 'تعديل Vote';

  @override
  String get pollDetail_editSavingMenuItem => 'جارٍ الحفظ...';

  @override
  String get pollDetail_deletePermissionError => 'يمكنك حذف Vote الخاصة بك فقط';

  @override
  String get pollDetail_deleteError => 'تعذر حذف Vote';

  @override
  String get pollDetail_deleteDialogTitle => 'حذف Vote';

  @override
  String pollDetail_deleteDialogMessage(String title) {
    return 'هل تريد حقًا حذف \"$title\"؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get pollDetail_deleteMenuItem => 'حذف Vote';

  @override
  String get pollDetail_deleteDeletingMenuItem => 'جارٍ الحذف...';

  @override
  String get pollDetail_publicVotesAvailableTitle => 'الأصوات العلنية متاحة';

  @override
  String get pollDetail_publicVotesAvailableMessage => 'يتيح لك هذا الـ Vote معرفة من صوّت لكل خيار.';

  @override
  String get pollDetail_publicVotesAction => 'عرض الأصوات العلنية';

  @override
  String get pollDetail_retryButton => 'حاول مرة أخرى';

  @override
  String get pollDetail_voteErrorNoOption => 'حدّد خيارًا واحدًا على الأقل';

  @override
  String get pollDetail_voteErrorAuthenticationRequired => 'يجب تسجيل الدخول للتصويت';

  @override
  String get pollDetail_voteErrorClosed => 'هذا الـ Vote مغلق';

  @override
  String get pollDetail_voteErrorAlreadyVoted => 'لقد صوّت بالفعل في هذا الـ Vote';

  @override
  String get pollDetail_voteErrorGeneric => 'تعذر إرسال التصويت';

  @override
  String get pollDetail_publicVotesSheetTitle => 'الأصوات العلنية';

  @override
  String get pollDetail_publicVotesSheetDescription => 'يمكنك هنا معرفة من صوّت لكل خيار في هذا الـ Vote.';

  @override
  String get pollDetail_publicVotesSearchHint => 'البحث عن مستخدمين';

  @override
  String get pollDetail_publicVotesLoadError => 'تعذر تحميل الأصوات العلنية';

  @override
  String get pollDetail_publicVotesEmpty => 'لا توجد أصوات علنية متاحة';

  @override
  String get pollDetail_publicVotesSearchEmpty => 'لم يتم العثور على مستخدمين لهذا البحث';

  @override
  String pollDetail_publicVotesResultsCount(int count) {
    return 'تم تحميل $count نتيجة';
  }

  @override
  String get pollDetail_publicVotesLoadMore => 'تحميل المزيد';

  @override
  String get pollDetail_publicVotesUserFallback => 'مستخدم';

  @override
  String get pollDetail_editDialogTitle => 'تعديل Vote';

  @override
  String get pollDetail_editTitleFieldLabel => 'العنوان';

  @override
  String get pollDetail_editTitleRequired => 'العنوان مطلوب';

  @override
  String get pollDetail_editDescriptionFieldLabel => 'الوصف';

  @override
  String get pollDetail_editError => 'تعذر تحديث Vote';

  @override
  String get pollDetail_loadError => 'تعذر تحميل Vote';

  @override
  String get pollDetail_notFound => 'لم يتم العثور على Vote';

  @override
  String get profileEditPageTitle => 'تعديل الملف الشخصي';

  @override
  String get profileLoginRequiredMessage => 'يجب تسجيل الدخول لتعديل ملفك الشخصي.';

  @override
  String get profileAvatarUploading => 'جارٍ الرفع...';

  @override
  String get profileUploadAvatarButton => 'رفع صورة الملف';

  @override
  String get profileDisplayNameLabel => 'الاسم المعروض';

  @override
  String get profileDisplayNameRequiredError => 'الاسم المعروض مطلوب.';

  @override
  String get profileUsernameHint => 'مثال: mario_roma';

  @override
  String get profileUsernameHelper => 'من 3 إلى 20 حرفًا: أحرف صغيرة وأرقام وشرطة سفلية';

  @override
  String get profileAvatarUrlLabel => 'رابط صورة الملف';

  @override
  String get profileBioLabel => 'نبذة';

  @override
  String get profileClearCountryButton => 'مسح البلد';

  @override
  String get profileCityResidenceHelper => 'يتم التحقق من مدينة الإقامة مقابل البلد المحدد قبل الحفظ.';

  @override
  String get profileCityNotFoundError => 'لم يتم العثور على المدينة في البلد المحدد.';

  @override
  String get profileCityVerificationError => 'تعذر التحقق من المدينة الآن.';

  @override
  String get profileAvatarUploadError => 'تعذر رفع صورة الملف.';

  @override
  String get profileAccountSectionTitle => 'الحساب';

  @override
  String get profileAccountEmailHelper => 'لا يمكن تغيير البريد الإلكتروني للحساب من هذه الشاشة.';

  @override
  String get profileChangePasswordAction => 'تغيير كلمة المرور';

  @override
  String get profileChangePasswordDescription => 'عيّن كلمة مرور جديدة لهذا الحساب.';

  @override
  String get notificationsPageTitle => 'الإشعارات';

  @override
  String get notificationsMarkAllReadAction => 'تحديد الكل كمقروء';

  @override
  String get notificationsNoTargetMessage => 'لا توجد وجهة متاحة لهذا الإشعار.';

  @override
  String get notificationsTargetUnavailableMessage => 'المحتوى المرتبط بهذا الإشعار غير متاح.';

  @override
  String get notificationsLoadError => 'تعذر تحميل الإشعارات.';

  @override
  String get notificationsRetryButton => 'حاول مرة أخرى';

  @override
  String get notificationsEmptyMessage => 'لا توجد إشعارات متاحة.';

  @override
  String get notificationsCommentReplyTitle => 'رد جديد على تعليقك';

  @override
  String get notificationsMentionTitle => 'تمت الإشارة إليك';

  @override
  String get notificationsPollResultTitle => 'تحديث Vote';

  @override
  String notificationsCommentReplySubtitle(String actor, String target) {
    return 'رد المستخدم $actor في $target';
  }

  @override
  String notificationsMentionSubtitle(String actor, String target) {
    return 'أشار إليك المستخدم $actor في $target';
  }

  @override
  String notificationsPollResultSubtitle(String target) {
    return 'توجد نتيجة جديدة في $target';
  }

  @override
  String get notificationsTargetPost => 'Voce';

  @override
  String get notificationsTargetNews => 'مقال News';

  @override
  String get notificationsTargetPoll => 'Vote';

  @override
  String get notificationsTargetVideo => 'فيديو';

  @override
  String get notificationsTargetContent => 'محتوى';

  @override
  String get notificationsUserFallback => 'مستخدم';

  @override
  String get profileDeleteAccountAction => 'حذف الحساب';

  @override
  String get profileDeleteAccountDescription => 'حذف الحساب والوصول نهائيًا';

  @override
  String get profileDeleteAccountDialogTitle => 'حذف الحساب';

  @override
  String get profileDeleteAccountDialogMessage => 'هذا الإجراء نهائي ولا يمكن استعادة الحساب. اكتب DELETE للتأكيد.';

  @override
  String get profileDeleteAccountConfirmationLabel => 'تأكيد الحذف';

  @override
  String get profileDeleteAccountConfirmationHint => 'اكتب DELETE';

  @override
  String get profileDeleteAccountConfirmationError => 'اكتب DELETE للمتابعة.';

  @override
  String get profileDeleteAccountCancelButton => 'إلغاء';

  @override
  String get profileDeleteAccountConfirmButton => 'حذف نهائي';

  @override
  String get profileDeleteAccountFailureMessage => 'تعذر حذف الحساب. حاول مرة أخرى.';

  @override
  String get identityActorTypePerson => 'شخص';

  @override
  String get identityActorTypePublicOfficial => 'مسؤول عام';

  @override
  String get identityActorTypePublicInstitution => 'مؤسسة عامة';

  @override
  String get identityActorTypeVerifiedOrganization => 'منظمة موثقة';

  @override
  String get identityVerificationNotVerified => 'غير موثق';

  @override
  String get identityVerificationLevel1 => 'هوية موثقة';

  @override
  String get identityVerificationLevel2 => 'هوية موثقة متقدمة';

  @override
  String get identityBadgeLevel1 => 'هوية موثقة';

  @override
  String get identityBadgeLevel2 => 'هوية موثقة متقدمة';

  @override
  String get identityBadgePublicOfficial => 'مسؤول عام';

  @override
  String get identityBadgePublicInstitution => 'مؤسسة عامة';

  @override
  String get identityBadgeVerifiedOrganization => 'منظمة موثقة';

  @override
  String get identityOrganizationNameLabel => 'اسم المنظمة';

  @override
  String get identityOrganizationNameRequired => 'أدخل اسم المنظمة.';

  @override
  String get identityInstitutionLevelMunicipality => 'بلدي';

  @override
  String get identityInstitutionLevelProvince => 'إقليمي';

  @override
  String get identityInstitutionLevelRegion => 'جهوي';

  @override
  String get identityInstitutionLevelMinistry => 'وزارة';

  @override
  String get identityInstitutionLevelGovernment => 'حكومة';

  @override
  String get identityInstitutionLevelPublicAgency => 'هيئة عامة';

  @override
  String get identityInstitutionLevelOtherPublicBody => 'جهة عامة أخرى';

  @override
  String get verificationRequestPersonLevel1 => 'توثيق شخص — المستوى 1';

  @override
  String get verificationRequestPersonLevel2 => 'توثيق شخص — المستوى 2';

  @override
  String get verificationRequestPublicOfficial => 'توثيق مسؤول عام';

  @override
  String get verificationRequestPublicInstitution => 'توثيق مؤسسة عامة';

  @override
  String get verificationRequestVerifiedOrganization => 'توثيق منظمة';

  @override
  String get verificationCenterTitle => 'التوثيق ونوع الحساب';

  @override
  String get verificationCurrentAccountSection => 'الحساب الحالي';

  @override
  String verificationAccountTypeValue(String accountType) {
    return 'نوع الحساب: $accountType';
  }

  @override
  String verificationLevelValue(String level) {
    return 'مستوى التوثيق: $level';
  }

  @override
  String verificationOfficialTitleValue(String title) {
    return 'الصفة الرسمية: $title';
  }

  @override
  String verificationInstitutionNameValue(String name) {
    return 'المؤسسة: $name';
  }

  @override
  String verificationOrganizationNameValue(String name) {
    return 'المنظمة: $name';
  }

  @override
  String verificationInstitutionLevelValue(String level) {
    return 'مستوى المؤسسة: $level';
  }

  @override
  String get verificationActiveRequestSection => 'الطلب النشط';

  @override
  String get verificationProfileUnchangedUntilApproval => 'لن يتغير ملفك الحالي حتى تتم الموافقة على الطلب.';

  @override
  String get verificationCancelPendingAction => 'إلغاء الطلب المعلّق';

  @override
  String get verificationPendingBlocksNewRequests => 'لا يمكنك إرسال طلب جديد أثناء وجود طلب آخر قيد الانتظار.';

  @override
  String get verificationNoActiveRequestSection => 'لا يوجد طلب نشط';

  @override
  String get verificationNoActiveRequestDescription => 'ليس لديك حاليًا أي طلب قيد المراجعة.';

  @override
  String get verificationLastRejectedSection => 'آخر طلب مرفوض';

  @override
  String get verificationLastRejectedDescription => 'تم رفض طلبك الأخير.';

  @override
  String get verificationRejectedCanResubmit => 'لم يتغير ملفك الحالي. يمكنك تصحيح المعلومات وإرسال طلب جديد.';

  @override
  String get verificationAvailableRequestsSection => 'الطلبات المتاحة';

  @override
  String get verificationRequestLevel1Title => 'طلب توثيق شخص — المستوى 1';

  @override
  String get verificationRequestLevel1Subtitle => 'توثيق أساسي للهوية الشخصية';

  @override
  String get verificationRequestLevel2Title => 'طلب توثيق شخص — المستوى 2';

  @override
  String get verificationRequestLevel2Subtitle => 'توثيق متقدم للهوية الشخصية';

  @override
  String get verificationRequestPublicOfficialTitle => 'طلب حساب مسؤول عام';

  @override
  String get verificationRequestPublicOfficialSubtitle => 'يتطلب صفة رسمية ومراجعة';

  @override
  String get verificationRequestPublicInstitutionTitle => 'طلب حساب مؤسسة عامة';

  @override
  String get verificationRequestPublicInstitutionSubtitle => 'يتطلب اسم المؤسسة ومستواها ومراجعة';

  @override
  String get verificationRequestOrganizationTitle => 'طلب حساب منظمة موثقة';

  @override
  String get verificationRequestOrganizationSubtitle => 'يتطلب تفاصيل المنظمة ودور الممثل ومراجعة Admin';

  @override
  String get verificationNoSelfServiceUpgrade => 'لا توجد خيارات توثيق متاحة لحالة حسابك الحالية.';

  @override
  String get verificationRequestSubmitSuccess => 'تم إرسال الطلب بنجاح.';

  @override
  String get verificationRequestSubmitFailure => 'تعذر إرسال الطلب.';

  @override
  String get verificationOfficialTitleDialogTitle => 'توثيق مسؤول عام';

  @override
  String get verificationOfficialTitleLabel => 'الصفة الرسمية';

  @override
  String get verificationOfficialTitleHint => 'مثال: عمدة، مستشار، وزير';

  @override
  String get verificationInstitutionDialogTitle => 'توثيق مؤسسة عامة';

  @override
  String get verificationInstitutionNameLabel => 'اسم المؤسسة';

  @override
  String get verificationInstitutionNameHint => 'مثال: مدينة روما';

  @override
  String get verificationInstitutionLevelLabel => 'مستوى المؤسسة';

  @override
  String get verificationOrganizationDialogTitle => 'توثيق منظمة';

  @override
  String get verificationOrganizationNameHint => 'مثال: جمعية البيئة الإيطالية';

  @override
  String get verificationSubmitRequestAction => 'إرسال الطلب';

  @override
  String get verificationCancelDialogTitle => 'إلغاء الطلب';

  @override
  String get verificationCancelDialogBody => 'هل أنت متأكد من إلغاء طلب التوثيق المعلّق؟';

  @override
  String get verificationCancelSuccess => 'تم إلغاء الطلب.';

  @override
  String get verificationCancelFailure => 'تعذر إلغاء الطلب.';

  @override
  String get verificationStatusPendingSuffix => 'طلب قيد المراجعة';

  @override
  String get verificationStatusRejectedSuffix => 'آخر طلب مرفوض';

  @override
  String get verificationReviewPageTitle => 'مراجعة التوثيق';

  @override
  String get verificationReviewLoginRequired => 'يجب تسجيل الدخول لمراجعة طلبات التوثيق.';

  @override
  String verificationReviewPendingCount(int count) {
    return 'الطلبات المعلقة: $count';
  }

  @override
  String get verificationReviewNoPendingRequests => 'لا توجد طلبات توثيق معلقة.';

  @override
  String get verificationReviewUserIdLabel => 'معرّف المستخدم';

  @override
  String get verificationReviewSubmittedLabel => 'تم الإرسال';

  @override
  String get verificationReviewOfficialTitleLabel => 'الصفة الرسمية';

  @override
  String get verificationReviewInstitutionLabel => 'المؤسسة';

  @override
  String get verificationReviewOrganizationLabel => 'المنظمة';

  @override
  String get verificationReviewNoteLabel => 'ملاحظة المراجعة';

  @override
  String get verificationReviewRejectAction => 'رفض';

  @override
  String get verificationReviewApproveAction => 'موافقة';

  @override
  String get verificationReviewApproveDialogTitle => 'الموافقة على الطلب';

  @override
  String get verificationReviewRejectDialogTitle => 'رفض الطلب';

  @override
  String get verificationReviewApproveConfirmation => 'تأكيد الموافقة على هذا الطلب؟';

  @override
  String get verificationReviewRejectConfirmation => 'تأكيد رفض هذا الطلب؟';

  @override
  String get verificationReviewOptionalNoteLabel => 'ملاحظة مراجعة اختيارية';

  @override
  String get verificationReviewRequiredNoteLabel => 'سبب الرفض';

  @override
  String get verificationReviewOptionalHelper => 'اختياري';

  @override
  String get verificationReviewRequiredHelper => 'مطلوب عند الرفض';

  @override
  String get verificationReviewRequiredNoteError => 'أدخل سبب الرفض.';

  @override
  String get verificationReviewApprovedSuccess => 'تمت الموافقة على الطلب.';

  @override
  String get verificationReviewRejectedSuccess => 'تم رفض الطلب.';

  @override
  String get verificationReviewOperationFailure => 'فشلت العملية.';

  @override
  String get adminCenterTitle => 'مركز Admin';

  @override
  String get adminCenterDashboardNavigation => 'لوحة التحكم';

  @override
  String get adminCenterUsersNavigation => 'المستخدمون';

  @override
  String get adminCenterVerificationNavigation => 'التوثيق';

  @override
  String get adminCenterReportsNavigation => 'البلاغات';

  @override
  String get adminCenterAuditNavigation => 'التدقيق';

  @override
  String get adminCenterAccountDetailsTitle => 'تفاصيل الحساب';

  @override
  String get adminCenterTryAgainAction => 'حاول مرة أخرى';

  @override
  String get adminCenterRetryAction => 'إعادة المحاولة';

  @override
  String get adminCenterClearAction => 'مسح';

  @override
  String get adminCenterApplyFiltersAction => 'تطبيق الفلاتر';

  @override
  String get adminCenterAllDates => 'كل التواريخ';

  @override
  String get adminCenterAuditDateFilterHelp => 'تصفية التدقيق حسب التاريخ';

  @override
  String get adminCenterActorUserIdLabel => 'معرّف مستخدم المنفّذ';

  @override
  String get adminCenterActionLabel => 'الإجراء';

  @override
  String get adminCenterAuditActionHint => 'resolve_escalated_report';

  @override
  String get adminCenterTargetIdLabel => 'معرّف الهدف';

  @override
  String get adminCenterOutcomeLabel => 'النتيجة';

  @override
  String get adminCenterAllOutcomes => 'كل النتائج';

  @override
  String get adminCenterOutcomeSuccess => 'نجاح';

  @override
  String get adminCenterOutcomeFailure => 'فشل';

  @override
  String get adminCenterOutcomeDenied => 'مرفوض';

  @override
  String get adminCenterOutcomeNoChange => 'لا تغيير';

  @override
  String get adminCenterOutcomeUnknown => 'غير معروف';

  @override
  String get adminCenterAuditUnavailableTitle => 'التدقيق غير متاح';

  @override
  String get adminCenterAuditUnavailableMessage => 'تحقق من الاتصال والصلاحيات ثم حاول مرة أخرى.';

  @override
  String get adminCenterNoAuditEntriesTitle => 'لا توجد سجلات تدقيق';

  @override
  String get adminCenterNoAuditEntriesMessage => 'لا توجد سجلات تطابق الفلاتر المحددة.';

  @override
  String get adminCenterAuditIdLabel => 'معرّف التدقيق';

  @override
  String get adminCenterActorLabel => 'المنفّذ';

  @override
  String get adminCenterReasonLabel => 'السبب';

  @override
  String get adminCenterTimestampLabel => 'الطابع الزمني';

  @override
  String get adminCenterErrorLabel => 'خطأ';

  @override
  String get adminCenterRecordedValuesTitle => 'القيم المسجلة';

  @override
  String get adminCenterPreviousValueLabel => 'السابق';

  @override
  String get adminCenterNewValueLabel => 'الجديد';

  @override
  String get adminCenterContentTypeLabel => 'نوع المحتوى';

  @override
  String get adminCenterAllContent => 'كل المحتوى';

  @override
  String get adminCenterPolls => 'Vote';

  @override
  String get adminCenterPosts => 'Voce';

  @override
  String get adminCenterNews => 'News';

  @override
  String get adminCenterAwaitingAdminDecision => 'بانتظار قرار Admin';

  @override
  String get adminCenterStatusLabel => 'الحالة';

  @override
  String get adminCenterAllStatuses => 'كل الحالات';

  @override
  String get adminCenterStatusOpen => 'مفتوح';

  @override
  String get adminCenterStatusInReview => 'قيد المراجعة';

  @override
  String get adminCenterStatusResolved => 'تم الحل';

  @override
  String get adminCenterStatusDismissed => 'مرفوض';

  @override
  String get adminCenterAdminQueueUnavailableTitle => 'قائمة تصعيد Admin غير متاحة';

  @override
  String get adminCenterReportsUnavailableTitle => 'البلاغات غير متاحة';

  @override
  String get adminCenterConnectionTryAgainMessage => 'تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get adminCenterNoAdminReportsTitle => 'لا توجد بلاغات بانتظار قرار Admin';

  @override
  String get adminCenterNoReportsTitle => 'لا توجد بلاغات';

  @override
  String get adminCenterNoAdminReportsMessage => 'لا توجد بلاغات مصعّدة تتطلب مراجعة مسؤول.';

  @override
  String get adminCenterNoReportsMessage => 'لا توجد بلاغات تطابق الفلاتر المحددة.';

  @override
  String get adminCenterSearchUsersHint => 'البحث بالاسم أو اسم المستخدم أو البريد الإلكتروني أو المعرّف';

  @override
  String get adminCenterClearSearchTooltip => 'مسح البحث';

  @override
  String get adminCenterUsersUnavailableTitle => 'المستخدمون غير متاحين';

  @override
  String get adminCenterNoUsersFoundTitle => 'لم يتم العثور على مستخدمين';

  @override
  String get adminCenterNoUsersTitle => 'لا يوجد مستخدمون';

  @override
  String get adminCenterNoUsersFoundMessage => 'جرّب اسمًا أو اسم مستخدم أو بريدًا إلكترونيًا أو معرّفًا آخر.';

  @override
  String get adminCenterNoUsersMessage => 'لا توجد حسابات لعرضها.';

  @override
  String get adminCenterAccountUnavailableTitle => 'الحساب غير متاح';

  @override
  String get adminCenterBackToUsersAction => 'العودة إلى المستخدمين';

  @override
  String get adminCenterPublicIdentitySection => 'الهوية العامة';

  @override
  String get adminCenterDisplayNameLabel => 'الاسم المعروض';

  @override
  String get adminCenterNotProvided => 'غير متوفر';

  @override
  String get adminCenterUsernameLabel => 'اسم المستخدم';

  @override
  String get adminCenterUserIdLabel => 'معرّف المستخدم';

  @override
  String get adminCenterIdentityTypeLabel => 'نوع الهوية';

  @override
  String get adminCenterAccountSection => 'الحساب';

  @override
  String get adminCenterTechnicalRoleLabel => 'الدور التقني';

  @override
  String get adminCenterRoleMirrorLabel => 'مرآة دور الملف';

  @override
  String get adminCenterRoleSynchronizationLabel => 'مزامنة الأدوار';

  @override
  String get adminCenterSynchronized => 'متزامن';

  @override
  String get adminCenterNotSynchronized => 'غير متزامن';

  @override
  String get adminCenterRoleNotSynchronized => 'الدور غير متزامن';

  @override
  String get adminCenterAccountStatusLabel => 'حالة الحساب';

  @override
  String get adminCenterSuspendedUntilLabel => 'معلّق حتى';

  @override
  String get adminCenterAccountManagementSection => 'إدارة الحساب';

  @override
  String get adminCenterDangerZoneSection => 'منطقة الخطر';

  @override
  String get adminCenterRoleManagementSection => 'إدارة الأدوار';

  @override
  String get adminCenterVerificationLevelLabel => 'مستوى التوثيق';

  @override
  String get adminCenterVerificationStatusLabel => 'حالة التوثيق';

  @override
  String get adminCenterAccessInformationSection => 'معلومات الوصول';

  @override
  String get adminCenterEmailLabel => 'البريد الإلكتروني';

  @override
  String get adminCenterNotAvailable => 'غير متاح';

  @override
  String get adminCenterEmailConfirmationLabel => 'تأكيد البريد الإلكتروني';

  @override
  String get adminCenterNotConfirmed => 'غير مؤكد';

  @override
  String get adminCenterRegisteredLabel => 'مسجّل';

  @override
  String get adminCenterLastAccessLabel => 'آخر وصول';

  @override
  String get adminCenterLoadingDashboardTitle => 'جارٍ تحميل لوحة التحكم';

  @override
  String get adminCenterLoadingDashboardMessage => 'جارٍ جلب أحدث المؤشرات.';

  @override
  String get adminCenterDashboardUnavailableTitle => 'لوحة التحكم غير متاحة';

  @override
  String get adminCenterIndicatorsUnavailableMessage => 'تعذر تحميل المؤشرات.';

  @override
  String get adminCenterVerificationPendingIndicator => 'توثيق معلق';

  @override
  String get adminCenterOpenReportsIndicator => 'بلاغات مفتوحة';

  @override
  String get adminCenterSuspendedAccountsIndicator => 'حسابات معلقة';

  @override
  String get adminCenterStaffIndicator => 'طاقم';

  @override
  String get adminCenterNoPendingWorkTitle => 'لا توجد مهام معلقة';

  @override
  String get adminCenterNoPendingWorkMessage => 'لا توجد مهام معلقة في التوثيق أو البلاغات أو الحسابات المعلقة.';

  @override
  String get adminCenterCouldNotUpdateUsers => 'تعذر تحديث قائمة المستخدمين.';

  @override
  String get adminCenterCouldNotUpdateReports => 'تعذر تحديث قائمة البلاغات.';

  @override
  String get adminCenterUnnamedUser => 'مستخدم بلا اسم';

  @override
  String get adminCenterTemporarySuspensionTitle => 'تعليق مؤقت';

  @override
  String get adminCenterReactivateDescription => 'إزالة التعليق فورًا والسماح بتسجيل دخول جديد.';

  @override
  String get adminCenterSuspendDescription => 'حظر الوصول لفترة محدودة وإنهاء جميع الجلسات الحالية.';

  @override
  String get adminCenterSuspensionUnavailableDescription => 'يتطلب التعليق حسابًا متزامنًا وغير Admin.';

  @override
  String get adminCenterReactivateAccountAction => 'إعادة تفعيل الحساب';

  @override
  String get adminCenterSuspendAccountAction => 'تعليق الحساب';

  @override
  String get adminCenterForceLogoutAction => 'فرض تسجيل الخروج';

  @override
  String get adminCenterSuspendedForceLogoutDescription => 'لقد أنهى التعليق الجلسات الحالية بالفعل. أعد تفعيل الحساب قبل اختبار تسجيل خروج منفصل.';

  @override
  String get adminCenterForceLogoutDescription => 'إنهاء جميع الجلسات الحالية دون تعليق الحساب.';

  @override
  String get adminCenterForceLogoutUnavailableDescription => 'يتطلب تسجيل الخروج القسري حسابًا متزامنًا وغير Admin.';

  @override
  String get adminCenterPermanentDeletionTitle => 'الحذف الدائم للحساب';

  @override
  String get adminCenterPermanentDeletionDescription => 'حذف بيانات المصادقة وإنهاء جميع الجلسات وإخفاء هوية السجل العام المحتفظ به.';

  @override
  String get adminCenterDeletionUnavailableDescription => 'يتطلب الحذف حسابًا متزامنًا وغير Admin.';

  @override
  String get adminCenterDeleteAccountPermanentlyAction => 'حذف الحساب نهائيًا';

  @override
  String get adminCenterDurationOneHour => 'ساعة واحدة';

  @override
  String get adminCenterDurationOneDay => '24 ساعة';

  @override
  String get adminCenterDurationSevenDays => '7 أيام';

  @override
  String get adminCenterDurationThirtyDays => '30 يومًا';

  @override
  String get adminCenterSuspendImmediateEffect => 'سيفقد الحساب الوصول فورًا وسيتم إنهاء جميع الجلسات الحالية.';

  @override
  String get adminCenterDurationLabel => 'المدة';

  @override
  String get adminCenterSuspendReasonHint => 'اشرح سبب ضرورة تعليق هذا الحساب';

  @override
  String get adminCenterReactivateReasonHint => 'اشرح سبب إمكانية إعادة تفعيل هذا الحساب';

  @override
  String get adminCenterReactivateConfirmation => 'أؤكد أن هذا الحساب يمكنه استعادة الوصول.';

  @override
  String get adminCenterReactivateFailure => 'تعذر إعادة تفعيل الحساب. تحقق من دوره وحالته ثم حاول مرة أخرى.';

  @override
  String get adminCenterReactivateSuccess => 'تمت إعادة تفعيل الحساب. يُسمح الآن بتسجيل دخول جديد.';

  @override
  String get adminCenterForceLogoutFullDescription => 'إنهاء جميع الجلسات الحالية لهذا الحساب. يبقى الحساب نشطًا ويمكنه تسجيل الدخول مجددًا.';

  @override
  String get adminCenterForceLogoutReasonHint => 'اشرح سبب ضرورة إنهاء الجلسات الحالية';

  @override
  String get adminCenterForceLogoutConfirmation => 'أؤكد الإنهاء الفوري لجميع الجلسات الحالية لهذا الحساب.';

  @override
  String get adminCenterForceLogoutFailure => 'تعذر تسجيل خروج الحساب. تحقق من دوره وحالته ثم حاول مرة أخرى.';

  @override
  String get adminCenterForceLogoutSuccess => 'تم إنهاء الجلسات الحالية. يمكن للحساب تسجيل الدخول مجددًا.';

  @override
  String get adminCenterSuspendFailure => 'تعذر تعليق الحساب. تحقق من دوره وحالته ثم حاول مرة أخرى.';

  @override
  String get adminCenterDeleteReasonHint => 'اشرح سبب ضرورة حذف هذا الحساب';

  @override
  String get adminCenterTypeDeleteLabel => 'اكتب DELETE';

  @override
  String get adminCenterTypeAccountIdLabel => 'اكتب معرّف الحساب كاملًا';

  @override
  String get adminCenterDeletePermanentlyAction => 'حذف نهائي';

  @override
  String get adminCenterDeleteIrreversibleWarning => 'هذا الإجراء لا يمكن التراجع عنه. ستُحذف بيانات المصادقة والجلسات الحالية والصورة الرمزية، وسيتم إخفاء هوية السجل العام المحتفظ به. سيبقى سجل التدقيق.';

  @override
  String get adminCenterDeleteFailure => 'تعذر حذف الحساب. تحقق من دوره وحالته وقيم التأكيد ثم حاول مرة أخرى.';

  @override
  String get adminCenterDeleteSuccess => 'تم حذف الحساب نهائيًا وإخفاء هوية البيانات الشخصية.';

  @override
  String get adminCenterChangeTechnicalRoleTitle => 'تغيير الدور التقني';

  @override
  String get adminCenterChangeRoleDescription => 'راجع الدور الحالي والدور المطلوب قبل التأكيد.';

  @override
  String get adminCenterChangeRoleUnavailableDescription => 'تتطلب تغييرات الدور حسابًا متزامنًا وغير محذوف.';

  @override
  String get adminCenterChangeRoleAction => 'تغيير الدور';

  @override
  String get adminCenterChangePublicIdentityTitle => 'تغيير الهوية العامة';

  @override
  String get adminCenterChangeIdentityDescription => 'تحديث نوع الحساب العام ومستوى التوثيق.';

  @override
  String get adminCenterChangeIdentityUnavailableDescription => 'تتطلب تغييرات الهوية حسابًا متزامنًا وغير Admin.';

  @override
  String get adminCenterChangeIdentityAction => 'تغيير الهوية';

  @override
  String get adminCenterChoosePublicIdentityMessage => 'اختر نوع الحساب العام وحالة توثيقه.';

  @override
  String get adminCenterPublicAccountTypeLabel => 'نوع الحساب العام';

  @override
  String get adminCenterPersonVerificationHelper => 'المستويان 1 و2 متاحان فقط لـ Persona.';

  @override
  String get adminCenterNonPersonVerificationHelper => 'الحسابات غير Persona لا تستخدم المستوى 1 أو 2.';

  @override
  String get adminCenterBeforeLabel => 'قبل';

  @override
  String get adminCenterAfterLabel => 'بعد';

  @override
  String get adminCenterIdentityReasonHint => 'اشرح سبب ضرورة تغيير الهوية العامة';

  @override
  String get adminCenterIdentityConfirmation => 'أؤكد الهوية العامة ومستوى التوثيق الموضحين أعلاه.';

  @override
  String get adminCenterIdentityChangeFailure => 'تعذر تغيير الهوية العامة. تحقق من حالة الحساب وحاول مرة أخرى.';

  @override
  String get adminCenterChooseTechnicalRoleMessage => 'اختر الدور التقني الجديد وسجّل سبب الحاجة إلى هذا التغيير.';

  @override
  String get adminCenterNewTechnicalRoleLabel => 'الدور التقني الجديد';

  @override
  String get adminCenterSelectRole => 'اختر دورًا';

  @override
  String get adminCenterRoleSessionWarning => 'ينهي هذا التغيير الجلسة النشطة للمستلم. يجب عليه تسجيل الدخول مجددًا قبل متابعة استخدام الحساب.';

  @override
  String get adminCenterRoleReasonHint => 'اشرح سبب ضرورة تغيير الدور التقني';

  @override
  String get adminCenterRoleConfirmation => 'أؤكد الدور الموضح أعلاه وأفهم أن المستلم يجب أن يسجل الدخول مجددًا.';

  @override
  String get adminCenterRoleChangeFailure => 'تعذر إكمال تغيير الدور. تحقق من حالة الحساب وحاول مرة أخرى.';

  @override
  String get adminCenterChangingRole => 'جارٍ تغيير الدور';

  @override
  String get adminCenterConfirmRoleChange => 'تأكيد تغيير الدور';

  @override
  String get adminCenterRoleUser => 'مستخدم';

  @override
  String get adminCenterRoleModerator => 'مشرف';

  @override
  String get adminCenterRoleAdmin => 'Admin';

  @override
  String get adminCenterAccountStatusActive => 'نشط';

  @override
  String get adminCenterAccountStatusSuspended => 'معلّق';

  @override
  String get adminCenterAccountStatusDeleted => 'محذوف';

  @override
  String get adminCenterVerificationStatusNone => 'لا شيء';

  @override
  String get adminCenterVerificationStatusPending => 'معلق';

  @override
  String get adminCenterVerificationStatusRejected => 'مرفوض';

  @override
  String get adminCenterVerificationNotVerified => 'غير موثق';

  @override
  String get adminCenterVerificationLevel1 => 'المستوى 1';

  @override
  String get adminCenterVerificationLevel2 => 'المستوى 2';

  @override
  String get adminCenterReportSingular => 'بلاغ';

  @override
  String get adminCenterReportPlural => 'بلاغات';

  @override
  String get adminCenterUserSingular => 'مستخدم';

  @override
  String get adminCenterUserPlural => 'مستخدمون';

  @override
  String get adminCenterPoll => 'Vote';

  @override
  String get adminCenterPost => 'Voce';

  @override
  String get adminCenterUnknown => 'غير معروف';

  @override
  String get adminCenterContentHidden => 'المحتوى مخفي';

  @override
  String get adminCenterContentVisible => 'المحتوى ظاهر';

  @override
  String get adminCenterReportedByLabel => 'أبلغ عنه';

  @override
  String get adminCenterContentOwnerLabel => 'مالك المحتوى';

  @override
  String get adminCenterReviewReportAction => 'مراجعة البلاغ';

  @override
  String get adminCenterAdminDecisionAction => 'قرار Admin';

  @override
  String get adminCenterRestoreContentAction => 'استعادة المحتوى';

  @override
  String get adminCenterHideContentAction => 'إخفاء المحتوى';

  @override
  String get adminCenterOpenProfileAction => 'فتح الملف الشخصي';

  @override
  String get adminCenterOpenContentAction => 'فتح المحتوى';

  @override
  String get adminCenterDecisionNoViolation => 'لا توجد مخالفة';

  @override
  String get adminCenterDecisionViolationConfirmed => 'تم تأكيد المخالفة';

  @override
  String get adminCenterDecisionEscalateToAdmin => 'تصعيد إلى Admin';

  @override
  String get adminCenterResolutionNoAccountAction => 'لا إجراء على الحساب';

  @override
  String get adminCenterResolutionAccountSuspended => 'تم تعليق الحساب';

  @override
  String get adminCenterResolutionLogoutForced => 'تم فرض تسجيل الخروج';

  @override
  String get adminCenterResolutionAccountDeleted => 'تم حذف الحساب';

  @override
  String get adminCenterReviewerLabel => 'المراجع';

  @override
  String get adminCenterDecisionDescriptionNoViolation => 'يرفض البلاغ لأن المحتوى لا يخالف القواعد الحالية.';

  @override
  String get adminCenterDecisionDescriptionViolation => 'يؤكد وجود مخالفة ويبقي الحالة قيد المراجعة لاتخاذ إجراء المحتوى في AC8.5.';

  @override
  String get adminCenterDecisionDescriptionEscalation => 'يصعّد الحالة لمراجعة على مستوى الحساب من قبل مسؤول.';

  @override
  String get adminCenterChooseModerationOutcome => 'اختر نتيجة الإشراف لهذا البلاغ.';

  @override
  String get adminCenterDecisionAlreadyRecordedFailure => 'تعذر تسجيل القرار. ربما تمت مراجعة البلاغ بالفعل. حدّث القائمة وحاول مرة أخرى.';

  @override
  String get adminCenterDecisionLabel => 'القرار';

  @override
  String get adminCenterReportReasonLabel => 'سبب البلاغ';

  @override
  String get adminCenterReviewNoteLabel => 'ملاحظة المراجعة';

  @override
  String get adminCenterReviewNoteHint => 'اشرح الأدلة وقرار الإشراف';

  @override
  String get adminCenterRecordingDecision => 'جارٍ تسجيل القرار';

  @override
  String get adminCenterConfirmDecision => 'تأكيد القرار';

  @override
  String get adminCenterAdministratorDecisionTitle => 'قرار المسؤول';

  @override
  String get adminCenterResolutionDescriptionNoAction => 'يغلق البلاغ المصعّد دون تغيير الحساب.';

  @override
  String get adminCenterResolutionDescriptionSuspended => 'يغلق البلاغ بعد تسجيل تعليق ناجح للحساب في سجل التدقيق.';

  @override
  String get adminCenterResolutionDescriptionLogout => 'يغلق البلاغ بعد تسجيل خروج قسري ناجح في سجل التدقيق.';

  @override
  String get adminCenterResolutionDescriptionDeleted => 'يغلق البلاغ بعد تسجيل حذف ناجح للحساب في سجل التدقيق.';

  @override
  String get adminCenterChooseFinalOutcome => 'اختر النتيجة النهائية للمسؤول لهذا التصعيد.';

  @override
  String get adminCenterAdminResolutionFailure => 'تعذر تسجيل قرار المسؤول. حدّث القائمة وحاول مرة أخرى.';

  @override
  String get adminCenterAdminResolutionRequiresAction => 'أكمل إجراء الحساب المطابق أولًا، ثم عد إلى هذا البلاغ وسجّل القرار النهائي للمسؤول.';

  @override
  String get adminCenterEscalationNoteLabel => 'ملاحظة التصعيد';

  @override
  String get adminCenterFinalOutcomeLabel => 'النتيجة النهائية';

  @override
  String get adminCenterAdministratorNoteLabel => 'ملاحظة المسؤول';

  @override
  String get adminCenterAdministratorNoteHint => 'اشرح القرار النهائي على مستوى الحساب';

  @override
  String get adminCenterHideContentFailure => 'تعذر إخفاء المحتوى. حدّث قائمة البلاغات وحاول مرة أخرى.';

  @override
  String get adminCenterRestoreContentFailure => 'تعذر استعادة المحتوى. حدّث قائمة البلاغات وحاول مرة أخرى.';

  @override
  String get adminCenterHideContentWarning => 'يؤدي هذا إلى إزالة المحتوى المبلّغ عنه من الوصول العام. يمكن التراجع عن الإجراء لاحقًا من فلتر البلاغات المحلولة.';

  @override
  String get adminCenterRestoreContentWarning => 'يجعل هذا المحتوى المبلّغ عنه متاحًا للعامة مجددًا.';

  @override
  String get adminCenterActionReasonLabel => 'سبب الإجراء';

  @override
  String get adminCenterHideContentReasonHint => 'اشرح سبب ضرورة إخفاء المحتوى';

  @override
  String get adminCenterRestoreContentReasonHint => 'اشرح سبب إمكانية استعادة المحتوى';

  @override
  String get adminCenterHidingContent => 'جارٍ إخفاء المحتوى';

  @override
  String get adminCenterRestoringContent => 'جارٍ استعادة المحتوى';

  @override
  String get adminCenterReportedProfileTitle => 'الملف المبلّغ عنه';

  @override
  String get adminCenterReportedProfileNotice => 'سياق الملف هذا يأتي من قائمة البلاغات المحمية. تبقى الإجراءات الإدارية على الحساب منفصلة.';

  @override
  String get adminCenterCouldNotRefreshIndicators => 'تعذر تحديث المؤشرات.';

  @override
  String get adminCenterCouldNotRefreshAccount => 'تعذر تحديث تفاصيل الحساب.';

  @override
  String get adminCenterReportAlreadyReviewed => 'تمت مراجعة هذا البلاغ بالفعل أو لم يعد معلقًا.';

  @override
  String get adminCenterReportNotAwaitingAdmin => 'هذا البلاغ لا ينتظر قرار مسؤول.';

  @override
  String get adminCenterConfirmedViolationRequired => 'يلزم تأكيد وجود مخالفة قبل تغيير ظهور المحتوى.';

  @override
  String get adminCenterContentHiddenSuccess => 'تم إخفاء المحتوى المبلّغ عنه.';

  @override
  String get adminCenterContentRestoredSuccess => 'تمت استعادة المحتوى المبلّغ عنه.';

  @override
  String get adminCenterMissingContentId => 'معرّف المحتوى الأصلي مفقود.';

  @override
  String get adminCenterUnsupportedTargetType => 'هذا البلاغ لديه نوع هدف غير مدعوم.';

  @override
  String get adminCenterOriginalContentUnavailable => 'المحتوى الأصلي لم يعد متاحًا.';

  @override
  String get adminCenterNoReportedProfile => 'لا يوجد ملف مبلّغ عنه مرتبط بهذا المحتوى.';

  @override
  String adminCenterRoleChangedSuccess(String previousRole, String newRole) {
    return 'تم تغيير الدور التقني من $previousRole إلى $newRole. تم تسجيل خروج المستلم ويجب عليه تسجيل الدخول مجددًا.';
  }

  @override
  String adminCenterIdentityChangedSuccess(String actorType, String verificationLevel) {
    return 'تم تغيير الهوية العامة إلى $actorType مع $verificationLevel.';
  }

  @override
  String adminCenterAccountSuspendedSuccess(String dateTime) {
    return 'تم تعليق الحساب حتى $dateTime. تم تسجيل خروج المستلم.';
  }

  @override
  String adminCenterReportDecisionRecorded(String decision) {
    return 'تم تسجيل قرار البلاغ: $decision.';
  }

  @override
  String adminCenterAdministratorDecisionRecorded(String decision) {
    return 'تم تسجيل قرار المسؤول: $decision.';
  }

  @override
  String adminCenterUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مستخدمين',
      one: '$count مستخدم',
    );
    return '$_temp0';
  }

  @override
  String adminCenterReportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بلاغات',
      one: '$count بلاغ',
    );
    return '$_temp0';
  }

  @override
  String adminCenterAccountValue(String account) {
    return 'الحساب: $account';
  }

  @override
  String adminCenterSuspendedUntilValue(String dateTime) {
    return 'معلّق حتى: $dateTime';
  }

  @override
  String adminCenterSuspendConfirmation(String dateTime) {
    return 'أؤكد التعليق حتى $dateTime والإنهاء الفوري للجلسات الحالية.';
  }

  @override
  String adminCenterAccountIdValue(String accountId) {
    return 'معرّف الحساب: $accountId';
  }

  @override
  String adminCenterCurrentRoleValue(String role) {
    return 'الحالي: $role';
  }

  @override
  String adminCenterTargetFallback(String targetType, String targetId) {
    return '$targetType $targetId';
  }

  @override
  String adminCenterMinimumCharactersRequired(int count) {
    return 'يلزم إدخال ملاحظة من $count أحرف على الأقل.';
  }

  @override
  String adminCenterMinimumReasonCharactersRequired(int count) {
    return 'يلزم إدخال سبب من $count أحرف على الأقل.';
  }

  @override
  String adminCenterPageOf(int currentPage, int totalPages) {
    return 'الصفحة $currentPage من $totalPages';
  }

  @override
  String get profilePublicProfileSectionTitle => 'الملف العام';

  @override
  String get profileIdentityVerificationSectionTitle => 'الهوية والتوثيق';

  @override
  String get profilePreferencesSectionTitle => 'التفضيلات';

  @override
  String get profileNotificationsSectionTitle => 'الإشعارات';

  @override
  String get profileActivitySectionTitle => 'النشاط الشخصي';

  @override
  String get profileSecurityAccountSectionTitle => 'الأمان والحساب';

  @override
  String get profileThemeTitle => 'السمة';

  @override
  String get profileThemeSystem => 'النظام';

  @override
  String get profileThemeSystemDescription => 'يتبع سمة الجهاز';

  @override
  String get profileThemeLight => 'فاتح';

  @override
  String get profileThemeDark => 'داكن';

  @override
  String get profileMyPollsTitle => 'Vote';

  @override
  String get profileMyPostsTitle => 'Voce';

  @override
  String get profileMyCommentsTitle => 'تعليقاتي';

  @override
  String get profileMyFavoritesTitle => 'محفوظاتي';

  @override
  String get profileAccountConnectionsTitle => 'المتابَعون والمتابعون';

  @override
  String get accountConnectionsFollowingTab => 'أتابع';

  @override
  String get accountConnectionsFollowersTab => 'المتابعون';

  @override
  String get accountConnectionsEmptyFollowing => 'أنت لا تتابع أي حساب بعد.';

  @override
  String get accountConnectionsEmptyFollowers => 'ليس لديك متابعون بعد.';

  @override
  String get accountConnectionsLoadError => 'تعذر تحميل الحسابات. حاول مرة أخرى.';

  @override
  String get profileMyFollowedScopesTitle => 'مناطقي المتابَعة';

  @override
  String get profileLogoutAction => 'تسجيل الخروج';

  @override
  String get profileLogoutDescription => 'تسجيل الخروج من الحساب الحالي';

  @override
  String get profileLogoutDialogTitle => 'تسجيل الخروج';

  @override
  String get profileLogoutDialogMessage => 'هل أنت متأكد من تسجيل الخروج من حسابك؟';

  @override
  String get profileLogoutCancelButton => 'إلغاء';

  @override
  String get profileLogoutConfirmButton => 'تسجيل الخروج';

  @override
  String get publicProfilePageTitle => 'الملف العام';

  @override
  String get publicProfileUserFallback => 'مستخدم';

  @override
  String get publicProfileNoBio => 'لا توجد نبذة متاحة.';

  @override
  String get publicProfileResidenceLabel => 'الإقامة';

  @override
  String get publicProfileResidenceUnknown => 'غير محدد';

  @override
  String get publicProfileMemberSinceLabel => 'عضو منذ';

  @override
  String get publicProfileContentSectionTitle => 'المحتوى العام';

  @override
  String get publicProfilePollsAction => 'Vote';

  @override
  String get publicProfilePostsAction => 'Voce';

  @override
  String get publicProfileBlockUserAction => 'حظر المستخدم';

  @override
  String get publicProfileLoadError => 'تعذر تحميل الملف الشخصي.';

  @override
  String get publicProfileNotFound => 'الملف الشخصي غير متاح.';

  @override
  String get publicProfileUnblockUserAction => 'إلغاء حظر المستخدم';

  @override
  String get publicProfileBlockDialogTitle => 'حظر هذا المستخدم؟';

  @override
  String get publicProfileBlockDialogMessage => 'يمكنك إلغاء حظره لاحقًا من ملفه العام.';

  @override
  String get publicProfileUnblockDialogTitle => 'إلغاء حظر هذا المستخدم؟';

  @override
  String get publicProfileUnblockDialogMessage => 'لن يعود المستخدم موجودًا في قائمة الحظر لديك.';

  @override
  String get publicProfileBlockSuccess => 'تم حظر المستخدم.';

  @override
  String get publicProfileUnblockSuccess => 'تم إلغاء حظر المستخدم.';

  @override
  String get publicProfileBlockError => 'تعذر تحديث الحظر. حاول مرة أخرى.';

  @override
  String get publicProfileFollowersLabel => 'متابعون';

  @override
  String get publicProfileFollowingLabel => 'يتابع';

  @override
  String get publicProfileFollowAction => 'متابعة';

  @override
  String get publicProfileUnfollowAction => 'إلغاء المتابعة';

  @override
  String get publicProfileFollowSuccess => 'تمت متابعة الحساب.';

  @override
  String get publicProfileUnfollowSuccess => 'تم إلغاء متابعة الحساب.';

  @override
  String get publicProfileFollowError => 'تعذر تحديث المتابعة. حاول مرة أخرى.';

  @override
  String get publicProfileFollowRetry => 'إعادة تحميل معلومات المتابعة';

  @override
  String get contentLanguageFieldLabel => 'لغة المحتوى';

  @override
  String get contentLanguageFieldHelper => 'اختر اللغة التي كتبت بها المحتوى.';

  @override
  String get contentLanguageUndetermined => 'غير محدد';

  @override
  String get createPollAdvancedOptionsTitle => 'خيارات متقدمة';

  @override
  String get createPollAdvancedOptionsSubtitle => 'إخفاء الهوية وظهور النتائج وتغيير التصويت والنصاب.';

  @override
  String get onboardingSkipButton => 'تخطي';

  @override
  String get onboardingNextButton => 'التالي';

  @override
  String get onboardingStartButton => 'ابدأ';

  @override
  String get onboardingPollTitle => 'Vote';

  @override
  String get onboardingPollDescription => 'شارك في Vote حول المواضيع التي تهمك، أو أنشئ واحدًا لجمع رأي المجتمع.';

  @override
  String get onboardingHeatIceTitle => 'Heat وIce';

  @override
  String get onboardingHeatIceDescription => 'استخدم Heat وIce لإظهار مدى قوة اهتمامك بمحتوى ما.';

  @override
  String get onboardingCivicMapTitle => 'Civic Map';

  @override
  String get onboardingCivicMapDescription => 'استكشف Vote وVoce وNews على الخريطة واكتشف ما يحدث في مناطق مختلفة.';

  @override
  String get onboardingGeoScopeTitle => 'GeoScope';

  @override
  String get onboardingGeoScopeDescription => 'اختر المستوى الجغرافي الذي تريد متابعته: العالم أو البلد أو المدينة.';

  @override
  String get onboardingVerificationTitle => 'توثيق الهوية';

  @override
  String get onboardingVerificationDescription => 'قد تتطلب بعض Vote مستوى توثيق لحماية نزاهة التصويت.';

  @override
  String get pollDetail_voteReceiptButton => 'إيصال التصويت';

  @override
  String get pollDetail_voteReceiptTitle => 'إيصال التصويت';

  @override
  String get pollDetail_voteReceiptIdLabel => 'معرّف الإيصال';

  @override
  String get pollDetail_voteReceiptDateLabel => 'تم التسجيل';

  @override
  String get pollDetail_voteReceiptPrivacy => 'يؤكد هذا الإيصال أن تصويتك سُجل دون إظهار الخيار الذي اخترته.';

  @override
  String get pollDetail_voteReceiptCloseButton => 'إغلاق';

  @override
  String get profileBiometricUnlockTitle => 'فتح القفل بالقياسات الحيوية';

  @override
  String get profileBiometricUnlockDescription => 'يحمي جلستك المحفوظة ببصمة الجهاز أو التعرف الحيوي.';

  @override
  String get profileBiometricRequiresRememberMe => 'يتطلب تفعيل تذكرني.';

  @override
  String get profileBiometricUnavailable => 'القياسات الحيوية غير متاحة أو غير مهيأة على هذا الجهاز.';

  @override
  String get profileBiometricEnableReason => 'أكد هويتك البيومترية لتفعيل فتح Social Vote.';

  @override
  String get profileBiometricEnabledMessage => 'تم تفعيل الفتح البيومتري.';

  @override
  String get profileBiometricDisabledMessage => 'تم تعطيل الفتح البيومتري.';

  @override
  String get profileBiometricAuthFailedMessage => 'لم تكتمل المصادقة البيومترية.';

  @override
  String get biometricLockTitle => 'Social Vote مقفل';

  @override
  String get biometricLockMessage => 'استخدم القياسات الحيوية لجهازك لفتح الجلسة المحفوظة.';

  @override
  String get biometricUnlockButton => 'فتح';

  @override
  String get biometricUsePasswordButton => 'استخدام كلمة المرور';

  @override
  String get biometricUnlockReason => 'افتح جلسة Social Vote الخاصة بك.';

  @override
  String get biometricUnlockFailedMessage => 'فشل فتح القفل. حاول مرة أخرى أو استخدم كلمة المرور.';

  @override
  String get adminCenterOperationalActivityTitle => 'النشاط التشغيلي';

  @override
  String get adminCenterOperationalActivitySubtitle => 'عدادات مجمعة. لا يوجد تتبع لحظي للحضور عبر الإنترنت.';

  @override
  String get adminCenterLast24HoursLabel => '24 ساعة';

  @override
  String get adminCenterLast7DaysLabel => '7 أيام';

  @override
  String get adminCenterNewUsersMetric => 'تسجيلات جديدة';

  @override
  String get adminCenterRecentSignInsMetric => 'تسجيلات دخول حديثة';

  @override
  String get adminCenterPollsCreatedMetric => 'Vote تم إنشاؤها';

  @override
  String get adminCenterPostsCreatedMetric => 'Voce تم إنشاؤها';

  @override
  String get adminCenterAdminActionsMetric => 'إجراءات Admin';

  @override
  String get authPublicNameHelper => 'هذا هو الاسم الذي سيراه المستخدمون الآخرون. يتم إنشاء اسم المستخدم تلقائيًا.';

  @override
  String get adminCenterRefreshMarkersTooltip => 'تحديث علامات Globe';

  @override
  String get adminCenterMarkerDensityTitle => 'كثافة علامات العالم';

  @override
  String get adminCenterMarkerDensitySubtitle => 'يتحكم في الميزانية البصرية لعلامات Home Globe دون تغيير الإحداثيات الحقيقية أو ترتيب المحتوى.';

  @override
  String get adminCenterMarkerDensityEmpty => 'فارغ';

  @override
  String get adminCenterMarkerDensityFull => 'كامل';

  @override
  String adminCenterMarkerDensityBudget(int count) {
    return 'ميزانية Home: $count علامة';
  }

  @override
  String get adminCenterMarkerDensitySaveError => 'تعذر حفظ كثافة علامات العالم.';

  @override
  String get adminCenterMarkerDensityBackendUnavailable => 'إعدادات علامات العالم في الخلفية غير متاحة بعد.';

  @override
  String get adminCenterQuickActionsTitle => 'إجراءات سريعة للحساب';

  @override
  String get adminCenterModerationSnapshotTitle => 'لمحة عن الإشراف والنشاط';

  @override
  String get adminCenterReportsReceivedMetric => 'بلاغات مستلمة';

  @override
  String get adminCenterPendingReportsMetric => 'بلاغات معلقة';

  @override
  String get adminCenterConfirmedViolationsMetric => 'مخالفات مؤكدة';

  @override
  String get adminCenterReportsFiledMetric => 'بلاغات مقدمة';

  @override
  String get adminCenterCommentsCreatedMetric => 'تعليقات منشأة';

  @override
  String get adminCenterAdminActionsOnAccountMetric => 'إجراءات Admin على الحساب';

  @override
  String get adminCenterLastReportReceivedLabel => 'آخر بلاغ مستلم';

  @override
  String get adminCenterOpenFullAccountAction => 'فتح جميع عناصر تحكم الحساب';

  @override
  String get profileAppLanguageGerman => 'الألمانية';

  @override
  String get profileAppLanguagePersian => 'الفارسية';

  @override
  String get discoveryPageTitle => 'استكشاف';

  @override
  String get organizationWorkspaceTitle => 'Workspace المنظمة';

  @override
  String get organizationPilotBannerTitle => 'تجربة مجانية';

  @override
  String get organizationPilotBannerBody => 'Sessions مجانية خلال المرحلة التجريبية. قد تصبح بعض الميزات الاحترافية مدفوعة مستقبلًا؛ الفوترة غير مفعلة الآن.';

  @override
  String get organizationVerifiedLabel => 'منظمة موثقة';

  @override
  String get organizationEditProfile => 'تعديل ملف المنظمة';

  @override
  String get organizationCreateSession => 'Session جديدة';

  @override
  String get organizationNoSessions => 'لا توجد Sessions بعد. أنشئ الأولى لاجتماع أو ورشة أو فعالية.';

  @override
  String get organizationSessionsTitle => 'Sessions مباشرة';

  @override
  String get organizationRequiresVerificationTitle => 'مطلوب منظمة موثقة';

  @override
  String get organizationRequiresVerificationBody => 'هذا الـ Workspace متاح فقط للحسابات التي اعتمدتها Social Vote كمنظمة موثقة.';

  @override
  String get organizationProfileEditorTitle => 'ملف المنظمة';

  @override
  String get organizationLegalName => 'الاسم القانوني';

  @override
  String get organizationPublicName => 'الاسم العام';

  @override
  String get organizationType => 'نوع المنظمة';

  @override
  String get organizationCountryCode => 'رمز البلد';

  @override
  String get organizationCity => 'المدينة';

  @override
  String get organizationWebsite => 'الموقع الرسمي';

  @override
  String get organizationDescription => 'الوصف';

  @override
  String get organizationUploadCover => 'تغيير الغلاف';

  @override
  String get organizationUploadLogo => 'تغيير الشعار';

  @override
  String get organizationMediaUpdated => 'تم تحديث صورة المنظمة.';

  @override
  String get organizationNamesRequired => 'الاسمان القانوني والعام مطلوبان.';

  @override
  String get organizationTypeAssociation => 'جمعية';

  @override
  String get organizationTypeNonprofit => 'منظمة غير ربحية';

  @override
  String get organizationTypeCompany => 'شركة';

  @override
  String get organizationTypeCooperative => 'تعاونية';

  @override
  String get organizationTypeSports => 'منظمة رياضية';

  @override
  String get organizationTypePublicBody => 'جهة عامة';

  @override
  String get organizationTypeCommittee => 'لجنة / مجموعة';

  @override
  String get organizationTypeOther => 'أخرى';

  @override
  String get sessionCreateTitle => 'إنشاء Live Session';

  @override
  String get sessionTitleLabel => 'عنوان Session';

  @override
  String get sessionExpectedParticipants => 'المشاركون المتوقعون';

  @override
  String get sessionAccessMode => 'وصول المشاركين';

  @override
  String get sessionAccessOpen => 'مجهول ومفتوح';

  @override
  String get sessionAccessOpenHint => 'يمكن لأي شخص لديه الرابط/الرمز الانضمام. منع التكرار يتم بأفضل جهد ولا يضمن هذا الوضع شخصًا واحدًا = صوتًا واحدًا.';

  @override
  String get sessionAccessControlled => 'مجهول ومتحكم به';

  @override
  String get sessionAccessControlledHint => 'استخدم Access Passes مجهولة ولمرة واحدة. تخزن Social Vote فقط بصمة Access Pass ولا تربط خيارات الاقتراع ببيانات اعتماد المشارك.';

  @override
  String get sessionResultsVisibility => 'ظهور النتائج';

  @override
  String get sessionResultsLive => 'مباشر';

  @override
  String get sessionResultsAfterVote => 'بعد تصويت المشارك';

  @override
  String get sessionResultsAfterClose => 'بعد إغلاق السؤال';

  @override
  String get sessionResultsOrganizerOnly => 'للمنظم فقط';

  @override
  String get sessionCreateAction => 'إنشاء Session';

  @override
  String get sessionPilotLimit => 'حد المرحلة التجريبية: من 1 إلى 250 مشاركًا لكل Session.';

  @override
  String get sessionStatusDraft => 'مسودة';

  @override
  String get sessionStatusOpen => 'مفتوحة';

  @override
  String get sessionStatusClosed => 'مغلقة';

  @override
  String get sessionJoinCode => 'رمز الانضمام';

  @override
  String get sessionShareJoin => 'مشاركة رابط الانضمام';

  @override
  String get sessionCopyJoinLink => 'نسخ الرابط';

  @override
  String get sessionGenerateTokens => 'إنشاء Access Passes';

  @override
  String get sessionGenerateTokensCount => 'عدد Access Passes';

  @override
  String get sessionTokensOneTimeTitle => 'احفظ بيانات الاعتماد هذه الآن';

  @override
  String get sessionTokensOneTimeBody => 'تُعرض Access Passes بالنص الصريح فقط في نتيجة هذه الدفعة. تخزن Social Vote بصماتها فقط. انسخها ووزعها بأمان.';

  @override
  String get sessionCopyTokens => 'نسخ كل الروابط';

  @override
  String get sessionTokensSavedAction => 'لقد حفظتها';

  @override
  String get sessionOpenAction => 'فتح Session';

  @override
  String get sessionCloseAction => 'إغلاق Session';

  @override
  String get sessionCloseConfirm => 'إغلاق التصويت وإنشاء لقطة Verified Result غير قابلة للتغيير؟';

  @override
  String get sessionQuestionsTitle => 'الأسئلة';

  @override
  String get sessionAddQuestion => 'إضافة سؤال';

  @override
  String get sessionQuestionTitle => 'السؤال';

  @override
  String get sessionQuestionType => 'نوع السؤال';

  @override
  String get sessionTypeYesNo => 'نعم / لا';

  @override
  String get sessionTypeSingle => 'اختيار واحد';

  @override
  String get sessionTypeMultiple => 'اختيارات متعددة';

  @override
  String get sessionOptions => 'الخيارات';

  @override
  String get sessionOptionHint => 'خيار واحد في كل سطر.';

  @override
  String get sessionMinSelections => 'الحد الأدنى للاختيارات';

  @override
  String get sessionMaxSelections => 'الحد الأقصى للاختيارات';

  @override
  String get sessionAddAction => 'إضافة';

  @override
  String get sessionOpenQuestion => 'فتح السؤال';

  @override
  String get sessionCloseQuestion => 'إغلاق السؤال';

  @override
  String get sessionNoQuestions => 'لا توجد أسئلة بعد.';

  @override
  String get sessionPresenterTitle => 'المقدّم';

  @override
  String get sessionParticipantTitle => 'Social Vote Live';

  @override
  String get sessionJoinAction => 'الانضمام إلى Session';

  @override
  String get sessionTokenLabel => 'رمز المشارك';

  @override
  String get sessionTokenHint => 'SV-…';

  @override
  String get sessionWaitingQuestion => 'بانتظار أن يفتح المنظم سؤالًا…';

  @override
  String get sessionVoteAction => 'إرسال التصويت';

  @override
  String get sessionVoteReceived => 'تم استلام التصويت';

  @override
  String get sessionResultsUnavailable => 'النتائج غير ظاهرة بعد وفق سياسة هذه الـ Session.';

  @override
  String get sessionPrivacyNotice => 'يحدد المنظم الغرض التشغيلي وأسئلة Session. تعالج Social Vote البيانات التقنية اللازمة لتقديم الخدمة وحمايتها. الأوضاع المجهولة لا تكشف للمنظم العلاقة بين بيانات اعتماد المشارك واختياره. قد تعتمد أدوار الخصوصية على السياق والاتفاقيات المعمول بها.';

  @override
  String get sessionNonBindingNotice => 'Sessions التجريبية مخصصة للتشاور والمشاركة. وهي ليست انتخابات قانونية ولا تصويت جمعية نظامية ولا اعتمادًا ملزمًا قانونيًا.';

  @override
  String get sessionOptionYes => 'نعم';

  @override
  String get sessionOptionNo => 'لا';

  @override
  String get verifiedResultTitle => 'Verified Result';

  @override
  String get verifiedResultValid => 'نجح فحص النزاهة';

  @override
  String get verifiedResultInvalid => 'فشل فحص النزاهة';

  @override
  String get verifiedResultReportId => 'معرّف التقرير';

  @override
  String get verifiedResultHash => 'بصمة SHA-256 للنتيجة';

  @override
  String get verifiedResultGeneratedBy => 'تم إنشاؤه وختم نزاهته بواسطة Social Vote';

  @override
  String get verifiedResultNotLegalCertificate => 'هذا تقرير نتيجة مجمعة قابلة للتحقق، وليس شهادة قانونية ولا اعتمادًا لانتخابات ملزمة قانونيًا.';

  @override
  String get verifiedResultShare => 'مشاركة رابط التحقق';

  @override
  String sessionResponses(int count) {
    return '$count استجابات';
  }

  @override
  String sessionResultVotes(int count) {
    return '$count أصوات';
  }

  @override
  String get organizationVerifiedIdentityLocked => 'الاسم والبلد جزء من الهوية الموثقة للمنظمة. تغييرهما يتطلب توثيقًا جديدًا. يمكنك تغيير الغلاف والشعار والنوع والمدينة والموقع والوصف بحرية.';

  @override
  String get verifiedResultOpenedAt => 'تم فتح Session';

  @override
  String get verifiedResultEligibleCredentials => 'بيانات الاعتماد المؤهلة';

  @override
  String get verifiedResultIntegritySeal => 'ختم نزاهة Social Vote';

  @override
  String get organizationVerifiedNameLocked => 'الاسم الموثق والبلد مقفلان. تغييرهما يتطلب مراجعة توثيق جديدة.';

  @override
  String get sessionRetentionLabel => 'مدة الاحتفاظ بالاقتراعات الخام';

  @override
  String get sessionRetention24h => '24 ساعة';

  @override
  String get sessionRetention7d => '7 أيام';

  @override
  String get sessionRetention30d => '30 يومًا';

  @override
  String sessionRetentionValue(String value) {
    return 'الاحتفاظ بالاقتراعات الخام: $value';
  }

  @override
  String get verifiedResultPrintPdf => 'تنزيل PDF';

  @override
  String get verifiedResultPdfError => 'تعذر تنزيل PDF. حاول مرة أخرى.';

  @override
  String get verifiedResultRestrictedTitle => 'نتيجة مقيّدة';

  @override
  String get verifiedResultRestrictedBody => 'هذا الـ Verified Result غير متاح للعامة. سجّل الدخول بحساب منظمة مخول لعرضه.';

  @override
  String get verifiedResultPrivateVerificationTitle => 'التحقق العام غير متاح';

  @override
  String get verifiedResultPrivateVerificationBody => 'هذه النتيجة مقيّدة بالمنظم. يبقى معرّف التقرير وSHA-256 وفحص النزاهة متاحًا في التقرير المصرح به.';

  @override
  String get organizationAccountSectionTitle => 'منظماتك';

  @override
  String get organizationManageAction => 'إدارة';

  @override
  String get organizationViewPublicProfileAction => 'عرض الملف';

  @override
  String get organizationOfficialWebsiteAction => 'الموقع الرسمي';

  @override
  String get organizationVerificationIntro => 'يشمل التوثيق وجود المنظمة وسلطتك لتمثيلها. ستراجع Social Vote المعلومات المقدمة قبل الموافقة.';

  @override
  String get organizationVerificationLegalName => 'الاسم القانوني';

  @override
  String get organizationVerificationPublicName => 'الاسم العام';

  @override
  String get organizationVerificationType => 'نوع المنظمة';

  @override
  String get organizationVerificationCountry => 'البلد';

  @override
  String get organizationVerificationCountryRequired => 'اختر بلد المنظمة.';

  @override
  String get organizationVerificationCity => 'المدينة';

  @override
  String get organizationVerificationWebsite => 'الموقع الرسمي';

  @override
  String get organizationVerificationRepresentativeRole => 'دورك في المنظمة';

  @override
  String get organizationVerificationRegistryId => 'معرّف السجل / الضريبة / المنظمة';

  @override
  String get organizationVerificationAuthorityNote => 'كيف يمكننا التحقق من أنك مخول لتمثيلها؟';

  @override
  String get organizationVerificationAuthorityHelper => 'اذكر بإيجاز دورك أو الدليل الذي يمكن لـ Admin التحقق منه خلال المرحلة التجريبية.';

  @override
  String get organizationVerificationRequired => 'حقل مطلوب.';

  @override
  String get sessionControlRoomTitle => 'غرفة تحكم Session';

  @override
  String get sessionSectionLive => 'مباشر';

  @override
  String get sessionSectionQuestions => 'الأسئلة';

  @override
  String get sessionSectionAccess => 'الوصول';

  @override
  String get sessionSectionSettings => 'الإعدادات';

  @override
  String get sessionStageAction => 'فتح Stage';

  @override
  String get sessionAccessPassesTitle => 'Access Passes للمشاركين';

  @override
  String get sessionAccessPassesSubtitle => 'يفتح كل pass هذه Controlled Anonymous Session دون الحاجة إلى كتابة بيانات الاعتماد الطويلة. لا تخزن Social Vote الـ pass بالنص الصريح.';

  @override
  String get sessionAccessPass => 'Access Pass';

  @override
  String get sessionAccessPassDetected => 'تم اكتشاف Access Pass';

  @override
  String get sessionAccessPassAutomatic => 'الـ pass الشخصي جاهز. تابع للدخول إلى Session بشكل مجهول.';

  @override
  String get sessionAccessPassFallback => 'أدخل pass يدويًا';

  @override
  String get sessionAccessPassInvalid => 'هذا الـ Access Pass غير صالح أو لم يعد متاحًا أو أن Session غير مفتوحة.';

  @override
  String get sessionAccessPassPrintWarning => 'اطبع أو احفظ أو وزع هذه الـ passes الآن. بعد مغادرة هذه الشاشة لن تتمكن Social Vote من إظهارها بالنص الصريح مجددًا.';

  @override
  String get sessionExistingPassesHidden => 'لأسباب أمنية لا يمكن إظهار الـ passes السابقة بالنص الصريح مرة أخرى. أنشئ Access Passes جديدة للحصول على روابط شخصية أو رموز QR جديدة.';

  @override
  String get sessionCopyPassLinks => 'نسخ كل الروابط';

  @override
  String get sessionCopyPassLink => 'نسخ هذا الرابط';

  @override
  String get sessionControlledNeedsAccessPass => 'قبل فتح Session متحكم بها، أنشئ Access Pass واحدًا على الأقل.';

  @override
  String get sessionJoinedParticipants => 'بيانات اعتماد الوصول المنضمة';

  @override
  String get sessionAccessesUsed => 'عمليات الوصول التي صوّتت';

  @override
  String get sessionBallotsRecorded => 'اقتراعات مسجلة';

  @override
  String get sessionQuestionsCompleted => 'أسئلة مكتملة';

  @override
  String get sessionCurrentQuestion => 'السؤال الحالي';

  @override
  String get sessionNoOpenQuestionTitle => 'لا يوجد سؤال مفتوح';

  @override
  String get sessionNoOpenQuestionBody => 'المشاركون متصلون وينتظرون. افتح السؤال التالي عندما تكون جاهزًا.';

  @override
  String get sessionNotStartedTitle => 'Session لم تبدأ بعد';

  @override
  String get sessionNotStartedBody => 'هذه الـ Session موجودة لكنها غير مفتوحة بعد. أبقِ هذه الصفحة مفتوحة وانتظر أن يبدأها المنظم.';

  @override
  String get sessionNoAccountRequired => 'لا يلزم حساب Social Vote';

  @override
  String get sessionReceiptDetails => 'تفاصيل الإيصال';

  @override
  String get sessionOpenAccessInstructions => 'اعرض أو شارك رمز QR هذا. يمكن لأي شخص لديه الرابط الدخول أثناء فتح Session.';

  @override
  String get sessionControlledAccessInstructions => 'أنشئ passes وصول شخصية وامنح كل مشارك واحدًا. يحتوي QR في كل pass على بيانات الاعتماد تلقائيًا.';

  @override
  String get sessionControlRoomHint => 'أدر الوصول والأسئلة وStage المعروض وVerified Result النهائي من مكان واحد.';

  @override
  String get sessionPresenterScreenTitle => 'Live Stage';

  @override
  String get sessionStageWaiting => 'بانتظار السؤال التالي';

  @override
  String get sessionStageScan => 'امسح للانضمام إلى Session';

  @override
  String get sessionConfigurationTitle => 'إعداد Session';

  @override
  String get sessionAccessRecommended => 'موصى به للاجتماعات المتحكم بها';

  @override
  String get sessionCreateIntroTitle => 'إعداد الاجتماع';

  @override
  String get sessionCreateIntroBody => 'اختر طريقة دخول المشاركين ووقت ظهور النتائج ومدة الاحتفاظ بالاقتراعات الخام. يتم فرض هذه الإعدادات بواسطة الخلفية.';

  @override
  String get verifiedCertificateNumber => 'رقم الشهادة';

  @override
  String get verifiedCertificateStatus => 'حالة النزاهة';

  @override
  String get verifiedCertificateIntegrityVerified => 'تم التحقق من النزاهة';

  @override
  String get verifiedCertificateIntegrityFailed => 'فشل فحص النزاهة';

  @override
  String get verifiedCertificateOrganizationSection => 'المنظمة';

  @override
  String get verifiedCertificateSessionSection => 'Session';

  @override
  String get verifiedCertificateParticipationSection => 'المشاركة';

  @override
  String get verifiedCertificateResultsSection => 'نتائج موثقة';

  @override
  String get verifiedCertificateIntegritySection => 'نزاهة النتيجة';

  @override
  String get verifiedCertificateLegalName => 'الاسم القانوني';

  @override
  String get verifiedCertificateOrganizationType => 'نوع المنظمة';

  @override
  String get verifiedCertificateLocation => 'الموقع';

  @override
  String get verifiedCertificateWebsite => 'الموقع الإلكتروني';

  @override
  String get verifiedCertificateVerification => 'التوثيق';

  @override
  String get verifiedCertificateIssuedAt => 'تاريخ إصدار الشهادة';

  @override
  String get verifiedCertificateAlgorithm => 'خوارزمية النزاهة';

  @override
  String get verifiedCertificateSchema => 'مخطط التقرير';

  @override
  String get verifiedCertificateJoinedCredentials => 'بيانات الاعتماد المنضمة';

  @override
  String get verifiedCertificateBallotsTotal => 'اقتراعات مسجلة';

  @override
  String get verifiedCertificateQuestionsTotal => 'الأسئلة';

  @override
  String get verifiedCertificatePrivacyModel => 'نموذج نتيجة مجهولة';

  @override
  String get verifiedCertificatePrivacyText => 'تحتوي اللقطة غير القابلة للتغيير على نتائج مجمعة فقط. ولا تحتوي على هوية مشارك أو Access Pass بالنص الصريح أو سر مشارك أو أي ربط بين بيانات اعتماد مشارك واختيار اقتراع.';

  @override
  String get verifiedCertificateVerifyQr => 'امسح رمز QR هذا للتحقق من التقرير عبر الإنترنت.';

  @override
  String get organizationDashboardTitle => 'نظرة عامة على المنظمة';

  @override
  String get organizationActiveSessions => 'Sessions مباشرة';

  @override
  String get organizationVerifiedReports => 'تقارير موثقة';

  @override
  String get organizationTotalSessions => 'إجمالي Sessions';

  @override
  String get sessionPrivacyPolicyAction => 'قراءة سياسة الخصوصية';

  @override
  String get radioMondoTitle => 'Radio Mondo';

  @override
  String get radioMondoDescription => 'ثلاثة مشاهد صوتية أصلية لاستكشاف Social Vote. يبدأ التشغيل فقط عندما تختار مقطعًا.';

  @override
  String get radioMondoTrackClassical => 'مدار كلاسيكي';

  @override
  String get radioMondoTrackRain => 'مطر فوق العالم';

  @override
  String get radioMondoTrackYoung => 'Pulse شبابي';

  @override
  String get radioMondoPlaying => 'يتم التشغيل الآن';

  @override
  String get radioMondoStopped => 'تم إيقاف Radio Mondo';

  @override
  String get radioMondoStopAction => 'إيقاف';

  @override
  String get radioMondoPlaybackError => 'تعذر تشغيل الصوت';

  @override
  String get radioMondoForegroundOnly => 'يتوقف التشغيل عند إغلاق Social Vote أو إرساله إلى الخلفية أو إخفاء تبويب المتصفح.';

  @override
  String get adminCenterEditorialNavigation => 'World Briefs';

  @override
  String get worldBriefEditorTitle => 'Social Vote World Briefs';

  @override
  String get worldBriefEditorDescription => 'أعد موجزات قائمة على الأدلة، وأبقِ عدم اليقين ظاهرًا، وحدد ما يظهر في News وعلى Globe.';

  @override
  String get worldBriefAllStatuses => 'كل الحالات';

  @override
  String get worldBriefCreateAction => 'إنشاء موجز';

  @override
  String get worldBriefDraftSaved => 'تم حفظ المسودة';

  @override
  String get worldBriefPublished => 'تم نشر الموجز';

  @override
  String get worldBriefWithdrawn => 'تم سحب الموجز';

  @override
  String get worldBriefSaveError => 'تعذر حفظ الموجز';

  @override
  String get worldBriefPublishError => 'تعذر نشر الموجز';

  @override
  String get worldBriefDraftDeleted => 'تم حذف المسودة';

  @override
  String get worldBriefDeleteDraft => 'حذف المسودة';

  @override
  String get worldBriefDeleteDraftConfirm => 'حذف هذه المسودة غير المنشورة نهائيًا؟';

  @override
  String get worldBriefRetry => 'حاول مرة أخرى';

  @override
  String get worldBriefStatusDraft => 'مسودة';

  @override
  String get worldBriefStatusPublished => 'منشور';

  @override
  String get worldBriefStatusWithdrawn => 'مسحوب';

  @override
  String get worldBriefSetupRequired => 'الخلفية التحريرية غير جاهزة';

  @override
  String get worldBriefSetupRequiredBody => 'طبّق ترحيل قاعدة بيانات World Brief المرفق قبل استخدام هذا القسم.';

  @override
  String get worldBriefEmptyTitle => 'لا توجد World Briefs بعد';

  @override
  String get worldBriefEmptyBody => 'أنشئ مسودة ووثّق مصدرين على الأقل وانشر فقط بعد المراجعة التحريرية.';

  @override
  String get worldBriefFeatured => 'مميز';

  @override
  String get worldBriefOnGlobe => 'إظهار على Globe';

  @override
  String get worldBriefPriority => 'الأولوية';

  @override
  String get worldBriefEditAction => 'تعديل';

  @override
  String get worldBriefPublishAction => 'نشر';

  @override
  String get worldBriefWithdrawAction => 'سحب';

  @override
  String get worldBriefSaveDraftAction => 'حفظ المسودة';

  @override
  String get worldBriefLanguage => 'لغة الموجز';

  @override
  String get worldBriefTitleField => 'العنوان';

  @override
  String get worldBriefWhatHappened => 'ما الذي حدث';

  @override
  String get worldBriefWhyItMatters => 'لماذا هذا مهم';

  @override
  String get worldBriefWhatIsUncertain => 'ما الذي لا يزال غير مؤكد';

  @override
  String get worldBriefSources => 'روابط المصادر';

  @override
  String get worldBriefSourcesHint => 'رابط HTTPS واحد في كل سطر؛ مصدران مستقلان على الأقل.';

  @override
  String get worldBriefTwoSourcesRequired => 'أضف مصدرين على الأقل.';

  @override
  String get worldBriefHttpsSourcesRequired => 'يجب أن يستخدم كل مصدر HTTPS.';

  @override
  String get worldBriefGlobeSection => 'الموضع على Globe';

  @override
  String get worldBriefGlobeRequiresPoint => 'يتطلب الظهور على Globe خط عرض وخط طول صالحين.';

  @override
  String get worldBriefCountryCode => 'رمز البلد';

  @override
  String get worldBriefCityId => 'معرّف المدينة';

  @override
  String get worldBriefLocationLabel => 'تسمية الموقع';

  @override
  String get worldBriefLatitude => 'خط العرض';

  @override
  String get worldBriefLongitude => 'خط الطول';

  @override
  String get worldBriefBreaking => 'تحديث عاجل';

  @override
  String get worldBriefExpiry => 'فترة المراجعة أو الانتهاء';

  @override
  String worldBriefExpiryDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days أيام',
      one: 'يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get worldBriefRequiredField => 'هذا الحقل مطلوب.';

  @override
  String get worldBriefCoordinatesRequired => 'أدخل إحداثيًا صالحًا.';

  @override
  String get profileHowItWorksTitle => 'كيف تعمل Social Vote';

  @override
  String get profileHowItWorksSubtitle => 'الأشخاص والمنظمات وVoce وVote وSessions والتوثيق.';

  @override
  String get profileMyPostsLoginRequired => 'يجب تسجيل الدخول لعرض Voce الخاصة بك.';

  @override
  String get profileMyPostsCreatedByYou => 'Voce أنشأتها أنت';

  @override
  String get profileMyPostsEmpty => 'لم تنشئ أي Voce بعد.';

  @override
  String get profileMyPollsLoginRequired => 'يجب تسجيل الدخول لعرض Vote الخاصة بك.';

  @override
  String get profileMyPollsCreatedByYou => 'Vote أنشأتها أنت';

  @override
  String get profileMyPollsEmpty => 'لم تنشئ أي Vote بعد.';

  @override
  String get profileMyCommentsLoginRequired => 'يجب تسجيل الدخول لعرض تعليقاتك.';

  @override
  String get profileMyCommentsEmpty => 'لم تكتب أي تعليقات بعد.';

  @override
  String get profileFollowedScopesLoginRequired => 'يجب تسجيل الدخول.';

  @override
  String get profileFollowedScopesEmpty => 'أنت لا تتابع أي مناطق بعد.';

  @override
  String get profileFollowedScopeWorld => 'العالم';

  @override
  String profileFollowedScopeCountry(String code) {
    return 'البلد: $code';
  }

  @override
  String profileFollowedScopeCity(String city) {
    return 'المدينة: $city';
  }

  @override
  String profileFollowedScopeArea(double radius) {
    return 'منطقة ($radius كم)';
  }

  @override
  String get publicProfilePollsLoadError => 'تعذر تحميل Vote العامة.';

  @override
  String get publicProfilePollsEmpty => 'لا توجد Vote عامة.';

  @override
  String get publicProfilePostsLoadError => 'تعذر تحميل Voce العامة.';

  @override
  String get publicProfilePostsEmpty => 'لا توجد Voce عامة.';

  @override
  String get worldBriefSocialVoteView => 'وجهة نظر Social Vote';

  @override
  String get worldBriefSocialVoteViewHint => 'تحليل أو وجهة نظر تحريرية لـ Social Vote. أبقها منفصلة عن الوقائع المبلغ عنها وعدم اليقين.';

  @override
  String get worldBriefSocialVoteViewPublicNote => 'تحليل تحريري من Social Vote منفصل بوضوح عن الوقائع المذكورة أعلاه.';

  @override
  String get worldBriefIndependentSourcesRequired => 'يتطلب النشر مصدرين HTTPS على الأقل من نطاقات مختلفة.';

  @override
  String get worldBriefPublishConfirmTitle => 'فحص نهائي قبل النشر';

  @override
  String worldBriefPublishConfirmSources(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم إدخال $count مصادر',
      one: 'تم إدخال مصدر واحد',
    );
    return '$_temp0';
  }

  @override
  String get worldBriefEnterpriseEditorTitle => 'محرر تحريري احترافي';

  @override
  String get worldBriefEnterpriseEditorHelp => 'ابنِ الموجز قسمًا بعد قسم. تتولى Social Vote الموضع التقني على Globe تلقائيًا: اختر بلدًا ومدينة، لا إحداثيات.';

  @override
  String get worldBriefEditorialContentSection => 'المحتوى التحريري';

  @override
  String get worldBriefEditorialContentHelp => 'افصل الوقائع والأهمية وعدم اليقين ووجهة نظر Social Vote. هذا يجعل الموجز أسهل في التحقق والقراءة.';

  @override
  String get worldBriefSourcesSection => 'المصادر والتحقق';

  @override
  String get worldBriefSourcesSectionHelp => 'أضف مصادر HTTPS قابلة للتحقق. يتطلب النشر نطاقين مستقلين على الأقل.';

  @override
  String get worldBriefDistributionSection => 'التوزيع';

  @override
  String get worldBriefDistributionHelp => 'اختر أين يظهر الموجز. النشر يجعله متاحًا في News؛ والموضع على Globe اختياري.';

  @override
  String get worldBriefNewsDestination => 'النشر في Social Vote News';

  @override
  String get worldBriefNewsDestinationHelp => 'هذه هي الوجهة الرئيسية لـ World Brief بعد نشره.';

  @override
  String get worldBriefGlobeAutomaticHelp => 'يضيف علامة على Globe. اختر المكان وستحدد Social Vote الموضع تلقائيًا.';

  @override
  String get worldBriefPlacementMode => 'موضع العلامة';

  @override
  String get worldBriefPlacementCity => 'مدينة / مكان';

  @override
  String get worldBriefPlacementCountry => 'مركز البلد';

  @override
  String get worldBriefCountry => 'البلد';

  @override
  String get worldBriefCity => 'مدينة أو مكان';

  @override
  String get worldBriefCityHelp => 'مثال: طهران. لا تدخل خط العرض أو خط الطول.';

  @override
  String get worldBriefResolveLocation => 'تحديد الموقع';

  @override
  String get worldBriefCoordinatesAutomatic => 'تتم إدارة الإحداثيات تلقائيًا ولا ينبغي إدخالها يدويًا.';

  @override
  String worldBriefLocationResolved(String location) {
    return 'الموقع جاهز: $location';
  }

  @override
  String get worldBriefChooseCountryFirst => 'اختر بلدًا أولًا.';

  @override
  String get worldBriefChooseCityFirst => 'أدخل مدينة أو مكانًا أولًا.';

  @override
  String get worldBriefLocationNotResolved => 'تعذر تحديد موقع موثوق. تحقق من البلد والمدينة وحاول مرة أخرى.';

  @override
  String get worldBriefVisibilitySection => 'الظهور والأولوية';

  @override
  String get worldBriefVisibilityHelp => 'تحكم في البروز التحريري والاستعجال والترتيب والعمر دون تغيير الوقائع المبلغ عنها.';

  @override
  String get worldBriefFeaturedHelp => 'امنح الموجز بروزًا أكبر على الأسطح التحريرية.';

  @override
  String get worldBriefBreakingHelp => 'استخدم فقط للأحداث العاجلة فعلًا أو سريعة التطور.';

  @override
  String get worldBriefPriorityHelp => '0 = أولوية عادية/منخفضة؛ 100 = أعلى أولوية تحريرية. لا يغير ذلك حالة صدق المحتوى.';

  @override
  String get worldBriefExpiryHelp => 'بعد هذه الفترة يجب ألا يبقى الموجز نشطًا دون مراجعة تحريرية جديدة.';

  @override
  String get profileAppLanguageSpanish => 'الإسبانية';

  @override
  String get profileAppLanguagePortuguese => 'البرتغالية';

  @override
  String get homeHeroPurpose => 'اكتشف ما يهم، وشارك Voce الخاصة بك وشارك في Vote.';

  @override
  String get commentSection_hideComments => 'إخفاء التعليقات';

  @override
  String get commentSection_viewComments => 'عرض التعليقات';

  @override
  String get commentSection_hideReplies => 'إخفاء الردود';

  @override
  String commentSection_editing(String snippet) {
    return 'جارٍ التعديل: $snippet';
  }

  @override
  String get commentSection_editInputHint => 'عدّل تعليقك';

  @override
  String commentSection_replyTo(String author) {
    return 'الرد على $author';
  }

  @override
  String get commentSection_userFallback => 'مستخدم';

  @override
  String get commentSection_addError => 'تعذر إضافة التعليق.';

  @override
  String get commentSection_nestedReplyError => 'الردود المتداخلة لأكثر من مستوى واحد غير مدعومة.';

  @override
  String get commentSection_addReplyError => 'تعذر إضافة الرد.';

  @override
  String get commentSection_editError => 'تعذر تعديل التعليق.';

  @override
  String get commentSection_deleteError => 'تعذر حذف التعليق.';

  @override
  String get commentSection_edited => 'تم التعديل';

  @override
  String get commentSection_editAction => 'تعديل';
}
