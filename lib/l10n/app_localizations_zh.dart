// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Social Vote';

  @override
  String get voteButton => '投票';

  @override
  String get createPollPageTitle => '创建 Vote';

  @override
  String get createPollPageSubtitle => '创建新的公民投票';

  @override
  String get createPollBasicInfoTitle => '基本信息';

  @override
  String get createPollBasicInfoSubtitle => '填写 Vote 的主要信息。';

  @override
  String get createPollTitleFieldLabel => '标题 *';

  @override
  String get createPollTitleFieldHelper => '清晰简洁的问题或陈述。';

  @override
  String get createPollDescriptionFieldLabel => '描述（可选）';

  @override
  String get createPollVotingModelTitle => '投票方式';

  @override
  String get createPollVotingModelSubtitle => '选择每个人可以选择一个答案还是多个答案。';

  @override
  String get createPollTypeFieldLabel => 'Vote 类型';

  @override
  String createPollSelectionRules(int min, int max) {
    return '选择规则：最少 $min 个，最多 $max 个选项（会根据 Vote 类型和选项自动调整）。';
  }

  @override
  String get createPollAllowVoteChangeTitle => '允许投票者更改投票';

  @override
  String get createPollAllowVoteChangeSubtitle => '在 Vote 关闭之前。';

  @override
  String get createPollOptionsTitle => '答案';

  @override
  String get createPollOptionsSubtitle => '至少输入两个供投票者选择的答案。标有 * 的字段为必填项。';

  @override
  String createPollOptionLabel(int index, Object requiredMarker) {
    return '选项 $index$requiredMarker';
  }

  @override
  String get createPollRemoveOptionTooltip => '删除选项';

  @override
  String get createPollAddOptionButton => '添加选项';

  @override
  String get createPollParticipationPrivacyTitle => '参与和隐私';

  @override
  String get createPollParticipationPrivacySubtitle => '决定谁可以投票，以及投票应保持何种程度的隐私。';

  @override
  String get createPollWhoCanVoteLabel => '谁可以投票？';

  @override
  String get createPollParticipationEveryoneSubtitle => '任何已注册用户都可以参与。';

  @override
  String get createPollParticipationGeoScopeSubtitle => '将此 Vote 限制为特定国家的用户。';

  @override
  String get createPollCountryFieldLabel => '此 Vote 的国家';

  @override
  String get createPollCountryFieldHelper => '该国家将决定谁可以参与此 Vote（未来后端集成）。';

  @override
  String get createPollVoteAnonymityTitle => '投票匿名性';

  @override
  String get createPollAnonymityAnonymousSubtitle => '公民投票平台的推荐默认设置。';

  @override
  String get createPollAnonymityPublicSubtitle => '请谨慎使用：投票可能与身份关联（未来功能）。';

  @override
  String get createPollResultsValidityTitle => '结果和有效性';

  @override
  String get createPollResultsValiditySubtitle => '控制结果何时可见，并在需要时设置最低法定人数。';

  @override
  String get createPollResultsVisibilityFieldLabel => '结果可见性';

  @override
  String get createPollQuorumTitle => '法定人数（可选）';

  @override
  String get createPollQuorumSubtitle => '如已设置，只有达到至少该票数时 Vote 才被视为有效。如无需法定人数，请留空。';

  @override
  String get createPollQuorumMinVotesFieldLabel => '最低票数';

  @override
  String get createPollTimingTitle => '时间安排';

  @override
  String get createPollTimingSubtitle => '设置 Vote 开放投票的时间。';

  @override
  String get createPollStartDateLabel => '开始日期';

  @override
  String get createPollEndDateLabel => '结束日期';

  @override
  String get createPollChangeDateButtonLabel => '更改';

  @override
  String get createPollTimingStatusInfo => '初始状态（开放/已安排/已关闭）将根据这些日期自动确定。';

  @override
  String get createPollSuccessMessage => 'Vote 创建成功';

  @override
  String get createPollSubmitCreatingLabel => '正在创建...';

  @override
  String get createPollSubmitLabel => '创建 Vote';

  @override
  String get createPollPollTypeYesNoLabel => '是 / 否';

  @override
  String get createPollPollTypeSingleChoiceLabel => '一个答案';

  @override
  String get createPollPollTypeMultipleChoiceLabel => '多个答案';

  @override
  String get createPollPollTypeApprovalLabel => '赞成投票';

  @override
  String get createPollPollTypeRankedLabel => '排序选择';

  @override
  String get createPollPollTypeScoreLabel => '评分 / 评级';

  @override
  String get createPollParticipationScopeEveryoneLabel => '所有人都可以投票';

  @override
  String get createPollParticipationScopeGeoScopeOnlyLabel => '仅限特定国家的用户';

  @override
  String get createPollAnonymityLevelAnonymousLabel => '投票匿名';

  @override
  String get createPollAnonymityLevelPublicLabel => '投票公开（高级 / 限制用途）';

  @override
  String get createPollResultsVisibilityAlwaysLabel => '始终可见（Vote 开放期间）';

  @override
  String get createPollResultsVisibilityAfterVoteLabel => '仅在投票后可见';

  @override
  String get createPollResultsVisibilityAfterCloseLabel => '仅在 Vote 关闭后可见';

  @override
  String get homeLoginButton => '登录';

  @override
  String get homeRegisterButton => '注册';

  @override
  String get homeProfileButton => '个人资料';

  @override
  String get homeLogoutButton => '退出登录';

  @override
  String get homeLogoutMessage => '已退出登录。你现在以访客模式使用应用（只读）。';

  @override
  String get homeSearchHint => '搜索城市、国家、账户和内容...';

  @override
  String get searchPageTitle => '搜索';

  @override
  String get searchInputHint => '搜索账户、Vote、News、Voce...';

  @override
  String get searchClearTooltip => '清除搜索';

  @override
  String get searchTypeAll => '全部';

  @override
  String get searchTypePolls => 'Vote';

  @override
  String get searchTypeNews => 'News';

  @override
  String get searchTypePosts => 'Voce';

  @override
  String get searchTypeAccounts => '账户';

  @override
  String get searchSortHottest => '最热';

  @override
  String get searchSortLatest => '最新';

  @override
  String get searchPollStatusAll => '所有 Vote';

  @override
  String get searchPollStatusOpen => '开放';

  @override
  String get searchPollStatusClosed => '已关闭';

  @override
  String get searchIdleMessage => '输入关键词开始搜索。';

  @override
  String get searchErrorMessage => '搜索时出现问题。';

  @override
  String get searchRetryButton => '重试';

  @override
  String get searchEmptyMessage => '未找到相关结果。';

  @override
  String get searchContentUnavailable => '内容不可用';

  @override
  String get searchResultTypePoll => 'Vote';

  @override
  String get searchResultTypeNews => 'News';

  @override
  String get searchResultTypePost => 'Voce';

  @override
  String get searchResultTypeAccount => '账户';

  @override
  String get searchResultTypeMixed => '混合';

  @override
  String homeUserStatusLoggedIn(Object userId) {
    return '已登录为：$userId';
  }

  @override
  String get homeUserStatusGuest => '访客模式：你只能阅读。登录或注册后即可投票、评论和互动。';

  @override
  String get homeScopeLabelWorld => '世界 — 全球投票和新闻';

  @override
  String get homeScopeLabelCountry => '国家 — 全国投票和新闻';

  @override
  String get homeScopeLabelCity => '城市 — 本地城市投票和新闻';

  @override
  String get homeScopeShortWorld => '世界';

  @override
  String get homeScopeShortCountry => '国家';

  @override
  String get homeScopeShortCity => '城市';

  @override
  String get homeScopeChipWorld => '世界';

  @override
  String get homeScopeChipItaly => '意大利';

  @override
  String get homeScopeChipTorino => '都灵';

  @override
  String get homeScopeChangedWorld => '范围已切换为世界';

  @override
  String get homeScopeChangedItaly => '范围已切换为意大利';

  @override
  String get homeScopeChangedTorino => '范围已切换为都灵';

  @override
  String get followScopeButtonFollowed => '已关注';

  @override
  String get followScopeButtonFollow => '关注此地区';

  @override
  String get homeTrendingTitle => '实时脉搏';

  @override
  String get homeTrendingError => '无法加载此地区的实时脉搏。';

  @override
  String get homeTrendingEmpty => '此地区目前没有实时脉搏内容。';

  @override
  String homeForYouTitle(Object scope) {
    return '脉搏（$scope）';
  }

  @override
  String get homeForYouError => '无法加载此地区的脉搏。';

  @override
  String get homeForYouEmpty => '此地区目前没有脉搏推荐内容。';

  @override
  String homePollsTitle(Object scope) {
    return '焦点 Vote（$scope）';
  }

  @override
  String get homePollsEmptyTitle => '此地区没有 Vote';

  @override
  String get homePollsEmptySubtitle => '此地区目前没有可用的 Vote。';

  @override
  String get homePollsViewAllButton => '查看 Vote';

  @override
  String homeNewsTitle(Object scope) {
    return '头条 News（$scope）';
  }

  @override
  String get homeNewsErrorTitle => '无法加载新闻';

  @override
  String get homeNewsErrorSubtitle => '加载此地区新闻时出现问题。';

  @override
  String get homeNewsEmptyTitle => '此地区没有新闻';

  @override
  String get homeNewsEmptySubtitle => '此范围目前没有新闻内容。';

  @override
  String get homeNewsViewAllButton => '查看所有新闻';

  @override
  String get homeNewsBreakingBadge => '突发';

  @override
  String homeSocialTitle(Object scope) {
    return 'Voce（$scope）';
  }

  @override
  String get homeSocialErrorTitle => '无法加载 Voce';

  @override
  String get homeSocialErrorSubtitle => '加载此地区的 Voce 时出现问题。';

  @override
  String get homeSocialEmptyTitle => '此地区没有 Voce';

  @override
  String get homeSocialEmptySubtitle => '此地区目前没有 Voce 内容。';

  @override
  String get homeSocialViewFeedButton => '查看所有 Voce';

  @override
  String get pollDetail_title => 'Vote 详情';

  @override
  String get pollDetail_removeFromFavoritesTooltip => '从已保存中移除';

  @override
  String get pollDetail_addToFavoritesTooltip => '保存';

  @override
  String get pollDetail_chipAnonymous => '匿名投票';

  @override
  String get pollDetail_chipPublic => '公开投票';

  @override
  String get pollDetail_chipRestrictedGeo => '受地理范围限制';

  @override
  String pollDetail_quorumReached(int currentVotes, int requiredVotes) {
    return '已达到法定人数（$currentVotes / $requiredVotes）';
  }

  @override
  String pollDetail_quorumNotReached(int currentVotes, int requiredVotes) {
    return '未达到法定人数（$currentVotes / $requiredVotes）';
  }

  @override
  String get pollDetail_optionsTitle => '选项';

  @override
  String get pollDetail_statusClosedMessage => '此 Vote 已关闭。';

  @override
  String get pollDetail_statusScheduledMessage => '此 Vote 尚未开放。';

  @override
  String get pollDetail_statusNotAvailableMessage => '当前无法投票。';

  @override
  String get pollDetail_voteSubmitted => '投票提交成功！';

  @override
  String get pollDetail_voteButton => '投票';

  @override
  String get pollDetail_resultsTitle => '结果';

  @override
  String pollDetail_outcomePrefix(Object label) {
    return '结果：$label';
  }

  @override
  String get pollDetail_noResults => '暂无结果。';

  @override
  String get pollDetail_resultsAfterVote => '投票后可查看结果。';

  @override
  String get pollDetail_resultsWhenClosed => 'Vote 关闭后可查看结果。';

  @override
  String get pollType_yesNo => '是 / 否';

  @override
  String get pollType_singleChoice => '单选';

  @override
  String get pollType_multipleChoice => '多选';

  @override
  String get pollType_approval => '赞成';

  @override
  String get pollStatus_draft => '草稿';

  @override
  String get pollStatus_open => '开放';

  @override
  String get pollStatus_closed => '已关闭';

  @override
  String get pollStatus_scheduled => '已安排';

  @override
  String get pollGeo_global => '全球';

  @override
  String get pollGeo_local => '本地';

  @override
  String get pollOutcome_approved => '已通过';

  @override
  String get pollOutcome_rejected => '已否决';

  @override
  String get pollOutcome_tie => '平局';

  @override
  String get pollOutcome_noMajority => '无多数';

  @override
  String get pollOutcome_notApplicable => '不适用';

  @override
  String get pollList_title => 'Vote';

  @override
  String get pollList_scopeWorld => '世界';

  @override
  String get pollList_scopeCountryFallback => '国家';

  @override
  String get pollList_scopeCityFallback => '城市';

  @override
  String get pollList_scopeDescriptionGlobal => '显示全球 Vote。';

  @override
  String get pollList_scopeDescriptionCountry => '显示此国家的 Vote。';

  @override
  String get pollList_scopeDescriptionCity => '显示此城市的 Vote。';

  @override
  String get pollList_filterStatus_all => '全部';

  @override
  String get pollList_filterStatus_open => '开放';

  @override
  String get pollList_filterStatus_closed => '已关闭';

  @override
  String get pollList_sort_latest => '最新';

  @override
  String get pollList_sort_hottest => '最热';

  @override
  String get pollList_filterScope_currentArea => '当前地区';

  @override
  String pollList_headerTitle(Object scopeLabel, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '找到 $count 个 Vote',
      one: '找到 1 个 Vote',
      zero: '未找到 Vote',
    );
    return '$scopeLabel · $_temp0';
  }

  @override
  String get pollList_createPollButton => '创建 Vote';

  @override
  String get pollList_paginationHint => '滚动加载更多 Vote…';

  @override
  String get pollList_emptyMessage => '此地区没有符合筛选条件的 Vote。';

  @override
  String get pollType_ranked => '排序选择';

  @override
  String get pollType_score => '评分投票';

  @override
  String get pollVisibility_whileOpen => 'Vote 开放时可见结果';

  @override
  String get pollVisibility_afterVote => '投票后可见结果';

  @override
  String get pollVisibility_afterClose => '关闭后可见结果';

  @override
  String get pollCard_countryRestricted => '国家限制';

  @override
  String pollCard_restrictedToCountry(Object countryName) {
    return '仅限 $countryName';
  }

  @override
  String pollCard_quorumLabel(int minVotes) {
    return '法定人数 $minVotes';
  }

  @override
  String get pollCard_resultsVisibleChip => '结果可见';

  @override
  String get pollCard_resultsAfterVoteChip => '投票后';

  @override
  String get pollCard_resultsAfterCloseChip => '关闭后';

  @override
  String get pollCard_publicOfficialPublisher => '公职人员';

  @override
  String get pollCard_institutionPublisher => '机构';

  @override
  String get pollCard_representativePublisher => '代表';

  @override
  String pollCard_voteCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '票',
      one: '票',
    );
    return '$_temp0';
  }

  @override
  String get pollCard_viewDetails => '查看详情';

  @override
  String pollResult_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '结果（$count 票）',
      one: '结果（1 票）',
      zero: '结果（暂无投票）',
    );
    return '$_temp0';
  }

  @override
  String get voteError_noSelection => '请至少选择一个选项。';

  @override
  String get voteError_unauthorized => '你无权参与此 Vote。';

  @override
  String get voteError_generic => '提交投票失败，请重试。';

  @override
  String get commentSection_title => '评论';

  @override
  String get commentSection_sortLabel => '排序：';

  @override
  String get commentSection_sortOldest => '最早';

  @override
  String get commentSection_sortNewest => '最新';

  @override
  String get commentSection_errorGeneric => '加载评论时发生错误。';

  @override
  String get commentSection_empty => '暂无评论。成为第一个评论的人。';

  @override
  String get commentSection_loadMore => '加载更多评论';

  @override
  String commentSection_replyingTo(Object snippet) {
    return '回复：$snippet';
  }

  @override
  String get commentSection_cancelReply => '取消';

  @override
  String get commentSection_inputHintRoot => '添加评论...';

  @override
  String get commentSection_inputHintReply => '写回复...';

  @override
  String get commentSection_deleteAction => '删除';

  @override
  String get commentSection_replyAction => '回复';

  @override
  String get commentSection_youBadge => '你';

  @override
  String get newsDetail_title => 'News 详情';

  @override
  String get newsDetail_breakingBadge => '突发';

  @override
  String get newsDetail_removeFromFavoritesTooltip => '从已保存中移除';

  @override
  String get newsDetail_addToFavoritesTooltip => '保存';

  @override
  String get newsDetail_bodyFallback => '此新闻暂无更多正文内容。';

  @override
  String get newsDetail_footerMoreContext => '更多背景和来源即将提供。';

  @override
  String get newsFeed_title => 'News';

  @override
  String get newsFeed_scopeWorld => '世界';

  @override
  String get newsFeed_scopeCountry => '国家';

  @override
  String get newsFeed_scopeCity => '城市';

  @override
  String newsFeed_scopeLabel(Object scope) {
    return '范围：$scope';
  }

  @override
  String get newsFeed_scopeGlobalDescription => '显示全球新闻。';

  @override
  String get newsFeed_scopeCountryDescription => '显示此国家的新闻。';

  @override
  String get newsFeed_scopeCityDescription => '显示此城市的新闻。';

  @override
  String get newsFeed_emptyTitle => '此地区暂无新闻。';

  @override
  String get newsFeed_emptySubtitle => '下拉刷新或稍后重试。';

  @override
  String newsFeed_itemsFound(int count) {
    return '找到 $count 条新闻';
  }

  @override
  String get newsFeed_loadingMoreHint => '滚动加载更多新闻…';

  @override
  String get newsFeed_errorTitle => '无法加载新闻';

  @override
  String get newsFeed_errorGeneric => '加载新闻时发生意外错误。';

  @override
  String get newsFeed_retryButton => '重试';

  @override
  String get newsCard_headerTitle => 'News';

  @override
  String get newsFeed_errorUnauthorized => 'News 配置无效（API 密钥）。';

  @override
  String get newsFeed_errorRateLimited => '请求过多，请稍后重试。';

  @override
  String get newsFeed_errorServerUnavailable => 'News 服务暂时不可用，请稍后重试。';

  @override
  String get newsFeed_errorTimeout => '请求耗时过长，请重试。';

  @override
  String get newsFeed_errorNetwork => '无网络连接。请检查网络后重试。';

  @override
  String get newsFeed_moreTooltip => '更多';

  @override
  String get newsFeed_actionCopyTitle => '复制标题';

  @override
  String get newsFeed_actionRefreshFeed => '刷新信息流';

  @override
  String get newsFeed_copiedTitleToast => '标题已复制';

  @override
  String get newsFeed_languageTooltip => 'News 语言';

  @override
  String get newsFeed_languageAuto => '自动';

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
  String get newsFeed_languageLimitedHint => '此语言的来源有限。请尝试“自动”。';

  @override
  String get newsTopic_all => '全部';

  @override
  String get newsTopic_world => '世界';

  @override
  String get newsTopic_nation => '国家';

  @override
  String get newsTopic_business => '商业';

  @override
  String get newsTopic_technology => '科技';

  @override
  String get newsTopic_science => '科学';

  @override
  String get newsTopic_health => '健康';

  @override
  String get newsTopic_sports => '体育';

  @override
  String get newsTopic_entertainment => '娱乐';

  @override
  String get newsDetail_openSource => '打开来源文章';

  @override
  String get newsDetail_openSourceUnavailable => '无法打开来源文章';

  @override
  String get socialFeedTitle => 'Voce';

  @override
  String get socialFeedCreatePostButton => '创建 Voce';

  @override
  String get commonCancelButton => '取消';

  @override
  String get commonApplyButton => '应用';

  @override
  String get homeScopeChooseCountry => '选择国家';

  @override
  String get homeScopeCountrySearchHint => '搜索国家或代码...';

  @override
  String get homeScopeChooseCity => '选择城市';

  @override
  String homeScopeCountryWithCode(String code) {
    return '国家：$code';
  }

  @override
  String get homeScopeCityFieldLabel => '城市';

  @override
  String get homeScopeCityExampleHint => '输入城市，例如 Merano';

  @override
  String get homeScopeCityRequiredError => '请输入城市。';

  @override
  String get homeScopeCityNotFoundError => '在所选国家中未找到该城市。';

  @override
  String get homeScopeCityVerificationError => '无法验证城市。请重试。';

  @override
  String get homeScopeVerifyingButton => '正在验证...';

  @override
  String get homeMapOpenButton => '打开地图';

  @override
  String get homeHeroHeadline => '塑造未来。\\n一起。';

  @override
  String get homeHeroPollsAction => 'Vote';

  @override
  String get homeHeroNewsAction => 'News';

  @override
  String get homeHeroCreateAction => '创建';

  @override
  String get homeHeroExploreAction => '探索';

  @override
  String get homeAccountMenuLabel => '账户';

  @override
  String get homeThemeSystemMenuItem => '主题：跟随系统';

  @override
  String get homeThemeLightMenuItem => '主题：浅色';

  @override
  String get homeThemeDarkMenuItem => '主题：深色';

  @override
  String get profileAppLanguageTitle => '应用语言';

  @override
  String get profileAppLanguageSystem => '系统';

  @override
  String get profileAppLanguageSystemDescription => '使用设备语言';

  @override
  String get profileAppLanguageItalian => '意大利语';

  @override
  String get profileAppLanguageEnglish => '英语';

  @override
  String get homeNotificationsTooltip => '通知';

  @override
  String get postCard_authorFallback => '作者';

  @override
  String get postCard_globalLocation => '全球';

  @override
  String get commonSaveButton => '保存';

  @override
  String get commonDeleteButton => '删除';

  @override
  String get contentReport_menuAction => '举报内容';

  @override
  String get contentReport_dialogTitle => '举报内容';

  @override
  String get contentReport_authenticationRequired => '你必须登录后才能举报内容';

  @override
  String get contentReport_submittedMessage => '举报已提交';

  @override
  String get contentReport_alreadySubmittedMessage => '你已经举报过此内容';

  @override
  String get contentReport_submitError => '无法提交举报';

  @override
  String get contentReport_sendButton => '提交';

  @override
  String get contentReport_reasonSpam => '垃圾信息';

  @override
  String get contentReport_reasonHarassment => '骚扰或辱骂';

  @override
  String get contentReport_reasonHateSpeech => '仇恨言论';

  @override
  String get contentReport_reasonMisinformation => '虚假信息';

  @override
  String get contentReport_reasonViolence => '暴力';

  @override
  String get contentReport_reasonOther => '其他';

  @override
  String get postDetail_title => 'Voce 详情';

  @override
  String get postDetail_favoriteUpdateError => '无法更新已保存内容';

  @override
  String get postDetail_shareMessage => '打开 Social Vote 查看此 Voce。';

  @override
  String get postDetail_shareError => '无法分享 Voce';

  @override
  String get postDetail_editDialogTitle => '编辑 Voce';

  @override
  String get postDetail_editTitleFieldLabel => '标题';

  @override
  String get postDetail_editContentFieldLabel => '内容';

  @override
  String get postDetail_editRequiredError => '标题和内容为必填项。';

  @override
  String get postDetail_updateSuccess => 'Voce 已更新';

  @override
  String get postDetail_updateError => '无法更新 Voce';

  @override
  String get postDetail_deleteDialogTitle => '删除此 Voce？';

  @override
  String get postDetail_deleteDialogMessage => '此操作无法撤销。';

  @override
  String get postDetail_deleteError => '无法删除 Voce';

  @override
  String get postDetail_editMenuItem => '编辑 Voce';

  @override
  String get postDetail_deleteMenuItem => '删除 Voce';

  @override
  String get postDetail_loadError => '加载 Voce 时发生错误。';

  @override
  String get postDetail_notFound => '未找到 Voce。';

  @override
  String get postDetail_errorTitle => '错误';

  @override
  String get postDetail_authorFallback => '作者';

  @override
  String get postDetail_shareAction => '分享';

  @override
  String get postDetail_saveAction => '保存';

  @override
  String get postDetail_addToFavoritesTooltip => '保存';

  @override
  String get postDetail_removeFromFavoritesTooltip => '从已保存中移除';

  @override
  String get newsDetail_favoriteUpdateError => '无法更新已保存内容';

  @override
  String get newsDetail_shareMessage => '打开 Social Vote 查看此新闻。';

  @override
  String get newsDetail_shareError => '无法分享新闻';

  @override
  String get newsDetail_shareTooltip => '分享';

  @override
  String get authLoginPageTitle => '登录';

  @override
  String get authLoginHeadline => '欢迎回来';

  @override
  String get authEmailLabel => '电子邮箱';

  @override
  String get authPasswordLabel => '密码';

  @override
  String get authRememberMeLabel => '记住我';

  @override
  String get authForgotPasswordAction => '忘记密码？';

  @override
  String get authLoginButton => '登录';

  @override
  String get authRegisterPrompt => '还没有账户？';

  @override
  String get authRegisterAction => '注册';

  @override
  String get authRegisterPageTitle => '注册';

  @override
  String get authRegisterHeadline => '创建账户';

  @override
  String get authPersonalAccountOwnershipTitle => '登录账户始终属于个人';

  @override
  String get authPersonalAccountOwnershipBody => '如果你代表某个组织，请先创建个人账户。登录后，你可以申请 Verified Organization，并在 Workspace 中管理它。';

  @override
  String get authOrganizationPathAction => '组织如何使用';

  @override
  String get authDisplayNameLabel => '公开名称';

  @override
  String get authUsernameLabel => '用户名';

  @override
  String get authCountryOfResidenceLabel => '居住国家';

  @override
  String get authCityOfResidenceLabel => '居住城市（可选）';

  @override
  String get authConfirmPasswordLabel => '确认密码';

  @override
  String get authLegalConsentPrefix => '我确认已年满 18 岁。我接受服务条款，并确认已阅读隐私政策。';

  @override
  String get authTermsOfServiceAction => '服务条款';

  @override
  String get authPrivacyPolicyAction => '隐私政策';

  @override
  String get authRegisterButton => '注册';

  @override
  String get authLoginPrompt => '已有账户？';

  @override
  String get authLoginAction => '登录';

  @override
  String get authForgotPasswordDialogTitle => '重置密码';

  @override
  String get authForgotPasswordDialogBody => '输入与你的账户关联的电子邮箱地址。我们会发送一个用于设置新密码的链接。';

  @override
  String get authForgotPasswordSendButton => '发送链接';

  @override
  String get authPasswordResetEmailSent => '密码重置邮件已发送。请查看收件箱。';

  @override
  String get authResetPasswordPageTitle => '重置密码';

  @override
  String get authResetPasswordHeadline => '设置新密码';

  @override
  String get authNewPasswordLabel => '新密码';

  @override
  String get authConfirmNewPasswordLabel => '确认新密码';

  @override
  String get authUpdatePasswordButton => '更新密码';

  @override
  String get authPasswordUpdated => '密码已成功更新。';

  @override
  String get authEmailConfirmationTitle => '检查邮箱';

  @override
  String get authEmailConfirmationIntro => '我们已向以下地址发送确认链接：';

  @override
  String get authEmailConfirmationInstructions => '打开邮件中的链接以验证你的地址。确认后，返回应用并登录。';

  @override
  String get authBackToLoginButton => '返回登录';

  @override
  String get authUseAnotherEmailButton => '使用其他邮箱地址';

  @override
  String get authEmailRequiredError => '请输入电子邮箱。';

  @override
  String get authEmailInvalidError => '请输入有效的电子邮箱地址。';

  @override
  String get authPasswordRequiredError => '请输入密码。';

  @override
  String get authPasswordTooShortError => '密码必须至少包含 8 个字符。';

  @override
  String get authDisplayNameRequiredError => '请输入公开名称。';

  @override
  String get authDisplayNameTooShortError => '公开名称太短。';

  @override
  String get authUsernameRequiredError => '请输入用户名。';

  @override
  String get authUsernameInvalidError => '使用 3 到 20 个字符：小写字母、数字和下划线。';

  @override
  String get authUsernameAlreadyTakenError => '该用户名已被使用。';

  @override
  String get authCountryRequiredError => '请选择居住国家。';

  @override
  String get authCityRequiredError => '请输入居住城市。';

  @override
  String get authConfirmPasswordRequiredError => '请确认密码。';

  @override
  String get authPasswordsDoNotMatchError => '两次输入的密码不一致。';

  @override
  String get authLegalConsentRequiredError => '注册前，请确认你已年满 18 岁、接受服务条款，并确认已阅读隐私政策。';

  @override
  String get authForgotPasswordEmailRequiredError => '请输入你要恢复的账户邮箱。';

  @override
  String get authInvalidCredentialsError => '电子邮箱或密码无效。';

  @override
  String get authEmailAlreadyRegisteredError => '此电子邮箱已注册。';

  @override
  String get authEmailNotConfirmedError => '电子邮箱尚未确认。登录前请查看收件箱。';

  @override
  String get authTooManyAttemptsError => '尝试次数过多。请等待几分钟后重试。';

  @override
  String get authNetworkError => '网络错误。请检查连接后重试。';

  @override
  String get authLoginGenericError => '登录失败。请重试。';

  @override
  String get authRegisterGenericError => '注册失败。请重试。';

  @override
  String get authPasswordResetGenericError => '无法发送重置链接。请重试。';

  @override
  String get authPasswordUpdateGenericError => '无法更新密码。请重试。';

  @override
  String get authShowPasswordTooltip => '显示密码';

  @override
  String get authHidePasswordTooltip => '隐藏密码';

  @override
  String get authTermsPageTitle => '服务条款';

  @override
  String get authPrivacyPageTitle => '隐私政策';

  @override
  String get authCloseButton => '关闭';

  @override
  String get pollDetail_favoriteUpdateError => '无法更新已保存内容';

  @override
  String get pollDetail_shareMessage => '打开 Social Vote 查看并参与此 Vote。';

  @override
  String get pollDetail_shareError => '无法分享 Vote';

  @override
  String get pollDetail_editPermissionError => '你只能编辑自己创建且尚无投票记录的 Vote';

  @override
  String get pollDetail_editSuccessMessage => 'Vote 已更新';

  @override
  String get pollDetail_editMenuItem => '编辑 Vote';

  @override
  String get pollDetail_editSavingMenuItem => '正在保存...';

  @override
  String get pollDetail_deletePermissionError => '你只能删除自己创建的 Vote';

  @override
  String get pollDetail_deleteError => '无法删除 Vote';

  @override
  String get pollDetail_deleteDialogTitle => '删除 Vote';

  @override
  String pollDetail_deleteDialogMessage(String title) {
    return '你确定要删除“$title”吗？此操作无法撤销。';
  }

  @override
  String get pollDetail_deleteMenuItem => '删除 Vote';

  @override
  String get pollDetail_deleteDeletingMenuItem => '正在删除...';

  @override
  String get pollDetail_publicVotesAvailableTitle => '可查看公开投票';

  @override
  String get pollDetail_publicVotesAvailableMessage => '此 Vote 允许查看每个选项的投票者。';

  @override
  String get pollDetail_publicVotesAction => '查看公开投票';

  @override
  String get pollDetail_retryButton => '重试';

  @override
  String get pollDetail_voteErrorNoOption => '请至少选择一个选项';

  @override
  String get pollDetail_voteErrorAuthenticationRequired => '你必须登录后才能投票';

  @override
  String get pollDetail_voteErrorClosed => '此 Vote 已关闭';

  @override
  String get pollDetail_voteErrorAlreadyVoted => '你已经参与过此 Vote';

  @override
  String get pollDetail_voteErrorGeneric => '无法提交投票';

  @override
  String get pollDetail_publicVotesSheetTitle => '公开投票';

  @override
  String get pollDetail_publicVotesSheetDescription => '这里可以查看此 Vote 中每个选项的投票者。';

  @override
  String get pollDetail_publicVotesSearchHint => '搜索用户';

  @override
  String get pollDetail_publicVotesLoadError => '无法加载公开投票';

  @override
  String get pollDetail_publicVotesEmpty => '暂无公开投票';

  @override
  String get pollDetail_publicVotesSearchEmpty => '未找到相关用户';

  @override
  String pollDetail_publicVotesResultsCount(int count) {
    return '已加载 $count 条结果';
  }

  @override
  String get pollDetail_publicVotesLoadMore => '加载更多';

  @override
  String get pollDetail_publicVotesUserFallback => '用户';

  @override
  String get pollDetail_editDialogTitle => '编辑 Vote';

  @override
  String get pollDetail_editTitleFieldLabel => '标题';

  @override
  String get pollDetail_editTitleRequired => '标题为必填项';

  @override
  String get pollDetail_editDescriptionFieldLabel => '描述';

  @override
  String get pollDetail_editError => '无法更新 Vote';

  @override
  String get pollDetail_loadError => '无法加载 Vote';

  @override
  String get pollDetail_notFound => '未找到 Vote';

  @override
  String get profileEditPageTitle => '编辑个人资料';

  @override
  String get profileLoginRequiredMessage => '你必须登录后才能编辑个人资料。';

  @override
  String get profileAvatarUploading => '正在上传...';

  @override
  String get profileUploadAvatarButton => '上传头像';

  @override
  String get profileDisplayNameLabel => '显示名称';

  @override
  String get profileDisplayNameRequiredError => '显示名称为必填项。';

  @override
  String get profileUsernameHint => '例如 mario_roma';

  @override
  String get profileUsernameHelper => '3–20 个字符：小写字母、数字和下划线';

  @override
  String get profileAvatarUrlLabel => '头像 URL';

  @override
  String get profileBioLabel => '简介';

  @override
  String get profileClearCountryButton => '清除国家';

  @override
  String get profileCityResidenceHelper => '保存前会根据所选国家验证居住城市。';

  @override
  String get profileCityNotFoundError => '在所选国家中未找到该城市。';

  @override
  String get profileCityVerificationError => '目前无法验证城市。';

  @override
  String get profileAvatarUploadError => '无法上传头像。';

  @override
  String get profileAccountSectionTitle => '账户';

  @override
  String get profileAccountEmailHelper => '无法在此页面更改账户邮箱地址。';

  @override
  String get profileChangePasswordAction => '更改密码';

  @override
  String get profileChangePasswordDescription => '为此账户设置新密码。';

  @override
  String get notificationsPageTitle => '通知';

  @override
  String get notificationsMarkAllReadAction => '全部标为已读';

  @override
  String get notificationsNoTargetMessage => '此通知没有可用的目标页面。';

  @override
  String get notificationsTargetUnavailableMessage => '与此通知关联的内容不可用。';

  @override
  String get notificationsLoadError => '无法加载通知。';

  @override
  String get notificationsRetryButton => '重试';

  @override
  String get notificationsEmptyMessage => '暂无通知。';

  @override
  String get notificationsCommentReplyTitle => '你的评论有新回复';

  @override
  String get notificationsMentionTitle => '有人提到了你';

  @override
  String get notificationsPollResultTitle => 'Vote 更新';

  @override
  String notificationsCommentReplySubtitle(String actor, String target) {
    return '用户 $actor 在 $target 中回复了你';
  }

  @override
  String notificationsMentionSubtitle(String actor, String target) {
    return '用户 $actor 在 $target 中提到了你';
  }

  @override
  String notificationsPollResultSubtitle(String target) {
    return '$target 中有新的结果';
  }

  @override
  String get notificationsTargetPost => '一条 Voce';

  @override
  String get notificationsTargetNews => '一篇新闻';

  @override
  String get notificationsTargetPoll => '一个 Vote';

  @override
  String get notificationsTargetVideo => '一个视频';

  @override
  String get notificationsTargetContent => '某些内容';

  @override
  String get notificationsUserFallback => '用户';

  @override
  String get profileDeleteAccountAction => '删除账户';

  @override
  String get profileDeleteAccountDescription => '永久删除账户及访问权限';

  @override
  String get profileDeleteAccountDialogTitle => '删除账户';

  @override
  String get profileDeleteAccountDialogMessage => '此操作为永久性操作，账户无法恢复。输入 DELETE 以确认。';

  @override
  String get profileDeleteAccountConfirmationLabel => '删除确认';

  @override
  String get profileDeleteAccountConfirmationHint => '输入 DELETE';

  @override
  String get profileDeleteAccountConfirmationError => '输入 DELETE 以继续。';

  @override
  String get profileDeleteAccountCancelButton => '取消';

  @override
  String get profileDeleteAccountConfirmButton => '永久删除';

  @override
  String get profileDeleteAccountFailureMessage => '无法删除账户。请重试。';

  @override
  String get identityActorTypePerson => '个人';

  @override
  String get identityActorTypePublicOfficial => '公职人员';

  @override
  String get identityActorTypePublicInstitution => '公共机构';

  @override
  String get identityActorTypeVerifiedOrganization => '已验证组织';

  @override
  String get identityVerificationNotVerified => '未验证';

  @override
  String get identityVerificationLevel1 => '已验证身份';

  @override
  String get identityVerificationLevel2 => '高级已验证身份';

  @override
  String get identityBadgeLevel1 => '已验证身份';

  @override
  String get identityBadgeLevel2 => '高级已验证身份';

  @override
  String get identityBadgePublicOfficial => '公职人员';

  @override
  String get identityBadgePublicInstitution => '公共机构';

  @override
  String get identityBadgeVerifiedOrganization => '已验证组织';

  @override
  String get identityOrganizationNameLabel => '组织名称';

  @override
  String get identityOrganizationNameRequired => '请输入组织名称。';

  @override
  String get identityInstitutionLevelMunicipality => '市级';

  @override
  String get identityInstitutionLevelProvince => '省级';

  @override
  String get identityInstitutionLevelRegion => '地区级';

  @override
  String get identityInstitutionLevelMinistry => '部委';

  @override
  String get identityInstitutionLevelGovernment => '政府';

  @override
  String get identityInstitutionLevelPublicAgency => '公共机构';

  @override
  String get identityInstitutionLevelOtherPublicBody => '其他公共机构';

  @override
  String get verificationRequestPersonLevel1 => '个人验证 — 1 级';

  @override
  String get verificationRequestPersonLevel2 => '个人验证 — 2 级';

  @override
  String get verificationRequestPublicOfficial => '公职人员验证';

  @override
  String get verificationRequestPublicInstitution => '公共机构验证';

  @override
  String get verificationRequestVerifiedOrganization => '组织验证';

  @override
  String get verificationCenterTitle => '验证与账户类型';

  @override
  String get verificationCurrentAccountSection => '当前账户';

  @override
  String verificationAccountTypeValue(String accountType) {
    return '账户类型：$accountType';
  }

  @override
  String verificationLevelValue(String level) {
    return '验证级别：$level';
  }

  @override
  String verificationOfficialTitleValue(String title) {
    return '正式职务：$title';
  }

  @override
  String verificationInstitutionNameValue(String name) {
    return '机构：$name';
  }

  @override
  String verificationOrganizationNameValue(String name) {
    return '组织：$name';
  }

  @override
  String verificationInstitutionLevelValue(String level) {
    return '机构级别：$level';
  }

  @override
  String get verificationActiveRequestSection => '进行中的申请';

  @override
  String get verificationProfileUnchangedUntilApproval => '在申请获批前，你当前的个人资料不会更改。';

  @override
  String get verificationCancelPendingAction => '取消待处理申请';

  @override
  String get verificationPendingBlocksNewRequests => '已有申请待处理时，无法提交新的申请。';

  @override
  String get verificationNoActiveRequestSection => '没有进行中的申请';

  @override
  String get verificationNoActiveRequestDescription => '你目前没有正在审核的申请。';

  @override
  String get verificationLastRejectedSection => '最近一次被拒申请';

  @override
  String get verificationLastRejectedDescription => '你最近一次申请已被拒绝。';

  @override
  String get verificationRejectedCanResubmit => '你当前的个人资料未发生变化。可以更正信息后重新提交申请。';

  @override
  String get verificationAvailableRequestsSection => '可申请项目';

  @override
  String get verificationRequestLevel1Title => '申请个人验证 — 1 级';

  @override
  String get verificationRequestLevel1Subtitle => '基础个人身份验证';

  @override
  String get verificationRequestLevel2Title => '申请个人验证 — 2 级';

  @override
  String get verificationRequestLevel2Subtitle => '高级个人身份验证';

  @override
  String get verificationRequestPublicOfficialTitle => '申请公职人员账户';

  @override
  String get verificationRequestPublicOfficialSubtitle => '需要正式职务并接受审核';

  @override
  String get verificationRequestPublicInstitutionTitle => '申请公共机构账户';

  @override
  String get verificationRequestPublicInstitutionSubtitle => '需要机构名称、机构级别并接受审核';

  @override
  String get verificationRequestOrganizationTitle => '申请已验证组织账户';

  @override
  String get verificationRequestOrganizationSubtitle => '需要组织信息、代表角色和 Admin 审核';

  @override
  String get verificationNoSelfServiceUpgrade => '当前账户状态没有可用的自助验证选项。';

  @override
  String get verificationRequestSubmitSuccess => '申请提交成功。';

  @override
  String get verificationRequestSubmitFailure => '无法提交申请。';

  @override
  String get verificationOfficialTitleDialogTitle => '公职人员验证';

  @override
  String get verificationOfficialTitleLabel => '正式职务';

  @override
  String get verificationOfficialTitleHint => '例如 市长、议员、部长';

  @override
  String get verificationInstitutionDialogTitle => '公共机构验证';

  @override
  String get verificationInstitutionNameLabel => '机构名称';

  @override
  String get verificationInstitutionNameHint => '例如 罗马市政府';

  @override
  String get verificationInstitutionLevelLabel => '机构级别';

  @override
  String get verificationOrganizationDialogTitle => '组织验证';

  @override
  String get verificationOrganizationNameHint => '例如 意大利环境协会';

  @override
  String get verificationSubmitRequestAction => '提交申请';

  @override
  String get verificationCancelDialogTitle => '取消申请';

  @override
  String get verificationCancelDialogBody => '确定要取消待处理的验证申请吗？';

  @override
  String get verificationCancelSuccess => '申请已取消。';

  @override
  String get verificationCancelFailure => '无法取消申请。';

  @override
  String get verificationStatusPendingSuffix => '申请审核中';

  @override
  String get verificationStatusRejectedSuffix => '最近一次申请被拒';

  @override
  String get verificationReviewPageTitle => '验证审核';

  @override
  String get verificationReviewLoginRequired => '你必须登录后才能审核验证申请。';

  @override
  String verificationReviewPendingCount(int count) {
    return '待处理申请：$count';
  }

  @override
  String get verificationReviewNoPendingRequests => '没有待处理的验证申请。';

  @override
  String get verificationReviewUserIdLabel => '用户 ID';

  @override
  String get verificationReviewSubmittedLabel => '提交时间';

  @override
  String get verificationReviewOfficialTitleLabel => '正式职务';

  @override
  String get verificationReviewInstitutionLabel => '机构';

  @override
  String get verificationReviewOrganizationLabel => '组织';

  @override
  String get verificationReviewNoteLabel => '审核备注';

  @override
  String get verificationReviewRejectAction => '拒绝';

  @override
  String get verificationReviewApproveAction => '批准';

  @override
  String get verificationReviewApproveDialogTitle => '批准申请';

  @override
  String get verificationReviewRejectDialogTitle => '拒绝申请';

  @override
  String get verificationReviewApproveConfirmation => '确认批准此申请？';

  @override
  String get verificationReviewRejectConfirmation => '确认拒绝此申请？';

  @override
  String get verificationReviewOptionalNoteLabel => '可选审核备注';

  @override
  String get verificationReviewRequiredNoteLabel => '拒绝原因';

  @override
  String get verificationReviewOptionalHelper => '可选';

  @override
  String get verificationReviewRequiredHelper => '拒绝时必填';

  @override
  String get verificationReviewRequiredNoteError => '请输入拒绝原因。';

  @override
  String get verificationReviewApprovedSuccess => '申请已批准。';

  @override
  String get verificationReviewRejectedSuccess => '申请已拒绝。';

  @override
  String get verificationReviewOperationFailure => '操作失败。';

  @override
  String get adminCenterTitle => 'Admin Center';

  @override
  String get adminCenterDashboardNavigation => '仪表盘';

  @override
  String get adminCenterUsersNavigation => '用户';

  @override
  String get adminCenterVerificationNavigation => '验证';

  @override
  String get adminCenterReportsNavigation => '举报';

  @override
  String get adminCenterAuditNavigation => '审计';

  @override
  String get adminCenterAccountDetailsTitle => '账户详情';

  @override
  String get adminCenterTryAgainAction => '重试';

  @override
  String get adminCenterRetryAction => '重试';

  @override
  String get adminCenterClearAction => '清除';

  @override
  String get adminCenterApplyFiltersAction => '应用筛选';

  @override
  String get adminCenterAllDates => '所有日期';

  @override
  String get adminCenterAuditDateFilterHelp => '按日期筛选审计记录';

  @override
  String get adminCenterActorUserIdLabel => '操作人用户 ID';

  @override
  String get adminCenterActionLabel => '操作';

  @override
  String get adminCenterAuditActionHint => 'resolve_escalated_report';

  @override
  String get adminCenterTargetIdLabel => '目标 ID';

  @override
  String get adminCenterOutcomeLabel => '结果';

  @override
  String get adminCenterAllOutcomes => '所有结果';

  @override
  String get adminCenterOutcomeSuccess => '成功';

  @override
  String get adminCenterOutcomeFailure => '失败';

  @override
  String get adminCenterOutcomeDenied => '已拒绝';

  @override
  String get adminCenterOutcomeNoChange => '无变化';

  @override
  String get adminCenterOutcomeUnknown => '未知';

  @override
  String get adminCenterAuditUnavailableTitle => '审计不可用';

  @override
  String get adminCenterAuditUnavailableMessage => '请检查网络连接和权限后重试。';

  @override
  String get adminCenterNoAuditEntriesTitle => '没有审计记录';

  @override
  String get adminCenterNoAuditEntriesMessage => '没有符合所选筛选条件的记录。';

  @override
  String get adminCenterAuditIdLabel => '审计 ID';

  @override
  String get adminCenterActorLabel => '操作人';

  @override
  String get adminCenterReasonLabel => '原因';

  @override
  String get adminCenterTimestampLabel => '时间戳';

  @override
  String get adminCenterErrorLabel => '错误';

  @override
  String get adminCenterRecordedValuesTitle => '已记录值';

  @override
  String get adminCenterPreviousValueLabel => '之前';

  @override
  String get adminCenterNewValueLabel => '之后';

  @override
  String get adminCenterContentTypeLabel => '内容类型';

  @override
  String get adminCenterAllContent => '所有内容';

  @override
  String get adminCenterPolls => 'Vote';

  @override
  String get adminCenterPosts => 'Voce';

  @override
  String get adminCenterNews => 'News';

  @override
  String get adminCenterAwaitingAdminDecision => '等待 Admin 决策';

  @override
  String get adminCenterStatusLabel => '状态';

  @override
  String get adminCenterAllStatuses => '所有状态';

  @override
  String get adminCenterStatusOpen => '开放';

  @override
  String get adminCenterStatusInReview => '审核中';

  @override
  String get adminCenterStatusResolved => '已解决';

  @override
  String get adminCenterStatusDismissed => '已驳回';

  @override
  String get adminCenterAdminQueueUnavailableTitle => 'Admin 升级队列不可用';

  @override
  String get adminCenterReportsUnavailableTitle => '举报不可用';

  @override
  String get adminCenterConnectionTryAgainMessage => '请检查网络连接后重试。';

  @override
  String get adminCenterNoAdminReportsTitle => '没有等待 Admin 决策的举报';

  @override
  String get adminCenterNoReportsTitle => '没有举报';

  @override
  String get adminCenterNoAdminReportsMessage => '没有需要管理员审核的升级举报。';

  @override
  String get adminCenterNoReportsMessage => '没有符合所选筛选条件的举报。';

  @override
  String get adminCenterSearchUsersHint => '按名称、用户名、电子邮箱或 ID 搜索';

  @override
  String get adminCenterClearSearchTooltip => '清除搜索';

  @override
  String get adminCenterUsersUnavailableTitle => '用户不可用';

  @override
  String get adminCenterNoUsersFoundTitle => '未找到用户';

  @override
  String get adminCenterNoUsersTitle => '没有用户';

  @override
  String get adminCenterNoUsersFoundMessage => '请尝试其他名称、用户名、电子邮箱或 ID。';

  @override
  String get adminCenterNoUsersMessage => '没有可显示的账户。';

  @override
  String get adminCenterAccountUnavailableTitle => '账户不可用';

  @override
  String get adminCenterBackToUsersAction => '返回用户列表';

  @override
  String get adminCenterPublicIdentitySection => '公开身份';

  @override
  String get adminCenterDisplayNameLabel => '显示名称';

  @override
  String get adminCenterNotProvided => '未提供';

  @override
  String get adminCenterUsernameLabel => '用户名';

  @override
  String get adminCenterUserIdLabel => '用户 ID';

  @override
  String get adminCenterIdentityTypeLabel => '身份类型';

  @override
  String get adminCenterAccountSection => '账户';

  @override
  String get adminCenterTechnicalRoleLabel => '技术角色';

  @override
  String get adminCenterRoleMirrorLabel => '资料角色镜像';

  @override
  String get adminCenterRoleSynchronizationLabel => '角色同步';

  @override
  String get adminCenterSynchronized => '已同步';

  @override
  String get adminCenterNotSynchronized => '未同步';

  @override
  String get adminCenterRoleNotSynchronized => '角色未同步';

  @override
  String get adminCenterAccountStatusLabel => '账户状态';

  @override
  String get adminCenterSuspendedUntilLabel => '暂停至';

  @override
  String get adminCenterAccountManagementSection => '账户管理';

  @override
  String get adminCenterDangerZoneSection => '危险区域';

  @override
  String get adminCenterRoleManagementSection => '角色管理';

  @override
  String get adminCenterVerificationLevelLabel => '验证级别';

  @override
  String get adminCenterVerificationStatusLabel => '验证状态';

  @override
  String get adminCenterAccessInformationSection => '访问信息';

  @override
  String get adminCenterEmailLabel => '电子邮箱';

  @override
  String get adminCenterNotAvailable => '不可用';

  @override
  String get adminCenterEmailConfirmationLabel => '邮箱确认';

  @override
  String get adminCenterNotConfirmed => '未确认';

  @override
  String get adminCenterRegisteredLabel => '注册时间';

  @override
  String get adminCenterLastAccessLabel => '最后访问';

  @override
  String get adminCenterLoadingDashboardTitle => '正在加载仪表盘';

  @override
  String get adminCenterLoadingDashboardMessage => '正在获取最新指标。';

  @override
  String get adminCenterDashboardUnavailableTitle => '仪表盘不可用';

  @override
  String get adminCenterIndicatorsUnavailableMessage => '无法加载指标。';

  @override
  String get adminCenterVerificationPendingIndicator => '待验证';

  @override
  String get adminCenterOpenReportsIndicator => '未处理举报';

  @override
  String get adminCenterSuspendedAccountsIndicator => '已暂停账户';

  @override
  String get adminCenterStaffIndicator => '工作人员';

  @override
  String get adminCenterNoPendingWorkTitle => '没有待处理工作';

  @override
  String get adminCenterNoPendingWorkMessage => '验证、举报和暂停账户均已处理完毕。';

  @override
  String get adminCenterCouldNotUpdateUsers => '无法更新用户列表。';

  @override
  String get adminCenterCouldNotUpdateReports => '无法更新举报队列。';

  @override
  String get adminCenterUnnamedUser => '未命名用户';

  @override
  String get adminCenterTemporarySuspensionTitle => '临时暂停';

  @override
  String get adminCenterReactivateDescription => '立即解除暂停并允许重新登录。';

  @override
  String get adminCenterSuspendDescription => '在限定时间内阻止访问并结束所有当前会话。';

  @override
  String get adminCenterSuspensionUnavailableDescription => '暂停操作要求账户已同步且不是 admin 账户。';

  @override
  String get adminCenterReactivateAccountAction => '重新激活账户';

  @override
  String get adminCenterSuspendAccountAction => '暂停账户';

  @override
  String get adminCenterForceLogoutAction => '强制退出';

  @override
  String get adminCenterSuspendedForceLogoutDescription => '暂停操作已结束当前会话。测试单独退出前，请先重新激活账户。';

  @override
  String get adminCenterForceLogoutDescription => '结束所有当前会话，但不暂停账户。';

  @override
  String get adminCenterForceLogoutUnavailableDescription => '强制退出要求账户已同步且不是 admin 账户。';

  @override
  String get adminCenterPermanentDeletionTitle => '永久删除账户';

  @override
  String get adminCenterPermanentDeletionDescription => '删除认证数据、结束所有会话，并匿名化保留的公开记录。';

  @override
  String get adminCenterDeletionUnavailableDescription => '删除操作要求账户已同步且不是 admin 账户。';

  @override
  String get adminCenterDeleteAccountPermanentlyAction => '永久删除账户';

  @override
  String get adminCenterDurationOneHour => '1 小时';

  @override
  String get adminCenterDurationOneDay => '24 小时';

  @override
  String get adminCenterDurationSevenDays => '7 天';

  @override
  String get adminCenterDurationThirtyDays => '30 天';

  @override
  String get adminCenterSuspendImmediateEffect => '账户将立即失去访问权限，所有当前会话都会结束。';

  @override
  String get adminCenterDurationLabel => '时长';

  @override
  String get adminCenterSuspendReasonHint => '说明为何必须暂停此账户';

  @override
  String get adminCenterReactivateReasonHint => '说明为何可以重新激活此账户';

  @override
  String get adminCenterReactivateConfirmation => '我确认此账户可以恢复访问权限。';

  @override
  String get adminCenterReactivateFailure => '无法重新激活账户。请检查其角色和状态后重试。';

  @override
  String get adminCenterReactivateSuccess => '账户已重新激活，现在允许重新登录。';

  @override
  String get adminCenterForceLogoutFullDescription => '结束此账户的所有当前会话。账户仍保持有效，可以再次登录。';

  @override
  String get adminCenterForceLogoutReasonHint => '说明为何必须结束当前会话';

  @override
  String get adminCenterForceLogoutConfirmation => '我确认立即结束此账户的所有当前会话。';

  @override
  String get adminCenterForceLogoutFailure => '无法使账户退出。请检查其角色和状态后重试。';

  @override
  String get adminCenterForceLogoutSuccess => '当前会话已结束。账户可以再次登录。';

  @override
  String get adminCenterSuspendFailure => '无法暂停账户。请检查其角色和状态后重试。';

  @override
  String get adminCenterDeleteReasonHint => '说明为何必须删除此账户';

  @override
  String get adminCenterTypeDeleteLabel => '输入 DELETE';

  @override
  String get adminCenterTypeAccountIdLabel => '输入完整的账户 ID';

  @override
  String get adminCenterDeletePermanentlyAction => '永久删除';

  @override
  String get adminCenterDeleteIrreversibleWarning => '此操作不可逆。认证数据和当前会话将被删除，头像会被删除，保留的公开记录将被匿名化。审计记录将保留。';

  @override
  String get adminCenterDeleteFailure => '无法删除账户。请检查其角色、状态和确认信息后重试。';

  @override
  String get adminCenterDeleteSuccess => '账户已永久删除，个人数据已匿名化。';

  @override
  String get adminCenterChangeTechnicalRoleTitle => '更改技术角色';

  @override
  String get adminCenterChangeRoleDescription => '确认前请核对当前角色和目标角色。';

  @override
  String get adminCenterChangeRoleUnavailableDescription => '角色更改要求账户已同步且未删除。';

  @override
  String get adminCenterChangeRoleAction => '更改角色';

  @override
  String get adminCenterChangePublicIdentityTitle => '更改公开身份';

  @override
  String get adminCenterChangeIdentityDescription => '更新公开账户类型和验证级别。';

  @override
  String get adminCenterChangeIdentityUnavailableDescription => '身份更改要求账户已同步且不是 admin 账户。';

  @override
  String get adminCenterChangeIdentityAction => '更改身份';

  @override
  String get adminCenterChoosePublicIdentityMessage => '选择公开账户类型及其验证状态。';

  @override
  String get adminCenterPublicAccountTypeLabel => '公开账户类型';

  @override
  String get adminCenterPersonVerificationHelper => '1 级和 2 级仅适用于 Persona。';

  @override
  String get adminCenterNonPersonVerificationHelper => '非 Persona 账户不使用 1 级或 2 级验证。';

  @override
  String get adminCenterBeforeLabel => '之前';

  @override
  String get adminCenterAfterLabel => '之后';

  @override
  String get adminCenterIdentityReasonHint => '说明为何必须更改公开身份';

  @override
  String get adminCenterIdentityConfirmation => '我确认上方显示的公开身份和验证级别。';

  @override
  String get adminCenterIdentityChangeFailure => '无法更改公开身份。请检查账户状态后重试。';

  @override
  String get adminCenterChooseTechnicalRoleMessage => '选择新的技术角色，并记录为何需要此更改。';

  @override
  String get adminCenterNewTechnicalRoleLabel => '新的技术角色';

  @override
  String get adminCenterSelectRole => '选择角色';

  @override
  String get adminCenterRoleSessionWarning => '此更改会结束目标用户的当前会话。对方必须重新登录后才能继续使用账户。';

  @override
  String get adminCenterRoleReasonHint => '说明为何必须更改技术角色';

  @override
  String get adminCenterRoleConfirmation => '我确认上方显示的角色，并理解目标用户必须重新登录。';

  @override
  String get adminCenterRoleChangeFailure => '无法完成角色更改。请检查账户状态后重试。';

  @override
  String get adminCenterChangingRole => '正在更改角色';

  @override
  String get adminCenterConfirmRoleChange => '确认角色更改';

  @override
  String get adminCenterRoleUser => '用户';

  @override
  String get adminCenterRoleModerator => '版主';

  @override
  String get adminCenterRoleAdmin => 'Admin';

  @override
  String get adminCenterAccountStatusActive => '有效';

  @override
  String get adminCenterAccountStatusSuspended => '已暂停';

  @override
  String get adminCenterAccountStatusDeleted => '已删除';

  @override
  String get adminCenterVerificationStatusNone => '无';

  @override
  String get adminCenterVerificationStatusPending => '待处理';

  @override
  String get adminCenterVerificationStatusRejected => '已拒绝';

  @override
  String get adminCenterVerificationNotVerified => '未验证';

  @override
  String get adminCenterVerificationLevel1 => '1 级';

  @override
  String get adminCenterVerificationLevel2 => '2 级';

  @override
  String get adminCenterReportSingular => '举报';

  @override
  String get adminCenterReportPlural => '举报';

  @override
  String get adminCenterUserSingular => '用户';

  @override
  String get adminCenterUserPlural => '用户';

  @override
  String get adminCenterPoll => 'Vote';

  @override
  String get adminCenterPost => 'Voce';

  @override
  String get adminCenterUnknown => '未知';

  @override
  String get adminCenterContentHidden => '内容已隐藏';

  @override
  String get adminCenterContentVisible => '内容可见';

  @override
  String get adminCenterReportedByLabel => '举报者';

  @override
  String get adminCenterContentOwnerLabel => '内容所有者';

  @override
  String get adminCenterReviewReportAction => '审核举报';

  @override
  String get adminCenterAdminDecisionAction => 'Admin 决策';

  @override
  String get adminCenterRestoreContentAction => '恢复内容';

  @override
  String get adminCenterHideContentAction => '隐藏内容';

  @override
  String get adminCenterOpenProfileAction => '打开个人资料';

  @override
  String get adminCenterOpenContentAction => '打开内容';

  @override
  String get adminCenterDecisionNoViolation => '无违规';

  @override
  String get adminCenterDecisionViolationConfirmed => '违规已确认';

  @override
  String get adminCenterDecisionEscalateToAdmin => '升级给 Admin';

  @override
  String get adminCenterResolutionNoAccountAction => '不对账户采取操作';

  @override
  String get adminCenterResolutionAccountSuspended => '账户已暂停';

  @override
  String get adminCenterResolutionLogoutForced => '已强制退出';

  @override
  String get adminCenterResolutionAccountDeleted => '账户已删除';

  @override
  String get adminCenterReviewerLabel => '审核人';

  @override
  String get adminCenterDecisionDescriptionNoViolation => '因内容未违反现行规则而驳回举报。';

  @override
  String get adminCenterDecisionDescriptionViolation => '确认存在违规，并将案件保留在审核中，以执行 AC8.5 中的内容处理操作。';

  @override
  String get adminCenterDecisionDescriptionEscalation => '将案件升级给管理员进行账户级审核。';

  @override
  String get adminCenterChooseModerationOutcome => '为此举报选择审核结果。';

  @override
  String get adminCenterDecisionAlreadyRecordedFailure => '无法记录决定。该举报可能已被审核。请刷新队列后重试。';

  @override
  String get adminCenterDecisionLabel => '决定';

  @override
  String get adminCenterReportReasonLabel => '举报原因';

  @override
  String get adminCenterReviewNoteLabel => '审核备注';

  @override
  String get adminCenterReviewNoteHint => '说明证据和审核决定';

  @override
  String get adminCenterRecordingDecision => '正在记录决定';

  @override
  String get adminCenterConfirmDecision => '确认决定';

  @override
  String get adminCenterAdministratorDecisionTitle => '管理员决定';

  @override
  String get adminCenterResolutionDescriptionNoAction => '关闭已升级举报，不对账户进行更改。';

  @override
  String get adminCenterResolutionDescriptionSuspended => '在账户暂停操作已成功并记录于审计日志后关闭举报。';

  @override
  String get adminCenterResolutionDescriptionLogout => '在强制退出操作已成功并记录于审计日志后关闭举报。';

  @override
  String get adminCenterResolutionDescriptionDeleted => '在账户删除操作已成功并记录于审计日志后关闭举报。';

  @override
  String get adminCenterChooseFinalOutcome => '为此次升级选择最终管理员处理结果。';

  @override
  String get adminCenterAdminResolutionFailure => '无法记录管理员决定。请刷新队列后重试。';

  @override
  String get adminCenterAdminResolutionRequiresAction => '请先完成对应的账户操作，然后返回此举报并记录最终管理员决定。';

  @override
  String get adminCenterEscalationNoteLabel => '升级备注';

  @override
  String get adminCenterFinalOutcomeLabel => '最终结果';

  @override
  String get adminCenterAdministratorNoteLabel => '管理员备注';

  @override
  String get adminCenterAdministratorNoteHint => '说明最终的账户级决定';

  @override
  String get adminCenterHideContentFailure => '无法隐藏内容。请刷新举报队列后重试。';

  @override
  String get adminCenterRestoreContentFailure => '无法恢复内容。请刷新举报队列后重试。';

  @override
  String get adminCenterHideContentWarning => '这会将被举报内容从公开访问中移除。之后可在“已解决举报”筛选中恢复。';

  @override
  String get adminCenterRestoreContentWarning => '这会让被举报内容重新公开可见。';

  @override
  String get adminCenterActionReasonLabel => '操作原因';

  @override
  String get adminCenterHideContentReasonHint => '说明为何必须隐藏内容';

  @override
  String get adminCenterRestoreContentReasonHint => '说明为何可以恢复内容';

  @override
  String get adminCenterHidingContent => '正在隐藏内容';

  @override
  String get adminCenterRestoringContent => '正在恢复内容';

  @override
  String get adminCenterReportedProfileTitle => '被举报的个人资料';

  @override
  String get adminCenterReportedProfileNotice => '此个人资料上下文来自受保护的举报队列。管理员账户操作仍需单独执行。';

  @override
  String get adminCenterCouldNotRefreshIndicators => '无法刷新指标。';

  @override
  String get adminCenterCouldNotRefreshAccount => '无法刷新账户详情。';

  @override
  String get adminCenterReportAlreadyReviewed => '此举报已被审核或不再处于待审核状态。';

  @override
  String get adminCenterReportNotAwaitingAdmin => '此举报不在等待管理员决定。';

  @override
  String get adminCenterConfirmedViolationRequired => '更改内容可见性前必须先确认存在违规。';

  @override
  String get adminCenterContentHiddenSuccess => '被举报内容已隐藏。';

  @override
  String get adminCenterContentRestoredSuccess => '被举报内容已恢复。';

  @override
  String get adminCenterMissingContentId => '缺少原始内容标识符。';

  @override
  String get adminCenterUnsupportedTargetType => '此举报的目标类型不受支持。';

  @override
  String get adminCenterOriginalContentUnavailable => '原始内容已不可用。';

  @override
  String get adminCenterNoReportedProfile => '此内容没有关联的被举报个人资料。';

  @override
  String adminCenterRoleChangedSuccess(String previousRole, String newRole) {
    return '技术角色已从 $previousRole 更改为 $newRole。目标用户已退出，必须重新登录。';
  }

  @override
  String adminCenterIdentityChangedSuccess(String actorType, String verificationLevel) {
    return '公开身份已更改为 $actorType，验证级别为 $verificationLevel。';
  }

  @override
  String adminCenterAccountSuspendedSuccess(String dateTime) {
    return '账户已暂停至 $dateTime。目标用户已退出。';
  }

  @override
  String adminCenterReportDecisionRecorded(String decision) {
    return '举报决定已记录：$decision。';
  }

  @override
  String adminCenterAdministratorDecisionRecorded(String decision) {
    return '管理员决定已记录：$decision。';
  }

  @override
  String adminCenterUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个用户',
      one: '$count 个用户',
    );
    return '$_temp0';
  }

  @override
  String adminCenterReportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条举报',
      one: '$count 条举报',
    );
    return '$_temp0';
  }

  @override
  String adminCenterAccountValue(String account) {
    return '账户：$account';
  }

  @override
  String adminCenterSuspendedUntilValue(String dateTime) {
    return '暂停至：$dateTime';
  }

  @override
  String adminCenterSuspendConfirmation(String dateTime) {
    return '我确认暂停至 $dateTime，并立即结束当前会话。';
  }

  @override
  String adminCenterAccountIdValue(String accountId) {
    return '账户 ID：$accountId';
  }

  @override
  String adminCenterCurrentRoleValue(String role) {
    return '当前：$role';
  }

  @override
  String adminCenterTargetFallback(String targetType, String targetId) {
    return '$targetType $targetId';
  }

  @override
  String adminCenterMinimumCharactersRequired(int count) {
    return '备注至少需要 $count 个字符。';
  }

  @override
  String adminCenterMinimumReasonCharactersRequired(int count) {
    return '原因至少需要 $count 个字符。';
  }

  @override
  String adminCenterPageOf(int currentPage, int totalPages) {
    return '第 $currentPage 页，共 $totalPages 页';
  }

  @override
  String get profilePublicProfileSectionTitle => '公开资料';

  @override
  String get profileIdentityVerificationSectionTitle => '身份与验证';

  @override
  String get profilePreferencesSectionTitle => '偏好设置';

  @override
  String get profileNotificationsSectionTitle => '通知';

  @override
  String get profileActivitySectionTitle => '个人活动';

  @override
  String get profileSecurityAccountSectionTitle => '安全与账户';

  @override
  String get profileThemeTitle => '主题';

  @override
  String get profileThemeSystem => '跟随系统';

  @override
  String get profileThemeSystemDescription => '使用设备主题';

  @override
  String get profileThemeLight => '浅色';

  @override
  String get profileThemeDark => '深色';

  @override
  String get profileMyPollsTitle => 'Vote';

  @override
  String get profileMyPostsTitle => 'Voce';

  @override
  String get profileMyCommentsTitle => '我的评论';

  @override
  String get profileMyFavoritesTitle => '我的收藏';

  @override
  String get profileAccountConnectionsTitle => '关注与粉丝';

  @override
  String get accountConnectionsFollowingTab => '关注';

  @override
  String get accountConnectionsFollowersTab => '粉丝';

  @override
  String get accountConnectionsEmptyFollowing => '你还没有关注任何账户。';

  @override
  String get accountConnectionsEmptyFollowers => '你还没有粉丝。';

  @override
  String get accountConnectionsLoadError => '无法加载账户。请重试。';

  @override
  String get profileMyFollowedScopesTitle => '我关注的地区';

  @override
  String get profileLogoutAction => '退出登录';

  @override
  String get profileLogoutDescription => '退出当前账户';

  @override
  String get profileLogoutDialogTitle => '退出登录';

  @override
  String get profileLogoutDialogMessage => '确定要退出当前账户吗？';

  @override
  String get profileLogoutCancelButton => '取消';

  @override
  String get profileLogoutConfirmButton => '退出登录';

  @override
  String get publicProfilePageTitle => '公开资料';

  @override
  String get publicProfileUserFallback => '用户';

  @override
  String get publicProfileNoBio => '暂无简介。';

  @override
  String get publicProfileResidenceLabel => '居住地';

  @override
  String get publicProfileResidenceUnknown => '未指定';

  @override
  String get publicProfileMemberSinceLabel => '加入时间';

  @override
  String get publicProfileContentSectionTitle => '公开内容';

  @override
  String get publicProfilePollsAction => 'Vote';

  @override
  String get publicProfilePostsAction => 'Voce';

  @override
  String get publicProfileBlockUserAction => '屏蔽用户';

  @override
  String get publicProfileLoadError => '无法加载个人资料。';

  @override
  String get publicProfileNotFound => '个人资料不可用。';

  @override
  String get publicProfileUnblockUserAction => '取消屏蔽用户';

  @override
  String get publicProfileBlockDialogTitle => '屏蔽此用户？';

  @override
  String get publicProfileBlockDialogMessage => '之后可以从其公开资料中取消屏蔽。';

  @override
  String get publicProfileUnblockDialogTitle => '取消屏蔽此用户？';

  @override
  String get publicProfileUnblockDialogMessage => '该用户将从你的屏蔽列表中移除。';

  @override
  String get publicProfileBlockSuccess => '用户已屏蔽。';

  @override
  String get publicProfileUnblockSuccess => '已取消屏蔽用户。';

  @override
  String get publicProfileBlockError => '无法更新屏蔽状态。请重试。';

  @override
  String get publicProfileFollowersLabel => '粉丝';

  @override
  String get publicProfileFollowingLabel => '关注';

  @override
  String get publicProfileFollowAction => '关注';

  @override
  String get publicProfileUnfollowAction => '取消关注';

  @override
  String get publicProfileFollowSuccess => '已关注账户。';

  @override
  String get publicProfileUnfollowSuccess => '已取消关注账户。';

  @override
  String get publicProfileFollowError => '无法更新关注状态。请重试。';

  @override
  String get publicProfileFollowRetry => '重新加载关注信息';

  @override
  String get contentLanguageFieldLabel => '内容语言';

  @override
  String get contentLanguageFieldHelper => '选择你撰写内容时使用的语言。';

  @override
  String get contentLanguageUndetermined => '未指定';

  @override
  String get createPollAdvancedOptionsTitle => '高级选项';

  @override
  String get createPollAdvancedOptionsSubtitle => '匿名性、结果可见性、投票更改和法定人数。';

  @override
  String get onboardingSkipButton => '跳过';

  @override
  String get onboardingNextButton => '下一步';

  @override
  String get onboardingStartButton => '开始';

  @override
  String get onboardingPollTitle => 'Vote';

  @override
  String get onboardingPollDescription => '参与你关心主题的 Vote，或创建 Vote 以收集社区意见。';

  @override
  String get onboardingHeatIceTitle => 'Heat 和 Ice';

  @override
  String get onboardingHeatIceDescription => '使用 Heat 和 Ice 表示某条内容吸引你的程度。';

  @override
  String get onboardingCivicMapTitle => 'Civic Map';

  @override
  String get onboardingCivicMapDescription => '在地图上探索 Vote、Voce 和 News，了解不同地区正在发生什么。';

  @override
  String get onboardingGeoScopeTitle => 'GeoScope';

  @override
  String get onboardingGeoScopeDescription => '选择你要关注的地理层级：世界、国家或城市。';

  @override
  String get onboardingVerificationTitle => '身份验证';

  @override
  String get onboardingVerificationDescription => '某些 Vote 可能要求特定验证级别，以保护投票完整性。';

  @override
  String get pollDetail_voteReceiptButton => '投票凭证';

  @override
  String get pollDetail_voteReceiptTitle => '投票凭证';

  @override
  String get pollDetail_voteReceiptIdLabel => '凭证 ID';

  @override
  String get pollDetail_voteReceiptDateLabel => '记录时间';

  @override
  String get pollDetail_voteReceiptPrivacy => '此凭证确认你的投票已被记录，但不会显示你选择了什么。';

  @override
  String get pollDetail_voteReceiptCloseButton => '关闭';

  @override
  String get profileBiometricUnlockTitle => '生物识别解锁';

  @override
  String get profileBiometricUnlockDescription => '使用设备指纹或生物识别保护已记住的会话。';

  @override
  String get profileBiometricRequiresRememberMe => '需要启用“记住我”。';

  @override
  String get profileBiometricUnavailable => '此设备上的生物识别不可用或尚未配置。';

  @override
  String get profileBiometricEnableReason => '请验证生物识别以启用 Social Vote 解锁。';

  @override
  String get profileBiometricEnabledMessage => '生物识别解锁已启用。';

  @override
  String get profileBiometricDisabledMessage => '生物识别解锁已关闭。';

  @override
  String get profileBiometricAuthFailedMessage => '生物识别认证未完成。';

  @override
  String get biometricLockTitle => 'Social Vote 已锁定';

  @override
  String get biometricLockMessage => '使用设备生物识别解锁已记住的会话。';

  @override
  String get biometricUnlockButton => '解锁';

  @override
  String get biometricUsePasswordButton => '使用密码';

  @override
  String get biometricUnlockReason => '解锁你的 Social Vote 会话。';

  @override
  String get biometricUnlockFailedMessage => '解锁失败。请重试或使用密码。';

  @override
  String get adminCenterOperationalActivityTitle => '运营活动';

  @override
  String get adminCenterOperationalActivitySubtitle => '汇总计数。不进行实时在线状态跟踪。';

  @override
  String get adminCenterLast24HoursLabel => '24 小时';

  @override
  String get adminCenterLast7DaysLabel => '7 天';

  @override
  String get adminCenterNewUsersMetric => '新注册';

  @override
  String get adminCenterRecentSignInsMetric => '近期登录';

  @override
  String get adminCenterPollsCreatedMetric => '创建的 Vote';

  @override
  String get adminCenterPostsCreatedMetric => '创建的 Voce';

  @override
  String get adminCenterAdminActionsMetric => 'Admin 操作';

  @override
  String get authPublicNameHelper => '这是其他用户将看到的名称。用户名会自动创建。';

  @override
  String get adminCenterRefreshMarkersTooltip => '刷新地球标记';

  @override
  String get adminCenterMarkerDensityTitle => '世界标记密度';

  @override
  String get adminCenterMarkerDensitySubtitle => '控制 Home 地球的可视标记预算，不改变真实坐标或内容排序。';

  @override
  String get adminCenterMarkerDensityEmpty => '空';

  @override
  String get adminCenterMarkerDensityFull => '全部';

  @override
  String adminCenterMarkerDensityBudget(int count) {
    return 'Home 预算：$count 个标记';
  }

  @override
  String get adminCenterMarkerDensitySaveError => '无法保存世界标记密度。';

  @override
  String get adminCenterMarkerDensityBackendUnavailable => '世界标记的后端设置暂不可用。';

  @override
  String get adminCenterQuickActionsTitle => '账户快捷操作';

  @override
  String get adminCenterModerationSnapshotTitle => '审核与活动概览';

  @override
  String get adminCenterReportsReceivedMetric => '收到的举报';

  @override
  String get adminCenterPendingReportsMetric => '待处理举报';

  @override
  String get adminCenterConfirmedViolationsMetric => '已确认违规';

  @override
  String get adminCenterReportsFiledMetric => '提交的举报';

  @override
  String get adminCenterCommentsCreatedMetric => '创建的评论';

  @override
  String get adminCenterAdminActionsOnAccountMetric => '针对账户的 Admin 操作';

  @override
  String get adminCenterLastReportReceivedLabel => '最近收到的举报';

  @override
  String get adminCenterOpenFullAccountAction => '打开完整账户控制';

  @override
  String get profileAppLanguageGerman => '德语';

  @override
  String get profileAppLanguagePersian => '波斯语';

  @override
  String get discoveryPageTitle => '探索';

  @override
  String get organizationWorkspaceTitle => '组织 Workspace';

  @override
  String get organizationPilotBannerTitle => '免费试点';

  @override
  String get organizationPilotBannerBody => '试点期间 Sessions 免费。部分专业功能未来可能收费；当前未启用计费。';

  @override
  String get organizationVerifiedLabel => '已验证组织';

  @override
  String get organizationEditProfile => '编辑组织资料';

  @override
  String get organizationCreateSession => '新建 Session';

  @override
  String get organizationNoSessions => '还没有 Sessions。为会议、工作坊或活动创建第一个 Session。';

  @override
  String get organizationSessionsTitle => 'Live Sessions';

  @override
  String get organizationRequiresVerificationTitle => '需要已验证组织';

  @override
  String get organizationRequiresVerificationBody => '此 workspace 仅对经 Social Vote 批准为已验证组织的账户开放。';

  @override
  String get organizationProfileEditorTitle => '组织资料';

  @override
  String get organizationLegalName => '法定名称';

  @override
  String get organizationPublicName => '公开名称';

  @override
  String get organizationType => '组织类型';

  @override
  String get organizationCountryCode => '国家代码';

  @override
  String get organizationCity => '城市';

  @override
  String get organizationWebsite => '官方网站';

  @override
  String get organizationDescription => '描述';

  @override
  String get organizationUploadCover => '更换封面';

  @override
  String get organizationUploadLogo => '更换标志';

  @override
  String get organizationMediaUpdated => '组织图片已更新。';

  @override
  String get organizationNamesRequired => '法定名称和公开名称为必填项。';

  @override
  String get organizationTypeAssociation => '协会';

  @override
  String get organizationTypeNonprofit => '非营利组织';

  @override
  String get organizationTypeCompany => '公司';

  @override
  String get organizationTypeCooperative => '合作社';

  @override
  String get organizationTypeSports => '体育组织';

  @override
  String get organizationTypePublicBody => '公共机构';

  @override
  String get organizationTypeCommittee => '委员会 / 团体';

  @override
  String get organizationTypeOther => '其他';

  @override
  String get sessionCreateTitle => '创建 Live Session';

  @override
  String get sessionTitleLabel => 'Session 标题';

  @override
  String get sessionExpectedParticipants => '预计参与者';

  @override
  String get sessionAccessMode => '参与者访问方式';

  @override
  String get sessionAccessOpen => '开放匿名';

  @override
  String get sessionAccessOpenHint => '任何拥有链接/代码的人都可以加入。重复参与防护采用尽力而为方式；此模式不保证“一人一票”。';

  @override
  String get sessionAccessControlled => '受控匿名';

  @override
  String get sessionAccessControlledHint => '使用一次性匿名 Access Pass。Social Vote 仅存储 Access Pass 的哈希，不会将选票选择与参与者凭证关联。';

  @override
  String get sessionResultsVisibility => '结果可见性';

  @override
  String get sessionResultsLive => '实时';

  @override
  String get sessionResultsAfterVote => '参与者投票后';

  @override
  String get sessionResultsAfterClose => '问题关闭后';

  @override
  String get sessionResultsOrganizerOnly => '仅组织者';

  @override
  String get sessionCreateAction => '创建 Session';

  @override
  String get sessionPilotLimit => '试点限制：每个 Session 1 至 250 名参与者。';

  @override
  String get sessionStatusDraft => '草稿';

  @override
  String get sessionStatusOpen => '开放';

  @override
  String get sessionStatusClosed => '已关闭';

  @override
  String get sessionJoinCode => '加入代码';

  @override
  String get sessionShareJoin => '分享加入链接';

  @override
  String get sessionCopyJoinLink => '复制链接';

  @override
  String get sessionGenerateTokens => '生成 Access Pass';

  @override
  String get sessionGenerateTokensCount => 'Access Pass 数量';

  @override
  String get sessionTokensOneTimeTitle => '立即保存这些凭证';

  @override
  String get sessionTokensOneTimeBody => '明文 Access Pass 仅在本次生成结果中显示。Social Vote 只存储其哈希。请复制并安全分发。';

  @override
  String get sessionCopyTokens => '复制所有链接';

  @override
  String get sessionTokensSavedAction => '我已保存';

  @override
  String get sessionOpenAction => '开启 Session';

  @override
  String get sessionCloseAction => '关闭 Session';

  @override
  String get sessionCloseConfirm => '关闭投票并创建不可变的 Verified Result 快照？';

  @override
  String get sessionQuestionsTitle => '问题';

  @override
  String get sessionAddQuestion => '添加问题';

  @override
  String get sessionQuestionTitle => '问题';

  @override
  String get sessionQuestionType => '问题类型';

  @override
  String get sessionTypeYesNo => '是 / 否';

  @override
  String get sessionTypeSingle => '单选';

  @override
  String get sessionTypeMultiple => '多选';

  @override
  String get sessionOptions => '选项';

  @override
  String get sessionOptionHint => '每行一个选项。';

  @override
  String get sessionMinSelections => '最少选择数';

  @override
  String get sessionMaxSelections => '最多选择数';

  @override
  String get sessionAddAction => '添加';

  @override
  String get sessionOpenQuestion => '开放问题';

  @override
  String get sessionCloseQuestion => '关闭问题';

  @override
  String get sessionNoQuestions => '还没有问题。';

  @override
  String get sessionPresenterTitle => 'Presenter';

  @override
  String get sessionParticipantTitle => 'Social Vote Live';

  @override
  String get sessionJoinAction => '加入 Session';

  @override
  String get sessionTokenLabel => '参与者令牌';

  @override
  String get sessionTokenHint => 'SV-…';

  @override
  String get sessionWaitingQuestion => '等待组织者开放问题…';

  @override
  String get sessionVoteAction => '提交投票';

  @override
  String get sessionVoteReceived => '投票已收到';

  @override
  String get sessionResultsUnavailable => '根据此 Session 的策略，结果暂不可见。';

  @override
  String get sessionPrivacyNotice => '组织者定义 Session 的运营目的和问题。Social Vote 处理提供和保护服务所必需的技术数据。匿名模式不会向组织者暴露参与者凭证与其选择之间的关联。隐私角色可能因具体场景和适用协议而异。';

  @override
  String get sessionNonBindingNotice => '试点 Sessions 用于咨询和参与。它们不是法律意义上的选举、法定会议投票或具有法律约束力的认证。';

  @override
  String get sessionOptionYes => '是';

  @override
  String get sessionOptionNo => '否';

  @override
  String get verifiedResultTitle => 'Verified Result';

  @override
  String get verifiedResultValid => '完整性检查通过';

  @override
  String get verifiedResultInvalid => '完整性检查失败';

  @override
  String get verifiedResultReportId => '报告 ID';

  @override
  String get verifiedResultHash => 'SHA-256 结果哈希';

  @override
  String get verifiedResultGeneratedBy => '由 Social Vote 生成并加盖完整性封印';

  @override
  String get verifiedResultNotLegalCertificate => '这是可验证的汇总结果报告，不是法律证书，也不是具有法律约束力选举的认证。';

  @override
  String get verifiedResultShare => '分享验证链接';

  @override
  String sessionResponses(int count) {
    return '$count 个回应';
  }

  @override
  String sessionResultVotes(int count) {
    return '$count 票';
  }

  @override
  String get organizationVerifiedIdentityLocked => '名称和国家属于组织已验证身份的一部分。更改它们需要重新验证。你可以自由更改封面、标志、类型、城市、网站和描述。';

  @override
  String get verifiedResultOpenedAt => 'Session 开启时间';

  @override
  String get verifiedResultEligibleCredentials => '合格凭证';

  @override
  String get verifiedResultIntegritySeal => 'Social Vote 完整性封印';

  @override
  String get organizationVerifiedNameLocked => '已验证名称和国家已锁定。更改它们需要重新审核验证。';

  @override
  String get sessionRetentionLabel => '原始选票保留期';

  @override
  String get sessionRetention24h => '24 小时';

  @override
  String get sessionRetention7d => '7 天';

  @override
  String get sessionRetention30d => '30 天';

  @override
  String sessionRetentionValue(String value) {
    return '原始选票保留期：$value';
  }

  @override
  String get verifiedResultPrintPdf => '下载 PDF';

  @override
  String get verifiedResultPdfError => '无法下载 PDF。请重试。';

  @override
  String get verifiedResultRestrictedTitle => '受限结果';

  @override
  String get verifiedResultRestrictedBody => '此 Verified Result 不公开。请使用已授权的组织账户登录查看。';

  @override
  String get verifiedResultPrivateVerificationTitle => '公开验证不可用';

  @override
  String get verifiedResultPrivateVerificationBody => '此结果仅限组织者查看。报告 ID、SHA-256 和完整性检查仍可在授权报告中查看。';

  @override
  String get organizationAccountSectionTitle => '你的组织';

  @override
  String get organizationManageAction => '管理';

  @override
  String get organizationViewPublicProfileAction => '查看资料';

  @override
  String get organizationOfficialWebsiteAction => '官方网站';

  @override
  String get organizationVerificationIntro => '验证同时涵盖组织是否真实存在以及你是否有权代表该组织。Social Vote 会在批准前审核所提交的信息。';

  @override
  String get organizationVerificationLegalName => '法定名称';

  @override
  String get organizationVerificationPublicName => '公开名称';

  @override
  String get organizationVerificationType => '组织类型';

  @override
  String get organizationVerificationCountry => '国家';

  @override
  String get organizationVerificationCountryRequired => '请选择组织所在国家。';

  @override
  String get organizationVerificationCity => '城市';

  @override
  String get organizationVerificationWebsite => '官方网站';

  @override
  String get organizationVerificationRepresentativeRole => '你在组织中的角色';

  @override
  String get organizationVerificationRegistryId => '登记 / 税务 / 组织标识符';

  @override
  String get organizationVerificationAuthorityNote => '我们如何验证你有权代表该组织？';

  @override
  String get organizationVerificationAuthorityHelper => '简要说明你的角色，或 Admin 在试点期间可以核实的证据。';

  @override
  String get organizationVerificationRequired => '必填项。';

  @override
  String get sessionControlRoomTitle => 'Session 控制室';

  @override
  String get sessionSectionLive => 'Live';

  @override
  String get sessionSectionQuestions => '问题';

  @override
  String get sessionSectionAccess => '访问';

  @override
  String get sessionSectionSettings => '设置';

  @override
  String get sessionStageAction => '打开 Stage';

  @override
  String get sessionAccessPassesTitle => '参与者 Access Pass';

  @override
  String get sessionAccessPassesSubtitle => '每个 pass 都可以进入此 Controlled Anonymous Session，无需参与者手动输入长凭证。Social Vote 不存储明文 pass。';

  @override
  String get sessionAccessPass => 'Access Pass';

  @override
  String get sessionAccessPassDetected => '检测到 Access Pass';

  @override
  String get sessionAccessPassAutomatic => '你的个人 pass 已准备好。继续即可匿名进入 Session。';

  @override
  String get sessionAccessPassFallback => '手动输入 pass';

  @override
  String get sessionAccessPassInvalid => '此 Access Pass 无效、已不可用，或 Session 尚未开放。';

  @override
  String get sessionAccessPassPrintWarning => '请立即打印、保存或分发这些 passes。离开此页面后，Social Vote 无法再次显示其明文内容。';

  @override
  String get sessionExistingPassesHidden => '出于安全原因，之前生成的 passes 无法再次以明文显示。请生成新的 Access Pass，以获取新的个人链接或二维码。';

  @override
  String get sessionCopyPassLinks => '复制所有链接';

  @override
  String get sessionCopyPassLink => '复制此链接';

  @override
  String get sessionControlledNeedsAccessPass => '开启受控 Session 前，请至少生成一个 Access Pass。';

  @override
  String get sessionJoinedParticipants => '已加入的访问凭证';

  @override
  String get sessionAccessesUsed => '已用于投票的访问凭证';

  @override
  String get sessionBallotsRecorded => '已记录选票';

  @override
  String get sessionQuestionsCompleted => '已完成问题';

  @override
  String get sessionCurrentQuestion => '当前问题';

  @override
  String get sessionNoOpenQuestionTitle => '没有开放的问题';

  @override
  String get sessionNoOpenQuestionBody => '参与者已连接并等待。准备好后请开放下一个问题。';

  @override
  String get sessionNotStartedTitle => 'Session 尚未开始';

  @override
  String get sessionNotStartedBody => '此 Session 已创建但尚未开放。请保持此页面打开并等待组织者开始。';

  @override
  String get sessionNoAccountRequired => '无需 Social Vote 账户';

  @override
  String get sessionReceiptDetails => '凭证详情';

  @override
  String get sessionOpenAccessInstructions => '展示或分享此二维码。Session 开放期间，任何拥有链接的人都可以进入。';

  @override
  String get sessionControlledAccessInstructions => '创建个人 Access Pass，并为每位参与者分配一个。每个 pass 中的二维码会自动包含凭证。';

  @override
  String get sessionControlRoomHint => '在一个地方管理访问、问题、投屏 Stage 和最终 Verified Result。';

  @override
  String get sessionPresenterScreenTitle => 'Live Stage';

  @override
  String get sessionStageWaiting => '等待下一个问题';

  @override
  String get sessionStageScan => '扫描加入 Session';

  @override
  String get sessionConfigurationTitle => 'Session 配置';

  @override
  String get sessionAccessRecommended => '推荐用于受控会议';

  @override
  String get sessionCreateIntroTitle => '设置会议';

  @override
  String get sessionCreateIntroBody => '选择参与者进入方式、结果何时可见以及原始选票保留多久。这些设置由后端强制执行。';

  @override
  String get verifiedCertificateNumber => '证书编号';

  @override
  String get verifiedCertificateStatus => '完整性状态';

  @override
  String get verifiedCertificateIntegrityVerified => '完整性已验证';

  @override
  String get verifiedCertificateIntegrityFailed => '完整性检查失败';

  @override
  String get verifiedCertificateOrganizationSection => '组织';

  @override
  String get verifiedCertificateSessionSection => 'Session';

  @override
  String get verifiedCertificateParticipationSection => '参与';

  @override
  String get verifiedCertificateResultsSection => '已验证结果';

  @override
  String get verifiedCertificateIntegritySection => '结果完整性';

  @override
  String get verifiedCertificateLegalName => '法定名称';

  @override
  String get verifiedCertificateOrganizationType => '组织类型';

  @override
  String get verifiedCertificateLocation => '地点';

  @override
  String get verifiedCertificateWebsite => '网站';

  @override
  String get verifiedCertificateVerification => '验证';

  @override
  String get verifiedCertificateIssuedAt => '证书签发时间';

  @override
  String get verifiedCertificateAlgorithm => '完整性算法';

  @override
  String get verifiedCertificateSchema => '报告架构';

  @override
  String get verifiedCertificateJoinedCredentials => '已加入凭证';

  @override
  String get verifiedCertificateBallotsTotal => '已记录选票';

  @override
  String get verifiedCertificateQuestionsTotal => '问题';

  @override
  String get verifiedCertificatePrivacyModel => '匿名结果模型';

  @override
  String get verifiedCertificatePrivacyText => '不可变快照仅包含汇总结果。它不包含参与者身份、明文 Access Pass、参与者密钥，也不包含参与者凭证与选票选择之间的映射。';

  @override
  String get verifiedCertificateVerifyQr => '扫描此二维码在线验证报告。';

  @override
  String get organizationDashboardTitle => '组织概览';

  @override
  String get organizationActiveSessions => 'Live Sessions';

  @override
  String get organizationVerifiedReports => '已验证报告';

  @override
  String get organizationTotalSessions => 'Sessions 总数';

  @override
  String get sessionPrivacyPolicyAction => '阅读隐私政策';

  @override
  String get radioMondoTitle => '世界电台';

  @override
  String get radioMondoDescription => '三种原创声景，用于探索 Social Vote。只有在你选择曲目后才会开始播放。';

  @override
  String get radioMondoTrackClassical => '古典轨道';

  @override
  String get radioMondoTrackRain => '世界之雨';

  @override
  String get radioMondoTrackYoung => '青春脉搏';

  @override
  String get radioMondoPlaying => '正在播放';

  @override
  String get radioMondoStopped => '世界电台已停止';

  @override
  String get radioMondoStopAction => '停止';

  @override
  String get radioMondoPlaybackError => '无法播放音频';

  @override
  String get radioMondoForegroundOnly => '当 Social Vote 被关闭、进入后台或浏览器标签页被隐藏时，播放会停止。';

  @override
  String get adminCenterEditorialNavigation => 'World Briefs';

  @override
  String get worldBriefEditorTitle => 'Social Vote World Briefs';

  @override
  String get worldBriefEditorDescription => '编写基于证据的 briefs，明确呈现不确定性，并决定哪些内容显示在 News 和地球上。';

  @override
  String get worldBriefAllStatuses => '所有状态';

  @override
  String get worldBriefCreateAction => '创建 brief';

  @override
  String get worldBriefDraftSaved => '草稿已保存';

  @override
  String get worldBriefPublished => 'Brief 已发布';

  @override
  String get worldBriefWithdrawn => 'Brief 已撤回';

  @override
  String get worldBriefSaveError => '无法保存 brief';

  @override
  String get worldBriefPublishError => '无法发布 brief';

  @override
  String get worldBriefDraftDeleted => '草稿已删除';

  @override
  String get worldBriefDeleteDraft => '删除草稿';

  @override
  String get worldBriefDeleteDraftConfirm => '永久删除此未发布草稿？';

  @override
  String get worldBriefRetry => '重试';

  @override
  String get worldBriefStatusDraft => '草稿';

  @override
  String get worldBriefStatusPublished => '已发布';

  @override
  String get worldBriefStatusWithdrawn => '已撤回';

  @override
  String get worldBriefSetupRequired => '编辑后端尚未就绪';

  @override
  String get worldBriefSetupRequiredBody => '使用此部分前，请先应用随附的 World Brief 数据库迁移。';

  @override
  String get worldBriefEmptyTitle => '还没有 World Briefs';

  @override
  String get worldBriefEmptyBody => '创建草稿，记录至少两个来源，并仅在编辑审核后发布。';

  @override
  String get worldBriefFeatured => '重点';

  @override
  String get worldBriefOnGlobe => '显示在地球上';

  @override
  String get worldBriefPriority => '优先级';

  @override
  String get worldBriefEditAction => '编辑';

  @override
  String get worldBriefPublishAction => '发布';

  @override
  String get worldBriefWithdrawAction => '撤回';

  @override
  String get worldBriefSaveDraftAction => '保存草稿';

  @override
  String get worldBriefLanguage => 'Brief 语言';

  @override
  String get worldBriefTitleField => '标题';

  @override
  String get worldBriefWhatHappened => '发生了什么';

  @override
  String get worldBriefWhyItMatters => '为什么重要';

  @override
  String get worldBriefWhatIsUncertain => '仍有哪些不确定';

  @override
  String get worldBriefSources => '来源 URL';

  @override
  String get worldBriefSourcesHint => '每行一个 HTTPS URL；至少两个独立来源。';

  @override
  String get worldBriefTwoSourcesRequired => '请至少添加两个来源。';

  @override
  String get worldBriefHttpsSourcesRequired => '每个来源都必须使用 HTTPS。';

  @override
  String get worldBriefGlobeSection => '地球位置';

  @override
  String get worldBriefGlobeRequiresPoint => '在地球上显示需要有效的纬度和经度。';

  @override
  String get worldBriefCountryCode => '国家代码';

  @override
  String get worldBriefCityId => '城市 ID';

  @override
  String get worldBriefLocationLabel => '地点标签';

  @override
  String get worldBriefLatitude => '纬度';

  @override
  String get worldBriefLongitude => '经度';

  @override
  String get worldBriefBreaking => '突发更新';

  @override
  String get worldBriefExpiry => '审核或到期窗口';

  @override
  String worldBriefExpiryDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days 天',
      one: '1 天',
    );
    return '$_temp0';
  }

  @override
  String get worldBriefRequiredField => '此字段为必填项。';

  @override
  String get worldBriefCoordinatesRequired => '请输入有效坐标。';

  @override
  String get profileHowItWorksTitle => 'Social Vote 如何运作';

  @override
  String get profileHowItWorksSubtitle => '个人、组织、Voce、Vote、Sessions 和验证。';

  @override
  String get profileMyPostsLoginRequired => '你必须登录后才能查看自己的 Voce。';

  @override
  String get profileMyPostsCreatedByYou => '你创建的 Voce';

  @override
  String get profileMyPostsEmpty => '你还没有创建任何 Voce。';

  @override
  String get profileMyPollsLoginRequired => '你必须登录后才能查看自己的 Vote。';

  @override
  String get profileMyPollsCreatedByYou => '你创建的 Vote';

  @override
  String get profileMyPollsEmpty => '你还没有创建任何 Vote。';

  @override
  String get profileMyCommentsLoginRequired => '你必须登录后才能查看自己的评论。';

  @override
  String get profileMyCommentsEmpty => '你还没有写过评论。';

  @override
  String get profileFollowedScopesLoginRequired => '你必须登录。';

  @override
  String get profileFollowedScopesEmpty => '你还没有关注任何地区。';

  @override
  String get profileFollowedScopeWorld => '世界';

  @override
  String profileFollowedScopeCountry(String code) {
    return '国家：$code';
  }

  @override
  String profileFollowedScopeCity(String city) {
    return '城市：$city';
  }

  @override
  String profileFollowedScopeArea(double radius) {
    return '地区（$radius 公里）';
  }

  @override
  String get publicProfilePollsLoadError => '无法加载公开 Vote。';

  @override
  String get publicProfilePollsEmpty => '没有公开 Vote。';

  @override
  String get publicProfilePostsLoadError => '无法加载公开 Voce。';

  @override
  String get publicProfilePostsEmpty => '没有公开 Voce。';

  @override
  String get worldBriefSocialVoteView => 'Social Vote 观点';

  @override
  String get worldBriefSocialVoteViewHint => 'Social Vote 的编辑分析或观点。请与报道事实和不确定性分开呈现。';

  @override
  String get worldBriefSocialVoteViewPublicNote => 'Social Vote 的编辑分析，与上方报道事实明确区分。';

  @override
  String get worldBriefIndependentSourcesRequired => '发布至少需要两个来自不同域名的 HTTPS 来源。';

  @override
  String get worldBriefPublishConfirmTitle => '发布前最终检查';

  @override
  String worldBriefPublishConfirmSources(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已输入 $count 个来源',
      one: '已输入 1 个来源',
    );
    return '$_temp0';
  }

  @override
  String get worldBriefEnterpriseEditorTitle => '专业编辑器';

  @override
  String get worldBriefEnterpriseEditorHelp => '按部分编写 brief。Social Vote 会自动处理地球上的技术定位：请选择国家和城市，不要输入坐标。';

  @override
  String get worldBriefEditorialContentSection => '编辑内容';

  @override
  String get worldBriefEditorialContentHelp => '将事实、重要性、不确定性和 Social Vote 观点分开。这样 brief 更易于核验和阅读。';

  @override
  String get worldBriefSourcesSection => '来源与核验';

  @override
  String get worldBriefSourcesSectionHelp => '添加可验证的 HTTPS 来源。发布至少需要两个独立域名。';

  @override
  String get worldBriefDistributionSection => '分发';

  @override
  String get worldBriefDistributionHelp => '选择 brief 显示的位置。发布后会出现在 News 中；是否显示在地球上为可选项。';

  @override
  String get worldBriefNewsDestination => '发布到 Social Vote News';

  @override
  String get worldBriefNewsDestinationHelp => 'World Brief 发布后的主要展示位置。';

  @override
  String get worldBriefGlobeAutomaticHelp => '在地球上添加标记。选择地点后，Social Vote 会自动解析位置。';

  @override
  String get worldBriefPlacementMode => '标记位置';

  @override
  String get worldBriefPlacementCity => '城市 / 地点';

  @override
  String get worldBriefPlacementCountry => '国家中心';

  @override
  String get worldBriefCountry => '国家';

  @override
  String get worldBriefCity => '城市或地点';

  @override
  String get worldBriefCityHelp => '示例：Tehran。不要输入纬度或经度。';

  @override
  String get worldBriefResolveLocation => '解析位置';

  @override
  String get worldBriefCoordinatesAutomatic => '坐标会自动处理，不应手动输入。';

  @override
  String worldBriefLocationResolved(String location) {
    return '位置已就绪：$location';
  }

  @override
  String get worldBriefChooseCountryFirst => '请先选择国家。';

  @override
  String get worldBriefChooseCityFirst => '请先输入城市或地点。';

  @override
  String get worldBriefLocationNotResolved => '无法可靠解析位置。请检查国家和城市后重试。';

  @override
  String get worldBriefVisibilitySection => '可见性与优先级';

  @override
  String get worldBriefVisibilityHelp => '在不更改报道事实的前提下，控制编辑突出程度、紧急性、排序和有效期。';

  @override
  String get worldBriefFeaturedHelp => '让 brief 在编辑展示区域中更加突出。';

  @override
  String get worldBriefBreakingHelp => '仅用于真正紧急或快速发展的事件。';

  @override
  String get worldBriefPriorityHelp => '0 = 普通/低优先级；100 = 最高编辑优先级。它不会改变内容的真实性状态。';

  @override
  String get worldBriefExpiryHelp => '超过此期限后，未经再次编辑审核，brief 不应继续保持活跃。';

  @override
  String get profileAppLanguageSpanish => '西班牙语';

  @override
  String get profileAppLanguagePortuguese => '葡萄牙语';

  @override
  String get homeHeroPurpose => '发现重要议题，分享你的 Voce，并参与 Vote。';

  @override
  String get commentSection_hideComments => '隐藏评论';

  @override
  String get commentSection_viewComments => '查看评论';

  @override
  String get commentSection_hideReplies => '隐藏回复';

  @override
  String commentSection_editing(String snippet) {
    return '正在编辑：$snippet';
  }

  @override
  String get commentSection_editInputHint => '编辑你的评论';

  @override
  String commentSection_replyTo(String author) {
    return '回复 $author';
  }

  @override
  String get commentSection_userFallback => '用户';

  @override
  String get commentSection_addError => '无法添加评论。';

  @override
  String get commentSection_nestedReplyError => '不支持超过一级的嵌套回复。';

  @override
  String get commentSection_addReplyError => '无法添加回复。';

  @override
  String get commentSection_editError => '无法编辑评论。';

  @override
  String get commentSection_deleteError => '无法删除评论。';

  @override
  String get commentSection_edited => '已编辑';

  @override
  String get commentSection_editAction => '编辑';
}
