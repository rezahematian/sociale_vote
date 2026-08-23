// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Social Vote';

  @override
  String get voteButton => 'Vota';

  @override
  String get createPollPageTitle => 'Crea Vote';

  @override
  String get createPollPageSubtitle => 'Definisci un nuovo voto civico';

  @override
  String get createPollBasicInfoTitle => 'Informazioni di base';

  @override
  String get createPollBasicInfoSubtitle => 'Definisci i dettagli principali del Vote.';

  @override
  String get createPollTitleFieldLabel => 'Titolo *';

  @override
  String get createPollTitleFieldHelper => 'Una domanda o affermazione chiara e concisa.';

  @override
  String get createPollDescriptionFieldLabel => 'Descrizione (facoltativa)';

  @override
  String get createPollVotingModelTitle => 'Come si vota';

  @override
  String get createPollVotingModelSubtitle => 'Scegli se ogni persona può dare una sola risposta oppure più risposte.';

  @override
  String get createPollTypeFieldLabel => 'Tipo di Vote';

  @override
  String createPollSelectionRules(int min, int max) {
    return 'Regole di selezione: minimo $min, massimo $max scelte (regolate automaticamente in base al tipo di Vote e alle opzioni).';
  }

  @override
  String get createPollAllowVoteChangeTitle => 'Consenti agli utenti di modificare il proprio voto';

  @override
  String get createPollAllowVoteChangeSubtitle => 'Fino alla chiusura del Vote.';

  @override
  String get createPollOptionsTitle => 'Risposte';

  @override
  String get createPollOptionsSubtitle => 'Scrivi almeno due risposte tra cui gli utenti possano scegliere. I campi contrassegnati con * sono obbligatori.';

  @override
  String createPollOptionLabel(int index, Object requiredMarker) {
    return 'Opzione $index$requiredMarker';
  }

  @override
  String get createPollRemoveOptionTooltip => 'Rimuovi opzione';

  @override
  String get createPollAddOptionButton => 'Aggiungi opzione';

  @override
  String get createPollParticipationPrivacyTitle => 'Partecipazione e privacy';

  @override
  String get createPollParticipationPrivacySubtitle => 'Decidi chi può votare e quanto devono essere identificabili i voti.';

  @override
  String get createPollWhoCanVoteLabel => 'Chi può votare?';

  @override
  String get createPollParticipationEveryoneSubtitle => 'Qualsiasi utente registrato può partecipare.';

  @override
  String get createPollParticipationGeoScopeSubtitle => 'Limita questo Vote alle persone di uno specifico Paese.';

  @override
  String get createPollCountryFieldLabel => 'Paese per questo Vote';

  @override
  String get createPollCountryFieldHelper => 'Questo Paese definirà chi è autorizzato a partecipare a questo Vote (funzionalità futura).';

  @override
  String get createPollVoteAnonymityTitle => 'Anonimato del voto';

  @override
  String get createPollAnonymityAnonymousSubtitle => 'Impostazione predefinita consigliata per piattaforme di voto civico.';

  @override
  String get createPollAnonymityPublicSubtitle => 'Usare con cautela: i voti potrebbero essere associati alle identità (funzionalità futura).';

  @override
  String get createPollResultsValidityTitle => 'Risultati e validità';

  @override
  String get createPollResultsValiditySubtitle => 'Controlla quando i risultati sono visibili e definisci un quorum minimo, se necessario.';

  @override
  String get createPollResultsVisibilityFieldLabel => 'Visibilità dei risultati';

  @override
  String get createPollQuorumTitle => 'Quorum (facoltativo)';

  @override
  String get createPollQuorumSubtitle => 'Se impostato, il Vote è considerato valido solo se viene raggiunto almeno questo numero di voti. Lascia vuoto per nessun quorum.';

  @override
  String get createPollQuorumMinVotesFieldLabel => 'Numero minimo di voti';

  @override
  String get createPollTimingTitle => 'Tempistiche';

  @override
  String get createPollTimingSubtitle => 'Definisci quando il Vote deve essere aperto alle votazioni.';

  @override
  String get createPollStartDateLabel => 'Data di inizio';

  @override
  String get createPollEndDateLabel => 'Data di fine';

  @override
  String get createPollChangeDateButtonLabel => 'Modifica';

  @override
  String get createPollTimingStatusInfo => 'Lo stato iniziale (aperto/pianificato/chiuso) sarà determinato automaticamente in base a queste date.';

  @override
  String get createPollSuccessMessage => 'Vote creato con successo';

  @override
  String get createPollSubmitCreatingLabel => 'Creazione in corso...';

  @override
  String get createPollSubmitLabel => 'Crea Vote';

  @override
  String get createPollPollTypeYesNoLabel => 'Sì / No';

  @override
  String get createPollPollTypeSingleChoiceLabel => 'Una risposta';

  @override
  String get createPollPollTypeMultipleChoiceLabel => 'Più risposte';

  @override
  String get createPollPollTypeApprovalLabel => 'Voto di approvazione';

  @override
  String get createPollPollTypeRankedLabel => 'Voto a scelta ordinata';

  @override
  String get createPollPollTypeScoreLabel => 'Punteggio / Valutazione';

  @override
  String get createPollParticipationScopeEveryoneLabel => 'Tutti possono votare';

  @override
  String get createPollParticipationScopeGeoScopeOnlyLabel => 'Solo utenti in un Paese specifico';

  @override
  String get createPollAnonymityLevelAnonymousLabel => 'I voti sono anonimi';

  @override
  String get createPollAnonymityLevelPublicLabel => 'I voti sono pubblici (uso avanzato / ristretto)';

  @override
  String get createPollResultsVisibilityAlwaysLabel => 'Sempre visibili (mentre il Vote è aperto)';

  @override
  String get createPollResultsVisibilityAfterVoteLabel => 'Visibili solo dopo aver votato';

  @override
  String get createPollResultsVisibilityAfterCloseLabel => 'Visibili solo dopo la chiusura del Vote';

  @override
  String get homeLoginButton => 'Accedi';

  @override
  String get homeRegisterButton => 'Registrati';

  @override
  String get homeProfileButton => 'Profilo';

  @override
  String get homeLogoutButton => 'Esci';

  @override
  String get homeLogoutMessage => 'Disconnessione completata. Ora stai usando l’app come ospite (sola lettura).';

  @override
  String get homeSearchHint => 'Cerca città, Paesi, account e contenuti...';

  @override
  String get searchPageTitle => 'Cerca';

  @override
  String get searchInputHint => 'Cerca account, Vote, News, Voce...';

  @override
  String get searchClearTooltip => 'Cancella ricerca';

  @override
  String get searchTypeAll => 'Tutti';

  @override
  String get searchTypePolls => 'Vote';

  @override
  String get searchTypeNews => 'News';

  @override
  String get searchTypePosts => 'Voce';

  @override
  String get searchTypeAccounts => 'Account';

  @override
  String get searchSortHottest => 'Più caldi';

  @override
  String get searchSortLatest => 'Più recenti';

  @override
  String get searchPollStatusAll => 'Tutti i Vote';

  @override
  String get searchPollStatusOpen => 'Aperti';

  @override
  String get searchPollStatusClosed => 'Chiusi';

  @override
  String get searchIdleMessage => 'Inserisci un termine per iniziare la ricerca.';

  @override
  String get searchErrorMessage => 'Si è verificato un problema durante la ricerca.';

  @override
  String get searchRetryButton => 'Riprova';

  @override
  String get searchEmptyMessage => 'Nessun risultato trovato per questa ricerca.';

  @override
  String get searchContentUnavailable => 'Contenuto non disponibile';

  @override
  String get searchResultTypePoll => 'Vote';

  @override
  String get searchResultTypeNews => 'News';

  @override
  String get searchResultTypePost => 'Voce';

  @override
  String get searchResultTypeAccount => 'Account';

  @override
  String get searchResultTypeMixed => 'Misto';

  @override
  String homeUserStatusLoggedIn(Object userId) {
    return 'Accesso effettuato come: $userId';
  }

  @override
  String get homeUserStatusGuest => 'Modalità ospite: puoi solo leggere. Accedi o registrati per votare, commentare e reagire.';

  @override
  String get homeScopeLabelWorld => 'Mondo – Votazioni e notizie globali';

  @override
  String get homeScopeLabelCountry => 'Paese – Votazioni e notizie nazionali';

  @override
  String get homeScopeLabelCity => 'Città – Votazioni e notizie locali';

  @override
  String get homeScopeShortWorld => 'Mondo';

  @override
  String get homeScopeShortCountry => 'Paese';

  @override
  String get homeScopeShortCity => 'Città';

  @override
  String get homeScopeChipWorld => 'Mondo';

  @override
  String get homeScopeChipItaly => 'Italia';

  @override
  String get homeScopeChipTorino => 'Torino';

  @override
  String get homeScopeChangedWorld => 'Ambito impostato su Mondo';

  @override
  String get homeScopeChangedItaly => 'Ambito impostato su Italia';

  @override
  String get homeScopeChangedTorino => 'Ambito impostato su Torino';

  @override
  String get followScopeButtonFollowed => 'Seguito';

  @override
  String get followScopeButtonFollow => 'Segui quest’area';

  @override
  String get homeTrendingTitle => 'Pulse Now';

  @override
  String get homeTrendingError => 'Impossibile caricare Pulse Now per quest’area.';

  @override
  String get homeTrendingEmpty => 'Nessun contenuto in Pulse Now per quest’area al momento.';

  @override
  String homeForYouTitle(Object scope) {
    return 'Pulse ($scope)';
  }

  @override
  String get homeForYouError => 'Impossibile caricare Pulse per quest’area.';

  @override
  String get homeForYouEmpty => 'Nessun contenuto suggerito in Pulse per quest’area al momento.';

  @override
  String homePollsTitle(Object scope) {
    return 'Vote in evidenza ($scope)';
  }

  @override
  String get homePollsEmptyTitle => 'Nessun Vote per quest’area';

  @override
  String get homePollsEmptySubtitle => 'Non ci sono Vote per quest’area.';

  @override
  String get homePollsViewAllButton => 'Vedi Vote';

  @override
  String homeNewsTitle(Object scope) {
    return 'News principali ($scope)';
  }

  @override
  String get homeNewsErrorTitle => 'Impossibile caricare le notizie';

  @override
  String get homeNewsErrorSubtitle => 'Si è verificato un problema nel caricamento delle notizie per quest’area.';

  @override
  String get homeNewsEmptyTitle => 'Nessuna notizia per quest’area';

  @override
  String get homeNewsEmptySubtitle => 'Non ci sono notizie per quest’area al momento.';

  @override
  String get homeNewsViewAllButton => 'Vedi tutte le notizie';

  @override
  String get homeNewsBreakingBadge => 'ULTIM’ORA';

  @override
  String homeSocialTitle(Object scope) {
    return 'Voce ($scope)';
  }

  @override
  String get homeSocialErrorTitle => 'Impossibile caricare Voce';

  @override
  String get homeSocialErrorSubtitle => 'Si è verificato un problema nel caricamento di Voce per quest’area.';

  @override
  String get homeSocialEmptyTitle => 'Nessuna Voce per quest’area';

  @override
  String get homeSocialEmptySubtitle => 'Non ci sono Voci per quest’area al momento.';

  @override
  String get homeSocialViewFeedButton => 'Vedi tutte le Voci';

  @override
  String get pollDetail_title => 'Dettaglio Vote';

  @override
  String get pollDetail_removeFromFavoritesTooltip => 'Rimuovi dai salvati';

  @override
  String get pollDetail_addToFavoritesTooltip => 'Salva';

  @override
  String get pollDetail_chipAnonymous => 'Voto anonimo';

  @override
  String get pollDetail_chipPublic => 'Voto pubblico';

  @override
  String get pollDetail_chipRestrictedGeo => 'Limitato all\'ambito geografico';

  @override
  String pollDetail_quorumReached(int currentVotes, int requiredVotes) {
    return 'Quorum raggiunto ($currentVotes / $requiredVotes)';
  }

  @override
  String pollDetail_quorumNotReached(int currentVotes, int requiredVotes) {
    return 'Quorum non raggiunto ($currentVotes / $requiredVotes)';
  }

  @override
  String get pollDetail_optionsTitle => 'Opzioni';

  @override
  String get pollDetail_statusClosedMessage => 'Questo Vote è chiuso.';

  @override
  String get pollDetail_statusScheduledMessage => 'Questo Vote non è ancora aperto.';

  @override
  String get pollDetail_statusNotAvailableMessage => 'La votazione non è disponibile.';

  @override
  String get pollDetail_voteSubmitted => 'Voto registrato con successo!';

  @override
  String get pollDetail_voteButton => 'Vota';

  @override
  String get pollDetail_resultsTitle => 'Risultati';

  @override
  String pollDetail_outcomePrefix(Object label) {
    return 'Esito: $label';
  }

  @override
  String get pollDetail_noResults => 'Nessun risultato disponibile al momento.';

  @override
  String get pollDetail_resultsAfterVote => 'I risultati saranno visibili dopo il tuo voto.';

  @override
  String get pollDetail_resultsWhenClosed => 'I risultati saranno visibili alla chiusura del Vote.';

  @override
  String get pollType_yesNo => 'Sì / No';

  @override
  String get pollType_singleChoice => 'Scelta singola';

  @override
  String get pollType_multipleChoice => 'Scelta multipla';

  @override
  String get pollType_approval => 'Approvazione';

  @override
  String get pollStatus_draft => 'Bozza';

  @override
  String get pollStatus_open => 'Aperto';

  @override
  String get pollStatus_closed => 'Chiuso';

  @override
  String get pollStatus_scheduled => 'Programmato';

  @override
  String get pollGeo_global => 'Globale';

  @override
  String get pollGeo_local => 'Locale';

  @override
  String get pollOutcome_approved => 'Approvato';

  @override
  String get pollOutcome_rejected => 'Respinto';

  @override
  String get pollOutcome_tie => 'Parità';

  @override
  String get pollOutcome_noMajority => 'Nessuna maggioranza';

  @override
  String get pollOutcome_notApplicable => 'Non applicabile';

  @override
  String get pollList_title => 'Vote';

  @override
  String get pollList_scopeWorld => 'Mondo';

  @override
  String get pollList_scopeCountryFallback => 'Paese';

  @override
  String get pollList_scopeCityFallback => 'Città';

  @override
  String get pollList_scopeDescriptionGlobal => 'Visualizzazione dei Vote globali.';

  @override
  String get pollList_scopeDescriptionCountry => 'Visualizzazione dei Vote per questo Paese.';

  @override
  String get pollList_scopeDescriptionCity => 'Visualizzazione dei Vote per questa città.';

  @override
  String get pollList_filterStatus_all => 'Tutti';

  @override
  String get pollList_filterStatus_open => 'Aperti';

  @override
  String get pollList_filterStatus_closed => 'Chiusi';

  @override
  String get pollList_sort_latest => 'Più recenti';

  @override
  String get pollList_sort_hottest => 'Più caldi';

  @override
  String get pollList_filterScope_currentArea => 'Area corrente';

  @override
  String pollList_headerTitle(Object scopeLabel, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Vote',
      one: '1 Vote',
      zero: 'nessun Vote',
    );
    return '$scopeLabel · $_temp0';
  }

  @override
  String get pollList_createPollButton => 'Crea Vote';

  @override
  String get pollList_paginationHint => 'Scorri per caricare altri Vote…';

  @override
  String get pollList_emptyMessage => 'Nessun Vote corrisponde a questo filtro per quest’area.';

  @override
  String get pollType_ranked => 'Voto a classifica';

  @override
  String get pollType_score => 'Voto a punteggio';

  @override
  String get pollVisibility_whileOpen => 'Risultati visibili durante l\'apertura';

  @override
  String get pollVisibility_afterVote => 'Risultati visibili dopo il voto';

  @override
  String get pollVisibility_afterClose => 'Risultati visibili dopo la chiusura';

  @override
  String get pollCard_countryRestricted => 'Limitato al paese';

  @override
  String pollCard_restrictedToCountry(Object countryName) {
    return 'Limitato a $countryName';
  }

  @override
  String pollCard_quorumLabel(int minVotes) {
    return 'Quorum $minVotes';
  }

  @override
  String get pollCard_resultsVisibleChip => 'Risultati visibili';

  @override
  String get pollCard_resultsAfterVoteChip => 'Dopo il voto';

  @override
  String get pollCard_resultsAfterCloseChip => 'Dopo la chiusura';

  @override
  String get pollCard_publicOfficialPublisher => 'Rappresentante pubblico';

  @override
  String get pollCard_institutionPublisher => 'Istituzione';

  @override
  String get pollCard_representativePublisher => 'Rappresentante';

  @override
  String pollCard_voteCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'voti',
      one: 'voto',
    );
    return '$_temp0';
  }

  @override
  String get pollCard_viewDetails => 'Vedi dettagli';

  @override
  String pollResult_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Risultati ($count voti)',
      one: 'Risultati (1 voto)',
      zero: 'Risultati (nessun voto)',
    );
    return '$_temp0';
  }

  @override
  String get voteError_noSelection => 'Seleziona almeno un\'opzione.';

  @override
  String get voteError_unauthorized => 'Non sei autorizzato a votare in questo Vote.';

  @override
  String get voteError_generic => 'Impossibile registrare il voto. Riprova.';

  @override
  String get commentSection_title => 'Commenti';

  @override
  String get commentSection_sortLabel => 'Ordina:';

  @override
  String get commentSection_sortOldest => 'Meno recenti';

  @override
  String get commentSection_sortNewest => 'Più recenti';

  @override
  String get commentSection_errorGeneric => 'Si è verificato un errore durante il caricamento dei commenti.';

  @override
  String get commentSection_empty => 'Non ci sono ancora commenti. Scrivi il primo tu.';

  @override
  String get commentSection_loadMore => 'Carica altri commenti';

  @override
  String commentSection_replyingTo(Object snippet) {
    return 'Stai rispondendo a: $snippet';
  }

  @override
  String get commentSection_cancelReply => 'Annulla';

  @override
  String get commentSection_inputHintRoot => 'Aggiungi un commento...';

  @override
  String get commentSection_inputHintReply => 'Scrivi una risposta...';

  @override
  String get commentSection_deleteAction => 'Elimina';

  @override
  String get commentSection_replyAction => 'Rispondi';

  @override
  String get commentSection_youBadge => 'Tu';

  @override
  String get newsDetail_title => 'Dettaglio notizia';

  @override
  String get newsDetail_breakingBadge => 'ULTIM\'ORA';

  @override
  String get newsDetail_removeFromFavoritesTooltip => 'Rimuovi dai salvati';

  @override
  String get newsDetail_addToFavoritesTooltip => 'Salva';

  @override
  String get newsDetail_bodyFallback => 'Non sono disponibili ulteriori dettagli per questa notizia.';

  @override
  String get newsDetail_footerMoreContext => 'Altri contesti e fonti saranno disponibili a breve.';

  @override
  String get newsFeed_title => 'Notizie';

  @override
  String get newsFeed_scopeWorld => 'Mondo';

  @override
  String get newsFeed_scopeCountry => 'Paese';

  @override
  String get newsFeed_scopeCity => 'Città';

  @override
  String newsFeed_scopeLabel(Object scope) {
    return 'Ambito: $scope';
  }

  @override
  String get newsFeed_scopeGlobalDescription => 'Notizie a livello globale.';

  @override
  String get newsFeed_scopeCountryDescription => 'Notizie per questo paese.';

  @override
  String get newsFeed_scopeCityDescription => 'Notizie per questa città.';

  @override
  String get newsFeed_emptyTitle => 'Nessuna notizia disponibile per quest’area.';

  @override
  String get newsFeed_emptySubtitle => 'Trascina per aggiornare o riprova più tardi.';

  @override
  String newsFeed_itemsFound(int count) {
    return '$count notizie trovate';
  }

  @override
  String get newsFeed_loadingMoreHint => 'Scorri per caricare altre notizie…';

  @override
  String get newsFeed_errorTitle => 'Impossibile caricare le notizie';

  @override
  String get newsFeed_errorGeneric => 'Si è verificato un errore durante il caricamento delle notizie.';

  @override
  String get newsFeed_retryButton => 'Riprova';

  @override
  String get newsCard_headerTitle => 'Notizia';

  @override
  String get newsFeed_errorUnauthorized => 'Configurazione delle notizie non valida (chiave API).';

  @override
  String get newsFeed_errorRateLimited => 'Troppe richieste. Riprova tra poco.';

  @override
  String get newsFeed_errorServerUnavailable => 'Servizio notizie temporaneamente non disponibile. Riprova più tardi.';

  @override
  String get newsFeed_errorTimeout => 'La richiesta sta impiegando troppo tempo. Riprova.';

  @override
  String get newsFeed_errorNetwork => 'Nessuna connessione. Controlla internet e riprova.';

  @override
  String get newsFeed_moreTooltip => 'Altro';

  @override
  String get newsFeed_actionCopyTitle => 'Copia titolo';

  @override
  String get newsFeed_actionRefreshFeed => 'Aggiorna notizie';

  @override
  String get newsFeed_copiedTitleToast => 'Titolo copiato';

  @override
  String get newsFeed_languageTooltip => 'Lingua notizie';

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
  String get newsFeed_languageLimitedHint => 'Poche fonti disponibili in questa lingua. Prova AUTO.';

  @override
  String get newsTopic_all => 'Tutte';

  @override
  String get newsTopic_world => 'Mondo';

  @override
  String get newsTopic_nation => 'Nazione';

  @override
  String get newsTopic_business => 'Economia';

  @override
  String get newsTopic_technology => 'Tecnologia';

  @override
  String get newsTopic_science => 'Scienza';

  @override
  String get newsTopic_health => 'Salute';

  @override
  String get newsTopic_sports => 'Sport';

  @override
  String get newsTopic_entertainment => 'Intrattenimento';

  @override
  String get newsDetail_openSource => 'Apri fonte';

  @override
  String get newsDetail_openSourceUnavailable => 'Impossibile aprire la fonte';

  @override
  String get socialFeedTitle => 'Voce';

  @override
  String get socialFeedCreatePostButton => 'Crea Voce';

  @override
  String get commonCancelButton => 'Annulla';

  @override
  String get commonApplyButton => 'Applica';

  @override
  String get homeScopeChooseCountry => 'Scegli paese';

  @override
  String get homeScopeCountrySearchHint => 'Cerca paese o codice...';

  @override
  String get homeScopeChooseCity => 'Scegli città';

  @override
  String homeScopeCountryWithCode(String code) {
    return 'Paese: $code';
  }

  @override
  String get homeScopeCityFieldLabel => 'Città';

  @override
  String get homeScopeCityExampleHint => 'Scrivi una città, es. Merano';

  @override
  String get homeScopeCityRequiredError => 'Inserisci una città.';

  @override
  String get homeScopeCityNotFoundError => 'Città non trovata nel paese selezionato.';

  @override
  String get homeScopeCityVerificationError => 'Impossibile verificare la città. Riprova.';

  @override
  String get homeScopeVerifyingButton => 'Verifica...';

  @override
  String get homeMapOpenButton => 'Apri mappa';

  @override
  String get homeHeroHeadline => 'Decidi il futuro.\nInsieme.';

  @override
  String get homeHeroPollsAction => 'Vote';

  @override
  String get homeHeroNewsAction => 'News';

  @override
  String get homeHeroCreateAction => 'Crea';

  @override
  String get homeHeroExploreAction => 'Esplora';

  @override
  String get homeAccountMenuLabel => 'Account';

  @override
  String get homeThemeSystemMenuItem => 'Tema: sistema';

  @override
  String get homeThemeLightMenuItem => 'Tema: chiaro';

  @override
  String get homeThemeDarkMenuItem => 'Tema: scuro';

  @override
  String get profileAppLanguageTitle => 'Lingua dell\'app';

  @override
  String get profileAppLanguageSystem => 'Sistema';

  @override
  String get profileAppLanguageSystemDescription => 'Usa la lingua del dispositivo';

  @override
  String get profileAppLanguageItalian => 'Italiano';

  @override
  String get profileAppLanguageEnglish => 'Inglese';

  @override
  String get homeNotificationsTooltip => 'Notifiche';

  @override
  String get postCard_authorFallback => 'Autore';

  @override
  String get postCard_globalLocation => 'Globale';

  @override
  String get commonSaveButton => 'Salva';

  @override
  String get commonDeleteButton => 'Elimina';

  @override
  String get contentReport_menuAction => 'Segnala contenuto';

  @override
  String get contentReport_dialogTitle => 'Segnala contenuto';

  @override
  String get contentReport_authenticationRequired => 'Devi essere autenticato per segnalare';

  @override
  String get contentReport_submittedMessage => 'Segnalazione inviata';

  @override
  String get contentReport_alreadySubmittedMessage => 'Hai già segnalato questo contenuto';

  @override
  String get contentReport_submitError => 'Impossibile inviare la segnalazione';

  @override
  String get contentReport_sendButton => 'Invia';

  @override
  String get contentReport_reasonSpam => 'Spam';

  @override
  String get contentReport_reasonHarassment => 'Molestie o abuso';

  @override
  String get contentReport_reasonHateSpeech => 'Incitamento all’odio';

  @override
  String get contentReport_reasonMisinformation => 'Disinformazione';

  @override
  String get contentReport_reasonViolence => 'Violenza';

  @override
  String get contentReport_reasonOther => 'Altro';

  @override
  String get postDetail_title => 'Dettaglio Voce';

  @override
  String get postDetail_favoriteUpdateError => 'Impossibile aggiornare i salvati';

  @override
  String get postDetail_shareMessage => 'Apri Social Vote per vedere questa Voce.';

  @override
  String get postDetail_shareError => 'Impossibile condividere la Voce';

  @override
  String get postDetail_editDialogTitle => 'Modifica Voce';

  @override
  String get postDetail_editTitleFieldLabel => 'Titolo';

  @override
  String get postDetail_editContentFieldLabel => 'Contenuto';

  @override
  String get postDetail_editRequiredError => 'Titolo e contenuto sono obbligatori.';

  @override
  String get postDetail_updateSuccess => 'Voce aggiornata';

  @override
  String get postDetail_updateError => 'Impossibile aggiornare la Voce';

  @override
  String get postDetail_deleteDialogTitle => 'Eliminare questa Voce?';

  @override
  String get postDetail_deleteDialogMessage => 'Questa azione non può essere annullata.';

  @override
  String get postDetail_deleteError => 'Impossibile eliminare la Voce';

  @override
  String get postDetail_editMenuItem => 'Modifica Voce';

  @override
  String get postDetail_deleteMenuItem => 'Elimina Voce';

  @override
  String get postDetail_loadError => 'Si è verificato un errore nel caricamento della Voce.';

  @override
  String get postDetail_notFound => 'Voce non trovata.';

  @override
  String get postDetail_errorTitle => 'Errore';

  @override
  String get postDetail_authorFallback => 'Autore';

  @override
  String get postDetail_shareAction => 'Condividi';

  @override
  String get postDetail_saveAction => 'Salva';

  @override
  String get postDetail_addToFavoritesTooltip => 'Salva';

  @override
  String get postDetail_removeFromFavoritesTooltip => 'Rimuovi dai salvati';

  @override
  String get newsDetail_favoriteUpdateError => 'Impossibile aggiornare i salvati';

  @override
  String get newsDetail_shareMessage => 'Apri Social Vote per vedere questa notizia.';

  @override
  String get newsDetail_shareError => 'Impossibile condividere la notizia';

  @override
  String get newsDetail_shareTooltip => 'Condividi';

  @override
  String get authLoginPageTitle => 'Accedi';

  @override
  String get authLoginHeadline => 'Bentornato';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authRememberMeLabel => 'Ricordami';

  @override
  String get authForgotPasswordAction => 'Password dimenticata?';

  @override
  String get authLoginButton => 'Accedi';

  @override
  String get authRegisterPrompt => 'Non hai un account?';

  @override
  String get authRegisterAction => 'Registrati';

  @override
  String get authRegisterPageTitle => 'Registrazione';

  @override
  String get authRegisterHeadline => 'Crea un account';

  @override
  String get authDisplayNameLabel => 'Nome pubblico';

  @override
  String get authUsernameLabel => 'Nome utente';

  @override
  String get authCountryOfResidenceLabel => 'Paese di residenza';

  @override
  String get authCityOfResidenceLabel => 'Città di residenza (facoltativa)';

  @override
  String get authConfirmPasswordLabel => 'Conferma password';

  @override
  String get authLegalConsentPrefix => 'Confermo di avere almeno 18 anni. Accetto i Termini di servizio e confermo di aver letto l’Informativa sulla privacy.';

  @override
  String get authTermsOfServiceAction => 'i Termini di servizio';

  @override
  String get authPrivacyPolicyAction => 'l’Informativa sulla privacy';

  @override
  String get authRegisterButton => 'Registrati';

  @override
  String get authLoginPrompt => 'Hai già un account?';

  @override
  String get authLoginAction => 'Accedi';

  @override
  String get authForgotPasswordDialogTitle => 'Reimposta la password';

  @override
  String get authForgotPasswordDialogBody => 'Inserisci l’indirizzo email associato al tuo account. Ti invieremo un link per scegliere una nuova password.';

  @override
  String get authForgotPasswordSendButton => 'Invia link';

  @override
  String get authPasswordResetEmailSent => 'Email di reimpostazione inviata. Controlla la posta in arrivo.';

  @override
  String get authResetPasswordPageTitle => 'Reimposta password';

  @override
  String get authResetPasswordHeadline => 'Scegli una nuova password';

  @override
  String get authNewPasswordLabel => 'Nuova password';

  @override
  String get authConfirmNewPasswordLabel => 'Conferma nuova password';

  @override
  String get authUpdatePasswordButton => 'Aggiorna password';

  @override
  String get authPasswordUpdated => 'Password aggiornata correttamente.';

  @override
  String get authEmailConfirmationTitle => 'Controlla la tua email';

  @override
  String get authEmailConfirmationIntro => 'Abbiamo inviato un link di conferma a:';

  @override
  String get authEmailConfirmationInstructions => 'Apri il link nel messaggio per verificare l’indirizzo. Dopo la conferma, torna nell’app e accedi.';

  @override
  String get authBackToLoginButton => 'Torna all’accesso';

  @override
  String get authUseAnotherEmailButton => 'Usa un altro indirizzo email';

  @override
  String get authEmailRequiredError => 'Inserisci la tua email.';

  @override
  String get authEmailInvalidError => 'Inserisci un indirizzo email valido.';

  @override
  String get authPasswordRequiredError => 'Inserisci la password.';

  @override
  String get authPasswordTooShortError => 'La password deve contenere almeno 8 caratteri.';

  @override
  String get authDisplayNameRequiredError => 'Inserisci il nome pubblico.';

  @override
  String get authDisplayNameTooShortError => 'Il nome pubblico è troppo corto.';

  @override
  String get authUsernameRequiredError => 'Inserisci un nome utente.';

  @override
  String get authUsernameInvalidError => 'Usa da 3 a 20 caratteri: lettere minuscole, numeri e underscore.';

  @override
  String get authUsernameAlreadyTakenError => 'Nome utente già utilizzato.';

  @override
  String get authCountryRequiredError => 'Seleziona il Paese di residenza.';

  @override
  String get authCityRequiredError => 'Inserisci la città di residenza.';

  @override
  String get authConfirmPasswordRequiredError => 'Conferma la password.';

  @override
  String get authPasswordsDoNotMatchError => 'Le password non coincidono.';

  @override
  String get authLegalConsentRequiredError => 'Per registrarti devi confermare di avere almeno 18 anni, accettare i Termini di servizio e confermare di aver letto l’Informativa sulla privacy.';

  @override
  String get authForgotPasswordEmailRequiredError => 'Inserisci l’email dell’account da recuperare.';

  @override
  String get authInvalidCredentialsError => 'Email o password non valide.';

  @override
  String get authEmailAlreadyRegisteredError => 'Questa email è già registrata.';

  @override
  String get authEmailNotConfirmedError => 'Email non confermata. Controlla la posta in arrivo prima di accedere.';

  @override
  String get authTooManyAttemptsError => 'Troppi tentativi. Attendi qualche minuto e riprova.';

  @override
  String get authNetworkError => 'Errore di rete. Controlla la connessione e riprova.';

  @override
  String get authLoginGenericError => 'Accesso non riuscito. Riprova.';

  @override
  String get authRegisterGenericError => 'Registrazione non riuscita. Riprova.';

  @override
  String get authPasswordResetGenericError => 'Impossibile inviare il link di reimpostazione. Riprova.';

  @override
  String get authPasswordUpdateGenericError => 'Impossibile aggiornare la password. Riprova.';

  @override
  String get authShowPasswordTooltip => 'Mostra password';

  @override
  String get authHidePasswordTooltip => 'Nascondi password';

  @override
  String get authTermsPageTitle => 'Termini di servizio';

  @override
  String get authPrivacyPageTitle => 'Informativa sulla privacy';

  @override
  String get authCloseButton => 'Chiudi';

  @override
  String get pollDetail_favoriteUpdateError => 'Impossibile aggiornare i salvati';

  @override
  String get pollDetail_shareMessage => 'Apri Social Vote per vedere e votare questo Vote.';

  @override
  String get pollDetail_shareError => 'Impossibile condividere il Vote';

  @override
  String get pollDetail_editPermissionError => 'Puoi modificare solo i tuoi Vote senza voti';

  @override
  String get pollDetail_editSuccessMessage => 'Vote aggiornato';

  @override
  String get pollDetail_editMenuItem => 'Modifica Vote';

  @override
  String get pollDetail_editSavingMenuItem => 'Salvataggio...';

  @override
  String get pollDetail_deletePermissionError => 'Puoi eliminare solo i tuoi Vote';

  @override
  String get pollDetail_deleteError => 'Impossibile eliminare il Vote';

  @override
  String get pollDetail_deleteDialogTitle => 'Elimina Vote';

  @override
  String pollDetail_deleteDialogMessage(String title) {
    return 'Vuoi davvero eliminare \"$title\"? Questa azione non può essere annullata.';
  }

  @override
  String get pollDetail_deleteMenuItem => 'Elimina Vote';

  @override
  String get pollDetail_deleteDeletingMenuItem => 'Eliminazione...';

  @override
  String get pollDetail_publicVotesAvailableTitle => 'Voti pubblici disponibili';

  @override
  String get pollDetail_publicVotesAvailableMessage => 'Questo Vote permette di vedere chi ha votato cosa.';

  @override
  String get pollDetail_publicVotesAction => 'Vedi voti pubblici';

  @override
  String get pollDetail_retryButton => 'Riprova';

  @override
  String get pollDetail_voteErrorNoOption => 'Seleziona almeno un\'opzione';

  @override
  String get pollDetail_voteErrorAuthenticationRequired => 'Devi essere autenticato per votare';

  @override
  String get pollDetail_voteErrorClosed => 'Questo Vote è chiuso';

  @override
  String get pollDetail_voteErrorAlreadyVoted => 'Hai già votato in questo Vote';

  @override
  String get pollDetail_voteErrorGeneric => 'Impossibile registrare il voto';

  @override
  String get pollDetail_publicVotesSheetTitle => 'Voti pubblici';

  @override
  String get pollDetail_publicVotesSheetDescription => 'Qui puoi vedere chi ha votato cosa in questo Vote.';

  @override
  String get pollDetail_publicVotesSearchHint => 'Cerca utente';

  @override
  String get pollDetail_publicVotesLoadError => 'Impossibile caricare i voti pubblici';

  @override
  String get pollDetail_publicVotesEmpty => 'Nessun voto pubblico disponibile';

  @override
  String get pollDetail_publicVotesSearchEmpty => 'Nessun utente trovato per questa ricerca';

  @override
  String pollDetail_publicVotesResultsCount(int count) {
    return '$count risultati caricati';
  }

  @override
  String get pollDetail_publicVotesLoadMore => 'Carica altri';

  @override
  String get pollDetail_publicVotesUserFallback => 'Utente';

  @override
  String get pollDetail_editDialogTitle => 'Modifica Vote';

  @override
  String get pollDetail_editTitleFieldLabel => 'Titolo';

  @override
  String get pollDetail_editTitleRequired => 'Il titolo è obbligatorio';

  @override
  String get pollDetail_editDescriptionFieldLabel => 'Descrizione';

  @override
  String get pollDetail_editError => 'Impossibile aggiornare il Vote';

  @override
  String get pollDetail_loadError => 'Impossibile caricare il Vote';

  @override
  String get pollDetail_notFound => 'Vote non trovato';

  @override
  String get profileEditPageTitle => 'Modifica profilo';

  @override
  String get profileLoginRequiredMessage => 'Devi accedere per modificare il profilo.';

  @override
  String get profileAvatarUploading => 'Caricamento...';

  @override
  String get profileUploadAvatarButton => 'Carica avatar';

  @override
  String get profileDisplayNameLabel => 'Nome visualizzato';

  @override
  String get profileDisplayNameRequiredError => 'Il nome visualizzato è obbligatorio.';

  @override
  String get profileUsernameHint => 'es. mario_roma';

  @override
  String get profileUsernameHelper => '3–20 caratteri: lettere minuscole, numeri e underscore';

  @override
  String get profileAvatarUrlLabel => 'URL avatar';

  @override
  String get profileBioLabel => 'Bio';

  @override
  String get profileClearCountryButton => 'Rimuovi Paese';

  @override
  String get profileCityResidenceHelper => 'La città di residenza viene verificata rispetto al Paese selezionato prima del salvataggio.';

  @override
  String get profileCityNotFoundError => 'Città non riconosciuta per il Paese selezionato.';

  @override
  String get profileCityVerificationError => 'Impossibile verificare la città in questo momento.';

  @override
  String get profileAvatarUploadError => 'Impossibile caricare l’avatar.';

  @override
  String get profileAccountSectionTitle => 'Account';

  @override
  String get profileAccountEmailHelper => 'L’indirizzo email dell’account non può essere modificato da questa schermata.';

  @override
  String get profileChangePasswordAction => 'Cambia password';

  @override
  String get profileChangePasswordDescription => 'Imposta una nuova password per questo account.';

  @override
  String get notificationsPageTitle => 'Notifiche';

  @override
  String get notificationsMarkAllReadAction => 'Segna tutte come lette';

  @override
  String get notificationsNoTargetMessage => 'Questa notifica non ha una destinazione apribile.';

  @override
  String get notificationsTargetUnavailableMessage => 'Il contenuto collegato alla notifica non è disponibile.';

  @override
  String get notificationsLoadError => 'Impossibile caricare le notifiche.';

  @override
  String get notificationsRetryButton => 'Riprova';

  @override
  String get notificationsEmptyMessage => 'Nessuna notifica disponibile.';

  @override
  String get notificationsCommentReplyTitle => 'Nuova risposta al tuo commento';

  @override
  String get notificationsMentionTitle => 'Sei stato menzionato';

  @override
  String get notificationsPollResultTitle => 'Aggiornamento Vote';

  @override
  String notificationsCommentReplySubtitle(String actor, String target) {
    return 'Utente $actor ha risposto in $target';
  }

  @override
  String notificationsMentionSubtitle(String actor, String target) {
    return 'Utente $actor ti ha menzionato in $target';
  }

  @override
  String notificationsPollResultSubtitle(String target) {
    return 'Nuovo risultato disponibile in $target';
  }

  @override
  String get notificationsTargetPost => 'una Voce';

  @override
  String get notificationsTargetNews => 'una notizia';

  @override
  String get notificationsTargetPoll => 'un Vote';

  @override
  String get notificationsTargetVideo => 'un video';

  @override
  String get notificationsTargetContent => 'un contenuto';

  @override
  String get notificationsUserFallback => 'utente';

  @override
  String get profileDeleteAccountAction => 'Elimina account';

  @override
  String get profileDeleteAccountDescription => 'Elimina definitivamente account e accesso';

  @override
  String get profileDeleteAccountDialogTitle => 'Elimina account';

  @override
  String get profileDeleteAccountDialogMessage => 'Questa operazione è permanente. L’account non potrà essere recuperato. Scrivi DELETE per confermare.';

  @override
  String get profileDeleteAccountConfirmationLabel => 'Conferma eliminazione';

  @override
  String get profileDeleteAccountConfirmationHint => 'Scrivi DELETE';

  @override
  String get profileDeleteAccountConfirmationError => 'Scrivi DELETE per continuare.';

  @override
  String get profileDeleteAccountCancelButton => 'Annulla';

  @override
  String get profileDeleteAccountConfirmButton => 'Elimina definitivamente';

  @override
  String get profileDeleteAccountFailureMessage => 'Impossibile eliminare l’account. Riprova.';

  @override
  String get identityActorTypePerson => 'Persona';

  @override
  String get identityActorTypePublicOfficial => 'Funzionario pubblico';

  @override
  String get identityActorTypePublicInstitution => 'Istituzione pubblica';

  @override
  String get identityActorTypeVerifiedOrganization => 'Organizzazione verificata';

  @override
  String get identityVerificationNotVerified => 'Non verificata';

  @override
  String get identityVerificationLevel1 => 'Identità verificata';

  @override
  String get identityVerificationLevel2 => 'Identità verificata avanzata';

  @override
  String get identityBadgeLevel1 => 'Identità verificata';

  @override
  String get identityBadgeLevel2 => 'Identità verificata avanzata';

  @override
  String get identityBadgePublicOfficial => 'Funzionario pubblico';

  @override
  String get identityBadgePublicInstitution => 'Istituzione pubblica';

  @override
  String get identityBadgeVerifiedOrganization => 'Organizzazione verificata';

  @override
  String get identityOrganizationNameLabel => 'Nome dell’organizzazione';

  @override
  String get identityOrganizationNameRequired => 'Inserisci il nome dell’organizzazione.';

  @override
  String get identityInstitutionLevelMunicipality => 'Comunale';

  @override
  String get identityInstitutionLevelProvince => 'Provinciale';

  @override
  String get identityInstitutionLevelRegion => 'Regionale';

  @override
  String get identityInstitutionLevelMinistry => 'Ministero';

  @override
  String get identityInstitutionLevelGovernment => 'Governo';

  @override
  String get identityInstitutionLevelPublicAgency => 'Agenzia pubblica';

  @override
  String get identityInstitutionLevelOtherPublicBody => 'Altro ente pubblico';

  @override
  String get verificationRequestPersonLevel1 => 'Verifica persona — Livello 1';

  @override
  String get verificationRequestPersonLevel2 => 'Verifica persona — Livello 2';

  @override
  String get verificationRequestPublicOfficial => 'Verifica funzionario pubblico';

  @override
  String get verificationRequestPublicInstitution => 'Verifica istituzione pubblica';

  @override
  String get verificationRequestVerifiedOrganization => 'Verifica organizzazione';

  @override
  String get verificationCenterTitle => 'Verifica e tipo di account';

  @override
  String get verificationCurrentAccountSection => 'Account attuale';

  @override
  String verificationAccountTypeValue(String accountType) {
    return 'Tipo di account: $accountType';
  }

  @override
  String verificationLevelValue(String level) {
    return 'Livello di verifica: $level';
  }

  @override
  String verificationOfficialTitleValue(String title) {
    return 'Titolo ufficiale: $title';
  }

  @override
  String verificationInstitutionNameValue(String name) {
    return 'Ente: $name';
  }

  @override
  String verificationOrganizationNameValue(String name) {
    return 'Organizzazione: $name';
  }

  @override
  String verificationInstitutionLevelValue(String level) {
    return 'Livello istituzionale: $level';
  }

  @override
  String get verificationActiveRequestSection => 'Richiesta attiva';

  @override
  String get verificationProfileUnchangedUntilApproval => 'Il profilo attuale non cambia finché la richiesta non viene approvata.';

  @override
  String get verificationCancelPendingAction => 'Annulla richiesta in attesa';

  @override
  String get verificationPendingBlocksNewRequests => 'Finché hai una richiesta in attesa non puoi inviarne una nuova.';

  @override
  String get verificationNoActiveRequestSection => 'Nessuna richiesta attiva';

  @override
  String get verificationNoActiveRequestDescription => 'Al momento non hai richieste in revisione.';

  @override
  String get verificationLastRejectedSection => 'Ultima richiesta respinta';

  @override
  String get verificationLastRejectedDescription => 'La tua ultima richiesta è stata respinta.';

  @override
  String get verificationRejectedCanResubmit => 'Il profilo attuale non è cambiato. Puoi correggere i dati e inviare una nuova richiesta.';

  @override
  String get verificationAvailableRequestsSection => 'Richieste disponibili';

  @override
  String get verificationRequestLevel1Title => 'Richiedi verifica persona — Livello 1';

  @override
  String get verificationRequestLevel1Subtitle => 'Verifica di base dell’identità personale';

  @override
  String get verificationRequestLevel2Title => 'Richiedi verifica persona — Livello 2';

  @override
  String get verificationRequestLevel2Subtitle => 'Verifica avanzata dell’identità personale';

  @override
  String get verificationRequestPublicOfficialTitle => 'Richiedi account Funzionario pubblico';

  @override
  String get verificationRequestPublicOfficialSubtitle => 'Richiede un titolo ufficiale e la revisione';

  @override
  String get verificationRequestPublicInstitutionTitle => 'Richiedi account Istituzione pubblica';

  @override
  String get verificationRequestPublicInstitutionSubtitle => 'Richiede nome dell’ente, livello istituzionale e revisione';

  @override
  String get verificationRequestOrganizationTitle => 'Richiedi account Organizzazione verificata';

  @override
  String get verificationRequestOrganizationSubtitle => 'Richiede i dati dell’organizzazione, il ruolo del rappresentante e la revisione Admin';

  @override
  String get verificationNoSelfServiceUpgrade => 'Non ci sono verifiche disponibili per lo stato attuale del tuo account.';

  @override
  String get verificationRequestSubmitSuccess => 'Richiesta inviata con successo.';

  @override
  String get verificationRequestSubmitFailure => 'Impossibile inviare la richiesta.';

  @override
  String get verificationOfficialTitleDialogTitle => 'Verifica Funzionario pubblico';

  @override
  String get verificationOfficialTitleLabel => 'Titolo ufficiale';

  @override
  String get verificationOfficialTitleHint => 'es. Sindaco, Assessore, Ministro';

  @override
  String get verificationInstitutionDialogTitle => 'Verifica Istituzione pubblica';

  @override
  String get verificationInstitutionNameLabel => 'Nome dell’ente';

  @override
  String get verificationInstitutionNameHint => 'es. Comune di Roma';

  @override
  String get verificationInstitutionLevelLabel => 'Livello istituzionale';

  @override
  String get verificationOrganizationDialogTitle => 'Verifica Organizzazione';

  @override
  String get verificationOrganizationNameHint => 'es. Associazione Ambiente Italia';

  @override
  String get verificationSubmitRequestAction => 'Invia richiesta';

  @override
  String get verificationCancelDialogTitle => 'Annulla richiesta';

  @override
  String get verificationCancelDialogBody => 'Vuoi davvero annullare la richiesta di verifica in attesa?';

  @override
  String get verificationCancelSuccess => 'Richiesta annullata.';

  @override
  String get verificationCancelFailure => 'Impossibile annullare la richiesta.';

  @override
  String get verificationStatusPendingSuffix => 'richiesta in revisione';

  @override
  String get verificationStatusRejectedSuffix => 'ultima richiesta respinta';

  @override
  String get verificationReviewPageTitle => 'Revisione verifiche';

  @override
  String get verificationReviewLoginRequired => 'Devi accedere per revisionare le richieste di verifica.';

  @override
  String verificationReviewPendingCount(int count) {
    return 'Richieste in attesa: $count';
  }

  @override
  String get verificationReviewNoPendingRequests => 'Nessuna richiesta di verifica in attesa.';

  @override
  String get verificationReviewUserIdLabel => 'ID utente';

  @override
  String get verificationReviewSubmittedLabel => 'Inviata';

  @override
  String get verificationReviewOfficialTitleLabel => 'Titolo ufficiale';

  @override
  String get verificationReviewInstitutionLabel => 'Istituzione';

  @override
  String get verificationReviewOrganizationLabel => 'Organizzazione';

  @override
  String get verificationReviewNoteLabel => 'Nota di revisione';

  @override
  String get verificationReviewRejectAction => 'Rifiuta';

  @override
  String get verificationReviewApproveAction => 'Approva';

  @override
  String get verificationReviewApproveDialogTitle => 'Approva richiesta';

  @override
  String get verificationReviewRejectDialogTitle => 'Rifiuta richiesta';

  @override
  String get verificationReviewApproveConfirmation => 'Confermi l’approvazione della richiesta?';

  @override
  String get verificationReviewRejectConfirmation => 'Confermi il rifiuto della richiesta?';

  @override
  String get verificationReviewOptionalNoteLabel => 'Nota di revisione facoltativa';

  @override
  String get verificationReviewRequiredNoteLabel => 'Motivo del rifiuto';

  @override
  String get verificationReviewOptionalHelper => 'Facoltativa';

  @override
  String get verificationReviewRequiredHelper => 'Obbligatorio per il rifiuto';

  @override
  String get verificationReviewRequiredNoteError => 'Inserisci il motivo del rifiuto.';

  @override
  String get verificationReviewApprovedSuccess => 'Richiesta approvata.';

  @override
  String get verificationReviewRejectedSuccess => 'Richiesta rifiutata.';

  @override
  String get verificationReviewOperationFailure => 'Operazione non riuscita.';

  @override
  String get adminCenterTitle => 'Centro amministrazione';

  @override
  String get adminCenterDashboardNavigation => 'Riepilogo';

  @override
  String get adminCenterUsersNavigation => 'Utenti';

  @override
  String get adminCenterVerificationNavigation => 'Verifiche';

  @override
  String get adminCenterReportsNavigation => 'Segnalazioni';

  @override
  String get adminCenterAuditNavigation => 'Registro attività';

  @override
  String get adminCenterAccountDetailsTitle => 'Dettagli account';

  @override
  String get adminCenterTryAgainAction => 'Riprova';

  @override
  String get adminCenterRetryAction => 'Riprova';

  @override
  String get adminCenterClearAction => 'Cancella';

  @override
  String get adminCenterApplyFiltersAction => 'Applica filtri';

  @override
  String get adminCenterAllDates => 'Tutte le date';

  @override
  String get adminCenterAuditDateFilterHelp => 'Filtra il registro per data';

  @override
  String get adminCenterActorUserIdLabel => 'ID utente autore';

  @override
  String get adminCenterActionLabel => 'Azione';

  @override
  String get adminCenterAuditActionHint => 'resolve_escalated_report';

  @override
  String get adminCenterTargetIdLabel => 'ID destinatario';

  @override
  String get adminCenterOutcomeLabel => 'Esito';

  @override
  String get adminCenterAllOutcomes => 'Tutti gli esiti';

  @override
  String get adminCenterOutcomeSuccess => 'Successo';

  @override
  String get adminCenterOutcomeFailure => 'Errore';

  @override
  String get adminCenterOutcomeDenied => 'Negato';

  @override
  String get adminCenterOutcomeNoChange => 'Nessuna modifica';

  @override
  String get adminCenterOutcomeUnknown => 'Sconosciuto';

  @override
  String get adminCenterAuditUnavailableTitle => 'Registro attività non disponibile';

  @override
  String get adminCenterAuditUnavailableMessage => 'Controlla la connessione e i permessi, poi riprova.';

  @override
  String get adminCenterNoAuditEntriesTitle => 'Nessuna registrazione';

  @override
  String get adminCenterNoAuditEntriesMessage => 'Non ci sono registrazioni corrispondenti ai filtri selezionati.';

  @override
  String get adminCenterAuditIdLabel => 'ID registrazione';

  @override
  String get adminCenterActorLabel => 'Autore';

  @override
  String get adminCenterReasonLabel => 'Motivo';

  @override
  String get adminCenterTimestampLabel => 'Data e ora';

  @override
  String get adminCenterErrorLabel => 'Errore';

  @override
  String get adminCenterRecordedValuesTitle => 'Valori registrati';

  @override
  String get adminCenterPreviousValueLabel => 'Precedente';

  @override
  String get adminCenterNewValueLabel => 'Nuovo';

  @override
  String get adminCenterContentTypeLabel => 'Tipo di contenuto';

  @override
  String get adminCenterAllContent => 'Tutti i contenuti';

  @override
  String get adminCenterPolls => 'Vote';

  @override
  String get adminCenterPosts => 'Voce';

  @override
  String get adminCenterNews => 'Notizie';

  @override
  String get adminCenterAwaitingAdminDecision => 'In attesa della decisione admin';

  @override
  String get adminCenterStatusLabel => 'Stato';

  @override
  String get adminCenterAllStatuses => 'Tutti gli stati';

  @override
  String get adminCenterStatusOpen => 'Aperta';

  @override
  String get adminCenterStatusInReview => 'In revisione';

  @override
  String get adminCenterStatusResolved => 'Risolta';

  @override
  String get adminCenterStatusDismissed => 'Archiviata';

  @override
  String get adminCenterAdminQueueUnavailableTitle => 'Coda escalation admin non disponibile';

  @override
  String get adminCenterReportsUnavailableTitle => 'Segnalazioni non disponibili';

  @override
  String get adminCenterConnectionTryAgainMessage => 'Controlla la connessione e riprova.';

  @override
  String get adminCenterNoAdminReportsTitle => 'Nessuna segnalazione in attesa dell’admin';

  @override
  String get adminCenterNoReportsTitle => 'Nessuna segnalazione';

  @override
  String get adminCenterNoAdminReportsMessage => 'Non ci sono segnalazioni escalate che richiedono una revisione amministrativa.';

  @override
  String get adminCenterNoReportsMessage => 'Non ci sono segnalazioni corrispondenti ai filtri selezionati.';

  @override
  String get adminCenterSearchUsersHint => 'Cerca per nome, username, email o ID';

  @override
  String get adminCenterClearSearchTooltip => 'Cancella ricerca';

  @override
  String get adminCenterUsersUnavailableTitle => 'Utenti non disponibili';

  @override
  String get adminCenterNoUsersFoundTitle => 'Nessun utente trovato';

  @override
  String get adminCenterNoUsersTitle => 'Nessun utente';

  @override
  String get adminCenterNoUsersFoundMessage => 'Prova un nome, username, email o ID diverso.';

  @override
  String get adminCenterNoUsersMessage => 'Non ci sono account da mostrare.';

  @override
  String get adminCenterAccountUnavailableTitle => 'Account non disponibile';

  @override
  String get adminCenterBackToUsersAction => 'Torna agli utenti';

  @override
  String get adminCenterPublicIdentitySection => 'Identità pubblica';

  @override
  String get adminCenterDisplayNameLabel => 'Nome visualizzato';

  @override
  String get adminCenterNotProvided => 'Non indicato';

  @override
  String get adminCenterUsernameLabel => 'Username';

  @override
  String get adminCenterUserIdLabel => 'ID utente';

  @override
  String get adminCenterIdentityTypeLabel => 'Tipo di identità';

  @override
  String get adminCenterAccountSection => 'Account';

  @override
  String get adminCenterTechnicalRoleLabel => 'Ruolo tecnico';

  @override
  String get adminCenterRoleMirrorLabel => 'Ruolo replicato nel profilo';

  @override
  String get adminCenterRoleSynchronizationLabel => 'Sincronizzazione ruolo';

  @override
  String get adminCenterSynchronized => 'Sincronizzato';

  @override
  String get adminCenterNotSynchronized => 'Non sincronizzato';

  @override
  String get adminCenterRoleNotSynchronized => 'Ruolo non sincronizzato';

  @override
  String get adminCenterAccountStatusLabel => 'Stato account';

  @override
  String get adminCenterSuspendedUntilLabel => 'Sospeso fino al';

  @override
  String get adminCenterAccountManagementSection => 'Gestione account';

  @override
  String get adminCenterDangerZoneSection => 'Zona pericolosa';

  @override
  String get adminCenterRoleManagementSection => 'Gestione ruolo';

  @override
  String get adminCenterVerificationLevelLabel => 'Livello di verifica';

  @override
  String get adminCenterVerificationStatusLabel => 'Stato verifica';

  @override
  String get adminCenterAccessInformationSection => 'Informazioni di accesso';

  @override
  String get adminCenterEmailLabel => 'Email';

  @override
  String get adminCenterNotAvailable => 'Non disponibile';

  @override
  String get adminCenterEmailConfirmationLabel => 'Conferma email';

  @override
  String get adminCenterNotConfirmed => 'Non confermata';

  @override
  String get adminCenterRegisteredLabel => 'Registrato';

  @override
  String get adminCenterLastAccessLabel => 'Ultimo accesso';

  @override
  String get adminCenterLoadingDashboardTitle => 'Caricamento riepilogo';

  @override
  String get adminCenterLoadingDashboardMessage => 'Recupero degli indicatori più recenti.';

  @override
  String get adminCenterDashboardUnavailableTitle => 'Riepilogo non disponibile';

  @override
  String get adminCenterIndicatorsUnavailableMessage => 'Non è stato possibile caricare gli indicatori.';

  @override
  String get adminCenterVerificationPendingIndicator => 'Verifiche in attesa';

  @override
  String get adminCenterOpenReportsIndicator => 'Segnalazioni aperte';

  @override
  String get adminCenterSuspendedAccountsIndicator => 'Account sospesi';

  @override
  String get adminCenterStaffIndicator => 'Staff';

  @override
  String get adminCenterNoPendingWorkTitle => 'Nessuna attività in attesa';

  @override
  String get adminCenterNoPendingWorkMessage => 'Verifiche, segnalazioni e account sospesi sono tutti sotto controllo.';

  @override
  String get adminCenterCouldNotUpdateUsers => 'Non è stato possibile aggiornare l’elenco utenti.';

  @override
  String get adminCenterCouldNotUpdateReports => 'Non è stato possibile aggiornare la coda segnalazioni.';

  @override
  String get adminCenterUnnamedUser => 'Utente senza nome';

  @override
  String get adminCenterTemporarySuspensionTitle => 'Sospensione temporanea';

  @override
  String get adminCenterReactivateDescription => 'Rimuovi subito la sospensione e consenti un nuovo accesso.';

  @override
  String get adminCenterSuspendDescription => 'Blocca l’accesso per un periodo limitato e termina tutte le sessioni attive.';

  @override
  String get adminCenterSuspensionUnavailableDescription => 'La sospensione richiede un account sincronizzato e non amministratore.';

  @override
  String get adminCenterReactivateAccountAction => 'Riattiva account';

  @override
  String get adminCenterSuspendAccountAction => 'Sospendi account';

  @override
  String get adminCenterForceLogoutAction => 'Forza logout';

  @override
  String get adminCenterSuspendedForceLogoutDescription => 'La sospensione ha già terminato le sessioni attive. Riattiva l’account prima di provare un logout separato.';

  @override
  String get adminCenterForceLogoutDescription => 'Termina tutte le sessioni attive senza sospendere l’account.';

  @override
  String get adminCenterForceLogoutUnavailableDescription => 'Il logout forzato richiede un account sincronizzato e non amministratore.';

  @override
  String get adminCenterPermanentDeletionTitle => 'Eliminazione definitiva account';

  @override
  String get adminCenterPermanentDeletionDescription => 'Elimina i dati di autenticazione, termina tutte le sessioni e anonimizza il record pubblico conservato.';

  @override
  String get adminCenterDeletionUnavailableDescription => 'L’eliminazione richiede un account sincronizzato e non amministratore.';

  @override
  String get adminCenterDeleteAccountPermanentlyAction => 'Elimina definitivamente l’account';

  @override
  String get adminCenterDurationOneHour => '1 ora';

  @override
  String get adminCenterDurationOneDay => '24 ore';

  @override
  String get adminCenterDurationSevenDays => '7 giorni';

  @override
  String get adminCenterDurationThirtyDays => '30 giorni';

  @override
  String get adminCenterSuspendImmediateEffect => 'L’account perderà subito l’accesso e tutte le sessioni attive verranno terminate.';

  @override
  String get adminCenterDurationLabel => 'Durata';

  @override
  String get adminCenterSuspendReasonHint => 'Spiega perché questo account deve essere sospeso';

  @override
  String get adminCenterReactivateReasonHint => 'Spiega perché questo account può essere riattivato';

  @override
  String get adminCenterReactivateConfirmation => 'Confermo che questo account può riottenere l’accesso.';

  @override
  String get adminCenterReactivateFailure => 'Non è stato possibile riattivare l’account. Controlla ruolo e stato, poi riprova.';

  @override
  String get adminCenterReactivateSuccess => 'Account riattivato. Ora è consentito un nuovo accesso.';

  @override
  String get adminCenterForceLogoutFullDescription => 'Termina tutte le sessioni attive di questo account. L’account resta attivo e può accedere di nuovo.';

  @override
  String get adminCenterForceLogoutReasonHint => 'Spiega perché le sessioni attive devono essere terminate';

  @override
  String get adminCenterForceLogoutConfirmation => 'Confermo la terminazione immediata di tutte le sessioni attive di questo account.';

  @override
  String get adminCenterForceLogoutFailure => 'Non è stato possibile disconnettere l’account. Controlla ruolo e stato, poi riprova.';

  @override
  String get adminCenterForceLogoutSuccess => 'Sessioni attive terminate. L’account può accedere di nuovo.';

  @override
  String get adminCenterSuspendFailure => 'Non è stato possibile sospendere l’account. Controlla ruolo e stato, poi riprova.';

  @override
  String get adminCenterDeleteReasonHint => 'Spiega perché questo account deve essere eliminato';

  @override
  String get adminCenterTypeDeleteLabel => 'Digita DELETE';

  @override
  String get adminCenterTypeAccountIdLabel => 'Digita l’ID account completo';

  @override
  String get adminCenterDeletePermanentlyAction => 'Elimina definitivamente';

  @override
  String get adminCenterDeleteIrreversibleWarning => 'Questa azione è irreversibile. I dati di autenticazione e le sessioni attive verranno rimossi, l’avatar verrà eliminato e il record pubblico conservato sarà anonimizzato. La registrazione di audit resterà disponibile.';

  @override
  String get adminCenterDeleteFailure => 'Non è stato possibile eliminare l’account. Controlla ruolo, stato e valori di conferma, poi riprova.';

  @override
  String get adminCenterDeleteSuccess => 'Account eliminato definitivamente e dati personali anonimizzati.';

  @override
  String get adminCenterChangeTechnicalRoleTitle => 'Cambia ruolo tecnico';

  @override
  String get adminCenterChangeRoleDescription => 'Controlla il ruolo attuale e quello richiesto prima di confermare.';

  @override
  String get adminCenterChangeRoleUnavailableDescription => 'Il cambio ruolo richiede un account sincronizzato e non eliminato.';

  @override
  String get adminCenterChangeRoleAction => 'Cambia ruolo';

  @override
  String get adminCenterChangePublicIdentityTitle => 'Cambia identità pubblica';

  @override
  String get adminCenterChangeIdentityDescription => 'Aggiorna il tipo di account pubblico e il livello di verifica.';

  @override
  String get adminCenterChangeIdentityUnavailableDescription => 'Il cambio identità richiede un account sincronizzato e non amministratore.';

  @override
  String get adminCenterChangeIdentityAction => 'Cambia identità';

  @override
  String get adminCenterChoosePublicIdentityMessage => 'Scegli il tipo di account pubblico e il relativo stato di verifica.';

  @override
  String get adminCenterPublicAccountTypeLabel => 'Tipo di account pubblico';

  @override
  String get adminCenterPersonVerificationHelper => 'Livello 1 e Livello 2 sono disponibili solo per Persona.';

  @override
  String get adminCenterNonPersonVerificationHelper => 'Gli account non Persona non usano Livello 1 o Livello 2.';

  @override
  String get adminCenterBeforeLabel => 'Prima';

  @override
  String get adminCenterAfterLabel => 'Dopo';

  @override
  String get adminCenterIdentityReasonHint => 'Spiega perché l’identità pubblica deve cambiare';

  @override
  String get adminCenterIdentityConfirmation => 'Confermo l’identità pubblica e il livello di verifica mostrati sopra.';

  @override
  String get adminCenterIdentityChangeFailure => 'Non è stato possibile cambiare l’identità pubblica. Controlla lo stato dell’account e riprova.';

  @override
  String get adminCenterChooseTechnicalRoleMessage => 'Scegli il nuovo ruolo tecnico e registra il motivo del cambiamento.';

  @override
  String get adminCenterNewTechnicalRoleLabel => 'Nuovo ruolo tecnico';

  @override
  String get adminCenterSelectRole => 'Seleziona un ruolo';

  @override
  String get adminCenterRoleSessionWarning => 'Questa modifica termina la sessione attiva del destinatario. Dovrà accedere di nuovo prima di continuare a usare l’account.';

  @override
  String get adminCenterRoleReasonHint => 'Spiega perché il ruolo tecnico deve cambiare';

  @override
  String get adminCenterRoleConfirmation => 'Confermo il ruolo mostrato sopra e comprendo che il destinatario dovrà accedere di nuovo.';

  @override
  String get adminCenterRoleChangeFailure => 'Non è stato possibile completare il cambio ruolo. Controlla lo stato dell’account e riprova.';

  @override
  String get adminCenterChangingRole => 'Cambio ruolo';

  @override
  String get adminCenterConfirmRoleChange => 'Conferma cambio ruolo';

  @override
  String get adminCenterRoleUser => 'Utente';

  @override
  String get adminCenterRoleModerator => 'Moderatore';

  @override
  String get adminCenterRoleAdmin => 'Admin';

  @override
  String get adminCenterAccountStatusActive => 'Attivo';

  @override
  String get adminCenterAccountStatusSuspended => 'Sospeso';

  @override
  String get adminCenterAccountStatusDeleted => 'Eliminato';

  @override
  String get adminCenterVerificationStatusNone => 'Nessuna';

  @override
  String get adminCenterVerificationStatusPending => 'In attesa';

  @override
  String get adminCenterVerificationStatusRejected => 'Rifiutata';

  @override
  String get adminCenterVerificationNotVerified => 'Non verificata';

  @override
  String get adminCenterVerificationLevel1 => 'Livello 1';

  @override
  String get adminCenterVerificationLevel2 => 'Livello 2';

  @override
  String get adminCenterReportSingular => 'segnalazione';

  @override
  String get adminCenterReportPlural => 'segnalazioni';

  @override
  String get adminCenterUserSingular => 'utente';

  @override
  String get adminCenterUserPlural => 'utenti';

  @override
  String get adminCenterPoll => 'Vote';

  @override
  String get adminCenterPost => 'Voce';

  @override
  String get adminCenterUnknown => 'Sconosciuto';

  @override
  String get adminCenterContentHidden => 'Contenuto nascosto';

  @override
  String get adminCenterContentVisible => 'Contenuto visibile';

  @override
  String get adminCenterReportedByLabel => 'Segnalato da';

  @override
  String get adminCenterContentOwnerLabel => 'Autore contenuto';

  @override
  String get adminCenterReviewReportAction => 'Revisiona segnalazione';

  @override
  String get adminCenterAdminDecisionAction => 'Decisione admin';

  @override
  String get adminCenterRestoreContentAction => 'Ripristina contenuto';

  @override
  String get adminCenterHideContentAction => 'Nascondi contenuto';

  @override
  String get adminCenterOpenProfileAction => 'Apri profilo';

  @override
  String get adminCenterOpenContentAction => 'Apri contenuto';

  @override
  String get adminCenterDecisionNoViolation => 'Nessuna violazione';

  @override
  String get adminCenterDecisionViolationConfirmed => 'Violazione confermata';

  @override
  String get adminCenterDecisionEscalateToAdmin => 'Escala all’admin';

  @override
  String get adminCenterResolutionNoAccountAction => 'Nessuna azione sull’account';

  @override
  String get adminCenterResolutionAccountSuspended => 'Account sospeso';

  @override
  String get adminCenterResolutionLogoutForced => 'Logout forzato';

  @override
  String get adminCenterResolutionAccountDeleted => 'Account eliminato';

  @override
  String get adminCenterReviewerLabel => 'Revisore';

  @override
  String get adminCenterDecisionDescriptionNoViolation => 'Archivia la segnalazione perché il contenuto non viola le regole attuali.';

  @override
  String get adminCenterDecisionDescriptionViolation => 'Conferma una violazione e mantiene il caso in revisione per l’azione sul contenuto prevista in AC8.5.';

  @override
  String get adminCenterDecisionDescriptionEscalation => 'Escala il caso per una revisione amministrativa a livello di account.';

  @override
  String get adminCenterChooseModerationOutcome => 'Scegli l’esito di moderazione per questa segnalazione.';

  @override
  String get adminCenterDecisionAlreadyRecordedFailure => 'Non è stato possibile registrare la decisione. La segnalazione potrebbe essere già stata revisionata. Aggiorna la coda e riprova.';

  @override
  String get adminCenterDecisionLabel => 'Decisione';

  @override
  String get adminCenterReportReasonLabel => 'Motivo segnalazione';

  @override
  String get adminCenterReviewNoteLabel => 'Nota di revisione';

  @override
  String get adminCenterReviewNoteHint => 'Spiega le prove e la decisione di moderazione';

  @override
  String get adminCenterRecordingDecision => 'Registrazione decisione';

  @override
  String get adminCenterConfirmDecision => 'Conferma decisione';

  @override
  String get adminCenterAdministratorDecisionTitle => 'Decisione amministratore';

  @override
  String get adminCenterResolutionDescriptionNoAction => 'Chiude la segnalazione escalata senza modificare l’account.';

  @override
  String get adminCenterResolutionDescriptionSuspended => 'Chiude la segnalazione dopo che una sospensione riuscita è stata registrata nel registro attività.';

  @override
  String get adminCenterResolutionDescriptionLogout => 'Chiude la segnalazione dopo che un logout forzato riuscito è stato registrato nel registro attività.';

  @override
  String get adminCenterResolutionDescriptionDeleted => 'Chiude la segnalazione dopo che un’eliminazione account riuscita è stata registrata nel registro attività.';

  @override
  String get adminCenterChooseFinalOutcome => 'Scegli l’esito amministrativo finale per questa escalation.';

  @override
  String get adminCenterAdminResolutionFailure => 'Non è stato possibile registrare la decisione amministrativa. Aggiorna la coda e riprova.';

  @override
  String get adminCenterAdminResolutionRequiresAction => 'Completa prima l’azione account corrispondente, poi torna a questa segnalazione e registra la decisione amministrativa finale.';

  @override
  String get adminCenterEscalationNoteLabel => 'Nota escalation';

  @override
  String get adminCenterFinalOutcomeLabel => 'Esito finale';

  @override
  String get adminCenterAdministratorNoteLabel => 'Nota amministratore';

  @override
  String get adminCenterAdministratorNoteHint => 'Spiega la decisione finale a livello di account';

  @override
  String get adminCenterHideContentFailure => 'Non è stato possibile nascondere il contenuto. Aggiorna la coda segnalazioni e riprova.';

  @override
  String get adminCenterRestoreContentFailure => 'Non è stato possibile ripristinare il contenuto. Aggiorna la coda segnalazioni e riprova.';

  @override
  String get adminCenterHideContentWarning => 'Rimuove il contenuto segnalato dall’accesso pubblico. L’azione potrà essere annullata dal filtro delle segnalazioni risolte.';

  @override
  String get adminCenterRestoreContentWarning => 'Rende nuovamente pubblico il contenuto segnalato.';

  @override
  String get adminCenterActionReasonLabel => 'Motivo azione';

  @override
  String get adminCenterHideContentReasonHint => 'Spiega perché il contenuto deve essere nascosto';

  @override
  String get adminCenterRestoreContentReasonHint => 'Spiega perché il contenuto può essere ripristinato';

  @override
  String get adminCenterHidingContent => 'Contenuto in occultamento';

  @override
  String get adminCenterRestoringContent => 'Ripristino contenuto';

  @override
  String get adminCenterReportedProfileTitle => 'Profilo segnalato';

  @override
  String get adminCenterReportedProfileNotice => 'Queste informazioni del profilo provengono dalla coda protetta delle segnalazioni. Le azioni amministrative sull’account restano separate.';

  @override
  String get adminCenterCouldNotRefreshIndicators => 'Non è stato possibile aggiornare gli indicatori.';

  @override
  String get adminCenterCouldNotRefreshAccount => 'Non è stato possibile aggiornare i dettagli account.';

  @override
  String get adminCenterReportAlreadyReviewed => 'Questa segnalazione è già stata revisionata o non è più in attesa.';

  @override
  String get adminCenterReportNotAwaitingAdmin => 'Questa segnalazione non è in attesa di una decisione amministrativa.';

  @override
  String get adminCenterConfirmedViolationRequired => 'È necessaria una violazione confermata prima di cambiare la visibilità del contenuto.';

  @override
  String get adminCenterContentHiddenSuccess => 'Il contenuto segnalato è stato nascosto.';

  @override
  String get adminCenterContentRestoredSuccess => 'Il contenuto segnalato è stato ripristinato.';

  @override
  String get adminCenterMissingContentId => 'Manca l’identificativo del contenuto originale.';

  @override
  String get adminCenterUnsupportedTargetType => 'Questa segnalazione ha un tipo di destinatario non supportato.';

  @override
  String get adminCenterOriginalContentUnavailable => 'Il contenuto originale non è più disponibile.';

  @override
  String get adminCenterNoReportedProfile => 'Nessun profilo segnalato è associato a questo contenuto.';

  @override
  String adminCenterRoleChangedSuccess(String previousRole, String newRole) {
    return 'Ruolo tecnico cambiato da $previousRole a $newRole. Il destinatario è stato disconnesso e deve accedere di nuovo.';
  }

  @override
  String adminCenterIdentityChangedSuccess(String actorType, String verificationLevel) {
    return 'Identità pubblica cambiata in $actorType con $verificationLevel.';
  }

  @override
  String adminCenterAccountSuspendedSuccess(String dateTime) {
    return 'Account sospeso fino al $dateTime. Il destinatario è stato disconnesso.';
  }

  @override
  String adminCenterReportDecisionRecorded(String decision) {
    return 'Decisione sulla segnalazione registrata: $decision.';
  }

  @override
  String adminCenterAdministratorDecisionRecorded(String decision) {
    return 'Decisione amministrativa registrata: $decision.';
  }

  @override
  String adminCenterUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count utenti',
      one: '$count utente',
    );
    return '$_temp0';
  }

  @override
  String adminCenterReportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count segnalazioni',
      one: '$count segnalazione',
    );
    return '$_temp0';
  }

  @override
  String adminCenterAccountValue(String account) {
    return 'Account: $account';
  }

  @override
  String adminCenterSuspendedUntilValue(String dateTime) {
    return 'Sospeso fino al: $dateTime';
  }

  @override
  String adminCenterSuspendConfirmation(String dateTime) {
    return 'Confermo la sospensione fino al $dateTime e la terminazione immediata delle sessioni attive.';
  }

  @override
  String adminCenterAccountIdValue(String accountId) {
    return 'ID account: $accountId';
  }

  @override
  String adminCenterCurrentRoleValue(String role) {
    return 'Attuale: $role';
  }

  @override
  String adminCenterTargetFallback(String targetType, String targetId) {
    return '$targetType $targetId';
  }

  @override
  String adminCenterMinimumCharactersRequired(int count) {
    return 'È richiesta una nota di almeno $count caratteri.';
  }

  @override
  String adminCenterMinimumReasonCharactersRequired(int count) {
    return 'È richiesto un motivo di almeno $count caratteri.';
  }

  @override
  String adminCenterPageOf(int currentPage, int totalPages) {
    return 'Pagina $currentPage di $totalPages';
  }

  @override
  String get profilePublicProfileSectionTitle => 'Profilo pubblico';

  @override
  String get profileIdentityVerificationSectionTitle => 'Identità e verifica';

  @override
  String get profilePreferencesSectionTitle => 'Preferenze';

  @override
  String get profileNotificationsSectionTitle => 'Notifiche';

  @override
  String get profileActivitySectionTitle => 'Attività personale';

  @override
  String get profileSecurityAccountSectionTitle => 'Sicurezza e account';

  @override
  String get profileThemeTitle => 'Tema';

  @override
  String get profileThemeSystem => 'Sistema';

  @override
  String get profileThemeSystemDescription => 'Segue il tema del dispositivo';

  @override
  String get profileThemeLight => 'Chiaro';

  @override
  String get profileThemeDark => 'Scuro';

  @override
  String get profileMyPollsTitle => 'Vote';

  @override
  String get profileMyPostsTitle => 'Voce';

  @override
  String get profileMyCommentsTitle => 'I miei commenti';

  @override
  String get profileMyFavoritesTitle => 'I miei salvati';

  @override
  String get profileAccountConnectionsTitle => 'Seguiti e follower';

  @override
  String get accountConnectionsFollowingTab => 'Seguiti';

  @override
  String get accountConnectionsFollowersTab => 'Follower';

  @override
  String get accountConnectionsEmptyFollowing => 'Non segui ancora nessun account.';

  @override
  String get accountConnectionsEmptyFollowers => 'Non hai ancora follower.';

  @override
  String get accountConnectionsLoadError => 'Impossibile caricare gli account. Riprova.';

  @override
  String get profileMyFollowedScopesTitle => 'Le mie aree seguite';

  @override
  String get profileLogoutAction => 'Logout';

  @override
  String get profileLogoutDescription => 'Esci dall’account corrente';

  @override
  String get profileLogoutDialogTitle => 'Logout';

  @override
  String get profileLogoutDialogMessage => 'Vuoi davvero uscire dal tuo account?';

  @override
  String get profileLogoutCancelButton => 'Annulla';

  @override
  String get profileLogoutConfirmButton => 'Logout';

  @override
  String get publicProfilePageTitle => 'Profilo pubblico';

  @override
  String get publicProfileUserFallback => 'Utente';

  @override
  String get publicProfileNoBio => 'Nessuna biografia disponibile.';

  @override
  String get publicProfileResidenceLabel => 'Residenza';

  @override
  String get publicProfileResidenceUnknown => 'Non indicata';

  @override
  String get publicProfileMemberSinceLabel => 'Membro dal';

  @override
  String get publicProfileContentSectionTitle => 'Contenuti pubblici';

  @override
  String get publicProfilePollsAction => 'Vote';

  @override
  String get publicProfilePostsAction => 'Voce';

  @override
  String get publicProfileBlockUserAction => 'Blocca utente';

  @override
  String get publicProfileLoadError => 'Impossibile caricare il profilo.';

  @override
  String get publicProfileNotFound => 'Profilo non disponibile.';

  @override
  String get publicProfileUnblockUserAction => 'Sblocca utente';

  @override
  String get publicProfileBlockDialogTitle => 'Bloccare questo utente?';

  @override
  String get publicProfileBlockDialogMessage => 'Potrai sbloccarlo in seguito dal suo profilo pubblico.';

  @override
  String get publicProfileUnblockDialogTitle => 'Sbloccare questo utente?';

  @override
  String get publicProfileUnblockDialogMessage => 'L\'utente non sarà più presente nella tua lista dei blocchi.';

  @override
  String get publicProfileBlockSuccess => 'Utente bloccato.';

  @override
  String get publicProfileUnblockSuccess => 'Utente sbloccato.';

  @override
  String get publicProfileBlockError => 'Impossibile aggiornare il blocco. Riprova.';

  @override
  String get publicProfileFollowersLabel => 'follower';

  @override
  String get publicProfileFollowingLabel => 'seguiti';

  @override
  String get publicProfileFollowAction => 'Segui';

  @override
  String get publicProfileUnfollowAction => 'Non seguire più';

  @override
  String get publicProfileFollowSuccess => 'Account seguito.';

  @override
  String get publicProfileUnfollowSuccess => 'Account non più seguito.';

  @override
  String get publicProfileFollowError => 'Impossibile aggiornare il follow. Riprova.';

  @override
  String get publicProfileFollowRetry => 'Ricarica informazioni follow';

  @override
  String get contentLanguageFieldLabel => 'Lingua del contenuto';

  @override
  String get contentLanguageFieldHelper => 'Indica la lingua in cui hai scritto il contenuto.';

  @override
  String get contentLanguageUndetermined => 'Non specificata';

  @override
  String get createPollAdvancedOptionsTitle => 'Opzioni avanzate';

  @override
  String get createPollAdvancedOptionsSubtitle => 'Anonimato, visibilità risultati, modifica voto e quorum.';

  @override
  String get onboardingSkipButton => 'Salta';

  @override
  String get onboardingNextButton => 'Avanti';

  @override
  String get onboardingStartButton => 'Inizia';

  @override
  String get onboardingPollTitle => 'Vote';

  @override
  String get onboardingPollDescription => 'Partecipa a un Vote sui temi che ti interessano oppure creane uno per raccogliere l’opinione della community.';

  @override
  String get onboardingHeatIceTitle => 'Heat e Ice';

  @override
  String get onboardingHeatIceDescription => 'Usa Heat e Ice per indicare quanto un contenuto sta attirando il tuo interesse.';

  @override
  String get onboardingCivicMapTitle => 'Civic Map';

  @override
  String get onboardingCivicMapDescription => 'Esplora Vote, Voce e News sulla mappa e scopri cosa succede nei diversi territori.';

  @override
  String get onboardingGeoScopeTitle => 'GeoScope';

  @override
  String get onboardingGeoScopeDescription => 'Scegli il livello geografico che vuoi seguire: mondo, paese o città.';

  @override
  String get onboardingVerificationTitle => 'Verifica identità';

  @override
  String get onboardingVerificationDescription => 'Alcuni Vote possono richiedere un livello di verifica per proteggere l’integrità della votazione.';

  @override
  String get pollDetail_voteReceiptButton => 'Ricevuta voto';

  @override
  String get pollDetail_voteReceiptTitle => 'Ricevuta del voto';

  @override
  String get pollDetail_voteReceiptIdLabel => 'ID ricevuta';

  @override
  String get pollDetail_voteReceiptDateLabel => 'Registrato';

  @override
  String get pollDetail_voteReceiptPrivacy => 'La ricevuta conferma la registrazione del voto senza mostrare la scelta effettuata.';

  @override
  String get pollDetail_voteReceiptCloseButton => 'Chiudi';

  @override
  String get profileBiometricUnlockTitle => 'Sblocco biometrico';

  @override
  String get profileBiometricUnlockDescription => 'Protegge la sessione ricordata con impronta digitale o riconoscimento biometrico del dispositivo.';

  @override
  String get profileBiometricRequiresRememberMe => 'Richiede Remember Me attivo.';

  @override
  String get profileBiometricUnavailable => 'Biometria non disponibile o non configurata su questo dispositivo.';

  @override
  String get profileBiometricEnableReason => 'Conferma la biometria per attivare lo sblocco di Social Vote.';

  @override
  String get profileBiometricEnabledMessage => 'Sblocco biometrico attivato.';

  @override
  String get profileBiometricDisabledMessage => 'Sblocco biometrico disattivato.';

  @override
  String get profileBiometricAuthFailedMessage => 'Autenticazione biometrica non completata.';

  @override
  String get biometricLockTitle => 'Social Vote è bloccato';

  @override
  String get biometricLockMessage => 'Usa la biometria del dispositivo per sbloccare la sessione ricordata.';

  @override
  String get biometricUnlockButton => 'Sblocca';

  @override
  String get biometricUsePasswordButton => 'Usa password';

  @override
  String get biometricUnlockReason => 'Sblocca la tua sessione Social Vote.';

  @override
  String get biometricUnlockFailedMessage => 'Sblocco non riuscito. Riprova o usa la password.';

  @override
  String get adminCenterOperationalActivityTitle => 'Attività operativa';

  @override
  String get adminCenterOperationalActivitySubtitle => 'Contatori aggregati. Nessun tracciamento di presenza online.';

  @override
  String get adminCenterLast24HoursLabel => '24 ore';

  @override
  String get adminCenterLast7DaysLabel => '7 giorni';

  @override
  String get adminCenterNewUsersMetric => 'Nuove registrazioni';

  @override
  String get adminCenterRecentSignInsMetric => 'Accessi recenti';

  @override
  String get adminCenterPollsCreatedMetric => 'Vote creati';

  @override
  String get adminCenterPostsCreatedMetric => 'Voci create';

  @override
  String get adminCenterAdminActionsMetric => 'Azioni amministrative';

  @override
  String get authPublicNameHelper => 'È il nome che vedranno gli altri utenti. Il nome utente viene creato automaticamente.';

  @override
  String get adminCenterRefreshMarkersTooltip => 'Aggiorna marker del globo';

  @override
  String get adminCenterQuickActionsTitle => 'Azioni rapide account';

  @override
  String get adminCenterModerationSnapshotTitle => 'Riepilogo moderazione e attività';

  @override
  String get adminCenterReportsReceivedMetric => 'Segnalazioni ricevute';

  @override
  String get adminCenterPendingReportsMetric => 'Segnalazioni in attesa';

  @override
  String get adminCenterConfirmedViolationsMetric => 'Violazioni confermate';

  @override
  String get adminCenterReportsFiledMetric => 'Segnalazioni inviate';

  @override
  String get adminCenterCommentsCreatedMetric => 'Commenti creati';

  @override
  String get adminCenterAdminActionsOnAccountMetric => 'Azioni admin sull’account';

  @override
  String get adminCenterLastReportReceivedLabel => 'Ultima segnalazione ricevuta';

  @override
  String get adminCenterOpenFullAccountAction => 'Apri controllo completo account';

  @override
  String get profileAppLanguageGerman => 'Tedesco';

  @override
  String get discoveryPageTitle => 'Esplora';

  @override
  String get organizationWorkspaceTitle => 'Workspace organizzazione';

  @override
  String get organizationPilotBannerTitle => 'Pilot gratuito';

  @override
  String get organizationPilotBannerBody => 'Durante il pilot le Sessions sono gratuite. Alcune funzioni professionali potranno diventare a pagamento in futuro; il billing non è attivo ora.';

  @override
  String get organizationVerifiedLabel => 'Organizzazione verificata';

  @override
  String get organizationEditProfile => 'Modifica profilo organizzazione';

  @override
  String get organizationCreateSession => 'Nuova Session';

  @override
  String get organizationNoSessions => 'Nessuna Session. Creane una per una riunione, workshop o evento.';

  @override
  String get organizationSessionsTitle => 'Sessions live';

  @override
  String get organizationRequiresVerificationTitle => 'Serve un’organizzazione verificata';

  @override
  String get organizationRequiresVerificationBody => 'Questo workspace è disponibile solo agli account approvati da Social Vote come organizzazione verificata.';

  @override
  String get organizationProfileEditorTitle => 'Profilo organizzazione';

  @override
  String get organizationLegalName => 'Denominazione legale';

  @override
  String get organizationPublicName => 'Nome pubblico';

  @override
  String get organizationType => 'Tipo di organizzazione';

  @override
  String get organizationCountryCode => 'Codice Paese';

  @override
  String get organizationCity => 'Città';

  @override
  String get organizationWebsite => 'Sito ufficiale';

  @override
  String get organizationDescription => 'Descrizione';

  @override
  String get organizationUploadCover => 'Cambia copertina';

  @override
  String get organizationUploadLogo => 'Cambia logo';

  @override
  String get organizationMediaUpdated => 'Immagine organizzazione aggiornata.';

  @override
  String get organizationNamesRequired => 'Denominazione legale e nome pubblico sono obbligatori.';

  @override
  String get organizationTypeAssociation => 'Associazione';

  @override
  String get organizationTypeNonprofit => 'Non profit';

  @override
  String get organizationTypeCompany => 'Azienda';

  @override
  String get organizationTypeCooperative => 'Cooperativa';

  @override
  String get organizationTypeSports => 'Organizzazione sportiva';

  @override
  String get organizationTypePublicBody => 'Ente pubblico';

  @override
  String get organizationTypeCommittee => 'Comitato / gruppo';

  @override
  String get organizationTypeOther => 'Altro';

  @override
  String get sessionCreateTitle => 'Crea Session live';

  @override
  String get sessionTitleLabel => 'Titolo Session';

  @override
  String get sessionExpectedParticipants => 'Partecipanti previsti';

  @override
  String get sessionAccessMode => 'Accesso partecipanti';

  @override
  String get sessionAccessOpen => 'Anonima aperta';

  @override
  String get sessionAccessOpenHint => 'Chiunque abbia link/codice può entrare. La prevenzione dei duplicati è best-effort: questa modalità non garantisce una persona-un voto.';

  @override
  String get sessionAccessControlled => 'Anonima controllata';

  @override
  String get sessionAccessControlledHint => 'Usa Access Pass anonimi monouso. Social Vote conserva solo l’hash dell’Access Pass e non collega le scelte di voto alle credenziali dei partecipanti.';

  @override
  String get sessionResultsVisibility => 'Visibilità risultati';

  @override
  String get sessionResultsLive => 'Live';

  @override
  String get sessionResultsAfterVote => 'Dopo il voto del partecipante';

  @override
  String get sessionResultsAfterClose => 'Dopo la chiusura della domanda';

  @override
  String get sessionResultsOrganizerOnly => 'Solo organizzatore';

  @override
  String get sessionCreateAction => 'Crea Session';

  @override
  String get sessionPilotLimit => 'Limite pilot: da 1 a 250 partecipanti per Session.';

  @override
  String get sessionStatusDraft => 'Bozza';

  @override
  String get sessionStatusOpen => 'Aperta';

  @override
  String get sessionStatusClosed => 'Chiusa';

  @override
  String get sessionJoinCode => 'Codice accesso';

  @override
  String get sessionShareJoin => 'Condividi link';

  @override
  String get sessionCopyJoinLink => 'Copia link';

  @override
  String get sessionGenerateTokens => 'Genera Access Pass';

  @override
  String get sessionGenerateTokensCount => 'Numero di Access Pass';

  @override
  String get sessionTokensOneTimeTitle => 'Salva ora queste credenziali';

  @override
  String get sessionTokensOneTimeBody => 'Gli Access Pass in chiaro vengono mostrati solo in questo risultato del batch. Social Vote conserva solo gli hash. Copiali e distribuiscili in modo sicuro.';

  @override
  String get sessionCopyTokens => 'Copia tutti i link';

  @override
  String get sessionTokensSavedAction => 'Li ho salvati';

  @override
  String get sessionOpenAction => 'Apri Session';

  @override
  String get sessionCloseAction => 'Chiudi Session';

  @override
  String get sessionCloseConfirm => 'Chiudere le votazioni e creare lo snapshot immutabile del Verified Result?';

  @override
  String get sessionQuestionsTitle => 'Domande';

  @override
  String get sessionAddQuestion => 'Aggiungi domanda';

  @override
  String get sessionQuestionTitle => 'Domanda';

  @override
  String get sessionQuestionType => 'Tipo di domanda';

  @override
  String get sessionTypeYesNo => 'Sì / No';

  @override
  String get sessionTypeSingle => 'Una risposta';

  @override
  String get sessionTypeMultiple => 'Più risposte';

  @override
  String get sessionOptions => 'Opzioni';

  @override
  String get sessionOptionHint => 'Una opzione per riga.';

  @override
  String get sessionMinSelections => 'Selezioni minime';

  @override
  String get sessionMaxSelections => 'Selezioni massime';

  @override
  String get sessionAddAction => 'Aggiungi';

  @override
  String get sessionOpenQuestion => 'Apri domanda';

  @override
  String get sessionCloseQuestion => 'Chiudi domanda';

  @override
  String get sessionNoQuestions => 'Nessuna domanda.';

  @override
  String get sessionPresenterTitle => 'Presentazione';

  @override
  String get sessionParticipantTitle => 'Social Vote Live';

  @override
  String get sessionJoinAction => 'Entra nella Session';

  @override
  String get sessionTokenLabel => 'Token partecipante';

  @override
  String get sessionTokenHint => 'SV-…';

  @override
  String get sessionWaitingQuestion => 'In attesa che l’organizzatore apra una domanda…';

  @override
  String get sessionVoteAction => 'Invia voto';

  @override
  String get sessionVoteReceived => 'Voto ricevuto';

  @override
  String get sessionResultsUnavailable => 'I risultati non sono ancora visibili secondo la regola scelta per questa Session.';

  @override
  String get sessionPrivacyNotice => 'L’organizzatore definisce finalità operative e domande della Session. Social Vote tratta i dati tecnici necessari a fornire e proteggere il servizio. Le modalità anonime non mostrano all’organizzatore il collegamento tra credenziale e scelta. I ruoli privacy possono dipendere dal contesto e dagli accordi applicabili.';

  @override
  String get sessionNonBindingNotice => 'Le Sessions pilot servono per consultazione e partecipazione. Non sono elezioni legali, votazioni statutarie o certificazioni legalmente vincolanti.';

  @override
  String get sessionOptionYes => 'Sì';

  @override
  String get sessionOptionNo => 'No';

  @override
  String get verifiedResultTitle => 'Verified Result';

  @override
  String get verifiedResultValid => 'Controllo integrità superato';

  @override
  String get verifiedResultInvalid => 'Controllo integrità non valido';

  @override
  String get verifiedResultReportId => 'ID report';

  @override
  String get verifiedResultHash => 'Hash risultato SHA-256';

  @override
  String get verifiedResultGeneratedBy => 'Generato e sigillato a livello di integrità da Social Vote';

  @override
  String get verifiedResultNotLegalCertificate => 'È un report aggregato verificabile, non un certificato legale né una certificazione di elezione legalmente vincolante.';

  @override
  String get verifiedResultShare => 'Condividi link di verifica';

  @override
  String sessionResponses(int count) {
    return '$count risposte';
  }

  @override
  String sessionResultVotes(int count) {
    return '$count voti';
  }

  @override
  String get organizationVerifiedIdentityLocked => 'Nome e Paese fanno parte dell’identità verificata dell’organizzazione. Per modificarli sarà necessaria una nuova verifica. Puoi cambiare liberamente copertina, logo, tipo, città, sito e descrizione.';

  @override
  String get verifiedResultOpenedAt => 'Apertura Session';

  @override
  String get verifiedResultEligibleCredentials => 'Credenziali abilitate';

  @override
  String get verifiedResultIntegritySeal => 'Sigillo di integrità Social Vote';

  @override
  String get organizationVerifiedNameLocked => 'Nome verificato e Paese sono bloccati. Per cambiarli serve una nuova revisione di verifica.';

  @override
  String get sessionRetentionLabel => 'Conservazione schede grezze';

  @override
  String get sessionRetention24h => '24 ore';

  @override
  String get sessionRetention7d => '7 giorni';

  @override
  String get sessionRetention30d => '30 giorni';

  @override
  String sessionRetentionValue(String value) {
    return 'Conservazione schede grezze: $value';
  }

  @override
  String get verifiedResultPrintPdf => 'Scarica PDF';

  @override
  String get verifiedResultPdfError => 'Impossibile scaricare il PDF. Riprova.';

  @override
  String get verifiedResultRestrictedTitle => 'Risultato riservato';

  @override
  String get verifiedResultRestrictedBody => 'Questo Verified Result non è disponibile pubblicamente. Accedi con un account autorizzato dell’organizzazione per visualizzarlo.';

  @override
  String get verifiedResultPrivateVerificationTitle => 'Verifica pubblica non disponibile';

  @override
  String get verifiedResultPrivateVerificationBody => 'Questo risultato è riservato all’organizzatore. ID report, SHA-256 e controllo di integrità restano disponibili nel report autorizzato.';

  @override
  String get organizationAccountSectionTitle => 'Le tue organizzazioni';

  @override
  String get organizationManageAction => 'Gestisci';

  @override
  String get organizationViewPublicProfileAction => 'Visualizza profilo';

  @override
  String get organizationOfficialWebsiteAction => 'Sito ufficiale';

  @override
  String get organizationVerificationIntro => 'La verifica riguarda sia l’esistenza dell’organizzazione sia il tuo ruolo nel rappresentarla. I dati inviati saranno revisionati da Social Vote prima dell’approvazione.';

  @override
  String get organizationVerificationLegalName => 'Denominazione legale';

  @override
  String get organizationVerificationPublicName => 'Nome pubblico';

  @override
  String get organizationVerificationType => 'Tipo di organizzazione';

  @override
  String get organizationVerificationCountry => 'Paese';

  @override
  String get organizationVerificationCountryRequired => 'Seleziona il Paese dell’organizzazione.';

  @override
  String get organizationVerificationCity => 'Città';

  @override
  String get organizationVerificationWebsite => 'Sito ufficiale';

  @override
  String get organizationVerificationRepresentativeRole => 'Il tuo ruolo nell’organizzazione';

  @override
  String get organizationVerificationRegistryId => 'Registro / CF / P.IVA / identificativo';

  @override
  String get organizationVerificationAuthorityNote => 'Come possiamo verificare che puoi rappresentarla?';

  @override
  String get organizationVerificationAuthorityHelper => 'Indica in modo breve il tuo ruolo o l’evidenza che un Admin può verificare durante il pilot.';

  @override
  String get organizationVerificationRequired => 'Campo obbligatorio.';

  @override
  String get sessionControlRoomTitle => 'Regia Session';

  @override
  String get sessionSectionLive => 'Live';

  @override
  String get sessionSectionQuestions => 'Domande';

  @override
  String get sessionSectionAccess => 'Accessi';

  @override
  String get sessionSectionSettings => 'Impostazioni';

  @override
  String get sessionStageAction => 'Apri Stage';

  @override
  String get sessionAccessPassesTitle => 'Pass di accesso partecipanti';

  @override
  String get sessionAccessPassesSubtitle => 'Ogni pass apre questa Session Anonima controllata senza obbligare il partecipante a digitare la credenziale lunga. Social Vote non conserva il pass in chiaro.';

  @override
  String get sessionAccessPass => 'Pass di accesso';

  @override
  String get sessionAccessPassDetected => 'Pass di accesso rilevato';

  @override
  String get sessionAccessPassAutomatic => 'Il tuo pass personale è pronto. Continua per entrare nella Session in modo anonimo.';

  @override
  String get sessionAccessPassFallback => 'Inserisci il pass manualmente';

  @override
  String get sessionAccessPassInvalid => 'Questo pass non è valido, non è più disponibile oppure la Session non è aperta.';

  @override
  String get sessionAccessPassPrintWarning => 'Stampa, salva o distribuisci ora questi pass. Uscendo da questa schermata Social Vote non potrà mostrare di nuovo i pass in chiaro.';

  @override
  String get sessionExistingPassesHidden => 'Per sicurezza i Pass già generati non possono essere mostrati di nuovo in chiaro. Per ottenere nuovi link o QR personali, genera nuovi Access Pass.';

  @override
  String get sessionCopyPassLinks => 'Copia tutti i link';

  @override
  String get sessionCopyPassLink => 'Copia questo link';

  @override
  String get sessionControlledNeedsAccessPass => 'Prima di aprire una Session controllata, genera almeno un Access Pass.';

  @override
  String get sessionJoinedParticipants => 'Credenziali entrate';

  @override
  String get sessionAccessesUsed => 'Accessi che hanno votato';

  @override
  String get sessionBallotsRecorded => 'Schede registrate';

  @override
  String get sessionQuestionsCompleted => 'Domande completate';

  @override
  String get sessionCurrentQuestion => 'Domanda corrente';

  @override
  String get sessionNoOpenQuestionTitle => 'Nessuna domanda aperta';

  @override
  String get sessionNoOpenQuestionBody => 'I partecipanti sono collegati e in attesa. Apri la prossima domanda quando sei pronto.';

  @override
  String get sessionNotStartedTitle => 'Session non ancora iniziata';

  @override
  String get sessionNotStartedBody => 'La Session esiste ma non è ancora aperta. Tieni questa pagina aperta e attendi che l’organizzatore la avvii.';

  @override
  String get sessionNoAccountRequired => 'Nessun account Social Vote richiesto';

  @override
  String get sessionReceiptDetails => 'Dettagli ricevuta';

  @override
  String get sessionOpenAccessInstructions => 'Mostra o condividi questo QR. Chiunque abbia il link può entrare mentre la Session è aperta.';

  @override
  String get sessionControlledAccessInstructions => 'Crea pass personali e consegnane uno a ogni partecipante. Il QR di ogni pass contiene automaticamente la credenziale.';

  @override
  String get sessionControlRoomHint => 'Gestisci accessi, domande, Stage da proiettare e Verified Result finale da un unico punto.';

  @override
  String get sessionPresenterScreenTitle => 'Stage live';

  @override
  String get sessionStageWaiting => 'In attesa della prossima domanda';

  @override
  String get sessionStageScan => 'Scansiona per entrare nella Session';

  @override
  String get sessionConfigurationTitle => 'Configurazione Session';

  @override
  String get sessionAccessRecommended => 'Consigliata per riunioni controllate';

  @override
  String get sessionCreateIntroTitle => 'Configura la riunione';

  @override
  String get sessionCreateIntroBody => 'Scegli come entrano i partecipanti, quando diventano visibili i risultati e per quanto tempo conservare le schede grezze. Queste regole sono applicate dal backend.';

  @override
  String get verifiedCertificateNumber => 'Numero certificato';

  @override
  String get verifiedCertificateStatus => 'Stato integrità';

  @override
  String get verifiedCertificateIntegrityVerified => 'INTEGRITÀ VERIFICATA';

  @override
  String get verifiedCertificateIntegrityFailed => 'CONTROLLO INTEGRITÀ FALLITO';

  @override
  String get verifiedCertificateOrganizationSection => 'Organizzazione';

  @override
  String get verifiedCertificateSessionSection => 'Session';

  @override
  String get verifiedCertificateParticipationSection => 'Partecipazione';

  @override
  String get verifiedCertificateResultsSection => 'Risultati verificati';

  @override
  String get verifiedCertificateIntegritySection => 'Integrità del risultato';

  @override
  String get verifiedCertificateLegalName => 'Denominazione legale';

  @override
  String get verifiedCertificateOrganizationType => 'Tipo organizzazione';

  @override
  String get verifiedCertificateLocation => 'Località';

  @override
  String get verifiedCertificateWebsite => 'Sito';

  @override
  String get verifiedCertificateVerification => 'Verifica';

  @override
  String get verifiedCertificateIssuedAt => 'Emissione certificato';

  @override
  String get verifiedCertificateAlgorithm => 'Algoritmo integrità';

  @override
  String get verifiedCertificateSchema => 'Schema report';

  @override
  String get verifiedCertificateJoinedCredentials => 'Credenziali entrate';

  @override
  String get verifiedCertificateBallotsTotal => 'Schede registrate';

  @override
  String get verifiedCertificateQuestionsTotal => 'Domande';

  @override
  String get verifiedCertificatePrivacyModel => 'Modello risultato anonimo';

  @override
  String get verifiedCertificatePrivacyText => 'Lo snapshot immutabile contiene solo risultati aggregati. Non contiene identità del partecipante, pass di accesso in chiaro, segreto partecipante o collegamenti tra una credenziale e la scelta espressa.';

  @override
  String get verifiedCertificateVerifyQr => 'Scansiona questo QR per verificare online il report.';

  @override
  String get organizationDashboardTitle => 'Panoramica organizzazione';

  @override
  String get organizationActiveSessions => 'Sessions live';

  @override
  String get organizationVerifiedReports => 'Report verificati';

  @override
  String get organizationTotalSessions => 'Sessions totali';

  @override
  String get sessionPrivacyPolicyAction => 'Leggi l’informativa sulla privacy';
}
