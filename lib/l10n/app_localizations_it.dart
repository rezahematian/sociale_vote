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
  String get commonCancel => 'Annulla';

  @override
  String get commonApply => 'Applica';

  @override
  String get commonVerifying => 'Verifica in corso...';

  @override
  String get homeScopeChooseCountry => 'Choose country';

  @override
  String get homeScopeChooseCity => 'Choose city';

  @override
  String get homeScopeCountrySearchHint => 'Search country or code...';

  @override
  String get homeScopeCityRequiredError => 'Enter a city.';

  @override
  String get homeScopeCityNotFoundError => 'City not found in the selected country.';

  @override
  String get homeScopeCityVerificationError => 'Unable to verify the city. Try again.';

  @override
  String homeScopeSelectedCountryLabel(Object countryCode) {
    return 'Country: $countryCode';
  }

  @override
  String get homeScopeCityFieldHint => 'E.g. Rome, São Paulo, Tehran';

  @override
  String get homeForYouPageTitle => 'Per te';

  @override
  String get homeTrendingRefreshTooltip => 'Aggiorna contenuti di tendenza';

  @override
  String get contentTypePoll => 'Sondaggio';

  @override
  String get contentTypeNews => 'Notizia';

  @override
  String get contentTypePost => 'Pubblicazione';

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
}
