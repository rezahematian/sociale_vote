// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Social Vote';

  @override
  String get voteButton => 'Abstimmen';

  @override
  String get createPollPageTitle => 'Vote erstellen';

  @override
  String get createPollPageSubtitle => 'Eine neue Bürgerumfrage definieren';

  @override
  String get createPollBasicInfoTitle => 'Grundinformationen';

  @override
  String get createPollBasicInfoSubtitle => 'Lege die wichtigsten Angaben für diesen Vote fest.';

  @override
  String get createPollTitleFieldLabel => 'Titel *';

  @override
  String get createPollTitleFieldHelper => 'Eine klare, prägnante Frage oder Aussage.';

  @override
  String get createPollDescriptionFieldLabel => 'Beschreibung (optional)';

  @override
  String get createPollVotingModelTitle => 'So wird abgestimmt';

  @override
  String get createPollVotingModelSubtitle => 'Wähle, ob jede Person eine oder mehrere Antworten auswählen kann.';

  @override
  String get createPollTypeFieldLabel => 'Vote-Typ';

  @override
  String createPollSelectionRules(int min, int max) {
    return 'Auswahlregeln: mindestens $min, höchstens $max Auswahlen (wird automatisch an Vote-Typ und Antworten angepasst).';
  }

  @override
  String get createPollAllowVoteChangeTitle => 'Änderung der Stimme erlauben';

  @override
  String get createPollAllowVoteChangeSubtitle => 'Bis der Vote geschlossen wird.';

  @override
  String get createPollOptionsTitle => 'Antworten';

  @override
  String get createPollOptionsSubtitle => 'Gib mindestens zwei Antworten zur Auswahl ein. Mit * markierte Felder sind Pflichtfelder.';

  @override
  String createPollOptionLabel(int index, Object requiredMarker) {
    return 'Option $index$requiredMarker';
  }

  @override
  String get createPollRemoveOptionTooltip => 'Option entfernen';

  @override
  String get createPollAddOptionButton => 'Option hinzufügen';

  @override
  String get createPollParticipationPrivacyTitle => 'Teilnahme & Datenschutz';

  @override
  String get createPollParticipationPrivacySubtitle => 'Lege fest, wer abstimmen darf und wie vertraulich die Stimmen sind.';

  @override
  String get createPollWhoCanVoteLabel => 'Wer darf abstimmen?';

  @override
  String get createPollParticipationEveryoneSubtitle => 'Jeder registrierte Nutzer kann teilnehmen.';

  @override
  String get createPollParticipationGeoScopeSubtitle => 'Beschränke diesen Vote auf Personen aus einem bestimmten Land.';

  @override
  String get createPollCountryFieldLabel => 'Land für diesen Vote';

  @override
  String get createPollCountryFieldHelper => 'Dieses Land legt fest, wer an diesem Vote teilnehmen darf (zukünftige Backend-Integration).';

  @override
  String get createPollVoteAnonymityTitle => 'Anonymität der Stimme';

  @override
  String get createPollAnonymityAnonymousSubtitle => 'Empfohlene Standardeinstellung für Bürgerbeteiligungsplattformen.';

  @override
  String get createPollAnonymityPublicSubtitle => 'Mit Vorsicht verwenden: Stimmen können Identitäten zugeordnet werden (zukünftige Funktion).';

  @override
  String get createPollResultsValidityTitle => 'Ergebnisse & Gültigkeit';

  @override
  String get createPollResultsValiditySubtitle => 'Lege fest, wann Ergebnisse sichtbar sind, und definiere bei Bedarf ein Mindestquorum.';

  @override
  String get createPollResultsVisibilityFieldLabel => 'Sichtbarkeit der Ergebnisse';

  @override
  String get createPollQuorumTitle => 'Quorum (optional)';

  @override
  String get createPollQuorumSubtitle => 'Wenn gesetzt, gilt der Vote nur als gültig, wenn mindestens diese Anzahl an Stimmen erreicht wird. Leer lassen, wenn kein Quorum erforderlich ist.';

  @override
  String get createPollQuorumMinVotesFieldLabel => 'Mindestanzahl an Stimmen';

  @override
  String get createPollTimingTitle => 'Zeitraum';

  @override
  String get createPollTimingSubtitle => 'Lege fest, wann der Vote zur Abstimmung geöffnet sein soll.';

  @override
  String get createPollStartDateLabel => 'Startdatum';

  @override
  String get createPollEndDateLabel => 'Enddatum';

  @override
  String get createPollChangeDateButtonLabel => 'Ändern';

  @override
  String get createPollTimingStatusInfo => 'Der anfängliche Status (offen/geplant/geschlossen) wird anhand dieser Daten automatisch bestimmt.';

  @override
  String get createPollSuccessMessage => 'Vote erfolgreich erstellt';

  @override
  String get createPollSubmitCreatingLabel => 'Wird erstellt...';

  @override
  String get createPollSubmitLabel => 'Vote erstellen';

  @override
  String get createPollPollTypeYesNoLabel => 'Ja / Nein';

  @override
  String get createPollPollTypeSingleChoiceLabel => 'Eine Antwort';

  @override
  String get createPollPollTypeMultipleChoiceLabel => 'Mehrere Antworten';

  @override
  String get createPollPollTypeApprovalLabel => 'Zustimmungswahl';

  @override
  String get createPollPollTypeRankedLabel => 'Rangwahl';

  @override
  String get createPollPollTypeScoreLabel => 'Punkte / Bewertung';

  @override
  String get createPollParticipationScopeEveryoneLabel => 'Alle können abstimmen';

  @override
  String get createPollParticipationScopeGeoScopeOnlyLabel => 'Nur Nutzer in einem bestimmten Land';

  @override
  String get createPollAnonymityLevelAnonymousLabel => 'Stimmen sind anonym';

  @override
  String get createPollAnonymityLevelPublicLabel => 'Stimmen sind öffentlich (erweiterte / eingeschränkte Nutzung)';

  @override
  String get createPollResultsVisibilityAlwaysLabel => 'Immer sichtbar (solange der Vote offen ist)';

  @override
  String get createPollResultsVisibilityAfterVoteLabel => 'Erst nach der Abstimmung sichtbar';

  @override
  String get createPollResultsVisibilityAfterCloseLabel => 'Erst sichtbar, wenn der Vote geschlossen ist';

  @override
  String get homeLoginButton => 'Anmelden';

  @override
  String get homeRegisterButton => 'Registrieren';

  @override
  String get homeProfileButton => 'Profil';

  @override
  String get homeLogoutButton => 'Abmelden';

  @override
  String get homeLogoutMessage => 'Abmeldung abgeschlossen. Du verwendest die App jetzt als Gast (nur Lesen).';

  @override
  String get homeSearchHint => 'Städte, Länder, Konten und Inhalte suchen...';

  @override
  String get searchPageTitle => 'Suche';

  @override
  String get searchInputHint => 'Konten, Vote, News, Voce suchen...';

  @override
  String get searchClearTooltip => 'Suche löschen';

  @override
  String get searchTypeAll => 'Alle';

  @override
  String get searchTypePolls => 'Vote';

  @override
  String get searchTypeNews => 'News';

  @override
  String get searchTypePosts => 'Voce';

  @override
  String get searchTypeAccounts => 'Konten';

  @override
  String get searchSortHottest => 'Am beliebtesten';

  @override
  String get searchSortLatest => 'Neueste';

  @override
  String get searchPollStatusAll => 'Alle Vote';

  @override
  String get searchPollStatusOpen => 'Offen';

  @override
  String get searchPollStatusClosed => 'Geschlossen';

  @override
  String get searchIdleMessage => 'Gib einen Begriff ein, um die Suche zu starten.';

  @override
  String get searchErrorMessage => 'Bei der Suche ist ein Fehler aufgetreten.';

  @override
  String get searchRetryButton => 'Erneut versuchen';

  @override
  String get searchEmptyMessage => 'Keine Ergebnisse für diese Suche gefunden.';

  @override
  String get searchContentUnavailable => 'Inhalt nicht verfügbar';

  @override
  String get searchResultTypePoll => 'Vote';

  @override
  String get searchResultTypeNews => 'News';

  @override
  String get searchResultTypePost => 'Voce';

  @override
  String get searchResultTypeAccount => 'Konto';

  @override
  String get searchResultTypeMixed => 'Gemischt';

  @override
  String homeUserStatusLoggedIn(Object userId) {
    return 'Angemeldet als: $userId';
  }

  @override
  String get homeUserStatusGuest => 'Gastmodus: Du kannst nur lesen. Melde dich an oder registriere dich, um abzustimmen, zu kommentieren und zu reagieren.';

  @override
  String get homeScopeLabelWorld => 'Welt – Globale Abstimmungen und Nachrichten';

  @override
  String get homeScopeLabelCountry => 'Land – Nationale Abstimmungen und Nachrichten';

  @override
  String get homeScopeLabelCity => 'Stadt – Lokale Abstimmungen und Nachrichten';

  @override
  String get homeScopeShortWorld => 'Welt';

  @override
  String get homeScopeShortCountry => 'Land';

  @override
  String get homeScopeShortCity => 'Stadt';

  @override
  String get homeScopeChipWorld => 'Welt';

  @override
  String get homeScopeChipItaly => 'Italien';

  @override
  String get homeScopeChipTorino => 'Turin';

  @override
  String get homeScopeChangedWorld => 'Bereich auf Welt geändert';

  @override
  String get homeScopeChangedItaly => 'Bereich auf Italien geändert';

  @override
  String get homeScopeChangedTorino => 'Bereich auf Turin geändert';

  @override
  String get followScopeButtonFollowed => 'Gefolgt';

  @override
  String get followScopeButtonFollow => 'Diesem Bereich folgen';

  @override
  String get homeTrendingTitle => 'Pulse Now';

  @override
  String get homeTrendingError => 'Pulse Now konnte für diesen Bereich nicht geladen werden.';

  @override
  String get homeTrendingEmpty => 'Für diesen Bereich gibt es derzeit keine Inhalte in Pulse Now.';

  @override
  String homeForYouTitle(Object scope) {
    return 'Pulse ($scope)';
  }

  @override
  String get homeForYouError => 'Pulse konnte für diesen Bereich nicht geladen werden.';

  @override
  String get homeForYouEmpty => 'Für diesen Bereich gibt es derzeit keine empfohlenen Inhalte in Pulse.';

  @override
  String homePollsTitle(Object scope) {
    return 'Vote im Fokus ($scope)';
  }

  @override
  String get homePollsEmptyTitle => 'Kein Vote für diesen Bereich';

  @override
  String get homePollsEmptySubtitle => 'Für diesen Bereich ist kein Vote verfügbar.';

  @override
  String get homePollsViewAllButton => 'Vote anzeigen';

  @override
  String homeNewsTitle(Object scope) {
    return 'Top News ($scope)';
  }

  @override
  String get homeNewsErrorTitle => 'Nachrichten konnten nicht geladen werden';

  @override
  String get homeNewsErrorSubtitle => 'Beim Laden der Nachrichten für diesen Bereich ist ein Problem aufgetreten.';

  @override
  String get homeNewsEmptyTitle => 'Keine Nachrichten für diesen Bereich';

  @override
  String get homeNewsEmptySubtitle => 'Für diesen Bereich gibt es derzeit keine Nachrichten.';

  @override
  String get homeNewsViewAllButton => 'Alle Nachrichten anzeigen';

  @override
  String get homeNewsBreakingBadge => 'EILMELDUNG';

  @override
  String homeSocialTitle(Object scope) {
    return 'Voce ($scope)';
  }

  @override
  String get homeSocialErrorTitle => 'Voce konnte nicht geladen werden';

  @override
  String get homeSocialErrorSubtitle => 'Beim Laden von Voce für diesen Bereich ist ein Problem aufgetreten.';

  @override
  String get homeSocialEmptyTitle => 'Keine Voce für diesen Bereich';

  @override
  String get homeSocialEmptySubtitle => 'Für diesen Bereich gibt es derzeit keine Voce-Inhalte.';

  @override
  String get homeSocialViewFeedButton => 'Alle Voce anzeigen';

  @override
  String get pollDetail_title => 'Vote-Details';

  @override
  String get pollDetail_removeFromFavoritesTooltip => 'Nicht mehr speichern';

  @override
  String get pollDetail_addToFavoritesTooltip => 'Speichern';

  @override
  String get pollDetail_chipAnonymous => 'Anonyme Stimme';

  @override
  String get pollDetail_chipPublic => 'Öffentliche Stimme';

  @override
  String get pollDetail_chipRestrictedGeo => 'Auf geografischen Bereich beschränkt';

  @override
  String pollDetail_quorumReached(int currentVotes, int requiredVotes) {
    return 'Quorum erreicht ($currentVotes / $requiredVotes)';
  }

  @override
  String pollDetail_quorumNotReached(int currentVotes, int requiredVotes) {
    return 'Quorum nicht erreicht ($currentVotes / $requiredVotes)';
  }

  @override
  String get pollDetail_optionsTitle => 'Optionen';

  @override
  String get pollDetail_statusClosedMessage => 'Dieser Vote ist geschlossen.';

  @override
  String get pollDetail_statusScheduledMessage => 'Dieser Vote ist noch nicht geöffnet.';

  @override
  String get pollDetail_statusNotAvailableMessage => 'Abstimmen ist nicht verfügbar.';

  @override
  String get pollDetail_voteSubmitted => 'Stimme erfolgreich abgegeben!';

  @override
  String get pollDetail_voteButton => 'Abstimmen';

  @override
  String get pollDetail_resultsTitle => 'Ergebnisse';

  @override
  String pollDetail_outcomePrefix(Object label) {
    return 'Ergebnis: $label';
  }

  @override
  String get pollDetail_noResults => 'Noch keine Ergebnisse verfügbar.';

  @override
  String get pollDetail_resultsAfterVote => 'Die Ergebnisse werden sichtbar, nachdem du abgestimmt hast.';

  @override
  String get pollDetail_resultsWhenClosed => 'Die Ergebnisse werden sichtbar, wenn der Vote geschlossen ist.';

  @override
  String get pollType_yesNo => 'Ja / Nein';

  @override
  String get pollType_singleChoice => 'Einfachauswahl';

  @override
  String get pollType_multipleChoice => 'Mehrfachauswahl';

  @override
  String get pollType_approval => 'Zustimmung';

  @override
  String get pollStatus_draft => 'Entwurf';

  @override
  String get pollStatus_open => 'Offen';

  @override
  String get pollStatus_closed => 'Geschlossen';

  @override
  String get pollStatus_scheduled => 'Geplant';

  @override
  String get pollGeo_global => 'Global';

  @override
  String get pollGeo_local => 'Lokal';

  @override
  String get pollOutcome_approved => 'Angenommen';

  @override
  String get pollOutcome_rejected => 'Abgelehnt';

  @override
  String get pollOutcome_tie => 'Unentschieden';

  @override
  String get pollOutcome_noMajority => 'Keine Mehrheit';

  @override
  String get pollOutcome_notApplicable => 'Nicht zutreffend';

  @override
  String get pollList_title => 'Vote';

  @override
  String get pollList_scopeWorld => 'Welt';

  @override
  String get pollList_scopeCountryFallback => 'Land';

  @override
  String get pollList_scopeCityFallback => 'Stadt';

  @override
  String get pollList_scopeDescriptionGlobal => 'Globale Vote werden angezeigt.';

  @override
  String get pollList_scopeDescriptionCountry => 'Vote für dieses Land werden angezeigt.';

  @override
  String get pollList_scopeDescriptionCity => 'Vote für diese Stadt werden angezeigt.';

  @override
  String get pollList_filterStatus_all => 'Alle';

  @override
  String get pollList_filterStatus_open => 'Offen';

  @override
  String get pollList_filterStatus_closed => 'Geschlossen';

  @override
  String get pollList_sort_latest => 'Neueste';

  @override
  String get pollList_sort_hottest => 'Am beliebtesten';

  @override
  String get pollList_filterScope_currentArea => 'Aktueller Bereich';

  @override
  String pollList_headerTitle(Object scopeLabel, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Vote gefunden',
      one: '1 Vote gefunden',
      zero: 'kein Vote gefunden',
    );
    return '$scopeLabel · $_temp0';
  }

  @override
  String get pollList_createPollButton => 'Vote erstellen';

  @override
  String get pollList_paginationHint => 'Scrollen, um weitere Vote zu laden…';

  @override
  String get pollList_emptyMessage => 'Keine Vote für diesen Filter und Bereich gefunden.';

  @override
  String get pollType_ranked => 'Rangwahl';

  @override
  String get pollType_score => 'Punktewahl';

  @override
  String get pollVisibility_whileOpen => 'Ergebnisse sichtbar, solange der Vote offen ist';

  @override
  String get pollVisibility_afterVote => 'Ergebnisse nach der Abstimmung sichtbar';

  @override
  String get pollVisibility_afterClose => 'Ergebnisse nach dem Schließen sichtbar';

  @override
  String get pollCard_countryRestricted => 'Auf Land beschränkt';

  @override
  String pollCard_restrictedToCountry(Object countryName) {
    return 'Beschränkt auf $countryName';
  }

  @override
  String pollCard_quorumLabel(int minVotes) {
    return 'Quorum $minVotes';
  }

  @override
  String get pollCard_resultsVisibleChip => 'Ergebnisse sichtbar';

  @override
  String get pollCard_resultsAfterVoteChip => 'Nach der Abstimmung';

  @override
  String get pollCard_resultsAfterCloseChip => 'Nach dem Schließen';

  @override
  String get pollCard_publicOfficialPublisher => 'Amtsträger';

  @override
  String get pollCard_institutionPublisher => 'Institution';

  @override
  String get pollCard_representativePublisher => 'Vertretung';

  @override
  String pollCard_voteCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Stimmen',
      one: 'Stimme',
    );
    return '$_temp0';
  }

  @override
  String get pollCard_viewDetails => 'Details anzeigen';

  @override
  String pollResult_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ergebnisse ($count Stimmen)',
      one: 'Ergebnisse (1 Stimme)',
      zero: 'Ergebnisse (keine Stimmen)',
    );
    return '$_temp0';
  }

  @override
  String get voteError_noSelection => 'Bitte wähle mindestens eine Option aus.';

  @override
  String get voteError_unauthorized => 'Du darfst an diesem Vote nicht abstimmen.';

  @override
  String get voteError_generic => 'Die Stimme konnte nicht abgegeben werden. Bitte versuche es erneut.';

  @override
  String get commentSection_title => 'Kommentare';

  @override
  String get commentSection_sortLabel => 'Sortieren:';

  @override
  String get commentSection_sortOldest => 'Älteste';

  @override
  String get commentSection_sortNewest => 'Neueste';

  @override
  String get commentSection_errorGeneric => 'Beim Laden der Kommentare ist ein Fehler aufgetreten.';

  @override
  String get commentSection_empty => 'Noch keine Kommentare. Schreibe den ersten Kommentar.';

  @override
  String get commentSection_loadMore => 'Weitere Kommentare laden';

  @override
  String commentSection_replyingTo(Object snippet) {
    return 'Antwort auf: $snippet';
  }

  @override
  String get commentSection_cancelReply => 'Abbrechen';

  @override
  String get commentSection_inputHintRoot => 'Kommentar hinzufügen...';

  @override
  String get commentSection_inputHintReply => 'Antwort schreiben...';

  @override
  String get commentSection_deleteAction => 'Löschen';

  @override
  String get commentSection_replyAction => 'Antworten';

  @override
  String get commentSection_youBadge => 'Du';

  @override
  String get newsDetail_title => 'Nachrichtendetails';

  @override
  String get newsDetail_breakingBadge => 'EILMELDUNG';

  @override
  String get newsDetail_removeFromFavoritesTooltip => 'Nicht mehr speichern';

  @override
  String get newsDetail_addToFavoritesTooltip => 'Speichern';

  @override
  String get newsDetail_bodyFallback => 'Für diese Nachricht ist kein zusätzlicher Text verfügbar.';

  @override
  String get newsDetail_footerMoreContext => 'Weitere Hintergründe und Quellen folgen in Kürze.';

  @override
  String get newsFeed_title => 'Nachrichten';

  @override
  String get newsFeed_scopeWorld => 'Welt';

  @override
  String get newsFeed_scopeCountry => 'Land';

  @override
  String get newsFeed_scopeCity => 'Stadt';

  @override
  String newsFeed_scopeLabel(Object scope) {
    return 'Bereich: $scope';
  }

  @override
  String get newsFeed_scopeGlobalDescription => 'Globale Nachrichten werden angezeigt.';

  @override
  String get newsFeed_scopeCountryDescription => 'Nachrichten für dieses Land werden angezeigt.';

  @override
  String get newsFeed_scopeCityDescription => 'Nachrichten für diese Stadt werden angezeigt.';

  @override
  String get newsFeed_emptyTitle => 'Für diesen Bereich sind keine Nachrichten verfügbar.';

  @override
  String get newsFeed_emptySubtitle => 'Zum Aktualisieren ziehen oder später erneut versuchen.';

  @override
  String newsFeed_itemsFound(int count) {
    return '$count Nachrichten gefunden';
  }

  @override
  String get newsFeed_loadingMoreHint => 'Scrollen, um weitere Nachrichten zu laden…';

  @override
  String get newsFeed_errorTitle => 'Nachrichten konnten nicht geladen werden';

  @override
  String get newsFeed_errorGeneric => 'Beim Laden der Nachrichten ist ein unerwarteter Fehler aufgetreten.';

  @override
  String get newsFeed_retryButton => 'Erneut versuchen';

  @override
  String get newsCard_headerTitle => 'Nachrichten';

  @override
  String get newsFeed_errorUnauthorized => 'Die Nachrichtenkonfiguration ist ungültig (API-Schlüssel).';

  @override
  String get newsFeed_errorRateLimited => 'Zu viele Anfragen. Bitte versuche es in Kürze erneut.';

  @override
  String get newsFeed_errorServerUnavailable => 'Der Nachrichtendienst ist vorübergehend nicht verfügbar. Bitte versuche es später erneut.';

  @override
  String get newsFeed_errorTimeout => 'Die Anfrage dauert zu lange. Bitte versuche es erneut.';

  @override
  String get newsFeed_errorNetwork => 'Keine Verbindung. Prüfe deine Internetverbindung und versuche es erneut.';

  @override
  String get newsFeed_moreTooltip => 'Mehr';

  @override
  String get newsFeed_actionCopyTitle => 'Titel kopieren';

  @override
  String get newsFeed_actionRefreshFeed => 'Feed aktualisieren';

  @override
  String get newsFeed_copiedTitleToast => 'Titel kopiert';

  @override
  String get newsFeed_languageTooltip => 'Nachrichtensprache';

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
  String get newsFeed_languageLimitedHint => 'In dieser Sprache sind nur wenige Quellen verfügbar. Versuche AUTO.';

  @override
  String get newsTopic_all => 'Alle';

  @override
  String get newsTopic_world => 'Welt';

  @override
  String get newsTopic_nation => 'Inland';

  @override
  String get newsTopic_business => 'Wirtschaft';

  @override
  String get newsTopic_technology => 'Technologie';

  @override
  String get newsTopic_science => 'Wissenschaft';

  @override
  String get newsTopic_health => 'Gesundheit';

  @override
  String get newsTopic_sports => 'Sport';

  @override
  String get newsTopic_entertainment => 'Unterhaltung';

  @override
  String get newsDetail_openSource => 'Originalartikel öffnen';

  @override
  String get newsDetail_openSourceUnavailable => 'Der Originalartikel konnte nicht geöffnet werden';

  @override
  String get socialFeedTitle => 'Voce';

  @override
  String get socialFeedCreatePostButton => 'Voce erstellen';

  @override
  String get commonCancelButton => 'Abbrechen';

  @override
  String get commonApplyButton => 'Anwenden';

  @override
  String get homeScopeChooseCountry => 'Land auswählen';

  @override
  String get homeScopeCountrySearchHint => 'Land oder Ländercode suchen...';

  @override
  String get homeScopeChooseCity => 'Stadt auswählen';

  @override
  String homeScopeCountryWithCode(String code) {
    return 'Land: $code';
  }

  @override
  String get homeScopeCityFieldLabel => 'Stadt';

  @override
  String get homeScopeCityExampleHint => 'Stadt eingeben, z. B. Meran';

  @override
  String get homeScopeCityRequiredError => 'Gib eine Stadt ein.';

  @override
  String get homeScopeCityNotFoundError => 'Die Stadt wurde im ausgewählten Land nicht gefunden.';

  @override
  String get homeScopeCityVerificationError => 'Die Stadt konnte nicht überprüft werden. Bitte versuche es erneut.';

  @override
  String get homeScopeVerifyingButton => 'Wird geprüft...';

  @override
  String get homeMapOpenButton => 'Karte öffnen';

  @override
  String get homeHeroHeadline => 'Gestalte die Zukunft.\nGemeinsam.';

  @override
  String get homeHeroPollsAction => 'Vote';

  @override
  String get homeHeroNewsAction => 'News';

  @override
  String get homeHeroCreateAction => 'Erstellen';

  @override
  String get homeHeroExploreAction => 'Entdecken';

  @override
  String get homeAccountMenuLabel => 'Konto';

  @override
  String get homeThemeSystemMenuItem => 'Design: System';

  @override
  String get homeThemeLightMenuItem => 'Design: Hell';

  @override
  String get homeThemeDarkMenuItem => 'Design: Dunkel';

  @override
  String get profileAppLanguageTitle => 'App-Sprache';

  @override
  String get profileAppLanguageSystem => 'System';

  @override
  String get profileAppLanguageSystemDescription => 'Verwendet die Sprache deines Geräts';

  @override
  String get profileAppLanguageItalian => 'Italienisch';

  @override
  String get profileAppLanguageEnglish => 'Englisch';

  @override
  String get homeNotificationsTooltip => 'Benachrichtigungen';

  @override
  String get postCard_authorFallback => 'Autor';

  @override
  String get postCard_globalLocation => 'Global';

  @override
  String get commonSaveButton => 'Speichern';

  @override
  String get commonDeleteButton => 'Löschen';

  @override
  String get contentReport_menuAction => 'Inhalt melden';

  @override
  String get contentReport_dialogTitle => 'Inhalt melden';

  @override
  String get contentReport_authenticationRequired => 'Du musst angemeldet sein, um Inhalte zu melden';

  @override
  String get contentReport_submittedMessage => 'Meldung gesendet';

  @override
  String get contentReport_alreadySubmittedMessage => 'Du hast diesen Inhalt bereits gemeldet';

  @override
  String get contentReport_submitError => 'Die Meldung konnte nicht gesendet werden';

  @override
  String get contentReport_sendButton => 'Senden';

  @override
  String get contentReport_reasonSpam => 'Spam';

  @override
  String get contentReport_reasonHarassment => 'Belästigung oder Missbrauch';

  @override
  String get contentReport_reasonHateSpeech => 'Hassrede';

  @override
  String get contentReport_reasonMisinformation => 'Falschinformation';

  @override
  String get contentReport_reasonViolence => 'Gewalt';

  @override
  String get contentReport_reasonOther => 'Sonstiges';

  @override
  String get postDetail_title => 'Voce-Details';

  @override
  String get postDetail_favoriteUpdateError => 'Gespeicherte Inhalte konnten nicht aktualisiert werden';

  @override
  String get postDetail_shareMessage => 'Öffne Social Vote, um diese Voce anzusehen.';

  @override
  String get postDetail_shareError => 'Die Voce konnte nicht geteilt werden';

  @override
  String get postDetail_editDialogTitle => 'Voce bearbeiten';

  @override
  String get postDetail_editTitleFieldLabel => 'Titel';

  @override
  String get postDetail_editContentFieldLabel => 'Inhalt';

  @override
  String get postDetail_editRequiredError => 'Titel und Inhalt sind erforderlich.';

  @override
  String get postDetail_updateSuccess => 'Voce aktualisiert';

  @override
  String get postDetail_updateError => 'Die Voce konnte nicht aktualisiert werden';

  @override
  String get postDetail_deleteDialogTitle => 'Diese Voce löschen?';

  @override
  String get postDetail_deleteDialogMessage => 'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get postDetail_deleteError => 'Die Voce konnte nicht gelöscht werden';

  @override
  String get postDetail_editMenuItem => 'Voce bearbeiten';

  @override
  String get postDetail_deleteMenuItem => 'Voce löschen';

  @override
  String get postDetail_loadError => 'Beim Laden der Voce ist ein Fehler aufgetreten.';

  @override
  String get postDetail_notFound => 'Voce nicht gefunden.';

  @override
  String get postDetail_errorTitle => 'Fehler';

  @override
  String get postDetail_authorFallback => 'Autor';

  @override
  String get postDetail_shareAction => 'Teilen';

  @override
  String get postDetail_saveAction => 'Speichern';

  @override
  String get postDetail_addToFavoritesTooltip => 'Speichern';

  @override
  String get postDetail_removeFromFavoritesTooltip => 'Nicht mehr speichern';

  @override
  String get newsDetail_favoriteUpdateError => 'Gespeicherte Inhalte konnten nicht aktualisiert werden';

  @override
  String get newsDetail_shareMessage => 'Öffne Social Vote, um diese Nachricht anzusehen.';

  @override
  String get newsDetail_shareError => 'Die Nachricht konnte nicht geteilt werden';

  @override
  String get newsDetail_shareTooltip => 'Teilen';

  @override
  String get authLoginPageTitle => 'Anmelden';

  @override
  String get authLoginHeadline => 'Willkommen zurück';

  @override
  String get authEmailLabel => 'E-Mail';

  @override
  String get authPasswordLabel => 'Passwort';

  @override
  String get authRememberMeLabel => 'Angemeldet bleiben';

  @override
  String get authForgotPasswordAction => 'Passwort vergessen?';

  @override
  String get authLoginButton => 'Anmelden';

  @override
  String get authRegisterPrompt => 'Noch kein Konto?';

  @override
  String get authRegisterAction => 'Registrieren';

  @override
  String get authRegisterPageTitle => 'Registrieren';

  @override
  String get authRegisterHeadline => 'Konto erstellen';

  @override
  String get authPersonalAccountOwnershipTitle => 'Der Zugang gehört immer einer Person';

  @override
  String get authPersonalAccountOwnershipBody => 'Wenn du eine Organisation vertrittst, erstelle dein persönliches Konto. Nach der Anmeldung kannst du eine verifizierte Organisation beantragen und im Workspace verwalten.';

  @override
  String get authOrganizationPathAction => 'So funktioniert es für Organisationen';

  @override
  String get authDisplayNameLabel => 'Öffentlicher Name';

  @override
  String get authUsernameLabel => 'Benutzername';

  @override
  String get authCountryOfResidenceLabel => 'Wohnsitzland';

  @override
  String get authCityOfResidenceLabel => 'Wohnort (optional)';

  @override
  String get authConfirmPasswordLabel => 'Passwort bestätigen';

  @override
  String get authLegalConsentPrefix => 'Ich bestätige, dass ich mindestens 18 Jahre alt bin. Ich akzeptiere die Nutzungsbedingungen und bestätige, dass ich die Datenschutzerklärung gelesen habe.';

  @override
  String get authTermsOfServiceAction => 'die Nutzungsbedingungen';

  @override
  String get authPrivacyPolicyAction => 'die Datenschutzerklärung';

  @override
  String get authRegisterButton => 'Registrieren';

  @override
  String get authLoginPrompt => 'Du hast bereits ein Konto?';

  @override
  String get authLoginAction => 'Anmelden';

  @override
  String get authForgotPasswordDialogTitle => 'Passwort zurücksetzen';

  @override
  String get authForgotPasswordDialogBody => 'Gib die E-Mail-Adresse ein, die mit deinem Konto verknüpft ist. Wir senden dir einen Link, mit dem du ein neues Passwort wählen kannst.';

  @override
  String get authForgotPasswordSendButton => 'Link senden';

  @override
  String get authPasswordResetEmailSent => 'E-Mail zum Zurücksetzen des Passworts gesendet. Prüfe deinen Posteingang.';

  @override
  String get authResetPasswordPageTitle => 'Passwort zurücksetzen';

  @override
  String get authResetPasswordHeadline => 'Neues Passwort wählen';

  @override
  String get authNewPasswordLabel => 'Neues Passwort';

  @override
  String get authConfirmNewPasswordLabel => 'Neues Passwort bestätigen';

  @override
  String get authUpdatePasswordButton => 'Passwort aktualisieren';

  @override
  String get authPasswordUpdated => 'Passwort erfolgreich aktualisiert.';

  @override
  String get authEmailConfirmationTitle => 'Prüfe deine E-Mails';

  @override
  String get authEmailConfirmationIntro => 'Wir haben einen Bestätigungslink gesendet an:';

  @override
  String get authEmailConfirmationInstructions => 'Öffne den Link in der Nachricht, um deine Adresse zu bestätigen. Kehre danach zur App zurück und melde dich an.';

  @override
  String get authBackToLoginButton => 'Zurück zur Anmeldung';

  @override
  String get authUseAnotherEmailButton => 'Andere E-Mail-Adresse verwenden';

  @override
  String get authEmailRequiredError => 'Gib deine E-Mail-Adresse ein.';

  @override
  String get authEmailInvalidError => 'Gib eine gültige E-Mail-Adresse ein.';

  @override
  String get authPasswordRequiredError => 'Gib dein Passwort ein.';

  @override
  String get authPasswordTooShortError => 'Das Passwort muss mindestens 8 Zeichen lang sein.';

  @override
  String get authDisplayNameRequiredError => 'Gib deinen öffentlichen Namen ein.';

  @override
  String get authDisplayNameTooShortError => 'Der öffentliche Name ist zu kurz.';

  @override
  String get authUsernameRequiredError => 'Gib einen Benutzernamen ein.';

  @override
  String get authUsernameInvalidError => 'Verwende 3 bis 20 Zeichen: Kleinbuchstaben, Zahlen und Unterstriche.';

  @override
  String get authUsernameAlreadyTakenError => 'Der Benutzername wird bereits verwendet.';

  @override
  String get authCountryRequiredError => 'Wähle dein Wohnsitzland aus.';

  @override
  String get authCityRequiredError => 'Gib deinen Wohnort ein.';

  @override
  String get authConfirmPasswordRequiredError => 'Bestätige dein Passwort.';

  @override
  String get authPasswordsDoNotMatchError => 'Die Passwörter stimmen nicht überein.';

  @override
  String get authLegalConsentRequiredError => 'Um dich zu registrieren, bestätige, dass du mindestens 18 Jahre alt bist, akzeptiere die Nutzungsbedingungen und bestätige, dass du die Datenschutzerklärung gelesen hast.';

  @override
  String get authForgotPasswordEmailRequiredError => 'Gib die E-Mail-Adresse des Kontos ein, das du wiederherstellen möchtest.';

  @override
  String get authInvalidCredentialsError => 'E-Mail-Adresse oder Passwort ist ungültig.';

  @override
  String get authEmailAlreadyRegisteredError => 'Diese E-Mail-Adresse ist bereits registriert.';

  @override
  String get authEmailNotConfirmedError => 'E-Mail-Adresse nicht bestätigt. Prüfe deinen Posteingang, bevor du dich anmeldest.';

  @override
  String get authTooManyAttemptsError => 'Zu viele Versuche. Warte einige Minuten und versuche es erneut.';

  @override
  String get authNetworkError => 'Netzwerkfehler. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get authLoginGenericError => 'Anmeldung fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get authRegisterGenericError => 'Registrierung fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get authPasswordResetGenericError => 'Der Link zum Zurücksetzen konnte nicht gesendet werden. Bitte versuche es erneut.';

  @override
  String get authPasswordUpdateGenericError => 'Das Passwort konnte nicht aktualisiert werden. Bitte versuche es erneut.';

  @override
  String get authShowPasswordTooltip => 'Passwort anzeigen';

  @override
  String get authHidePasswordTooltip => 'Passwort ausblenden';

  @override
  String get authTermsPageTitle => 'Nutzungsbedingungen';

  @override
  String get authPrivacyPageTitle => 'Datenschutzerklärung';

  @override
  String get authCloseButton => 'Schließen';

  @override
  String get pollDetail_favoriteUpdateError => 'Gespeicherte Inhalte konnten nicht aktualisiert werden';

  @override
  String get pollDetail_shareMessage => 'Öffne Social Vote, um diesen Vote anzusehen und daran teilzunehmen.';

  @override
  String get pollDetail_shareError => 'Der Vote konnte nicht geteilt werden';

  @override
  String get pollDetail_editPermissionError => 'Du kannst nur eigene Vote ohne abgegebene Stimmen bearbeiten';

  @override
  String get pollDetail_editSuccessMessage => 'Vote aktualisiert';

  @override
  String get pollDetail_editMenuItem => 'Vote bearbeiten';

  @override
  String get pollDetail_editSavingMenuItem => 'Wird gespeichert...';

  @override
  String get pollDetail_deletePermissionError => 'Du kannst nur eigene Vote löschen';

  @override
  String get pollDetail_deleteError => 'Der Vote konnte nicht gelöscht werden';

  @override
  String get pollDetail_deleteDialogTitle => 'Vote löschen';

  @override
  String pollDetail_deleteDialogMessage(String title) {
    return 'Möchtest du „$title“ wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String get pollDetail_deleteMenuItem => 'Vote löschen';

  @override
  String get pollDetail_deleteDeletingMenuItem => 'Wird gelöscht...';

  @override
  String get pollDetail_publicVotesAvailableTitle => 'Öffentliche Stimmen verfügbar';

  @override
  String get pollDetail_publicVotesAvailableMessage => 'Bei diesem Vote kannst du sehen, wer für welche Option abgestimmt hat.';

  @override
  String get pollDetail_publicVotesAction => 'Öffentliche Stimmen anzeigen';

  @override
  String get pollDetail_retryButton => 'Erneut versuchen';

  @override
  String get pollDetail_voteErrorNoOption => 'Wähle mindestens eine Option aus';

  @override
  String get pollDetail_voteErrorAuthenticationRequired => 'Du musst angemeldet sein, um abzustimmen';

  @override
  String get pollDetail_voteErrorClosed => 'Dieser Vote ist geschlossen';

  @override
  String get pollDetail_voteErrorAlreadyVoted => 'Du hast bereits an diesem Vote abgestimmt';

  @override
  String get pollDetail_voteErrorGeneric => 'Die Stimme konnte nicht abgegeben werden';

  @override
  String get pollDetail_publicVotesSheetTitle => 'Öffentliche Stimmen';

  @override
  String get pollDetail_publicVotesSheetDescription => 'Hier kannst du sehen, wer bei diesem Vote für welche Option abgestimmt hat.';

  @override
  String get pollDetail_publicVotesSearchHint => 'Nutzer suchen';

  @override
  String get pollDetail_publicVotesLoadError => 'Öffentliche Stimmen konnten nicht geladen werden';

  @override
  String get pollDetail_publicVotesEmpty => 'Keine öffentlichen Stimmen verfügbar';

  @override
  String get pollDetail_publicVotesSearchEmpty => 'Keine Nutzer für diese Suche gefunden';

  @override
  String pollDetail_publicVotesResultsCount(int count) {
    return '$count Ergebnisse geladen';
  }

  @override
  String get pollDetail_publicVotesLoadMore => 'Mehr laden';

  @override
  String get pollDetail_publicVotesUserFallback => 'Nutzer';

  @override
  String get pollDetail_editDialogTitle => 'Vote bearbeiten';

  @override
  String get pollDetail_editTitleFieldLabel => 'Titel';

  @override
  String get pollDetail_editTitleRequired => 'Titel ist erforderlich';

  @override
  String get pollDetail_editDescriptionFieldLabel => 'Beschreibung';

  @override
  String get pollDetail_editError => 'Der Vote konnte nicht aktualisiert werden';

  @override
  String get pollDetail_loadError => 'Der Vote konnte nicht geladen werden';

  @override
  String get pollDetail_notFound => 'Vote nicht gefunden';

  @override
  String get profileEditPageTitle => 'Profil bearbeiten';

  @override
  String get profileLoginRequiredMessage => 'Du musst angemeldet sein, um dein Profil zu bearbeiten.';

  @override
  String get profileAvatarUploading => 'Wird hochgeladen...';

  @override
  String get profileUploadAvatarButton => 'Avatar hochladen';

  @override
  String get profileDisplayNameLabel => 'Anzeigename';

  @override
  String get profileDisplayNameRequiredError => 'Anzeigename ist erforderlich.';

  @override
  String get profileUsernameHint => 'z. B. mario_roma';

  @override
  String get profileUsernameHelper => '3–20 Zeichen: Kleinbuchstaben, Zahlen und Unterstriche';

  @override
  String get profileAvatarUrlLabel => 'Avatar-URL';

  @override
  String get profileBioLabel => 'Bio';

  @override
  String get profileClearCountryButton => 'Land entfernen';

  @override
  String get profileCityResidenceHelper => 'Der Wohnort wird vor dem Speichern mit dem ausgewählten Land abgeglichen.';

  @override
  String get profileCityNotFoundError => 'Die Stadt wurde im ausgewählten Land nicht gefunden.';

  @override
  String get profileCityVerificationError => 'Die Stadt kann derzeit nicht überprüft werden.';

  @override
  String get profileAvatarUploadError => 'Der Avatar konnte nicht hochgeladen werden.';

  @override
  String get profileAccountSectionTitle => 'Konto';

  @override
  String get profileAccountEmailHelper => 'Die E-Mail-Adresse des Kontos kann auf dieser Seite nicht geändert werden.';

  @override
  String get profileChangePasswordAction => 'Passwort ändern';

  @override
  String get profileChangePasswordDescription => 'Lege ein neues Passwort für dieses Konto fest.';

  @override
  String get notificationsPageTitle => 'Benachrichtigungen';

  @override
  String get notificationsMarkAllReadAction => 'Alle als gelesen markieren';

  @override
  String get notificationsNoTargetMessage => 'Für diese Benachrichtigung ist kein Ziel verfügbar.';

  @override
  String get notificationsTargetUnavailableMessage => 'Der mit dieser Benachrichtigung verknüpfte Inhalt ist nicht verfügbar.';

  @override
  String get notificationsLoadError => 'Benachrichtigungen konnten nicht geladen werden.';

  @override
  String get notificationsRetryButton => 'Erneut versuchen';

  @override
  String get notificationsEmptyMessage => 'Keine Benachrichtigungen verfügbar.';

  @override
  String get notificationsCommentReplyTitle => 'Neue Antwort auf deinen Kommentar';

  @override
  String get notificationsMentionTitle => 'Du wurdest erwähnt';

  @override
  String get notificationsPollResultTitle => 'Vote-Update';

  @override
  String notificationsCommentReplySubtitle(String actor, String target) {
    return 'Nutzer $actor hat in $target geantwortet';
  }

  @override
  String notificationsMentionSubtitle(String actor, String target) {
    return 'Nutzer $actor hat dich in $target erwähnt';
  }

  @override
  String notificationsPollResultSubtitle(String target) {
    return 'In $target ist ein neues Ergebnis verfügbar';
  }

  @override
  String get notificationsTargetPost => 'einer Voce';

  @override
  String get notificationsTargetNews => 'einer Nachricht';

  @override
  String get notificationsTargetPoll => 'einem Vote';

  @override
  String get notificationsTargetVideo => 'einem Video';

  @override
  String get notificationsTargetContent => 'einem Inhalt';

  @override
  String get notificationsUserFallback => 'Nutzer';

  @override
  String get profileDeleteAccountAction => 'Konto löschen';

  @override
  String get profileDeleteAccountDescription => 'Konto und Zugriff dauerhaft löschen';

  @override
  String get profileDeleteAccountDialogTitle => 'Konto löschen';

  @override
  String get profileDeleteAccountDialogMessage => 'Diese Aktion ist endgültig. Das Konto kann nicht wiederhergestellt werden. Gib DELETE ein, um zu bestätigen.';

  @override
  String get profileDeleteAccountConfirmationLabel => 'Löschbestätigung';

  @override
  String get profileDeleteAccountConfirmationHint => 'DELETE eingeben';

  @override
  String get profileDeleteAccountConfirmationError => 'Gib DELETE ein, um fortzufahren.';

  @override
  String get profileDeleteAccountCancelButton => 'Abbrechen';

  @override
  String get profileDeleteAccountConfirmButton => 'Dauerhaft löschen';

  @override
  String get profileDeleteAccountFailureMessage => 'Das Konto konnte nicht gelöscht werden. Bitte versuche es erneut.';

  @override
  String get identityActorTypePerson => 'Person';

  @override
  String get identityActorTypePublicOfficial => 'Amtsträger';

  @override
  String get identityActorTypePublicInstitution => 'Öffentliche Institution';

  @override
  String get identityActorTypeVerifiedOrganization => 'Verifizierte Organisation';

  @override
  String get identityVerificationNotVerified => 'Nicht verifiziert';

  @override
  String get identityVerificationLevel1 => 'Verifizierte Identität';

  @override
  String get identityVerificationLevel2 => 'Erweitert verifizierte Identität';

  @override
  String get identityBadgeLevel1 => 'Verifizierte Identität';

  @override
  String get identityBadgeLevel2 => 'Erweitert verifizierte Identität';

  @override
  String get identityBadgePublicOfficial => 'Amtsträger';

  @override
  String get identityBadgePublicInstitution => 'Öffentliche Institution';

  @override
  String get identityBadgeVerifiedOrganization => 'Verifizierte Organisation';

  @override
  String get identityOrganizationNameLabel => 'Name der Organisation';

  @override
  String get identityOrganizationNameRequired => 'Gib den Namen der Organisation ein.';

  @override
  String get identityInstitutionLevelMunicipality => 'Kommunal';

  @override
  String get identityInstitutionLevelProvince => 'Provinzial';

  @override
  String get identityInstitutionLevelRegion => 'Regional';

  @override
  String get identityInstitutionLevelMinistry => 'Ministerium';

  @override
  String get identityInstitutionLevelGovernment => 'Regierung';

  @override
  String get identityInstitutionLevelPublicAgency => 'Öffentliche Behörde';

  @override
  String get identityInstitutionLevelOtherPublicBody => 'Andere öffentliche Stelle';

  @override
  String get verificationRequestPersonLevel1 => 'Personenverifizierung — Stufe 1';

  @override
  String get verificationRequestPersonLevel2 => 'Personenverifizierung — Stufe 2';

  @override
  String get verificationRequestPublicOfficial => 'Verifizierung als Amtsträger';

  @override
  String get verificationRequestPublicInstitution => 'Verifizierung einer öffentlichen Institution';

  @override
  String get verificationRequestVerifiedOrganization => 'Organisationsverifizierung';

  @override
  String get verificationCenterTitle => 'Verifizierung und Kontotyp';

  @override
  String get verificationCurrentAccountSection => 'Aktuelles Konto';

  @override
  String verificationAccountTypeValue(String accountType) {
    return 'Kontotyp: $accountType';
  }

  @override
  String verificationLevelValue(String level) {
    return 'Verifizierungsstufe: $level';
  }

  @override
  String verificationOfficialTitleValue(String title) {
    return 'Amtliche Funktion: $title';
  }

  @override
  String verificationInstitutionNameValue(String name) {
    return 'Institution: $name';
  }

  @override
  String verificationOrganizationNameValue(String name) {
    return 'Organisation: $name';
  }

  @override
  String verificationInstitutionLevelValue(String level) {
    return 'Institutionsebene: $level';
  }

  @override
  String get verificationActiveRequestSection => 'Aktiver Antrag';

  @override
  String get verificationProfileUnchangedUntilApproval => 'Dein aktuelles Profil ändert sich erst, wenn der Antrag genehmigt wurde.';

  @override
  String get verificationCancelPendingAction => 'Ausstehenden Antrag zurückziehen';

  @override
  String get verificationPendingBlocksNewRequests => 'Du kannst keinen neuen Antrag stellen, solange ein anderer Antrag aussteht.';

  @override
  String get verificationNoActiveRequestSection => 'Kein aktiver Antrag';

  @override
  String get verificationNoActiveRequestDescription => 'Derzeit befindet sich kein Antrag von dir in Prüfung.';

  @override
  String get verificationLastRejectedSection => 'Letzter abgelehnter Antrag';

  @override
  String get verificationLastRejectedDescription => 'Dein letzter Antrag wurde abgelehnt.';

  @override
  String get verificationRejectedCanResubmit => 'Dein aktuelles Profil wurde nicht geändert. Du kannst die Angaben korrigieren und einen neuen Antrag stellen.';

  @override
  String get verificationAvailableRequestsSection => 'Verfügbare Anträge';

  @override
  String get verificationRequestLevel1Title => 'Personenverifizierung — Stufe 1 beantragen';

  @override
  String get verificationRequestLevel1Subtitle => 'Grundlegende persönliche Identitätsprüfung';

  @override
  String get verificationRequestLevel2Title => 'Personenverifizierung — Stufe 2 beantragen';

  @override
  String get verificationRequestLevel2Subtitle => 'Erweiterte persönliche Identitätsprüfung';

  @override
  String get verificationRequestPublicOfficialTitle => 'Konto als Amtsträger beantragen';

  @override
  String get verificationRequestPublicOfficialSubtitle => 'Erfordert eine amtliche Funktion und eine Prüfung';

  @override
  String get verificationRequestPublicInstitutionTitle => 'Konto für eine öffentliche Institution beantragen';

  @override
  String get verificationRequestPublicInstitutionSubtitle => 'Erfordert Institutionsname, Institutionsebene und Prüfung';

  @override
  String get verificationRequestOrganizationTitle => 'Konto als verifizierte Organisation beantragen';

  @override
  String get verificationRequestOrganizationSubtitle => 'Erfordert Organisationsdaten, Vertretungsrolle und Admin-Prüfung';

  @override
  String get verificationNoSelfServiceUpgrade => 'Für deinen aktuellen Kontostatus sind keine Verifizierungsoptionen verfügbar.';

  @override
  String get verificationRequestSubmitSuccess => 'Antrag erfolgreich eingereicht.';

  @override
  String get verificationRequestSubmitFailure => 'Der Antrag konnte nicht eingereicht werden.';

  @override
  String get verificationOfficialTitleDialogTitle => 'Verifizierung als Amtsträger';

  @override
  String get verificationOfficialTitleLabel => 'Amtliche Funktion';

  @override
  String get verificationOfficialTitleHint => 'z. B. Bürgermeister, Gemeinderat, Minister';

  @override
  String get verificationInstitutionDialogTitle => 'Verifizierung einer öffentlichen Institution';

  @override
  String get verificationInstitutionNameLabel => 'Name der Institution';

  @override
  String get verificationInstitutionNameHint => 'z. B. Stadt Rom';

  @override
  String get verificationInstitutionLevelLabel => 'Institutionsebene';

  @override
  String get verificationOrganizationDialogTitle => 'Organisationsverifizierung';

  @override
  String get verificationOrganizationNameHint => 'z. B. Umweltverein Italien';

  @override
  String get verificationSubmitRequestAction => 'Antrag einreichen';

  @override
  String get verificationCancelDialogTitle => 'Antrag zurückziehen';

  @override
  String get verificationCancelDialogBody => 'Möchtest du den ausstehenden Verifizierungsantrag wirklich zurückziehen?';

  @override
  String get verificationCancelSuccess => 'Antrag zurückgezogen.';

  @override
  String get verificationCancelFailure => 'Der Antrag konnte nicht zurückgezogen werden.';

  @override
  String get verificationStatusPendingSuffix => 'Antrag wird geprüft';

  @override
  String get verificationStatusRejectedSuffix => 'letzter Antrag abgelehnt';

  @override
  String get verificationReviewPageTitle => 'Verifizierungsprüfung';

  @override
  String get verificationReviewLoginRequired => 'Du musst angemeldet sein, um Verifizierungsanträge zu prüfen.';

  @override
  String verificationReviewPendingCount(int count) {
    return 'Ausstehende Anträge: $count';
  }

  @override
  String get verificationReviewNoPendingRequests => 'Es gibt keine ausstehenden Verifizierungsanträge.';

  @override
  String get verificationReviewUserIdLabel => 'Nutzer-ID';

  @override
  String get verificationReviewSubmittedLabel => 'Eingereicht';

  @override
  String get verificationReviewOfficialTitleLabel => 'Amtliche Funktion';

  @override
  String get verificationReviewInstitutionLabel => 'Institution';

  @override
  String get verificationReviewOrganizationLabel => 'Organisation';

  @override
  String get verificationReviewNoteLabel => 'Prüfnotiz';

  @override
  String get verificationReviewRejectAction => 'Ablehnen';

  @override
  String get verificationReviewApproveAction => 'Genehmigen';

  @override
  String get verificationReviewApproveDialogTitle => 'Antrag genehmigen';

  @override
  String get verificationReviewRejectDialogTitle => 'Antrag ablehnen';

  @override
  String get verificationReviewApproveConfirmation => 'Genehmigung dieses Antrags bestätigen?';

  @override
  String get verificationReviewRejectConfirmation => 'Ablehnung dieses Antrags bestätigen?';

  @override
  String get verificationReviewOptionalNoteLabel => 'Optionale Prüfnotiz';

  @override
  String get verificationReviewRequiredNoteLabel => 'Grund für die Ablehnung';

  @override
  String get verificationReviewOptionalHelper => 'Optional';

  @override
  String get verificationReviewRequiredHelper => 'Bei Ablehnung erforderlich';

  @override
  String get verificationReviewRequiredNoteError => 'Gib den Grund für die Ablehnung ein.';

  @override
  String get verificationReviewApprovedSuccess => 'Antrag genehmigt.';

  @override
  String get verificationReviewRejectedSuccess => 'Antrag abgelehnt.';

  @override
  String get verificationReviewOperationFailure => 'Vorgang fehlgeschlagen.';

  @override
  String get adminCenterTitle => 'Admin Center';

  @override
  String get adminCenterDashboardNavigation => 'Übersicht';

  @override
  String get adminCenterUsersNavigation => 'Nutzer';

  @override
  String get adminCenterVerificationNavigation => 'Verifizierungen';

  @override
  String get adminCenterReportsNavigation => 'Meldungen';

  @override
  String get adminCenterAuditNavigation => 'Audit';

  @override
  String get adminCenterAccountDetailsTitle => 'Kontodetails';

  @override
  String get adminCenterTryAgainAction => 'Erneut versuchen';

  @override
  String get adminCenterRetryAction => 'Erneut versuchen';

  @override
  String get adminCenterClearAction => 'Zurücksetzen';

  @override
  String get adminCenterApplyFiltersAction => 'Filter anwenden';

  @override
  String get adminCenterAllDates => 'Alle Zeiträume';

  @override
  String get adminCenterAuditDateFilterHelp => 'Audit nach Datum filtern';

  @override
  String get adminCenterActorUserIdLabel => 'Akteur-Nutzer-ID';

  @override
  String get adminCenterActionLabel => 'Aktion';

  @override
  String get adminCenterAuditActionHint => 'resolve_escalated_report';

  @override
  String get adminCenterTargetIdLabel => 'Ziel-ID';

  @override
  String get adminCenterOutcomeLabel => 'Ergebnis';

  @override
  String get adminCenterAllOutcomes => 'Alle Ergebnisse';

  @override
  String get adminCenterOutcomeSuccess => 'Erfolgreich';

  @override
  String get adminCenterOutcomeFailure => 'Fehlgeschlagen';

  @override
  String get adminCenterOutcomeDenied => 'Abgelehnt';

  @override
  String get adminCenterOutcomeNoChange => 'Keine Änderung';

  @override
  String get adminCenterOutcomeUnknown => 'Unbekannt';

  @override
  String get adminCenterAuditUnavailableTitle => 'Audit nicht verfügbar';

  @override
  String get adminCenterAuditUnavailableMessage => 'Prüfe Verbindung und Berechtigungen und versuche es erneut.';

  @override
  String get adminCenterNoAuditEntriesTitle => 'Keine Audit-Einträge';

  @override
  String get adminCenterNoAuditEntriesMessage => 'Für die ausgewählten Filter gibt es keine Einträge.';

  @override
  String get adminCenterAuditIdLabel => 'Audit-ID';

  @override
  String get adminCenterActorLabel => 'Akteur';

  @override
  String get adminCenterReasonLabel => 'Grund';

  @override
  String get adminCenterTimestampLabel => 'Zeitpunkt';

  @override
  String get adminCenterErrorLabel => 'Fehler';

  @override
  String get adminCenterRecordedValuesTitle => 'Gespeicherte Werte';

  @override
  String get adminCenterPreviousValueLabel => 'Vorher';

  @override
  String get adminCenterNewValueLabel => 'Neu';

  @override
  String get adminCenterContentTypeLabel => 'Inhaltstyp';

  @override
  String get adminCenterAllContent => 'Alle Inhalte';

  @override
  String get adminCenterPolls => 'Vote';

  @override
  String get adminCenterPosts => 'Voce';

  @override
  String get adminCenterNews => 'Nachrichten';

  @override
  String get adminCenterAwaitingAdminDecision => 'Wartet auf Admin-Entscheidung';

  @override
  String get adminCenterStatusLabel => 'Status';

  @override
  String get adminCenterAllStatuses => 'Alle Status';

  @override
  String get adminCenterStatusOpen => 'Offen';

  @override
  String get adminCenterStatusInReview => 'In Prüfung';

  @override
  String get adminCenterStatusResolved => 'Erledigt';

  @override
  String get adminCenterStatusDismissed => 'Verworfen';

  @override
  String get adminCenterAdminQueueUnavailableTitle => 'Admin-Eskalationswarteschlange nicht verfügbar';

  @override
  String get adminCenterReportsUnavailableTitle => 'Meldungen nicht verfügbar';

  @override
  String get adminCenterConnectionTryAgainMessage => 'Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get adminCenterNoAdminReportsTitle => 'Keine Meldungen warten auf Admin-Entscheidung';

  @override
  String get adminCenterNoReportsTitle => 'Keine Meldungen';

  @override
  String get adminCenterNoAdminReportsMessage => 'Es gibt keine eskalierten Meldungen, die eine Admin-Prüfung erfordern.';

  @override
  String get adminCenterNoReportsMessage => 'Für die ausgewählten Filter gibt es keine Meldungen.';

  @override
  String get adminCenterSearchUsersHint => 'Nach Name, Benutzername, E-Mail oder ID suchen';

  @override
  String get adminCenterClearSearchTooltip => 'Suche löschen';

  @override
  String get adminCenterUsersUnavailableTitle => 'Nutzer nicht verfügbar';

  @override
  String get adminCenterNoUsersFoundTitle => 'Keine Nutzer gefunden';

  @override
  String get adminCenterNoUsersTitle => 'Keine Nutzer';

  @override
  String get adminCenterNoUsersFoundMessage => 'Versuche es mit einem anderen Namen, Benutzernamen, einer anderen E-Mail oder ID.';

  @override
  String get adminCenterNoUsersMessage => 'Es gibt keine Konten zum Anzeigen.';

  @override
  String get adminCenterAccountUnavailableTitle => 'Konto nicht verfügbar';

  @override
  String get adminCenterBackToUsersAction => 'Zurück zu Nutzern';

  @override
  String get adminCenterPublicIdentitySection => 'Öffentliche Identität';

  @override
  String get adminCenterDisplayNameLabel => 'Anzeigename';

  @override
  String get adminCenterNotProvided => 'Nicht angegeben';

  @override
  String get adminCenterUsernameLabel => 'Benutzername';

  @override
  String get adminCenterUserIdLabel => 'Nutzer-ID';

  @override
  String get adminCenterIdentityTypeLabel => 'Identitätstyp';

  @override
  String get adminCenterAccountSection => 'Konto';

  @override
  String get adminCenterTechnicalRoleLabel => 'Technische Rolle';

  @override
  String get adminCenterRoleMirrorLabel => 'Profil-Rollenspiegel';

  @override
  String get adminCenterRoleSynchronizationLabel => 'Rollensynchronisierung';

  @override
  String get adminCenterSynchronized => 'Synchronisiert';

  @override
  String get adminCenterNotSynchronized => 'Nicht synchronisiert';

  @override
  String get adminCenterRoleNotSynchronized => 'Rolle nicht synchronisiert';

  @override
  String get adminCenterAccountStatusLabel => 'Kontostatus';

  @override
  String get adminCenterSuspendedUntilLabel => 'Gesperrt bis';

  @override
  String get adminCenterAccountManagementSection => 'Kontoverwaltung';

  @override
  String get adminCenterDangerZoneSection => 'Gefahrenbereich';

  @override
  String get adminCenterRoleManagementSection => 'Rollenverwaltung';

  @override
  String get adminCenterVerificationLevelLabel => 'Verifizierungsstufe';

  @override
  String get adminCenterVerificationStatusLabel => 'Verifizierungsstatus';

  @override
  String get adminCenterAccessInformationSection => 'Zugriffsinformationen';

  @override
  String get adminCenterEmailLabel => 'E-Mail';

  @override
  String get adminCenterNotAvailable => 'Nicht verfügbar';

  @override
  String get adminCenterEmailConfirmationLabel => 'E-Mail-Bestätigung';

  @override
  String get adminCenterNotConfirmed => 'Nicht bestätigt';

  @override
  String get adminCenterRegisteredLabel => 'Registriert';

  @override
  String get adminCenterLastAccessLabel => 'Letzter Zugriff';

  @override
  String get adminCenterLoadingDashboardTitle => 'Übersicht wird geladen';

  @override
  String get adminCenterLoadingDashboardMessage => 'Die neuesten Kennzahlen werden abgerufen.';

  @override
  String get adminCenterDashboardUnavailableTitle => 'Übersicht nicht verfügbar';

  @override
  String get adminCenterIndicatorsUnavailableMessage => 'Die Kennzahlen konnten nicht geladen werden.';

  @override
  String get adminCenterVerificationPendingIndicator => 'Ausstehende Verifizierungen';

  @override
  String get adminCenterOpenReportsIndicator => 'Offene Meldungen';

  @override
  String get adminCenterSuspendedAccountsIndicator => 'Gesperrte Konten';

  @override
  String get adminCenterStaffIndicator => 'Team';

  @override
  String get adminCenterNoPendingWorkTitle => 'Keine offenen Aufgaben';

  @override
  String get adminCenterNoPendingWorkMessage => 'Verifizierungen, Meldungen und gesperrte Konten sind abgearbeitet.';

  @override
  String get adminCenterCouldNotUpdateUsers => 'Die Nutzerliste konnte nicht aktualisiert werden.';

  @override
  String get adminCenterCouldNotUpdateReports => 'Die Meldungswarteschlange konnte nicht aktualisiert werden.';

  @override
  String get adminCenterUnnamedUser => 'Unbenannter Nutzer';

  @override
  String get adminCenterTemporarySuspensionTitle => 'Vorübergehende Sperre';

  @override
  String get adminCenterReactivateDescription => 'Sperre sofort aufheben und eine neue Anmeldung ermöglichen.';

  @override
  String get adminCenterSuspendDescription => 'Zugriff für begrenzte Zeit sperren und alle aktuellen Sitzungen beenden.';

  @override
  String get adminCenterSuspensionUnavailableDescription => 'Eine Sperre erfordert ein synchronisiertes Konto, das kein Admin-Konto ist.';

  @override
  String get adminCenterReactivateAccountAction => 'Konto reaktivieren';

  @override
  String get adminCenterSuspendAccountAction => 'Konto sperren';

  @override
  String get adminCenterForceLogoutAction => 'Abmeldung erzwingen';

  @override
  String get adminCenterSuspendedForceLogoutDescription => 'Die Sperre hat die aktuellen Sitzungen bereits beendet. Reaktiviere das Konto, bevor du eine separate Abmeldung testest.';

  @override
  String get adminCenterForceLogoutDescription => 'Alle aktuellen Sitzungen beenden, ohne das Konto zu sperren.';

  @override
  String get adminCenterForceLogoutUnavailableDescription => 'Erzwungene Abmeldung erfordert ein synchronisiertes Konto, das kein Admin-Konto ist.';

  @override
  String get adminCenterPermanentDeletionTitle => 'Dauerhafte Kontolöschung';

  @override
  String get adminCenterPermanentDeletionDescription => 'Authentifizierungsdaten löschen, alle Sitzungen beenden und den verbleibenden öffentlichen Datensatz anonymisieren.';

  @override
  String get adminCenterDeletionUnavailableDescription => 'Die Löschung erfordert ein synchronisiertes Konto, das kein Admin-Konto ist.';

  @override
  String get adminCenterDeleteAccountPermanentlyAction => 'Konto dauerhaft löschen';

  @override
  String get adminCenterDurationOneHour => '1 Stunde';

  @override
  String get adminCenterDurationOneDay => '24 Stunden';

  @override
  String get adminCenterDurationSevenDays => '7 Tage';

  @override
  String get adminCenterDurationThirtyDays => '30 Tage';

  @override
  String get adminCenterSuspendImmediateEffect => 'Das Konto verliert sofort den Zugriff und alle aktuellen Sitzungen werden beendet.';

  @override
  String get adminCenterDurationLabel => 'Dauer';

  @override
  String get adminCenterSuspendReasonHint => 'Begründe, warum dieses Konto gesperrt werden muss';

  @override
  String get adminCenterReactivateReasonHint => 'Begründe, warum dieses Konto reaktiviert werden kann';

  @override
  String get adminCenterReactivateConfirmation => 'Ich bestätige, dass dieses Konto wieder Zugriff erhalten kann.';

  @override
  String get adminCenterReactivateFailure => 'Das Konto konnte nicht reaktiviert werden. Prüfe Rolle und Status und versuche es erneut.';

  @override
  String get adminCenterReactivateSuccess => 'Konto reaktiviert. Eine neue Anmeldung ist jetzt möglich.';

  @override
  String get adminCenterForceLogoutFullDescription => 'Alle aktuellen Sitzungen dieses Kontos beenden. Das Konto bleibt aktiv und kann sich erneut anmelden.';

  @override
  String get adminCenterForceLogoutReasonHint => 'Begründe, warum die aktuellen Sitzungen beendet werden müssen';

  @override
  String get adminCenterForceLogoutConfirmation => 'Ich bestätige die sofortige Beendigung aller aktuellen Sitzungen dieses Kontos.';

  @override
  String get adminCenterForceLogoutFailure => 'Das Konto konnte nicht abgemeldet werden. Prüfe Rolle und Status und versuche es erneut.';

  @override
  String get adminCenterForceLogoutSuccess => 'Aktuelle Sitzungen beendet. Das Konto kann sich erneut anmelden.';

  @override
  String get adminCenterSuspendFailure => 'Das Konto konnte nicht gesperrt werden. Prüfe Rolle und Status und versuche es erneut.';

  @override
  String get adminCenterDeleteReasonHint => 'Begründe, warum dieses Konto gelöscht werden muss';

  @override
  String get adminCenterTypeDeleteLabel => 'DELETE eingeben';

  @override
  String get adminCenterTypeAccountIdLabel => 'Vollständige Konto-ID eingeben';

  @override
  String get adminCenterDeletePermanentlyAction => 'Dauerhaft löschen';

  @override
  String get adminCenterDeleteIrreversibleWarning => 'Diese Aktion ist unwiderruflich. Authentifizierungsdaten und aktuelle Sitzungen werden entfernt, der Avatar wird gelöscht und der verbleibende öffentliche Datensatz anonymisiert. Der Audit-Eintrag bleibt erhalten.';

  @override
  String get adminCenterDeleteFailure => 'Das Konto konnte nicht gelöscht werden. Prüfe Rolle, Status und Bestätigungswerte und versuche es erneut.';

  @override
  String get adminCenterDeleteSuccess => 'Konto dauerhaft gelöscht und personenbezogene Daten anonymisiert.';

  @override
  String get adminCenterChangeTechnicalRoleTitle => 'Technische Rolle ändern';

  @override
  String get adminCenterChangeRoleDescription => 'Prüfe aktuelle und gewünschte Rolle vor der Bestätigung.';

  @override
  String get adminCenterChangeRoleUnavailableDescription => 'Rollenänderungen erfordern ein synchronisiertes, nicht gelöschtes Konto.';

  @override
  String get adminCenterChangeRoleAction => 'Rolle ändern';

  @override
  String get adminCenterChangePublicIdentityTitle => 'Öffentliche Identität ändern';

  @override
  String get adminCenterChangeIdentityDescription => 'Öffentlichen Kontotyp und Verifizierungsstufe aktualisieren.';

  @override
  String get adminCenterChangeIdentityUnavailableDescription => 'Identitätsänderungen erfordern ein synchronisiertes Konto, das kein Admin-Konto ist.';

  @override
  String get adminCenterChangeIdentityAction => 'Identität ändern';

  @override
  String get adminCenterChoosePublicIdentityMessage => 'Wähle den öffentlichen Kontotyp und dessen Verifizierungsstatus.';

  @override
  String get adminCenterPublicAccountTypeLabel => 'Öffentlicher Kontotyp';

  @override
  String get adminCenterPersonVerificationHelper => 'Stufe 1 und Stufe 2 sind nur für Personen verfügbar.';

  @override
  String get adminCenterNonPersonVerificationHelper => 'Konten, die keine Person darstellen, verwenden weder Stufe 1 noch Stufe 2.';

  @override
  String get adminCenterBeforeLabel => 'Vorher';

  @override
  String get adminCenterAfterLabel => 'Nachher';

  @override
  String get adminCenterIdentityReasonHint => 'Begründe, warum die öffentliche Identität geändert werden muss';

  @override
  String get adminCenterIdentityConfirmation => 'Ich bestätige die oben angezeigte öffentliche Identität und Verifizierungsstufe.';

  @override
  String get adminCenterIdentityChangeFailure => 'Die öffentliche Identität konnte nicht geändert werden. Prüfe den Kontostatus und versuche es erneut.';

  @override
  String get adminCenterChooseTechnicalRoleMessage => 'Wähle die neue technische Rolle und dokumentiere, warum diese Änderung erforderlich ist.';

  @override
  String get adminCenterNewTechnicalRoleLabel => 'Neue technische Rolle';

  @override
  String get adminCenterSelectRole => 'Rolle auswählen';

  @override
  String get adminCenterRoleSessionWarning => 'Diese Änderung beendet die aktive Sitzung des betroffenen Nutzers. Er muss sich erneut anmelden, bevor er das Konto weiter verwenden kann.';

  @override
  String get adminCenterRoleReasonHint => 'Begründe, warum die technische Rolle geändert werden muss';

  @override
  String get adminCenterRoleConfirmation => 'Ich bestätige die oben angezeigte Rolle und weiß, dass sich der betroffene Nutzer erneut anmelden muss.';

  @override
  String get adminCenterRoleChangeFailure => 'Die Rollenänderung konnte nicht abgeschlossen werden. Prüfe den Kontostatus und versuche es erneut.';

  @override
  String get adminCenterChangingRole => 'Rolle wird geändert';

  @override
  String get adminCenterConfirmRoleChange => 'Rollenänderung bestätigen';

  @override
  String get adminCenterRoleUser => 'Nutzer';

  @override
  String get adminCenterRoleModerator => 'Moderator';

  @override
  String get adminCenterRoleAdmin => 'Admin';

  @override
  String get adminCenterAccountStatusActive => 'Aktiv';

  @override
  String get adminCenterAccountStatusSuspended => 'Gesperrt';

  @override
  String get adminCenterAccountStatusDeleted => 'Gelöscht';

  @override
  String get adminCenterVerificationStatusNone => 'Keine';

  @override
  String get adminCenterVerificationStatusPending => 'Ausstehend';

  @override
  String get adminCenterVerificationStatusRejected => 'Abgelehnt';

  @override
  String get adminCenterVerificationNotVerified => 'Nicht verifiziert';

  @override
  String get adminCenterVerificationLevel1 => 'Stufe 1';

  @override
  String get adminCenterVerificationLevel2 => 'Stufe 2';

  @override
  String get adminCenterReportSingular => 'Meldung';

  @override
  String get adminCenterReportPlural => 'Meldungen';

  @override
  String get adminCenterUserSingular => 'Nutzer';

  @override
  String get adminCenterUserPlural => 'Nutzer';

  @override
  String get adminCenterPoll => 'Vote';

  @override
  String get adminCenterPost => 'Voce';

  @override
  String get adminCenterUnknown => 'Unbekannt';

  @override
  String get adminCenterContentHidden => 'Inhalt ausgeblendet';

  @override
  String get adminCenterContentVisible => 'Inhalt sichtbar';

  @override
  String get adminCenterReportedByLabel => 'Gemeldet von';

  @override
  String get adminCenterContentOwnerLabel => 'Inhaber des Inhalts';

  @override
  String get adminCenterReviewReportAction => 'Meldung prüfen';

  @override
  String get adminCenterAdminDecisionAction => 'Admin-Entscheidung';

  @override
  String get adminCenterRestoreContentAction => 'Inhalt wiederherstellen';

  @override
  String get adminCenterHideContentAction => 'Inhalt ausblenden';

  @override
  String get adminCenterOpenProfileAction => 'Profil öffnen';

  @override
  String get adminCenterOpenContentAction => 'Inhalt öffnen';

  @override
  String get adminCenterDecisionNoViolation => 'Kein Verstoß';

  @override
  String get adminCenterDecisionViolationConfirmed => 'Verstoß bestätigt';

  @override
  String get adminCenterDecisionEscalateToAdmin => 'An Admin eskalieren';

  @override
  String get adminCenterResolutionNoAccountAction => 'Keine Kontoaktion';

  @override
  String get adminCenterResolutionAccountSuspended => 'Konto gesperrt';

  @override
  String get adminCenterResolutionLogoutForced => 'Abmeldung erzwungen';

  @override
  String get adminCenterResolutionAccountDeleted => 'Konto gelöscht';

  @override
  String get adminCenterReviewerLabel => 'Prüfer';

  @override
  String get adminCenterDecisionDescriptionNoViolation => 'Verwirft die Meldung, weil der Inhalt nicht gegen die aktuellen Regeln verstößt.';

  @override
  String get adminCenterDecisionDescriptionViolation => 'Bestätigt einen Verstoß und lässt den Fall für die in AC8.5 behandelte Inhaltsmaßnahme in Prüfung.';

  @override
  String get adminCenterDecisionDescriptionEscalation => 'Eskaliert den Fall für eine Prüfung auf Kontoebene durch einen Administrator.';

  @override
  String get adminCenterChooseModerationOutcome => 'Wähle das Moderationsergebnis für diese Meldung.';

  @override
  String get adminCenterDecisionAlreadyRecordedFailure => 'Die Entscheidung konnte nicht gespeichert werden. Die Meldung wurde möglicherweise bereits geprüft. Aktualisiere die Warteschlange und versuche es erneut.';

  @override
  String get adminCenterDecisionLabel => 'Entscheidung';

  @override
  String get adminCenterReportReasonLabel => 'Meldegrund';

  @override
  String get adminCenterReviewNoteLabel => 'Prüfnotiz';

  @override
  String get adminCenterReviewNoteHint => 'Beschreibe die Belege und die Moderationsentscheidung';

  @override
  String get adminCenterRecordingDecision => 'Entscheidung wird gespeichert';

  @override
  String get adminCenterConfirmDecision => 'Entscheidung bestätigen';

  @override
  String get adminCenterAdministratorDecisionTitle => 'Administratorentscheidung';

  @override
  String get adminCenterResolutionDescriptionNoAction => 'Schließt die eskalierte Meldung, ohne das Konto zu ändern.';

  @override
  String get adminCenterResolutionDescriptionSuspended => 'Schließt die Meldung, nachdem eine erfolgreiche Kontosperre bereits im Audit-Protokoll erfasst wurde.';

  @override
  String get adminCenterResolutionDescriptionLogout => 'Schließt die Meldung, nachdem eine erfolgreiche erzwungene Abmeldung bereits im Audit-Protokoll erfasst wurde.';

  @override
  String get adminCenterResolutionDescriptionDeleted => 'Schließt die Meldung, nachdem eine erfolgreiche Kontolöschung bereits im Audit-Protokoll erfasst wurde.';

  @override
  String get adminCenterChooseFinalOutcome => 'Wähle das endgültige Administratorergebnis für diese Eskalation.';

  @override
  String get adminCenterAdminResolutionFailure => 'Die Administratorentscheidung konnte nicht gespeichert werden. Aktualisiere die Warteschlange und versuche es erneut.';

  @override
  String get adminCenterAdminResolutionRequiresAction => 'Führe zuerst die passende Kontoaktion aus. Kehre dann zu dieser Meldung zurück und speichere die endgültige Administratorentscheidung.';

  @override
  String get adminCenterEscalationNoteLabel => 'Eskalationsnotiz';

  @override
  String get adminCenterFinalOutcomeLabel => 'Endgültiges Ergebnis';

  @override
  String get adminCenterAdministratorNoteLabel => 'Administratornotiz';

  @override
  String get adminCenterAdministratorNoteHint => 'Begründe die endgültige Entscheidung auf Kontoebene';

  @override
  String get adminCenterHideContentFailure => 'Der Inhalt konnte nicht ausgeblendet werden. Aktualisiere die Meldungswarteschlange und versuche es erneut.';

  @override
  String get adminCenterRestoreContentFailure => 'Der Inhalt konnte nicht wiederhergestellt werden. Aktualisiere die Meldungswarteschlange und versuche es erneut.';

  @override
  String get adminCenterHideContentWarning => 'Dadurch wird der gemeldete Inhalt aus dem öffentlichen Zugriff entfernt. Die Aktion kann später über den Filter „Erledigt“ rückgängig gemacht werden.';

  @override
  String get adminCenterRestoreContentWarning => 'Dadurch wird der gemeldete Inhalt wieder öffentlich verfügbar.';

  @override
  String get adminCenterActionReasonLabel => 'Grund der Aktion';

  @override
  String get adminCenterHideContentReasonHint => 'Begründe, warum der Inhalt ausgeblendet werden muss';

  @override
  String get adminCenterRestoreContentReasonHint => 'Begründe, warum der Inhalt wiederhergestellt werden kann';

  @override
  String get adminCenterHidingContent => 'Inhalt wird ausgeblendet';

  @override
  String get adminCenterRestoringContent => 'Inhalt wird wiederhergestellt';

  @override
  String get adminCenterReportedProfileTitle => 'Gemeldetes Profil';

  @override
  String get adminCenterReportedProfileNotice => 'Dieser Profilkontext stammt aus der geschützten Meldungswarteschlange. Administrative Kontoaktionen bleiben davon getrennt.';

  @override
  String get adminCenterCouldNotRefreshIndicators => 'Die Kennzahlen konnten nicht aktualisiert werden.';

  @override
  String get adminCenterCouldNotRefreshAccount => 'Die Kontodetails konnten nicht aktualisiert werden.';

  @override
  String get adminCenterReportAlreadyReviewed => 'Diese Meldung wurde bereits geprüft oder ist nicht mehr ausstehend.';

  @override
  String get adminCenterReportNotAwaitingAdmin => 'Diese Meldung wartet nicht auf eine Administratorentscheidung.';

  @override
  String get adminCenterConfirmedViolationRequired => 'Ein bestätigter Verstoß ist erforderlich, bevor die Sichtbarkeit eines Inhalts geändert werden kann.';

  @override
  String get adminCenterContentHiddenSuccess => 'Der gemeldete Inhalt wurde ausgeblendet.';

  @override
  String get adminCenterContentRestoredSuccess => 'Der gemeldete Inhalt wurde wiederhergestellt.';

  @override
  String get adminCenterMissingContentId => 'Die ursprüngliche Inhalts-ID fehlt.';

  @override
  String get adminCenterUnsupportedTargetType => 'Diese Meldung hat einen nicht unterstützten Zieltyp.';

  @override
  String get adminCenterOriginalContentUnavailable => 'Der ursprüngliche Inhalt ist nicht mehr verfügbar.';

  @override
  String get adminCenterNoReportedProfile => 'Mit diesem Inhalt ist kein gemeldetes Profil verknüpft.';

  @override
  String adminCenterRoleChangedSuccess(String previousRole, String newRole) {
    return 'Technische Rolle von $previousRole zu $newRole geändert. Der betroffene Nutzer wurde abgemeldet und muss sich erneut anmelden.';
  }

  @override
  String adminCenterIdentityChangedSuccess(String actorType, String verificationLevel) {
    return 'Öffentliche Identität auf $actorType mit $verificationLevel geändert.';
  }

  @override
  String adminCenterAccountSuspendedSuccess(String dateTime) {
    return 'Konto bis $dateTime gesperrt. Der betroffene Nutzer wurde abgemeldet.';
  }

  @override
  String adminCenterReportDecisionRecorded(String decision) {
    return 'Meldungsentscheidung gespeichert: $decision.';
  }

  @override
  String adminCenterAdministratorDecisionRecorded(String decision) {
    return 'Administratorentscheidung gespeichert: $decision.';
  }

  @override
  String adminCenterUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Nutzer',
      one: '$count Nutzer',
    );
    return '$_temp0';
  }

  @override
  String adminCenterReportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Meldungen',
      one: '$count Meldung',
    );
    return '$_temp0';
  }

  @override
  String adminCenterAccountValue(String account) {
    return 'Konto: $account';
  }

  @override
  String adminCenterSuspendedUntilValue(String dateTime) {
    return 'Gesperrt bis: $dateTime';
  }

  @override
  String adminCenterSuspendConfirmation(String dateTime) {
    return 'Ich bestätige die Sperre bis $dateTime und die sofortige Beendigung der aktuellen Sitzungen.';
  }

  @override
  String adminCenterAccountIdValue(String accountId) {
    return 'Konto-ID: $accountId';
  }

  @override
  String adminCenterCurrentRoleValue(String role) {
    return 'Aktuell: $role';
  }

  @override
  String adminCenterTargetFallback(String targetType, String targetId) {
    return '$targetType $targetId';
  }

  @override
  String adminCenterMinimumCharactersRequired(int count) {
    return 'Eine Notiz mit mindestens $count Zeichen ist erforderlich.';
  }

  @override
  String adminCenterMinimumReasonCharactersRequired(int count) {
    return 'Ein Grund mit mindestens $count Zeichen ist erforderlich.';
  }

  @override
  String adminCenterPageOf(int currentPage, int totalPages) {
    return 'Seite $currentPage von $totalPages';
  }

  @override
  String get profilePublicProfileSectionTitle => 'Öffentliches Profil';

  @override
  String get profileIdentityVerificationSectionTitle => 'Identität und Verifizierung';

  @override
  String get profilePreferencesSectionTitle => 'Einstellungen';

  @override
  String get profileNotificationsSectionTitle => 'Benachrichtigungen';

  @override
  String get profileActivitySectionTitle => 'Persönliche Aktivität';

  @override
  String get profileSecurityAccountSectionTitle => 'Sicherheit und Konto';

  @override
  String get profileThemeTitle => 'Design';

  @override
  String get profileThemeSystem => 'System';

  @override
  String get profileThemeSystemDescription => 'Folgt dem Gerätedesign';

  @override
  String get profileThemeLight => 'Hell';

  @override
  String get profileThemeDark => 'Dunkel';

  @override
  String get profileMyPollsTitle => 'Vote';

  @override
  String get profileMyPostsTitle => 'Voce';

  @override
  String get profileMyCommentsTitle => 'Meine Kommentare';

  @override
  String get profileMyFavoritesTitle => 'Gespeichert';

  @override
  String get profileAccountConnectionsTitle => 'Gefolgte Konten und Follower';

  @override
  String get accountConnectionsFollowingTab => 'Gefolgt';

  @override
  String get accountConnectionsFollowersTab => 'Follower';

  @override
  String get accountConnectionsEmptyFollowing => 'Du folgst noch keinen Konten.';

  @override
  String get accountConnectionsEmptyFollowers => 'Du hast noch keine Follower.';

  @override
  String get accountConnectionsLoadError => 'Konten konnten nicht geladen werden. Bitte versuche es erneut.';

  @override
  String get profileMyFollowedScopesTitle => 'Meine gefolgten Bereiche';

  @override
  String get profileLogoutAction => 'Abmelden';

  @override
  String get profileLogoutDescription => 'Vom aktuellen Konto abmelden';

  @override
  String get profileLogoutDialogTitle => 'Abmelden';

  @override
  String get profileLogoutDialogMessage => 'Möchtest du dich wirklich von deinem Konto abmelden?';

  @override
  String get profileLogoutCancelButton => 'Abbrechen';

  @override
  String get profileLogoutConfirmButton => 'Abmelden';

  @override
  String get publicProfilePageTitle => 'Öffentliches Profil';

  @override
  String get publicProfileUserFallback => 'Nutzer';

  @override
  String get publicProfileNoBio => 'Keine Bio verfügbar.';

  @override
  String get publicProfileResidenceLabel => 'Wohnort';

  @override
  String get publicProfileResidenceUnknown => 'Nicht angegeben';

  @override
  String get publicProfileMemberSinceLabel => 'Mitglied seit';

  @override
  String get publicProfileContentSectionTitle => 'Öffentliche Inhalte';

  @override
  String get publicProfilePollsAction => 'Vote';

  @override
  String get publicProfilePostsAction => 'Voce';

  @override
  String get publicProfileBlockUserAction => 'Nutzer blockieren';

  @override
  String get publicProfileLoadError => 'Das Profil konnte nicht geladen werden.';

  @override
  String get publicProfileNotFound => 'Profil nicht verfügbar.';

  @override
  String get publicProfileUnblockUserAction => 'Nutzer entsperren';

  @override
  String get publicProfileBlockDialogTitle => 'Diesen Nutzer blockieren?';

  @override
  String get publicProfileBlockDialogMessage => 'Du kannst die Blockierung später im öffentlichen Profil wieder aufheben.';

  @override
  String get publicProfileUnblockDialogTitle => 'Diesen Nutzer entsperren?';

  @override
  String get publicProfileUnblockDialogMessage => 'Der Nutzer wird aus deiner Blockierliste entfernt.';

  @override
  String get publicProfileBlockSuccess => 'Nutzer blockiert.';

  @override
  String get publicProfileUnblockSuccess => 'Nutzer entsperrt.';

  @override
  String get publicProfileBlockError => 'Die Blockierung konnte nicht aktualisiert werden. Bitte versuche es erneut.';

  @override
  String get publicProfileFollowersLabel => 'Follower';

  @override
  String get publicProfileFollowingLabel => 'Gefolgt';

  @override
  String get publicProfileFollowAction => 'Folgen';

  @override
  String get publicProfileUnfollowAction => 'Nicht mehr folgen';

  @override
  String get publicProfileFollowSuccess => 'Konto wird jetzt gefolgt.';

  @override
  String get publicProfileUnfollowSuccess => 'Konto wird nicht mehr gefolgt.';

  @override
  String get publicProfileFollowError => 'Der Follow-Status konnte nicht aktualisiert werden. Bitte versuche es erneut.';

  @override
  String get publicProfileFollowRetry => 'Follow-Informationen neu laden';

  @override
  String get contentLanguageFieldLabel => 'Sprache des Inhalts';

  @override
  String get contentLanguageFieldHelper => 'Wähle die Sprache aus, in der du den Inhalt geschrieben hast.';

  @override
  String get contentLanguageUndetermined => 'Nicht angegeben';

  @override
  String get createPollAdvancedOptionsTitle => 'Erweiterte Optionen';

  @override
  String get createPollAdvancedOptionsSubtitle => 'Anonymität, Sichtbarkeit der Ergebnisse, Stimmänderungen und Quorum.';

  @override
  String get onboardingSkipButton => 'Überspringen';

  @override
  String get onboardingNextButton => 'Weiter';

  @override
  String get onboardingStartButton => 'Starten';

  @override
  String get onboardingPollTitle => 'Vote';

  @override
  String get onboardingPollDescription => 'Nimm an einem Vote zu Themen teil, die dir wichtig sind, oder erstelle selbst einen, um die Meinung der Community einzuholen.';

  @override
  String get onboardingHeatIceTitle => 'Heat und Ice';

  @override
  String get onboardingHeatIceDescription => 'Nutze Heat und Ice, um zu zeigen, wie stark ein Inhalt dein Interesse weckt.';

  @override
  String get onboardingCivicMapTitle => 'Civic Map';

  @override
  String get onboardingCivicMapDescription => 'Erkunde Vote, Voce und News auf der Karte und entdecke, was in verschiedenen Gebieten passiert.';

  @override
  String get onboardingGeoScopeTitle => 'GeoScope';

  @override
  String get onboardingGeoScopeDescription => 'Wähle die geografische Ebene, der du folgen möchtest: Welt, Land oder Stadt.';

  @override
  String get onboardingVerificationTitle => 'Identitätsverifizierung';

  @override
  String get onboardingVerificationDescription => 'Einige Vote können eine bestimmte Verifizierungsstufe verlangen, um die Integrität der Abstimmung zu schützen.';

  @override
  String get pollDetail_voteReceiptButton => 'Stimmbeleg';

  @override
  String get pollDetail_voteReceiptTitle => 'Stimmbeleg';

  @override
  String get pollDetail_voteReceiptIdLabel => 'Beleg-ID';

  @override
  String get pollDetail_voteReceiptDateLabel => 'Erfasst';

  @override
  String get pollDetail_voteReceiptPrivacy => 'Dieser Beleg bestätigt, dass deine Stimme erfasst wurde, ohne deine getroffene Auswahl anzuzeigen.';

  @override
  String get pollDetail_voteReceiptCloseButton => 'Schließen';

  @override
  String get profileBiometricUnlockTitle => 'Biometrische Entsperrung';

  @override
  String get profileBiometricUnlockDescription => 'Schützt deine gespeicherte Sitzung mit Fingerabdruck oder biometrischer Erkennung des Geräts.';

  @override
  String get profileBiometricRequiresRememberMe => 'Dafür muss „Angemeldet bleiben“ aktiviert sein.';

  @override
  String get profileBiometricUnavailable => 'Biometrie ist auf diesem Gerät nicht verfügbar oder nicht eingerichtet.';

  @override
  String get profileBiometricEnableReason => 'Bestätige deine biometrischen Daten, um die Entsperrung von Social Vote zu aktivieren.';

  @override
  String get profileBiometricEnabledMessage => 'Biometrische Entsperrung aktiviert.';

  @override
  String get profileBiometricDisabledMessage => 'Biometrische Entsperrung deaktiviert.';

  @override
  String get profileBiometricAuthFailedMessage => 'Die biometrische Authentifizierung wurde nicht abgeschlossen.';

  @override
  String get biometricLockTitle => 'Social Vote ist gesperrt';

  @override
  String get biometricLockMessage => 'Verwende die Biometrie deines Geräts, um die gespeicherte Sitzung zu entsperren.';

  @override
  String get biometricUnlockButton => 'Entsperren';

  @override
  String get biometricUsePasswordButton => 'Passwort verwenden';

  @override
  String get biometricUnlockReason => 'Entsperre deine Social-Vote-Sitzung.';

  @override
  String get biometricUnlockFailedMessage => 'Entsperren fehlgeschlagen. Versuche es erneut oder verwende dein Passwort.';

  @override
  String get adminCenterOperationalActivityTitle => 'Operative Aktivität';

  @override
  String get adminCenterOperationalActivitySubtitle => 'Aggregierte Kennzahlen. Keine Echtzeit-Erfassung der Online-Präsenz.';

  @override
  String get adminCenterLast24HoursLabel => '24 Stunden';

  @override
  String get adminCenterLast7DaysLabel => '7 Tage';

  @override
  String get adminCenterNewUsersMetric => 'Neue Registrierungen';

  @override
  String get adminCenterRecentSignInsMetric => 'Letzte Anmeldungen';

  @override
  String get adminCenterPollsCreatedMetric => 'Erstellte Vote';

  @override
  String get adminCenterPostsCreatedMetric => 'Erstellte Voce';

  @override
  String get adminCenterAdminActionsMetric => 'Admin-Aktionen';

  @override
  String get authPublicNameHelper => 'Dies ist der Name, den andere Nutzer sehen. Dein Benutzername wird automatisch erstellt.';

  @override
  String get adminCenterRefreshMarkersTooltip => 'Globus-Marker aktualisieren';

  @override
  String get adminCenterMarkerDensityTitle => 'World-Marker-Dichte';

  @override
  String get adminCenterMarkerDensitySubtitle => 'Steuert das visuelle Marker-Budget des Home-Globus, ohne reale Koordinaten oder das Inhaltsranking zu verändern.';

  @override
  String get adminCenterMarkerDensityEmpty => 'Leer';

  @override
  String get adminCenterMarkerDensityFull => 'Voll';

  @override
  String adminCenterMarkerDensityBudget(int count) {
    return 'Home-Budget: $count Marker';
  }

  @override
  String get adminCenterMarkerDensitySaveError => 'Die World-Marker-Dichte konnte nicht gespeichert werden.';

  @override
  String get adminCenterMarkerDensityBackendUnavailable => 'Die Backend-Einstellungen für World-Marker sind noch nicht verfügbar.';

  @override
  String get adminCenterQuickActionsTitle => 'Schnelle Kontoaktionen';

  @override
  String get adminCenterModerationSnapshotTitle => 'Moderations- und Aktivitätsübersicht';

  @override
  String get adminCenterReportsReceivedMetric => 'Erhaltene Meldungen';

  @override
  String get adminCenterPendingReportsMetric => 'Ausstehende Meldungen';

  @override
  String get adminCenterConfirmedViolationsMetric => 'Bestätigte Verstöße';

  @override
  String get adminCenterReportsFiledMetric => 'Eingereichte Meldungen';

  @override
  String get adminCenterCommentsCreatedMetric => 'Erstellte Kommentare';

  @override
  String get adminCenterAdminActionsOnAccountMetric => 'Admin-Aktionen am Konto';

  @override
  String get adminCenterLastReportReceivedLabel => 'Letzte erhaltene Meldung';

  @override
  String get adminCenterOpenFullAccountAction => 'Vollständige Kontosteuerung öffnen';

  @override
  String get profileAppLanguageGerman => 'Deutsch';

  @override
  String get profileAppLanguagePersian => 'Persisch';

  @override
  String get discoveryPageTitle => 'Entdecken';

  @override
  String get organizationWorkspaceTitle => 'Organisationsbereich';

  @override
  String get organizationPilotBannerTitle => 'Kostenloser Pilot';

  @override
  String get organizationPilotBannerBody => 'Während des Piloten sind Sessions kostenlos. Einige professionelle Funktionen können künftig kostenpflichtig werden; die Abrechnung ist derzeit nicht aktiv.';

  @override
  String get organizationVerifiedLabel => 'Verifizierte Organisation';

  @override
  String get organizationEditProfile => 'Organisationsprofil bearbeiten';

  @override
  String get organizationCreateSession => 'Neue Session';

  @override
  String get organizationNoSessions => 'Noch keine Sessions. Erstelle die erste für ein Meeting, einen Workshop oder eine Veranstaltung.';

  @override
  String get organizationSessionsTitle => 'Live-Sessions';

  @override
  String get organizationRequiresVerificationTitle => 'Verifizierte Organisation erforderlich';

  @override
  String get organizationRequiresVerificationBody => 'Dieser Bereich ist nur für Konten verfügbar, die von Social Vote als verifizierte Organisation bestätigt wurden.';

  @override
  String get organizationProfileEditorTitle => 'Organisationsprofil';

  @override
  String get organizationLegalName => 'Rechtlicher Name';

  @override
  String get organizationPublicName => 'Öffentlicher Name';

  @override
  String get organizationType => 'Organisationstyp';

  @override
  String get organizationCountryCode => 'Ländercode';

  @override
  String get organizationCity => 'Stadt';

  @override
  String get organizationWebsite => 'Offizielle Website';

  @override
  String get organizationDescription => 'Beschreibung';

  @override
  String get organizationUploadCover => 'Titelbild ändern';

  @override
  String get organizationUploadLogo => 'Logo ändern';

  @override
  String get organizationMediaUpdated => 'Organisationsbild aktualisiert.';

  @override
  String get organizationNamesRequired => 'Rechtlicher und öffentlicher Name sind erforderlich.';

  @override
  String get organizationTypeAssociation => 'Verein';

  @override
  String get organizationTypeNonprofit => 'Gemeinnützige Organisation';

  @override
  String get organizationTypeCompany => 'Unternehmen';

  @override
  String get organizationTypeCooperative => 'Genossenschaft';

  @override
  String get organizationTypeSports => 'Sportorganisation';

  @override
  String get organizationTypePublicBody => 'Öffentliche Stelle';

  @override
  String get organizationTypeCommittee => 'Komitee / Gruppe';

  @override
  String get organizationTypeOther => 'Andere';

  @override
  String get sessionCreateTitle => 'Live-Session erstellen';

  @override
  String get sessionTitleLabel => 'Session-Titel';

  @override
  String get sessionExpectedParticipants => 'Erwartete Teilnehmende';

  @override
  String get sessionAccessMode => 'Teilnehmerzugang';

  @override
  String get sessionAccessOpen => 'Offen anonym';

  @override
  String get sessionAccessOpenHint => 'Jeder mit Link/Code kann teilnehmen. Die Duplikatvermeidung ist nur bestmöglich; dieser Modus garantiert nicht eine Person – eine Stimme.';

  @override
  String get sessionAccessControlled => 'Kontrolliert anonym';

  @override
  String get sessionAccessControlledHint => 'Verwendet einmalige anonyme Access Passes. Social Vote speichert nur den Hash des Access Pass und verknüpft Abstimmungsentscheidungen nicht mit Teilnehmerzugängen.';

  @override
  String get sessionResultsVisibility => 'Sichtbarkeit der Ergebnisse';

  @override
  String get sessionResultsLive => 'Live';

  @override
  String get sessionResultsAfterVote => 'Nach eigener Stimmabgabe';

  @override
  String get sessionResultsAfterClose => 'Nach Schließen der Frage';

  @override
  String get sessionResultsOrganizerOnly => 'Nur Organisator';

  @override
  String get sessionCreateAction => 'Session erstellen';

  @override
  String get sessionPilotLimit => 'Pilotlimit: 1 bis 250 Teilnehmende pro Session.';

  @override
  String get sessionStatusDraft => 'Entwurf';

  @override
  String get sessionStatusOpen => 'Offen';

  @override
  String get sessionStatusClosed => 'Geschlossen';

  @override
  String get sessionJoinCode => 'Zugangscode';

  @override
  String get sessionShareJoin => 'Teilnahmelink teilen';

  @override
  String get sessionCopyJoinLink => 'Link kopieren';

  @override
  String get sessionGenerateTokens => 'Access Passes erzeugen';

  @override
  String get sessionGenerateTokensCount => 'Anzahl Access Passes';

  @override
  String get sessionTokensOneTimeTitle => 'Diese Zugangsdaten jetzt speichern';

  @override
  String get sessionTokensOneTimeBody => 'Access Passes im Klartext werden nur in diesem Batch-Ergebnis angezeigt. Social Vote speichert nur deren Hashes. Sicher kopieren und verteilen.';

  @override
  String get sessionCopyTokens => 'Alle Links kopieren';

  @override
  String get sessionTokensSavedAction => 'Ich habe sie gespeichert';

  @override
  String get sessionOpenAction => 'Session öffnen';

  @override
  String get sessionCloseAction => 'Session schließen';

  @override
  String get sessionCloseConfirm => 'Abstimmung schließen und den unveränderlichen Verified-Result-Snapshot erzeugen?';

  @override
  String get sessionQuestionsTitle => 'Fragen';

  @override
  String get sessionAddQuestion => 'Frage hinzufügen';

  @override
  String get sessionQuestionTitle => 'Frage';

  @override
  String get sessionQuestionType => 'Fragetyp';

  @override
  String get sessionTypeYesNo => 'Ja / Nein';

  @override
  String get sessionTypeSingle => 'Eine Antwort';

  @override
  String get sessionTypeMultiple => 'Mehrere Antworten';

  @override
  String get sessionOptions => 'Optionen';

  @override
  String get sessionOptionHint => 'Eine Option pro Zeile.';

  @override
  String get sessionMinSelections => 'Minimale Auswahl';

  @override
  String get sessionMaxSelections => 'Maximale Auswahl';

  @override
  String get sessionAddAction => 'Hinzufügen';

  @override
  String get sessionOpenQuestion => 'Frage öffnen';

  @override
  String get sessionCloseQuestion => 'Frage schließen';

  @override
  String get sessionNoQuestions => 'Noch keine Fragen.';

  @override
  String get sessionPresenterTitle => 'Präsentation';

  @override
  String get sessionParticipantTitle => 'Social Vote Live';

  @override
  String get sessionJoinAction => 'Session beitreten';

  @override
  String get sessionTokenLabel => 'Teilnehmer-Token';

  @override
  String get sessionTokenHint => 'SV-…';

  @override
  String get sessionWaitingQuestion => 'Warten, bis der Organisator eine Frage öffnet…';

  @override
  String get sessionVoteAction => 'Stimme senden';

  @override
  String get sessionVoteReceived => 'Stimme empfangen';

  @override
  String get sessionResultsUnavailable => 'Die Ergebnisse sind nach der gewählten Session-Regel noch nicht sichtbar.';

  @override
  String get sessionPrivacyNotice => 'Der Organisator legt den operativen Zweck und die Fragen der Session fest. Social Vote verarbeitet die technischen Daten, die zur Bereitstellung und zum Schutz des Dienstes erforderlich sind. Anonyme Modi zeigen dem Organisator keine Verknüpfung zwischen Teilnehmerzugang und Auswahl. Datenschutzrollen können vom Kontext und den anwendbaren Vereinbarungen abhängen.';

  @override
  String get sessionNonBindingNotice => 'Pilot-Sessions dienen Konsultation und Beteiligung. Sie sind keine rechtsverbindliche Wahl, Satzungsabstimmung oder rechtliche Zertifizierung.';

  @override
  String get sessionOptionYes => 'Ja';

  @override
  String get sessionOptionNo => 'Nein';

  @override
  String get verifiedResultTitle => 'Verified Result';

  @override
  String get verifiedResultValid => 'Integritätsprüfung bestanden';

  @override
  String get verifiedResultInvalid => 'Integritätsprüfung fehlgeschlagen';

  @override
  String get verifiedResultReportId => 'Report-ID';

  @override
  String get verifiedResultHash => 'SHA-256-Ergebnis-Hash';

  @override
  String get verifiedResultGeneratedBy => 'Von Social Vote erzeugt und integritätsgesiegelt';

  @override
  String get verifiedResultNotLegalCertificate => 'Dies ist ein überprüfbarer aggregierter Ergebnisbericht, kein Rechtszertifikat und keine Zertifizierung einer rechtsverbindlichen Wahl.';

  @override
  String get verifiedResultShare => 'Prüflink teilen';

  @override
  String sessionResponses(int count) {
    return '$count Antworten';
  }

  @override
  String sessionResultVotes(int count) {
    return '$count Stimmen';
  }

  @override
  String get organizationVerifiedIdentityLocked => 'Name und Land gehören zur verifizierten Identität der Organisation. Änderungen erfordern eine neue Verifizierung. Titelbild, Logo, Typ, Stadt, Website und Beschreibung können frei geändert werden.';

  @override
  String get verifiedResultOpenedAt => 'Session eröffnet';

  @override
  String get verifiedResultEligibleCredentials => 'Berechtigte Zugangsdaten';

  @override
  String get verifiedResultIntegritySeal => 'Social Vote Integritätssiegel';

  @override
  String get organizationVerifiedNameLocked => 'Verifizierter Name und Land sind gesperrt. Eine Änderung erfordert eine neue Verifizierungsprüfung.';

  @override
  String get sessionRetentionLabel => 'Aufbewahrung der Rohstimmzettel';

  @override
  String get sessionRetention24h => '24 Stunden';

  @override
  String get sessionRetention7d => '7 Tage';

  @override
  String get sessionRetention30d => '30 Tage';

  @override
  String sessionRetentionValue(String value) {
    return 'Aufbewahrung der Rohstimmzettel: $value';
  }

  @override
  String get verifiedResultPrintPdf => 'PDF herunterladen';

  @override
  String get verifiedResultPdfError => 'Das PDF konnte nicht heruntergeladen werden. Versuche es erneut.';

  @override
  String get verifiedResultRestrictedTitle => 'Geschütztes Ergebnis';

  @override
  String get verifiedResultRestrictedBody => 'Dieses Verified Result ist nicht öffentlich verfügbar. Melde dich mit einem autorisierten Organisationskonto an, um es anzuzeigen.';

  @override
  String get verifiedResultPrivateVerificationTitle => 'Öffentliche Prüfung nicht verfügbar';

  @override
  String get verifiedResultPrivateVerificationBody => 'Dieses Ergebnis ist auf den Organisator beschränkt. Report-ID, SHA-256 und Integritätsprüfung bleiben im autorisierten Bericht verfügbar.';

  @override
  String get organizationAccountSectionTitle => 'Deine Organisationen';

  @override
  String get organizationManageAction => 'Verwalten';

  @override
  String get organizationViewPublicProfileAction => 'Profil ansehen';

  @override
  String get organizationOfficialWebsiteAction => 'Offizielle Website';

  @override
  String get organizationVerificationIntro => 'Die Verifizierung betrifft sowohl die Existenz der Organisation als auch deine Berechtigung, sie zu vertreten. Social Vote prüft die Angaben vor der Freigabe.';

  @override
  String get organizationVerificationLegalName => 'Rechtlicher Name';

  @override
  String get organizationVerificationPublicName => 'Öffentlicher Name';

  @override
  String get organizationVerificationType => 'Organisationstyp';

  @override
  String get organizationVerificationCountry => 'Land';

  @override
  String get organizationVerificationCountryRequired => 'Wähle das Land der Organisation aus.';

  @override
  String get organizationVerificationCity => 'Stadt';

  @override
  String get organizationVerificationWebsite => 'Offizielle Website';

  @override
  String get organizationVerificationRepresentativeRole => 'Deine Rolle in der Organisation';

  @override
  String get organizationVerificationRegistryId => 'Register / Steuer- / Organisationskennung';

  @override
  String get organizationVerificationAuthorityNote => 'Wie können wir deine Vertretungsberechtigung prüfen?';

  @override
  String get organizationVerificationAuthorityHelper => 'Beschreibe kurz deine Rolle oder einen Nachweis, den ein Admin während des Piloten prüfen kann.';

  @override
  String get organizationVerificationRequired => 'Pflichtfeld.';

  @override
  String get sessionControlRoomTitle => 'Session-Regie';

  @override
  String get sessionSectionLive => 'Live';

  @override
  String get sessionSectionQuestions => 'Fragen';

  @override
  String get sessionSectionAccess => 'Zugang';

  @override
  String get sessionSectionSettings => 'Einstellungen';

  @override
  String get sessionStageAction => 'Stage öffnen';

  @override
  String get sessionAccessPassesTitle => 'Teilnehmer-Zugangspässe';

  @override
  String get sessionAccessPassesSubtitle => 'Jeder Pass öffnet diese kontrolliert anonyme Session, ohne dass der Teilnehmer die lange Zugangsdatenfolge eingeben muss. Social Vote speichert den Pass nicht im Klartext.';

  @override
  String get sessionAccessPass => 'Zugangspass';

  @override
  String get sessionAccessPassDetected => 'Zugangspass erkannt';

  @override
  String get sessionAccessPassAutomatic => 'Dein persönlicher Pass ist bereit. Fahre fort, um anonym an der Session teilzunehmen.';

  @override
  String get sessionAccessPassFallback => 'Pass manuell eingeben';

  @override
  String get sessionAccessPassInvalid => 'Dieser Zugangspass ist ungültig, nicht mehr verfügbar oder die Session ist nicht geöffnet.';

  @override
  String get sessionAccessPassPrintWarning => 'Drucke, speichere oder verteile diese Pässe jetzt. Nach Verlassen dieser Ansicht kann Social Vote die Klartext-Pässe nicht erneut anzeigen.';

  @override
  String get sessionExistingPassesHidden => 'Aus Sicherheitsgründen können bereits erzeugte Pässe nicht erneut im Klartext angezeigt werden. Erzeuge neue Access Passes, um neue persönliche Links oder QR-Codes zu erhalten.';

  @override
  String get sessionCopyPassLinks => 'Alle Links kopieren';

  @override
  String get sessionCopyPassLink => 'Diesen Link kopieren';

  @override
  String get sessionControlledNeedsAccessPass => 'Erstelle vor dem Öffnen einer kontrollierten Session mindestens einen Zugangspass.';

  @override
  String get sessionJoinedParticipants => 'Beigetretene Zugangsdaten';

  @override
  String get sessionAccessesUsed => 'Zugänge mit Stimme';

  @override
  String get sessionBallotsRecorded => 'Erfasste Stimmzettel';

  @override
  String get sessionQuestionsCompleted => 'Abgeschlossene Fragen';

  @override
  String get sessionCurrentQuestion => 'Aktuelle Frage';

  @override
  String get sessionNoOpenQuestionTitle => 'Keine Frage ist geöffnet';

  @override
  String get sessionNoOpenQuestionBody => 'Die Teilnehmenden sind verbunden und warten. Öffne die nächste Frage, wenn du bereit bist.';

  @override
  String get sessionNotStartedTitle => 'Session noch nicht gestartet';

  @override
  String get sessionNotStartedBody => 'Diese Session existiert, ist aber noch nicht geöffnet. Lass diese Seite offen und warte, bis der Organisator sie startet.';

  @override
  String get sessionNoAccountRequired => 'Kein Social-Vote-Konto erforderlich';

  @override
  String get sessionReceiptDetails => 'Belegdetails';

  @override
  String get sessionOpenAccessInstructions => 'Zeige oder teile diesen QR-Code. Jeder mit dem Link kann beitreten, solange die Session geöffnet ist.';

  @override
  String get sessionControlledAccessInstructions => 'Erstelle persönliche Zugangspässe und gib jedem Teilnehmer einen. Der QR-Code jedes Passes enthält die Zugangsdaten automatisch.';

  @override
  String get sessionControlRoomHint => 'Verwalte Zugänge, Fragen, die projizierte Stage und das finale Verified Result an einem Ort.';

  @override
  String get sessionPresenterScreenTitle => 'Live-Stage';

  @override
  String get sessionStageWaiting => 'Warten auf die nächste Frage';

  @override
  String get sessionStageScan => 'Scannen, um der Session beizutreten';

  @override
  String get sessionConfigurationTitle => 'Session-Konfiguration';

  @override
  String get sessionAccessRecommended => 'Empfohlen für kontrollierte Meetings';

  @override
  String get sessionCreateIntroTitle => 'Meeting einrichten';

  @override
  String get sessionCreateIntroBody => 'Lege fest, wie Teilnehmende eintreten, wann Ergebnisse sichtbar werden und wie lange Rohstimmzettel aufbewahrt werden. Diese Regeln werden im Backend durchgesetzt.';

  @override
  String get verifiedCertificateNumber => 'Zertifikatsnummer';

  @override
  String get verifiedCertificateStatus => 'Integritätsstatus';

  @override
  String get verifiedCertificateIntegrityVerified => 'INTEGRITÄT VERIFIZIERT';

  @override
  String get verifiedCertificateIntegrityFailed => 'INTEGRITÄTSPRÜFUNG FEHLGESCHLAGEN';

  @override
  String get verifiedCertificateOrganizationSection => 'Organisation';

  @override
  String get verifiedCertificateSessionSection => 'Session';

  @override
  String get verifiedCertificateParticipationSection => 'Teilnahme';

  @override
  String get verifiedCertificateResultsSection => 'Verifizierte Ergebnisse';

  @override
  String get verifiedCertificateIntegritySection => 'Ergebnisintegrität';

  @override
  String get verifiedCertificateLegalName => 'Rechtlicher Name';

  @override
  String get verifiedCertificateOrganizationType => 'Organisationstyp';

  @override
  String get verifiedCertificateLocation => 'Ort';

  @override
  String get verifiedCertificateWebsite => 'Website';

  @override
  String get verifiedCertificateVerification => 'Verifizierung';

  @override
  String get verifiedCertificateIssuedAt => 'Zertifikat ausgestellt';

  @override
  String get verifiedCertificateAlgorithm => 'Integritätsalgorithmus';

  @override
  String get verifiedCertificateSchema => 'Berichtsschema';

  @override
  String get verifiedCertificateJoinedCredentials => 'Beigetretene Zugangsdaten';

  @override
  String get verifiedCertificateBallotsTotal => 'Erfasste Stimmzettel';

  @override
  String get verifiedCertificateQuestionsTotal => 'Fragen';

  @override
  String get verifiedCertificatePrivacyModel => 'Anonymes Ergebnismodell';

  @override
  String get verifiedCertificatePrivacyText => 'Der unveränderliche Snapshot enthält nur aggregierte Ergebnisse. Er enthält keine Teilnehmeridentität, keinen Klartext-Zugangspass, kein Teilnehmergeheimnis und keine Zuordnung zwischen Zugangsdaten und Stimmabgabe.';

  @override
  String get verifiedCertificateVerifyQr => 'Scanne diesen QR-Code, um den Bericht online zu prüfen.';

  @override
  String get organizationDashboardTitle => 'Organisationsübersicht';

  @override
  String get organizationActiveSessions => 'Live-Sessions';

  @override
  String get organizationVerifiedReports => 'Verifizierte Berichte';

  @override
  String get organizationTotalSessions => 'Sessions gesamt';

  @override
  String get sessionPrivacyPolicyAction => 'Datenschutzerklärung lesen';

  @override
  String get radioMondoTitle => 'Weltradio';

  @override
  String get radioMondoDescription => 'Drei originale Klangwelten zum Erkunden von Social Vote. Die Wiedergabe startet nur, wenn du einen Titel auswählst.';

  @override
  String get radioMondoTrackClassical => 'Klassische Umlaufbahn';

  @override
  String get radioMondoTrackRain => 'Regen über der Welt';

  @override
  String get radioMondoTrackYoung => 'Junger Pulse';

  @override
  String get radioMondoPlaying => 'Wird wiedergegeben';

  @override
  String get radioMondoStopped => 'Weltradio beendet';

  @override
  String get radioMondoStopAction => 'Stoppen';

  @override
  String get radioMondoPlaybackError => 'Die Audiodatei konnte nicht wiedergegeben werden';

  @override
  String get radioMondoForegroundOnly => 'Die Wiedergabe endet, wenn Social Vote geschlossen, in den Hintergrund verschoben oder der Browser-Tab ausgeblendet wird.';

  @override
  String get adminCenterEditorialNavigation => 'World Briefs';

  @override
  String get worldBriefEditorTitle => 'Social Vote World Briefs';

  @override
  String get worldBriefEditorDescription => 'Erstelle belegte Kurzberichte, mache Unsicherheit sichtbar und entscheide, was in den Nachrichten und auf dem Globus erscheint.';

  @override
  String get worldBriefAllStatuses => 'Alle Status';

  @override
  String get worldBriefCreateAction => 'Brief erstellen';

  @override
  String get worldBriefDraftSaved => 'Entwurf gespeichert';

  @override
  String get worldBriefPublished => 'Brief veröffentlicht';

  @override
  String get worldBriefWithdrawn => 'Brief zurückgezogen';

  @override
  String get worldBriefSaveError => 'Der Brief konnte nicht gespeichert werden';

  @override
  String get worldBriefPublishError => 'Der Brief konnte nicht veröffentlicht werden';

  @override
  String get worldBriefDraftDeleted => 'Entwurf gelöscht';

  @override
  String get worldBriefDeleteDraft => 'Entwurf löschen';

  @override
  String get worldBriefDeleteDraftConfirm => 'Diesen unveröffentlichten Entwurf dauerhaft löschen?';

  @override
  String get worldBriefRetry => 'Erneut versuchen';

  @override
  String get worldBriefStatusDraft => 'Entwurf';

  @override
  String get worldBriefStatusPublished => 'Veröffentlicht';

  @override
  String get worldBriefStatusWithdrawn => 'Zurückgezogen';

  @override
  String get worldBriefSetupRequired => 'Redaktionelles Backend nicht bereit';

  @override
  String get worldBriefSetupRequiredBody => 'Wende vor der Nutzung dieses Bereichs die enthaltene World-Brief-Datenbankmigration an.';

  @override
  String get worldBriefEmptyTitle => 'Noch keine World Briefs';

  @override
  String get worldBriefEmptyBody => 'Erstelle einen Entwurf, dokumentiere mindestens zwei Quellen und veröffentliche erst nach redaktioneller Prüfung.';

  @override
  String get worldBriefFeatured => 'Hervorgehoben';

  @override
  String get worldBriefOnGlobe => 'Auf dem Globus zeigen';

  @override
  String get worldBriefPriority => 'Priorität';

  @override
  String get worldBriefEditAction => 'Bearbeiten';

  @override
  String get worldBriefPublishAction => 'Veröffentlichen';

  @override
  String get worldBriefWithdrawAction => 'Zurückziehen';

  @override
  String get worldBriefSaveDraftAction => 'Entwurf speichern';

  @override
  String get worldBriefLanguage => 'Sprache des Briefs';

  @override
  String get worldBriefTitleField => 'Überschrift';

  @override
  String get worldBriefWhatHappened => 'Was passiert ist';

  @override
  String get worldBriefWhyItMatters => 'Warum es wichtig ist';

  @override
  String get worldBriefWhatIsUncertain => 'Was noch unklar ist';

  @override
  String get worldBriefSources => 'Quellen-URLs';

  @override
  String get worldBriefSourcesHint => 'Eine HTTPS-URL pro Zeile; mindestens zwei unabhängige Quellen.';

  @override
  String get worldBriefTwoSourcesRequired => 'Füge mindestens zwei Quellen hinzu.';

  @override
  String get worldBriefHttpsSourcesRequired => 'Jede Quelle muss HTTPS verwenden.';

  @override
  String get worldBriefGlobeSection => 'Platzierung auf dem Globus';

  @override
  String get worldBriefGlobeRequiresPoint => 'Die Anzeige auf dem Globus erfordert gültige Breiten- und Längengrade.';

  @override
  String get worldBriefCountryCode => 'Ländercode';

  @override
  String get worldBriefCityId => 'Stadt-ID';

  @override
  String get worldBriefLocationLabel => 'Ortsbezeichnung';

  @override
  String get worldBriefLatitude => 'Breitengrad';

  @override
  String get worldBriefLongitude => 'Längengrad';

  @override
  String get worldBriefBreaking => 'Eilmeldung';

  @override
  String get worldBriefExpiry => 'Prüf- oder Ablaufzeitraum';

  @override
  String worldBriefExpiryDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days Tage',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get worldBriefRequiredField => 'Dieses Feld ist erforderlich.';

  @override
  String get worldBriefCoordinatesRequired => 'Gib eine gültige Koordinate ein.';

  @override
  String get profileHowItWorksTitle => 'So funktioniert Social Vote';

  @override
  String get profileHowItWorksSubtitle => 'Personen, Organisationen, Voce, Vote, Sessions und Verifizierung.';

  @override
  String get profileMyPostsLoginRequired => 'Du musst angemeldet sein, um deine Voce anzuzeigen.';

  @override
  String get profileMyPostsCreatedByYou => 'Von dir erstellte Voce';

  @override
  String get profileMyPostsEmpty => 'Du hast noch keine Voce erstellt.';

  @override
  String get profileMyPollsLoginRequired => 'Du musst angemeldet sein, um deine Vote anzuzeigen.';

  @override
  String get profileMyPollsCreatedByYou => 'Von dir erstellte Vote';

  @override
  String get profileMyPollsEmpty => 'Du hast noch keine Vote erstellt.';

  @override
  String get profileMyCommentsLoginRequired => 'Du musst angemeldet sein, um deine Kommentare anzuzeigen.';

  @override
  String get profileMyCommentsEmpty => 'Du hast noch keine Kommentare geschrieben.';

  @override
  String get profileFollowedScopesLoginRequired => 'Du musst angemeldet sein.';

  @override
  String get profileFollowedScopesEmpty => 'Du folgst noch keinen Bereichen.';

  @override
  String get profileFollowedScopeWorld => 'Welt';

  @override
  String profileFollowedScopeCountry(String code) {
    return 'Land: $code';
  }

  @override
  String profileFollowedScopeCity(String city) {
    return 'Stadt: $city';
  }

  @override
  String profileFollowedScopeArea(double radius) {
    return 'Gebiet ($radius km)';
  }

  @override
  String get publicProfilePollsLoadError => 'Öffentliche Vote konnten nicht geladen werden.';

  @override
  String get publicProfilePollsEmpty => 'Keine öffentlichen Vote.';

  @override
  String get publicProfilePostsLoadError => 'Öffentliche Voce konnten nicht geladen werden.';

  @override
  String get publicProfilePostsEmpty => 'Keine öffentlichen Voce.';

  @override
  String get worldBriefSocialVoteView => 'Social Vote Einordnung';

  @override
  String get worldBriefSocialVoteViewHint => 'Redaktionelle Analyse oder Einordnung von Social Vote. Sie bleibt klar von Fakten und Unsicherheiten getrennt.';

  @override
  String get worldBriefSocialVoteViewPublicNote => 'Redaktionelle Einordnung von Social Vote, klar getrennt von den oben dargestellten Fakten.';

  @override
  String get worldBriefIndependentSourcesRequired => 'Für die Veröffentlichung sind mindestens zwei HTTPS-Quellen aus unterschiedlichen Domains erforderlich.';

  @override
  String get worldBriefPublishConfirmTitle => 'Letzte Prüfung vor der Veröffentlichung';

  @override
  String worldBriefPublishConfirmSources(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Quellen eingetragen',
      one: '1 Quelle eingetragen',
    );
    return '$_temp0';
  }

  @override
  String get worldBriefEnterpriseEditorTitle => 'Professioneller Redaktionseditor';

  @override
  String get worldBriefEnterpriseEditorHelp => 'Erstelle den Brief abschnittsweise. Social Vote übernimmt die technische Globe-Position automatisch: Land und Stadt auswählen, keine Koordinaten.';

  @override
  String get worldBriefEditorialContentSection => 'Redaktioneller Inhalt';

  @override
  String get worldBriefEditorialContentHelp => 'Trenne Fakten, Bedeutung, Unsicherheit und die Social-Vote-Einordnung. So bleibt der Brief nachvollziehbar und lesbar.';

  @override
  String get worldBriefSourcesSection => 'Quellen und Prüfung';

  @override
  String get worldBriefSourcesSectionHelp => 'Füge überprüfbare HTTPS-Quellen hinzu. Für die Veröffentlichung sind mindestens zwei unabhängige Domains erforderlich.';

  @override
  String get worldBriefDistributionSection => 'Verteilung';

  @override
  String get worldBriefDistributionHelp => 'Lege fest, wo der Brief erscheint. Nach Veröffentlichung ist er in News verfügbar; der Globe ist optional.';

  @override
  String get worldBriefNewsDestination => 'In Social Vote News veröffentlichen';

  @override
  String get worldBriefNewsDestinationHelp => 'Dies ist nach der Veröffentlichung das Hauptziel eines World Briefs.';

  @override
  String get worldBriefGlobeAutomaticHelp => 'Fügt einen Marker auf dem Globe hinzu. Ort auswählen; Social Vote ermittelt die Position automatisch.';

  @override
  String get worldBriefPlacementMode => 'Marker-Positionierung';

  @override
  String get worldBriefPlacementCity => 'Stadt / Ort';

  @override
  String get worldBriefPlacementCountry => 'Landeszentrum';

  @override
  String get worldBriefCountry => 'Land';

  @override
  String get worldBriefCity => 'Stadt oder Ort';

  @override
  String get worldBriefCityHelp => 'Beispiel: Tehran. Keine Breiten- oder Längengrade eingeben.';

  @override
  String get worldBriefResolveLocation => 'Position ermitteln';

  @override
  String get worldBriefCoordinatesAutomatic => 'Koordinaten werden automatisch verwaltet und nicht manuell eingegeben.';

  @override
  String worldBriefLocationResolved(String location) {
    return 'Position bereit: $location';
  }

  @override
  String get worldBriefChooseCountryFirst => 'Wähle zuerst ein Land.';

  @override
  String get worldBriefChooseCityFirst => 'Gib zuerst eine Stadt oder einen Ort ein.';

  @override
  String get worldBriefLocationNotResolved => 'Es konnte keine verlässliche Position gefunden werden. Prüfe Land und Stadt und versuche es erneut.';

  @override
  String get worldBriefVisibilitySection => 'Sichtbarkeit und Priorität';

  @override
  String get worldBriefVisibilityHelp => 'Steuere redaktionelle Hervorhebung, Dringlichkeit, Reihenfolge und Laufzeit, ohne die Fakten zu verändern.';

  @override
  String get worldBriefFeaturedHelp => 'Hebt den Brief auf redaktionellen Flächen stärker hervor.';

  @override
  String get worldBriefBreakingHelp => 'Nur für tatsächlich dringende oder sich schnell entwickelnde Ereignisse verwenden.';

  @override
  String get worldBriefPriorityHelp => '0 = normal/niedrig; 100 = höchste redaktionelle Priorität. Dies verändert nicht den Wahrheitsstatus des Inhalts.';

  @override
  String get worldBriefExpiryHelp => 'Nach diesem Zeitraum sollte der Brief ohne erneute redaktionelle Prüfung nicht aktiv bleiben.';

  @override
  String get profileAppLanguageSpanish => 'Spanisch';

  @override
  String get profileAppLanguagePortuguese => 'Portugiesisch';

  @override
  String get homeHeroPurpose => 'Entdecke, was zählt, teile deine Voce und nimm an Vote teil.';

  @override
  String get commentSection_hideComments => 'Kommentare ausblenden';

  @override
  String get commentSection_viewComments => 'Kommentare anzeigen';

  @override
  String get commentSection_hideReplies => 'Antworten ausblenden';

  @override
  String commentSection_editing(String snippet) {
    return 'Wird bearbeitet: $snippet';
  }

  @override
  String get commentSection_editInputHint => 'Kommentar bearbeiten';

  @override
  String commentSection_replyTo(String author) {
    return 'Antwort an $author';
  }

  @override
  String get commentSection_userFallback => 'Benutzer';

  @override
  String get commentSection_addError => 'Der Kommentar konnte nicht hinzugefügt werden.';

  @override
  String get commentSection_nestedReplyError => 'Verschachtelte Antworten über eine Ebene hinaus werden nicht unterstützt.';

  @override
  String get commentSection_addReplyError => 'Die Antwort konnte nicht hinzugefügt werden.';

  @override
  String get commentSection_editError => 'Der Kommentar konnte nicht bearbeitet werden.';

  @override
  String get commentSection_deleteError => 'Der Kommentar konnte nicht gelöscht werden.';

  @override
  String get commentSection_edited => 'Bearbeitet';

  @override
  String get commentSection_editAction => 'Bearbeiten';
}
