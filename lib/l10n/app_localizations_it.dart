// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Sociale Vote';

  @override
  String get voteButton => 'Vota';

  @override
  String get createPollPageTitle => 'Crea sondaggio';

  @override
  String get createPollPageSubtitle => 'Definisci un nuovo voto civico';

  @override
  String get createPollBasicInfoTitle => 'Informazioni di base';

  @override
  String get createPollBasicInfoSubtitle => 'Definisci i dettagli principali del sondaggio.';

  @override
  String get createPollTitleFieldLabel => 'Titolo *';

  @override
  String get createPollTitleFieldHelper => 'Una domanda o affermazione chiara e concisa.';

  @override
  String get createPollDescriptionFieldLabel => 'Descrizione (facoltativa)';

  @override
  String get createPollVotingModelTitle => 'Modello di voto';

  @override
  String get createPollVotingModelSubtitle => 'Scegli come verrà espresso il voto e le regole di base.';

  @override
  String get createPollTypeFieldLabel => 'Tipo di sondaggio';

  @override
  String createPollSelectionRules(int min, int max) {
    return 'Regole di selezione: minimo $min, massimo $max scelte (regolate automaticamente in base al tipo di sondaggio e alle opzioni).';
  }

  @override
  String get createPollAllowVoteChangeTitle => 'Consenti agli utenti di modificare il proprio voto';

  @override
  String get createPollAllowVoteChangeSubtitle => 'Fino alla chiusura del sondaggio.';

  @override
  String get createPollOptionsTitle => 'Opzioni';

  @override
  String get createPollOptionsSubtitle => 'Aggiungi almeno due opzioni tra cui gli utenti possano scegliere. I campi contrassegnati con * sono obbligatori.';

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
  String get createPollParticipationGeoScopeSubtitle => 'Limita questo sondaggio alle persone di uno specifico Paese.';

  @override
  String get createPollCountryFieldLabel => 'Paese per questo sondaggio';

  @override
  String get createPollCountryFieldHelper => 'Questo Paese definirà chi è autorizzato a partecipare a questo sondaggio (funzionalità futura).';

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
  String get createPollQuorumSubtitle => 'Se impostato, il sondaggio è considerato valido solo se viene raggiunto almeno questo numero di voti. Lascia vuoto per nessun quorum.';

  @override
  String get createPollQuorumMinVotesFieldLabel => 'Numero minimo di voti';

  @override
  String get createPollTimingTitle => 'Tempistiche';

  @override
  String get createPollTimingSubtitle => 'Definisci quando il sondaggio deve essere aperto alle votazioni.';

  @override
  String get createPollStartDateLabel => 'Data di inizio';

  @override
  String get createPollEndDateLabel => 'Data di fine';

  @override
  String get createPollChangeDateButtonLabel => 'Modifica';

  @override
  String get createPollTimingStatusInfo => 'Lo stato iniziale (aperto/pianificato/chiuso) sarà determinato automaticamente in base a queste date.';

  @override
  String get createPollSuccessMessage => 'Sondaggio creato con successo';

  @override
  String get createPollSubmitCreatingLabel => 'Creazione in corso...';

  @override
  String get createPollSubmitLabel => 'Crea sondaggio';

  @override
  String get createPollPollTypeYesNoLabel => 'Sì / No';

  @override
  String get createPollPollTypeSingleChoiceLabel => 'Scelta singola';

  @override
  String get createPollPollTypeMultipleChoiceLabel => 'Scelta multipla';

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
  String get createPollResultsVisibilityAlwaysLabel => 'Sempre visibili (mentre il sondaggio è aperto)';

  @override
  String get createPollResultsVisibilityAfterVoteLabel => 'Visibili solo dopo aver votato';

  @override
  String get createPollResultsVisibilityAfterCloseLabel => 'Visibili solo dopo la chiusura del sondaggio';

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
  String get homeSearchHint => 'Cerca città, Paese, sondaggi, notizie, pubblicazioni...';

  @override
  String get searchPageTitle => 'Cerca';

  @override
  String get searchInputHint => 'Cerca sondaggi, notizie, pubblicazioni...';

  @override
  String get searchClearTooltip => 'Cancella ricerca';

  @override
  String get searchTypeAll => 'Tutti';

  @override
  String get searchTypePolls => 'Sondaggi';

  @override
  String get searchTypeNews => 'Notizie';

  @override
  String get searchTypePosts => 'Pubblicazioni';

  @override
  String get searchSortHottest => 'Più caldi';

  @override
  String get searchSortLatest => 'Più recenti';

  @override
  String get searchPollStatusAll => 'Tutti i sondaggi';

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
  String get searchResultTypePoll => 'Sondaggio';

  @override
  String get searchResultTypeNews => 'Notizia';

  @override
  String get searchResultTypePost => 'Pubblicazione';

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
  String get homeTrendingTitle => 'Di tendenza';

  @override
  String get homeTrendingError => 'Impossibile caricare i contenuti di tendenza per quest’area.';

  @override
  String get homeTrendingEmpty => 'Nessun contenuto di tendenza per quest’area al momento.';

  @override
  String homeForYouTitle(Object scope) {
    return 'Per te ($scope)';
  }

  @override
  String get homeForYouError => 'Impossibile caricare i contenuti Per te per quest’area.';

  @override
  String get homeForYouEmpty => 'Nessun contenuto suggerito per te in quest’area al momento.';

  @override
  String homePollsTitle(Object scope) {
    return 'Sondaggi in evidenza ($scope)';
  }

  @override
  String get homePollsEmptyTitle => 'Nessun sondaggio per quest’area';

  @override
  String get homePollsEmptySubtitle => 'Non ci sono votazioni per quest’area.';

  @override
  String get homePollsViewAllButton => 'Vedi tutti i sondaggi';

  @override
  String homeNewsTitle(Object scope) {
    return 'Notizie principali ($scope)';
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
    return 'Discussioni ($scope)';
  }

  @override
  String get homeSocialErrorTitle => 'Impossibile caricare le discussioni';

  @override
  String get homeSocialErrorSubtitle => 'Si è verificato un problema nel caricamento delle discussioni per quest’area.';

  @override
  String get homeSocialEmptyTitle => 'Nessuna discussione per quest’area';

  @override
  String get homeSocialEmptySubtitle => 'Non ci sono discussioni per quest’area al momento.';

  @override
  String get homeSocialViewFeedButton => 'Vedi tutte le discussioni';

  @override
  String get pollDetail_title => 'Dettaglio sondaggio';

  @override
  String get pollDetail_removeFromFavoritesTooltip => 'Rimuovi dai preferiti';

  @override
  String get pollDetail_addToFavoritesTooltip => 'Aggiungi ai preferiti';

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
  String get pollDetail_statusClosedMessage => 'Questo sondaggio è chiuso.';

  @override
  String get pollDetail_statusScheduledMessage => 'Questo sondaggio non è ancora aperto.';

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
  String get pollDetail_resultsWhenClosed => 'I risultati saranno visibili alla chiusura del sondaggio.';

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
  String get pollList_title => 'Sondaggi';

  @override
  String get pollList_scopeWorld => 'Mondo';

  @override
  String get pollList_scopeCountryFallback => 'Paese';

  @override
  String get pollList_scopeCityFallback => 'Città';

  @override
  String get pollList_scopeDescriptionGlobal => 'Visualizzazione dei sondaggi globali.';

  @override
  String get pollList_scopeDescriptionCountry => 'Visualizzazione dei sondaggi per questo paese.';

  @override
  String get pollList_scopeDescriptionCity => 'Visualizzazione dei sondaggi per questa città.';

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
      other: '$count sondaggi',
      one: '1 sondaggio',
      zero: 'nessun sondaggio',
    );
    return '$scopeLabel · $_temp0';
  }

  @override
  String get pollList_createPollButton => 'Crea sondaggio';

  @override
  String get pollList_paginationHint => 'Scorri per caricare altri sondaggi…';

  @override
  String get pollList_emptyMessage => 'Nessun sondaggio che corrisponde a questo filtro per quest’area.';

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
  String get voteError_unauthorized => 'Non sei autorizzato a votare in questo sondaggio.';

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
  String get newsDetail_removeFromFavoritesTooltip => 'Rimuovi dai preferiti';

  @override
  String get newsDetail_addToFavoritesTooltip => 'Aggiungi ai preferiti';

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
  String get socialFeedTitle => 'Discussioni';

  @override
  String get socialFeedCreatePostButton => 'Crea post';

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
  String get homeScopeCityExampleHint => 'Es. Roma, São Paulo, Tehran';

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
  String get homeAccountMenuLabel => 'Account';

  @override
  String get homeThemeSystemMenuItem => 'Tema: sistema';

  @override
  String get homeThemeLightMenuItem => 'Tema: chiaro';

  @override
  String get homeThemeDarkMenuItem => 'Tema: scuro';

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
  String get postDetail_title => 'Dettaglio post';

  @override
  String get postDetail_favoriteUpdateError => 'Impossibile aggiornare i preferiti';

  @override
  String get postDetail_shareMessage => 'Apri Sociale_Vote per vedere questo post.';

  @override
  String get postDetail_shareError => 'Impossibile condividere il post';

  @override
  String get postDetail_editDialogTitle => 'Modifica post';

  @override
  String get postDetail_editTitleFieldLabel => 'Titolo';

  @override
  String get postDetail_editContentFieldLabel => 'Contenuto';

  @override
  String get postDetail_editRequiredError => 'Titolo e contenuto sono obbligatori.';

  @override
  String get postDetail_updateSuccess => 'Post aggiornato';

  @override
  String get postDetail_updateError => 'Impossibile aggiornare il post';

  @override
  String get postDetail_deleteDialogTitle => 'Eliminare il post?';

  @override
  String get postDetail_deleteDialogMessage => 'Questa azione non può essere annullata.';

  @override
  String get postDetail_deleteError => 'Impossibile eliminare il post';

  @override
  String get postDetail_editMenuItem => 'Modifica post';

  @override
  String get postDetail_deleteMenuItem => 'Elimina post';

  @override
  String get postDetail_loadError => 'Si è verificato un errore nel caricamento del post.';

  @override
  String get postDetail_notFound => 'Post non trovato.';

  @override
  String get postDetail_errorTitle => 'Errore';

  @override
  String get postDetail_authorFallback => 'Autore';

  @override
  String get postDetail_shareAction => 'Condividi';

  @override
  String get postDetail_saveAction => 'Salva';

  @override
  String get postDetail_addToFavoritesTooltip => 'Aggiungi ai preferiti';

  @override
  String get postDetail_removeFromFavoritesTooltip => 'Rimuovi dai preferiti';

  @override
  String get newsDetail_favoriteUpdateError => 'Impossibile aggiornare i preferiti';

  @override
  String get newsDetail_shareMessage => 'Apri Sociale_Vote per vedere questa notizia.';

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
  String get authDisplayNameLabel => 'Nome visualizzato';

  @override
  String get authUsernameLabel => 'Nome utente';

  @override
  String get authCountryOfResidenceLabel => 'Paese di residenza';

  @override
  String get authCityOfResidenceLabel => 'Città di residenza';

  @override
  String get authConfirmPasswordLabel => 'Conferma password';

  @override
  String get authLegalConsentPrefix => 'Ho letto e accetto';

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
  String get authDisplayNameRequiredError => 'Inserisci il nome visualizzato.';

  @override
  String get authDisplayNameTooShortError => 'Il nome visualizzato è troppo corto.';

  @override
  String get authUsernameRequiredError => 'Inserisci un nome utente.';

  @override
  String get authUsernameInvalidError => 'Usa da 3 a 20 caratteri: lettere minuscole, numeri e underscore.';

  @override
  String get authCountryRequiredError => 'Seleziona il Paese di residenza.';

  @override
  String get authCityRequiredError => 'Inserisci la città di residenza.';

  @override
  String get authConfirmPasswordRequiredError => 'Conferma la password.';

  @override
  String get authPasswordsDoNotMatchError => 'Le password non coincidono.';

  @override
  String get authLegalConsentRequiredError => 'Devi leggere e accettare i Termini di servizio e l’Informativa sulla privacy.';

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
  String get pollDetail_favoriteUpdateError => 'Impossibile aggiornare i preferiti';

  @override
  String get pollDetail_shareMessage => 'Apri Sociale_Vote per vedere e votare questo sondaggio.';

  @override
  String get pollDetail_shareError => 'Impossibile condividere il sondaggio';

  @override
  String get pollDetail_editPermissionError => 'Puoi modificare solo i tuoi sondaggi senza voti';

  @override
  String get pollDetail_editSuccessMessage => 'Sondaggio aggiornato';

  @override
  String get pollDetail_editMenuItem => 'Modifica sondaggio';

  @override
  String get pollDetail_editSavingMenuItem => 'Salvataggio...';

  @override
  String get pollDetail_deletePermissionError => 'Puoi eliminare solo i tuoi sondaggi';

  @override
  String get pollDetail_deleteError => 'Impossibile eliminare il sondaggio';

  @override
  String get pollDetail_deleteDialogTitle => 'Elimina sondaggio';

  @override
  String pollDetail_deleteDialogMessage(String title) {
    return 'Vuoi davvero eliminare \"$title\"? Questa azione non può essere annullata.';
  }

  @override
  String get pollDetail_deleteMenuItem => 'Elimina sondaggio';

  @override
  String get pollDetail_deleteDeletingMenuItem => 'Eliminazione...';

  @override
  String get pollDetail_publicVotesAvailableTitle => 'Voti pubblici disponibili';

  @override
  String get pollDetail_publicVotesAvailableMessage => 'Questo sondaggio permette di vedere chi ha votato cosa.';

  @override
  String get pollDetail_publicVotesAction => 'Vedi voti pubblici';

  @override
  String get pollDetail_retryButton => 'Riprova';

  @override
  String get pollDetail_voteErrorNoOption => 'Seleziona almeno un\'opzione';

  @override
  String get pollDetail_voteErrorAuthenticationRequired => 'Devi essere autenticato per votare';

  @override
  String get pollDetail_voteErrorClosed => 'Questo sondaggio è chiuso';

  @override
  String get pollDetail_voteErrorAlreadyVoted => 'Hai già votato in questo sondaggio';

  @override
  String get pollDetail_voteErrorGeneric => 'Impossibile registrare il voto';

  @override
  String get pollDetail_publicVotesSheetTitle => 'Voti pubblici';

  @override
  String get pollDetail_publicVotesSheetDescription => 'Qui puoi vedere chi ha votato cosa in questo sondaggio.';

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
  String get pollDetail_editDialogTitle => 'Modifica sondaggio';

  @override
  String get pollDetail_editTitleFieldLabel => 'Titolo';

  @override
  String get pollDetail_editTitleRequired => 'Il titolo è obbligatorio';

  @override
  String get pollDetail_editDescriptionFieldLabel => 'Descrizione';

  @override
  String get pollDetail_editError => 'Impossibile aggiornare il sondaggio';

  @override
  String get pollDetail_loadError => 'Impossibile caricare il sondaggio';

  @override
  String get pollDetail_notFound => 'Sondaggio non trovato';

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
  String get notificationsPollResultTitle => 'Aggiornamento sondaggio';

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
  String get notificationsTargetPost => 'un post';

  @override
  String get notificationsTargetNews => 'una notizia';

  @override
  String get notificationsTargetPoll => 'un sondaggio';

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
}
