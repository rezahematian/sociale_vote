// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'Social Vote';

  @override
  String get voteButton => 'Vote';

  @override
  String get createPollPageTitle => 'Creează Vote';

  @override
  String get createPollPageSubtitle => 'Definește un nou vot civic';

  @override
  String get createPollBasicInfoTitle => 'Informații de bază';

  @override
  String get createPollBasicInfoSubtitle => 'Definește detaliile principale ale Vote.';

  @override
  String get createPollTitleFieldLabel => 'Titlu *';

  @override
  String get createPollTitleFieldHelper => 'O întrebare sau afirmație clară și concisă.';

  @override
  String get createPollDescriptionFieldLabel => 'Descriere (opțional)';

  @override
  String get createPollVotingModelTitle => 'Cum funcționează votarea';

  @override
  String get createPollVotingModelSubtitle => 'Alege dacă fiecare persoană poate selecta un singur răspuns sau mai multe răspunsuri.';

  @override
  String get createPollTypeFieldLabel => 'Tip Vote';

  @override
  String createPollSelectionRules(int min, int max) {
    return 'Reguli de selecție: minimum $min, maximum $max selecții (ajustate automat în funcție de tipul Vote și de opțiuni).';
  }

  @override
  String get createPollAllowVoteChangeTitle => 'Permite alegătorilor să își schimbe votul';

  @override
  String get createPollAllowVoteChangeSubtitle => 'Până la închiderea Vote.';

  @override
  String get createPollOptionsTitle => 'Răspunsuri';

  @override
  String get createPollOptionsSubtitle => 'Introdu cel puțin două răspunsuri dintre care alegătorii să poată alege. Câmpurile marcate cu * sunt obligatorii.';

  @override
  String createPollOptionLabel(int index, Object requiredMarker) {
    return 'Opțiunea $index$requiredMarker';
  }

  @override
  String get createPollRemoveOptionTooltip => 'Elimină opțiunea';

  @override
  String get createPollAddOptionButton => 'Adaugă opțiune';

  @override
  String get createPollParticipationPrivacyTitle => 'Participare și confidențialitate';

  @override
  String get createPollParticipationPrivacySubtitle => 'Decide cine poate vota și cât de private trebuie să fie voturile.';

  @override
  String get createPollWhoCanVoteLabel => 'Cine poate vota?';

  @override
  String get createPollParticipationEveryoneSubtitle => 'Orice utilizator înregistrat poate participa.';

  @override
  String get createPollParticipationGeoScopeSubtitle => 'Limitează acest Vote la persoanele dintr-o anumită țară.';

  @override
  String get createPollCountryFieldLabel => 'Țara pentru acest Vote';

  @override
  String get createPollCountryFieldHelper => 'Această țară va determina cine are voie să participe la acest Vote (integrare backend viitoare).';

  @override
  String get createPollVoteAnonymityTitle => 'Anonimatul Vote';

  @override
  String get createPollAnonymityAnonymousSubtitle => 'Setare implicită recomandată pentru platformele de vot civic.';

  @override
  String get createPollAnonymityPublicSubtitle => 'Folosește cu atenție: voturile pot fi asociate cu identități (funcție viitoare).';

  @override
  String get createPollResultsValidityTitle => 'Rezultate și validitate';

  @override
  String get createPollResultsValiditySubtitle => 'Controlează când sunt vizibile rezultatele și definește un cvorum minim dacă este necesar.';

  @override
  String get createPollResultsVisibilityFieldLabel => 'Vizibilitatea rezultatelor';

  @override
  String get createPollQuorumTitle => 'Cvorum (opțional)';

  @override
  String get createPollQuorumSubtitle => 'Dacă este setat, Vote este considerat valid numai dacă este atins cel puțin acest număr de voturi. Lasă necompletat pentru fără cvorum.';

  @override
  String get createPollQuorumMinVotesFieldLabel => 'Număr minim de voturi';

  @override
  String get createPollTimingTitle => 'Programare';

  @override
  String get createPollTimingSubtitle => 'Definește perioada în care Vote trebuie să fie deschis pentru votare.';

  @override
  String get createPollStartDateLabel => 'Data de început';

  @override
  String get createPollEndDateLabel => 'Data de încheiere';

  @override
  String get createPollChangeDateButtonLabel => 'Schimbă';

  @override
  String get createPollTimingStatusInfo => 'Starea inițială (deschis/programat/închis) va fi determinată automat pe baza acestor date.';

  @override
  String get createPollSuccessMessage => 'Vote creat cu succes';

  @override
  String get createPollSubmitCreatingLabel => 'Se creează...';

  @override
  String get createPollSubmitLabel => 'Creează Vote';

  @override
  String get createPollPollTypeYesNoLabel => 'Da / Nu';

  @override
  String get createPollPollTypeSingleChoiceLabel => 'Un răspuns';

  @override
  String get createPollPollTypeMultipleChoiceLabel => 'Mai multe răspunsuri';

  @override
  String get createPollPollTypeApprovalLabel => 'Vot prin aprobare';

  @override
  String get createPollPollTypeRankedLabel => 'Alegere ordonată';

  @override
  String get createPollPollTypeScoreLabel => 'Scor / Evaluare';

  @override
  String get createPollParticipationScopeEveryoneLabel => 'Toată lumea poate vota';

  @override
  String get createPollParticipationScopeGeoScopeOnlyLabel => 'Doar utilizatorii dintr-o anumită țară';

  @override
  String get createPollAnonymityLevelAnonymousLabel => 'Voturile sunt anonime';

  @override
  String get createPollAnonymityLevelPublicLabel => 'Voturile sunt publice (utilizare avansată / restricționată)';

  @override
  String get createPollResultsVisibilityAlwaysLabel => 'Vizibile întotdeauna (cât timp Vote este deschis)';

  @override
  String get createPollResultsVisibilityAfterVoteLabel => 'Vizibile numai după votare';

  @override
  String get createPollResultsVisibilityAfterCloseLabel => 'Vizibile numai după închiderea Vote';

  @override
  String get homeLoginButton => 'Autentificare';

  @override
  String get homeRegisterButton => 'Înregistrare';

  @override
  String get homeProfileButton => 'Profil';

  @override
  String get homeLogoutButton => 'Deconectare';

  @override
  String get homeLogoutMessage => 'Deconectare finalizată. Acum folosești aplicația ca oaspete (doar citire).';

  @override
  String get homeSearchHint => 'Caută orașe, țări, conturi și conținut...';

  @override
  String get searchPageTitle => 'Căutare';

  @override
  String get searchInputHint => 'Caută conturi, Vote, News, Voce...';

  @override
  String get searchClearTooltip => 'Șterge căutarea';

  @override
  String get searchTypeAll => 'Toate';

  @override
  String get searchTypePolls => 'Vote';

  @override
  String get searchTypeNews => 'News';

  @override
  String get searchTypePosts => 'Voce';

  @override
  String get searchTypeAccounts => 'Conturi';

  @override
  String get searchSortHottest => 'Cele mai populare';

  @override
  String get searchSortLatest => 'Cele mai recente';

  @override
  String get searchPollStatusAll => 'Toate Vote';

  @override
  String get searchPollStatusOpen => 'Deschis';

  @override
  String get searchPollStatusClosed => 'Închis';

  @override
  String get searchIdleMessage => 'Introdu un termen pentru a începe căutarea.';

  @override
  String get searchErrorMessage => 'A apărut o problemă în timpul căutării.';

  @override
  String get searchRetryButton => 'Încearcă din nou';

  @override
  String get searchEmptyMessage => 'Nu s-au găsit rezultate pentru această căutare.';

  @override
  String get searchContentUnavailable => 'Conținut indisponibil';

  @override
  String get searchResultTypePoll => 'Vote';

  @override
  String get searchResultTypeNews => 'News';

  @override
  String get searchResultTypePost => 'Voce';

  @override
  String get searchResultTypeAccount => 'Cont';

  @override
  String get searchResultTypeMixed => 'Mixt';

  @override
  String homeUserStatusLoggedIn(Object userId) {
    return 'Autentificat ca: $userId';
  }

  @override
  String get homeUserStatusGuest => 'Mod oaspete: poți doar să citești. Autentifică-te sau înregistrează-te pentru a vota, comenta și reacționa.';

  @override
  String get homeScopeLabelWorld => 'Lume – voturi și știri globale';

  @override
  String get homeScopeLabelCountry => 'Țară – voturi și știri naționale';

  @override
  String get homeScopeLabelCity => 'Oraș – voturi și știri locale';

  @override
  String get homeScopeShortWorld => 'Lume';

  @override
  String get homeScopeShortCountry => 'Țară';

  @override
  String get homeScopeShortCity => 'Oraș';

  @override
  String get homeScopeChipWorld => 'Lume';

  @override
  String get homeScopeChipItaly => 'Italia';

  @override
  String get homeScopeChipTorino => 'Torino';

  @override
  String get homeScopeChangedWorld => 'Zona a fost schimbată la Lume';

  @override
  String get homeScopeChangedItaly => 'Zona a fost schimbată la Italia';

  @override
  String get homeScopeChangedTorino => 'Zona a fost schimbată la Torino';

  @override
  String get followScopeButtonFollowed => 'Urmărită';

  @override
  String get followScopeButtonFollow => 'Urmărește această zonă';

  @override
  String get homeTrendingTitle => 'Pulse acum';

  @override
  String get homeTrendingError => 'Nu s-a putut încărca Pulse acum pentru această zonă.';

  @override
  String get homeTrendingEmpty => 'Nu există conținut în Pulse acum pentru această zonă în acest moment.';

  @override
  String homeForYouTitle(Object scope) {
    return 'Pulse ($scope)';
  }

  @override
  String get homeForYouError => 'Nu s-a putut încărca Pulse pentru această zonă.';

  @override
  String get homeForYouEmpty => 'Nu există conținut sugerat în Pulse pentru această zonă în acest moment.';

  @override
  String homePollsTitle(Object scope) {
    return 'Vote în prim-plan ($scope)';
  }

  @override
  String get homePollsEmptyTitle => 'Niciun Vote pentru această zonă';

  @override
  String get homePollsEmptySubtitle => 'Nu există Vote disponibile pentru această zonă.';

  @override
  String get homePollsViewAllButton => 'Vezi Vote';

  @override
  String homeNewsTitle(Object scope) {
    return 'News principale ($scope)';
  }

  @override
  String get homeNewsErrorTitle => 'Nu s-au putut încărca News';

  @override
  String get homeNewsErrorSubtitle => 'A apărut o problemă la încărcarea News pentru această zonă.';

  @override
  String get homeNewsEmptyTitle => 'Nicio News pentru această zonă';

  @override
  String get homeNewsEmptySubtitle => 'Nu există elemente News pentru acest domeniu în acest moment.';

  @override
  String get homeNewsViewAllButton => 'Vezi toate News';

  @override
  String get homeNewsBreakingBadge => 'ULTIMA ORĂ';

  @override
  String homeSocialTitle(Object scope) {
    return 'Voce ($scope)';
  }

  @override
  String get homeSocialErrorTitle => 'Nu s-a putut încărca Voce';

  @override
  String get homeSocialErrorSubtitle => 'A apărut o problemă la încărcarea Voce pentru această zonă.';

  @override
  String get homeSocialEmptyTitle => 'Nicio Voce pentru această zonă';

  @override
  String get homeSocialEmptySubtitle => 'Nu există conținut Voce pentru această zonă în acest moment.';

  @override
  String get homeSocialViewFeedButton => 'Vezi toate Voce';

  @override
  String get pollDetail_title => 'Detalii Vote';

  @override
  String get pollDetail_removeFromFavoritesTooltip => 'Elimină din salvate';

  @override
  String get pollDetail_addToFavoritesTooltip => 'Salvează';

  @override
  String get pollDetail_chipAnonymous => 'Vote anonim';

  @override
  String get pollDetail_chipPublic => 'Vote public';

  @override
  String get pollDetail_chipRestrictedGeo => 'Restricționat la domeniul geografic';

  @override
  String pollDetail_quorumReached(int currentVotes, int requiredVotes) {
    return 'Cvorum atins ($currentVotes / $requiredVotes)';
  }

  @override
  String pollDetail_quorumNotReached(int currentVotes, int requiredVotes) {
    return 'Cvorum neatins ($currentVotes / $requiredVotes)';
  }

  @override
  String get pollDetail_optionsTitle => 'Opțiuni';

  @override
  String get pollDetail_statusClosedMessage => 'Acest Vote este închis.';

  @override
  String get pollDetail_statusScheduledMessage => 'Acest Vote nu este încă deschis.';

  @override
  String get pollDetail_statusNotAvailableMessage => 'Votarea nu este disponibilă.';

  @override
  String get pollDetail_voteSubmitted => 'Vot trimis cu succes!';

  @override
  String get pollDetail_voteButton => 'Votează';

  @override
  String get pollDetail_resultsTitle => 'Rezultate';

  @override
  String pollDetail_outcomePrefix(Object label) {
    return 'Rezultat: $label';
  }

  @override
  String get pollDetail_noResults => 'Nu există încă rezultate disponibile.';

  @override
  String get pollDetail_resultsAfterVote => 'Rezultatele vor fi vizibile după ce votezi.';

  @override
  String get pollDetail_resultsWhenClosed => 'Rezultatele vor fi vizibile când Vote se închide.';

  @override
  String get pollType_yesNo => 'Da / Nu';

  @override
  String get pollType_singleChoice => 'Alegere unică';

  @override
  String get pollType_multipleChoice => 'Alegere multiplă';

  @override
  String get pollType_approval => 'Aprobare';

  @override
  String get pollStatus_draft => 'Ciornă';

  @override
  String get pollStatus_open => 'Deschis';

  @override
  String get pollStatus_closed => 'Închis';

  @override
  String get pollStatus_scheduled => 'Programat';

  @override
  String get pollGeo_global => 'Global';

  @override
  String get pollGeo_local => 'Local';

  @override
  String get pollOutcome_approved => 'Aprobat';

  @override
  String get pollOutcome_rejected => 'Respins';

  @override
  String get pollOutcome_tie => 'Egalitate';

  @override
  String get pollOutcome_noMajority => 'Fără majoritate';

  @override
  String get pollOutcome_notApplicable => 'Nu se aplică';

  @override
  String get pollList_title => 'Vote';

  @override
  String get pollList_scopeWorld => 'Lume';

  @override
  String get pollList_scopeCountryFallback => 'Țară';

  @override
  String get pollList_scopeCityFallback => 'Oraș';

  @override
  String get pollList_scopeDescriptionGlobal => 'Se afișează Vote globale.';

  @override
  String get pollList_scopeDescriptionCountry => 'Se afișează Vote pentru această țară.';

  @override
  String get pollList_scopeDescriptionCity => 'Se afișează Vote pentru acest oraș.';

  @override
  String get pollList_filterStatus_all => 'Toate';

  @override
  String get pollList_filterStatus_open => 'Deschise';

  @override
  String get pollList_filterStatus_closed => 'Închise';

  @override
  String get pollList_sort_latest => 'Cele mai recente';

  @override
  String get pollList_sort_hottest => 'Cele mai populare';

  @override
  String get pollList_filterScope_currentArea => 'Zona curentă';

  @override
  String pollList_headerTitle(Object scopeLabel, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Vote găsite',
      one: '1 Vote găsit',
      zero: 'niciun Vote găsit',
    );
    return '$scopeLabel · $_temp0';
  }

  @override
  String get pollList_createPollButton => 'Creează Vote';

  @override
  String get pollList_paginationHint => 'Derulează pentru a încărca mai multe Vote…';

  @override
  String get pollList_emptyMessage => 'Niciun Vote care să corespundă acestui filtru pentru această zonă.';

  @override
  String get pollType_ranked => 'Alegere ordonată';

  @override
  String get pollType_score => 'Vot prin scor';

  @override
  String get pollVisibility_whileOpen => 'Rezultate vizibile cât timp este deschis';

  @override
  String get pollVisibility_afterVote => 'Rezultate vizibile după vot';

  @override
  String get pollVisibility_afterClose => 'Rezultate vizibile după închidere';

  @override
  String get pollCard_countryRestricted => 'Restricționat la țară';

  @override
  String pollCard_restrictedToCountry(Object countryName) {
    return 'Restricționat la $countryName';
  }

  @override
  String pollCard_quorumLabel(int minVotes) {
    return 'Cvorum $minVotes';
  }

  @override
  String get pollCard_resultsVisibleChip => 'Rezultate vizibile';

  @override
  String get pollCard_resultsAfterVoteChip => 'După vot';

  @override
  String get pollCard_resultsAfterCloseChip => 'După închidere';

  @override
  String get pollCard_publicOfficialPublisher => 'Oficial public';

  @override
  String get pollCard_institutionPublisher => 'Instituție';

  @override
  String get pollCard_representativePublisher => 'Reprezentant';

  @override
  String pollCard_voteCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'voturi',
      one: 'vot',
    );
    return '$_temp0';
  }

  @override
  String get pollCard_viewDetails => 'Vezi detaliile';

  @override
  String pollResult_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rezultate ($count voturi)',
      one: 'Rezultate (1 vot)',
      zero: 'Rezultate (fără voturi)',
    );
    return '$_temp0';
  }

  @override
  String get voteError_noSelection => 'Selectează cel puțin o opțiune.';

  @override
  String get voteError_unauthorized => 'Nu ai permisiunea să votezi în acest Vote.';

  @override
  String get voteError_generic => 'Trimiterea votului a eșuat. Încearcă din nou.';

  @override
  String get commentSection_title => 'Comentarii';

  @override
  String get commentSection_sortLabel => 'Sortare:';

  @override
  String get commentSection_sortOldest => 'Cele mai vechi';

  @override
  String get commentSection_sortNewest => 'Cele mai noi';

  @override
  String get commentSection_errorGeneric => 'A apărut o eroare la încărcarea comentariilor.';

  @override
  String get commentSection_empty => 'Nu există încă comentarii. Fii primul care comentează.';

  @override
  String get commentSection_loadMore => 'Încarcă mai multe comentarii';

  @override
  String commentSection_replyingTo(Object snippet) {
    return 'Răspuns la: $snippet';
  }

  @override
  String get commentSection_cancelReply => 'Anulează';

  @override
  String get commentSection_inputHintRoot => 'Adaugă un comentariu...';

  @override
  String get commentSection_inputHintReply => 'Scrie un răspuns...';

  @override
  String get commentSection_deleteAction => 'Șterge';

  @override
  String get commentSection_replyAction => 'Răspunde';

  @override
  String get commentSection_youBadge => 'Tu';

  @override
  String get newsDetail_title => 'Detalii News';

  @override
  String get newsDetail_breakingBadge => 'ULTIMA ORĂ';

  @override
  String get newsDetail_removeFromFavoritesTooltip => 'Elimină din salvate';

  @override
  String get newsDetail_addToFavoritesTooltip => 'Salvează';

  @override
  String get newsDetail_bodyFallback => 'Nu este disponibil niciun text suplimentar pentru această News.';

  @override
  String get newsDetail_footerMoreContext => 'Mai mult context și mai multe surse vor fi disponibile în curând.';

  @override
  String get newsFeed_title => 'News';

  @override
  String get newsFeed_scopeWorld => 'Lume';

  @override
  String get newsFeed_scopeCountry => 'Țară';

  @override
  String get newsFeed_scopeCity => 'Oraș';

  @override
  String newsFeed_scopeLabel(Object scope) {
    return 'Domeniu: $scope';
  }

  @override
  String get newsFeed_scopeGlobalDescription => 'Se afișează News globale.';

  @override
  String get newsFeed_scopeCountryDescription => 'Se afișează News pentru această țară.';

  @override
  String get newsFeed_scopeCityDescription => 'Se afișează News pentru acest oraș.';

  @override
  String get newsFeed_emptyTitle => 'Nu există News disponibile pentru această zonă.';

  @override
  String get newsFeed_emptySubtitle => 'Trage pentru reîmprospătare sau încearcă din nou mai târziu.';

  @override
  String newsFeed_itemsFound(int count) {
    return '$count element(e) News găsit(e)';
  }

  @override
  String get newsFeed_loadingMoreHint => 'Derulează pentru a încărca mai multe News…';

  @override
  String get newsFeed_errorTitle => 'Nu s-au putut încărca News';

  @override
  String get newsFeed_errorGeneric => 'A apărut o eroare neașteptată la încărcarea News.';

  @override
  String get newsFeed_retryButton => 'Reîncearcă';

  @override
  String get newsCard_headerTitle => 'News';

  @override
  String get newsFeed_errorUnauthorized => 'Configurația News nu este validă (cheie API).';

  @override
  String get newsFeed_errorRateLimited => 'Prea multe solicitări. Încearcă din nou în curând.';

  @override
  String get newsFeed_errorServerUnavailable => 'Serviciul News este temporar indisponibil. Încearcă din nou mai târziu.';

  @override
  String get newsFeed_errorTimeout => 'Solicitarea durează prea mult. Încearcă din nou.';

  @override
  String get newsFeed_errorNetwork => 'Fără conexiune. Verifică internetul și încearcă din nou.';

  @override
  String get newsFeed_moreTooltip => 'Mai multe';

  @override
  String get newsFeed_actionCopyTitle => 'Copiază titlul';

  @override
  String get newsFeed_actionRefreshFeed => 'Reîmprospătează fluxul';

  @override
  String get newsFeed_copiedTitleToast => 'Titlu copiat';

  @override
  String get newsFeed_languageTooltip => 'Limba News';

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
  String get newsFeed_languageLimitedHint => 'Surse limitate în această limbă. Încearcă AUTO.';

  @override
  String get newsTopic_all => 'Toate';

  @override
  String get newsTopic_world => 'Lume';

  @override
  String get newsTopic_nation => 'Național';

  @override
  String get newsTopic_business => 'Afaceri';

  @override
  String get newsTopic_technology => 'Tehnologie';

  @override
  String get newsTopic_science => 'Știință';

  @override
  String get newsTopic_health => 'Sănătate';

  @override
  String get newsTopic_sports => 'Sport';

  @override
  String get newsTopic_entertainment => 'Divertisment';

  @override
  String get newsDetail_openSource => 'Deschide articolul sursă';

  @override
  String get newsDetail_openSourceUnavailable => 'Articolul sursă nu poate fi deschis';

  @override
  String get socialFeedTitle => 'Voce';

  @override
  String get socialFeedCreatePostButton => 'Creează Voce';

  @override
  String get commonCancelButton => 'Anulează';

  @override
  String get commonApplyButton => 'Aplică';

  @override
  String get homeScopeChooseCountry => 'Alege țara';

  @override
  String get homeScopeCountrySearchHint => 'Caută țară sau cod...';

  @override
  String get homeScopeChooseCity => 'Alege orașul';

  @override
  String homeScopeCountryWithCode(String code) {
    return 'Țară: $code';
  }

  @override
  String get homeScopeCityFieldLabel => 'Oraș';

  @override
  String get homeScopeCityExampleHint => 'Introdu un oraș, de ex. Merano';

  @override
  String get homeScopeCityRequiredError => 'Introdu un oraș.';

  @override
  String get homeScopeCityNotFoundError => 'Orașul nu a fost găsit în țara selectată.';

  @override
  String get homeScopeCityVerificationError => 'Orașul nu a putut fi verificat. Încearcă din nou.';

  @override
  String get homeScopeVerifyingButton => 'Se verifică...';

  @override
  String get homeMapOpenButton => 'Deschide harta';

  @override
  String get homeHeroHeadline => 'Modelați viitorul.\nÎmpreună.';

  @override
  String get homeHeroPollsAction => 'Vote';

  @override
  String get homeHeroNewsAction => 'News';

  @override
  String get homeHeroCreateAction => 'Creează';

  @override
  String get homeHeroExploreAction => 'Explorează';

  @override
  String get homeAccountMenuLabel => 'Cont';

  @override
  String get homeThemeSystemMenuItem => 'Temă: sistem';

  @override
  String get homeThemeLightMenuItem => 'Temă: deschisă';

  @override
  String get homeThemeDarkMenuItem => 'Temă: întunecată';

  @override
  String get profileAppLanguageTitle => 'Limba aplicației';

  @override
  String get profileAppLanguageSystem => 'Sistem';

  @override
  String get profileAppLanguageSystemDescription => 'Folosește limba dispozitivului';

  @override
  String get profileAppLanguageItalian => 'Italiană';

  @override
  String get profileAppLanguageEnglish => 'Engleză';

  @override
  String get homeNotificationsTooltip => 'Notificări';

  @override
  String get postCard_authorFallback => 'Autor';

  @override
  String get postCard_globalLocation => 'Global';

  @override
  String get commonSaveButton => 'Salvează';

  @override
  String get commonDeleteButton => 'Șterge';

  @override
  String get contentReport_menuAction => 'Raportează conținutul';

  @override
  String get contentReport_dialogTitle => 'Raportează conținutul';

  @override
  String get contentReport_authenticationRequired => 'Trebuie să fii autentificat pentru a raporta conținutul';

  @override
  String get contentReport_submittedMessage => 'Raport trimis';

  @override
  String get contentReport_alreadySubmittedMessage => 'Ai raportat deja acest conținut';

  @override
  String get contentReport_submitError => 'Raportul nu a putut fi trimis';

  @override
  String get contentReport_sendButton => 'Trimite';

  @override
  String get contentReport_reasonSpam => 'Spam';

  @override
  String get contentReport_reasonHarassment => 'Hărțuire sau abuz';

  @override
  String get contentReport_reasonHateSpeech => 'Discurs instigator la ură';

  @override
  String get contentReport_reasonMisinformation => 'Dezinformare';

  @override
  String get contentReport_reasonViolence => 'Violență';

  @override
  String get contentReport_reasonOther => 'Altul';

  @override
  String get postDetail_title => 'Detalii Voce';

  @override
  String get postDetail_favoriteUpdateError => 'Elementele salvate nu au putut fi actualizate';

  @override
  String get postDetail_shareMessage => 'Deschide Social Vote pentru a vedea această Voce.';

  @override
  String get postDetail_shareError => 'Voce nu a putut fi distribuită';

  @override
  String get postDetail_editDialogTitle => 'Editează Voce';

  @override
  String get postDetail_editTitleFieldLabel => 'Titlu';

  @override
  String get postDetail_editContentFieldLabel => 'Conținut';

  @override
  String get postDetail_editRequiredError => 'Titlul și conținutul sunt obligatorii.';

  @override
  String get postDetail_updateSuccess => 'Voce actualizată';

  @override
  String get postDetail_updateError => 'Voce nu a putut fi actualizată';

  @override
  String get postDetail_deleteDialogTitle => 'Ștergi această Voce?';

  @override
  String get postDetail_deleteDialogMessage => 'Această acțiune nu poate fi anulată.';

  @override
  String get postDetail_deleteError => 'Voce nu a putut fi ștearsă';

  @override
  String get postDetail_editMenuItem => 'Editează Voce';

  @override
  String get postDetail_deleteMenuItem => 'Șterge Voce';

  @override
  String get postDetail_loadError => 'A apărut o eroare la încărcarea Voce.';

  @override
  String get postDetail_notFound => 'Voce nu a fost găsită.';

  @override
  String get postDetail_errorTitle => 'Eroare';

  @override
  String get postDetail_authorFallback => 'Autor';

  @override
  String get postDetail_shareAction => 'Distribuie';

  @override
  String get postDetail_saveAction => 'Salvează';

  @override
  String get postDetail_addToFavoritesTooltip => 'Salvează';

  @override
  String get postDetail_removeFromFavoritesTooltip => 'Elimină din salvate';

  @override
  String get newsDetail_favoriteUpdateError => 'Elementele salvate nu au putut fi actualizate';

  @override
  String get newsDetail_shareMessage => 'Deschide Social Vote pentru a vedea această News.';

  @override
  String get newsDetail_shareError => 'News nu a putut fi distribuită';

  @override
  String get newsDetail_shareTooltip => 'Distribuie';

  @override
  String get authLoginPageTitle => 'Autentificare';

  @override
  String get authLoginHeadline => 'Bine ai revenit';

  @override
  String get authEmailLabel => 'E-mail';

  @override
  String get authPasswordLabel => 'Parolă';

  @override
  String get authRememberMeLabel => 'Ține-mă minte';

  @override
  String get authForgotPasswordAction => 'Ai uitat parola?';

  @override
  String get authLoginButton => 'Autentificare';

  @override
  String get authRegisterPrompt => 'Nu ai un cont?';

  @override
  String get authRegisterAction => 'Înregistrează-te';

  @override
  String get authRegisterPageTitle => 'Înregistrare';

  @override
  String get authRegisterHeadline => 'Creează un cont';

  @override
  String get authPersonalAccountOwnershipTitle => 'Autentificarea aparține întotdeauna unei persoane';

  @override
  String get authPersonalAccountOwnershipBody => 'Dacă reprezinți o organizație, creează-ți contul personal. După autentificare, poți solicita o Organizație verificată și o poți gestiona din Workspace.';

  @override
  String get authOrganizationPathAction => 'Cum funcționează pentru organizații';

  @override
  String get authDisplayNameLabel => 'Nume public';

  @override
  String get authUsernameLabel => 'Nume de utilizator';

  @override
  String get authCountryOfResidenceLabel => 'Țara de reședință';

  @override
  String get authCityOfResidenceLabel => 'Oraș de reședință (opțional)';

  @override
  String get authConfirmPasswordLabel => 'Confirmă parola';

  @override
  String get authLegalConsentPrefix => 'Confirm că am cel puțin 18 ani. Accept Termenii și condițiile și confirm că am citit Politica de confidențialitate.';

  @override
  String get authTermsOfServiceAction => 'Termenii și condițiile';

  @override
  String get authPrivacyPolicyAction => 'Politica de confidențialitate';

  @override
  String get authRegisterButton => 'Înregistrează-te';

  @override
  String get authLoginPrompt => 'Ai deja un cont?';

  @override
  String get authLoginAction => 'Autentificare';

  @override
  String get authForgotPasswordDialogTitle => 'Resetează parola';

  @override
  String get authForgotPasswordDialogBody => 'Introdu adresa de e-mail asociată contului. Îți vom trimite un link pentru a alege o parolă nouă.';

  @override
  String get authForgotPasswordSendButton => 'Trimite linkul';

  @override
  String get authPasswordResetEmailSent => 'E-mailul pentru resetarea parolei a fost trimis. Verifică inboxul.';

  @override
  String get authResetPasswordPageTitle => 'Resetare parolă';

  @override
  String get authResetPasswordHeadline => 'Alege o parolă nouă';

  @override
  String get authNewPasswordLabel => 'Parolă nouă';

  @override
  String get authConfirmNewPasswordLabel => 'Confirmă parola nouă';

  @override
  String get authUpdatePasswordButton => 'Actualizează parola';

  @override
  String get authPasswordUpdated => 'Parola a fost actualizată cu succes.';

  @override
  String get authEmailConfirmationTitle => 'Verifică e-mailul';

  @override
  String get authEmailConfirmationIntro => 'Am trimis un link de confirmare la:';

  @override
  String get authEmailConfirmationInstructions => 'Deschide linkul din mesaj pentru a-ți verifica adresa. După confirmare, revino în aplicație și autentifică-te.';

  @override
  String get authBackToLoginButton => 'Înapoi la autentificare';

  @override
  String get authUseAnotherEmailButton => 'Folosește o altă adresă de e-mail';

  @override
  String get authEmailRequiredError => 'Introdu adresa de e-mail.';

  @override
  String get authEmailInvalidError => 'Introdu o adresă de e-mail validă.';

  @override
  String get authPasswordRequiredError => 'Introdu parola.';

  @override
  String get authPasswordTooShortError => 'Parola trebuie să aibă cel puțin 8 caractere.';

  @override
  String get authDisplayNameRequiredError => 'Introdu numele public.';

  @override
  String get authDisplayNameTooShortError => 'Numele public este prea scurt.';

  @override
  String get authUsernameRequiredError => 'Introdu un nume de utilizator.';

  @override
  String get authUsernameInvalidError => 'Folosește între 3 și 20 de caractere: litere mici, cifre și underscore.';

  @override
  String get authUsernameAlreadyTakenError => 'Numele de utilizator este deja folosit.';

  @override
  String get authCountryRequiredError => 'Selectează țara de reședință.';

  @override
  String get authCityRequiredError => 'Introdu orașul de reședință.';

  @override
  String get authConfirmPasswordRequiredError => 'Confirmă parola.';

  @override
  String get authPasswordsDoNotMatchError => 'Parolele nu coincid.';

  @override
  String get authLegalConsentRequiredError => 'Pentru a te înregistra, confirmă că ai cel puțin 18 ani, acceptă Termenii și condițiile și confirmă că ai citit Politica de confidențialitate.';

  @override
  String get authForgotPasswordEmailRequiredError => 'Introdu e-mailul contului pe care vrei să-l recuperezi.';

  @override
  String get authInvalidCredentialsError => 'E-mailul sau parola nu este validă.';

  @override
  String get authEmailAlreadyRegisteredError => 'Această adresă de e-mail este deja înregistrată.';

  @override
  String get authEmailNotConfirmedError => 'E-mail neconfirmat. Verifică inboxul înainte de autentificare.';

  @override
  String get authTooManyAttemptsError => 'Prea multe încercări. Așteaptă câteva minute și încearcă din nou.';

  @override
  String get authNetworkError => 'Eroare de rețea. Verifică conexiunea și încearcă din nou.';

  @override
  String get authLoginGenericError => 'Autentificarea a eșuat. Încearcă din nou.';

  @override
  String get authRegisterGenericError => 'Înregistrarea a eșuat. Încearcă din nou.';

  @override
  String get authPasswordResetGenericError => 'Linkul de resetare nu a putut fi trimis. Încearcă din nou.';

  @override
  String get authPasswordUpdateGenericError => 'Parola nu a putut fi actualizată. Încearcă din nou.';

  @override
  String get authShowPasswordTooltip => 'Afișează parola';

  @override
  String get authHidePasswordTooltip => 'Ascunde parola';

  @override
  String get authTermsPageTitle => 'Termeni și condiții';

  @override
  String get authPrivacyPageTitle => 'Politica de confidențialitate';

  @override
  String get authCloseButton => 'Închide';

  @override
  String get pollDetail_favoriteUpdateError => 'Elementele salvate nu au putut fi actualizate';

  @override
  String get pollDetail_shareMessage => 'Deschide Social Vote pentru a vedea și a vota în acest Vote.';

  @override
  String get pollDetail_shareError => 'Vote nu a putut fi distribuit';

  @override
  String get pollDetail_editPermissionError => 'Poți edita doar propriile Vote fără voturi înregistrate';

  @override
  String get pollDetail_editSuccessMessage => 'Vote actualizat';

  @override
  String get pollDetail_editMenuItem => 'Editează Vote';

  @override
  String get pollDetail_editSavingMenuItem => 'Se salvează...';

  @override
  String get pollDetail_deletePermissionError => 'Poți șterge doar propriile Vote';

  @override
  String get pollDetail_deleteError => 'Vote nu a putut fi șters';

  @override
  String get pollDetail_deleteDialogTitle => 'Șterge Vote';

  @override
  String pollDetail_deleteDialogMessage(String title) {
    return 'Sigur vrei să ștergi „$title”? Această acțiune nu poate fi anulată.';
  }

  @override
  String get pollDetail_deleteMenuItem => 'Șterge Vote';

  @override
  String get pollDetail_deleteDeletingMenuItem => 'Se șterge...';

  @override
  String get pollDetail_publicVotesAvailableTitle => 'Voturi publice disponibile';

  @override
  String get pollDetail_publicVotesAvailableMessage => 'Acest Vote îți permite să vezi cine a votat pentru fiecare opțiune.';

  @override
  String get pollDetail_publicVotesAction => 'Vezi voturile publice';

  @override
  String get pollDetail_retryButton => 'Încearcă din nou';

  @override
  String get pollDetail_voteErrorNoOption => 'Selectează cel puțin o opțiune';

  @override
  String get pollDetail_voteErrorAuthenticationRequired => 'Trebuie să fii autentificat pentru a vota';

  @override
  String get pollDetail_voteErrorClosed => 'Acest Vote este închis';

  @override
  String get pollDetail_voteErrorAlreadyVoted => 'Ai votat deja în acest Vote';

  @override
  String get pollDetail_voteErrorGeneric => 'Votul nu a putut fi trimis';

  @override
  String get pollDetail_publicVotesSheetTitle => 'Voturi publice';

  @override
  String get pollDetail_publicVotesSheetDescription => 'Aici poți vedea cine a votat pentru fiecare opțiune din acest Vote.';

  @override
  String get pollDetail_publicVotesSearchHint => 'Caută utilizatori';

  @override
  String get pollDetail_publicVotesLoadError => 'Voturile publice nu au putut fi încărcate';

  @override
  String get pollDetail_publicVotesEmpty => 'Nu există voturi publice disponibile';

  @override
  String get pollDetail_publicVotesSearchEmpty => 'Nu s-au găsit utilizatori pentru această căutare';

  @override
  String pollDetail_publicVotesResultsCount(int count) {
    return '$count rezultate încărcate';
  }

  @override
  String get pollDetail_publicVotesLoadMore => 'Încarcă mai multe';

  @override
  String get pollDetail_publicVotesUserFallback => 'Utilizator';

  @override
  String get pollDetail_editDialogTitle => 'Editează Vote';

  @override
  String get pollDetail_editTitleFieldLabel => 'Titlu';

  @override
  String get pollDetail_editTitleRequired => 'Titlul este obligatoriu';

  @override
  String get pollDetail_editDescriptionFieldLabel => 'Descriere';

  @override
  String get pollDetail_editError => 'Vote nu a putut fi actualizat';

  @override
  String get pollDetail_loadError => 'Vote nu a putut fi încărcat';

  @override
  String get pollDetail_notFound => 'Vote nu a fost găsit';

  @override
  String get profileEditPageTitle => 'Editează profilul';

  @override
  String get profileLoginRequiredMessage => 'Trebuie să fii autentificat pentru a-ți edita profilul.';

  @override
  String get profileAvatarUploading => 'Se încarcă...';

  @override
  String get profileUploadAvatarButton => 'Încarcă avatar';

  @override
  String get profileDisplayNameLabel => 'Nume afișat';

  @override
  String get profileDisplayNameRequiredError => 'Numele afișat este obligatoriu.';

  @override
  String get profileUsernameHint => 'ex. mario_roma';

  @override
  String get profileUsernameHelper => '3–20 de caractere: litere mici, cifre și underscore';

  @override
  String get profileAvatarUrlLabel => 'URL avatar';

  @override
  String get profileBioLabel => 'Bio';

  @override
  String get profileClearCountryButton => 'Șterge țara';

  @override
  String get profileCityResidenceHelper => 'Orașul de reședință este verificat în raport cu țara selectată înainte de salvare.';

  @override
  String get profileCityNotFoundError => 'Orașul nu a fost găsit în țara selectată.';

  @override
  String get profileCityVerificationError => 'Orașul nu poate fi verificat acum.';

  @override
  String get profileAvatarUploadError => 'Avatarul nu a putut fi încărcat.';

  @override
  String get profileAccountSectionTitle => 'Cont';

  @override
  String get profileAccountEmailHelper => 'Adresa de e-mail a contului nu poate fi schimbată din acest ecran.';

  @override
  String get profileChangePasswordAction => 'Schimbă parola';

  @override
  String get profileChangePasswordDescription => 'Setează o parolă nouă pentru acest cont.';

  @override
  String get notificationsPageTitle => 'Notificări';

  @override
  String get notificationsMarkAllReadAction => 'Marchează toate ca citite';

  @override
  String get notificationsNoTargetMessage => 'Această notificare nu are o destinație disponibilă.';

  @override
  String get notificationsTargetUnavailableMessage => 'Conținutul asociat acestei notificări este indisponibil.';

  @override
  String get notificationsLoadError => 'Notificările nu au putut fi încărcate.';

  @override
  String get notificationsRetryButton => 'Încearcă din nou';

  @override
  String get notificationsEmptyMessage => 'Nu există notificări disponibile.';

  @override
  String get notificationsCommentReplyTitle => 'Răspuns nou la comentariul tău';

  @override
  String get notificationsMentionTitle => 'Ai fost menționat';

  @override
  String get notificationsPollResultTitle => 'Actualizare Vote';

  @override
  String notificationsCommentReplySubtitle(String actor, String target) {
    return 'Utilizatorul $actor a răspuns în $target';
  }

  @override
  String notificationsMentionSubtitle(String actor, String target) {
    return 'Utilizatorul $actor te-a menționat în $target';
  }

  @override
  String notificationsPollResultSubtitle(String target) {
    return 'Un rezultat nou este disponibil în $target';
  }

  @override
  String get notificationsTargetPost => 'o Voce';

  @override
  String get notificationsTargetNews => 'un articol News';

  @override
  String get notificationsTargetPoll => 'un Vote';

  @override
  String get notificationsTargetVideo => 'un videoclip';

  @override
  String get notificationsTargetContent => 'un conținut';

  @override
  String get notificationsUserFallback => 'utilizator';

  @override
  String get profileDeleteAccountAction => 'Șterge contul';

  @override
  String get profileDeleteAccountDescription => 'Șterge definitiv contul și accesul';

  @override
  String get profileDeleteAccountDialogTitle => 'Șterge contul';

  @override
  String get profileDeleteAccountDialogMessage => 'Această acțiune este permanentă. Contul nu poate fi recuperat. Scrie DELETE pentru confirmare.';

  @override
  String get profileDeleteAccountConfirmationLabel => 'Confirmarea ștergerii';

  @override
  String get profileDeleteAccountConfirmationHint => 'Scrie DELETE';

  @override
  String get profileDeleteAccountConfirmationError => 'Scrie DELETE pentru a continua.';

  @override
  String get profileDeleteAccountCancelButton => 'Anulează';

  @override
  String get profileDeleteAccountConfirmButton => 'Șterge definitiv';

  @override
  String get profileDeleteAccountFailureMessage => 'Contul nu a putut fi șters. Încearcă din nou.';

  @override
  String get identityActorTypePerson => 'Persoană';

  @override
  String get identityActorTypePublicOfficial => 'Oficial public';

  @override
  String get identityActorTypePublicInstitution => 'Instituție publică';

  @override
  String get identityActorTypeVerifiedOrganization => 'Organizație verificată';

  @override
  String get identityVerificationNotVerified => 'Neverificat';

  @override
  String get identityVerificationLevel1 => 'Identitate verificată';

  @override
  String get identityVerificationLevel2 => 'Identitate verificată avansată';

  @override
  String get identityBadgeLevel1 => 'Identitate verificată';

  @override
  String get identityBadgeLevel2 => 'Identitate verificată avansată';

  @override
  String get identityBadgePublicOfficial => 'Oficial public';

  @override
  String get identityBadgePublicInstitution => 'Instituție publică';

  @override
  String get identityBadgeVerifiedOrganization => 'Organizație verificată';

  @override
  String get identityOrganizationNameLabel => 'Numele organizației';

  @override
  String get identityOrganizationNameRequired => 'Introdu numele organizației.';

  @override
  String get identityInstitutionLevelMunicipality => 'Municipal';

  @override
  String get identityInstitutionLevelProvince => 'Provincial';

  @override
  String get identityInstitutionLevelRegion => 'Regional';

  @override
  String get identityInstitutionLevelMinistry => 'Minister';

  @override
  String get identityInstitutionLevelGovernment => 'Guvern';

  @override
  String get identityInstitutionLevelPublicAgency => 'Agenție publică';

  @override
  String get identityInstitutionLevelOtherPublicBody => 'Alt organism public';

  @override
  String get verificationRequestPersonLevel1 => 'Verificare persoană — Nivel 1';

  @override
  String get verificationRequestPersonLevel2 => 'Verificare persoană — Nivel 2';

  @override
  String get verificationRequestPublicOfficial => 'Verificare oficial public';

  @override
  String get verificationRequestPublicInstitution => 'Verificare instituție publică';

  @override
  String get verificationRequestVerifiedOrganization => 'Verificare organizație';

  @override
  String get verificationCenterTitle => 'Verificare și tip de cont';

  @override
  String get verificationCurrentAccountSection => 'Cont curent';

  @override
  String verificationAccountTypeValue(String accountType) {
    return 'Tip cont: $accountType';
  }

  @override
  String verificationLevelValue(String level) {
    return 'Nivel de verificare: $level';
  }

  @override
  String verificationOfficialTitleValue(String title) {
    return 'Titlu oficial: $title';
  }

  @override
  String verificationInstitutionNameValue(String name) {
    return 'Instituție: $name';
  }

  @override
  String verificationOrganizationNameValue(String name) {
    return 'Organizație: $name';
  }

  @override
  String verificationInstitutionLevelValue(String level) {
    return 'Nivel instituție: $level';
  }

  @override
  String get verificationActiveRequestSection => 'Cerere activă';

  @override
  String get verificationProfileUnchangedUntilApproval => 'Profilul tău actual nu se va modifica până când cererea nu este aprobată.';

  @override
  String get verificationCancelPendingAction => 'Anulează cererea în așteptare';

  @override
  String get verificationPendingBlocksNewRequests => 'Nu poți trimite o cerere nouă cât timp există o altă cerere în așteptare.';

  @override
  String get verificationNoActiveRequestSection => 'Nicio cerere activă';

  @override
  String get verificationNoActiveRequestDescription => 'În prezent nu ai nicio cerere în curs de examinare.';

  @override
  String get verificationLastRejectedSection => 'Ultima cerere respinsă';

  @override
  String get verificationLastRejectedDescription => 'Ultima ta cerere a fost respinsă.';

  @override
  String get verificationRejectedCanResubmit => 'Profilul tău actual nu s-a schimbat. Poți corecta informațiile și trimite o cerere nouă.';

  @override
  String get verificationAvailableRequestsSection => 'Cereri disponibile';

  @override
  String get verificationRequestLevel1Title => 'Solicită verificarea persoanei — Nivel 1';

  @override
  String get verificationRequestLevel1Subtitle => 'Verificare de bază a identității personale';

  @override
  String get verificationRequestLevel2Title => 'Solicită verificarea persoanei — Nivel 2';

  @override
  String get verificationRequestLevel2Subtitle => 'Verificare avansată a identității personale';

  @override
  String get verificationRequestPublicOfficialTitle => 'Solicită un cont de Oficial public';

  @override
  String get verificationRequestPublicOfficialSubtitle => 'Necesită un titlu oficial și verificare';

  @override
  String get verificationRequestPublicInstitutionTitle => 'Solicită un cont de Instituție publică';

  @override
  String get verificationRequestPublicInstitutionSubtitle => 'Necesită numele instituției, nivelul instituției și verificare';

  @override
  String get verificationRequestOrganizationTitle => 'Solicită un cont de Organizație verificată';

  @override
  String get verificationRequestOrganizationSubtitle => 'Necesită detalii despre organizație, rolul reprezentantului și verificare Admin';

  @override
  String get verificationNoSelfServiceUpgrade => 'Nu există opțiuni de verificare disponibile pentru starea actuală a contului tău.';

  @override
  String get verificationRequestSubmitSuccess => 'Cererea a fost trimisă cu succes.';

  @override
  String get verificationRequestSubmitFailure => 'Cererea nu a putut fi trimisă.';

  @override
  String get verificationOfficialTitleDialogTitle => 'Verificare oficial public';

  @override
  String get verificationOfficialTitleLabel => 'Titlu oficial';

  @override
  String get verificationOfficialTitleHint => 'ex. Primar, Consilier, Ministru';

  @override
  String get verificationInstitutionDialogTitle => 'Verificare instituție publică';

  @override
  String get verificationInstitutionNameLabel => 'Numele instituției';

  @override
  String get verificationInstitutionNameHint => 'ex. Primăria Romei';

  @override
  String get verificationInstitutionLevelLabel => 'Nivelul instituției';

  @override
  String get verificationOrganizationDialogTitle => 'Verificare organizație';

  @override
  String get verificationOrganizationNameHint => 'ex. Asociația Mediu Italia';

  @override
  String get verificationSubmitRequestAction => 'Trimite cererea';

  @override
  String get verificationCancelDialogTitle => 'Anulează cererea';

  @override
  String get verificationCancelDialogBody => 'Sigur vrei să anulezi cererea de verificare în așteptare?';

  @override
  String get verificationCancelSuccess => 'Cerere anulată.';

  @override
  String get verificationCancelFailure => 'Cererea nu a putut fi anulată.';

  @override
  String get verificationStatusPendingSuffix => 'cerere în curs de examinare';

  @override
  String get verificationStatusRejectedSuffix => 'ultima cerere respinsă';

  @override
  String get verificationReviewPageTitle => 'Revizuire verificări';

  @override
  String get verificationReviewLoginRequired => 'Trebuie să te autentifici pentru a revizui cererile de verificare.';

  @override
  String verificationReviewPendingCount(int count) {
    return 'Cereri în așteptare: $count';
  }

  @override
  String get verificationReviewNoPendingRequests => 'Nu există cereri de verificare în așteptare.';

  @override
  String get verificationReviewUserIdLabel => 'ID utilizator';

  @override
  String get verificationReviewSubmittedLabel => 'Trimisă';

  @override
  String get verificationReviewOfficialTitleLabel => 'Titlu oficial';

  @override
  String get verificationReviewInstitutionLabel => 'Instituție';

  @override
  String get verificationReviewOrganizationLabel => 'Organizație';

  @override
  String get verificationReviewNoteLabel => 'Notă de revizuire';

  @override
  String get verificationReviewRejectAction => 'Respinge';

  @override
  String get verificationReviewApproveAction => 'Aprobă';

  @override
  String get verificationReviewApproveDialogTitle => 'Aprobă cererea';

  @override
  String get verificationReviewRejectDialogTitle => 'Respinge cererea';

  @override
  String get verificationReviewApproveConfirmation => 'Confirmi aprobarea acestei cereri?';

  @override
  String get verificationReviewRejectConfirmation => 'Confirmi respingerea acestei cereri?';

  @override
  String get verificationReviewOptionalNoteLabel => 'Notă opțională de revizuire';

  @override
  String get verificationReviewRequiredNoteLabel => 'Motivul respingerii';

  @override
  String get verificationReviewOptionalHelper => 'Opțional';

  @override
  String get verificationReviewRequiredHelper => 'Obligatoriu la respingere';

  @override
  String get verificationReviewRequiredNoteError => 'Introdu motivul respingerii.';

  @override
  String get verificationReviewApprovedSuccess => 'Cerere aprobată.';

  @override
  String get verificationReviewRejectedSuccess => 'Cerere respinsă.';

  @override
  String get verificationReviewOperationFailure => 'Operațiunea a eșuat.';

  @override
  String get adminCenterTitle => 'Centru Admin';

  @override
  String get adminCenterDashboardNavigation => 'Panou de control';

  @override
  String get adminCenterUsersNavigation => 'Utilizatori';

  @override
  String get adminCenterVerificationNavigation => 'Verificare';

  @override
  String get adminCenterReportsNavigation => 'Raportări';

  @override
  String get adminCenterAuditNavigation => 'Audit';

  @override
  String get adminCenterAccountDetailsTitle => 'Detalii cont';

  @override
  String get adminCenterTryAgainAction => 'Încearcă din nou';

  @override
  String get adminCenterRetryAction => 'Reîncearcă';

  @override
  String get adminCenterClearAction => 'Șterge';

  @override
  String get adminCenterApplyFiltersAction => 'Aplică filtrele';

  @override
  String get adminCenterAllDates => 'Toate datele';

  @override
  String get adminCenterAuditDateFilterHelp => 'Filtrează auditul după dată';

  @override
  String get adminCenterActorUserIdLabel => 'ID utilizator actor';

  @override
  String get adminCenterActionLabel => 'Acțiune';

  @override
  String get adminCenterAuditActionHint => 'resolve_escalated_report';

  @override
  String get adminCenterTargetIdLabel => 'ID țintă';

  @override
  String get adminCenterOutcomeLabel => 'Rezultat';

  @override
  String get adminCenterAllOutcomes => 'Toate rezultatele';

  @override
  String get adminCenterOutcomeSuccess => 'Succes';

  @override
  String get adminCenterOutcomeFailure => 'Eșec';

  @override
  String get adminCenterOutcomeDenied => 'Refuzat';

  @override
  String get adminCenterOutcomeNoChange => 'Fără modificări';

  @override
  String get adminCenterOutcomeUnknown => 'Necunoscut';

  @override
  String get adminCenterAuditUnavailableTitle => 'Audit indisponibil';

  @override
  String get adminCenterAuditUnavailableMessage => 'Verifică conexiunea și permisiunile, apoi încearcă din nou.';

  @override
  String get adminCenterNoAuditEntriesTitle => 'Nicio înregistrare de audit';

  @override
  String get adminCenterNoAuditEntriesMessage => 'Nu există înregistrări care să corespundă filtrelor selectate.';

  @override
  String get adminCenterAuditIdLabel => 'ID audit';

  @override
  String get adminCenterActorLabel => 'Actor';

  @override
  String get adminCenterReasonLabel => 'Motiv';

  @override
  String get adminCenterTimestampLabel => 'Marcaj temporal';

  @override
  String get adminCenterErrorLabel => 'Eroare';

  @override
  String get adminCenterRecordedValuesTitle => 'Valori înregistrate';

  @override
  String get adminCenterPreviousValueLabel => 'Anterior';

  @override
  String get adminCenterNewValueLabel => 'Nou';

  @override
  String get adminCenterContentTypeLabel => 'Tip de conținut';

  @override
  String get adminCenterAllContent => 'Tot conținutul';

  @override
  String get adminCenterPolls => 'Vote';

  @override
  String get adminCenterPosts => 'Voce';

  @override
  String get adminCenterNews => 'News';

  @override
  String get adminCenterAwaitingAdminDecision => 'În așteptarea unei decizii Admin';

  @override
  String get adminCenterStatusLabel => 'Stare';

  @override
  String get adminCenterAllStatuses => 'Toate stările';

  @override
  String get adminCenterStatusOpen => 'Deschis';

  @override
  String get adminCenterStatusInReview => 'În curs de examinare';

  @override
  String get adminCenterStatusResolved => 'Rezolvat';

  @override
  String get adminCenterStatusDismissed => 'Respins';

  @override
  String get adminCenterAdminQueueUnavailableTitle => 'Coada de escaladare Admin este indisponibilă';

  @override
  String get adminCenterReportsUnavailableTitle => 'Raportări indisponibile';

  @override
  String get adminCenterConnectionTryAgainMessage => 'Verifică conexiunea și încearcă din nou.';

  @override
  String get adminCenterNoAdminReportsTitle => 'Nicio raportare în așteptarea deciziei Admin';

  @override
  String get adminCenterNoReportsTitle => 'Nicio raportare';

  @override
  String get adminCenterNoAdminReportsMessage => 'Nu există raportări escaladate care necesită examinarea unui administrator.';

  @override
  String get adminCenterNoReportsMessage => 'Nu există raportări care să corespundă filtrelor selectate.';

  @override
  String get adminCenterSearchUsersHint => 'Caută după nume, nume de utilizator, e-mail sau ID';

  @override
  String get adminCenterClearSearchTooltip => 'Șterge căutarea';

  @override
  String get adminCenterUsersUnavailableTitle => 'Utilizatori indisponibili';

  @override
  String get adminCenterNoUsersFoundTitle => 'Nu s-au găsit utilizatori';

  @override
  String get adminCenterNoUsersTitle => 'Niciun utilizator';

  @override
  String get adminCenterNoUsersFoundMessage => 'Încearcă un alt nume, nume de utilizator, e-mail sau ID.';

  @override
  String get adminCenterNoUsersMessage => 'Nu există conturi de afișat.';

  @override
  String get adminCenterAccountUnavailableTitle => 'Cont indisponibil';

  @override
  String get adminCenterBackToUsersAction => 'Înapoi la utilizatori';

  @override
  String get adminCenterPublicIdentitySection => 'Identitate publică';

  @override
  String get adminCenterDisplayNameLabel => 'Nume afișat';

  @override
  String get adminCenterNotProvided => 'Nefurnizat';

  @override
  String get adminCenterUsernameLabel => 'Nume de utilizator';

  @override
  String get adminCenterUserIdLabel => 'ID utilizator';

  @override
  String get adminCenterIdentityTypeLabel => 'Tip de identitate';

  @override
  String get adminCenterAccountSection => 'Cont';

  @override
  String get adminCenterTechnicalRoleLabel => 'Rol tehnic';

  @override
  String get adminCenterRoleMirrorLabel => 'Oglindire rol profil';

  @override
  String get adminCenterRoleSynchronizationLabel => 'Sincronizare roluri';

  @override
  String get adminCenterSynchronized => 'Sincronizat';

  @override
  String get adminCenterNotSynchronized => 'Nesincronizat';

  @override
  String get adminCenterRoleNotSynchronized => 'Rol nesincronizat';

  @override
  String get adminCenterAccountStatusLabel => 'Starea contului';

  @override
  String get adminCenterSuspendedUntilLabel => 'Suspendat până la';

  @override
  String get adminCenterAccountManagementSection => 'Administrarea contului';

  @override
  String get adminCenterDangerZoneSection => 'Zonă periculoasă';

  @override
  String get adminCenterRoleManagementSection => 'Gestionarea rolurilor';

  @override
  String get adminCenterVerificationLevelLabel => 'Nivel de verificare';

  @override
  String get adminCenterVerificationStatusLabel => 'Starea verificării';

  @override
  String get adminCenterAccessInformationSection => 'Informații de acces';

  @override
  String get adminCenterEmailLabel => 'E-mail';

  @override
  String get adminCenterNotAvailable => 'Indisponibil';

  @override
  String get adminCenterEmailConfirmationLabel => 'Confirmare e-mail';

  @override
  String get adminCenterNotConfirmed => 'Neconfirmat';

  @override
  String get adminCenterRegisteredLabel => 'Înregistrat';

  @override
  String get adminCenterLastAccessLabel => 'Ultimul acces';

  @override
  String get adminCenterLoadingDashboardTitle => 'Se încarcă panoul de control';

  @override
  String get adminCenterLoadingDashboardMessage => 'Se preiau cei mai recenți indicatori.';

  @override
  String get adminCenterDashboardUnavailableTitle => 'Panou de control indisponibil';

  @override
  String get adminCenterIndicatorsUnavailableMessage => 'Indicatorii nu au putut fi încărcați.';

  @override
  String get adminCenterVerificationPendingIndicator => 'Verificări în așteptare';

  @override
  String get adminCenterOpenReportsIndicator => 'Raportări deschise';

  @override
  String get adminCenterSuspendedAccountsIndicator => 'Conturi suspendate';

  @override
  String get adminCenterStaffIndicator => 'Personal';

  @override
  String get adminCenterNoPendingWorkTitle => 'Nicio activitate în așteptare';

  @override
  String get adminCenterNoPendingWorkMessage => 'Verificările, raportările și conturile suspendate sunt la zi.';

  @override
  String get adminCenterCouldNotUpdateUsers => 'Lista utilizatorilor nu a putut fi actualizată.';

  @override
  String get adminCenterCouldNotUpdateReports => 'Coada de raportări nu a putut fi actualizată.';

  @override
  String get adminCenterUnnamedUser => 'Utilizator fără nume';

  @override
  String get adminCenterTemporarySuspensionTitle => 'Suspendare temporară';

  @override
  String get adminCenterReactivateDescription => 'Elimină imediat suspendarea și permite o nouă autentificare.';

  @override
  String get adminCenterSuspendDescription => 'Blochează accesul pentru o perioadă limitată și încheie toate sesiunile curente.';

  @override
  String get adminCenterSuspensionUnavailableDescription => 'Suspendarea necesită un cont sincronizat care nu este Admin.';

  @override
  String get adminCenterReactivateAccountAction => 'Reactivează contul';

  @override
  String get adminCenterSuspendAccountAction => 'Suspendă contul';

  @override
  String get adminCenterForceLogoutAction => 'Forțează deconectarea';

  @override
  String get adminCenterSuspendedForceLogoutDescription => 'Suspendarea a încheiat deja sesiunile curente. Reactivează contul înainte de a testa o deconectare separată.';

  @override
  String get adminCenterForceLogoutDescription => 'Încheie toate sesiunile curente fără a suspenda contul.';

  @override
  String get adminCenterForceLogoutUnavailableDescription => 'Deconectarea forțată necesită un cont sincronizat care nu este Admin.';

  @override
  String get adminCenterPermanentDeletionTitle => 'Ștergere permanentă a contului';

  @override
  String get adminCenterPermanentDeletionDescription => 'Șterge datele de autentificare, încheie toate sesiunile și anonimizează înregistrarea publică păstrată.';

  @override
  String get adminCenterDeletionUnavailableDescription => 'Ștergerea necesită un cont sincronizat care nu este Admin.';

  @override
  String get adminCenterDeleteAccountPermanentlyAction => 'Șterge definitiv contul';

  @override
  String get adminCenterDurationOneHour => '1 oră';

  @override
  String get adminCenterDurationOneDay => '24 de ore';

  @override
  String get adminCenterDurationSevenDays => '7 zile';

  @override
  String get adminCenterDurationThirtyDays => '30 de zile';

  @override
  String get adminCenterSuspendImmediateEffect => 'Contul va pierde accesul imediat și toate sesiunile curente vor fi încheiate.';

  @override
  String get adminCenterDurationLabel => 'Durată';

  @override
  String get adminCenterSuspendReasonHint => 'Explică de ce trebuie suspendat acest cont';

  @override
  String get adminCenterReactivateReasonHint => 'Explică de ce poate fi reactivat acest cont';

  @override
  String get adminCenterReactivateConfirmation => 'Confirm că acest cont poate redobândi accesul.';

  @override
  String get adminCenterReactivateFailure => 'Contul nu a putut fi reactivat. Verifică rolul și starea, apoi încearcă din nou.';

  @override
  String get adminCenterReactivateSuccess => 'Cont reactivat. O nouă autentificare este acum permisă.';

  @override
  String get adminCenterForceLogoutFullDescription => 'Încheie toate sesiunile curente ale acestui cont. Contul rămâne activ și se poate autentifica din nou.';

  @override
  String get adminCenterForceLogoutReasonHint => 'Explică de ce trebuie încheiate sesiunile curente';

  @override
  String get adminCenterForceLogoutConfirmation => 'Confirm încheierea imediată a tuturor sesiunilor curente pentru acest cont.';

  @override
  String get adminCenterForceLogoutFailure => 'Contul nu a putut fi deconectat. Verifică rolul și starea, apoi încearcă din nou.';

  @override
  String get adminCenterForceLogoutSuccess => 'Sesiunile curente au fost încheiate. Contul se poate autentifica din nou.';

  @override
  String get adminCenterSuspendFailure => 'Contul nu a putut fi suspendat. Verifică rolul și starea, apoi încearcă din nou.';

  @override
  String get adminCenterDeleteReasonHint => 'Explică de ce trebuie șters acest cont';

  @override
  String get adminCenterTypeDeleteLabel => 'Scrie DELETE';

  @override
  String get adminCenterTypeAccountIdLabel => 'Scrie ID-ul complet al contului';

  @override
  String get adminCenterDeletePermanentlyAction => 'Șterge definitiv';

  @override
  String get adminCenterDeleteIrreversibleWarning => 'Această acțiune este ireversibilă. Datele de autentificare și sesiunile curente vor fi eliminate, avatarul va fi șters, iar înregistrarea publică păstrată va fi anonimizată. Jurnalul de audit va rămâne.';

  @override
  String get adminCenterDeleteFailure => 'Contul nu a putut fi șters. Verifică rolul, starea și valorile de confirmare, apoi încearcă din nou.';

  @override
  String get adminCenterDeleteSuccess => 'Cont șters definitiv, iar datele personale au fost anonimizate.';

  @override
  String get adminCenterChangeTechnicalRoleTitle => 'Schimbă rolul tehnic';

  @override
  String get adminCenterChangeRoleDescription => 'Verifică rolul curent și rolul solicitat înainte de confirmare.';

  @override
  String get adminCenterChangeRoleUnavailableDescription => 'Schimbările de rol necesită un cont sincronizat și neșters.';

  @override
  String get adminCenterChangeRoleAction => 'Schimbă rolul';

  @override
  String get adminCenterChangePublicIdentityTitle => 'Schimbă identitatea publică';

  @override
  String get adminCenterChangeIdentityDescription => 'Actualizează tipul de cont public și nivelul de verificare.';

  @override
  String get adminCenterChangeIdentityUnavailableDescription => 'Schimbările de identitate necesită un cont sincronizat care nu este Admin.';

  @override
  String get adminCenterChangeIdentityAction => 'Schimbă identitatea';

  @override
  String get adminCenterChoosePublicIdentityMessage => 'Alege tipul de cont public și starea sa de verificare.';

  @override
  String get adminCenterPublicAccountTypeLabel => 'Tip de cont public';

  @override
  String get adminCenterPersonVerificationHelper => 'Nivelurile 1 și 2 sunt disponibile numai pentru Persona.';

  @override
  String get adminCenterNonPersonVerificationHelper => 'Conturile non-Persona nu folosesc Nivelul 1 sau Nivelul 2.';

  @override
  String get adminCenterBeforeLabel => 'Înainte';

  @override
  String get adminCenterAfterLabel => 'După';

  @override
  String get adminCenterIdentityReasonHint => 'Explică de ce trebuie schimbată identitatea publică';

  @override
  String get adminCenterIdentityConfirmation => 'Confirm identitatea publică și nivelul de verificare afișate mai sus.';

  @override
  String get adminCenterIdentityChangeFailure => 'Identitatea publică nu a putut fi schimbată. Verifică starea contului și încearcă din nou.';

  @override
  String get adminCenterChooseTechnicalRoleMessage => 'Alege noul rol tehnic și notează de ce este necesară această schimbare.';

  @override
  String get adminCenterNewTechnicalRoleLabel => 'Rol tehnic nou';

  @override
  String get adminCenterSelectRole => 'Selectează un rol';

  @override
  String get adminCenterRoleSessionWarning => 'Această schimbare încheie sesiunea activă a destinatarului. Va trebui să se autentifice din nou înainte de a continua să folosească contul.';

  @override
  String get adminCenterRoleReasonHint => 'Explică de ce trebuie schimbat rolul tehnic';

  @override
  String get adminCenterRoleConfirmation => 'Confirm rolul afișat mai sus și înțeleg că destinatarul trebuie să se autentifice din nou.';

  @override
  String get adminCenterRoleChangeFailure => 'Schimbarea rolului nu a putut fi finalizată. Verifică starea contului și încearcă din nou.';

  @override
  String get adminCenterChangingRole => 'Se schimbă rolul';

  @override
  String get adminCenterConfirmRoleChange => 'Confirmă schimbarea rolului';

  @override
  String get adminCenterRoleUser => 'Utilizator';

  @override
  String get adminCenterRoleModerator => 'Moderator';

  @override
  String get adminCenterRoleAdmin => 'Admin';

  @override
  String get adminCenterAccountStatusActive => 'Activ';

  @override
  String get adminCenterAccountStatusSuspended => 'Suspendat';

  @override
  String get adminCenterAccountStatusDeleted => 'Șters';

  @override
  String get adminCenterVerificationStatusNone => 'Niciuna';

  @override
  String get adminCenterVerificationStatusPending => 'În așteptare';

  @override
  String get adminCenterVerificationStatusRejected => 'Respins';

  @override
  String get adminCenterVerificationNotVerified => 'Neverificat';

  @override
  String get adminCenterVerificationLevel1 => 'Nivel 1';

  @override
  String get adminCenterVerificationLevel2 => 'Nivel 2';

  @override
  String get adminCenterReportSingular => 'raportare';

  @override
  String get adminCenterReportPlural => 'raportări';

  @override
  String get adminCenterUserSingular => 'utilizator';

  @override
  String get adminCenterUserPlural => 'utilizatori';

  @override
  String get adminCenterPoll => 'Vote';

  @override
  String get adminCenterPost => 'Voce';

  @override
  String get adminCenterUnknown => 'Necunoscut';

  @override
  String get adminCenterContentHidden => 'Conținut ascuns';

  @override
  String get adminCenterContentVisible => 'Conținut vizibil';

  @override
  String get adminCenterReportedByLabel => 'Raportat de';

  @override
  String get adminCenterContentOwnerLabel => 'Proprietarul conținutului';

  @override
  String get adminCenterReviewReportAction => 'Revizuiește raportarea';

  @override
  String get adminCenterAdminDecisionAction => 'Decizie Admin';

  @override
  String get adminCenterRestoreContentAction => 'Restaurează conținutul';

  @override
  String get adminCenterHideContentAction => 'Ascunde conținutul';

  @override
  String get adminCenterOpenProfileAction => 'Deschide profilul';

  @override
  String get adminCenterOpenContentAction => 'Deschide conținutul';

  @override
  String get adminCenterDecisionNoViolation => 'Nicio încălcare';

  @override
  String get adminCenterDecisionViolationConfirmed => 'Încălcare confirmată';

  @override
  String get adminCenterDecisionEscalateToAdmin => 'Escaladează către Admin';

  @override
  String get adminCenterResolutionNoAccountAction => 'Nicio acțiune asupra contului';

  @override
  String get adminCenterResolutionAccountSuspended => 'Cont suspendat';

  @override
  String get adminCenterResolutionLogoutForced => 'Deconectare forțată';

  @override
  String get adminCenterResolutionAccountDeleted => 'Cont șters';

  @override
  String get adminCenterReviewerLabel => 'Evaluator';

  @override
  String get adminCenterDecisionDescriptionNoViolation => 'Respinge raportarea deoarece conținutul nu încalcă regulile actuale.';

  @override
  String get adminCenterDecisionDescriptionViolation => 'Confirmă o încălcare și menține cazul în examinare pentru acțiunea asupra conținutului gestionată în AC8.5.';

  @override
  String get adminCenterDecisionDescriptionEscalation => 'Escaladează cazul pentru o revizuire la nivel de cont de către un administrator.';

  @override
  String get adminCenterChooseModerationOutcome => 'Alege rezultatul moderării pentru această raportare.';

  @override
  String get adminCenterDecisionAlreadyRecordedFailure => 'Decizia nu a putut fi înregistrată. Raportarea poate fi deja revizuită. Reîmprospătează coada și încearcă din nou.';

  @override
  String get adminCenterDecisionLabel => 'Decizie';

  @override
  String get adminCenterReportReasonLabel => 'Motivul raportării';

  @override
  String get adminCenterReviewNoteLabel => 'Notă de revizuire';

  @override
  String get adminCenterReviewNoteHint => 'Explică dovezile și decizia de moderare';

  @override
  String get adminCenterRecordingDecision => 'Se înregistrează decizia';

  @override
  String get adminCenterConfirmDecision => 'Confirmă decizia';

  @override
  String get adminCenterAdministratorDecisionTitle => 'Decizia administratorului';

  @override
  String get adminCenterResolutionDescriptionNoAction => 'Închide raportarea escaladată fără a modifica contul.';

  @override
  String get adminCenterResolutionDescriptionSuspended => 'Închide raportarea după ce o suspendare reușită a contului a fost deja înregistrată în jurnalul de audit.';

  @override
  String get adminCenterResolutionDescriptionLogout => 'Închide raportarea după ce o deconectare forțată reușită a fost deja înregistrată în jurnalul de audit.';

  @override
  String get adminCenterResolutionDescriptionDeleted => 'Închide raportarea după ce o ștergere reușită a contului a fost deja înregistrată în jurnalul de audit.';

  @override
  String get adminCenterChooseFinalOutcome => 'Alege rezultatul final al administratorului pentru această escaladare.';

  @override
  String get adminCenterAdminResolutionFailure => 'Decizia administratorului nu a putut fi înregistrată. Reîmprospătează coada și încearcă din nou.';

  @override
  String get adminCenterAdminResolutionRequiresAction => 'Finalizează mai întâi acțiunea corespunzătoare asupra contului, apoi revino la această raportare și înregistrează decizia finală a administratorului.';

  @override
  String get adminCenterEscalationNoteLabel => 'Notă de escaladare';

  @override
  String get adminCenterFinalOutcomeLabel => 'Rezultat final';

  @override
  String get adminCenterAdministratorNoteLabel => 'Nota administratorului';

  @override
  String get adminCenterAdministratorNoteHint => 'Explică decizia finală la nivelul contului';

  @override
  String get adminCenterHideContentFailure => 'Conținutul nu a putut fi ascuns. Reîmprospătează coada de raportări și încearcă din nou.';

  @override
  String get adminCenterRestoreContentFailure => 'Conținutul nu a putut fi restaurat. Reîmprospătează coada de raportări și încearcă din nou.';

  @override
  String get adminCenterHideContentWarning => 'Aceasta elimină conținutul raportat din accesul public. Acțiunea poate fi inversată ulterior din filtrul raportărilor rezolvate.';

  @override
  String get adminCenterRestoreContentWarning => 'Aceasta face din nou conținutul raportat disponibil public.';

  @override
  String get adminCenterActionReasonLabel => 'Motivul acțiunii';

  @override
  String get adminCenterHideContentReasonHint => 'Explică de ce trebuie ascuns conținutul';

  @override
  String get adminCenterRestoreContentReasonHint => 'Explică de ce poate fi restaurat conținutul';

  @override
  String get adminCenterHidingContent => 'Se ascunde conținutul';

  @override
  String get adminCenterRestoringContent => 'Se restaurează conținutul';

  @override
  String get adminCenterReportedProfileTitle => 'Profil raportat';

  @override
  String get adminCenterReportedProfileNotice => 'Acest context de profil provine din coada protejată de raportări. Acțiunile administrative asupra contului rămân separate.';

  @override
  String get adminCenterCouldNotRefreshIndicators => 'Indicatorii nu au putut fi reîmprospătați.';

  @override
  String get adminCenterCouldNotRefreshAccount => 'Detaliile contului nu au putut fi reîmprospătate.';

  @override
  String get adminCenterReportAlreadyReviewed => 'Această raportare a fost deja revizuită sau nu mai este în așteptare.';

  @override
  String get adminCenterReportNotAwaitingAdmin => 'Această raportare nu așteaptă o decizie a administratorului.';

  @override
  String get adminCenterConfirmedViolationRequired => 'Este necesară o încălcare confirmată înainte de a modifica vizibilitatea conținutului.';

  @override
  String get adminCenterContentHiddenSuccess => 'Conținutul raportat a fost ascuns.';

  @override
  String get adminCenterContentRestoredSuccess => 'Conținutul raportat a fost restaurat.';

  @override
  String get adminCenterMissingContentId => 'Identificatorul conținutului original lipsește.';

  @override
  String get adminCenterUnsupportedTargetType => 'Această raportare are un tip de țintă nesuportat.';

  @override
  String get adminCenterOriginalContentUnavailable => 'Conținutul original nu mai este disponibil.';

  @override
  String get adminCenterNoReportedProfile => 'Niciun profil raportat nu este asociat cu acest conținut.';

  @override
  String adminCenterRoleChangedSuccess(String previousRole, String newRole) {
    return 'Rolul tehnic a fost schimbat din $previousRole în $newRole. Destinatarul a fost deconectat și trebuie să se autentifice din nou.';
  }

  @override
  String adminCenterIdentityChangedSuccess(String actorType, String verificationLevel) {
    return 'Identitatea publică a fost schimbată în $actorType cu $verificationLevel.';
  }

  @override
  String adminCenterAccountSuspendedSuccess(String dateTime) {
    return 'Cont suspendat până la $dateTime. Destinatarul a fost deconectat.';
  }

  @override
  String adminCenterReportDecisionRecorded(String decision) {
    return 'Decizia raportării a fost înregistrată: $decision.';
  }

  @override
  String adminCenterAdministratorDecisionRecorded(String decision) {
    return 'Decizia administratorului a fost înregistrată: $decision.';
  }

  @override
  String adminCenterUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count utilizatori',
      one: '$count utilizator',
    );
    return '$_temp0';
  }

  @override
  String adminCenterReportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count raportări',
      one: '$count raportare',
    );
    return '$_temp0';
  }

  @override
  String adminCenterAccountValue(String account) {
    return 'Cont: $account';
  }

  @override
  String adminCenterSuspendedUntilValue(String dateTime) {
    return 'Suspendat până la: $dateTime';
  }

  @override
  String adminCenterSuspendConfirmation(String dateTime) {
    return 'Confirm suspendarea până la $dateTime și încheierea imediată a sesiunilor curente.';
  }

  @override
  String adminCenterAccountIdValue(String accountId) {
    return 'ID cont: $accountId';
  }

  @override
  String adminCenterCurrentRoleValue(String role) {
    return 'Curent: $role';
  }

  @override
  String adminCenterTargetFallback(String targetType, String targetId) {
    return '$targetType $targetId';
  }

  @override
  String adminCenterMinimumCharactersRequired(int count) {
    return 'Este necesară o notă de cel puțin $count caractere.';
  }

  @override
  String adminCenterMinimumReasonCharactersRequired(int count) {
    return 'Este necesar un motiv de cel puțin $count caractere.';
  }

  @override
  String adminCenterPageOf(int currentPage, int totalPages) {
    return 'Pagina $currentPage din $totalPages';
  }

  @override
  String get profilePublicProfileSectionTitle => 'Profil public';

  @override
  String get profileIdentityVerificationSectionTitle => 'Identitate și verificare';

  @override
  String get profilePreferencesSectionTitle => 'Preferințe';

  @override
  String get profileNotificationsSectionTitle => 'Notificări';

  @override
  String get profileActivitySectionTitle => 'Activitate personală';

  @override
  String get profileSecurityAccountSectionTitle => 'Securitate și cont';

  @override
  String get profileThemeTitle => 'Temă';

  @override
  String get profileThemeSystem => 'Sistem';

  @override
  String get profileThemeSystemDescription => 'Urmează tema dispozitivului';

  @override
  String get profileThemeLight => 'Deschis';

  @override
  String get profileThemeDark => 'Întunecat';

  @override
  String get profileMyPollsTitle => 'Vote';

  @override
  String get profileMyPostsTitle => 'Voce';

  @override
  String get profileMyCommentsTitle => 'Comentariile mele';

  @override
  String get profileMyFavoritesTitle => 'Elementele mele salvate';

  @override
  String get profileAccountConnectionsTitle => 'Urmăriri și urmăritori';

  @override
  String get accountConnectionsFollowingTab => 'Urmărești';

  @override
  String get accountConnectionsFollowersTab => 'Urmăritori';

  @override
  String get accountConnectionsEmptyFollowing => 'Nu urmărești încă niciun cont.';

  @override
  String get accountConnectionsEmptyFollowers => 'Nu ai încă urmăritori.';

  @override
  String get accountConnectionsLoadError => 'Conturile nu au putut fi încărcate. Încearcă din nou.';

  @override
  String get profileMyFollowedScopesTitle => 'Zonele mele urmărite';

  @override
  String get profileLogoutAction => 'Deconectare';

  @override
  String get profileLogoutDescription => 'Ieși din contul curent';

  @override
  String get profileLogoutDialogTitle => 'Deconectare';

  @override
  String get profileLogoutDialogMessage => 'Sigur vrei să te deconectezi din cont?';

  @override
  String get profileLogoutCancelButton => 'Anulează';

  @override
  String get profileLogoutConfirmButton => 'Deconectare';

  @override
  String get publicProfilePageTitle => 'Profil public';

  @override
  String get publicProfileUserFallback => 'Utilizator';

  @override
  String get publicProfileNoBio => 'Nicio biografie disponibilă.';

  @override
  String get publicProfileResidenceLabel => 'Reședință';

  @override
  String get publicProfileResidenceUnknown => 'Nespecificat';

  @override
  String get publicProfileMemberSinceLabel => 'Membru din';

  @override
  String get publicProfileContentSectionTitle => 'Conținut public';

  @override
  String get publicProfilePollsAction => 'Vote';

  @override
  String get publicProfilePostsAction => 'Voce';

  @override
  String get publicProfileBlockUserAction => 'Blochează utilizatorul';

  @override
  String get publicProfileLoadError => 'Profilul nu a putut fi încărcat.';

  @override
  String get publicProfileNotFound => 'Profil indisponibil.';

  @override
  String get publicProfileUnblockUserAction => 'Deblochează utilizatorul';

  @override
  String get publicProfileBlockDialogTitle => 'Blochezi acest utilizator?';

  @override
  String get publicProfileBlockDialogMessage => 'Îl poți debloca ulterior din profilul său public.';

  @override
  String get publicProfileUnblockDialogTitle => 'Deblochezi acest utilizator?';

  @override
  String get publicProfileUnblockDialogMessage => 'Utilizatorul nu va mai fi în lista ta de blocare.';

  @override
  String get publicProfileBlockSuccess => 'Utilizator blocat.';

  @override
  String get publicProfileUnblockSuccess => 'Utilizator deblocat.';

  @override
  String get publicProfileBlockError => 'Blocarea nu a putut fi actualizată. Încearcă din nou.';

  @override
  String get publicProfileFollowersLabel => 'urmăritori';

  @override
  String get publicProfileFollowingLabel => 'urmăriri';

  @override
  String get publicProfileFollowAction => 'Urmărește';

  @override
  String get publicProfileUnfollowAction => 'Nu mai urmări';

  @override
  String get publicProfileFollowSuccess => 'Cont urmărit.';

  @override
  String get publicProfileUnfollowSuccess => 'Urmărirea contului a fost oprită.';

  @override
  String get publicProfileFollowError => 'Urmărirea nu a putut fi actualizată. Încearcă din nou.';

  @override
  String get publicProfileFollowRetry => 'Reîncarcă informațiile despre urmărire';

  @override
  String get contentLanguageFieldLabel => 'Limba conținutului';

  @override
  String get contentLanguageFieldHelper => 'Selectează limba în care ai scris conținutul.';

  @override
  String get contentLanguageUndetermined => 'Nespecificat';

  @override
  String get createPollAdvancedOptionsTitle => 'Opțiuni avansate';

  @override
  String get createPollAdvancedOptionsSubtitle => 'Anonimat, vizibilitatea rezultatelor, schimbarea votului și cvorum.';

  @override
  String get onboardingSkipButton => 'Omite';

  @override
  String get onboardingNextButton => 'Următorul';

  @override
  String get onboardingStartButton => 'Începe';

  @override
  String get onboardingPollTitle => 'Vote';

  @override
  String get onboardingPollDescription => 'Participă la un Vote pe teme care te interesează sau creează unul pentru a colecta opinia comunității.';

  @override
  String get onboardingHeatIceTitle => 'Heat și Ice';

  @override
  String get onboardingHeatIceDescription => 'Folosește Heat și Ice pentru a arăta cât de puternic îți atrage atenția un conținut.';

  @override
  String get onboardingCivicMapTitle => 'Civic Map';

  @override
  String get onboardingCivicMapDescription => 'Explorează Vote, Voce și News pe hartă și descoperă ce se întâmplă în diferite zone.';

  @override
  String get onboardingGeoScopeTitle => 'GeoScope';

  @override
  String get onboardingGeoScopeDescription => 'Alege nivelul geografic pe care vrei să-l urmărești: lume, țară sau oraș.';

  @override
  String get onboardingVerificationTitle => 'Verificarea identității';

  @override
  String get onboardingVerificationDescription => 'Unele Vote pot necesita un nivel de verificare pentru a proteja integritatea votării.';

  @override
  String get pollDetail_voteReceiptButton => 'Dovadă de vot';

  @override
  String get pollDetail_voteReceiptTitle => 'Dovadă de vot';

  @override
  String get pollDetail_voteReceiptIdLabel => 'ID dovadă';

  @override
  String get pollDetail_voteReceiptDateLabel => 'Înregistrat';

  @override
  String get pollDetail_voteReceiptPrivacy => 'Această dovadă confirmă că votul tău a fost înregistrat fără a arăta alegerea făcută.';

  @override
  String get pollDetail_voteReceiptCloseButton => 'Închide';

  @override
  String get profileBiometricUnlockTitle => 'Deblocare biometrică';

  @override
  String get profileBiometricUnlockDescription => 'Protejează sesiunea memorată cu amprenta sau recunoașterea biometrică a dispozitivului.';

  @override
  String get profileBiometricRequiresRememberMe => 'Necesită activarea opțiunii Ține-mă minte.';

  @override
  String get profileBiometricUnavailable => 'Biometria este indisponibilă sau neconfigurată pe acest dispozitiv.';

  @override
  String get profileBiometricEnableReason => 'Confirmă biometria pentru a activa deblocarea Social Vote.';

  @override
  String get profileBiometricEnabledMessage => 'Deblocarea biometrică a fost activată.';

  @override
  String get profileBiometricDisabledMessage => 'Deblocarea biometrică a fost dezactivată.';

  @override
  String get profileBiometricAuthFailedMessage => 'Autentificarea biometrică nu a fost finalizată.';

  @override
  String get biometricLockTitle => 'Social Vote este blocat';

  @override
  String get biometricLockMessage => 'Folosește biometria dispozitivului pentru a debloca sesiunea memorată.';

  @override
  String get biometricUnlockButton => 'Deblochează';

  @override
  String get biometricUsePasswordButton => 'Folosește parola';

  @override
  String get biometricUnlockReason => 'Deblochează sesiunea Social Vote.';

  @override
  String get biometricUnlockFailedMessage => 'Deblocarea a eșuat. Încearcă din nou sau folosește parola.';

  @override
  String get adminCenterOperationalActivityTitle => 'Activitate operațională';

  @override
  String get adminCenterOperationalActivitySubtitle => 'Contori agregați. Fără urmărirea în timp real a prezenței online.';

  @override
  String get adminCenterLast24HoursLabel => '24 de ore';

  @override
  String get adminCenterLast7DaysLabel => '7 zile';

  @override
  String get adminCenterNewUsersMetric => 'Înregistrări noi';

  @override
  String get adminCenterRecentSignInsMetric => 'Autentificări recente';

  @override
  String get adminCenterPollsCreatedMetric => 'Vote create';

  @override
  String get adminCenterPostsCreatedMetric => 'Voce create';

  @override
  String get adminCenterAdminActionsMetric => 'Acțiuni Admin';

  @override
  String get authPublicNameHelper => 'Acesta este numele pe care îl vor vedea ceilalți utilizatori. Numele de utilizator este creat automat.';

  @override
  String get adminCenterRefreshMarkersTooltip => 'Reîmprospătează marcajele Globe';

  @override
  String get adminCenterMarkerDensityTitle => 'Densitatea marcajelor lumii';

  @override
  String get adminCenterMarkerDensitySubtitle => 'Controlează bugetul vizual de marcaje al Home Globe fără a modifica coordonatele reale sau clasarea conținutului.';

  @override
  String get adminCenterMarkerDensityEmpty => 'Gol';

  @override
  String get adminCenterMarkerDensityFull => 'Complet';

  @override
  String adminCenterMarkerDensityBudget(int count) {
    return 'Buget Home: $count marcaje';
  }

  @override
  String get adminCenterMarkerDensitySaveError => 'Densitatea marcajelor lumii nu a putut fi salvată.';

  @override
  String get adminCenterMarkerDensityBackendUnavailable => 'Setările backend pentru marcajele lumii nu sunt încă disponibile.';

  @override
  String get adminCenterQuickActionsTitle => 'Acțiuni rapide pentru cont';

  @override
  String get adminCenterModerationSnapshotTitle => 'Instantaneu moderare și activitate';

  @override
  String get adminCenterReportsReceivedMetric => 'Raportări primite';

  @override
  String get adminCenterPendingReportsMetric => 'Raportări în așteptare';

  @override
  String get adminCenterConfirmedViolationsMetric => 'Încălcări confirmate';

  @override
  String get adminCenterReportsFiledMetric => 'Raportări depuse';

  @override
  String get adminCenterCommentsCreatedMetric => 'Comentarii create';

  @override
  String get adminCenterAdminActionsOnAccountMetric => 'Acțiuni Admin asupra contului';

  @override
  String get adminCenterLastReportReceivedLabel => 'Ultima raportare primită';

  @override
  String get adminCenterOpenFullAccountAction => 'Deschide toate controalele contului';

  @override
  String get profileAppLanguageGerman => 'Germană';

  @override
  String get profileAppLanguagePersian => 'Persană';

  @override
  String get discoveryPageTitle => 'Explorează';

  @override
  String get organizationWorkspaceTitle => 'Workspace organizației';

  @override
  String get organizationPilotBannerTitle => 'Pilot gratuit';

  @override
  String get organizationPilotBannerBody => 'Sessions sunt gratuite în perioada pilot. Unele funcții profesionale pot deveni cu plată în viitor; facturarea nu este activă acum.';

  @override
  String get organizationVerifiedLabel => 'Organizație verificată';

  @override
  String get organizationEditProfile => 'Editează profilul organizației';

  @override
  String get organizationCreateSession => 'Session nouă';

  @override
  String get organizationNoSessions => 'Nu există încă Sessions. Creează prima pentru o întâlnire, atelier sau eveniment.';

  @override
  String get organizationSessionsTitle => 'Sessions live';

  @override
  String get organizationRequiresVerificationTitle => 'Este necesară o organizație verificată';

  @override
  String get organizationRequiresVerificationBody => 'Acest Workspace este disponibil doar conturilor aprobate de Social Vote ca organizație verificată.';

  @override
  String get organizationProfileEditorTitle => 'Profilul organizației';

  @override
  String get organizationLegalName => 'Denumire legală';

  @override
  String get organizationPublicName => 'Nume public';

  @override
  String get organizationType => 'Tip organizație';

  @override
  String get organizationCountryCode => 'Cod țară';

  @override
  String get organizationCity => 'Oraș';

  @override
  String get organizationWebsite => 'Site oficial';

  @override
  String get organizationDescription => 'Descriere';

  @override
  String get organizationUploadCover => 'Schimbă coperta';

  @override
  String get organizationUploadLogo => 'Schimbă logo-ul';

  @override
  String get organizationMediaUpdated => 'Imaginea organizației a fost actualizată.';

  @override
  String get organizationNamesRequired => 'Denumirea legală și numele public sunt obligatorii.';

  @override
  String get organizationTypeAssociation => 'Asociație';

  @override
  String get organizationTypeNonprofit => 'Organizație nonprofit';

  @override
  String get organizationTypeCompany => 'Companie';

  @override
  String get organizationTypeCooperative => 'Cooperativă';

  @override
  String get organizationTypeSports => 'Organizație sportivă';

  @override
  String get organizationTypePublicBody => 'Organism public';

  @override
  String get organizationTypeCommittee => 'Comitet / grup';

  @override
  String get organizationTypeOther => 'Altul';

  @override
  String get sessionCreateTitle => 'Creează Live Session';

  @override
  String get sessionTitleLabel => 'Titlul Session';

  @override
  String get sessionExpectedParticipants => 'Participanți estimați';

  @override
  String get sessionAccessMode => 'Acces participanți';

  @override
  String get sessionAccessOpen => 'Anonim deschis';

  @override
  String get sessionAccessOpenHint => 'Oricine are linkul/codul se poate alătura. Prevenirea duplicatelor este de tip best-effort; acest mod nu garantează o persoană = un vot.';

  @override
  String get sessionAccessControlled => 'Anonim controlat';

  @override
  String get sessionAccessControlledHint => 'Folosește Access Passes anonime de unică folosință. Social Vote stochează doar hash-ul Access Pass și nu leagă alegerile din buletin de credențialele participantului.';

  @override
  String get sessionResultsVisibility => 'Vizibilitatea rezultatelor';

  @override
  String get sessionResultsLive => 'Live';

  @override
  String get sessionResultsAfterVote => 'După votul participantului';

  @override
  String get sessionResultsAfterClose => 'După închiderea întrebării';

  @override
  String get sessionResultsOrganizerOnly => 'Doar organizatorul';

  @override
  String get sessionCreateAction => 'Creează Session';

  @override
  String get sessionPilotLimit => 'Limită pilot: între 1 și 250 de participanți per Session.';

  @override
  String get sessionStatusDraft => 'Ciornă';

  @override
  String get sessionStatusOpen => 'Deschisă';

  @override
  String get sessionStatusClosed => 'Închisă';

  @override
  String get sessionJoinCode => 'Cod de acces';

  @override
  String get sessionShareJoin => 'Distribuie linkul de acces';

  @override
  String get sessionCopyJoinLink => 'Copiază linkul';

  @override
  String get sessionGenerateTokens => 'Generează Access Passes';

  @override
  String get sessionGenerateTokensCount => 'Număr de Access Passes';

  @override
  String get sessionTokensOneTimeTitle => 'Salvează aceste credențiale acum';

  @override
  String get sessionTokensOneTimeBody => 'Access Passes în clar sunt afișate doar în rezultatul acestui lot. Social Vote stochează doar hash-urile lor. Copiază-le și distribuie-le în siguranță.';

  @override
  String get sessionCopyTokens => 'Copiază toate linkurile';

  @override
  String get sessionTokensSavedAction => 'Le-am salvat';

  @override
  String get sessionOpenAction => 'Deschide Session';

  @override
  String get sessionCloseAction => 'Închide Session';

  @override
  String get sessionCloseConfirm => 'Închizi votarea și creezi instantaneul imuabil Verified Result?';

  @override
  String get sessionQuestionsTitle => 'Întrebări';

  @override
  String get sessionAddQuestion => 'Adaugă întrebare';

  @override
  String get sessionQuestionTitle => 'Întrebare';

  @override
  String get sessionQuestionType => 'Tip întrebare';

  @override
  String get sessionTypeYesNo => 'Da / Nu';

  @override
  String get sessionTypeSingle => 'Alegere unică';

  @override
  String get sessionTypeMultiple => 'Alegere multiplă';

  @override
  String get sessionOptions => 'Opțiuni';

  @override
  String get sessionOptionHint => 'O opțiune pe fiecare rând.';

  @override
  String get sessionMinSelections => 'Selecții minime';

  @override
  String get sessionMaxSelections => 'Selecții maxime';

  @override
  String get sessionAddAction => 'Adaugă';

  @override
  String get sessionOpenQuestion => 'Deschide întrebarea';

  @override
  String get sessionCloseQuestion => 'Închide întrebarea';

  @override
  String get sessionNoQuestions => 'Nu există încă întrebări.';

  @override
  String get sessionPresenterTitle => 'Prezentator';

  @override
  String get sessionParticipantTitle => 'Social Vote Live';

  @override
  String get sessionJoinAction => 'Alătură-te Session';

  @override
  String get sessionTokenLabel => 'Token participant';

  @override
  String get sessionTokenHint => 'SV-…';

  @override
  String get sessionWaitingQuestion => 'Se așteaptă ca organizatorul să deschidă o întrebare…';

  @override
  String get sessionVoteAction => 'Trimite votul';

  @override
  String get sessionVoteReceived => 'Vot primit';

  @override
  String get sessionResultsUnavailable => 'Rezultatele nu sunt încă vizibile conform politicii acestei Session.';

  @override
  String get sessionPrivacyNotice => 'Organizatorul definește scopul operațional și întrebările Session. Social Vote prelucrează datele tehnice necesare pentru furnizarea și protejarea serviciului. Modurile anonime nu expun organizatorului legătura dintre credențialele unui participant și o alegere. Rolurile privind confidențialitatea pot depinde de context și de acordurile aplicabile.';

  @override
  String get sessionNonBindingNotice => 'Sessions pilot sunt pentru consultare și participare. Ele nu reprezintă alegeri legale, voturi statutare ale unei adunări sau certificări cu caracter juridic obligatoriu.';

  @override
  String get sessionOptionYes => 'Da';

  @override
  String get sessionOptionNo => 'Nu';

  @override
  String get verifiedResultTitle => 'Verified Result';

  @override
  String get verifiedResultValid => 'Verificarea integrității a reușit';

  @override
  String get verifiedResultInvalid => 'Verificarea integrității a eșuat';

  @override
  String get verifiedResultReportId => 'ID raport';

  @override
  String get verifiedResultHash => 'Hash SHA-256 al rezultatului';

  @override
  String get verifiedResultGeneratedBy => 'Generat și sigilat pentru integritate de Social Vote';

  @override
  String get verifiedResultNotLegalCertificate => 'Acesta este un raport verificabil de rezultat agregat, nu un certificat legal și nici o certificare a unor alegeri cu caracter juridic obligatoriu.';

  @override
  String get verifiedResultShare => 'Distribuie linkul de verificare';

  @override
  String sessionResponses(int count) {
    return '$count răspunsuri';
  }

  @override
  String sessionResultVotes(int count) {
    return '$count voturi';
  }

  @override
  String get organizationVerifiedIdentityLocked => 'Numele și țara fac parte din identitatea verificată a organizației. Schimbarea lor va necesita o nouă verificare. Poți modifica liber coperta, logo-ul, tipul, orașul, site-ul și descrierea.';

  @override
  String get verifiedResultOpenedAt => 'Session deschisă';

  @override
  String get verifiedResultEligibleCredentials => 'Credențiale eligibile';

  @override
  String get verifiedResultIntegritySeal => 'Sigiliu de integritate Social Vote';

  @override
  String get organizationVerifiedNameLocked => 'Numele verificat și țara sunt blocate. Schimbarea lor necesită o nouă revizuire de verificare.';

  @override
  String get sessionRetentionLabel => 'Păstrarea buletinelor brute';

  @override
  String get sessionRetention24h => '24 de ore';

  @override
  String get sessionRetention7d => '7 zile';

  @override
  String get sessionRetention30d => '30 de zile';

  @override
  String sessionRetentionValue(String value) {
    return 'Păstrarea buletinelor brute: $value';
  }

  @override
  String get verifiedResultPrintPdf => 'Descarcă PDF';

  @override
  String get verifiedResultPdfError => 'PDF-ul nu a putut fi descărcat. Încearcă din nou.';

  @override
  String get verifiedResultRestrictedTitle => 'Rezultat restricționat';

  @override
  String get verifiedResultRestrictedBody => 'Acest Verified Result nu este disponibil public. Autentifică-te cu un cont de organizație autorizat pentru a-l vedea.';

  @override
  String get verifiedResultPrivateVerificationTitle => 'Verificare publică indisponibilă';

  @override
  String get verifiedResultPrivateVerificationBody => 'Acest rezultat este restricționat organizatorului. ID-ul raportului, SHA-256 și verificarea integrității rămân disponibile în raportul autorizat.';

  @override
  String get organizationAccountSectionTitle => 'Organizațiile tale';

  @override
  String get organizationManageAction => 'Gestionează';

  @override
  String get organizationViewPublicProfileAction => 'Vezi profilul';

  @override
  String get organizationOfficialWebsiteAction => 'Site oficial';

  @override
  String get organizationVerificationIntro => 'Verificarea acoperă atât existența organizației, cât și autoritatea ta de a o reprezenta. Social Vote va revizui informațiile trimise înainte de aprobare.';

  @override
  String get organizationVerificationLegalName => 'Denumire legală';

  @override
  String get organizationVerificationPublicName => 'Nume public';

  @override
  String get organizationVerificationType => 'Tip organizație';

  @override
  String get organizationVerificationCountry => 'Țară';

  @override
  String get organizationVerificationCountryRequired => 'Selectează țara organizației.';

  @override
  String get organizationVerificationCity => 'Oraș';

  @override
  String get organizationVerificationWebsite => 'Site oficial';

  @override
  String get organizationVerificationRepresentativeRole => 'Rolul tău în organizație';

  @override
  String get organizationVerificationRegistryId => 'Identificator registru / fiscal / organizație';

  @override
  String get organizationVerificationAuthorityNote => 'Cum putem verifica faptul că o poți reprezenta?';

  @override
  String get organizationVerificationAuthorityHelper => 'Descrie pe scurt rolul tău sau dovada pe care un Admin o poate verifica în perioada pilot.';

  @override
  String get organizationVerificationRequired => 'Câmp obligatoriu.';

  @override
  String get sessionControlRoomTitle => 'Camera de control Session';

  @override
  String get sessionSectionLive => 'Live';

  @override
  String get sessionSectionQuestions => 'Întrebări';

  @override
  String get sessionSectionAccess => 'Acces';

  @override
  String get sessionSectionSettings => 'Setări';

  @override
  String get sessionStageAction => 'Deschide Stage';

  @override
  String get sessionAccessPassesTitle => 'Access Passes pentru participanți';

  @override
  String get sessionAccessPassesSubtitle => 'Fiecare pass deschide această Controlled Anonymous Session fără ca participantul să introducă credențiala lungă. Pass-ul în clar nu este stocat de Social Vote.';

  @override
  String get sessionAccessPass => 'Access Pass';

  @override
  String get sessionAccessPassDetected => 'Access Pass detectat';

  @override
  String get sessionAccessPassAutomatic => 'Pass-ul tău personal este gata. Continuă pentru a intra anonim în Session.';

  @override
  String get sessionAccessPassFallback => 'Introdu pass-ul manual';

  @override
  String get sessionAccessPassInvalid => 'Acest Access Pass este invalid, nu mai este disponibil sau Session nu este deschisă.';

  @override
  String get sessionAccessPassPrintWarning => 'Tipărește, salvează sau distribuie aceste passes acum. După ce părăsești acest ecran, Social Vote nu le va mai putea afișa în clar.';

  @override
  String get sessionExistingPassesHidden => 'Din motive de securitate, passes generate anterior nu mai pot fi afișate în clar. Generează Access Passes noi pentru a obține linkuri personale sau coduri QR noi.';

  @override
  String get sessionCopyPassLinks => 'Copiază toate linkurile';

  @override
  String get sessionCopyPassLink => 'Copiază acest link';

  @override
  String get sessionControlledNeedsAccessPass => 'Înainte de a deschide o Session controlată, generează cel puțin un Access Pass.';

  @override
  String get sessionJoinedParticipants => 'Credențiale de acces conectate';

  @override
  String get sessionAccessesUsed => 'Accesări care au votat';

  @override
  String get sessionBallotsRecorded => 'Buletine înregistrate';

  @override
  String get sessionQuestionsCompleted => 'Întrebări finalizate';

  @override
  String get sessionCurrentQuestion => 'Întrebarea curentă';

  @override
  String get sessionNoOpenQuestionTitle => 'Nicio întrebare nu este deschisă';

  @override
  String get sessionNoOpenQuestionBody => 'Participanții sunt conectați și așteaptă. Deschide următoarea întrebare când ești gata.';

  @override
  String get sessionNotStartedTitle => 'Session nu a început încă';

  @override
  String get sessionNotStartedBody => 'Această Session există, dar nu este încă deschisă. Păstrează această pagină deschisă și așteaptă ca organizatorul să o pornească.';

  @override
  String get sessionNoAccountRequired => 'Nu este necesar un cont Social Vote';

  @override
  String get sessionReceiptDetails => 'Detalii dovadă';

  @override
  String get sessionOpenAccessInstructions => 'Afișează sau distribuie acest QR. Oricine are linkul poate intra cât timp Session este deschisă.';

  @override
  String get sessionControlledAccessInstructions => 'Creează passes de acces personale și oferă câte unul fiecărui participant. QR-ul din fiecare pass conține automat credențiala.';

  @override
  String get sessionControlRoomHint => 'Gestionează accesul, întrebările, Stage proiectat și Verified Result final dintr-un singur loc.';

  @override
  String get sessionPresenterScreenTitle => 'Live Stage';

  @override
  String get sessionStageWaiting => 'Se așteaptă următoarea întrebare';

  @override
  String get sessionStageScan => 'Scanează pentru a te alătura Session';

  @override
  String get sessionConfigurationTitle => 'Configurarea Session';

  @override
  String get sessionAccessRecommended => 'Recomandat pentru întâlniri controlate';

  @override
  String get sessionCreateIntroTitle => 'Configurează întâlnirea';

  @override
  String get sessionCreateIntroBody => 'Alege cum intră participanții, când devin vizibile rezultatele și cât timp sunt păstrate buletinele brute. Aceste setări sunt impuse de backend.';

  @override
  String get verifiedCertificateNumber => 'Număr certificat';

  @override
  String get verifiedCertificateStatus => 'Stare integritate';

  @override
  String get verifiedCertificateIntegrityVerified => 'INTEGRITATE VERIFICATĂ';

  @override
  String get verifiedCertificateIntegrityFailed => 'VERIFICAREA INTEGRITĂȚII A EȘUAT';

  @override
  String get verifiedCertificateOrganizationSection => 'Organizație';

  @override
  String get verifiedCertificateSessionSection => 'Session';

  @override
  String get verifiedCertificateParticipationSection => 'Participare';

  @override
  String get verifiedCertificateResultsSection => 'Rezultate verificate';

  @override
  String get verifiedCertificateIntegritySection => 'Integritatea rezultatului';

  @override
  String get verifiedCertificateLegalName => 'Denumire legală';

  @override
  String get verifiedCertificateOrganizationType => 'Tip organizație';

  @override
  String get verifiedCertificateLocation => 'Locație';

  @override
  String get verifiedCertificateWebsite => 'Site web';

  @override
  String get verifiedCertificateVerification => 'Verificare';

  @override
  String get verifiedCertificateIssuedAt => 'Certificat emis';

  @override
  String get verifiedCertificateAlgorithm => 'Algoritm de integritate';

  @override
  String get verifiedCertificateSchema => 'Schema raportului';

  @override
  String get verifiedCertificateJoinedCredentials => 'Credențiale conectate';

  @override
  String get verifiedCertificateBallotsTotal => 'Buletine înregistrate';

  @override
  String get verifiedCertificateQuestionsTotal => 'Întrebări';

  @override
  String get verifiedCertificatePrivacyModel => 'Model de rezultat anonim';

  @override
  String get verifiedCertificatePrivacyText => 'Instantaneul imuabil conține doar rezultate agregate. Nu conține identitatea participantului, Access Pass în clar, secretul participantului sau vreo mapare între credențialele participantului și alegerea din buletin.';

  @override
  String get verifiedCertificateVerifyQr => 'Scanează acest QR pentru a verifica raportul online.';

  @override
  String get organizationDashboardTitle => 'Prezentare generală a organizației';

  @override
  String get organizationActiveSessions => 'Sessions live';

  @override
  String get organizationVerifiedReports => 'Rapoarte verificate';

  @override
  String get organizationTotalSessions => 'Total Sessions';

  @override
  String get sessionPrivacyPolicyAction => 'Citește Politica de confidențialitate';

  @override
  String get radioMondoTitle => 'Radio Mondo';

  @override
  String get radioMondoDescription => 'Trei peisaje sonore originale pentru explorarea Social Vote. Redarea începe doar când alegi o piesă.';

  @override
  String get radioMondoTrackClassical => 'Orbită clasică';

  @override
  String get radioMondoTrackRain => 'Ploaie peste lume';

  @override
  String get radioMondoTrackYoung => 'Pulse tânăr';

  @override
  String get radioMondoPlaying => 'Se redă acum';

  @override
  String get radioMondoStopped => 'Radio Mondo oprită';

  @override
  String get radioMondoStopAction => 'Oprește';

  @override
  String get radioMondoPlaybackError => 'Sunetul nu a putut fi redat';

  @override
  String get radioMondoForegroundOnly => 'Redarea se oprește când Social Vote este închis, trimis în fundal sau fila browserului este ascunsă.';

  @override
  String get adminCenterEditorialNavigation => 'World Briefs';

  @override
  String get worldBriefEditorTitle => 'Social Vote World Briefs';

  @override
  String get worldBriefEditorDescription => 'Pregătește sinteze bazate pe dovezi, păstrează incertitudinea vizibilă și decide ce apare în News și pe Globe.';

  @override
  String get worldBriefAllStatuses => 'Toate stările';

  @override
  String get worldBriefCreateAction => 'Creează un brief';

  @override
  String get worldBriefDraftSaved => 'Ciornă salvată';

  @override
  String get worldBriefPublished => 'Brief publicat';

  @override
  String get worldBriefWithdrawn => 'Brief retras';

  @override
  String get worldBriefSaveError => 'Brief-ul nu a putut fi salvat';

  @override
  String get worldBriefPublishError => 'Brief-ul nu a putut fi publicat';

  @override
  String get worldBriefDraftDeleted => 'Ciornă ștearsă';

  @override
  String get worldBriefDeleteDraft => 'Șterge ciorna';

  @override
  String get worldBriefDeleteDraftConfirm => 'Ștergi definitiv această ciornă nepublicată?';

  @override
  String get worldBriefRetry => 'Încearcă din nou';

  @override
  String get worldBriefStatusDraft => 'Ciornă';

  @override
  String get worldBriefStatusPublished => 'Publicat';

  @override
  String get worldBriefStatusWithdrawn => 'Retras';

  @override
  String get worldBriefSetupRequired => 'Backend editorial nepregătit';

  @override
  String get worldBriefSetupRequiredBody => 'Aplică migrarea de bază de date World Brief inclusă înainte de a folosi această secțiune.';

  @override
  String get worldBriefEmptyTitle => 'Niciun World Brief încă';

  @override
  String get worldBriefEmptyBody => 'Creează o ciornă, documentează cel puțin două surse și publică numai după revizuirea editorială.';

  @override
  String get worldBriefFeatured => 'Recomandat';

  @override
  String get worldBriefOnGlobe => 'Afișează pe Globe';

  @override
  String get worldBriefPriority => 'Prioritate';

  @override
  String get worldBriefEditAction => 'Editează';

  @override
  String get worldBriefPublishAction => 'Publică';

  @override
  String get worldBriefWithdrawAction => 'Retrage';

  @override
  String get worldBriefSaveDraftAction => 'Salvează ciorna';

  @override
  String get worldBriefLanguage => 'Limba brief-ului';

  @override
  String get worldBriefTitleField => 'Titlu';

  @override
  String get worldBriefWhatHappened => 'Ce s-a întâmplat';

  @override
  String get worldBriefWhyItMatters => 'De ce contează';

  @override
  String get worldBriefWhatIsUncertain => 'Ce este încă incert';

  @override
  String get worldBriefSources => 'URL-uri surse';

  @override
  String get worldBriefSourcesHint => 'Un URL HTTPS pe fiecare rând; cel puțin două surse independente.';

  @override
  String get worldBriefTwoSourcesRequired => 'Adaugă cel puțin două surse.';

  @override
  String get worldBriefHttpsSourcesRequired => 'Fiecare sursă trebuie să folosească HTTPS.';

  @override
  String get worldBriefGlobeSection => 'Plasare pe Globe';

  @override
  String get worldBriefGlobeRequiresPoint => 'Vizibilitatea pe Globe necesită latitudine și longitudine valide.';

  @override
  String get worldBriefCountryCode => 'Cod țară';

  @override
  String get worldBriefCityId => 'ID oraș';

  @override
  String get worldBriefLocationLabel => 'Etichetă locație';

  @override
  String get worldBriefLatitude => 'Latitudine';

  @override
  String get worldBriefLongitude => 'Longitudine';

  @override
  String get worldBriefBreaking => 'Actualizare urgentă';

  @override
  String get worldBriefExpiry => 'Fereastră de revizuire sau expirare';

  @override
  String worldBriefExpiryDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days zile',
      one: '1 zi',
    );
    return '$_temp0';
  }

  @override
  String get worldBriefRequiredField => 'Acest câmp este obligatoriu.';

  @override
  String get worldBriefCoordinatesRequired => 'Introdu o coordonată validă.';

  @override
  String get profileHowItWorksTitle => 'Cum funcționează Social Vote';

  @override
  String get profileHowItWorksSubtitle => 'Persoane, Organizații, Voce, Vote, Sessions și verificare.';

  @override
  String get profileMyPostsLoginRequired => 'Trebuie să fii autentificat pentru a vedea Voce create de tine.';

  @override
  String get profileMyPostsCreatedByYou => 'Voce create de tine';

  @override
  String get profileMyPostsEmpty => 'Nu ai creat încă nicio Voce.';

  @override
  String get profileMyPollsLoginRequired => 'Trebuie să fii autentificat pentru a vedea Vote create de tine.';

  @override
  String get profileMyPollsCreatedByYou => 'Vote create de tine';

  @override
  String get profileMyPollsEmpty => 'Nu ai creat încă niciun Vote.';

  @override
  String get profileMyCommentsLoginRequired => 'Trebuie să fii autentificat pentru a-ți vedea comentariile.';

  @override
  String get profileMyCommentsEmpty => 'Nu ai scris încă niciun comentariu.';

  @override
  String get profileFollowedScopesLoginRequired => 'Trebuie să fii autentificat.';

  @override
  String get profileFollowedScopesEmpty => 'Nu urmărești încă nicio zonă.';

  @override
  String get profileFollowedScopeWorld => 'Lume';

  @override
  String profileFollowedScopeCountry(String code) {
    return 'Țară: $code';
  }

  @override
  String profileFollowedScopeCity(String city) {
    return 'Oraș: $city';
  }

  @override
  String profileFollowedScopeArea(double radius) {
    return 'Zonă ($radius km)';
  }

  @override
  String get publicProfilePollsLoadError => 'Vote publice nu au putut fi încărcate.';

  @override
  String get publicProfilePollsEmpty => 'Niciun Vote public.';

  @override
  String get publicProfilePostsLoadError => 'Voce publice nu au putut fi încărcate.';

  @override
  String get publicProfilePostsEmpty => 'Nicio Voce publică.';

  @override
  String get worldBriefSocialVoteView => 'Perspectiva Social Vote';

  @override
  String get worldBriefSocialVoteViewHint => 'Analiză sau perspectivă editorială Social Vote. Păstreaz-o separată de faptele raportate și de incertitudine.';

  @override
  String get worldBriefSocialVoteViewPublicNote => 'Analiză editorială Social Vote, clar separată de faptele raportate mai sus.';

  @override
  String get worldBriefIndependentSourcesRequired => 'Publicarea necesită cel puțin două surse HTTPS din domenii diferite.';

  @override
  String get worldBriefPublishConfirmTitle => 'Verificare finală înainte de publicare';

  @override
  String worldBriefPublishConfirmSources(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count surse introduse',
      one: '1 sursă introdusă',
    );
    return '$_temp0';
  }

  @override
  String get worldBriefEnterpriseEditorTitle => 'Editor editorial profesional';

  @override
  String get worldBriefEnterpriseEditorHelp => 'Construiește brief-ul pe secțiuni. Social Vote gestionează automat plasarea tehnică pe Globe: alege o țară și un oraș, nu coordonate.';

  @override
  String get worldBriefEditorialContentSection => 'Conținut editorial';

  @override
  String get worldBriefEditorialContentHelp => 'Păstrează separate faptele, importanța, incertitudinea și perspectiva Social Vote. Astfel brief-ul este mai ușor de verificat și citit.';

  @override
  String get worldBriefSourcesSection => 'Surse și verificare';

  @override
  String get worldBriefSourcesSectionHelp => 'Adaugă surse HTTPS verificabile. Publicarea necesită cel puțin două domenii independente.';

  @override
  String get worldBriefDistributionSection => 'Distribuție';

  @override
  String get worldBriefDistributionHelp => 'Alege unde apare brief-ul. Publicarea îl face disponibil în News; plasarea pe Globe este opțională.';

  @override
  String get worldBriefNewsDestination => 'Publică în Social Vote News';

  @override
  String get worldBriefNewsDestinationHelp => 'Aceasta este destinația principală a unui World Brief după publicare.';

  @override
  String get worldBriefGlobeAutomaticHelp => 'Adaugă un marcaj pe Globe. Alege locul, iar Social Vote rezolvă automat poziția.';

  @override
  String get worldBriefPlacementMode => 'Plasarea marcajului';

  @override
  String get worldBriefPlacementCity => 'Oraș / loc';

  @override
  String get worldBriefPlacementCountry => 'Centrul țării';

  @override
  String get worldBriefCountry => 'Țară';

  @override
  String get worldBriefCity => 'Oraș sau loc';

  @override
  String get worldBriefCityHelp => 'Exemplu: Teheran. Nu introduce latitudine sau longitudine.';

  @override
  String get worldBriefResolveLocation => 'Rezolvă locația';

  @override
  String get worldBriefCoordinatesAutomatic => 'Coordonatele sunt gestionate automat și nu trebuie introduse manual.';

  @override
  String worldBriefLocationResolved(String location) {
    return 'Locație pregătită: $location';
  }

  @override
  String get worldBriefChooseCountryFirst => 'Alege mai întâi o țară.';

  @override
  String get worldBriefChooseCityFirst => 'Introdu mai întâi un oraș sau un loc.';

  @override
  String get worldBriefLocationNotResolved => 'Nu a putut fi determinată o locație de încredere. Verifică țara și orașul și încearcă din nou.';

  @override
  String get worldBriefVisibilitySection => 'Vizibilitate și prioritate';

  @override
  String get worldBriefVisibilityHelp => 'Controlează proeminența editorială, urgența, ordinea și durata fără a modifica faptele raportate.';

  @override
  String get worldBriefFeaturedHelp => 'Oferă brief-ului mai multă vizibilitate pe suprafețele editoriale.';

  @override
  String get worldBriefBreakingHelp => 'Folosește numai pentru evenimente cu adevărat urgente sau în evoluție rapidă.';

  @override
  String get worldBriefPriorityHelp => '0 = prioritate normală/scăzută; 100 = cea mai mare prioritate editorială. Nu schimbă statutul de adevăr al conținutului.';

  @override
  String get worldBriefExpiryHelp => 'După această perioadă, brief-ul nu trebuie să rămână activ fără o nouă revizuire editorială.';

  @override
  String get profileAppLanguageSpanish => 'Spaniolă';

  @override
  String get profileAppLanguagePortuguese => 'Portugheză';

  @override
  String get homeHeroPurpose => 'Descoperă ce contează, împărtășește Voce și participă la Vote.';

  @override
  String get commentSection_hideComments => 'Ascunde comentariile';

  @override
  String get commentSection_viewComments => 'Vezi comentariile';

  @override
  String get commentSection_hideReplies => 'Ascunde răspunsurile';

  @override
  String commentSection_editing(String snippet) {
    return 'Se editează: $snippet';
  }

  @override
  String get commentSection_editInputHint => 'Editează comentariul';

  @override
  String commentSection_replyTo(String author) {
    return 'Răspunde lui $author';
  }

  @override
  String get commentSection_userFallback => 'Utilizator';

  @override
  String get commentSection_addError => 'Comentariul nu a putut fi adăugat.';

  @override
  String get commentSection_nestedReplyError => 'Răspunsurile imbricate dincolo de un singur nivel nu sunt acceptate.';

  @override
  String get commentSection_addReplyError => 'Răspunsul nu a putut fi adăugat.';

  @override
  String get commentSection_editError => 'Comentariul nu a putut fi editat.';

  @override
  String get commentSection_deleteError => 'Comentariul nu a putut fi șters.';

  @override
  String get commentSection_edited => 'Editat';

  @override
  String get commentSection_editAction => 'Editează';
}
