// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Social Vote';

  @override
  String get voteButton => 'Vote';

  @override
  String get createPollPageTitle => 'Créer un Vote';

  @override
  String get createPollPageSubtitle => 'Définissez un nouveau vote civique';

  @override
  String get createPollBasicInfoTitle => 'Informations de base';

  @override
  String get createPollBasicInfoSubtitle => 'Définissez les principaux détails du Vote.';

  @override
  String get createPollTitleFieldLabel => 'Titre *';

  @override
  String get createPollTitleFieldHelper => 'Une question ou une affirmation claire et concise.';

  @override
  String get createPollDescriptionFieldLabel => 'Description (facultatif)';

  @override
  String get createPollVotingModelTitle => 'Fonctionnement du vote';

  @override
  String get createPollVotingModelSubtitle => 'Choisissez si chaque personne peut sélectionner une seule réponse ou plusieurs réponses.';

  @override
  String get createPollTypeFieldLabel => 'Type de Vote';

  @override
  String createPollSelectionRules(int min, int max) {
    return 'Règles de sélection : minimum $min, maximum $max sélections (ajustées automatiquement selon le type de Vote et les options).';
  }

  @override
  String get createPollAllowVoteChangeTitle => 'Autoriser les votants à modifier leur vote';

  @override
  String get createPollAllowVoteChangeSubtitle => 'Jusqu’à la clôture du Vote.';

  @override
  String get createPollOptionsTitle => 'Réponses';

  @override
  String get createPollOptionsSubtitle => 'Saisissez au moins deux réponses parmi lesquelles les votants pourront choisir. Les champs marqués d’un * sont obligatoires.';

  @override
  String createPollOptionLabel(int index, Object requiredMarker) {
    return 'Option $index$requiredMarker';
  }

  @override
  String get createPollRemoveOptionTooltip => 'Supprimer l’option';

  @override
  String get createPollAddOptionButton => 'Ajouter une option';

  @override
  String get createPollParticipationPrivacyTitle => 'Participation et confidentialité';

  @override
  String get createPollParticipationPrivacySubtitle => 'Décidez qui peut voter et quel niveau de confidentialité appliquer aux votes.';

  @override
  String get createPollWhoCanVoteLabel => 'Qui peut voter ?';

  @override
  String get createPollParticipationEveryoneSubtitle => 'Tout utilisateur inscrit peut participer.';

  @override
  String get createPollParticipationGeoScopeSubtitle => 'Limiter ce Vote aux personnes d’un pays précis.';

  @override
  String get createPollCountryFieldLabel => 'Pays de ce Vote';

  @override
  String get createPollCountryFieldHelper => 'Ce pays déterminera qui est autorisé à participer à ce Vote (future intégration backend).';

  @override
  String get createPollVoteAnonymityTitle => 'Anonymat du Vote';

  @override
  String get createPollAnonymityAnonymousSubtitle => 'Réglage par défaut recommandé pour les plateformes de vote civique.';

  @override
  String get createPollAnonymityPublicSubtitle => 'À utiliser avec prudence : les votes peuvent être associés aux identités (fonction future).';

  @override
  String get createPollResultsValidityTitle => 'Résultats et validité';

  @override
  String get createPollResultsValiditySubtitle => 'Contrôlez quand les résultats sont visibles et définissez un quorum minimal si nécessaire.';

  @override
  String get createPollResultsVisibilityFieldLabel => 'Visibilité des résultats';

  @override
  String get createPollQuorumTitle => 'Quorum (facultatif)';

  @override
  String get createPollQuorumSubtitle => 'S’il est défini, le Vote n’est considéré valide que si ce nombre minimum de votes est atteint. Laissez vide pour aucun quorum.';

  @override
  String get createPollQuorumMinVotesFieldLabel => 'Nombre minimum de votes';

  @override
  String get createPollTimingTitle => 'Calendrier';

  @override
  String get createPollTimingSubtitle => 'Définissez la période pendant laquelle le Vote doit être ouvert.';

  @override
  String get createPollStartDateLabel => 'Date de début';

  @override
  String get createPollEndDateLabel => 'Date de fin';

  @override
  String get createPollChangeDateButtonLabel => 'Modifier';

  @override
  String get createPollTimingStatusInfo => 'Le statut initial (ouvert/programmé/fermé) sera déterminé automatiquement selon ces dates.';

  @override
  String get createPollSuccessMessage => 'Vote créé avec succès';

  @override
  String get createPollSubmitCreatingLabel => 'Création...';

  @override
  String get createPollSubmitLabel => 'Créer le Vote';

  @override
  String get createPollPollTypeYesNoLabel => 'Oui / Non';

  @override
  String get createPollPollTypeSingleChoiceLabel => 'Une réponse';

  @override
  String get createPollPollTypeMultipleChoiceLabel => 'Plusieurs réponses';

  @override
  String get createPollPollTypeApprovalLabel => 'Vote par approbation';

  @override
  String get createPollPollTypeRankedLabel => 'Choix classé';

  @override
  String get createPollPollTypeScoreLabel => 'Score / Évaluation';

  @override
  String get createPollParticipationScopeEveryoneLabel => 'Tout le monde peut voter';

  @override
  String get createPollParticipationScopeGeoScopeOnlyLabel => 'Uniquement les utilisateurs d’un pays précis';

  @override
  String get createPollAnonymityLevelAnonymousLabel => 'Les votes sont anonymes';

  @override
  String get createPollAnonymityLevelPublicLabel => 'Les votes sont publics (usage avancé / restreint)';

  @override
  String get createPollResultsVisibilityAlwaysLabel => 'Toujours visibles (tant que le Vote est ouvert)';

  @override
  String get createPollResultsVisibilityAfterVoteLabel => 'Visibles uniquement après avoir voté';

  @override
  String get createPollResultsVisibilityAfterCloseLabel => 'Visibles uniquement après la clôture du Vote';

  @override
  String get homeLoginButton => 'Se connecter';

  @override
  String get homeRegisterButton => 'S’inscrire';

  @override
  String get homeProfileButton => 'Profil';

  @override
  String get homeLogoutButton => 'Se déconnecter';

  @override
  String get homeLogoutMessage => 'Déconnexion terminée. Vous utilisez maintenant l’application en tant qu’invité (lecture seule).';

  @override
  String get homeSearchHint => 'Rechercher des villes, pays, comptes et contenus...';

  @override
  String get searchPageTitle => 'Rechercher';

  @override
  String get searchInputHint => 'Rechercher des comptes, Vote, News, Voce...';

  @override
  String get searchClearTooltip => 'Effacer la recherche';

  @override
  String get searchTypeAll => 'Tout';

  @override
  String get searchTypePolls => 'Vote';

  @override
  String get searchTypeNews => 'News';

  @override
  String get searchTypePosts => 'Voce';

  @override
  String get searchTypeAccounts => 'Comptes';

  @override
  String get searchSortHottest => 'Les plus populaires';

  @override
  String get searchSortLatest => 'Les plus récents';

  @override
  String get searchPollStatusAll => 'Tous les Vote';

  @override
  String get searchPollStatusOpen => 'Ouvert';

  @override
  String get searchPollStatusClosed => 'Fermé';

  @override
  String get searchIdleMessage => 'Saisissez un terme pour commencer la recherche.';

  @override
  String get searchErrorMessage => 'Un problème est survenu pendant la recherche.';

  @override
  String get searchRetryButton => 'Réessayer';

  @override
  String get searchEmptyMessage => 'Aucun résultat trouvé pour cette recherche.';

  @override
  String get searchContentUnavailable => 'Contenu indisponible';

  @override
  String get searchResultTypePoll => 'Vote';

  @override
  String get searchResultTypeNews => 'News';

  @override
  String get searchResultTypePost => 'Voce';

  @override
  String get searchResultTypeAccount => 'Compte';

  @override
  String get searchResultTypeMixed => 'Mixte';

  @override
  String homeUserStatusLoggedIn(Object userId) {
    return 'Connecté en tant que : $userId';
  }

  @override
  String get homeUserStatusGuest => 'Mode invité : lecture seule. Connectez-vous ou inscrivez-vous pour voter, commenter et réagir.';

  @override
  String get homeScopeLabelWorld => 'Monde – Votes et actualités mondiales';

  @override
  String get homeScopeLabelCountry => 'Pays – Votes et actualités nationales';

  @override
  String get homeScopeLabelCity => 'Ville – Votes et actualités locales';

  @override
  String get homeScopeShortWorld => 'Monde';

  @override
  String get homeScopeShortCountry => 'Pays';

  @override
  String get homeScopeShortCity => 'Ville';

  @override
  String get homeScopeChipWorld => 'Monde';

  @override
  String get homeScopeChipItaly => 'Italie';

  @override
  String get homeScopeChipTorino => 'Turin';

  @override
  String get homeScopeChangedWorld => 'Zone changée vers Monde';

  @override
  String get homeScopeChangedItaly => 'Zone changée vers Italie';

  @override
  String get homeScopeChangedTorino => 'Zone changée vers Turin';

  @override
  String get followScopeButtonFollowed => 'Suivi';

  @override
  String get followScopeButtonFollow => 'Suivre cette zone';

  @override
  String get homeTrendingTitle => 'Pulse maintenant';

  @override
  String get homeTrendingError => 'Impossible de charger Pulse maintenant pour cette zone.';

  @override
  String get homeTrendingEmpty => 'Aucun contenu dans Pulse maintenant pour cette zone.';

  @override
  String homeForYouTitle(Object scope) {
    return 'Pulse ($scope)';
  }

  @override
  String get homeForYouError => 'Impossible de charger Pulse pour cette zone.';

  @override
  String get homeForYouEmpty => 'Aucun contenu suggéré dans Pulse pour cette zone actuellement.';

  @override
  String homePollsTitle(Object scope) {
    return 'Vote à la une ($scope)';
  }

  @override
  String get homePollsEmptyTitle => 'Aucun Vote pour cette zone';

  @override
  String get homePollsEmptySubtitle => 'Aucun Vote n’est disponible pour cette zone.';

  @override
  String get homePollsViewAllButton => 'Voir les Vote';

  @override
  String homeNewsTitle(Object scope) {
    return 'Principales News ($scope)';
  }

  @override
  String get homeNewsErrorTitle => 'Impossible de charger les News';

  @override
  String get homeNewsErrorSubtitle => 'Un problème est survenu lors du chargement des News pour cette zone.';

  @override
  String get homeNewsEmptyTitle => 'Aucune News pour cette zone';

  @override
  String get homeNewsEmptySubtitle => 'Aucune News n’est disponible pour ce périmètre actuellement.';

  @override
  String get homeNewsViewAllButton => 'Voir toutes les News';

  @override
  String get homeNewsBreakingBadge => 'URGENT';

  @override
  String homeSocialTitle(Object scope) {
    return 'Voce ($scope)';
  }

  @override
  String get homeSocialErrorTitle => 'Impossible de charger Voce';

  @override
  String get homeSocialErrorSubtitle => 'Un problème est survenu lors du chargement de Voce pour cette zone.';

  @override
  String get homeSocialEmptyTitle => 'Aucune Voce pour cette zone';

  @override
  String get homeSocialEmptySubtitle => 'Aucun contenu Voce pour cette zone actuellement.';

  @override
  String get homeSocialViewFeedButton => 'Voir toutes les Voce';

  @override
  String get pollDetail_title => 'Détails du Vote';

  @override
  String get pollDetail_removeFromFavoritesTooltip => 'Retirer des éléments enregistrés';

  @override
  String get pollDetail_addToFavoritesTooltip => 'Enregistrer';

  @override
  String get pollDetail_chipAnonymous => 'Vote anonyme';

  @override
  String get pollDetail_chipPublic => 'Vote public';

  @override
  String get pollDetail_chipRestrictedGeo => 'Limité au périmètre géographique';

  @override
  String pollDetail_quorumReached(int currentVotes, int requiredVotes) {
    return 'Quorum atteint ($currentVotes / $requiredVotes)';
  }

  @override
  String pollDetail_quorumNotReached(int currentVotes, int requiredVotes) {
    return 'Quorum non atteint ($currentVotes / $requiredVotes)';
  }

  @override
  String get pollDetail_optionsTitle => 'Options';

  @override
  String get pollDetail_statusClosedMessage => 'Ce Vote est fermé.';

  @override
  String get pollDetail_statusScheduledMessage => 'Ce Vote n’est pas encore ouvert.';

  @override
  String get pollDetail_statusNotAvailableMessage => 'Le vote n’est pas disponible.';

  @override
  String get pollDetail_voteSubmitted => 'Vote envoyé avec succès !';

  @override
  String get pollDetail_voteButton => 'Voter';

  @override
  String get pollDetail_resultsTitle => 'Résultats';

  @override
  String pollDetail_outcomePrefix(Object label) {
    return 'Résultat : $label';
  }

  @override
  String get pollDetail_noResults => 'Aucun résultat disponible pour le moment.';

  @override
  String get pollDetail_resultsAfterVote => 'Les résultats seront visibles après votre vote.';

  @override
  String get pollDetail_resultsWhenClosed => 'Les résultats seront visibles à la clôture du Vote.';

  @override
  String get pollType_yesNo => 'Oui / Non';

  @override
  String get pollType_singleChoice => 'Choix unique';

  @override
  String get pollType_multipleChoice => 'Choix multiples';

  @override
  String get pollType_approval => 'Approbation';

  @override
  String get pollStatus_draft => 'Brouillon';

  @override
  String get pollStatus_open => 'Ouvert';

  @override
  String get pollStatus_closed => 'Fermé';

  @override
  String get pollStatus_scheduled => 'Programmé';

  @override
  String get pollGeo_global => 'Global';

  @override
  String get pollGeo_local => 'Local';

  @override
  String get pollOutcome_approved => 'Approuvé';

  @override
  String get pollOutcome_rejected => 'Rejeté';

  @override
  String get pollOutcome_tie => 'Égalité';

  @override
  String get pollOutcome_noMajority => 'Aucune majorité';

  @override
  String get pollOutcome_notApplicable => 'Sans objet';

  @override
  String get pollList_title => 'Vote';

  @override
  String get pollList_scopeWorld => 'Monde';

  @override
  String get pollList_scopeCountryFallback => 'Pays';

  @override
  String get pollList_scopeCityFallback => 'Ville';

  @override
  String get pollList_scopeDescriptionGlobal => 'Affichage des Vote globaux.';

  @override
  String get pollList_scopeDescriptionCountry => 'Affichage des Vote pour ce pays.';

  @override
  String get pollList_scopeDescriptionCity => 'Affichage des Vote pour cette ville.';

  @override
  String get pollList_filterStatus_all => 'Tous';

  @override
  String get pollList_filterStatus_open => 'Ouverts';

  @override
  String get pollList_filterStatus_closed => 'Fermés';

  @override
  String get pollList_sort_latest => 'Plus récents';

  @override
  String get pollList_sort_hottest => 'Plus populaires';

  @override
  String get pollList_filterScope_currentArea => 'Zone actuelle';

  @override
  String pollList_headerTitle(Object scopeLabel, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Vote trouvés',
      one: '1 Vote trouvé',
      zero: 'aucun Vote trouvé',
    );
    return '$scopeLabel · $_temp0';
  }

  @override
  String get pollList_createPollButton => 'Créer un Vote';

  @override
  String get pollList_paginationHint => 'Faites défiler pour charger plus de Vote…';

  @override
  String get pollList_emptyMessage => 'Aucun Vote correspondant à ce filtre pour cette zone.';

  @override
  String get pollType_ranked => 'Choix classé';

  @override
  String get pollType_score => 'Vote par score';

  @override
  String get pollVisibility_whileOpen => 'Résultats visibles pendant l’ouverture';

  @override
  String get pollVisibility_afterVote => 'Résultats visibles après le vote';

  @override
  String get pollVisibility_afterClose => 'Résultats visibles après la clôture';

  @override
  String get pollCard_countryRestricted => 'Limité au pays';

  @override
  String pollCard_restrictedToCountry(Object countryName) {
    return 'Limité à $countryName';
  }

  @override
  String pollCard_quorumLabel(int minVotes) {
    return 'Quorum $minVotes';
  }

  @override
  String get pollCard_resultsVisibleChip => 'Résultats visibles';

  @override
  String get pollCard_resultsAfterVoteChip => 'Après le vote';

  @override
  String get pollCard_resultsAfterCloseChip => 'Après la clôture';

  @override
  String get pollCard_publicOfficialPublisher => 'Responsable public';

  @override
  String get pollCard_institutionPublisher => 'Institution';

  @override
  String get pollCard_representativePublisher => 'Représentant';

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
  String get pollCard_viewDetails => 'Voir les détails';

  @override
  String pollResult_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Résultats ($count votes)',
      one: 'Résultats (1 vote)',
      zero: 'Résultats (aucun vote)',
    );
    return '$_temp0';
  }

  @override
  String get voteError_noSelection => 'Veuillez sélectionner au moins une option.';

  @override
  String get voteError_unauthorized => 'Vous n’êtes pas autorisé à voter dans ce Vote.';

  @override
  String get voteError_generic => 'Échec de l’envoi du vote. Veuillez réessayer.';

  @override
  String get commentSection_title => 'Commentaires';

  @override
  String get commentSection_sortLabel => 'Trier :';

  @override
  String get commentSection_sortOldest => 'Les plus anciens';

  @override
  String get commentSection_sortNewest => 'Les plus récents';

  @override
  String get commentSection_errorGeneric => 'Une erreur est survenue lors du chargement des commentaires.';

  @override
  String get commentSection_empty => 'Aucun commentaire pour le moment. Soyez le premier à commenter.';

  @override
  String get commentSection_loadMore => 'Charger plus de commentaires';

  @override
  String commentSection_replyingTo(Object snippet) {
    return 'Réponse à : $snippet';
  }

  @override
  String get commentSection_cancelReply => 'Annuler';

  @override
  String get commentSection_inputHintRoot => 'Ajouter un commentaire...';

  @override
  String get commentSection_inputHintReply => 'Écrire une réponse...';

  @override
  String get commentSection_deleteAction => 'Supprimer';

  @override
  String get commentSection_replyAction => 'Répondre';

  @override
  String get commentSection_youBadge => 'Vous';

  @override
  String get newsDetail_title => 'Détails de la News';

  @override
  String get newsDetail_breakingBadge => 'URGENT';

  @override
  String get newsDetail_removeFromFavoritesTooltip => 'Retirer des éléments enregistrés';

  @override
  String get newsDetail_addToFavoritesTooltip => 'Enregistrer';

  @override
  String get newsDetail_bodyFallback => 'Aucun texte supplémentaire n’est disponible pour cette News.';

  @override
  String get newsDetail_footerMoreContext => 'Plus de contexte et de sources seront ajoutés prochainement.';

  @override
  String get newsFeed_title => 'News';

  @override
  String get newsFeed_scopeWorld => 'Monde';

  @override
  String get newsFeed_scopeCountry => 'Pays';

  @override
  String get newsFeed_scopeCity => 'Ville';

  @override
  String newsFeed_scopeLabel(Object scope) {
    return 'Périmètre : $scope';
  }

  @override
  String get newsFeed_scopeGlobalDescription => 'Affichage des News mondiales.';

  @override
  String get newsFeed_scopeCountryDescription => 'Affichage des News pour ce pays.';

  @override
  String get newsFeed_scopeCityDescription => 'Affichage des News pour cette ville.';

  @override
  String get newsFeed_emptyTitle => 'Aucune News disponible pour cette zone.';

  @override
  String get newsFeed_emptySubtitle => 'Tirez pour actualiser ou réessayez plus tard.';

  @override
  String newsFeed_itemsFound(int count) {
    return '$count élément(s) News trouvé(s)';
  }

  @override
  String get newsFeed_loadingMoreHint => 'Faites défiler pour charger plus de News…';

  @override
  String get newsFeed_errorTitle => 'Impossible de charger les News';

  @override
  String get newsFeed_errorGeneric => 'Une erreur inattendue est survenue lors du chargement des News.';

  @override
  String get newsFeed_retryButton => 'Réessayer';

  @override
  String get newsCard_headerTitle => 'News';

  @override
  String get newsFeed_errorUnauthorized => 'La configuration de News n’est pas valide (clé API).';

  @override
  String get newsFeed_errorRateLimited => 'Trop de requêtes. Veuillez réessayer dans un instant.';

  @override
  String get newsFeed_errorServerUnavailable => 'Le service News est temporairement indisponible. Veuillez réessayer plus tard.';

  @override
  String get newsFeed_errorTimeout => 'La requête prend trop de temps. Veuillez réessayer.';

  @override
  String get newsFeed_errorNetwork => 'Aucune connexion. Vérifiez votre connexion Internet et réessayez.';

  @override
  String get newsFeed_moreTooltip => 'Plus';

  @override
  String get newsFeed_actionCopyTitle => 'Copier le titre';

  @override
  String get newsFeed_actionRefreshFeed => 'Actualiser le fil';

  @override
  String get newsFeed_copiedTitleToast => 'Titre copié';

  @override
  String get newsFeed_languageTooltip => 'Langue des News';

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
  String get newsFeed_languageLimitedHint => 'Sources limitées dans cette langue. Essayez AUTO.';

  @override
  String get newsTopic_all => 'Tout';

  @override
  String get newsTopic_world => 'Monde';

  @override
  String get newsTopic_nation => 'National';

  @override
  String get newsTopic_business => 'Économie';

  @override
  String get newsTopic_technology => 'Technologie';

  @override
  String get newsTopic_science => 'Science';

  @override
  String get newsTopic_health => 'Santé';

  @override
  String get newsTopic_sports => 'Sports';

  @override
  String get newsTopic_entertainment => 'Divertissement';

  @override
  String get newsDetail_openSource => 'Ouvrir l’article source';

  @override
  String get newsDetail_openSourceUnavailable => 'Impossible d’ouvrir l’article source';

  @override
  String get socialFeedTitle => 'Voce';

  @override
  String get socialFeedCreatePostButton => 'Créer une Voce';

  @override
  String get commonCancelButton => 'Annuler';

  @override
  String get commonApplyButton => 'Appliquer';

  @override
  String get homeScopeChooseCountry => 'Choisir un pays';

  @override
  String get homeScopeCountrySearchHint => 'Rechercher un pays ou un code...';

  @override
  String get homeScopeChooseCity => 'Choisir une ville';

  @override
  String homeScopeCountryWithCode(String code) {
    return 'Pays : $code';
  }

  @override
  String get homeScopeCityFieldLabel => 'Ville';

  @override
  String get homeScopeCityExampleHint => 'Saisissez une ville, par ex. Merano';

  @override
  String get homeScopeCityRequiredError => 'Saisissez une ville.';

  @override
  String get homeScopeCityNotFoundError => 'Ville introuvable dans le pays sélectionné.';

  @override
  String get homeScopeCityVerificationError => 'Impossible de vérifier la ville. Réessayez.';

  @override
  String get homeScopeVerifyingButton => 'Vérification...';

  @override
  String get homeMapOpenButton => 'Ouvrir la carte';

  @override
  String get homeHeroHeadline => 'Façonnez l’avenir.\nEnsemble.';

  @override
  String get homeHeroPollsAction => 'Vote';

  @override
  String get homeHeroNewsAction => 'News';

  @override
  String get homeHeroCreateAction => 'Créer';

  @override
  String get homeHeroExploreAction => 'Explorer';

  @override
  String get homeAccountMenuLabel => 'Compte';

  @override
  String get homeThemeSystemMenuItem => 'Thème : système';

  @override
  String get homeThemeLightMenuItem => 'Thème : clair';

  @override
  String get homeThemeDarkMenuItem => 'Thème : sombre';

  @override
  String get profileAppLanguageTitle => 'Langue de l’application';

  @override
  String get profileAppLanguageSystem => 'Système';

  @override
  String get profileAppLanguageSystemDescription => 'Utilise la langue de votre appareil';

  @override
  String get profileAppLanguageItalian => 'Italien';

  @override
  String get profileAppLanguageEnglish => 'Anglais';

  @override
  String get homeNotificationsTooltip => 'Notifications';

  @override
  String get postCard_authorFallback => 'Auteur';

  @override
  String get postCard_globalLocation => 'Global';

  @override
  String get commonSaveButton => 'Enregistrer';

  @override
  String get commonDeleteButton => 'Supprimer';

  @override
  String get contentReport_menuAction => 'Signaler le contenu';

  @override
  String get contentReport_dialogTitle => 'Signaler le contenu';

  @override
  String get contentReport_authenticationRequired => 'Vous devez être connecté pour signaler un contenu';

  @override
  String get contentReport_submittedMessage => 'Signalement envoyé';

  @override
  String get contentReport_alreadySubmittedMessage => 'Vous avez déjà signalé ce contenu';

  @override
  String get contentReport_submitError => 'Impossible d’envoyer le signalement';

  @override
  String get contentReport_sendButton => 'Envoyer';

  @override
  String get contentReport_reasonSpam => 'Spam';

  @override
  String get contentReport_reasonHarassment => 'Harcèlement ou abus';

  @override
  String get contentReport_reasonHateSpeech => 'Discours haineux';

  @override
  String get contentReport_reasonMisinformation => 'Désinformation';

  @override
  String get contentReport_reasonViolence => 'Violence';

  @override
  String get contentReport_reasonOther => 'Autre';

  @override
  String get postDetail_title => 'Détails de la Voce';

  @override
  String get postDetail_favoriteUpdateError => 'Impossible de mettre à jour les éléments enregistrés';

  @override
  String get postDetail_shareMessage => 'Ouvrez Social Vote pour voir cette Voce.';

  @override
  String get postDetail_shareError => 'Impossible de partager la Voce';

  @override
  String get postDetail_editDialogTitle => 'Modifier la Voce';

  @override
  String get postDetail_editTitleFieldLabel => 'Titre';

  @override
  String get postDetail_editContentFieldLabel => 'Contenu';

  @override
  String get postDetail_editRequiredError => 'Le titre et le contenu sont obligatoires.';

  @override
  String get postDetail_updateSuccess => 'Voce mise à jour';

  @override
  String get postDetail_updateError => 'Impossible de mettre à jour la Voce';

  @override
  String get postDetail_deleteDialogTitle => 'Supprimer cette Voce ?';

  @override
  String get postDetail_deleteDialogMessage => 'Cette action est irréversible.';

  @override
  String get postDetail_deleteError => 'Impossible de supprimer la Voce';

  @override
  String get postDetail_editMenuItem => 'Modifier la Voce';

  @override
  String get postDetail_deleteMenuItem => 'Supprimer la Voce';

  @override
  String get postDetail_loadError => 'Une erreur est survenue lors du chargement de la Voce.';

  @override
  String get postDetail_notFound => 'Voce introuvable.';

  @override
  String get postDetail_errorTitle => 'Erreur';

  @override
  String get postDetail_authorFallback => 'Auteur';

  @override
  String get postDetail_shareAction => 'Partager';

  @override
  String get postDetail_saveAction => 'Enregistrer';

  @override
  String get postDetail_addToFavoritesTooltip => 'Enregistrer';

  @override
  String get postDetail_removeFromFavoritesTooltip => 'Retirer des éléments enregistrés';

  @override
  String get newsDetail_favoriteUpdateError => 'Impossible de mettre à jour les éléments enregistrés';

  @override
  String get newsDetail_shareMessage => 'Ouvrez Social Vote pour voir cette News.';

  @override
  String get newsDetail_shareError => 'Impossible de partager la News';

  @override
  String get newsDetail_shareTooltip => 'Partager';

  @override
  String get authLoginPageTitle => 'Se connecter';

  @override
  String get authLoginHeadline => 'Bon retour';

  @override
  String get authEmailLabel => 'E-mail';

  @override
  String get authPasswordLabel => 'Mot de passe';

  @override
  String get authRememberMeLabel => 'Se souvenir de moi';

  @override
  String get authForgotPasswordAction => 'Mot de passe oublié ?';

  @override
  String get authLoginButton => 'Se connecter';

  @override
  String get authRegisterPrompt => 'Vous n’avez pas de compte ?';

  @override
  String get authRegisterAction => 'S’inscrire';

  @override
  String get authRegisterPageTitle => 'S’inscrire';

  @override
  String get authRegisterHeadline => 'Créer un compte';

  @override
  String get authPersonalAccountOwnershipTitle => 'La connexion appartient toujours à une personne';

  @override
  String get authPersonalAccountOwnershipBody => 'Si vous représentez une organisation, créez votre compte personnel. Après connexion, vous pourrez demander une Organisation vérifiée et la gérer depuis le Workspace.';

  @override
  String get authOrganizationPathAction => 'Comment ça fonctionne pour les organisations';

  @override
  String get authDisplayNameLabel => 'Nom public';

  @override
  String get authUsernameLabel => 'Nom d’utilisateur';

  @override
  String get authCountryOfResidenceLabel => 'Pays de résidence';

  @override
  String get authCityOfResidenceLabel => 'Ville de résidence (facultatif)';

  @override
  String get authConfirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get authLegalConsentPrefix => 'Je confirme avoir au moins 18 ans. J’accepte les Conditions d’utilisation et confirme avoir lu la Politique de confidentialité.';

  @override
  String get authTermsOfServiceAction => 'les Conditions d’utilisation';

  @override
  String get authPrivacyPolicyAction => 'la Politique de confidentialité';

  @override
  String get authRegisterButton => 'S’inscrire';

  @override
  String get authLoginPrompt => 'Vous avez déjà un compte ?';

  @override
  String get authLoginAction => 'Se connecter';

  @override
  String get authForgotPasswordDialogTitle => 'Réinitialiser le mot de passe';

  @override
  String get authForgotPasswordDialogBody => 'Saisissez l’adresse e-mail liée à votre compte. Nous vous enverrons un lien pour choisir un nouveau mot de passe.';

  @override
  String get authForgotPasswordSendButton => 'Envoyer le lien';

  @override
  String get authPasswordResetEmailSent => 'E-mail de réinitialisation envoyé. Consultez votre boîte de réception.';

  @override
  String get authResetPasswordPageTitle => 'Réinitialiser le mot de passe';

  @override
  String get authResetPasswordHeadline => 'Choisissez un nouveau mot de passe';

  @override
  String get authNewPasswordLabel => 'Nouveau mot de passe';

  @override
  String get authConfirmNewPasswordLabel => 'Confirmer le nouveau mot de passe';

  @override
  String get authUpdatePasswordButton => 'Mettre à jour le mot de passe';

  @override
  String get authPasswordUpdated => 'Mot de passe mis à jour avec succès.';

  @override
  String get authEmailConfirmationTitle => 'Consultez votre e-mail';

  @override
  String get authEmailConfirmationIntro => 'Nous avons envoyé un lien de confirmation à :';

  @override
  String get authEmailConfirmationInstructions => 'Ouvrez le lien dans le message pour vérifier votre adresse. Après confirmation, revenez dans l’application et connectez-vous.';

  @override
  String get authBackToLoginButton => 'Retour à la connexion';

  @override
  String get authUseAnotherEmailButton => 'Utiliser une autre adresse e-mail';

  @override
  String get authEmailRequiredError => 'Saisissez votre e-mail.';

  @override
  String get authEmailInvalidError => 'Saisissez une adresse e-mail valide.';

  @override
  String get authPasswordRequiredError => 'Saisissez votre mot de passe.';

  @override
  String get authPasswordTooShortError => 'Le mot de passe doit contenir au moins 8 caractères.';

  @override
  String get authDisplayNameRequiredError => 'Saisissez votre nom public.';

  @override
  String get authDisplayNameTooShortError => 'Le nom public est trop court.';

  @override
  String get authUsernameRequiredError => 'Saisissez un nom d’utilisateur.';

  @override
  String get authUsernameInvalidError => 'Utilisez de 3 à 20 caractères : lettres minuscules, chiffres et traits de soulignement.';

  @override
  String get authUsernameAlreadyTakenError => 'Ce nom d’utilisateur est déjà utilisé.';

  @override
  String get authCountryRequiredError => 'Sélectionnez votre pays de résidence.';

  @override
  String get authCityRequiredError => 'Saisissez votre ville de résidence.';

  @override
  String get authConfirmPasswordRequiredError => 'Confirmez votre mot de passe.';

  @override
  String get authPasswordsDoNotMatchError => 'Les mots de passe ne correspondent pas.';

  @override
  String get authLegalConsentRequiredError => 'Pour vous inscrire, confirmez que vous avez au moins 18 ans, acceptez les Conditions d’utilisation et confirmez avoir lu la Politique de confidentialité.';

  @override
  String get authForgotPasswordEmailRequiredError => 'Saisissez l’e-mail du compte que vous souhaitez récupérer.';

  @override
  String get authInvalidCredentialsError => 'L’e-mail ou le mot de passe n’est pas valide.';

  @override
  String get authEmailAlreadyRegisteredError => 'Cet e-mail est déjà enregistré.';

  @override
  String get authEmailNotConfirmedError => 'E-mail non confirmé. Consultez votre boîte de réception avant de vous connecter.';

  @override
  String get authTooManyAttemptsError => 'Trop de tentatives. Attendez quelques minutes et réessayez.';

  @override
  String get authNetworkError => 'Erreur réseau. Vérifiez votre connexion et réessayez.';

  @override
  String get authLoginGenericError => 'Échec de la connexion. Réessayez.';

  @override
  String get authRegisterGenericError => 'Échec de l’inscription. Réessayez.';

  @override
  String get authPasswordResetGenericError => 'Impossible d’envoyer le lien de réinitialisation. Réessayez.';

  @override
  String get authPasswordUpdateGenericError => 'Impossible de mettre à jour le mot de passe. Réessayez.';

  @override
  String get authShowPasswordTooltip => 'Afficher le mot de passe';

  @override
  String get authHidePasswordTooltip => 'Masquer le mot de passe';

  @override
  String get authTermsPageTitle => 'Conditions d’utilisation';

  @override
  String get authPrivacyPageTitle => 'Politique de confidentialité';

  @override
  String get authCloseButton => 'Fermer';

  @override
  String get pollDetail_favoriteUpdateError => 'Impossible de mettre à jour les éléments enregistrés';

  @override
  String get pollDetail_shareMessage => 'Ouvrez Social Vote pour voir et voter dans ce Vote.';

  @override
  String get pollDetail_shareError => 'Impossible de partager le Vote';

  @override
  String get pollDetail_editPermissionError => 'Vous ne pouvez modifier que vos propres Vote sans votes enregistrés';

  @override
  String get pollDetail_editSuccessMessage => 'Vote mis à jour';

  @override
  String get pollDetail_editMenuItem => 'Modifier le Vote';

  @override
  String get pollDetail_editSavingMenuItem => 'Enregistrement...';

  @override
  String get pollDetail_deletePermissionError => 'Vous ne pouvez supprimer que vos propres Vote';

  @override
  String get pollDetail_deleteError => 'Impossible de supprimer le Vote';

  @override
  String get pollDetail_deleteDialogTitle => 'Supprimer le Vote';

  @override
  String pollDetail_deleteDialogMessage(String title) {
    return 'Voulez-vous vraiment supprimer « $title » ? Cette action est irréversible.';
  }

  @override
  String get pollDetail_deleteMenuItem => 'Supprimer le Vote';

  @override
  String get pollDetail_deleteDeletingMenuItem => 'Suppression...';

  @override
  String get pollDetail_publicVotesAvailableTitle => 'Votes publics disponibles';

  @override
  String get pollDetail_publicVotesAvailableMessage => 'Ce Vote permet de voir qui a voté pour chaque option.';

  @override
  String get pollDetail_publicVotesAction => 'Voir les votes publics';

  @override
  String get pollDetail_retryButton => 'Réessayer';

  @override
  String get pollDetail_voteErrorNoOption => 'Sélectionnez au moins une option';

  @override
  String get pollDetail_voteErrorAuthenticationRequired => 'Vous devez être connecté pour voter';

  @override
  String get pollDetail_voteErrorClosed => 'Ce Vote est fermé';

  @override
  String get pollDetail_voteErrorAlreadyVoted => 'Vous avez déjà voté dans ce Vote';

  @override
  String get pollDetail_voteErrorGeneric => 'Impossible d’envoyer le vote';

  @override
  String get pollDetail_publicVotesSheetTitle => 'Votes publics';

  @override
  String get pollDetail_publicVotesSheetDescription => 'Vous pouvez voir ici qui a voté pour chaque option de ce Vote.';

  @override
  String get pollDetail_publicVotesSearchHint => 'Rechercher des utilisateurs';

  @override
  String get pollDetail_publicVotesLoadError => 'Impossible de charger les votes publics';

  @override
  String get pollDetail_publicVotesEmpty => 'Aucun vote public disponible';

  @override
  String get pollDetail_publicVotesSearchEmpty => 'Aucun utilisateur trouvé pour cette recherche';

  @override
  String pollDetail_publicVotesResultsCount(int count) {
    return '$count résultats chargés';
  }

  @override
  String get pollDetail_publicVotesLoadMore => 'Charger plus';

  @override
  String get pollDetail_publicVotesUserFallback => 'Utilisateur';

  @override
  String get pollDetail_editDialogTitle => 'Modifier le Vote';

  @override
  String get pollDetail_editTitleFieldLabel => 'Titre';

  @override
  String get pollDetail_editTitleRequired => 'Le titre est obligatoire';

  @override
  String get pollDetail_editDescriptionFieldLabel => 'Description';

  @override
  String get pollDetail_editError => 'Impossible de mettre à jour le Vote';

  @override
  String get pollDetail_loadError => 'Impossible de charger le Vote';

  @override
  String get pollDetail_notFound => 'Vote introuvable';

  @override
  String get profileEditPageTitle => 'Modifier le profil';

  @override
  String get profileLoginRequiredMessage => 'Vous devez être connecté pour modifier votre profil.';

  @override
  String get profileAvatarUploading => 'Téléversement...';

  @override
  String get profileUploadAvatarButton => 'Téléverser un avatar';

  @override
  String get profileDisplayNameLabel => 'Nom affiché';

  @override
  String get profileDisplayNameRequiredError => 'Le nom affiché est obligatoire.';

  @override
  String get profileUsernameHint => 'ex. mario_roma';

  @override
  String get profileUsernameHelper => '3 à 20 caractères : lettres minuscules, chiffres et traits de soulignement';

  @override
  String get profileAvatarUrlLabel => 'URL de l’avatar';

  @override
  String get profileBioLabel => 'Bio';

  @override
  String get profileClearCountryButton => 'Effacer le pays';

  @override
  String get profileCityResidenceHelper => 'La ville de résidence est vérifiée par rapport au pays sélectionné avant l’enregistrement.';

  @override
  String get profileCityNotFoundError => 'Ville introuvable dans le pays sélectionné.';

  @override
  String get profileCityVerificationError => 'Impossible de vérifier la ville pour le moment.';

  @override
  String get profileAvatarUploadError => 'Impossible de téléverser l’avatar.';

  @override
  String get profileAccountSectionTitle => 'Compte';

  @override
  String get profileAccountEmailHelper => 'L’adresse e-mail du compte ne peut pas être modifiée depuis cet écran.';

  @override
  String get profileChangePasswordAction => 'Changer le mot de passe';

  @override
  String get profileChangePasswordDescription => 'Définir un nouveau mot de passe pour ce compte.';

  @override
  String get notificationsPageTitle => 'Notifications';

  @override
  String get notificationsMarkAllReadAction => 'Tout marquer comme lu';

  @override
  String get notificationsNoTargetMessage => 'Cette notification n’a aucune destination disponible.';

  @override
  String get notificationsTargetUnavailableMessage => 'Le contenu lié à cette notification est indisponible.';

  @override
  String get notificationsLoadError => 'Impossible de charger les notifications.';

  @override
  String get notificationsRetryButton => 'Réessayer';

  @override
  String get notificationsEmptyMessage => 'Aucune notification disponible.';

  @override
  String get notificationsCommentReplyTitle => 'Nouvelle réponse à votre commentaire';

  @override
  String get notificationsMentionTitle => 'Vous avez été mentionné';

  @override
  String get notificationsPollResultTitle => 'Mise à jour du Vote';

  @override
  String notificationsCommentReplySubtitle(String actor, String target) {
    return 'L’utilisateur $actor a répondu dans $target';
  }

  @override
  String notificationsMentionSubtitle(String actor, String target) {
    return 'L’utilisateur $actor vous a mentionné dans $target';
  }

  @override
  String notificationsPollResultSubtitle(String target) {
    return 'Un nouveau résultat est disponible dans $target';
  }

  @override
  String get notificationsTargetPost => 'une Voce';

  @override
  String get notificationsTargetNews => 'un article News';

  @override
  String get notificationsTargetPoll => 'un Vote';

  @override
  String get notificationsTargetVideo => 'une vidéo';

  @override
  String get notificationsTargetContent => 'un contenu';

  @override
  String get notificationsUserFallback => 'utilisateur';

  @override
  String get profileDeleteAccountAction => 'Supprimer le compte';

  @override
  String get profileDeleteAccountDescription => 'Supprimer définitivement le compte et l’accès';

  @override
  String get profileDeleteAccountDialogTitle => 'Supprimer le compte';

  @override
  String get profileDeleteAccountDialogMessage => 'Cette action est définitive. Le compte ne pourra pas être récupéré. Saisissez DELETE pour confirmer.';

  @override
  String get profileDeleteAccountConfirmationLabel => 'Confirmation de suppression';

  @override
  String get profileDeleteAccountConfirmationHint => 'Saisissez DELETE';

  @override
  String get profileDeleteAccountConfirmationError => 'Saisissez DELETE pour continuer.';

  @override
  String get profileDeleteAccountCancelButton => 'Annuler';

  @override
  String get profileDeleteAccountConfirmButton => 'Supprimer définitivement';

  @override
  String get profileDeleteAccountFailureMessage => 'Impossible de supprimer le compte. Réessayez.';

  @override
  String get identityActorTypePerson => 'Personne';

  @override
  String get identityActorTypePublicOfficial => 'Responsable public';

  @override
  String get identityActorTypePublicInstitution => 'Institution publique';

  @override
  String get identityActorTypeVerifiedOrganization => 'Organisation vérifiée';

  @override
  String get identityVerificationNotVerified => 'Non vérifié';

  @override
  String get identityVerificationLevel1 => 'Identité vérifiée';

  @override
  String get identityVerificationLevel2 => 'Identité vérifiée avancée';

  @override
  String get identityBadgeLevel1 => 'Identité vérifiée';

  @override
  String get identityBadgeLevel2 => 'Identité vérifiée avancée';

  @override
  String get identityBadgePublicOfficial => 'Responsable public';

  @override
  String get identityBadgePublicInstitution => 'Institution publique';

  @override
  String get identityBadgeVerifiedOrganization => 'Organisation vérifiée';

  @override
  String get identityOrganizationNameLabel => 'Nom de l’organisation';

  @override
  String get identityOrganizationNameRequired => 'Saisissez le nom de l’organisation.';

  @override
  String get identityInstitutionLevelMunicipality => 'Municipal';

  @override
  String get identityInstitutionLevelProvince => 'Provincial';

  @override
  String get identityInstitutionLevelRegion => 'Régional';

  @override
  String get identityInstitutionLevelMinistry => 'Ministère';

  @override
  String get identityInstitutionLevelGovernment => 'Gouvernement';

  @override
  String get identityInstitutionLevelPublicAgency => 'Agence publique';

  @override
  String get identityInstitutionLevelOtherPublicBody => 'Autre organisme public';

  @override
  String get verificationRequestPersonLevel1 => 'Vérification de personne — Niveau 1';

  @override
  String get verificationRequestPersonLevel2 => 'Vérification de personne — Niveau 2';

  @override
  String get verificationRequestPublicOfficial => 'Vérification de responsable public';

  @override
  String get verificationRequestPublicInstitution => 'Vérification d’institution publique';

  @override
  String get verificationRequestVerifiedOrganization => 'Vérification d’organisation';

  @override
  String get verificationCenterTitle => 'Vérification et type de compte';

  @override
  String get verificationCurrentAccountSection => 'Compte actuel';

  @override
  String verificationAccountTypeValue(String accountType) {
    return 'Type de compte : $accountType';
  }

  @override
  String verificationLevelValue(String level) {
    return 'Niveau de vérification : $level';
  }

  @override
  String verificationOfficialTitleValue(String title) {
    return 'Fonction officielle : $title';
  }

  @override
  String verificationInstitutionNameValue(String name) {
    return 'Institution : $name';
  }

  @override
  String verificationOrganizationNameValue(String name) {
    return 'Organisation : $name';
  }

  @override
  String verificationInstitutionLevelValue(String level) {
    return 'Niveau de l’institution : $level';
  }

  @override
  String get verificationActiveRequestSection => 'Demande active';

  @override
  String get verificationProfileUnchangedUntilApproval => 'Votre profil actuel ne changera pas tant que la demande n’aura pas été approuvée.';

  @override
  String get verificationCancelPendingAction => 'Annuler la demande en attente';

  @override
  String get verificationPendingBlocksNewRequests => 'Vous ne pouvez pas envoyer une nouvelle demande tant qu’une autre est en attente.';

  @override
  String get verificationNoActiveRequestSection => 'Aucune demande active';

  @override
  String get verificationNoActiveRequestDescription => 'Vous n’avez actuellement aucune demande en cours d’examen.';

  @override
  String get verificationLastRejectedSection => 'Dernière demande rejetée';

  @override
  String get verificationLastRejectedDescription => 'Votre dernière demande a été rejetée.';

  @override
  String get verificationRejectedCanResubmit => 'Votre profil actuel n’a pas changé. Vous pouvez corriger les informations et envoyer une nouvelle demande.';

  @override
  String get verificationAvailableRequestsSection => 'Demandes disponibles';

  @override
  String get verificationRequestLevel1Title => 'Demander la vérification de personne — Niveau 1';

  @override
  String get verificationRequestLevel1Subtitle => 'Vérification de base de l’identité personnelle';

  @override
  String get verificationRequestLevel2Title => 'Demander la vérification de personne — Niveau 2';

  @override
  String get verificationRequestLevel2Subtitle => 'Vérification avancée de l’identité personnelle';

  @override
  String get verificationRequestPublicOfficialTitle => 'Demander un compte Responsable public';

  @override
  String get verificationRequestPublicOfficialSubtitle => 'Nécessite une fonction officielle et une vérification';

  @override
  String get verificationRequestPublicInstitutionTitle => 'Demander un compte Institution publique';

  @override
  String get verificationRequestPublicInstitutionSubtitle => 'Nécessite le nom de l’institution, son niveau et une vérification';

  @override
  String get verificationRequestOrganizationTitle => 'Demander un compte Organisation vérifiée';

  @override
  String get verificationRequestOrganizationSubtitle => 'Nécessite les informations de l’organisation, le rôle du représentant et une validation Admin';

  @override
  String get verificationNoSelfServiceUpgrade => 'Aucune option de vérification n’est disponible pour le statut actuel de votre compte.';

  @override
  String get verificationRequestSubmitSuccess => 'Demande envoyée avec succès.';

  @override
  String get verificationRequestSubmitFailure => 'Impossible d’envoyer la demande.';

  @override
  String get verificationOfficialTitleDialogTitle => 'Vérification de responsable public';

  @override
  String get verificationOfficialTitleLabel => 'Fonction officielle';

  @override
  String get verificationOfficialTitleHint => 'ex. Maire, Conseiller, Ministre';

  @override
  String get verificationInstitutionDialogTitle => 'Vérification d’institution publique';

  @override
  String get verificationInstitutionNameLabel => 'Nom de l’institution';

  @override
  String get verificationInstitutionNameHint => 'ex. Ville de Rome';

  @override
  String get verificationInstitutionLevelLabel => 'Niveau de l’institution';

  @override
  String get verificationOrganizationDialogTitle => 'Vérification d’organisation';

  @override
  String get verificationOrganizationNameHint => 'ex. Association Environnement Italie';

  @override
  String get verificationSubmitRequestAction => 'Envoyer la demande';

  @override
  String get verificationCancelDialogTitle => 'Annuler la demande';

  @override
  String get verificationCancelDialogBody => 'Voulez-vous vraiment annuler la demande de vérification en attente ?';

  @override
  String get verificationCancelSuccess => 'Demande annulée.';

  @override
  String get verificationCancelFailure => 'Impossible d’annuler la demande.';

  @override
  String get verificationStatusPendingSuffix => 'demande en cours d’examen';

  @override
  String get verificationStatusRejectedSuffix => 'dernière demande rejetée';

  @override
  String get verificationReviewPageTitle => 'Examen des vérifications';

  @override
  String get verificationReviewLoginRequired => 'Vous devez vous connecter pour examiner les demandes de vérification.';

  @override
  String verificationReviewPendingCount(int count) {
    return 'Demandes en attente : $count';
  }

  @override
  String get verificationReviewNoPendingRequests => 'Aucune demande de vérification n’est en attente.';

  @override
  String get verificationReviewUserIdLabel => 'ID utilisateur';

  @override
  String get verificationReviewSubmittedLabel => 'Envoyée';

  @override
  String get verificationReviewOfficialTitleLabel => 'Fonction officielle';

  @override
  String get verificationReviewInstitutionLabel => 'Institution';

  @override
  String get verificationReviewOrganizationLabel => 'Organisation';

  @override
  String get verificationReviewNoteLabel => 'Note d’examen';

  @override
  String get verificationReviewRejectAction => 'Rejeter';

  @override
  String get verificationReviewApproveAction => 'Approuver';

  @override
  String get verificationReviewApproveDialogTitle => 'Approuver la demande';

  @override
  String get verificationReviewRejectDialogTitle => 'Rejeter la demande';

  @override
  String get verificationReviewApproveConfirmation => 'Confirmer l’approbation de cette demande ?';

  @override
  String get verificationReviewRejectConfirmation => 'Confirmer le rejet de cette demande ?';

  @override
  String get verificationReviewOptionalNoteLabel => 'Note d’examen facultative';

  @override
  String get verificationReviewRequiredNoteLabel => 'Motif du rejet';

  @override
  String get verificationReviewOptionalHelper => 'Facultatif';

  @override
  String get verificationReviewRequiredHelper => 'Obligatoire en cas de rejet';

  @override
  String get verificationReviewRequiredNoteError => 'Saisissez le motif du rejet.';

  @override
  String get verificationReviewApprovedSuccess => 'Demande approuvée.';

  @override
  String get verificationReviewRejectedSuccess => 'Demande rejetée.';

  @override
  String get verificationReviewOperationFailure => 'Échec de l’opération.';

  @override
  String get adminCenterTitle => 'Centre Admin';

  @override
  String get adminCenterDashboardNavigation => 'Tableau de bord';

  @override
  String get adminCenterUsersNavigation => 'Utilisateurs';

  @override
  String get adminCenterVerificationNavigation => 'Vérification';

  @override
  String get adminCenterReportsNavigation => 'Signalements';

  @override
  String get adminCenterAuditNavigation => 'Audit';

  @override
  String get adminCenterAccountDetailsTitle => 'Détails du compte';

  @override
  String get adminCenterTryAgainAction => 'Réessayer';

  @override
  String get adminCenterRetryAction => 'Réessayer';

  @override
  String get adminCenterClearAction => 'Effacer';

  @override
  String get adminCenterApplyFiltersAction => 'Appliquer les filtres';

  @override
  String get adminCenterAllDates => 'Toutes les dates';

  @override
  String get adminCenterAuditDateFilterHelp => 'Filtrer l’audit par date';

  @override
  String get adminCenterActorUserIdLabel => 'ID utilisateur de l’acteur';

  @override
  String get adminCenterActionLabel => 'Action';

  @override
  String get adminCenterAuditActionHint => 'resolve_escalated_report';

  @override
  String get adminCenterTargetIdLabel => 'ID cible';

  @override
  String get adminCenterOutcomeLabel => 'Résultat';

  @override
  String get adminCenterAllOutcomes => 'Tous les résultats';

  @override
  String get adminCenterOutcomeSuccess => 'Succès';

  @override
  String get adminCenterOutcomeFailure => 'Échec';

  @override
  String get adminCenterOutcomeDenied => 'Refusé';

  @override
  String get adminCenterOutcomeNoChange => 'Aucun changement';

  @override
  String get adminCenterOutcomeUnknown => 'Inconnu';

  @override
  String get adminCenterAuditUnavailableTitle => 'Audit indisponible';

  @override
  String get adminCenterAuditUnavailableMessage => 'Vérifiez votre connexion et vos autorisations, puis réessayez.';

  @override
  String get adminCenterNoAuditEntriesTitle => 'Aucune entrée d’audit';

  @override
  String get adminCenterNoAuditEntriesMessage => 'Aucune entrée ne correspond aux filtres sélectionnés.';

  @override
  String get adminCenterAuditIdLabel => 'ID audit';

  @override
  String get adminCenterActorLabel => 'Acteur';

  @override
  String get adminCenterReasonLabel => 'Motif';

  @override
  String get adminCenterTimestampLabel => 'Horodatage';

  @override
  String get adminCenterErrorLabel => 'Erreur';

  @override
  String get adminCenterRecordedValuesTitle => 'Valeurs enregistrées';

  @override
  String get adminCenterPreviousValueLabel => 'Précédent';

  @override
  String get adminCenterNewValueLabel => 'Nouveau';

  @override
  String get adminCenterContentTypeLabel => 'Type de contenu';

  @override
  String get adminCenterAllContent => 'Tous les contenus';

  @override
  String get adminCenterPolls => 'Vote';

  @override
  String get adminCenterPosts => 'Voce';

  @override
  String get adminCenterNews => 'News';

  @override
  String get adminCenterAwaitingAdminDecision => 'En attente d’une décision Admin';

  @override
  String get adminCenterStatusLabel => 'Statut';

  @override
  String get adminCenterAllStatuses => 'Tous les statuts';

  @override
  String get adminCenterStatusOpen => 'Ouvert';

  @override
  String get adminCenterStatusInReview => 'En cours d’examen';

  @override
  String get adminCenterStatusResolved => 'Résolu';

  @override
  String get adminCenterStatusDismissed => 'Classé';

  @override
  String get adminCenterAdminQueueUnavailableTitle => 'File d’escalade Admin indisponible';

  @override
  String get adminCenterReportsUnavailableTitle => 'Signalements indisponibles';

  @override
  String get adminCenterConnectionTryAgainMessage => 'Vérifiez votre connexion et réessayez.';

  @override
  String get adminCenterNoAdminReportsTitle => 'Aucun signalement en attente de décision Admin';

  @override
  String get adminCenterNoReportsTitle => 'Aucun signalement';

  @override
  String get adminCenterNoAdminReportsMessage => 'Aucun signalement escaladé ne nécessite l’examen d’un administrateur.';

  @override
  String get adminCenterNoReportsMessage => 'Aucun signalement ne correspond aux filtres sélectionnés.';

  @override
  String get adminCenterSearchUsersHint => 'Rechercher par nom, nom d’utilisateur, e-mail ou ID';

  @override
  String get adminCenterClearSearchTooltip => 'Effacer la recherche';

  @override
  String get adminCenterUsersUnavailableTitle => 'Utilisateurs indisponibles';

  @override
  String get adminCenterNoUsersFoundTitle => 'Aucun utilisateur trouvé';

  @override
  String get adminCenterNoUsersTitle => 'Aucun utilisateur';

  @override
  String get adminCenterNoUsersFoundMessage => 'Essayez un autre nom, nom d’utilisateur, e-mail ou ID.';

  @override
  String get adminCenterNoUsersMessage => 'Aucun compte à afficher.';

  @override
  String get adminCenterAccountUnavailableTitle => 'Compte indisponible';

  @override
  String get adminCenterBackToUsersAction => 'Retour aux utilisateurs';

  @override
  String get adminCenterPublicIdentitySection => 'Identité publique';

  @override
  String get adminCenterDisplayNameLabel => 'Nom affiché';

  @override
  String get adminCenterNotProvided => 'Non fourni';

  @override
  String get adminCenterUsernameLabel => 'Nom d’utilisateur';

  @override
  String get adminCenterUserIdLabel => 'ID utilisateur';

  @override
  String get adminCenterIdentityTypeLabel => 'Type d’identité';

  @override
  String get adminCenterAccountSection => 'Compte';

  @override
  String get adminCenterTechnicalRoleLabel => 'Rôle technique';

  @override
  String get adminCenterRoleMirrorLabel => 'Miroir du rôle de profil';

  @override
  String get adminCenterRoleSynchronizationLabel => 'Synchronisation des rôles';

  @override
  String get adminCenterSynchronized => 'Synchronisé';

  @override
  String get adminCenterNotSynchronized => 'Non synchronisé';

  @override
  String get adminCenterRoleNotSynchronized => 'Rôle non synchronisé';

  @override
  String get adminCenterAccountStatusLabel => 'Statut du compte';

  @override
  String get adminCenterSuspendedUntilLabel => 'Suspendu jusqu’au';

  @override
  String get adminCenterAccountManagementSection => 'Gestion du compte';

  @override
  String get adminCenterDangerZoneSection => 'Zone dangereuse';

  @override
  String get adminCenterRoleManagementSection => 'Gestion des rôles';

  @override
  String get adminCenterVerificationLevelLabel => 'Niveau de vérification';

  @override
  String get adminCenterVerificationStatusLabel => 'Statut de vérification';

  @override
  String get adminCenterAccessInformationSection => 'Informations d’accès';

  @override
  String get adminCenterEmailLabel => 'E-mail';

  @override
  String get adminCenterNotAvailable => 'Indisponible';

  @override
  String get adminCenterEmailConfirmationLabel => 'Confirmation de l’e-mail';

  @override
  String get adminCenterNotConfirmed => 'Non confirmé';

  @override
  String get adminCenterRegisteredLabel => 'Inscrit';

  @override
  String get adminCenterLastAccessLabel => 'Dernier accès';

  @override
  String get adminCenterLoadingDashboardTitle => 'Chargement du tableau de bord';

  @override
  String get adminCenterLoadingDashboardMessage => 'Récupération des derniers indicateurs.';

  @override
  String get adminCenterDashboardUnavailableTitle => 'Tableau de bord indisponible';

  @override
  String get adminCenterIndicatorsUnavailableMessage => 'Les indicateurs n’ont pas pu être chargés.';

  @override
  String get adminCenterVerificationPendingIndicator => 'Vérifications en attente';

  @override
  String get adminCenterOpenReportsIndicator => 'Signalements ouverts';

  @override
  String get adminCenterSuspendedAccountsIndicator => 'Comptes suspendus';

  @override
  String get adminCenterStaffIndicator => 'Équipe';

  @override
  String get adminCenterNoPendingWorkTitle => 'Aucun travail en attente';

  @override
  String get adminCenterNoPendingWorkMessage => 'Les vérifications, signalements et comptes suspendus sont à jour.';

  @override
  String get adminCenterCouldNotUpdateUsers => 'Impossible de mettre à jour la liste des utilisateurs.';

  @override
  String get adminCenterCouldNotUpdateReports => 'Impossible de mettre à jour la file des signalements.';

  @override
  String get adminCenterUnnamedUser => 'Utilisateur sans nom';

  @override
  String get adminCenterTemporarySuspensionTitle => 'Suspension temporaire';

  @override
  String get adminCenterReactivateDescription => 'Supprimer immédiatement la suspension et autoriser une nouvelle connexion.';

  @override
  String get adminCenterSuspendDescription => 'Bloquer l’accès pour une durée limitée et terminer toutes les sessions actives.';

  @override
  String get adminCenterSuspensionUnavailableDescription => 'La suspension nécessite un compte synchronisé qui n’est pas Admin.';

  @override
  String get adminCenterReactivateAccountAction => 'Réactiver le compte';

  @override
  String get adminCenterSuspendAccountAction => 'Suspendre le compte';

  @override
  String get adminCenterForceLogoutAction => 'Forcer la déconnexion';

  @override
  String get adminCenterSuspendedForceLogoutDescription => 'La suspension a déjà mis fin aux sessions actives. Réactivez le compte avant de tester une déconnexion séparée.';

  @override
  String get adminCenterForceLogoutDescription => 'Mettre fin à toutes les sessions actives sans suspendre le compte.';

  @override
  String get adminCenterForceLogoutUnavailableDescription => 'La déconnexion forcée nécessite un compte synchronisé qui n’est pas Admin.';

  @override
  String get adminCenterPermanentDeletionTitle => 'Suppression définitive du compte';

  @override
  String get adminCenterPermanentDeletionDescription => 'Supprimer les données d’authentification, mettre fin à toutes les sessions et anonymiser l’enregistrement public conservé.';

  @override
  String get adminCenterDeletionUnavailableDescription => 'La suppression nécessite un compte synchronisé qui n’est pas Admin.';

  @override
  String get adminCenterDeleteAccountPermanentlyAction => 'Supprimer définitivement le compte';

  @override
  String get adminCenterDurationOneHour => '1 heure';

  @override
  String get adminCenterDurationOneDay => '24 heures';

  @override
  String get adminCenterDurationSevenDays => '7 jours';

  @override
  String get adminCenterDurationThirtyDays => '30 jours';

  @override
  String get adminCenterSuspendImmediateEffect => 'Le compte perdra immédiatement l’accès et toutes les sessions actives seront terminées.';

  @override
  String get adminCenterDurationLabel => 'Durée';

  @override
  String get adminCenterSuspendReasonHint => 'Expliquez pourquoi ce compte doit être suspendu';

  @override
  String get adminCenterReactivateReasonHint => 'Expliquez pourquoi ce compte peut être réactivé';

  @override
  String get adminCenterReactivateConfirmation => 'Je confirme que ce compte peut retrouver l’accès.';

  @override
  String get adminCenterReactivateFailure => 'Le compte n’a pas pu être réactivé. Vérifiez son rôle et son statut, puis réessayez.';

  @override
  String get adminCenterReactivateSuccess => 'Compte réactivé. Une nouvelle connexion est maintenant autorisée.';

  @override
  String get adminCenterForceLogoutFullDescription => 'Mettre fin à toutes les sessions actives de ce compte. Le compte reste actif et peut se reconnecter.';

  @override
  String get adminCenterForceLogoutReasonHint => 'Expliquez pourquoi les sessions actives doivent être terminées';

  @override
  String get adminCenterForceLogoutConfirmation => 'Je confirme la fin immédiate de toutes les sessions actives de ce compte.';

  @override
  String get adminCenterForceLogoutFailure => 'Le compte n’a pas pu être déconnecté. Vérifiez son rôle et son statut, puis réessayez.';

  @override
  String get adminCenterForceLogoutSuccess => 'Sessions actives terminées. Le compte peut se reconnecter.';

  @override
  String get adminCenterSuspendFailure => 'Le compte n’a pas pu être suspendu. Vérifiez son rôle et son statut, puis réessayez.';

  @override
  String get adminCenterDeleteReasonHint => 'Expliquez pourquoi ce compte doit être supprimé';

  @override
  String get adminCenterTypeDeleteLabel => 'Saisissez DELETE';

  @override
  String get adminCenterTypeAccountIdLabel => 'Saisissez l’ID complet du compte';

  @override
  String get adminCenterDeletePermanentlyAction => 'Supprimer définitivement';

  @override
  String get adminCenterDeleteIrreversibleWarning => 'Cette action est irréversible. Les données d’authentification et les sessions actives seront supprimées, l’avatar sera effacé et l’enregistrement public conservé sera anonymisé. Le journal d’audit sera conservé.';

  @override
  String get adminCenterDeleteFailure => 'Le compte n’a pas pu être supprimé. Vérifiez son rôle, son statut et les valeurs de confirmation, puis réessayez.';

  @override
  String get adminCenterDeleteSuccess => 'Compte supprimé définitivement et données personnelles anonymisées.';

  @override
  String get adminCenterChangeTechnicalRoleTitle => 'Modifier le rôle technique';

  @override
  String get adminCenterChangeRoleDescription => 'Vérifiez le rôle actuel et le rôle demandé avant de confirmer.';

  @override
  String get adminCenterChangeRoleUnavailableDescription => 'Les changements de rôle nécessitent un compte synchronisé et non supprimé.';

  @override
  String get adminCenterChangeRoleAction => 'Modifier le rôle';

  @override
  String get adminCenterChangePublicIdentityTitle => 'Modifier l’identité publique';

  @override
  String get adminCenterChangeIdentityDescription => 'Mettre à jour le type de compte public et le niveau de vérification.';

  @override
  String get adminCenterChangeIdentityUnavailableDescription => 'Les changements d’identité nécessitent un compte synchronisé qui n’est pas Admin.';

  @override
  String get adminCenterChangeIdentityAction => 'Modifier l’identité';

  @override
  String get adminCenterChoosePublicIdentityMessage => 'Choisissez le type de compte public et son état de vérification.';

  @override
  String get adminCenterPublicAccountTypeLabel => 'Type de compte public';

  @override
  String get adminCenterPersonVerificationHelper => 'Les niveaux 1 et 2 sont disponibles uniquement pour Persona.';

  @override
  String get adminCenterNonPersonVerificationHelper => 'Les comptes autres que Persona n’utilisent pas les niveaux 1 ou 2.';

  @override
  String get adminCenterBeforeLabel => 'Avant';

  @override
  String get adminCenterAfterLabel => 'Après';

  @override
  String get adminCenterIdentityReasonHint => 'Expliquez pourquoi l’identité publique doit changer';

  @override
  String get adminCenterIdentityConfirmation => 'Je confirme l’identité publique et le niveau de vérification indiqués ci-dessus.';

  @override
  String get adminCenterIdentityChangeFailure => 'L’identité publique n’a pas pu être modifiée. Vérifiez l’état du compte et réessayez.';

  @override
  String get adminCenterChooseTechnicalRoleMessage => 'Choisissez le nouveau rôle technique et indiquez pourquoi ce changement est nécessaire.';

  @override
  String get adminCenterNewTechnicalRoleLabel => 'Nouveau rôle technique';

  @override
  String get adminCenterSelectRole => 'Sélectionner un rôle';

  @override
  String get adminCenterRoleSessionWarning => 'Ce changement met fin à la session active du destinataire. Il devra se reconnecter avant de continuer à utiliser le compte.';

  @override
  String get adminCenterRoleReasonHint => 'Expliquez pourquoi le rôle technique doit changer';

  @override
  String get adminCenterRoleConfirmation => 'Je confirme le rôle indiqué ci-dessus et comprends que le destinataire devra se reconnecter.';

  @override
  String get adminCenterRoleChangeFailure => 'Le changement de rôle n’a pas pu être effectué. Vérifiez l’état du compte et réessayez.';

  @override
  String get adminCenterChangingRole => 'Modification du rôle';

  @override
  String get adminCenterConfirmRoleChange => 'Confirmer le changement de rôle';

  @override
  String get adminCenterRoleUser => 'Utilisateur';

  @override
  String get adminCenterRoleModerator => 'Modérateur';

  @override
  String get adminCenterRoleAdmin => 'Admin';

  @override
  String get adminCenterAccountStatusActive => 'Actif';

  @override
  String get adminCenterAccountStatusSuspended => 'Suspendu';

  @override
  String get adminCenterAccountStatusDeleted => 'Supprimé';

  @override
  String get adminCenterVerificationStatusNone => 'Aucun';

  @override
  String get adminCenterVerificationStatusPending => 'En attente';

  @override
  String get adminCenterVerificationStatusRejected => 'Rejeté';

  @override
  String get adminCenterVerificationNotVerified => 'Non vérifié';

  @override
  String get adminCenterVerificationLevel1 => 'Niveau 1';

  @override
  String get adminCenterVerificationLevel2 => 'Niveau 2';

  @override
  String get adminCenterReportSingular => 'signalement';

  @override
  String get adminCenterReportPlural => 'signalements';

  @override
  String get adminCenterUserSingular => 'utilisateur';

  @override
  String get adminCenterUserPlural => 'utilisateurs';

  @override
  String get adminCenterPoll => 'Vote';

  @override
  String get adminCenterPost => 'Voce';

  @override
  String get adminCenterUnknown => 'Inconnu';

  @override
  String get adminCenterContentHidden => 'Contenu masqué';

  @override
  String get adminCenterContentVisible => 'Contenu visible';

  @override
  String get adminCenterReportedByLabel => 'Signalé par';

  @override
  String get adminCenterContentOwnerLabel => 'Propriétaire du contenu';

  @override
  String get adminCenterReviewReportAction => 'Examiner le signalement';

  @override
  String get adminCenterAdminDecisionAction => 'Décision Admin';

  @override
  String get adminCenterRestoreContentAction => 'Restaurer le contenu';

  @override
  String get adminCenterHideContentAction => 'Masquer le contenu';

  @override
  String get adminCenterOpenProfileAction => 'Ouvrir le profil';

  @override
  String get adminCenterOpenContentAction => 'Ouvrir le contenu';

  @override
  String get adminCenterDecisionNoViolation => 'Aucune violation';

  @override
  String get adminCenterDecisionViolationConfirmed => 'Violation confirmée';

  @override
  String get adminCenterDecisionEscalateToAdmin => 'Escalader vers Admin';

  @override
  String get adminCenterResolutionNoAccountAction => 'Aucune action sur le compte';

  @override
  String get adminCenterResolutionAccountSuspended => 'Compte suspendu';

  @override
  String get adminCenterResolutionLogoutForced => 'Déconnexion forcée';

  @override
  String get adminCenterResolutionAccountDeleted => 'Compte supprimé';

  @override
  String get adminCenterReviewerLabel => 'Examinateur';

  @override
  String get adminCenterDecisionDescriptionNoViolation => 'Classe le signalement car le contenu n’enfreint pas les règles actuelles.';

  @override
  String get adminCenterDecisionDescriptionViolation => 'Confirme une violation et maintient le dossier en examen pour l’action sur le contenu gérée dans AC8.5.';

  @override
  String get adminCenterDecisionDescriptionEscalation => 'Escalade le dossier pour un examen au niveau du compte par un administrateur.';

  @override
  String get adminCenterChooseModerationOutcome => 'Choisissez le résultat de modération pour ce signalement.';

  @override
  String get adminCenterDecisionAlreadyRecordedFailure => 'La décision n’a pas pu être enregistrée. Le signalement a peut-être déjà été examiné. Actualisez la file et réessayez.';

  @override
  String get adminCenterDecisionLabel => 'Décision';

  @override
  String get adminCenterReportReasonLabel => 'Motif du signalement';

  @override
  String get adminCenterReviewNoteLabel => 'Note d’examen';

  @override
  String get adminCenterReviewNoteHint => 'Expliquez les éléments de preuve et la décision de modération';

  @override
  String get adminCenterRecordingDecision => 'Enregistrement de la décision';

  @override
  String get adminCenterConfirmDecision => 'Confirmer la décision';

  @override
  String get adminCenterAdministratorDecisionTitle => 'Décision de l’administrateur';

  @override
  String get adminCenterResolutionDescriptionNoAction => 'Clôture le signalement escaladé sans modifier le compte.';

  @override
  String get adminCenterResolutionDescriptionSuspended => 'Clôture le signalement après qu’une suspension de compte réussie a déjà été enregistrée dans le journal d’audit.';

  @override
  String get adminCenterResolutionDescriptionLogout => 'Clôture le signalement après qu’une déconnexion forcée réussie a déjà été enregistrée dans le journal d’audit.';

  @override
  String get adminCenterResolutionDescriptionDeleted => 'Clôture le signalement après qu’une suppression de compte réussie a déjà été enregistrée dans le journal d’audit.';

  @override
  String get adminCenterChooseFinalOutcome => 'Choisissez le résultat final de l’administrateur pour cette escalade.';

  @override
  String get adminCenterAdminResolutionFailure => 'La décision de l’administrateur n’a pas pu être enregistrée. Actualisez la file et réessayez.';

  @override
  String get adminCenterAdminResolutionRequiresAction => 'Effectuez d’abord l’action de compte correspondante, puis revenez à ce signalement et enregistrez la décision finale de l’administrateur.';

  @override
  String get adminCenterEscalationNoteLabel => 'Note d’escalade';

  @override
  String get adminCenterFinalOutcomeLabel => 'Résultat final';

  @override
  String get adminCenterAdministratorNoteLabel => 'Note de l’administrateur';

  @override
  String get adminCenterAdministratorNoteHint => 'Expliquez la décision finale au niveau du compte';

  @override
  String get adminCenterHideContentFailure => 'Le contenu n’a pas pu être masqué. Actualisez la file des signalements et réessayez.';

  @override
  String get adminCenterRestoreContentFailure => 'Le contenu n’a pas pu être restauré. Actualisez la file des signalements et réessayez.';

  @override
  String get adminCenterHideContentWarning => 'Cela retire le contenu signalé de l’accès public. L’action pourra ensuite être annulée depuis le filtre des signalements résolus.';

  @override
  String get adminCenterRestoreContentWarning => 'Cela rend à nouveau le contenu signalé accessible au public.';

  @override
  String get adminCenterActionReasonLabel => 'Motif de l’action';

  @override
  String get adminCenterHideContentReasonHint => 'Expliquez pourquoi le contenu doit être masqué';

  @override
  String get adminCenterRestoreContentReasonHint => 'Expliquez pourquoi le contenu peut être restauré';

  @override
  String get adminCenterHidingContent => 'Masquage du contenu';

  @override
  String get adminCenterRestoringContent => 'Restauration du contenu';

  @override
  String get adminCenterReportedProfileTitle => 'Profil signalé';

  @override
  String get adminCenterReportedProfileNotice => 'Ce contexte de profil provient de la file protégée des signalements. Les actions administratives sur le compte restent séparées.';

  @override
  String get adminCenterCouldNotRefreshIndicators => 'Impossible d’actualiser les indicateurs.';

  @override
  String get adminCenterCouldNotRefreshAccount => 'Impossible d’actualiser les détails du compte.';

  @override
  String get adminCenterReportAlreadyReviewed => 'Ce signalement a déjà été examiné ou n’est plus en attente.';

  @override
  String get adminCenterReportNotAwaitingAdmin => 'Ce signalement n’attend pas de décision d’administrateur.';

  @override
  String get adminCenterConfirmedViolationRequired => 'Une violation confirmée est requise avant de modifier la visibilité du contenu.';

  @override
  String get adminCenterContentHiddenSuccess => 'Le contenu signalé a été masqué.';

  @override
  String get adminCenterContentRestoredSuccess => 'Le contenu signalé a été restauré.';

  @override
  String get adminCenterMissingContentId => 'L’identifiant du contenu d’origine est manquant.';

  @override
  String get adminCenterUnsupportedTargetType => 'Ce signalement possède un type de cible non pris en charge.';

  @override
  String get adminCenterOriginalContentUnavailable => 'Le contenu d’origine n’est plus disponible.';

  @override
  String get adminCenterNoReportedProfile => 'Aucun profil signalé n’est associé à ce contenu.';

  @override
  String adminCenterRoleChangedSuccess(String previousRole, String newRole) {
    return 'Rôle technique modifié de $previousRole à $newRole. Le destinataire a été déconnecté et doit se reconnecter.';
  }

  @override
  String adminCenterIdentityChangedSuccess(String actorType, String verificationLevel) {
    return 'Identité publique modifiée en $actorType avec $verificationLevel.';
  }

  @override
  String adminCenterAccountSuspendedSuccess(String dateTime) {
    return 'Compte suspendu jusqu’au $dateTime. Le destinataire a été déconnecté.';
  }

  @override
  String adminCenterReportDecisionRecorded(String decision) {
    return 'Décision sur le signalement enregistrée : $decision.';
  }

  @override
  String adminCenterAdministratorDecisionRecorded(String decision) {
    return 'Décision de l’administrateur enregistrée : $decision.';
  }

  @override
  String adminCenterUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count utilisateurs',
      one: '$count utilisateur',
    );
    return '$_temp0';
  }

  @override
  String adminCenterReportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count signalements',
      one: '$count signalement',
    );
    return '$_temp0';
  }

  @override
  String adminCenterAccountValue(String account) {
    return 'Compte : $account';
  }

  @override
  String adminCenterSuspendedUntilValue(String dateTime) {
    return 'Suspendu jusqu’au : $dateTime';
  }

  @override
  String adminCenterSuspendConfirmation(String dateTime) {
    return 'Je confirme la suspension jusqu’au $dateTime et la fin immédiate des sessions actives.';
  }

  @override
  String adminCenterAccountIdValue(String accountId) {
    return 'ID du compte : $accountId';
  }

  @override
  String adminCenterCurrentRoleValue(String role) {
    return 'Actuel : $role';
  }

  @override
  String adminCenterTargetFallback(String targetType, String targetId) {
    return '$targetType $targetId';
  }

  @override
  String adminCenterMinimumCharactersRequired(int count) {
    return 'Une note d’au moins $count caractères est requise.';
  }

  @override
  String adminCenterMinimumReasonCharactersRequired(int count) {
    return 'Un motif d’au moins $count caractères est requis.';
  }

  @override
  String adminCenterPageOf(int currentPage, int totalPages) {
    return 'Page $currentPage sur $totalPages';
  }

  @override
  String get profilePublicProfileSectionTitle => 'Profil public';

  @override
  String get profileIdentityVerificationSectionTitle => 'Identité et vérification';

  @override
  String get profilePreferencesSectionTitle => 'Préférences';

  @override
  String get profileNotificationsSectionTitle => 'Notifications';

  @override
  String get profileActivitySectionTitle => 'Activité personnelle';

  @override
  String get profileSecurityAccountSectionTitle => 'Sécurité et compte';

  @override
  String get profileThemeTitle => 'Thème';

  @override
  String get profileThemeSystem => 'Système';

  @override
  String get profileThemeSystemDescription => 'Suit le thème de l’appareil';

  @override
  String get profileThemeLight => 'Clair';

  @override
  String get profileThemeDark => 'Sombre';

  @override
  String get profileMyPollsTitle => 'Vote';

  @override
  String get profileMyPostsTitle => 'Voce';

  @override
  String get profileMyCommentsTitle => 'Mes commentaires';

  @override
  String get profileMyFavoritesTitle => 'Mes éléments enregistrés';

  @override
  String get profileAccountConnectionsTitle => 'Abonnements et abonnés';

  @override
  String get accountConnectionsFollowingTab => 'Abonnements';

  @override
  String get accountConnectionsFollowersTab => 'Abonnés';

  @override
  String get accountConnectionsEmptyFollowing => 'Vous ne suivez encore aucun compte.';

  @override
  String get accountConnectionsEmptyFollowers => 'Vous n’avez encore aucun abonné.';

  @override
  String get accountConnectionsLoadError => 'Impossible de charger les comptes. Réessayez.';

  @override
  String get profileMyFollowedScopesTitle => 'Mes zones suivies';

  @override
  String get profileLogoutAction => 'Se déconnecter';

  @override
  String get profileLogoutDescription => 'Se déconnecter du compte actuel';

  @override
  String get profileLogoutDialogTitle => 'Se déconnecter';

  @override
  String get profileLogoutDialogMessage => 'Voulez-vous vraiment vous déconnecter de votre compte ?';

  @override
  String get profileLogoutCancelButton => 'Annuler';

  @override
  String get profileLogoutConfirmButton => 'Se déconnecter';

  @override
  String get publicProfilePageTitle => 'Profil public';

  @override
  String get publicProfileUserFallback => 'Utilisateur';

  @override
  String get publicProfileNoBio => 'Aucune bio disponible.';

  @override
  String get publicProfileResidenceLabel => 'Résidence';

  @override
  String get publicProfileResidenceUnknown => 'Non précisé';

  @override
  String get publicProfileMemberSinceLabel => 'Membre depuis';

  @override
  String get publicProfileContentSectionTitle => 'Contenu public';

  @override
  String get publicProfilePollsAction => 'Vote';

  @override
  String get publicProfilePostsAction => 'Voce';

  @override
  String get publicProfileBlockUserAction => 'Bloquer l’utilisateur';

  @override
  String get publicProfileLoadError => 'Impossible de charger le profil.';

  @override
  String get publicProfileNotFound => 'Profil indisponible.';

  @override
  String get publicProfileUnblockUserAction => 'Débloquer l’utilisateur';

  @override
  String get publicProfileBlockDialogTitle => 'Bloquer cet utilisateur ?';

  @override
  String get publicProfileBlockDialogMessage => 'Vous pourrez le débloquer plus tard depuis son profil public.';

  @override
  String get publicProfileUnblockDialogTitle => 'Débloquer cet utilisateur ?';

  @override
  String get publicProfileUnblockDialogMessage => 'L’utilisateur ne figurera plus dans votre liste de blocage.';

  @override
  String get publicProfileBlockSuccess => 'Utilisateur bloqué.';

  @override
  String get publicProfileUnblockSuccess => 'Utilisateur débloqué.';

  @override
  String get publicProfileBlockError => 'Impossible de mettre à jour le blocage. Réessayez.';

  @override
  String get publicProfileFollowersLabel => 'abonnés';

  @override
  String get publicProfileFollowingLabel => 'abonnements';

  @override
  String get publicProfileFollowAction => 'Suivre';

  @override
  String get publicProfileUnfollowAction => 'Ne plus suivre';

  @override
  String get publicProfileFollowSuccess => 'Compte suivi.';

  @override
  String get publicProfileUnfollowSuccess => 'Compte non suivi.';

  @override
  String get publicProfileFollowError => 'Impossible de mettre à jour l’abonnement. Réessayez.';

  @override
  String get publicProfileFollowRetry => 'Recharger les informations d’abonnement';

  @override
  String get contentLanguageFieldLabel => 'Langue du contenu';

  @override
  String get contentLanguageFieldHelper => 'Sélectionnez la langue dans laquelle vous avez écrit le contenu.';

  @override
  String get contentLanguageUndetermined => 'Non précisé';

  @override
  String get createPollAdvancedOptionsTitle => 'Options avancées';

  @override
  String get createPollAdvancedOptionsSubtitle => 'Anonymat, visibilité des résultats, modification du vote et quorum.';

  @override
  String get onboardingSkipButton => 'Ignorer';

  @override
  String get onboardingNextButton => 'Suivant';

  @override
  String get onboardingStartButton => 'Commencer';

  @override
  String get onboardingPollTitle => 'Vote';

  @override
  String get onboardingPollDescription => 'Participez à un Vote sur les sujets qui vous intéressent, ou créez-en un pour recueillir l’avis de la communauté.';

  @override
  String get onboardingHeatIceTitle => 'Heat et Ice';

  @override
  String get onboardingHeatIceDescription => 'Utilisez Heat et Ice pour indiquer à quel point un contenu attire votre intérêt.';

  @override
  String get onboardingCivicMapTitle => 'Civic Map';

  @override
  String get onboardingCivicMapDescription => 'Explorez Vote, Voce et News sur la carte et découvrez ce qui se passe dans différentes zones.';

  @override
  String get onboardingGeoScopeTitle => 'GeoScope';

  @override
  String get onboardingGeoScopeDescription => 'Choisissez le niveau géographique à suivre : monde, pays ou ville.';

  @override
  String get onboardingVerificationTitle => 'Vérification d’identité';

  @override
  String get onboardingVerificationDescription => 'Certains Vote peuvent exiger un niveau de vérification afin de protéger l’intégrité du vote.';

  @override
  String get pollDetail_voteReceiptButton => 'Reçu de vote';

  @override
  String get pollDetail_voteReceiptTitle => 'Reçu de vote';

  @override
  String get pollDetail_voteReceiptIdLabel => 'ID du reçu';

  @override
  String get pollDetail_voteReceiptDateLabel => 'Enregistré';

  @override
  String get pollDetail_voteReceiptPrivacy => 'Ce reçu confirme que votre vote a été enregistré sans révéler votre choix.';

  @override
  String get pollDetail_voteReceiptCloseButton => 'Fermer';

  @override
  String get profileBiometricUnlockTitle => 'Déverrouillage biométrique';

  @override
  String get profileBiometricUnlockDescription => 'Protège votre session mémorisée avec l’empreinte ou la reconnaissance biométrique de l’appareil.';

  @override
  String get profileBiometricRequiresRememberMe => 'Nécessite l’activation de Se souvenir de moi.';

  @override
  String get profileBiometricUnavailable => 'La biométrie est indisponible ou non configurée sur cet appareil.';

  @override
  String get profileBiometricEnableReason => 'Confirmez vos données biométriques pour activer le déverrouillage Social Vote.';

  @override
  String get profileBiometricEnabledMessage => 'Déverrouillage biométrique activé.';

  @override
  String get profileBiometricDisabledMessage => 'Déverrouillage biométrique désactivé.';

  @override
  String get profileBiometricAuthFailedMessage => 'L’authentification biométrique n’a pas été terminée.';

  @override
  String get biometricLockTitle => 'Social Vote est verrouillé';

  @override
  String get biometricLockMessage => 'Utilisez la biométrie de votre appareil pour déverrouiller la session mémorisée.';

  @override
  String get biometricUnlockButton => 'Déverrouiller';

  @override
  String get biometricUsePasswordButton => 'Utiliser le mot de passe';

  @override
  String get biometricUnlockReason => 'Déverrouillez votre session Social Vote.';

  @override
  String get biometricUnlockFailedMessage => 'Échec du déverrouillage. Réessayez ou utilisez votre mot de passe.';

  @override
  String get adminCenterOperationalActivityTitle => 'Activité opérationnelle';

  @override
  String get adminCenterOperationalActivitySubtitle => 'Compteurs agrégés. Aucun suivi en temps réel de la présence en ligne.';

  @override
  String get adminCenterLast24HoursLabel => '24 heures';

  @override
  String get adminCenterLast7DaysLabel => '7 jours';

  @override
  String get adminCenterNewUsersMetric => 'Nouvelles inscriptions';

  @override
  String get adminCenterRecentSignInsMetric => 'Connexions récentes';

  @override
  String get adminCenterPollsCreatedMetric => 'Vote créés';

  @override
  String get adminCenterPostsCreatedMetric => 'Voce créées';

  @override
  String get adminCenterAdminActionsMetric => 'Actions Admin';

  @override
  String get authPublicNameHelper => 'C’est le nom que les autres utilisateurs verront. Votre nom d’utilisateur est créé automatiquement.';

  @override
  String get adminCenterRefreshMarkersTooltip => 'Actualiser les marqueurs du Globe';

  @override
  String get adminCenterMarkerDensityTitle => 'Densité des marqueurs du monde';

  @override
  String get adminCenterMarkerDensitySubtitle => 'Contrôle le budget visuel des marqueurs du Home Globe sans modifier les coordonnées réelles ni le classement du contenu.';

  @override
  String get adminCenterMarkerDensityEmpty => 'Vide';

  @override
  String get adminCenterMarkerDensityFull => 'Complet';

  @override
  String adminCenterMarkerDensityBudget(int count) {
    return 'Budget Home : $count marqueurs';
  }

  @override
  String get adminCenterMarkerDensitySaveError => 'Impossible d’enregistrer la densité des marqueurs du monde.';

  @override
  String get adminCenterMarkerDensityBackendUnavailable => 'Les paramètres backend des marqueurs du monde ne sont pas encore disponibles.';

  @override
  String get adminCenterQuickActionsTitle => 'Actions rapides sur le compte';

  @override
  String get adminCenterModerationSnapshotTitle => 'Aperçu de la modération et de l’activité';

  @override
  String get adminCenterReportsReceivedMetric => 'Signalements reçus';

  @override
  String get adminCenterPendingReportsMetric => 'Signalements en attente';

  @override
  String get adminCenterConfirmedViolationsMetric => 'Violations confirmées';

  @override
  String get adminCenterReportsFiledMetric => 'Signalements déposés';

  @override
  String get adminCenterCommentsCreatedMetric => 'Commentaires créés';

  @override
  String get adminCenterAdminActionsOnAccountMetric => 'Actions Admin sur le compte';

  @override
  String get adminCenterLastReportReceivedLabel => 'Dernier signalement reçu';

  @override
  String get adminCenterOpenFullAccountAction => 'Ouvrir tous les contrôles du compte';

  @override
  String get profileAppLanguageGerman => 'Allemand';

  @override
  String get profileAppLanguagePersian => 'Persan';

  @override
  String get discoveryPageTitle => 'Explorer';

  @override
  String get organizationWorkspaceTitle => 'Workspace de l’organisation';

  @override
  String get organizationPilotBannerTitle => 'Pilote gratuit';

  @override
  String get organizationPilotBannerBody => 'Les Sessions sont gratuites pendant le pilote. Certaines fonctions professionnelles pourront devenir payantes à l’avenir ; la facturation n’est pas active actuellement.';

  @override
  String get organizationVerifiedLabel => 'Organisation vérifiée';

  @override
  String get organizationEditProfile => 'Modifier le profil de l’organisation';

  @override
  String get organizationCreateSession => 'Nouvelle Session';

  @override
  String get organizationNoSessions => 'Aucune Session pour le moment. Créez la première pour une réunion, un atelier ou un événement.';

  @override
  String get organizationSessionsTitle => 'Sessions en direct';

  @override
  String get organizationRequiresVerificationTitle => 'Organisation vérifiée requise';

  @override
  String get organizationRequiresVerificationBody => 'Ce Workspace est disponible uniquement pour les comptes approuvés par Social Vote comme organisation vérifiée.';

  @override
  String get organizationProfileEditorTitle => 'Profil de l’organisation';

  @override
  String get organizationLegalName => 'Dénomination légale';

  @override
  String get organizationPublicName => 'Nom public';

  @override
  String get organizationType => 'Type d’organisation';

  @override
  String get organizationCountryCode => 'Code pays';

  @override
  String get organizationCity => 'Ville';

  @override
  String get organizationWebsite => 'Site officiel';

  @override
  String get organizationDescription => 'Description';

  @override
  String get organizationUploadCover => 'Changer la couverture';

  @override
  String get organizationUploadLogo => 'Changer le logo';

  @override
  String get organizationMediaUpdated => 'Image de l’organisation mise à jour.';

  @override
  String get organizationNamesRequired => 'Les noms légal et public sont obligatoires.';

  @override
  String get organizationTypeAssociation => 'Association';

  @override
  String get organizationTypeNonprofit => 'Organisation à but non lucratif';

  @override
  String get organizationTypeCompany => 'Entreprise';

  @override
  String get organizationTypeCooperative => 'Coopérative';

  @override
  String get organizationTypeSports => 'Organisation sportive';

  @override
  String get organizationTypePublicBody => 'Organisme public';

  @override
  String get organizationTypeCommittee => 'Comité / groupe';

  @override
  String get organizationTypeOther => 'Autre';

  @override
  String get sessionCreateTitle => 'Créer une Live Session';

  @override
  String get sessionTitleLabel => 'Titre de la Session';

  @override
  String get sessionExpectedParticipants => 'Participants attendus';

  @override
  String get sessionAccessMode => 'Accès des participants';

  @override
  String get sessionAccessOpen => 'Anonyme ouvert';

  @override
  String get sessionAccessOpenHint => 'Toute personne disposant du lien/code peut participer. La prévention des doublons est au mieux de l’effort ; ce mode ne garantit pas une personne = un vote.';

  @override
  String get sessionAccessControlled => 'Anonyme contrôlé';

  @override
  String get sessionAccessControlledHint => 'Utilisez des Access Passes anonymes à usage unique. Social Vote conserve uniquement le hash de l’Access Pass et ne relie pas les choix du bulletin aux identifiants du participant.';

  @override
  String get sessionResultsVisibility => 'Visibilité des résultats';

  @override
  String get sessionResultsLive => 'En direct';

  @override
  String get sessionResultsAfterVote => 'Après le vote du participant';

  @override
  String get sessionResultsAfterClose => 'Après la clôture de la question';

  @override
  String get sessionResultsOrganizerOnly => 'Organisateur uniquement';

  @override
  String get sessionCreateAction => 'Créer la Session';

  @override
  String get sessionPilotLimit => 'Limite du pilote : 1 à 250 participants par Session.';

  @override
  String get sessionStatusDraft => 'Brouillon';

  @override
  String get sessionStatusOpen => 'Ouverte';

  @override
  String get sessionStatusClosed => 'Fermée';

  @override
  String get sessionJoinCode => 'Code d’accès';

  @override
  String get sessionShareJoin => 'Partager le lien d’accès';

  @override
  String get sessionCopyJoinLink => 'Copier le lien';

  @override
  String get sessionGenerateTokens => 'Générer des Access Passes';

  @override
  String get sessionGenerateTokensCount => 'Nombre d’Access Passes';

  @override
  String get sessionTokensOneTimeTitle => 'Enregistrez ces identifiants maintenant';

  @override
  String get sessionTokensOneTimeBody => 'Les Access Passes en clair ne sont affichés que dans le résultat de ce lot. Social Vote ne conserve que leurs hash. Copiez-les et distribuez-les de manière sécurisée.';

  @override
  String get sessionCopyTokens => 'Copier tous les liens';

  @override
  String get sessionTokensSavedAction => 'Je les ai enregistrés';

  @override
  String get sessionOpenAction => 'Ouvrir la Session';

  @override
  String get sessionCloseAction => 'Fermer la Session';

  @override
  String get sessionCloseConfirm => 'Clôturer le vote et créer l’instantané immuable Verified Result ?';

  @override
  String get sessionQuestionsTitle => 'Questions';

  @override
  String get sessionAddQuestion => 'Ajouter une question';

  @override
  String get sessionQuestionTitle => 'Question';

  @override
  String get sessionQuestionType => 'Type de question';

  @override
  String get sessionTypeYesNo => 'Oui / Non';

  @override
  String get sessionTypeSingle => 'Choix unique';

  @override
  String get sessionTypeMultiple => 'Choix multiples';

  @override
  String get sessionOptions => 'Options';

  @override
  String get sessionOptionHint => 'Une option par ligne.';

  @override
  String get sessionMinSelections => 'Sélections minimum';

  @override
  String get sessionMaxSelections => 'Sélections maximum';

  @override
  String get sessionAddAction => 'Ajouter';

  @override
  String get sessionOpenQuestion => 'Ouvrir la question';

  @override
  String get sessionCloseQuestion => 'Fermer la question';

  @override
  String get sessionNoQuestions => 'Aucune question pour le moment.';

  @override
  String get sessionPresenterTitle => 'Présentateur';

  @override
  String get sessionParticipantTitle => 'Social Vote Live';

  @override
  String get sessionJoinAction => 'Rejoindre la Session';

  @override
  String get sessionTokenLabel => 'Jeton participant';

  @override
  String get sessionTokenHint => 'SV-…';

  @override
  String get sessionWaitingQuestion => 'En attente de l’ouverture d’une question par l’organisateur…';

  @override
  String get sessionVoteAction => 'Envoyer le vote';

  @override
  String get sessionVoteReceived => 'Vote reçu';

  @override
  String get sessionResultsUnavailable => 'Les résultats ne sont pas encore visibles selon la politique de cette Session.';

  @override
  String get sessionPrivacyNotice => 'L’organisateur définit l’objectif opérationnel et les questions de la Session. Social Vote traite les données techniques nécessaires pour fournir et protéger le service. Les modes anonymes n’exposent pas à l’organisateur le lien entre l’identifiant d’un participant et son choix. Les rôles en matière de confidentialité peuvent dépendre du contexte et des accords applicables.';

  @override
  String get sessionNonBindingNotice => 'Les Sessions pilotes servent à la consultation et à la participation. Elles ne constituent ni une élection légale, ni un vote d’assemblée statutaire, ni une certification juridiquement contraignante.';

  @override
  String get sessionOptionYes => 'Oui';

  @override
  String get sessionOptionNo => 'Non';

  @override
  String get verifiedResultTitle => 'Verified Result';

  @override
  String get verifiedResultValid => 'Contrôle d’intégrité réussi';

  @override
  String get verifiedResultInvalid => 'Échec du contrôle d’intégrité';

  @override
  String get verifiedResultReportId => 'ID du rapport';

  @override
  String get verifiedResultHash => 'Hash SHA-256 du résultat';

  @override
  String get verifiedResultGeneratedBy => 'Généré et scellé pour l’intégrité par Social Vote';

  @override
  String get verifiedResultNotLegalCertificate => 'Il s’agit d’un rapport de résultat agrégé vérifiable, et non d’un certificat légal ni d’une certification d’une élection juridiquement contraignante.';

  @override
  String get verifiedResultShare => 'Partager le lien de vérification';

  @override
  String sessionResponses(int count) {
    return '$count réponses';
  }

  @override
  String sessionResultVotes(int count) {
    return '$count votes';
  }

  @override
  String get organizationVerifiedIdentityLocked => 'Le nom et le pays font partie de l’identité vérifiée de l’organisation. Les modifier exigera une nouvelle vérification. Vous pouvez modifier librement la couverture, le logo, le type, la ville, le site et la description.';

  @override
  String get verifiedResultOpenedAt => 'Session ouverte';

  @override
  String get verifiedResultEligibleCredentials => 'Identifiants éligibles';

  @override
  String get verifiedResultIntegritySeal => 'Sceau d’intégrité Social Vote';

  @override
  String get organizationVerifiedNameLocked => 'Le nom vérifié et le pays sont verrouillés. Les modifier nécessite un nouvel examen de vérification.';

  @override
  String get sessionRetentionLabel => 'Conservation des bulletins bruts';

  @override
  String get sessionRetention24h => '24 heures';

  @override
  String get sessionRetention7d => '7 jours';

  @override
  String get sessionRetention30d => '30 jours';

  @override
  String sessionRetentionValue(String value) {
    return 'Conservation des bulletins bruts : $value';
  }

  @override
  String get verifiedResultPrintPdf => 'Télécharger le PDF';

  @override
  String get verifiedResultPdfError => 'Impossible de télécharger le PDF. Réessayez.';

  @override
  String get verifiedResultRestrictedTitle => 'Résultat restreint';

  @override
  String get verifiedResultRestrictedBody => 'Ce Verified Result n’est pas accessible au public. Connectez-vous avec un compte d’organisation autorisé pour le consulter.';

  @override
  String get verifiedResultPrivateVerificationTitle => 'Vérification publique indisponible';

  @override
  String get verifiedResultPrivateVerificationBody => 'Ce résultat est limité à l’organisateur. L’ID du rapport, le SHA-256 et le contrôle d’intégrité restent disponibles dans le rapport autorisé.';

  @override
  String get organizationAccountSectionTitle => 'Vos organisations';

  @override
  String get organizationManageAction => 'Gérer';

  @override
  String get organizationViewPublicProfileAction => 'Voir le profil';

  @override
  String get organizationOfficialWebsiteAction => 'Site officiel';

  @override
  String get organizationVerificationIntro => 'La vérification porte à la fois sur l’existence de l’organisation et sur votre autorité à la représenter. Social Vote examinera les informations fournies avant approbation.';

  @override
  String get organizationVerificationLegalName => 'Dénomination légale';

  @override
  String get organizationVerificationPublicName => 'Nom public';

  @override
  String get organizationVerificationType => 'Type d’organisation';

  @override
  String get organizationVerificationCountry => 'Pays';

  @override
  String get organizationVerificationCountryRequired => 'Sélectionnez le pays de l’organisation.';

  @override
  String get organizationVerificationCity => 'Ville';

  @override
  String get organizationVerificationWebsite => 'Site officiel';

  @override
  String get organizationVerificationRepresentativeRole => 'Votre rôle dans l’organisation';

  @override
  String get organizationVerificationRegistryId => 'Identifiant registre / fiscal / organisation';

  @override
  String get organizationVerificationAuthorityNote => 'Comment pouvons-nous vérifier que vous pouvez la représenter ?';

  @override
  String get organizationVerificationAuthorityHelper => 'Indiquez brièvement votre rôle ou l’élément qu’un Admin peut vérifier pendant le pilote.';

  @override
  String get organizationVerificationRequired => 'Champ obligatoire.';

  @override
  String get sessionControlRoomTitle => 'Salle de contrôle de la Session';

  @override
  String get sessionSectionLive => 'En direct';

  @override
  String get sessionSectionQuestions => 'Questions';

  @override
  String get sessionSectionAccess => 'Accès';

  @override
  String get sessionSectionSettings => 'Paramètres';

  @override
  String get sessionStageAction => 'Ouvrir Stage';

  @override
  String get sessionAccessPassesTitle => 'Access Passes des participants';

  @override
  String get sessionAccessPassesSubtitle => 'Chaque pass ouvre cette Controlled Anonymous Session sans demander au participant de saisir l’identifiant long. Le pass en clair n’est pas conservé par Social Vote.';

  @override
  String get sessionAccessPass => 'Access Pass';

  @override
  String get sessionAccessPassDetected => 'Access Pass détecté';

  @override
  String get sessionAccessPassAutomatic => 'Votre pass personnel est prêt. Continuez pour entrer anonymement dans la Session.';

  @override
  String get sessionAccessPassFallback => 'Saisir le pass manuellement';

  @override
  String get sessionAccessPassInvalid => 'Cet Access Pass est invalide, déjà indisponible, ou la Session n’est pas ouverte.';

  @override
  String get sessionAccessPassPrintWarning => 'Imprimez, enregistrez ou distribuez ces passes maintenant. Après avoir quitté cet écran, Social Vote ne pourra plus afficher les passes en clair.';

  @override
  String get sessionExistingPassesHidden => 'Pour des raisons de sécurité, les passes générés précédemment ne peuvent plus être affichés en clair. Générez de nouveaux Access Passes pour obtenir de nouveaux liens personnels ou codes QR.';

  @override
  String get sessionCopyPassLinks => 'Copier tous les liens';

  @override
  String get sessionCopyPassLink => 'Copier ce lien';

  @override
  String get sessionControlledNeedsAccessPass => 'Avant d’ouvrir une Session contrôlée, générez au moins un Access Pass.';

  @override
  String get sessionJoinedParticipants => 'Identifiants d’accès ayant rejoint';

  @override
  String get sessionAccessesUsed => 'Accès ayant voté';

  @override
  String get sessionBallotsRecorded => 'Bulletins enregistrés';

  @override
  String get sessionQuestionsCompleted => 'Questions terminées';

  @override
  String get sessionCurrentQuestion => 'Question actuelle';

  @override
  String get sessionNoOpenQuestionTitle => 'Aucune question n’est ouverte';

  @override
  String get sessionNoOpenQuestionBody => 'Les participants sont connectés et attendent. Ouvrez la prochaine question lorsque vous êtes prêt.';

  @override
  String get sessionNotStartedTitle => 'La Session n’a pas encore commencé';

  @override
  String get sessionNotStartedBody => 'Cette Session existe mais n’est pas encore ouverte. Gardez cette page ouverte et attendez que l’organisateur la démarre.';

  @override
  String get sessionNoAccountRequired => 'Aucun compte Social Vote requis';

  @override
  String get sessionReceiptDetails => 'Détails du reçu';

  @override
  String get sessionOpenAccessInstructions => 'Affichez ou partagez ce QR. Toute personne disposant du lien peut entrer tant que la Session est ouverte.';

  @override
  String get sessionControlledAccessInstructions => 'Créez des passes d’accès personnels et donnez-en un à chaque participant. Le QR de chaque pass contient automatiquement l’identifiant.';

  @override
  String get sessionControlRoomHint => 'Gérez l’accès, les questions, le Stage projeté et le Verified Result final depuis un seul endroit.';

  @override
  String get sessionPresenterScreenTitle => 'Live Stage';

  @override
  String get sessionStageWaiting => 'En attente de la prochaine question';

  @override
  String get sessionStageScan => 'Scannez pour rejoindre la Session';

  @override
  String get sessionConfigurationTitle => 'Configuration de la Session';

  @override
  String get sessionAccessRecommended => 'Recommandé pour les réunions contrôlées';

  @override
  String get sessionCreateIntroTitle => 'Configurer la réunion';

  @override
  String get sessionCreateIntroBody => 'Choisissez comment les participants entrent, quand les résultats deviennent visibles et combien de temps les bulletins bruts sont conservés. Ces paramètres sont appliqués par le backend.';

  @override
  String get verifiedCertificateNumber => 'Numéro du certificat';

  @override
  String get verifiedCertificateStatus => 'Statut d’intégrité';

  @override
  String get verifiedCertificateIntegrityVerified => 'INTÉGRITÉ VÉRIFIÉE';

  @override
  String get verifiedCertificateIntegrityFailed => 'ÉCHEC DU CONTRÔLE D’INTÉGRITÉ';

  @override
  String get verifiedCertificateOrganizationSection => 'Organisation';

  @override
  String get verifiedCertificateSessionSection => 'Session';

  @override
  String get verifiedCertificateParticipationSection => 'Participation';

  @override
  String get verifiedCertificateResultsSection => 'Résultats vérifiés';

  @override
  String get verifiedCertificateIntegritySection => 'Intégrité du résultat';

  @override
  String get verifiedCertificateLegalName => 'Dénomination légale';

  @override
  String get verifiedCertificateOrganizationType => 'Type d’organisation';

  @override
  String get verifiedCertificateLocation => 'Localisation';

  @override
  String get verifiedCertificateWebsite => 'Site web';

  @override
  String get verifiedCertificateVerification => 'Vérification';

  @override
  String get verifiedCertificateIssuedAt => 'Certificat émis';

  @override
  String get verifiedCertificateAlgorithm => 'Algorithme d’intégrité';

  @override
  String get verifiedCertificateSchema => 'Schéma du rapport';

  @override
  String get verifiedCertificateJoinedCredentials => 'Identifiants ayant rejoint';

  @override
  String get verifiedCertificateBallotsTotal => 'Bulletins enregistrés';

  @override
  String get verifiedCertificateQuestionsTotal => 'Questions';

  @override
  String get verifiedCertificatePrivacyModel => 'Modèle de résultat anonyme';

  @override
  String get verifiedCertificatePrivacyText => 'L’instantané immuable contient uniquement des résultats agrégés. Il ne contient ni identité de participant, ni Access Pass en clair, ni secret de participant, ni correspondance entre un identifiant de participant et un choix de bulletin.';

  @override
  String get verifiedCertificateVerifyQr => 'Scannez ce QR pour vérifier le rapport en ligne.';

  @override
  String get organizationDashboardTitle => 'Vue d’ensemble de l’organisation';

  @override
  String get organizationActiveSessions => 'Sessions en direct';

  @override
  String get organizationVerifiedReports => 'Rapports vérifiés';

  @override
  String get organizationTotalSessions => 'Total des Sessions';

  @override
  String get sessionPrivacyPolicyAction => 'Lire la Politique de confidentialité';

  @override
  String get radioMondoTitle => 'Radio Mondo';

  @override
  String get radioMondoDescription => 'Trois paysages sonores originaux pour explorer Social Vote. La lecture ne démarre que lorsque vous choisissez une piste.';

  @override
  String get radioMondoTrackClassical => 'Orbite classique';

  @override
  String get radioMondoTrackRain => 'Pluie sur le monde';

  @override
  String get radioMondoTrackYoung => 'Pulse jeune';

  @override
  String get radioMondoPlaying => 'En cours de lecture';

  @override
  String get radioMondoStopped => 'Radio Mondo arrêtée';

  @override
  String get radioMondoStopAction => 'Arrêter';

  @override
  String get radioMondoPlaybackError => 'Impossible de lire l’audio';

  @override
  String get radioMondoForegroundOnly => 'La lecture s’arrête lorsque Social Vote est fermé, passe en arrière-plan ou lorsque l’onglet du navigateur est masqué.';

  @override
  String get adminCenterEditorialNavigation => 'World Briefs';

  @override
  String get worldBriefEditorTitle => 'Social Vote World Briefs';

  @override
  String get worldBriefEditorDescription => 'Préparez des synthèses fondées sur des preuves, rendez l’incertitude visible et décidez de ce qui apparaît dans News et sur le Globe.';

  @override
  String get worldBriefAllStatuses => 'Tous les statuts';

  @override
  String get worldBriefCreateAction => 'Créer un brief';

  @override
  String get worldBriefDraftSaved => 'Brouillon enregistré';

  @override
  String get worldBriefPublished => 'Brief publié';

  @override
  String get worldBriefWithdrawn => 'Brief retiré';

  @override
  String get worldBriefSaveError => 'Le brief n’a pas pu être enregistré';

  @override
  String get worldBriefPublishError => 'Le brief n’a pas pu être publié';

  @override
  String get worldBriefDraftDeleted => 'Brouillon supprimé';

  @override
  String get worldBriefDeleteDraft => 'Supprimer le brouillon';

  @override
  String get worldBriefDeleteDraftConfirm => 'Supprimer définitivement ce brouillon non publié ?';

  @override
  String get worldBriefRetry => 'Réessayer';

  @override
  String get worldBriefStatusDraft => 'Brouillon';

  @override
  String get worldBriefStatusPublished => 'Publié';

  @override
  String get worldBriefStatusWithdrawn => 'Retiré';

  @override
  String get worldBriefSetupRequired => 'Backend éditorial non prêt';

  @override
  String get worldBriefSetupRequiredBody => 'Appliquez la migration de base de données World Brief incluse avant d’utiliser cette section.';

  @override
  String get worldBriefEmptyTitle => 'Aucun World Brief pour le moment';

  @override
  String get worldBriefEmptyBody => 'Créez un brouillon, documentez au moins deux sources et publiez uniquement après examen éditorial.';

  @override
  String get worldBriefFeatured => 'À la une';

  @override
  String get worldBriefOnGlobe => 'Afficher sur le Globe';

  @override
  String get worldBriefPriority => 'Priorité';

  @override
  String get worldBriefEditAction => 'Modifier';

  @override
  String get worldBriefPublishAction => 'Publier';

  @override
  String get worldBriefWithdrawAction => 'Retirer';

  @override
  String get worldBriefSaveDraftAction => 'Enregistrer le brouillon';

  @override
  String get worldBriefLanguage => 'Langue du brief';

  @override
  String get worldBriefTitleField => 'Titre';

  @override
  String get worldBriefWhatHappened => 'Ce qui s’est passé';

  @override
  String get worldBriefWhyItMatters => 'Pourquoi c’est important';

  @override
  String get worldBriefWhatIsUncertain => 'Ce qui reste incertain';

  @override
  String get worldBriefSources => 'URL des sources';

  @override
  String get worldBriefSourcesHint => 'Une URL HTTPS par ligne ; au moins deux sources indépendantes.';

  @override
  String get worldBriefTwoSourcesRequired => 'Ajoutez au moins deux sources.';

  @override
  String get worldBriefHttpsSourcesRequired => 'Chaque source doit utiliser HTTPS.';

  @override
  String get worldBriefGlobeSection => 'Placement sur le Globe';

  @override
  String get worldBriefGlobeRequiresPoint => 'L’affichage sur le Globe nécessite une latitude et une longitude valides.';

  @override
  String get worldBriefCountryCode => 'Code pays';

  @override
  String get worldBriefCityId => 'ID ville';

  @override
  String get worldBriefLocationLabel => 'Libellé du lieu';

  @override
  String get worldBriefLatitude => 'Latitude';

  @override
  String get worldBriefLongitude => 'Longitude';

  @override
  String get worldBriefBreaking => 'Mise à jour urgente';

  @override
  String get worldBriefExpiry => 'Fenêtre de révision ou d’expiration';

  @override
  String worldBriefExpiryDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String get worldBriefRequiredField => 'Ce champ est obligatoire.';

  @override
  String get worldBriefCoordinatesRequired => 'Saisissez une coordonnée valide.';

  @override
  String get profileHowItWorksTitle => 'Comment fonctionne Social Vote';

  @override
  String get profileHowItWorksSubtitle => 'Personnes, Organisations, Voce, Vote, Sessions et vérification.';

  @override
  String get profileMyPostsLoginRequired => 'Vous devez être connecté pour voir vos Voce.';

  @override
  String get profileMyPostsCreatedByYou => 'Voce créées par vous';

  @override
  String get profileMyPostsEmpty => 'Vous n’avez encore créé aucune Voce.';

  @override
  String get profileMyPollsLoginRequired => 'Vous devez être connecté pour voir vos Vote.';

  @override
  String get profileMyPollsCreatedByYou => 'Vote créés par vous';

  @override
  String get profileMyPollsEmpty => 'Vous n’avez encore créé aucun Vote.';

  @override
  String get profileMyCommentsLoginRequired => 'Vous devez être connecté pour voir vos commentaires.';

  @override
  String get profileMyCommentsEmpty => 'Vous n’avez encore écrit aucun commentaire.';

  @override
  String get profileFollowedScopesLoginRequired => 'Vous devez être connecté.';

  @override
  String get profileFollowedScopesEmpty => 'Vous ne suivez encore aucune zone.';

  @override
  String get profileFollowedScopeWorld => 'Monde';

  @override
  String profileFollowedScopeCountry(String code) {
    return 'Pays : $code';
  }

  @override
  String profileFollowedScopeCity(String city) {
    return 'Ville : $city';
  }

  @override
  String profileFollowedScopeArea(double radius) {
    return 'Zone ($radius km)';
  }

  @override
  String get publicProfilePollsLoadError => 'Impossible de charger les Vote publics.';

  @override
  String get publicProfilePollsEmpty => 'Aucun Vote public.';

  @override
  String get publicProfilePostsLoadError => 'Impossible de charger les Voce publiques.';

  @override
  String get publicProfilePostsEmpty => 'Aucune Voce publique.';

  @override
  String get worldBriefSocialVoteView => 'Point de vue Social Vote';

  @override
  String get worldBriefSocialVoteViewHint => 'Analyse ou point de vue éditorial Social Vote. Gardez-le séparé des faits rapportés et des incertitudes.';

  @override
  String get worldBriefSocialVoteViewPublicNote => 'Analyse éditoriale Social Vote, clairement séparée des faits rapportés ci-dessus.';

  @override
  String get worldBriefIndependentSourcesRequired => 'La publication exige au moins deux sources HTTPS provenant de domaines différents.';

  @override
  String get worldBriefPublishConfirmTitle => 'Vérification finale avant publication';

  @override
  String worldBriefPublishConfirmSources(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sources saisies',
      one: '1 source saisie',
    );
    return '$_temp0';
  }

  @override
  String get worldBriefEnterpriseEditorTitle => 'Éditeur éditorial professionnel';

  @override
  String get worldBriefEnterpriseEditorHelp => 'Construisez le brief section par section. Social Vote gère automatiquement le placement technique sur le Globe : choisissez un pays et une ville, pas des coordonnées.';

  @override
  String get worldBriefEditorialContentSection => 'Contenu éditorial';

  @override
  String get worldBriefEditorialContentHelp => 'Séparez les faits, leur importance, les incertitudes et le point de vue Social Vote. Cela facilite la vérification et la lecture du brief.';

  @override
  String get worldBriefSourcesSection => 'Sources et vérification';

  @override
  String get worldBriefSourcesSectionHelp => 'Ajoutez des sources HTTPS vérifiables. La publication exige au moins deux domaines indépendants.';

  @override
  String get worldBriefDistributionSection => 'Distribution';

  @override
  String get worldBriefDistributionHelp => 'Choisissez où le brief apparaît. La publication le rend disponible dans News ; le placement sur le Globe est facultatif.';

  @override
  String get worldBriefNewsDestination => 'Publier dans Social Vote News';

  @override
  String get worldBriefNewsDestinationHelp => 'C’est la destination principale d’un World Brief une fois publié.';

  @override
  String get worldBriefGlobeAutomaticHelp => 'Ajoute un marqueur sur le Globe. Choisissez le lieu et Social Vote résout automatiquement la position.';

  @override
  String get worldBriefPlacementMode => 'Placement du marqueur';

  @override
  String get worldBriefPlacementCity => 'Ville / lieu';

  @override
  String get worldBriefPlacementCountry => 'Centre du pays';

  @override
  String get worldBriefCountry => 'Pays';

  @override
  String get worldBriefCity => 'Ville ou lieu';

  @override
  String get worldBriefCityHelp => 'Exemple : Téhéran. Ne saisissez pas la latitude ni la longitude.';

  @override
  String get worldBriefResolveLocation => 'Résoudre le lieu';

  @override
  String get worldBriefCoordinatesAutomatic => 'Les coordonnées sont gérées automatiquement et ne doivent pas être saisies manuellement.';

  @override
  String worldBriefLocationResolved(String location) {
    return 'Lieu prêt : $location';
  }

  @override
  String get worldBriefChooseCountryFirst => 'Choisissez d’abord un pays.';

  @override
  String get worldBriefChooseCityFirst => 'Saisissez d’abord une ville ou un lieu.';

  @override
  String get worldBriefLocationNotResolved => 'Impossible de déterminer un lieu fiable. Vérifiez le pays et la ville puis réessayez.';

  @override
  String get worldBriefVisibilitySection => 'Visibilité et priorité';

  @override
  String get worldBriefVisibilityHelp => 'Contrôlez la mise en avant éditoriale, l’urgence, l’ordre et la durée de vie sans modifier les faits rapportés.';

  @override
  String get worldBriefFeaturedHelp => 'Donnez davantage de visibilité au brief sur les surfaces éditoriales.';

  @override
  String get worldBriefBreakingHelp => 'À utiliser uniquement pour des événements réellement urgents ou en évolution rapide.';

  @override
  String get worldBriefPriorityHelp => '0 = priorité normale/faible ; 100 = priorité éditoriale maximale. Cela ne modifie pas le statut de vérité du contenu.';

  @override
  String get worldBriefExpiryHelp => 'Après cette fenêtre, le brief ne doit pas rester actif sans nouvelle révision éditoriale.';

  @override
  String get profileAppLanguageSpanish => 'Espagnol';

  @override
  String get profileAppLanguagePortuguese => 'Portugais';

  @override
  String get homeHeroPurpose => 'Découvrez ce qui compte, partagez votre Voce et participez à Vote.';

  @override
  String get commentSection_hideComments => 'Masquer les commentaires';

  @override
  String get commentSection_viewComments => 'Voir les commentaires';

  @override
  String get commentSection_hideReplies => 'Masquer les réponses';

  @override
  String commentSection_editing(String snippet) {
    return 'Modification : $snippet';
  }

  @override
  String get commentSection_editInputHint => 'Modifier votre commentaire';

  @override
  String commentSection_replyTo(String author) {
    return 'Répondre à $author';
  }

  @override
  String get commentSection_userFallback => 'Utilisateur';

  @override
  String get commentSection_addError => 'Impossible d’ajouter le commentaire.';

  @override
  String get commentSection_nestedReplyError => 'Les réponses imbriquées au-delà d’un niveau ne sont pas prises en charge.';

  @override
  String get commentSection_addReplyError => 'Impossible d’ajouter la réponse.';

  @override
  String get commentSection_editError => 'Impossible de modifier le commentaire.';

  @override
  String get commentSection_deleteError => 'Impossible de supprimer le commentaire.';

  @override
  String get commentSection_edited => 'Modifié';

  @override
  String get commentSection_editAction => 'Modifier';
}
