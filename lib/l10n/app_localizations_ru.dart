// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Social Vote';

  @override
  String get voteButton => 'Голосовать';

  @override
  String get createPollPageTitle => 'Создать Vote';

  @override
  String get createPollPageSubtitle => 'Создайте новое гражданское голосование';

  @override
  String get createPollBasicInfoTitle => 'Основная информация';

  @override
  String get createPollBasicInfoSubtitle => 'Укажите основные сведения о Vote.';

  @override
  String get createPollTitleFieldLabel => 'Заголовок *';

  @override
  String get createPollTitleFieldHelper => 'Ясный и краткий вопрос или утверждение.';

  @override
  String get createPollDescriptionFieldLabel => 'Описание (необязательно)';

  @override
  String get createPollVotingModelTitle => 'Как проходит голосование';

  @override
  String get createPollVotingModelSubtitle => 'Выберите, сможет ли каждый человек выбрать один или несколько вариантов ответа.';

  @override
  String get createPollTypeFieldLabel => 'Тип Vote';

  @override
  String createPollSelectionRules(int min, int max) {
    return 'Правила выбора: минимум $min, максимум $max вариантов (автоматически корректируется в зависимости от типа Vote и вариантов ответа).';
  }

  @override
  String get createPollAllowVoteChangeTitle => 'Разрешить избирателям изменять свой голос';

  @override
  String get createPollAllowVoteChangeSubtitle => 'До закрытия Vote.';

  @override
  String get createPollOptionsTitle => 'Варианты ответа';

  @override
  String get createPollOptionsSubtitle => 'Введите как минимум два варианта ответа. Поля, отмеченные *, обязательны.';

  @override
  String createPollOptionLabel(int index, Object requiredMarker) {
    return 'Вариант $index$requiredMarker';
  }

  @override
  String get createPollRemoveOptionTooltip => 'Удалить вариант';

  @override
  String get createPollAddOptionButton => 'Добавить вариант';

  @override
  String get createPollParticipationPrivacyTitle => 'Участие и конфиденциальность';

  @override
  String get createPollParticipationPrivacySubtitle => 'Определите, кто может голосовать и насколько конфиденциальными должны быть голоса.';

  @override
  String get createPollWhoCanVoteLabel => 'Кто может голосовать?';

  @override
  String get createPollParticipationEveryoneSubtitle => 'Участвовать может любой зарегистрированный пользователь.';

  @override
  String get createPollParticipationGeoScopeSubtitle => 'Ограничить этот Vote людьми из определённой страны.';

  @override
  String get createPollCountryFieldLabel => 'Страна для этого Vote';

  @override
  String get createPollCountryFieldHelper => 'Эта страна определяет, кто сможет участвовать в этом Vote (будущая интеграция с backend).';

  @override
  String get createPollVoteAnonymityTitle => 'Анонимность голосования';

  @override
  String get createPollAnonymityAnonymousSubtitle => 'Рекомендуемый вариант по умолчанию для платформ гражданского голосования.';

  @override
  String get createPollAnonymityPublicSubtitle => 'Используйте с осторожностью: голоса могут быть связаны с личностью пользователя (будущая функция).';

  @override
  String get createPollResultsValidityTitle => 'Результаты и действительность';

  @override
  String get createPollResultsValiditySubtitle => 'Определите, когда видны результаты, и при необходимости установите минимальный кворум.';

  @override
  String get createPollResultsVisibilityFieldLabel => 'Видимость результатов';

  @override
  String get createPollQuorumTitle => 'Кворум (необязательно)';

  @override
  String get createPollQuorumSubtitle => 'Если значение задано, Vote считается действительным только при достижении как минимум этого количества голосов. Оставьте пустым, если кворум не нужен.';

  @override
  String get createPollQuorumMinVotesFieldLabel => 'Минимальное количество голосов';

  @override
  String get createPollTimingTitle => 'Сроки';

  @override
  String get createPollTimingSubtitle => 'Укажите, когда Vote должен быть открыт для голосования.';

  @override
  String get createPollStartDateLabel => 'Дата начала';

  @override
  String get createPollEndDateLabel => 'Дата окончания';

  @override
  String get createPollChangeDateButtonLabel => 'Изменить';

  @override
  String get createPollTimingStatusInfo => 'Начальный статус (открыт/запланирован/закрыт) будет определён автоматически на основе этих дат.';

  @override
  String get createPollSuccessMessage => 'Vote успешно создан';

  @override
  String get createPollSubmitCreatingLabel => 'Создание...';

  @override
  String get createPollSubmitLabel => 'Создать Vote';

  @override
  String get createPollPollTypeYesNoLabel => 'Да / Нет';

  @override
  String get createPollPollTypeSingleChoiceLabel => 'Один ответ';

  @override
  String get createPollPollTypeMultipleChoiceLabel => 'Несколько ответов';

  @override
  String get createPollPollTypeApprovalLabel => 'Одобрительное голосование';

  @override
  String get createPollPollTypeRankedLabel => 'Ранжированный выбор';

  @override
  String get createPollPollTypeScoreLabel => 'Баллы / Оценка';

  @override
  String get createPollParticipationScopeEveryoneLabel => 'Голосовать могут все';

  @override
  String get createPollParticipationScopeGeoScopeOnlyLabel => 'Только пользователи из определённой страны';

  @override
  String get createPollAnonymityLevelAnonymousLabel => 'Голоса анонимны';

  @override
  String get createPollAnonymityLevelPublicLabel => 'Голоса публичны (расширенное / ограниченное использование)';

  @override
  String get createPollResultsVisibilityAlwaysLabel => 'Всегда видны (пока Vote открыт)';

  @override
  String get createPollResultsVisibilityAfterVoteLabel => 'Видны только после голосования';

  @override
  String get createPollResultsVisibilityAfterCloseLabel => 'Видны только после закрытия Vote';

  @override
  String get homeLoginButton => 'Войти';

  @override
  String get homeRegisterButton => 'Регистрация';

  @override
  String get homeProfileButton => 'Профиль';

  @override
  String get homeLogoutButton => 'Выйти';

  @override
  String get homeLogoutMessage => 'Вы вышли из системы. Сейчас приложение используется в гостевом режиме (только чтение).';

  @override
  String get homeSearchHint => 'Искать города, страны, аккаунты и контент...';

  @override
  String get searchPageTitle => 'Поиск';

  @override
  String get searchInputHint => 'Искать аккаунты, Vote, News, Voce...';

  @override
  String get searchClearTooltip => 'Очистить поиск';

  @override
  String get searchTypeAll => 'Все';

  @override
  String get searchTypePolls => 'Vote';

  @override
  String get searchTypeNews => 'News';

  @override
  String get searchTypePosts => 'Voce';

  @override
  String get searchTypeAccounts => 'Аккаунты';

  @override
  String get searchSortHottest => 'Популярные';

  @override
  String get searchSortLatest => 'Новые';

  @override
  String get searchPollStatusAll => 'Все Vote';

  @override
  String get searchPollStatusOpen => 'Открытые';

  @override
  String get searchPollStatusClosed => 'Закрытые';

  @override
  String get searchIdleMessage => 'Введите запрос, чтобы начать поиск.';

  @override
  String get searchErrorMessage => 'Во время поиска произошла ошибка.';

  @override
  String get searchRetryButton => 'Повторить';

  @override
  String get searchEmptyMessage => 'По этому запросу ничего не найдено.';

  @override
  String get searchContentUnavailable => 'Контент недоступен';

  @override
  String get searchResultTypePoll => 'Vote';

  @override
  String get searchResultTypeNews => 'News';

  @override
  String get searchResultTypePost => 'Voce';

  @override
  String get searchResultTypeAccount => 'Аккаунт';

  @override
  String get searchResultTypeMixed => 'Смешанное';

  @override
  String homeUserStatusLoggedIn(Object userId) {
    return 'Выполнен вход как: $userId';
  }

  @override
  String get homeUserStatusGuest => 'Гостевой режим: доступно только чтение. Войдите или зарегистрируйтесь, чтобы голосовать, комментировать и реагировать.';

  @override
  String get homeScopeLabelWorld => 'Мир — глобальные голосования и новости';

  @override
  String get homeScopeLabelCountry => 'Страна — национальные голосования и новости';

  @override
  String get homeScopeLabelCity => 'Город — местные городские голосования и новости';

  @override
  String get homeScopeShortWorld => 'Мир';

  @override
  String get homeScopeShortCountry => 'Страна';

  @override
  String get homeScopeShortCity => 'Город';

  @override
  String get homeScopeChipWorld => 'Мир';

  @override
  String get homeScopeChipItaly => 'Италия';

  @override
  String get homeScopeChipTorino => 'Турин';

  @override
  String get homeScopeChangedWorld => 'Область изменена на Мир';

  @override
  String get homeScopeChangedItaly => 'Область изменена на Италию';

  @override
  String get homeScopeChangedTorino => 'Область изменена на Турин';

  @override
  String get followScopeButtonFollowed => 'Отслеживается';

  @override
  String get followScopeButtonFollow => 'Следить за этой областью';

  @override
  String get homeTrendingTitle => 'Pulse Now';

  @override
  String get homeTrendingError => 'Не удалось загрузить Pulse Now для этой области.';

  @override
  String get homeTrendingEmpty => 'Сейчас в Pulse Now для этой области нет контента.';

  @override
  String homeForYouTitle(Object scope) {
    return 'Pulse ($scope)';
  }

  @override
  String get homeForYouError => 'Не удалось загрузить Pulse для этой области.';

  @override
  String get homeForYouEmpty => 'Сейчас для этой области нет рекомендуемого контента в Pulse.';

  @override
  String homePollsTitle(Object scope) {
    return 'Vote в центре внимания ($scope)';
  }

  @override
  String get homePollsEmptyTitle => 'Для этой области нет Vote';

  @override
  String get homePollsEmptySubtitle => 'Для этой области сейчас нет доступных Vote.';

  @override
  String get homePollsViewAllButton => 'Смотреть Vote';

  @override
  String homeNewsTitle(Object scope) {
    return 'Главные News ($scope)';
  }

  @override
  String get homeNewsErrorTitle => 'Не удалось загрузить новости';

  @override
  String get homeNewsErrorSubtitle => 'При загрузке новостей для этой области возникла проблема.';

  @override
  String get homeNewsEmptyTitle => 'Для этой области нет новостей';

  @override
  String get homeNewsEmptySubtitle => 'Для этой области сейчас нет новостей.';

  @override
  String get homeNewsViewAllButton => 'Смотреть все новости';

  @override
  String get homeNewsBreakingBadge => 'СРОЧНО';

  @override
  String homeSocialTitle(Object scope) {
    return 'Voce ($scope)';
  }

  @override
  String get homeSocialErrorTitle => 'Не удалось загрузить Voce';

  @override
  String get homeSocialErrorSubtitle => 'При загрузке Voce для этой области возникла проблема.';

  @override
  String get homeSocialEmptyTitle => 'Для этой области нет Voce';

  @override
  String get homeSocialEmptySubtitle => 'Для этой области сейчас нет контента Voce.';

  @override
  String get homeSocialViewFeedButton => 'Смотреть все Voce';

  @override
  String get pollDetail_title => 'Подробности Vote';

  @override
  String get pollDetail_removeFromFavoritesTooltip => 'Удалить из сохранённых';

  @override
  String get pollDetail_addToFavoritesTooltip => 'Сохранить';

  @override
  String get pollDetail_chipAnonymous => 'Анонимное голосование';

  @override
  String get pollDetail_chipPublic => 'Публичное голосование';

  @override
  String get pollDetail_chipRestrictedGeo => 'Ограничено географической областью';

  @override
  String pollDetail_quorumReached(int currentVotes, int requiredVotes) {
    return 'Кворум достигнут ($currentVotes / $requiredVotes)';
  }

  @override
  String pollDetail_quorumNotReached(int currentVotes, int requiredVotes) {
    return 'Кворум не достигнут ($currentVotes / $requiredVotes)';
  }

  @override
  String get pollDetail_optionsTitle => 'Варианты';

  @override
  String get pollDetail_statusClosedMessage => 'Этот Vote закрыт.';

  @override
  String get pollDetail_statusScheduledMessage => 'Этот Vote ещё не открыт.';

  @override
  String get pollDetail_statusNotAvailableMessage => 'Голосование недоступно.';

  @override
  String get pollDetail_voteSubmitted => 'Голос успешно отправлен!';

  @override
  String get pollDetail_voteButton => 'Голосовать';

  @override
  String get pollDetail_resultsTitle => 'Результаты';

  @override
  String pollDetail_outcomePrefix(Object label) {
    return 'Итог: $label';
  }

  @override
  String get pollDetail_noResults => 'Результатов пока нет.';

  @override
  String get pollDetail_resultsAfterVote => 'Результаты будут видны после того, как вы проголосуете.';

  @override
  String get pollDetail_resultsWhenClosed => 'Результаты будут видны после закрытия Vote.';

  @override
  String get pollType_yesNo => 'Да / Нет';

  @override
  String get pollType_singleChoice => 'Один вариант';

  @override
  String get pollType_multipleChoice => 'Несколько вариантов';

  @override
  String get pollType_approval => 'Одобрение';

  @override
  String get pollStatus_draft => 'Черновик';

  @override
  String get pollStatus_open => 'Открыт';

  @override
  String get pollStatus_closed => 'Закрыт';

  @override
  String get pollStatus_scheduled => 'Запланирован';

  @override
  String get pollGeo_global => 'Глобальный';

  @override
  String get pollGeo_local => 'Локальный';

  @override
  String get pollOutcome_approved => 'Одобрено';

  @override
  String get pollOutcome_rejected => 'Отклонено';

  @override
  String get pollOutcome_tie => 'Ничья';

  @override
  String get pollOutcome_noMajority => 'Нет большинства';

  @override
  String get pollOutcome_notApplicable => 'Не применимо';

  @override
  String get pollList_title => 'Vote';

  @override
  String get pollList_scopeWorld => 'Мир';

  @override
  String get pollList_scopeCountryFallback => 'Страна';

  @override
  String get pollList_scopeCityFallback => 'Город';

  @override
  String get pollList_scopeDescriptionGlobal => 'Показаны глобальные Vote.';

  @override
  String get pollList_scopeDescriptionCountry => 'Показаны Vote для этой страны.';

  @override
  String get pollList_scopeDescriptionCity => 'Показаны Vote для этого города.';

  @override
  String get pollList_filterStatus_all => 'Все';

  @override
  String get pollList_filterStatus_open => 'Открытые';

  @override
  String get pollList_filterStatus_closed => 'Закрытые';

  @override
  String get pollList_sort_latest => 'Новые';

  @override
  String get pollList_sort_hottest => 'Популярные';

  @override
  String get pollList_filterScope_currentArea => 'Текущая область';

  @override
  String pollList_headerTitle(Object scopeLabel, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Найдено Vote: $count',
      one: 'Найден 1 Vote',
      zero: 'Vote не найдены',
    );
    return '$scopeLabel · $_temp0';
  }

  @override
  String get pollList_createPollButton => 'Создать Vote';

  @override
  String get pollList_paginationHint => 'Прокрутите, чтобы загрузить больше Vote…';

  @override
  String get pollList_emptyMessage => 'Для этой области нет Vote, соответствующих фильтру.';

  @override
  String get pollType_ranked => 'Ранжированный выбор';

  @override
  String get pollType_score => 'Оценочное голосование';

  @override
  String get pollVisibility_whileOpen => 'Результаты видны, пока Vote открыт';

  @override
  String get pollVisibility_afterVote => 'Результаты видны после голосования';

  @override
  String get pollVisibility_afterClose => 'Результаты видны после закрытия';

  @override
  String get pollCard_countryRestricted => 'Ограничение по стране';

  @override
  String pollCard_restrictedToCountry(Object countryName) {
    return 'Только для $countryName';
  }

  @override
  String pollCard_quorumLabel(int minVotes) {
    return 'Кворум $minVotes';
  }

  @override
  String get pollCard_resultsVisibleChip => 'Результаты видны';

  @override
  String get pollCard_resultsAfterVoteChip => 'После голосования';

  @override
  String get pollCard_resultsAfterCloseChip => 'После закрытия';

  @override
  String get pollCard_publicOfficialPublisher => 'Публичное должностное лицо';

  @override
  String get pollCard_institutionPublisher => 'Учреждение';

  @override
  String get pollCard_representativePublisher => 'Представитель';

  @override
  String pollCard_voteCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'голосов',
      one: 'голос',
    );
    return '$_temp0';
  }

  @override
  String get pollCard_viewDetails => 'Подробнее';

  @override
  String pollResult_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Результаты ($count голосов)',
      one: 'Результаты (1 голос)',
      zero: 'Результаты (голосов нет)',
    );
    return '$_temp0';
  }

  @override
  String get voteError_noSelection => 'Выберите хотя бы один вариант.';

  @override
  String get voteError_unauthorized => 'У вас нет права голосовать в этом Vote.';

  @override
  String get voteError_generic => 'Не удалось отправить голос. Попробуйте ещё раз.';

  @override
  String get commentSection_title => 'Комментарии';

  @override
  String get commentSection_sortLabel => 'Сортировка:';

  @override
  String get commentSection_sortOldest => 'Сначала старые';

  @override
  String get commentSection_sortNewest => 'Сначала новые';

  @override
  String get commentSection_errorGeneric => 'При загрузке комментариев произошла ошибка.';

  @override
  String get commentSection_empty => 'Комментариев пока нет. Оставьте первый комментарий.';

  @override
  String get commentSection_loadMore => 'Загрузить ещё комментарии';

  @override
  String commentSection_replyingTo(Object snippet) {
    return 'Ответ на: $snippet';
  }

  @override
  String get commentSection_cancelReply => 'Отмена';

  @override
  String get commentSection_inputHintRoot => 'Добавить комментарий...';

  @override
  String get commentSection_inputHintReply => 'Написать ответ...';

  @override
  String get commentSection_deleteAction => 'Удалить';

  @override
  String get commentSection_replyAction => 'Ответить';

  @override
  String get commentSection_youBadge => 'Вы';

  @override
  String get newsDetail_title => 'Подробности News';

  @override
  String get newsDetail_breakingBadge => 'СРОЧНО';

  @override
  String get newsDetail_removeFromFavoritesTooltip => 'Удалить из сохранённых';

  @override
  String get newsDetail_addToFavoritesTooltip => 'Сохранить';

  @override
  String get newsDetail_bodyFallback => 'Для этой новости нет дополнительного текста.';

  @override
  String get newsDetail_footerMoreContext => 'Дополнительный контекст и источники появятся позже.';

  @override
  String get newsFeed_title => 'News';

  @override
  String get newsFeed_scopeWorld => 'Мир';

  @override
  String get newsFeed_scopeCountry => 'Страна';

  @override
  String get newsFeed_scopeCity => 'Город';

  @override
  String newsFeed_scopeLabel(Object scope) {
    return 'Область: $scope';
  }

  @override
  String get newsFeed_scopeGlobalDescription => 'Показаны глобальные новости.';

  @override
  String get newsFeed_scopeCountryDescription => 'Показаны новости для этой страны.';

  @override
  String get newsFeed_scopeCityDescription => 'Показаны новости для этого города.';

  @override
  String get newsFeed_emptyTitle => 'Для этой области нет доступных новостей.';

  @override
  String get newsFeed_emptySubtitle => 'Потяните для обновления или попробуйте позже.';

  @override
  String newsFeed_itemsFound(int count) {
    return 'Найдено новостей: $count';
  }

  @override
  String get newsFeed_loadingMoreHint => 'Прокрутите, чтобы загрузить больше новостей…';

  @override
  String get newsFeed_errorTitle => 'Не удалось загрузить новости';

  @override
  String get newsFeed_errorGeneric => 'При загрузке новостей произошла непредвиденная ошибка.';

  @override
  String get newsFeed_retryButton => 'Повторить';

  @override
  String get newsCard_headerTitle => 'News';

  @override
  String get newsFeed_errorUnauthorized => 'Конфигурация News недействительна (API-ключ).';

  @override
  String get newsFeed_errorRateLimited => 'Слишком много запросов. Попробуйте снова через некоторое время.';

  @override
  String get newsFeed_errorServerUnavailable => 'Сервис News временно недоступен. Попробуйте позже.';

  @override
  String get newsFeed_errorTimeout => 'Запрос выполняется слишком долго. Попробуйте ещё раз.';

  @override
  String get newsFeed_errorNetwork => 'Нет соединения. Проверьте интернет и попробуйте снова.';

  @override
  String get newsFeed_moreTooltip => 'Ещё';

  @override
  String get newsFeed_actionCopyTitle => 'Копировать заголовок';

  @override
  String get newsFeed_actionRefreshFeed => 'Обновить ленту';

  @override
  String get newsFeed_copiedTitleToast => 'Заголовок скопирован';

  @override
  String get newsFeed_languageTooltip => 'Язык News';

  @override
  String get newsFeed_languageAuto => 'АВТО';

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
  String get newsFeed_languageLimitedHint => 'Ограниченное количество источников на этом языке. Попробуйте AUTO.';

  @override
  String get newsTopic_all => 'Все';

  @override
  String get newsTopic_world => 'Мир';

  @override
  String get newsTopic_nation => 'Страна';

  @override
  String get newsTopic_business => 'Бизнес';

  @override
  String get newsTopic_technology => 'Технологии';

  @override
  String get newsTopic_science => 'Наука';

  @override
  String get newsTopic_health => 'Здоровье';

  @override
  String get newsTopic_sports => 'Спорт';

  @override
  String get newsTopic_entertainment => 'Развлечения';

  @override
  String get newsDetail_openSource => 'Открыть статью-источник';

  @override
  String get newsDetail_openSourceUnavailable => 'Не удалось открыть статью-источник';

  @override
  String get socialFeedTitle => 'Voce';

  @override
  String get socialFeedCreatePostButton => 'Создать Voce';

  @override
  String get commonCancelButton => 'Отмена';

  @override
  String get commonApplyButton => 'Применить';

  @override
  String get homeScopeChooseCountry => 'Выберите страну';

  @override
  String get homeScopeCountrySearchHint => 'Искать страну или код...';

  @override
  String get homeScopeChooseCity => 'Выберите город';

  @override
  String homeScopeCountryWithCode(String code) {
    return 'Страна: $code';
  }

  @override
  String get homeScopeCityFieldLabel => 'Город';

  @override
  String get homeScopeCityExampleHint => 'Введите город, например Merano';

  @override
  String get homeScopeCityRequiredError => 'Введите город.';

  @override
  String get homeScopeCityNotFoundError => 'Город не найден в выбранной стране.';

  @override
  String get homeScopeCityVerificationError => 'Не удалось проверить город. Попробуйте ещё раз.';

  @override
  String get homeScopeVerifyingButton => 'Проверка...';

  @override
  String get homeMapOpenButton => 'Открыть карту';

  @override
  String get homeHeroHeadline => 'Формируйте будущее.\\nВместе.';

  @override
  String get homeHeroPollsAction => 'Vote';

  @override
  String get homeHeroNewsAction => 'News';

  @override
  String get homeHeroCreateAction => 'Создать';

  @override
  String get homeHeroExploreAction => 'Исследовать';

  @override
  String get homeAccountMenuLabel => 'Аккаунт';

  @override
  String get homeThemeSystemMenuItem => 'Тема: системная';

  @override
  String get homeThemeLightMenuItem => 'Тема: светлая';

  @override
  String get homeThemeDarkMenuItem => 'Тема: тёмная';

  @override
  String get profileAppLanguageTitle => 'Язык приложения';

  @override
  String get profileAppLanguageSystem => 'Система';

  @override
  String get profileAppLanguageSystemDescription => 'Использовать язык устройства';

  @override
  String get profileAppLanguageItalian => 'Итальянский';

  @override
  String get profileAppLanguageEnglish => 'Английский';

  @override
  String get homeNotificationsTooltip => 'Уведомления';

  @override
  String get postCard_authorFallback => 'Автор';

  @override
  String get postCard_globalLocation => 'Глобально';

  @override
  String get commonSaveButton => 'Сохранить';

  @override
  String get commonDeleteButton => 'Удалить';

  @override
  String get contentReport_menuAction => 'Пожаловаться на контент';

  @override
  String get contentReport_dialogTitle => 'Пожаловаться на контент';

  @override
  String get contentReport_authenticationRequired => 'Чтобы пожаловаться на контент, необходимо войти в систему';

  @override
  String get contentReport_submittedMessage => 'Жалоба отправлена';

  @override
  String get contentReport_alreadySubmittedMessage => 'Вы уже пожаловались на этот контент';

  @override
  String get contentReport_submitError => 'Не удалось отправить жалобу';

  @override
  String get contentReport_sendButton => 'Отправить';

  @override
  String get contentReport_reasonSpam => 'Спам';

  @override
  String get contentReport_reasonHarassment => 'Домогательства или оскорбления';

  @override
  String get contentReport_reasonHateSpeech => 'Разжигание ненависти';

  @override
  String get contentReport_reasonMisinformation => 'Дезинформация';

  @override
  String get contentReport_reasonViolence => 'Насилие';

  @override
  String get contentReport_reasonOther => 'Другое';

  @override
  String get postDetail_title => 'Подробности Voce';

  @override
  String get postDetail_favoriteUpdateError => 'Не удалось обновить сохранённое';

  @override
  String get postDetail_shareMessage => 'Откройте Social Vote, чтобы посмотреть эту Voce.';

  @override
  String get postDetail_shareError => 'Не удалось поделиться Voce';

  @override
  String get postDetail_editDialogTitle => 'Редактировать Voce';

  @override
  String get postDetail_editTitleFieldLabel => 'Заголовок';

  @override
  String get postDetail_editContentFieldLabel => 'Содержание';

  @override
  String get postDetail_editRequiredError => 'Заголовок и содержание обязательны.';

  @override
  String get postDetail_updateSuccess => 'Voce обновлена';

  @override
  String get postDetail_updateError => 'Не удалось обновить Voce';

  @override
  String get postDetail_deleteDialogTitle => 'Удалить эту Voce?';

  @override
  String get postDetail_deleteDialogMessage => 'Это действие нельзя отменить.';

  @override
  String get postDetail_deleteError => 'Не удалось удалить Voce';

  @override
  String get postDetail_editMenuItem => 'Редактировать Voce';

  @override
  String get postDetail_deleteMenuItem => 'Удалить Voce';

  @override
  String get postDetail_loadError => 'При загрузке Voce произошла ошибка.';

  @override
  String get postDetail_notFound => 'Voce не найдена.';

  @override
  String get postDetail_errorTitle => 'Ошибка';

  @override
  String get postDetail_authorFallback => 'Автор';

  @override
  String get postDetail_shareAction => 'Поделиться';

  @override
  String get postDetail_saveAction => 'Сохранить';

  @override
  String get postDetail_addToFavoritesTooltip => 'Сохранить';

  @override
  String get postDetail_removeFromFavoritesTooltip => 'Удалить из сохранённых';

  @override
  String get newsDetail_favoriteUpdateError => 'Не удалось обновить сохранённое';

  @override
  String get newsDetail_shareMessage => 'Откройте Social Vote, чтобы посмотреть эту новость.';

  @override
  String get newsDetail_shareError => 'Не удалось поделиться новостью';

  @override
  String get newsDetail_shareTooltip => 'Поделиться';

  @override
  String get authLoginPageTitle => 'Войти';

  @override
  String get authLoginHeadline => 'С возвращением';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Пароль';

  @override
  String get authRememberMeLabel => 'Запомнить меня';

  @override
  String get authForgotPasswordAction => 'Забыли пароль?';

  @override
  String get authLoginButton => 'Войти';

  @override
  String get authRegisterPrompt => 'Нет аккаунта?';

  @override
  String get authRegisterAction => 'Зарегистрироваться';

  @override
  String get authRegisterPageTitle => 'Регистрация';

  @override
  String get authRegisterHeadline => 'Создать аккаунт';

  @override
  String get authPersonalAccountOwnershipTitle => 'Вход всегда принадлежит человеку';

  @override
  String get authPersonalAccountOwnershipBody => 'Если вы представляете организацию, создайте личный аккаунт. После входа вы сможете запросить Verified Organization и управлять ею из Workspace.';

  @override
  String get authOrganizationPathAction => 'Как это работает для организаций';

  @override
  String get authDisplayNameLabel => 'Публичное имя';

  @override
  String get authUsernameLabel => 'Имя пользователя';

  @override
  String get authCountryOfResidenceLabel => 'Страна проживания';

  @override
  String get authCityOfResidenceLabel => 'Город проживания (необязательно)';

  @override
  String get authConfirmPasswordLabel => 'Подтвердите пароль';

  @override
  String get authLegalConsentPrefix => 'Я подтверждаю, что мне не менее 18 лет. Я принимаю Условия использования и подтверждаю, что прочитал(а) Политику конфиденциальности.';

  @override
  String get authTermsOfServiceAction => 'Условия использования';

  @override
  String get authPrivacyPolicyAction => 'Политику конфиденциальности';

  @override
  String get authRegisterButton => 'Зарегистрироваться';

  @override
  String get authLoginPrompt => 'Уже есть аккаунт?';

  @override
  String get authLoginAction => 'Войти';

  @override
  String get authForgotPasswordDialogTitle => 'Сброс пароля';

  @override
  String get authForgotPasswordDialogBody => 'Введите адрес email, связанный с вашим аккаунтом. Мы отправим ссылку для выбора нового пароля.';

  @override
  String get authForgotPasswordSendButton => 'Отправить ссылку';

  @override
  String get authPasswordResetEmailSent => 'Письмо для сброса пароля отправлено. Проверьте входящие.';

  @override
  String get authResetPasswordPageTitle => 'Сброс пароля';

  @override
  String get authResetPasswordHeadline => 'Выберите новый пароль';

  @override
  String get authNewPasswordLabel => 'Новый пароль';

  @override
  String get authConfirmNewPasswordLabel => 'Подтвердите новый пароль';

  @override
  String get authUpdatePasswordButton => 'Обновить пароль';

  @override
  String get authPasswordUpdated => 'Пароль успешно обновлён.';

  @override
  String get authEmailConfirmationTitle => 'Проверьте email';

  @override
  String get authEmailConfirmationIntro => 'Мы отправили ссылку подтверждения на:';

  @override
  String get authEmailConfirmationInstructions => 'Откройте ссылку в письме, чтобы подтвердить адрес. После подтверждения вернитесь в приложение и войдите.';

  @override
  String get authBackToLoginButton => 'Вернуться ко входу';

  @override
  String get authUseAnotherEmailButton => 'Использовать другой email';

  @override
  String get authEmailRequiredError => 'Введите email.';

  @override
  String get authEmailInvalidError => 'Введите корректный email.';

  @override
  String get authPasswordRequiredError => 'Введите пароль.';

  @override
  String get authPasswordTooShortError => 'Пароль должен содержать не менее 8 символов.';

  @override
  String get authDisplayNameRequiredError => 'Введите публичное имя.';

  @override
  String get authDisplayNameTooShortError => 'Публичное имя слишком короткое.';

  @override
  String get authUsernameRequiredError => 'Введите имя пользователя.';

  @override
  String get authUsernameInvalidError => 'Используйте от 3 до 20 символов: строчные буквы, цифры и символ подчёркивания.';

  @override
  String get authUsernameAlreadyTakenError => 'Это имя пользователя уже занято.';

  @override
  String get authCountryRequiredError => 'Выберите страну проживания.';

  @override
  String get authCityRequiredError => 'Введите город проживания.';

  @override
  String get authConfirmPasswordRequiredError => 'Подтвердите пароль.';

  @override
  String get authPasswordsDoNotMatchError => 'Пароли не совпадают.';

  @override
  String get authLegalConsentRequiredError => 'Для регистрации подтвердите, что вам не менее 18 лет, примите Условия использования и подтвердите, что прочитали Политику конфиденциальности.';

  @override
  String get authForgotPasswordEmailRequiredError => 'Введите email аккаунта, который хотите восстановить.';

  @override
  String get authInvalidCredentialsError => 'Неверный email или пароль.';

  @override
  String get authEmailAlreadyRegisteredError => 'Этот email уже зарегистрирован.';

  @override
  String get authEmailNotConfirmedError => 'Email не подтверждён. Перед входом проверьте входящие.';

  @override
  String get authTooManyAttemptsError => 'Слишком много попыток. Подождите несколько минут и повторите.';

  @override
  String get authNetworkError => 'Ошибка сети. Проверьте соединение и повторите.';

  @override
  String get authLoginGenericError => 'Не удалось войти. Попробуйте ещё раз.';

  @override
  String get authRegisterGenericError => 'Не удалось зарегистрироваться. Попробуйте ещё раз.';

  @override
  String get authPasswordResetGenericError => 'Не удалось отправить ссылку для сброса. Попробуйте ещё раз.';

  @override
  String get authPasswordUpdateGenericError => 'Не удалось обновить пароль. Попробуйте ещё раз.';

  @override
  String get authShowPasswordTooltip => 'Показать пароль';

  @override
  String get authHidePasswordTooltip => 'Скрыть пароль';

  @override
  String get authTermsPageTitle => 'Условия использования';

  @override
  String get authPrivacyPageTitle => 'Политика конфиденциальности';

  @override
  String get authCloseButton => 'Закрыть';

  @override
  String get pollDetail_favoriteUpdateError => 'Не удалось обновить сохранённое';

  @override
  String get pollDetail_shareMessage => 'Откройте Social Vote, чтобы посмотреть и проголосовать в этом Vote.';

  @override
  String get pollDetail_shareError => 'Не удалось поделиться Vote';

  @override
  String get pollDetail_editPermissionError => 'Вы можете редактировать только собственные Vote, в которых ещё нет голосов';

  @override
  String get pollDetail_editSuccessMessage => 'Vote обновлён';

  @override
  String get pollDetail_editMenuItem => 'Редактировать Vote';

  @override
  String get pollDetail_editSavingMenuItem => 'Сохранение...';

  @override
  String get pollDetail_deletePermissionError => 'Вы можете удалять только собственные Vote';

  @override
  String get pollDetail_deleteError => 'Не удалось удалить Vote';

  @override
  String get pollDetail_deleteDialogTitle => 'Удалить Vote';

  @override
  String pollDetail_deleteDialogMessage(String title) {
    return 'Вы действительно хотите удалить «$title»? Это действие нельзя отменить.';
  }

  @override
  String get pollDetail_deleteMenuItem => 'Удалить Vote';

  @override
  String get pollDetail_deleteDeletingMenuItem => 'Удаление...';

  @override
  String get pollDetail_publicVotesAvailableTitle => 'Доступны публичные голоса';

  @override
  String get pollDetail_publicVotesAvailableMessage => 'В этом Vote можно посмотреть, кто проголосовал за каждый вариант.';

  @override
  String get pollDetail_publicVotesAction => 'Посмотреть публичные голоса';

  @override
  String get pollDetail_retryButton => 'Повторить';

  @override
  String get pollDetail_voteErrorNoOption => 'Выберите хотя бы один вариант';

  @override
  String get pollDetail_voteErrorAuthenticationRequired => 'Чтобы голосовать, необходимо войти в систему';

  @override
  String get pollDetail_voteErrorClosed => 'Этот Vote закрыт';

  @override
  String get pollDetail_voteErrorAlreadyVoted => 'Вы уже голосовали в этом Vote';

  @override
  String get pollDetail_voteErrorGeneric => 'Не удалось отправить голос';

  @override
  String get pollDetail_publicVotesSheetTitle => 'Публичные голоса';

  @override
  String get pollDetail_publicVotesSheetDescription => 'Здесь можно посмотреть, кто проголосовал за каждый вариант в этом Vote.';

  @override
  String get pollDetail_publicVotesSearchHint => 'Искать пользователей';

  @override
  String get pollDetail_publicVotesLoadError => 'Не удалось загрузить публичные голоса';

  @override
  String get pollDetail_publicVotesEmpty => 'Публичных голосов нет';

  @override
  String get pollDetail_publicVotesSearchEmpty => 'По этому запросу пользователи не найдены';

  @override
  String pollDetail_publicVotesResultsCount(int count) {
    return 'Загружено результатов: $count';
  }

  @override
  String get pollDetail_publicVotesLoadMore => 'Загрузить ещё';

  @override
  String get pollDetail_publicVotesUserFallback => 'Пользователь';

  @override
  String get pollDetail_editDialogTitle => 'Редактировать Vote';

  @override
  String get pollDetail_editTitleFieldLabel => 'Заголовок';

  @override
  String get pollDetail_editTitleRequired => 'Заголовок обязателен';

  @override
  String get pollDetail_editDescriptionFieldLabel => 'Описание';

  @override
  String get pollDetail_editError => 'Не удалось обновить Vote';

  @override
  String get pollDetail_loadError => 'Не удалось загрузить Vote';

  @override
  String get pollDetail_notFound => 'Vote не найден';

  @override
  String get profileEditPageTitle => 'Редактировать профиль';

  @override
  String get profileLoginRequiredMessage => 'Чтобы редактировать профиль, необходимо войти в систему.';

  @override
  String get profileAvatarUploading => 'Загрузка...';

  @override
  String get profileUploadAvatarButton => 'Загрузить аватар';

  @override
  String get profileDisplayNameLabel => 'Отображаемое имя';

  @override
  String get profileDisplayNameRequiredError => 'Отображаемое имя обязательно.';

  @override
  String get profileUsernameHint => 'например mario_roma';

  @override
  String get profileUsernameHelper => '3–20 символов: строчные буквы, цифры и символ подчёркивания';

  @override
  String get profileAvatarUrlLabel => 'URL аватара';

  @override
  String get profileBioLabel => 'О себе';

  @override
  String get profileClearCountryButton => 'Очистить страну';

  @override
  String get profileCityResidenceHelper => 'Перед сохранением город проживания проверяется на соответствие выбранной стране.';

  @override
  String get profileCityNotFoundError => 'Город не найден в выбранной стране.';

  @override
  String get profileCityVerificationError => 'Сейчас не удалось проверить город.';

  @override
  String get profileAvatarUploadError => 'Не удалось загрузить аватар.';

  @override
  String get profileAccountSectionTitle => 'Аккаунт';

  @override
  String get profileAccountEmailHelper => 'Адрес email аккаунта нельзя изменить на этом экране.';

  @override
  String get profileChangePasswordAction => 'Изменить пароль';

  @override
  String get profileChangePasswordDescription => 'Установить новый пароль для этого аккаунта.';

  @override
  String get notificationsPageTitle => 'Уведомления';

  @override
  String get notificationsMarkAllReadAction => 'Отметить всё как прочитанное';

  @override
  String get notificationsNoTargetMessage => 'У этого уведомления нет доступного места назначения.';

  @override
  String get notificationsTargetUnavailableMessage => 'Контент, связанный с этим уведомлением, недоступен.';

  @override
  String get notificationsLoadError => 'Не удалось загрузить уведомления.';

  @override
  String get notificationsRetryButton => 'Повторить';

  @override
  String get notificationsEmptyMessage => 'Уведомлений нет.';

  @override
  String get notificationsCommentReplyTitle => 'Новый ответ на ваш комментарий';

  @override
  String get notificationsMentionTitle => 'Вас упомянули';

  @override
  String get notificationsPollResultTitle => 'Обновление Vote';

  @override
  String notificationsCommentReplySubtitle(String actor, String target) {
    return 'Пользователь $actor ответил в $target';
  }

  @override
  String notificationsMentionSubtitle(String actor, String target) {
    return 'Пользователь $actor упомянул вас в $target';
  }

  @override
  String notificationsPollResultSubtitle(String target) {
    return 'В $target доступен новый результат';
  }

  @override
  String get notificationsTargetPost => 'Voce';

  @override
  String get notificationsTargetNews => 'новости';

  @override
  String get notificationsTargetPoll => 'Vote';

  @override
  String get notificationsTargetVideo => 'видео';

  @override
  String get notificationsTargetContent => 'контенте';

  @override
  String get notificationsUserFallback => 'пользователь';

  @override
  String get profileDeleteAccountAction => 'Удалить аккаунт';

  @override
  String get profileDeleteAccountDescription => 'Навсегда удалить аккаунт и доступ';

  @override
  String get profileDeleteAccountDialogTitle => 'Удалить аккаунт';

  @override
  String get profileDeleteAccountDialogMessage => 'Это действие необратимо. Аккаунт нельзя восстановить. Введите DELETE для подтверждения.';

  @override
  String get profileDeleteAccountConfirmationLabel => 'Подтверждение удаления';

  @override
  String get profileDeleteAccountConfirmationHint => 'Введите DELETE';

  @override
  String get profileDeleteAccountConfirmationError => 'Введите DELETE, чтобы продолжить.';

  @override
  String get profileDeleteAccountCancelButton => 'Отмена';

  @override
  String get profileDeleteAccountConfirmButton => 'Удалить навсегда';

  @override
  String get profileDeleteAccountFailureMessage => 'Не удалось удалить аккаунт. Попробуйте ещё раз.';

  @override
  String get identityActorTypePerson => 'Человек';

  @override
  String get identityActorTypePublicOfficial => 'Публичное должностное лицо';

  @override
  String get identityActorTypePublicInstitution => 'Государственное учреждение';

  @override
  String get identityActorTypeVerifiedOrganization => 'Проверенная организация';

  @override
  String get identityVerificationNotVerified => 'Не проверено';

  @override
  String get identityVerificationLevel1 => 'Подтверждённая личность';

  @override
  String get identityVerificationLevel2 => 'Расширенная подтверждённая личность';

  @override
  String get identityBadgeLevel1 => 'Подтверждённая личность';

  @override
  String get identityBadgeLevel2 => 'Расширенная подтверждённая личность';

  @override
  String get identityBadgePublicOfficial => 'Публичное должностное лицо';

  @override
  String get identityBadgePublicInstitution => 'Государственное учреждение';

  @override
  String get identityBadgeVerifiedOrganization => 'Проверенная организация';

  @override
  String get identityOrganizationNameLabel => 'Название организации';

  @override
  String get identityOrganizationNameRequired => 'Введите название организации.';

  @override
  String get identityInstitutionLevelMunicipality => 'Муниципальный';

  @override
  String get identityInstitutionLevelProvince => 'Провинциальный';

  @override
  String get identityInstitutionLevelRegion => 'Региональный';

  @override
  String get identityInstitutionLevelMinistry => 'Министерство';

  @override
  String get identityInstitutionLevelGovernment => 'Правительство';

  @override
  String get identityInstitutionLevelPublicAgency => 'Государственное агентство';

  @override
  String get identityInstitutionLevelOtherPublicBody => 'Другой государственный орган';

  @override
  String get verificationRequestPersonLevel1 => 'Проверка личности — Уровень 1';

  @override
  String get verificationRequestPersonLevel2 => 'Проверка личности — Уровень 2';

  @override
  String get verificationRequestPublicOfficial => 'Проверка публичного должностного лица';

  @override
  String get verificationRequestPublicInstitution => 'Проверка государственного учреждения';

  @override
  String get verificationRequestVerifiedOrganization => 'Проверка организации';

  @override
  String get verificationCenterTitle => 'Проверка и тип аккаунта';

  @override
  String get verificationCurrentAccountSection => 'Текущий аккаунт';

  @override
  String verificationAccountTypeValue(String accountType) {
    return 'Тип аккаунта: $accountType';
  }

  @override
  String verificationLevelValue(String level) {
    return 'Уровень проверки: $level';
  }

  @override
  String verificationOfficialTitleValue(String title) {
    return 'Официальная должность: $title';
  }

  @override
  String verificationInstitutionNameValue(String name) {
    return 'Учреждение: $name';
  }

  @override
  String verificationOrganizationNameValue(String name) {
    return 'Организация: $name';
  }

  @override
  String verificationInstitutionLevelValue(String level) {
    return 'Уровень учреждения: $level';
  }

  @override
  String get verificationActiveRequestSection => 'Активная заявка';

  @override
  String get verificationProfileUnchangedUntilApproval => 'Ваш текущий профиль не изменится до одобрения заявки.';

  @override
  String get verificationCancelPendingAction => 'Отменить ожидающую заявку';

  @override
  String get verificationPendingBlocksNewRequests => 'Нельзя подать новую заявку, пока другая находится на рассмотрении.';

  @override
  String get verificationNoActiveRequestSection => 'Нет активных заявок';

  @override
  String get verificationNoActiveRequestDescription => 'Сейчас у вас нет заявок на рассмотрении.';

  @override
  String get verificationLastRejectedSection => 'Последняя отклонённая заявка';

  @override
  String get verificationLastRejectedDescription => 'Ваша последняя заявка была отклонена.';

  @override
  String get verificationRejectedCanResubmit => 'Ваш текущий профиль не изменён. Вы можете исправить информацию и подать новую заявку.';

  @override
  String get verificationAvailableRequestsSection => 'Доступные заявки';

  @override
  String get verificationRequestLevel1Title => 'Запросить проверку личности — Уровень 1';

  @override
  String get verificationRequestLevel1Subtitle => 'Базовая проверка личности';

  @override
  String get verificationRequestLevel2Title => 'Запросить проверку личности — Уровень 2';

  @override
  String get verificationRequestLevel2Subtitle => 'Расширенная проверка личности';

  @override
  String get verificationRequestPublicOfficialTitle => 'Запросить аккаунт публичного должностного лица';

  @override
  String get verificationRequestPublicOfficialSubtitle => 'Требуются официальная должность и проверка';

  @override
  String get verificationRequestPublicInstitutionTitle => 'Запросить аккаунт государственного учреждения';

  @override
  String get verificationRequestPublicInstitutionSubtitle => 'Требуются название учреждения, его уровень и проверка';

  @override
  String get verificationRequestOrganizationTitle => 'Запросить аккаунт проверенной организации';

  @override
  String get verificationRequestOrganizationSubtitle => 'Требуются сведения об организации, роль представителя и проверка Admin';

  @override
  String get verificationNoSelfServiceUpgrade => 'Для текущего состояния аккаунта нет доступных вариантов проверки.';

  @override
  String get verificationRequestSubmitSuccess => 'Заявка успешно отправлена.';

  @override
  String get verificationRequestSubmitFailure => 'Не удалось отправить заявку.';

  @override
  String get verificationOfficialTitleDialogTitle => 'Проверка публичного должностного лица';

  @override
  String get verificationOfficialTitleLabel => 'Официальная должность';

  @override
  String get verificationOfficialTitleHint => 'например мэр, советник, министр';

  @override
  String get verificationInstitutionDialogTitle => 'Проверка государственного учреждения';

  @override
  String get verificationInstitutionNameLabel => 'Название учреждения';

  @override
  String get verificationInstitutionNameHint => 'например город Рим';

  @override
  String get verificationInstitutionLevelLabel => 'Уровень учреждения';

  @override
  String get verificationOrganizationDialogTitle => 'Проверка организации';

  @override
  String get verificationOrganizationNameHint => 'например Ассоциация «Экология Италии»';

  @override
  String get verificationSubmitRequestAction => 'Отправить заявку';

  @override
  String get verificationCancelDialogTitle => 'Отменить заявку';

  @override
  String get verificationCancelDialogBody => 'Вы уверены, что хотите отменить ожидающую заявку на проверку?';

  @override
  String get verificationCancelSuccess => 'Заявка отменена.';

  @override
  String get verificationCancelFailure => 'Не удалось отменить заявку.';

  @override
  String get verificationStatusPendingSuffix => 'заявка на рассмотрении';

  @override
  String get verificationStatusRejectedSuffix => 'последняя заявка отклонена';

  @override
  String get verificationReviewPageTitle => 'Рассмотрение заявок на проверку';

  @override
  String get verificationReviewLoginRequired => 'Чтобы рассматривать заявки на проверку, необходимо войти в систему.';

  @override
  String verificationReviewPendingCount(int count) {
    return 'Ожидающих заявок: $count';
  }

  @override
  String get verificationReviewNoPendingRequests => 'Нет ожидающих заявок на проверку.';

  @override
  String get verificationReviewUserIdLabel => 'ID пользователя';

  @override
  String get verificationReviewSubmittedLabel => 'Отправлено';

  @override
  String get verificationReviewOfficialTitleLabel => 'Официальная должность';

  @override
  String get verificationReviewInstitutionLabel => 'Учреждение';

  @override
  String get verificationReviewOrganizationLabel => 'Организация';

  @override
  String get verificationReviewNoteLabel => 'Примечание проверки';

  @override
  String get verificationReviewRejectAction => 'Отклонить';

  @override
  String get verificationReviewApproveAction => 'Одобрить';

  @override
  String get verificationReviewApproveDialogTitle => 'Одобрить заявку';

  @override
  String get verificationReviewRejectDialogTitle => 'Отклонить заявку';

  @override
  String get verificationReviewApproveConfirmation => 'Подтвердить одобрение этой заявки?';

  @override
  String get verificationReviewRejectConfirmation => 'Подтвердить отклонение этой заявки?';

  @override
  String get verificationReviewOptionalNoteLabel => 'Необязательное примечание';

  @override
  String get verificationReviewRequiredNoteLabel => 'Причина отклонения';

  @override
  String get verificationReviewOptionalHelper => 'Необязательно';

  @override
  String get verificationReviewRequiredHelper => 'Обязательно при отклонении';

  @override
  String get verificationReviewRequiredNoteError => 'Введите причину отклонения.';

  @override
  String get verificationReviewApprovedSuccess => 'Заявка одобрена.';

  @override
  String get verificationReviewRejectedSuccess => 'Заявка отклонена.';

  @override
  String get verificationReviewOperationFailure => 'Операция не выполнена.';

  @override
  String get adminCenterTitle => 'Admin Center';

  @override
  String get adminCenterDashboardNavigation => 'Панель';

  @override
  String get adminCenterUsersNavigation => 'Пользователи';

  @override
  String get adminCenterVerificationNavigation => 'Проверка';

  @override
  String get adminCenterReportsNavigation => 'Жалобы';

  @override
  String get adminCenterAuditNavigation => 'Аудит';

  @override
  String get adminCenterAccountDetailsTitle => 'Сведения об аккаунте';

  @override
  String get adminCenterTryAgainAction => 'Попробовать ещё раз';

  @override
  String get adminCenterRetryAction => 'Повторить';

  @override
  String get adminCenterClearAction => 'Очистить';

  @override
  String get adminCenterApplyFiltersAction => 'Применить фильтры';

  @override
  String get adminCenterAllDates => 'Все даты';

  @override
  String get adminCenterAuditDateFilterHelp => 'Фильтр аудита по дате';

  @override
  String get adminCenterActorUserIdLabel => 'ID пользователя-исполнителя';

  @override
  String get adminCenterActionLabel => 'Действие';

  @override
  String get adminCenterAuditActionHint => 'resolve_escalated_report';

  @override
  String get adminCenterTargetIdLabel => 'ID цели';

  @override
  String get adminCenterOutcomeLabel => 'Результат';

  @override
  String get adminCenterAllOutcomes => 'Все результаты';

  @override
  String get adminCenterOutcomeSuccess => 'Успешно';

  @override
  String get adminCenterOutcomeFailure => 'Ошибка';

  @override
  String get adminCenterOutcomeDenied => 'Отказано';

  @override
  String get adminCenterOutcomeNoChange => 'Без изменений';

  @override
  String get adminCenterOutcomeUnknown => 'Неизвестно';

  @override
  String get adminCenterAuditUnavailableTitle => 'Аудит недоступен';

  @override
  String get adminCenterAuditUnavailableMessage => 'Проверьте соединение и права доступа, затем повторите.';

  @override
  String get adminCenterNoAuditEntriesTitle => 'Нет записей аудита';

  @override
  String get adminCenterNoAuditEntriesMessage => 'Нет записей, соответствующих выбранным фильтрам.';

  @override
  String get adminCenterAuditIdLabel => 'ID аудита';

  @override
  String get adminCenterActorLabel => 'Исполнитель';

  @override
  String get adminCenterReasonLabel => 'Причина';

  @override
  String get adminCenterTimestampLabel => 'Время';

  @override
  String get adminCenterErrorLabel => 'Ошибка';

  @override
  String get adminCenterRecordedValuesTitle => 'Записанные значения';

  @override
  String get adminCenterPreviousValueLabel => 'Предыдущее';

  @override
  String get adminCenterNewValueLabel => 'Новое';

  @override
  String get adminCenterContentTypeLabel => 'Тип контента';

  @override
  String get adminCenterAllContent => 'Весь контент';

  @override
  String get adminCenterPolls => 'Vote';

  @override
  String get adminCenterPosts => 'Voce';

  @override
  String get adminCenterNews => 'News';

  @override
  String get adminCenterAwaitingAdminDecision => 'Ожидает решения Admin';

  @override
  String get adminCenterStatusLabel => 'Статус';

  @override
  String get adminCenterAllStatuses => 'Все статусы';

  @override
  String get adminCenterStatusOpen => 'Открыт';

  @override
  String get adminCenterStatusInReview => 'На рассмотрении';

  @override
  String get adminCenterStatusResolved => 'Решён';

  @override
  String get adminCenterStatusDismissed => 'Отклонён';

  @override
  String get adminCenterAdminQueueUnavailableTitle => 'Очередь эскалаций Admin недоступна';

  @override
  String get adminCenterReportsUnavailableTitle => 'Жалобы недоступны';

  @override
  String get adminCenterConnectionTryAgainMessage => 'Проверьте соединение и попробуйте ещё раз.';

  @override
  String get adminCenterNoAdminReportsTitle => 'Нет жалоб, ожидающих решения Admin';

  @override
  String get adminCenterNoReportsTitle => 'Нет жалоб';

  @override
  String get adminCenterNoAdminReportsMessage => 'Нет эскалированных жалоб, требующих проверки администратора.';

  @override
  String get adminCenterNoReportsMessage => 'Нет жалоб, соответствующих выбранным фильтрам.';

  @override
  String get adminCenterSearchUsersHint => 'Поиск по имени, имени пользователя, email или ID';

  @override
  String get adminCenterClearSearchTooltip => 'Очистить поиск';

  @override
  String get adminCenterUsersUnavailableTitle => 'Пользователи недоступны';

  @override
  String get adminCenterNoUsersFoundTitle => 'Пользователи не найдены';

  @override
  String get adminCenterNoUsersTitle => 'Нет пользователей';

  @override
  String get adminCenterNoUsersFoundMessage => 'Попробуйте другое имя, имя пользователя, email или ID.';

  @override
  String get adminCenterNoUsersMessage => 'Нет аккаунтов для отображения.';

  @override
  String get adminCenterAccountUnavailableTitle => 'Аккаунт недоступен';

  @override
  String get adminCenterBackToUsersAction => 'Вернуться к пользователям';

  @override
  String get adminCenterPublicIdentitySection => 'Публичная идентичность';

  @override
  String get adminCenterDisplayNameLabel => 'Отображаемое имя';

  @override
  String get adminCenterNotProvided => 'Не указано';

  @override
  String get adminCenterUsernameLabel => 'Имя пользователя';

  @override
  String get adminCenterUserIdLabel => 'ID пользователя';

  @override
  String get adminCenterIdentityTypeLabel => 'Тип идентичности';

  @override
  String get adminCenterAccountSection => 'Аккаунт';

  @override
  String get adminCenterTechnicalRoleLabel => 'Техническая роль';

  @override
  String get adminCenterRoleMirrorLabel => 'Зеркало роли профиля';

  @override
  String get adminCenterRoleSynchronizationLabel => 'Синхронизация ролей';

  @override
  String get adminCenterSynchronized => 'Синхронизировано';

  @override
  String get adminCenterNotSynchronized => 'Не синхронизировано';

  @override
  String get adminCenterRoleNotSynchronized => 'Роль не синхронизирована';

  @override
  String get adminCenterAccountStatusLabel => 'Статус аккаунта';

  @override
  String get adminCenterSuspendedUntilLabel => 'Приостановлен до';

  @override
  String get adminCenterAccountManagementSection => 'Управление аккаунтом';

  @override
  String get adminCenterDangerZoneSection => 'Опасная зона';

  @override
  String get adminCenterRoleManagementSection => 'Управление ролями';

  @override
  String get adminCenterVerificationLevelLabel => 'Уровень проверки';

  @override
  String get adminCenterVerificationStatusLabel => 'Статус проверки';

  @override
  String get adminCenterAccessInformationSection => 'Информация о доступе';

  @override
  String get adminCenterEmailLabel => 'Email';

  @override
  String get adminCenterNotAvailable => 'Недоступно';

  @override
  String get adminCenterEmailConfirmationLabel => 'Подтверждение email';

  @override
  String get adminCenterNotConfirmed => 'Не подтверждён';

  @override
  String get adminCenterRegisteredLabel => 'Зарегистрирован';

  @override
  String get adminCenterLastAccessLabel => 'Последний доступ';

  @override
  String get adminCenterLoadingDashboardTitle => 'Загрузка панели';

  @override
  String get adminCenterLoadingDashboardMessage => 'Получение последних показателей.';

  @override
  String get adminCenterDashboardUnavailableTitle => 'Панель недоступна';

  @override
  String get adminCenterIndicatorsUnavailableMessage => 'Не удалось загрузить показатели.';

  @override
  String get adminCenterVerificationPendingIndicator => 'Ожидает проверки';

  @override
  String get adminCenterOpenReportsIndicator => 'Открытые жалобы';

  @override
  String get adminCenterSuspendedAccountsIndicator => 'Приостановленные аккаунты';

  @override
  String get adminCenterStaffIndicator => 'Персонал';

  @override
  String get adminCenterNoPendingWorkTitle => 'Нет ожидающей работы';

  @override
  String get adminCenterNoPendingWorkMessage => 'Проверки, жалобы и приостановленные аккаунты обработаны.';

  @override
  String get adminCenterCouldNotUpdateUsers => 'Не удалось обновить список пользователей.';

  @override
  String get adminCenterCouldNotUpdateReports => 'Не удалось обновить очередь жалоб.';

  @override
  String get adminCenterUnnamedUser => 'Пользователь без имени';

  @override
  String get adminCenterTemporarySuspensionTitle => 'Временная приостановка';

  @override
  String get adminCenterReactivateDescription => 'Немедленно снять приостановку и разрешить новый вход.';

  @override
  String get adminCenterSuspendDescription => 'Ограничить доступ на определённый срок и завершить все текущие сессии.';

  @override
  String get adminCenterSuspensionUnavailableDescription => 'Приостановка доступна только для синхронизированного аккаунта, не являющегося admin.';

  @override
  String get adminCenterReactivateAccountAction => 'Повторно активировать аккаунт';

  @override
  String get adminCenterSuspendAccountAction => 'Приостановить аккаунт';

  @override
  String get adminCenterForceLogoutAction => 'Принудительно выйти';

  @override
  String get adminCenterSuspendedForceLogoutDescription => 'Приостановка уже завершила текущие сессии. Перед отдельной проверкой выхода повторно активируйте аккаунт.';

  @override
  String get adminCenterForceLogoutDescription => 'Завершить все текущие сессии без приостановки аккаунта.';

  @override
  String get adminCenterForceLogoutUnavailableDescription => 'Принудительный выход доступен только для синхронизированного аккаунта, не являющегося admin.';

  @override
  String get adminCenterPermanentDeletionTitle => 'Безвозвратное удаление аккаунта';

  @override
  String get adminCenterPermanentDeletionDescription => 'Удалить данные аутентификации, завершить все сессии и анонимизировать сохраняемую публичную запись.';

  @override
  String get adminCenterDeletionUnavailableDescription => 'Удаление доступно только для синхронизированного аккаунта, не являющегося admin.';

  @override
  String get adminCenterDeleteAccountPermanentlyAction => 'Удалить аккаунт навсегда';

  @override
  String get adminCenterDurationOneHour => '1 час';

  @override
  String get adminCenterDurationOneDay => '24 часа';

  @override
  String get adminCenterDurationSevenDays => '7 дней';

  @override
  String get adminCenterDurationThirtyDays => '30 дней';

  @override
  String get adminCenterSuspendImmediateEffect => 'Аккаунт немедленно потеряет доступ, а все текущие сессии будут завершены.';

  @override
  String get adminCenterDurationLabel => 'Срок';

  @override
  String get adminCenterSuspendReasonHint => 'Объясните, почему этот аккаунт необходимо приостановить';

  @override
  String get adminCenterReactivateReasonHint => 'Объясните, почему этот аккаунт можно повторно активировать';

  @override
  String get adminCenterReactivateConfirmation => 'Я подтверждаю, что этому аккаунту можно вернуть доступ.';

  @override
  String get adminCenterReactivateFailure => 'Не удалось повторно активировать аккаунт. Проверьте его роль и статус, затем повторите.';

  @override
  String get adminCenterReactivateSuccess => 'Аккаунт повторно активирован. Новый вход разрешён.';

  @override
  String get adminCenterForceLogoutFullDescription => 'Завершить все текущие сессии этого аккаунта. Аккаунт останется активным и сможет снова войти.';

  @override
  String get adminCenterForceLogoutReasonHint => 'Объясните, почему текущие сессии необходимо завершить';

  @override
  String get adminCenterForceLogoutConfirmation => 'Я подтверждаю немедленное завершение всех текущих сессий этого аккаунта.';

  @override
  String get adminCenterForceLogoutFailure => 'Не удалось завершить сессии аккаунта. Проверьте его роль и статус, затем повторите.';

  @override
  String get adminCenterForceLogoutSuccess => 'Текущие сессии завершены. Аккаунт может снова войти.';

  @override
  String get adminCenterSuspendFailure => 'Не удалось приостановить аккаунт. Проверьте его роль и статус, затем повторите.';

  @override
  String get adminCenterDeleteReasonHint => 'Объясните, почему этот аккаунт необходимо удалить';

  @override
  String get adminCenterTypeDeleteLabel => 'Введите DELETE';

  @override
  String get adminCenterTypeAccountIdLabel => 'Введите полный ID аккаунта';

  @override
  String get adminCenterDeletePermanentlyAction => 'Удалить навсегда';

  @override
  String get adminCenterDeleteIrreversibleWarning => 'Это действие необратимо. Данные аутентификации и текущие сессии будут удалены, аватар будет удалён, а сохраняемая публичная запись — анонимизирована. Запись аудита останется.';

  @override
  String get adminCenterDeleteFailure => 'Не удалось удалить аккаунт. Проверьте его роль, статус и значения подтверждения, затем повторите.';

  @override
  String get adminCenterDeleteSuccess => 'Аккаунт безвозвратно удалён, личные данные анонимизированы.';

  @override
  String get adminCenterChangeTechnicalRoleTitle => 'Изменить техническую роль';

  @override
  String get adminCenterChangeRoleDescription => 'Перед подтверждением проверьте текущую и запрашиваемую роль.';

  @override
  String get adminCenterChangeRoleUnavailableDescription => 'Изменение роли доступно только для синхронизированного, не удалённого аккаунта.';

  @override
  String get adminCenterChangeRoleAction => 'Изменить роль';

  @override
  String get adminCenterChangePublicIdentityTitle => 'Изменить публичную идентичность';

  @override
  String get adminCenterChangeIdentityDescription => 'Обновить публичный тип аккаунта и уровень проверки.';

  @override
  String get adminCenterChangeIdentityUnavailableDescription => 'Изменение идентичности доступно только для синхронизированного аккаунта, не являющегося admin.';

  @override
  String get adminCenterChangeIdentityAction => 'Изменить идентичность';

  @override
  String get adminCenterChoosePublicIdentityMessage => 'Выберите публичный тип аккаунта и его статус проверки.';

  @override
  String get adminCenterPublicAccountTypeLabel => 'Публичный тип аккаунта';

  @override
  String get adminCenterPersonVerificationHelper => 'Уровни 1 и 2 доступны только для Persona.';

  @override
  String get adminCenterNonPersonVerificationHelper => 'Аккаунты не типа Persona не используют Уровень 1 или Уровень 2.';

  @override
  String get adminCenterBeforeLabel => 'До';

  @override
  String get adminCenterAfterLabel => 'После';

  @override
  String get adminCenterIdentityReasonHint => 'Объясните, почему публичную идентичность необходимо изменить';

  @override
  String get adminCenterIdentityConfirmation => 'Я подтверждаю публичную идентичность и уровень проверки, показанные выше.';

  @override
  String get adminCenterIdentityChangeFailure => 'Не удалось изменить публичную идентичность. Проверьте состояние аккаунта и повторите.';

  @override
  String get adminCenterChooseTechnicalRoleMessage => 'Выберите новую техническую роль и укажите причину изменения.';

  @override
  String get adminCenterNewTechnicalRoleLabel => 'Новая техническая роль';

  @override
  String get adminCenterSelectRole => 'Выберите роль';

  @override
  String get adminCenterRoleSessionWarning => 'Это изменение завершит активную сессию получателя. Чтобы продолжить пользоваться аккаунтом, ему потребуется войти снова.';

  @override
  String get adminCenterRoleReasonHint => 'Объясните, почему необходимо изменить техническую роль';

  @override
  String get adminCenterRoleConfirmation => 'Я подтверждаю указанную выше роль и понимаю, что получателю потребуется войти снова.';

  @override
  String get adminCenterRoleChangeFailure => 'Не удалось изменить роль. Проверьте состояние аккаунта и повторите.';

  @override
  String get adminCenterChangingRole => 'Изменение роли';

  @override
  String get adminCenterConfirmRoleChange => 'Подтвердить изменение роли';

  @override
  String get adminCenterRoleUser => 'Пользователь';

  @override
  String get adminCenterRoleModerator => 'Модератор';

  @override
  String get adminCenterRoleAdmin => 'Admin';

  @override
  String get adminCenterAccountStatusActive => 'Активен';

  @override
  String get adminCenterAccountStatusSuspended => 'Приостановлен';

  @override
  String get adminCenterAccountStatusDeleted => 'Удалён';

  @override
  String get adminCenterVerificationStatusNone => 'Нет';

  @override
  String get adminCenterVerificationStatusPending => 'Ожидает';

  @override
  String get adminCenterVerificationStatusRejected => 'Отклонён';

  @override
  String get adminCenterVerificationNotVerified => 'Не проверен';

  @override
  String get adminCenterVerificationLevel1 => 'Уровень 1';

  @override
  String get adminCenterVerificationLevel2 => 'Уровень 2';

  @override
  String get adminCenterReportSingular => 'жалоба';

  @override
  String get adminCenterReportPlural => 'жалобы';

  @override
  String get adminCenterUserSingular => 'пользователь';

  @override
  String get adminCenterUserPlural => 'пользователи';

  @override
  String get adminCenterPoll => 'Vote';

  @override
  String get adminCenterPost => 'Voce';

  @override
  String get adminCenterUnknown => 'Неизвестно';

  @override
  String get adminCenterContentHidden => 'Контент скрыт';

  @override
  String get adminCenterContentVisible => 'Контент видим';

  @override
  String get adminCenterReportedByLabel => 'Жалоба от';

  @override
  String get adminCenterContentOwnerLabel => 'Владелец контента';

  @override
  String get adminCenterReviewReportAction => 'Рассмотреть жалобу';

  @override
  String get adminCenterAdminDecisionAction => 'Решение Admin';

  @override
  String get adminCenterRestoreContentAction => 'Восстановить контент';

  @override
  String get adminCenterHideContentAction => 'Скрыть контент';

  @override
  String get adminCenterOpenProfileAction => 'Открыть профиль';

  @override
  String get adminCenterOpenContentAction => 'Открыть контент';

  @override
  String get adminCenterDecisionNoViolation => 'Нарушения нет';

  @override
  String get adminCenterDecisionViolationConfirmed => 'Нарушение подтверждено';

  @override
  String get adminCenterDecisionEscalateToAdmin => 'Передать Admin';

  @override
  String get adminCenterResolutionNoAccountAction => 'Без действий с аккаунтом';

  @override
  String get adminCenterResolutionAccountSuspended => 'Аккаунт приостановлен';

  @override
  String get adminCenterResolutionLogoutForced => 'Принудительный выход';

  @override
  String get adminCenterResolutionAccountDeleted => 'Аккаунт удалён';

  @override
  String get adminCenterReviewerLabel => 'Проверяющий';

  @override
  String get adminCenterDecisionDescriptionNoViolation => 'Закрывает жалобу, поскольку контент не нарушает действующие правила.';

  @override
  String get adminCenterDecisionDescriptionViolation => 'Подтверждает нарушение и оставляет дело на рассмотрении для действия с контентом, предусмотренного AC8.5.';

  @override
  String get adminCenterDecisionDescriptionEscalation => 'Передаёт дело администратору для проверки на уровне аккаунта.';

  @override
  String get adminCenterChooseModerationOutcome => 'Выберите результат модерации для этой жалобы.';

  @override
  String get adminCenterDecisionAlreadyRecordedFailure => 'Не удалось записать решение. Возможно, жалоба уже была рассмотрена. Обновите очередь и повторите.';

  @override
  String get adminCenterDecisionLabel => 'Решение';

  @override
  String get adminCenterReportReasonLabel => 'Причина жалобы';

  @override
  String get adminCenterReviewNoteLabel => 'Примечание проверки';

  @override
  String get adminCenterReviewNoteHint => 'Опишите доказательства и решение модерации';

  @override
  String get adminCenterRecordingDecision => 'Запись решения';

  @override
  String get adminCenterConfirmDecision => 'Подтвердить решение';

  @override
  String get adminCenterAdministratorDecisionTitle => 'Решение администратора';

  @override
  String get adminCenterResolutionDescriptionNoAction => 'Закрывает эскалированную жалобу без изменения аккаунта.';

  @override
  String get adminCenterResolutionDescriptionSuspended => 'Закрывает жалобу после успешной приостановки аккаунта, уже записанной в журнале аудита.';

  @override
  String get adminCenterResolutionDescriptionLogout => 'Закрывает жалобу после успешного принудительного выхода, уже записанного в журнале аудита.';

  @override
  String get adminCenterResolutionDescriptionDeleted => 'Закрывает жалобу после успешного удаления аккаунта, уже записанного в журнале аудита.';

  @override
  String get adminCenterChooseFinalOutcome => 'Выберите окончательный результат администратора для этой эскалации.';

  @override
  String get adminCenterAdminResolutionFailure => 'Не удалось записать решение администратора. Обновите очередь и повторите.';

  @override
  String get adminCenterAdminResolutionRequiresAction => 'Сначала выполните соответствующее действие с аккаунтом, затем вернитесь к этой жалобе и запишите окончательное решение администратора.';

  @override
  String get adminCenterEscalationNoteLabel => 'Примечание эскалации';

  @override
  String get adminCenterFinalOutcomeLabel => 'Итоговый результат';

  @override
  String get adminCenterAdministratorNoteLabel => 'Примечание администратора';

  @override
  String get adminCenterAdministratorNoteHint => 'Объясните окончательное решение на уровне аккаунта';

  @override
  String get adminCenterHideContentFailure => 'Не удалось скрыть контент. Обновите очередь жалоб и повторите.';

  @override
  String get adminCenterRestoreContentFailure => 'Не удалось восстановить контент. Обновите очередь жалоб и повторите.';

  @override
  String get adminCenterHideContentWarning => 'Это удалит контент из публичного доступа. Позже действие можно отменить через фильтр «Решённые жалобы».';

  @override
  String get adminCenterRestoreContentWarning => 'Это снова сделает контент публично доступным.';

  @override
  String get adminCenterActionReasonLabel => 'Причина действия';

  @override
  String get adminCenterHideContentReasonHint => 'Объясните, почему контент необходимо скрыть';

  @override
  String get adminCenterRestoreContentReasonHint => 'Объясните, почему контент можно восстановить';

  @override
  String get adminCenterHidingContent => 'Скрытие контента';

  @override
  String get adminCenterRestoringContent => 'Восстановление контента';

  @override
  String get adminCenterReportedProfileTitle => 'Профиль, на который пожаловались';

  @override
  String get adminCenterReportedProfileNotice => 'Контекст этого профиля получен из защищённой очереди жалоб. Административные действия с аккаунтом выполняются отдельно.';

  @override
  String get adminCenterCouldNotRefreshIndicators => 'Не удалось обновить показатели.';

  @override
  String get adminCenterCouldNotRefreshAccount => 'Не удалось обновить сведения об аккаунте.';

  @override
  String get adminCenterReportAlreadyReviewed => 'Эта жалоба уже рассмотрена или больше не ожидает проверки.';

  @override
  String get adminCenterReportNotAwaitingAdmin => 'Эта жалоба не ожидает решения администратора.';

  @override
  String get adminCenterConfirmedViolationRequired => 'Чтобы изменить видимость контента, требуется подтверждённое нарушение.';

  @override
  String get adminCenterContentHiddenSuccess => 'Контент, на который пожаловались, скрыт.';

  @override
  String get adminCenterContentRestoredSuccess => 'Контент, на который пожаловались, восстановлен.';

  @override
  String get adminCenterMissingContentId => 'Отсутствует исходный идентификатор контента.';

  @override
  String get adminCenterUnsupportedTargetType => 'У этой жалобы неподдерживаемый тип цели.';

  @override
  String get adminCenterOriginalContentUnavailable => 'Исходный контент больше недоступен.';

  @override
  String get adminCenterNoReportedProfile => 'С этим контентом не связан профиль, на который пожаловались.';

  @override
  String adminCenterRoleChangedSuccess(String previousRole, String newRole) {
    return 'Техническая роль изменена с $previousRole на $newRole. Получатель вышел из системы и должен войти снова.';
  }

  @override
  String adminCenterIdentityChangedSuccess(String actorType, String verificationLevel) {
    return 'Публичная идентичность изменена на $actorType с уровнем проверки $verificationLevel.';
  }

  @override
  String adminCenterAccountSuspendedSuccess(String dateTime) {
    return 'Аккаунт приостановлен до $dateTime. Получатель вышел из системы.';
  }

  @override
  String adminCenterReportDecisionRecorded(String decision) {
    return 'Решение по жалобе записано: $decision.';
  }

  @override
  String adminCenterAdministratorDecisionRecorded(String decision) {
    return 'Решение администратора записано: $decision.';
  }

  @override
  String adminCenterUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count пользователей',
      one: '$count пользователь',
    );
    return '$_temp0';
  }

  @override
  String adminCenterReportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count жалоб',
      one: '$count жалоба',
    );
    return '$_temp0';
  }

  @override
  String adminCenterAccountValue(String account) {
    return 'Аккаунт: $account';
  }

  @override
  String adminCenterSuspendedUntilValue(String dateTime) {
    return 'Приостановлен до: $dateTime';
  }

  @override
  String adminCenterSuspendConfirmation(String dateTime) {
    return 'Я подтверждаю приостановку до $dateTime и немедленное завершение текущих сессий.';
  }

  @override
  String adminCenterAccountIdValue(String accountId) {
    return 'ID аккаунта: $accountId';
  }

  @override
  String adminCenterCurrentRoleValue(String role) {
    return 'Текущая: $role';
  }

  @override
  String adminCenterTargetFallback(String targetType, String targetId) {
    return '$targetType $targetId';
  }

  @override
  String adminCenterMinimumCharactersRequired(int count) {
    return 'Требуется примечание не короче $count символов.';
  }

  @override
  String adminCenterMinimumReasonCharactersRequired(int count) {
    return 'Требуется причина не короче $count символов.';
  }

  @override
  String adminCenterPageOf(int currentPage, int totalPages) {
    return 'Страница $currentPage из $totalPages';
  }

  @override
  String get profilePublicProfileSectionTitle => 'Публичный профиль';

  @override
  String get profileIdentityVerificationSectionTitle => 'Идентичность и проверка';

  @override
  String get profilePreferencesSectionTitle => 'Настройки';

  @override
  String get profileNotificationsSectionTitle => 'Уведомления';

  @override
  String get profileActivitySectionTitle => 'Личная активность';

  @override
  String get profileSecurityAccountSectionTitle => 'Безопасность и аккаунт';

  @override
  String get profileThemeTitle => 'Тема';

  @override
  String get profileThemeSystem => 'Системная';

  @override
  String get profileThemeSystemDescription => 'Следует теме устройства';

  @override
  String get profileThemeLight => 'Светлая';

  @override
  String get profileThemeDark => 'Тёмная';

  @override
  String get profileMyPollsTitle => 'Vote';

  @override
  String get profileMyPostsTitle => 'Voce';

  @override
  String get profileMyCommentsTitle => 'Мои комментарии';

  @override
  String get profileMyFavoritesTitle => 'Мои сохранённые';

  @override
  String get profileAccountConnectionsTitle => 'Подписки и подписчики';

  @override
  String get accountConnectionsFollowingTab => 'Подписки';

  @override
  String get accountConnectionsFollowersTab => 'Подписчики';

  @override
  String get accountConnectionsEmptyFollowing => 'Вы пока ни на кого не подписаны.';

  @override
  String get accountConnectionsEmptyFollowers => 'У вас пока нет подписчиков.';

  @override
  String get accountConnectionsLoadError => 'Не удалось загрузить аккаунты. Попробуйте ещё раз.';

  @override
  String get profileMyFollowedScopesTitle => 'Мои отслеживаемые области';

  @override
  String get profileLogoutAction => 'Выйти';

  @override
  String get profileLogoutDescription => 'Выйти из текущего аккаунта';

  @override
  String get profileLogoutDialogTitle => 'Выйти';

  @override
  String get profileLogoutDialogMessage => 'Вы уверены, что хотите выйти из аккаунта?';

  @override
  String get profileLogoutCancelButton => 'Отмена';

  @override
  String get profileLogoutConfirmButton => 'Выйти';

  @override
  String get publicProfilePageTitle => 'Публичный профиль';

  @override
  String get publicProfileUserFallback => 'Пользователь';

  @override
  String get publicProfileNoBio => 'Описание отсутствует.';

  @override
  String get publicProfileResidenceLabel => 'Место проживания';

  @override
  String get publicProfileResidenceUnknown => 'Не указано';

  @override
  String get publicProfileMemberSinceLabel => 'Участник с';

  @override
  String get publicProfileContentSectionTitle => 'Публичный контент';

  @override
  String get publicProfilePollsAction => 'Vote';

  @override
  String get publicProfilePostsAction => 'Voce';

  @override
  String get publicProfileBlockUserAction => 'Заблокировать пользователя';

  @override
  String get publicProfileLoadError => 'Не удалось загрузить профиль.';

  @override
  String get publicProfileNotFound => 'Профиль недоступен.';

  @override
  String get publicProfileUnblockUserAction => 'Разблокировать пользователя';

  @override
  String get publicProfileBlockDialogTitle => 'Заблокировать этого пользователя?';

  @override
  String get publicProfileBlockDialogMessage => 'Позже вы сможете разблокировать его из публичного профиля.';

  @override
  String get publicProfileUnblockDialogTitle => 'Разблокировать этого пользователя?';

  @override
  String get publicProfileUnblockDialogMessage => 'Пользователь будет удалён из вашего списка блокировок.';

  @override
  String get publicProfileBlockSuccess => 'Пользователь заблокирован.';

  @override
  String get publicProfileUnblockSuccess => 'Пользователь разблокирован.';

  @override
  String get publicProfileBlockError => 'Не удалось обновить блокировку. Попробуйте ещё раз.';

  @override
  String get publicProfileFollowersLabel => 'подписчиков';

  @override
  String get publicProfileFollowingLabel => 'подписок';

  @override
  String get publicProfileFollowAction => 'Подписаться';

  @override
  String get publicProfileUnfollowAction => 'Отписаться';

  @override
  String get publicProfileFollowSuccess => 'Вы подписались на аккаунт.';

  @override
  String get publicProfileUnfollowSuccess => 'Вы отписались от аккаунта.';

  @override
  String get publicProfileFollowError => 'Не удалось обновить подписку. Попробуйте ещё раз.';

  @override
  String get publicProfileFollowRetry => 'Обновить информацию о подписке';

  @override
  String get contentLanguageFieldLabel => 'Язык контента';

  @override
  String get contentLanguageFieldHelper => 'Выберите язык, на котором написан контент.';

  @override
  String get contentLanguageUndetermined => 'Не указано';

  @override
  String get createPollAdvancedOptionsTitle => 'Расширенные настройки';

  @override
  String get createPollAdvancedOptionsSubtitle => 'Анонимность, видимость результатов, изменение голоса и кворум.';

  @override
  String get onboardingSkipButton => 'Пропустить';

  @override
  String get onboardingNextButton => 'Далее';

  @override
  String get onboardingStartButton => 'Начать';

  @override
  String get onboardingPollTitle => 'Vote';

  @override
  String get onboardingPollDescription => 'Участвуйте в Vote по важным для вас темам или создайте свой, чтобы узнать мнение сообщества.';

  @override
  String get onboardingHeatIceTitle => 'Heat и Ice';

  @override
  String get onboardingHeatIceDescription => 'Используйте Heat и Ice, чтобы показать, насколько сильно контент привлекает ваш интерес.';

  @override
  String get onboardingCivicMapTitle => 'Civic Map';

  @override
  String get onboardingCivicMapDescription => 'Исследуйте Vote, Voce и News на карте и узнавайте, что происходит в разных местах.';

  @override
  String get onboardingGeoScopeTitle => 'GeoScope';

  @override
  String get onboardingGeoScopeDescription => 'Выберите географический уровень, который хотите отслеживать: мир, страна или город.';

  @override
  String get onboardingVerificationTitle => 'Проверка личности';

  @override
  String get onboardingVerificationDescription => 'Некоторые Vote могут требовать определённого уровня проверки для защиты целостности голосования.';

  @override
  String get pollDetail_voteReceiptButton => 'Квитанция голосования';

  @override
  String get pollDetail_voteReceiptTitle => 'Квитанция голосования';

  @override
  String get pollDetail_voteReceiptIdLabel => 'ID квитанции';

  @override
  String get pollDetail_voteReceiptDateLabel => 'Записано';

  @override
  String get pollDetail_voteReceiptPrivacy => 'Эта квитанция подтверждает, что ваш голос записан, не раскрывая сделанный выбор.';

  @override
  String get pollDetail_voteReceiptCloseButton => 'Закрыть';

  @override
  String get profileBiometricUnlockTitle => 'Биометрическая разблокировка';

  @override
  String get profileBiometricUnlockDescription => 'Защищает сохранённую сессию с помощью отпечатка пальца или биометрии устройства.';

  @override
  String get profileBiometricRequiresRememberMe => 'Требуется включить «Запомнить меня».';

  @override
  String get profileBiometricUnavailable => 'Биометрия недоступна или не настроена на этом устройстве.';

  @override
  String get profileBiometricEnableReason => 'Подтвердите биометрию, чтобы включить разблокировку Social Vote.';

  @override
  String get profileBiometricEnabledMessage => 'Биометрическая разблокировка включена.';

  @override
  String get profileBiometricDisabledMessage => 'Биометрическая разблокировка отключена.';

  @override
  String get profileBiometricAuthFailedMessage => 'Биометрическая аутентификация не была завершена.';

  @override
  String get biometricLockTitle => 'Social Vote заблокирован';

  @override
  String get biometricLockMessage => 'Используйте биометрию устройства, чтобы разблокировать сохранённую сессию.';

  @override
  String get biometricUnlockButton => 'Разблокировать';

  @override
  String get biometricUsePasswordButton => 'Использовать пароль';

  @override
  String get biometricUnlockReason => 'Разблокируйте вашу сессию Social Vote.';

  @override
  String get biometricUnlockFailedMessage => 'Не удалось разблокировать. Попробуйте ещё раз или используйте пароль.';

  @override
  String get adminCenterOperationalActivityTitle => 'Операционная активность';

  @override
  String get adminCenterOperationalActivitySubtitle => 'Агрегированные счётчики. Без отслеживания присутствия онлайн в реальном времени.';

  @override
  String get adminCenterLast24HoursLabel => '24 часа';

  @override
  String get adminCenterLast7DaysLabel => '7 дней';

  @override
  String get adminCenterNewUsersMetric => 'Новые регистрации';

  @override
  String get adminCenterRecentSignInsMetric => 'Недавние входы';

  @override
  String get adminCenterPollsCreatedMetric => 'Созданные Vote';

  @override
  String get adminCenterPostsCreatedMetric => 'Созданные Voce';

  @override
  String get adminCenterAdminActionsMetric => 'Действия Admin';

  @override
  String get authPublicNameHelper => 'Это имя будут видеть другие пользователи. Имя пользователя создаётся автоматически.';

  @override
  String get adminCenterRefreshMarkersTooltip => 'Обновить маркеры глобуса';

  @override
  String get adminCenterMarkerDensityTitle => 'Плотность мировых маркеров';

  @override
  String get adminCenterMarkerDensitySubtitle => 'Управляет визуальным бюджетом маркеров на глобусе Home, не изменяя реальные координаты или ранжирование контента.';

  @override
  String get adminCenterMarkerDensityEmpty => 'Пусто';

  @override
  String get adminCenterMarkerDensityFull => 'Полностью';

  @override
  String adminCenterMarkerDensityBudget(int count) {
    return 'Бюджет Home: $count маркеров';
  }

  @override
  String get adminCenterMarkerDensitySaveError => 'Не удалось сохранить плотность мировых маркеров.';

  @override
  String get adminCenterMarkerDensityBackendUnavailable => 'Backend-настройки мировых маркеров пока недоступны.';

  @override
  String get adminCenterQuickActionsTitle => 'Быстрые действия с аккаунтом';

  @override
  String get adminCenterModerationSnapshotTitle => 'Сводка модерации и активности';

  @override
  String get adminCenterReportsReceivedMetric => 'Полученные жалобы';

  @override
  String get adminCenterPendingReportsMetric => 'Ожидающие жалобы';

  @override
  String get adminCenterConfirmedViolationsMetric => 'Подтверждённые нарушения';

  @override
  String get adminCenterReportsFiledMetric => 'Отправленные жалобы';

  @override
  String get adminCenterCommentsCreatedMetric => 'Созданные комментарии';

  @override
  String get adminCenterAdminActionsOnAccountMetric => 'Действия Admin с аккаунтом';

  @override
  String get adminCenterLastReportReceivedLabel => 'Последняя полученная жалоба';

  @override
  String get adminCenterOpenFullAccountAction => 'Открыть полное управление аккаунтом';

  @override
  String get profileAppLanguageGerman => 'Немецкий';

  @override
  String get profileAppLanguagePersian => 'Персидский';

  @override
  String get discoveryPageTitle => 'Исследовать';

  @override
  String get organizationWorkspaceTitle => 'Workspace организации';

  @override
  String get organizationPilotBannerTitle => 'Бесплатный пилот';

  @override
  String get organizationPilotBannerBody => 'Во время пилота Sessions бесплатны. Некоторые профессиональные функции в будущем могут стать платными; сейчас billing отключён.';

  @override
  String get organizationVerifiedLabel => 'Проверенная организация';

  @override
  String get organizationEditProfile => 'Редактировать профиль организации';

  @override
  String get organizationCreateSession => 'Новая Session';

  @override
  String get organizationNoSessions => 'Sessions пока нет. Создайте первую для встречи, семинара или мероприятия.';

  @override
  String get organizationSessionsTitle => 'Live Sessions';

  @override
  String get organizationRequiresVerificationTitle => 'Требуется проверенная организация';

  @override
  String get organizationRequiresVerificationBody => 'Этот workspace доступен только аккаунтам, одобренным Social Vote как проверенная организация.';

  @override
  String get organizationProfileEditorTitle => 'Профиль организации';

  @override
  String get organizationLegalName => 'Юридическое название';

  @override
  String get organizationPublicName => 'Публичное название';

  @override
  String get organizationType => 'Тип организации';

  @override
  String get organizationCountryCode => 'Код страны';

  @override
  String get organizationCity => 'Город';

  @override
  String get organizationWebsite => 'Официальный сайт';

  @override
  String get organizationDescription => 'Описание';

  @override
  String get organizationUploadCover => 'Изменить обложку';

  @override
  String get organizationUploadLogo => 'Изменить логотип';

  @override
  String get organizationMediaUpdated => 'Изображение организации обновлено.';

  @override
  String get organizationNamesRequired => 'Юридическое и публичное названия обязательны.';

  @override
  String get organizationTypeAssociation => 'Ассоциация';

  @override
  String get organizationTypeNonprofit => 'Некоммерческая организация';

  @override
  String get organizationTypeCompany => 'Компания';

  @override
  String get organizationTypeCooperative => 'Кооператив';

  @override
  String get organizationTypeSports => 'Спортивная организация';

  @override
  String get organizationTypePublicBody => 'Государственный орган';

  @override
  String get organizationTypeCommittee => 'Комитет / группа';

  @override
  String get organizationTypeOther => 'Другое';

  @override
  String get sessionCreateTitle => 'Создать Live Session';

  @override
  String get sessionTitleLabel => 'Название Session';

  @override
  String get sessionExpectedParticipants => 'Ожидаемое число участников';

  @override
  String get sessionAccessMode => 'Доступ участников';

  @override
  String get sessionAccessOpen => 'Открытый анонимный';

  @override
  String get sessionAccessOpenHint => 'Любой человек со ссылкой/кодом может присоединиться. Защита от дубликатов работает по принципу best-effort; этот режим не гарантирует принцип «один человек — один голос».';

  @override
  String get sessionAccessControlled => 'Контролируемый анонимный';

  @override
  String get sessionAccessControlledHint => 'Используйте одноразовые анонимные Access Pass. Social Vote хранит только хэш Access Pass и не связывает выбор в бюллетене с учётными данными участника.';

  @override
  String get sessionResultsVisibility => 'Видимость результатов';

  @override
  String get sessionResultsLive => 'В реальном времени';

  @override
  String get sessionResultsAfterVote => 'После голоса участника';

  @override
  String get sessionResultsAfterClose => 'После закрытия вопроса';

  @override
  String get sessionResultsOrganizerOnly => 'Только организатор';

  @override
  String get sessionCreateAction => 'Создать Session';

  @override
  String get sessionPilotLimit => 'Лимит пилота: от 1 до 250 участников на Session.';

  @override
  String get sessionStatusDraft => 'Черновик';

  @override
  String get sessionStatusOpen => 'Открыта';

  @override
  String get sessionStatusClosed => 'Закрыта';

  @override
  String get sessionJoinCode => 'Код присоединения';

  @override
  String get sessionShareJoin => 'Поделиться ссылкой для входа';

  @override
  String get sessionCopyJoinLink => 'Копировать ссылку';

  @override
  String get sessionGenerateTokens => 'Создать Access Pass';

  @override
  String get sessionGenerateTokensCount => 'Количество Access Pass';

  @override
  String get sessionTokensOneTimeTitle => 'Сохраните эти данные сейчас';

  @override
  String get sessionTokensOneTimeBody => 'Открытые Access Pass показываются только в результате этой генерации. Social Vote хранит только их хэши. Скопируйте и передайте их безопасным способом.';

  @override
  String get sessionCopyTokens => 'Копировать все ссылки';

  @override
  String get sessionTokensSavedAction => 'Я сохранил(а)';

  @override
  String get sessionOpenAction => 'Открыть Session';

  @override
  String get sessionCloseAction => 'Закрыть Session';

  @override
  String get sessionCloseConfirm => 'Закрыть голосование и создать неизменяемый снимок Verified Result?';

  @override
  String get sessionQuestionsTitle => 'Вопросы';

  @override
  String get sessionAddQuestion => 'Добавить вопрос';

  @override
  String get sessionQuestionTitle => 'Вопрос';

  @override
  String get sessionQuestionType => 'Тип вопроса';

  @override
  String get sessionTypeYesNo => 'Да / Нет';

  @override
  String get sessionTypeSingle => 'Один вариант';

  @override
  String get sessionTypeMultiple => 'Несколько вариантов';

  @override
  String get sessionOptions => 'Варианты';

  @override
  String get sessionOptionHint => 'Один вариант на строку.';

  @override
  String get sessionMinSelections => 'Минимум вариантов';

  @override
  String get sessionMaxSelections => 'Максимум вариантов';

  @override
  String get sessionAddAction => 'Добавить';

  @override
  String get sessionOpenQuestion => 'Открыть вопрос';

  @override
  String get sessionCloseQuestion => 'Закрыть вопрос';

  @override
  String get sessionNoQuestions => 'Вопросов пока нет.';

  @override
  String get sessionPresenterTitle => 'Presenter';

  @override
  String get sessionParticipantTitle => 'Social Vote Live';

  @override
  String get sessionJoinAction => 'Присоединиться к Session';

  @override
  String get sessionTokenLabel => 'Токен участника';

  @override
  String get sessionTokenHint => 'SV-…';

  @override
  String get sessionWaitingQuestion => 'Ожидание, пока организатор откроет вопрос…';

  @override
  String get sessionVoteAction => 'Отправить голос';

  @override
  String get sessionVoteReceived => 'Голос получен';

  @override
  String get sessionResultsUnavailable => 'Согласно политике этой Session результаты пока не видны.';

  @override
  String get sessionPrivacyNotice => 'Организатор определяет рабочую цель Session и вопросы. Social Vote обрабатывает технические данные, необходимые для предоставления и защиты сервиса. В анонимных режимах связь между учётными данными участника и его выбором не раскрывается организатору. Роли в сфере конфиденциальности могут зависеть от контекста и применимых соглашений.';

  @override
  String get sessionNonBindingNotice => 'Пилотные Sessions предназначены для консультаций и участия. Они не являются юридическими выборами, установленным законом голосованием собрания или юридически обязательной сертификацией.';

  @override
  String get sessionOptionYes => 'Да';

  @override
  String get sessionOptionNo => 'Нет';

  @override
  String get verifiedResultTitle => 'Verified Result';

  @override
  String get verifiedResultValid => 'Проверка целостности пройдена';

  @override
  String get verifiedResultInvalid => 'Проверка целостности не пройдена';

  @override
  String get verifiedResultReportId => 'ID отчёта';

  @override
  String get verifiedResultHash => 'SHA-256 хэш результата';

  @override
  String get verifiedResultGeneratedBy => 'Создано и защищено печатью целостности Social Vote';

  @override
  String get verifiedResultNotLegalCertificate => 'Это проверяемый агрегированный отчёт о результатах, а не юридический сертификат и не сертификация юридически обязательных выборов.';

  @override
  String get verifiedResultShare => 'Поделиться ссылкой проверки';

  @override
  String sessionResponses(int count) {
    return '$count ответов';
  }

  @override
  String sessionResultVotes(int count) {
    return '$count голосов';
  }

  @override
  String get organizationVerifiedIdentityLocked => 'Название и страна являются частью подтверждённой идентичности организации. Их изменение потребует новой проверки. Вы можете свободно менять обложку, логотип, тип, город, сайт и описание.';

  @override
  String get verifiedResultOpenedAt => 'Session открыта';

  @override
  String get verifiedResultEligibleCredentials => 'Допустимые учётные данные';

  @override
  String get verifiedResultIntegritySeal => 'Печать целостности Social Vote';

  @override
  String get organizationVerifiedNameLocked => 'Подтверждённые название и страна заблокированы. Их изменение требует новой проверки.';

  @override
  String get sessionRetentionLabel => 'Хранение исходных бюллетеней';

  @override
  String get sessionRetention24h => '24 часа';

  @override
  String get sessionRetention7d => '7 дней';

  @override
  String get sessionRetention30d => '30 дней';

  @override
  String sessionRetentionValue(String value) {
    return 'Хранение исходных бюллетеней: $value';
  }

  @override
  String get verifiedResultPrintPdf => 'Скачать PDF';

  @override
  String get verifiedResultPdfError => 'Не удалось скачать PDF. Попробуйте ещё раз.';

  @override
  String get verifiedResultRestrictedTitle => 'Ограниченный результат';

  @override
  String get verifiedResultRestrictedBody => 'Этот Verified Result недоступен публично. Войдите через авторизованный аккаунт организации, чтобы посмотреть его.';

  @override
  String get verifiedResultPrivateVerificationTitle => 'Публичная проверка недоступна';

  @override
  String get verifiedResultPrivateVerificationBody => 'Этот результат доступен только организатору. ID отчёта, SHA-256 и проверка целостности остаются доступны в авторизованном отчёте.';

  @override
  String get organizationAccountSectionTitle => 'Ваши организации';

  @override
  String get organizationManageAction => 'Управлять';

  @override
  String get organizationViewPublicProfileAction => 'Посмотреть профиль';

  @override
  String get organizationOfficialWebsiteAction => 'Официальный сайт';

  @override
  String get organizationVerificationIntro => 'Проверка охватывает как существование организации, так и ваши полномочия представлять её. Social Vote рассмотрит предоставленные сведения до одобрения.';

  @override
  String get organizationVerificationLegalName => 'Юридическое название';

  @override
  String get organizationVerificationPublicName => 'Публичное название';

  @override
  String get organizationVerificationType => 'Тип организации';

  @override
  String get organizationVerificationCountry => 'Страна';

  @override
  String get organizationVerificationCountryRequired => 'Выберите страну организации.';

  @override
  String get organizationVerificationCity => 'Город';

  @override
  String get organizationVerificationWebsite => 'Официальный сайт';

  @override
  String get organizationVerificationRepresentativeRole => 'Ваша роль в организации';

  @override
  String get organizationVerificationRegistryId => 'Регистрационный / налоговый / организационный идентификатор';

  @override
  String get organizationVerificationAuthorityNote => 'Как мы можем проверить, что вы имеете право представлять организацию?';

  @override
  String get organizationVerificationAuthorityHelper => 'Кратко укажите вашу роль или доказательства, которые Admin может проверить во время пилота.';

  @override
  String get organizationVerificationRequired => 'Обязательное поле.';

  @override
  String get sessionControlRoomTitle => 'Session Control Room';

  @override
  String get sessionSectionLive => 'Live';

  @override
  String get sessionSectionQuestions => 'Вопросы';

  @override
  String get sessionSectionAccess => 'Доступ';

  @override
  String get sessionSectionSettings => 'Настройки';

  @override
  String get sessionStageAction => 'Открыть Stage';

  @override
  String get sessionAccessPassesTitle => 'Access Pass участников';

  @override
  String get sessionAccessPassesSubtitle => 'Каждый pass открывает эту Controlled Anonymous Session без необходимости вводить длинные учётные данные вручную. Открытый pass не хранится Social Vote.';

  @override
  String get sessionAccessPass => 'Access Pass';

  @override
  String get sessionAccessPassDetected => 'Access Pass обнаружен';

  @override
  String get sessionAccessPassAutomatic => 'Ваш персональный pass готов. Продолжайте, чтобы войти в Session анонимно.';

  @override
  String get sessionAccessPassFallback => 'Ввести pass вручную';

  @override
  String get sessionAccessPassInvalid => 'Этот Access Pass недействителен, уже недоступен или Session не открыта.';

  @override
  String get sessionAccessPassPrintWarning => 'Распечатайте, сохраните или раздайте эти passes сейчас. После выхода с этого экрана Social Vote не сможет снова показать их в открытом виде.';

  @override
  String get sessionExistingPassesHidden => 'В целях безопасности ранее созданные passes нельзя снова показать в открытом виде. Создайте новые Access Pass, чтобы получить новые персональные ссылки или QR-коды.';

  @override
  String get sessionCopyPassLinks => 'Копировать все ссылки';

  @override
  String get sessionCopyPassLink => 'Копировать эту ссылку';

  @override
  String get sessionControlledNeedsAccessPass => 'Перед открытием контролируемой Session создайте хотя бы один Access Pass.';

  @override
  String get sessionJoinedParticipants => 'Присоединившиеся учётные данные';

  @override
  String get sessionAccessesUsed => 'Доступы, использованные для голосования';

  @override
  String get sessionBallotsRecorded => 'Записанные бюллетени';

  @override
  String get sessionQuestionsCompleted => 'Завершённые вопросы';

  @override
  String get sessionCurrentQuestion => 'Текущий вопрос';

  @override
  String get sessionNoOpenQuestionTitle => 'Нет открытого вопроса';

  @override
  String get sessionNoOpenQuestionBody => 'Участники подключены и ожидают. Откройте следующий вопрос, когда будете готовы.';

  @override
  String get sessionNotStartedTitle => 'Session ещё не началась';

  @override
  String get sessionNotStartedBody => 'Эта Session существует, но ещё не открыта. Оставьте страницу открытой и дождитесь запуска организатором.';

  @override
  String get sessionNoAccountRequired => 'Аккаунт Social Vote не требуется';

  @override
  String get sessionReceiptDetails => 'Сведения о квитанции';

  @override
  String get sessionOpenAccessInstructions => 'Покажите или поделитесь этим QR-кодом. Любой человек со ссылкой может войти, пока Session открыта.';

  @override
  String get sessionControlledAccessInstructions => 'Создайте персональные Access Pass и выдайте по одному каждому участнику. QR-код в каждом pass автоматически содержит учётные данные.';

  @override
  String get sessionControlRoomHint => 'Управляйте доступом, вопросами, проецируемым Stage и итоговым Verified Result из одного места.';

  @override
  String get sessionPresenterScreenTitle => 'Live Stage';

  @override
  String get sessionStageWaiting => 'Ожидание следующего вопроса';

  @override
  String get sessionStageScan => 'Сканируйте, чтобы присоединиться к Session';

  @override
  String get sessionConfigurationTitle => 'Конфигурация Session';

  @override
  String get sessionAccessRecommended => 'Рекомендуется для контролируемых встреч';

  @override
  String get sessionCreateIntroTitle => 'Настройте встречу';

  @override
  String get sessionCreateIntroBody => 'Выберите способ входа участников, момент отображения результатов и срок хранения исходных бюллетеней. Эти настройки применяются backend.';

  @override
  String get verifiedCertificateNumber => 'Номер сертификата';

  @override
  String get verifiedCertificateStatus => 'Статус целостности';

  @override
  String get verifiedCertificateIntegrityVerified => 'ЦЕЛОСТНОСТЬ ПОДТВЕРЖДЕНА';

  @override
  String get verifiedCertificateIntegrityFailed => 'ПРОВЕРКА ЦЕЛОСТНОСТИ НЕ ПРОЙДЕНА';

  @override
  String get verifiedCertificateOrganizationSection => 'Организация';

  @override
  String get verifiedCertificateSessionSection => 'Session';

  @override
  String get verifiedCertificateParticipationSection => 'Участие';

  @override
  String get verifiedCertificateResultsSection => 'Проверенные результаты';

  @override
  String get verifiedCertificateIntegritySection => 'Целостность результата';

  @override
  String get verifiedCertificateLegalName => 'Юридическое название';

  @override
  String get verifiedCertificateOrganizationType => 'Тип организации';

  @override
  String get verifiedCertificateLocation => 'Местоположение';

  @override
  String get verifiedCertificateWebsite => 'Сайт';

  @override
  String get verifiedCertificateVerification => 'Проверка';

  @override
  String get verifiedCertificateIssuedAt => 'Сертификат выдан';

  @override
  String get verifiedCertificateAlgorithm => 'Алгоритм целостности';

  @override
  String get verifiedCertificateSchema => 'Схема отчёта';

  @override
  String get verifiedCertificateJoinedCredentials => 'Присоединившиеся учётные данные';

  @override
  String get verifiedCertificateBallotsTotal => 'Записанные бюллетени';

  @override
  String get verifiedCertificateQuestionsTotal => 'Вопросы';

  @override
  String get verifiedCertificatePrivacyModel => 'Модель анонимных результатов';

  @override
  String get verifiedCertificatePrivacyText => 'Неизменяемый снимок содержит только агрегированные результаты. Он не содержит личность участника, открытый Access Pass, секрет участника или сопоставление учётных данных участника с выбором в бюллетене.';

  @override
  String get verifiedCertificateVerifyQr => 'Сканируйте этот QR-код, чтобы проверить отчёт онлайн.';

  @override
  String get organizationDashboardTitle => 'Обзор организации';

  @override
  String get organizationActiveSessions => 'Live Sessions';

  @override
  String get organizationVerifiedReports => 'Проверенные отчёты';

  @override
  String get organizationTotalSessions => 'Всего Sessions';

  @override
  String get sessionPrivacyPolicyAction => 'Прочитать Политику конфиденциальности';

  @override
  String get radioMondoTitle => 'Мировое радио';

  @override
  String get radioMondoDescription => 'Три оригинальных звуковых пространства для исследования Social Vote. Воспроизведение начинается только после выбора трека.';

  @override
  String get radioMondoTrackClassical => 'Классическая орбита';

  @override
  String get radioMondoTrackRain => 'Дождь над миром';

  @override
  String get radioMondoTrackYoung => 'Молодой пульс';

  @override
  String get radioMondoPlaying => 'Сейчас играет';

  @override
  String get radioMondoStopped => 'Мировое радио остановлено';

  @override
  String get radioMondoStopAction => 'Остановить';

  @override
  String get radioMondoPlaybackError => 'Не удалось воспроизвести аудио';

  @override
  String get radioMondoForegroundOnly => 'Воспроизведение останавливается, когда Social Vote закрыт, отправлен в фон или вкладка браузера скрыта.';

  @override
  String get adminCenterEditorialNavigation => 'World Briefs';

  @override
  String get worldBriefEditorTitle => 'Social Vote World Briefs';

  @override
  String get worldBriefEditorDescription => 'Готовьте briefs на основе доказательств, явно показывайте неопределённость и решайте, что появляется в News и на глобусе.';

  @override
  String get worldBriefAllStatuses => 'Все статусы';

  @override
  String get worldBriefCreateAction => 'Создать brief';

  @override
  String get worldBriefDraftSaved => 'Черновик сохранён';

  @override
  String get worldBriefPublished => 'Brief опубликован';

  @override
  String get worldBriefWithdrawn => 'Brief снят с публикации';

  @override
  String get worldBriefSaveError => 'Не удалось сохранить brief';

  @override
  String get worldBriefPublishError => 'Не удалось опубликовать brief';

  @override
  String get worldBriefDraftDeleted => 'Черновик удалён';

  @override
  String get worldBriefDeleteDraft => 'Удалить черновик';

  @override
  String get worldBriefDeleteDraftConfirm => 'Навсегда удалить этот неопубликованный черновик?';

  @override
  String get worldBriefRetry => 'Попробовать ещё раз';

  @override
  String get worldBriefStatusDraft => 'Черновик';

  @override
  String get worldBriefStatusPublished => 'Опубликован';

  @override
  String get worldBriefStatusWithdrawn => 'Снят с публикации';

  @override
  String get worldBriefSetupRequired => 'Редакционный backend не готов';

  @override
  String get worldBriefSetupRequiredBody => 'Перед использованием этого раздела примените включённую миграцию базы данных World Brief.';

  @override
  String get worldBriefEmptyTitle => 'World Briefs пока нет';

  @override
  String get worldBriefEmptyBody => 'Создайте черновик, укажите как минимум два источника и публикуйте только после редакционной проверки.';

  @override
  String get worldBriefFeatured => 'Избранное';

  @override
  String get worldBriefOnGlobe => 'Показывать на глобусе';

  @override
  String get worldBriefPriority => 'Приоритет';

  @override
  String get worldBriefEditAction => 'Редактировать';

  @override
  String get worldBriefPublishAction => 'Опубликовать';

  @override
  String get worldBriefWithdrawAction => 'Снять с публикации';

  @override
  String get worldBriefSaveDraftAction => 'Сохранить черновик';

  @override
  String get worldBriefLanguage => 'Язык brief';

  @override
  String get worldBriefTitleField => 'Заголовок';

  @override
  String get worldBriefWhatHappened => 'Что произошло';

  @override
  String get worldBriefWhyItMatters => 'Почему это важно';

  @override
  String get worldBriefWhatIsUncertain => 'Что всё ещё неизвестно';

  @override
  String get worldBriefSources => 'URL источников';

  @override
  String get worldBriefSourcesHint => 'Один HTTPS URL на строку; минимум два независимых источника.';

  @override
  String get worldBriefTwoSourcesRequired => 'Добавьте как минимум два источника.';

  @override
  String get worldBriefHttpsSourcesRequired => 'Каждый источник должен использовать HTTPS.';

  @override
  String get worldBriefGlobeSection => 'Размещение на глобусе';

  @override
  String get worldBriefGlobeRequiresPoint => 'Для отображения на глобусе требуются корректные широта и долгота.';

  @override
  String get worldBriefCountryCode => 'Код страны';

  @override
  String get worldBriefCityId => 'ID города';

  @override
  String get worldBriefLocationLabel => 'Название места';

  @override
  String get worldBriefLatitude => 'Широта';

  @override
  String get worldBriefLongitude => 'Долгота';

  @override
  String get worldBriefBreaking => 'Срочное обновление';

  @override
  String get worldBriefExpiry => 'Окно проверки или истечения';

  @override
  String worldBriefExpiryDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дней',
      one: '1 день',
    );
    return '$_temp0';
  }

  @override
  String get worldBriefRequiredField => 'Это поле обязательно.';

  @override
  String get worldBriefCoordinatesRequired => 'Введите корректную координату.';

  @override
  String get profileHowItWorksTitle => 'Как работает Social Vote';

  @override
  String get profileHowItWorksSubtitle => 'Люди, организации, Voce, Vote, Sessions и проверка.';

  @override
  String get profileMyPostsLoginRequired => 'Чтобы посмотреть свои Voce, необходимо войти.';

  @override
  String get profileMyPostsCreatedByYou => 'Voce, созданные вами';

  @override
  String get profileMyPostsEmpty => 'Вы ещё не создали ни одной Voce.';

  @override
  String get profileMyPollsLoginRequired => 'Чтобы посмотреть свои Vote, необходимо войти.';

  @override
  String get profileMyPollsCreatedByYou => 'Vote, созданные вами';

  @override
  String get profileMyPollsEmpty => 'Вы ещё не создали ни одного Vote.';

  @override
  String get profileMyCommentsLoginRequired => 'Чтобы посмотреть свои комментарии, необходимо войти.';

  @override
  String get profileMyCommentsEmpty => 'Вы ещё не написали ни одного комментария.';

  @override
  String get profileFollowedScopesLoginRequired => 'Необходимо войти в систему.';

  @override
  String get profileFollowedScopesEmpty => 'Вы пока не отслеживаете ни одной области.';

  @override
  String get profileFollowedScopeWorld => 'Мир';

  @override
  String profileFollowedScopeCountry(String code) {
    return 'Страна: $code';
  }

  @override
  String profileFollowedScopeCity(String city) {
    return 'Город: $city';
  }

  @override
  String profileFollowedScopeArea(double radius) {
    return 'Область ($radius км)';
  }

  @override
  String get publicProfilePollsLoadError => 'Не удалось загрузить публичные Vote.';

  @override
  String get publicProfilePollsEmpty => 'Публичных Vote нет.';

  @override
  String get publicProfilePostsLoadError => 'Не удалось загрузить публичные Voce.';

  @override
  String get publicProfilePostsEmpty => 'Публичных Voce нет.';

  @override
  String get worldBriefSocialVoteView => 'Позиция Social Vote';

  @override
  String get worldBriefSocialVoteViewHint => 'Редакционный анализ или позиция Social Vote. Держите её отдельно от сообщаемых фактов и неопределённости.';

  @override
  String get worldBriefSocialVoteViewPublicNote => 'Редакционный анализ Social Vote, явно отделённый от сообщаемых выше фактов.';

  @override
  String get worldBriefIndependentSourcesRequired => 'Для публикации требуется минимум два HTTPS-источника из разных доменов.';

  @override
  String get worldBriefPublishConfirmTitle => 'Финальная проверка перед публикацией';

  @override
  String worldBriefPublishConfirmSources(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Указано источников: $count',
      one: 'Указан 1 источник',
    );
    return '$_temp0';
  }

  @override
  String get worldBriefEnterpriseEditorTitle => 'Профессиональный редакционный редактор';

  @override
  String get worldBriefEnterpriseEditorHelp => 'Создавайте brief по разделам. Social Vote автоматически обрабатывает техническое размещение на глобусе: выбирайте страну и город, а не координаты.';

  @override
  String get worldBriefEditorialContentSection => 'Редакционный контент';

  @override
  String get worldBriefEditorialContentHelp => 'Разделяйте факты, значимость, неопределённость и позицию Social Vote. Так brief легче проверять и читать.';

  @override
  String get worldBriefSourcesSection => 'Источники и проверка';

  @override
  String get worldBriefSourcesSectionHelp => 'Добавьте проверяемые HTTPS-источники. Для публикации нужны минимум два независимых домена.';

  @override
  String get worldBriefDistributionSection => 'Распространение';

  @override
  String get worldBriefDistributionHelp => 'Выберите, где будет показан brief. Публикация делает его доступным в News; размещение на глобусе необязательно.';

  @override
  String get worldBriefNewsDestination => 'Опубликовать в Social Vote News';

  @override
  String get worldBriefNewsDestinationHelp => 'После публикации это основное место размещения World Brief.';

  @override
  String get worldBriefGlobeAutomaticHelp => 'Добавляет маркер на глобус. Выберите место, а Social Vote автоматически определит позицию.';

  @override
  String get worldBriefPlacementMode => 'Размещение маркера';

  @override
  String get worldBriefPlacementCity => 'Город / место';

  @override
  String get worldBriefPlacementCountry => 'Центр страны';

  @override
  String get worldBriefCountry => 'Страна';

  @override
  String get worldBriefCity => 'Город или место';

  @override
  String get worldBriefCityHelp => 'Пример: Тегеран. Не вводите широту или долготу.';

  @override
  String get worldBriefResolveLocation => 'Определить место';

  @override
  String get worldBriefCoordinatesAutomatic => 'Координаты определяются автоматически и не должны вводиться вручную.';

  @override
  String worldBriefLocationResolved(String location) {
    return 'Место готово: $location';
  }

  @override
  String get worldBriefChooseCountryFirst => 'Сначала выберите страну.';

  @override
  String get worldBriefChooseCityFirst => 'Сначала введите город или место.';

  @override
  String get worldBriefLocationNotResolved => 'Не удалось надёжно определить место. Проверьте страну и город и повторите.';

  @override
  String get worldBriefVisibilitySection => 'Видимость и приоритет';

  @override
  String get worldBriefVisibilityHelp => 'Управляйте редакционной заметностью, срочностью, порядком и сроком жизни без изменения сообщаемых фактов.';

  @override
  String get worldBriefFeaturedHelp => 'Сделайте brief более заметным на редакционных поверхностях.';

  @override
  String get worldBriefBreakingHelp => 'Используйте только для действительно срочных или быстро развивающихся событий.';

  @override
  String get worldBriefPriorityHelp => '0 = обычный/низкий приоритет; 100 = наивысший редакционный приоритет. Это не меняет статус достоверности контента.';

  @override
  String get worldBriefExpiryHelp => 'После этого срока brief не должен оставаться активным без новой редакционной проверки.';

  @override
  String get profileAppLanguageSpanish => 'Испанский';

  @override
  String get profileAppLanguagePortuguese => 'Португальский';

  @override
  String get homeHeroPurpose => 'Узнавайте, что важно, делитесь своей Voce и участвуйте в Vote.';

  @override
  String get commentSection_hideComments => 'Скрыть комментарии';

  @override
  String get commentSection_viewComments => 'Показать комментарии';

  @override
  String get commentSection_hideReplies => 'Скрыть ответы';

  @override
  String commentSection_editing(String snippet) {
    return 'Редактирование: $snippet';
  }

  @override
  String get commentSection_editInputHint => 'Редактировать комментарий';

  @override
  String commentSection_replyTo(String author) {
    return 'Ответить $author';
  }

  @override
  String get commentSection_userFallback => 'Пользователь';

  @override
  String get commentSection_addError => 'Не удалось добавить комментарий.';

  @override
  String get commentSection_nestedReplyError => 'Вложенные ответы глубже одного уровня не поддерживаются.';

  @override
  String get commentSection_addReplyError => 'Не удалось добавить ответ.';

  @override
  String get commentSection_editError => 'Не удалось отредактировать комментарий.';

  @override
  String get commentSection_deleteError => 'Не удалось удалить комментарий.';

  @override
  String get commentSection_edited => 'Изменено';

  @override
  String get commentSection_editAction => 'Редактировать';
}
