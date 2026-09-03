// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Social Vote';

  @override
  String get voteButton => 'Votar';

  @override
  String get createPollPageTitle => 'Crear Vote';

  @override
  String get createPollPageSubtitle => 'Define una nueva votación cívica';

  @override
  String get createPollBasicInfoTitle => 'Información básica';

  @override
  String get createPollBasicInfoSubtitle => 'Define los detalles principales del Vote.';

  @override
  String get createPollTitleFieldLabel => 'Título *';

  @override
  String get createPollTitleFieldHelper => 'Una pregunta o afirmación clara y concisa.';

  @override
  String get createPollDescriptionFieldLabel => 'Descripción (opcional)';

  @override
  String get createPollVotingModelTitle => 'Cómo funciona la votación';

  @override
  String get createPollVotingModelSubtitle => 'Elige si cada persona puede seleccionar una respuesta o varias respuestas.';

  @override
  String get createPollTypeFieldLabel => 'Tipo de Vote';

  @override
  String createPollSelectionRules(int min, int max) {
    return 'Reglas de selección: mínimo $min, máximo $max selecciones (ajustadas automáticamente según el tipo de Vote y las opciones).';
  }

  @override
  String get createPollAllowVoteChangeTitle => 'Permitir que los votantes cambien su voto';

  @override
  String get createPollAllowVoteChangeSubtitle => 'Hasta que se cierre el Vote.';

  @override
  String get createPollOptionsTitle => 'Respuestas';

  @override
  String get createPollOptionsSubtitle => 'Introduce al menos dos respuestas para que los votantes elijan. Los campos marcados con * son obligatorios.';

  @override
  String createPollOptionLabel(int index, Object requiredMarker) {
    return 'Opción $index$requiredMarker';
  }

  @override
  String get createPollRemoveOptionTooltip => 'Eliminar opción';

  @override
  String get createPollAddOptionButton => 'Añadir opción';

  @override
  String get createPollParticipationPrivacyTitle => 'Participación y privacidad';

  @override
  String get createPollParticipationPrivacySubtitle => 'Decide quién puede votar y qué grado de privacidad deben tener los votos.';

  @override
  String get createPollWhoCanVoteLabel => '¿Quién puede votar?';

  @override
  String get createPollParticipationEveryoneSubtitle => 'Cualquier usuario registrado puede participar.';

  @override
  String get createPollParticipationGeoScopeSubtitle => 'Limita este Vote a personas de un país específico.';

  @override
  String get createPollCountryFieldLabel => 'País para este Vote';

  @override
  String get createPollCountryFieldHelper => 'Este país definirá quién puede participar en este Vote (futura integración con el backend).';

  @override
  String get createPollVoteAnonymityTitle => 'Anonimato del voto';

  @override
  String get createPollAnonymityAnonymousSubtitle => 'Opción predeterminada recomendada para plataformas de votación cívica.';

  @override
  String get createPollAnonymityPublicSubtitle => 'Úsalo con precaución: los votos pueden asociarse a identidades (función futura).';

  @override
  String get createPollResultsValidityTitle => 'Resultados y validez';

  @override
  String get createPollResultsValiditySubtitle => 'Controla cuándo se muestran los resultados y define un cuórum mínimo si es necesario.';

  @override
  String get createPollResultsVisibilityFieldLabel => 'Visibilidad de los resultados';

  @override
  String get createPollQuorumTitle => 'Cuórum (opcional)';

  @override
  String get createPollQuorumSubtitle => 'Si se establece, el Vote se considera válido solo si se alcanza al menos este número de votos. Déjalo vacío para no exigir cuórum.';

  @override
  String get createPollQuorumMinVotesFieldLabel => 'Número mínimo de votos';

  @override
  String get createPollTimingTitle => 'Calendario';

  @override
  String get createPollTimingSubtitle => 'Define cuándo debe estar abierto el Vote para votar.';

  @override
  String get createPollStartDateLabel => 'Fecha de inicio';

  @override
  String get createPollEndDateLabel => 'Fecha de fin';

  @override
  String get createPollChangeDateButtonLabel => 'Cambiar';

  @override
  String get createPollTimingStatusInfo => 'El estado inicial (abierto/programado/cerrado) se determinará automáticamente según estas fechas.';

  @override
  String get createPollSuccessMessage => 'Vote creado correctamente';

  @override
  String get createPollSubmitCreatingLabel => 'Creando...';

  @override
  String get createPollSubmitLabel => 'Crear Vote';

  @override
  String get createPollPollTypeYesNoLabel => 'Sí / No';

  @override
  String get createPollPollTypeSingleChoiceLabel => 'Una respuesta';

  @override
  String get createPollPollTypeMultipleChoiceLabel => 'Varias respuestas';

  @override
  String get createPollPollTypeApprovalLabel => 'Votación por aprobación';

  @override
  String get createPollPollTypeRankedLabel => 'Elección por orden de preferencia';

  @override
  String get createPollPollTypeScoreLabel => 'Puntuación / Valoración';

  @override
  String get createPollParticipationScopeEveryoneLabel => 'Todos pueden votar';

  @override
  String get createPollParticipationScopeGeoScopeOnlyLabel => 'Solo usuarios de un país específico';

  @override
  String get createPollAnonymityLevelAnonymousLabel => 'Los votos son anónimos';

  @override
  String get createPollAnonymityLevelPublicLabel => 'Los votos son públicos (uso avanzado / restringido)';

  @override
  String get createPollResultsVisibilityAlwaysLabel => 'Siempre visibles (mientras el Vote está abierto)';

  @override
  String get createPollResultsVisibilityAfterVoteLabel => 'Visibles solo después de votar';

  @override
  String get createPollResultsVisibilityAfterCloseLabel => 'Visibles solo después de cerrar el Vote';

  @override
  String get homeLoginButton => 'Iniciar sesión';

  @override
  String get homeRegisterButton => 'Registrarse';

  @override
  String get homeProfileButton => 'Perfil';

  @override
  String get homeLogoutButton => 'Cerrar sesión';

  @override
  String get homeLogoutMessage => 'Sesión cerrada. Ahora estás usando la app como invitado (solo lectura).';

  @override
  String get homeSearchHint => 'Buscar ciudades, países, cuentas y contenido...';

  @override
  String get searchPageTitle => 'Buscar';

  @override
  String get searchInputHint => 'Buscar cuentas, Vote, News, Voce...';

  @override
  String get searchClearTooltip => 'Borrar búsqueda';

  @override
  String get searchTypeAll => 'Todo';

  @override
  String get searchTypePolls => 'Vote';

  @override
  String get searchTypeNews => 'News';

  @override
  String get searchTypePosts => 'Voce';

  @override
  String get searchTypeAccounts => 'Cuentas';

  @override
  String get searchSortHottest => 'Más populares';

  @override
  String get searchSortLatest => 'Más recientes';

  @override
  String get searchPollStatusAll => 'Todos los Vote';

  @override
  String get searchPollStatusOpen => 'Abiertos';

  @override
  String get searchPollStatusClosed => 'Cerrados';

  @override
  String get searchIdleMessage => 'Introduce un término para empezar a buscar.';

  @override
  String get searchErrorMessage => 'Se produjo un error durante la búsqueda.';

  @override
  String get searchRetryButton => 'Intentar de nuevo';

  @override
  String get searchEmptyMessage => 'No se encontraron resultados para esta búsqueda.';

  @override
  String get searchContentUnavailable => 'Contenido no disponible';

  @override
  String get searchResultTypePoll => 'Vote';

  @override
  String get searchResultTypeNews => 'News';

  @override
  String get searchResultTypePost => 'Voce';

  @override
  String get searchResultTypeAccount => 'Cuenta';

  @override
  String get searchResultTypeMixed => 'Mixto';

  @override
  String homeUserStatusLoggedIn(Object userId) {
    return 'Sesión iniciada como: $userId';
  }

  @override
  String get homeUserStatusGuest => 'Modo invitado: solo puedes leer. Inicia sesión o regístrate para votar, comentar y reaccionar.';

  @override
  String get homeScopeLabelWorld => 'Mundo – Votaciones y noticias globales';

  @override
  String get homeScopeLabelCountry => 'País – Votaciones y noticias nacionales';

  @override
  String get homeScopeLabelCity => 'Ciudad – Votaciones y noticias locales';

  @override
  String get homeScopeShortWorld => 'Mundo';

  @override
  String get homeScopeShortCountry => 'País';

  @override
  String get homeScopeShortCity => 'Ciudad';

  @override
  String get homeScopeChipWorld => 'Mundo';

  @override
  String get homeScopeChipItaly => 'Italia';

  @override
  String get homeScopeChipTorino => 'Turín';

  @override
  String get homeScopeChangedWorld => 'Ámbito cambiado a Mundo';

  @override
  String get homeScopeChangedItaly => 'Ámbito cambiado a Italia';

  @override
  String get homeScopeChangedTorino => 'Ámbito cambiado a Turín';

  @override
  String get followScopeButtonFollowed => 'Siguiendo';

  @override
  String get followScopeButtonFollow => 'Seguir esta zona';

  @override
  String get homeTrendingTitle => 'Pulse Now';

  @override
  String get homeTrendingError => 'No se puede cargar Pulse Now para esta zona.';

  @override
  String get homeTrendingEmpty => 'No hay contenido en Pulse Now para esta zona en este momento.';

  @override
  String homeForYouTitle(Object scope) {
    return 'Pulse ($scope)';
  }

  @override
  String get homeForYouError => 'No se puede cargar Pulse para esta zona.';

  @override
  String get homeForYouEmpty => 'No hay contenido sugerido en Pulse para esta zona en este momento.';

  @override
  String homePollsTitle(Object scope) {
    return 'Vote destacados ($scope)';
  }

  @override
  String get homePollsEmptyTitle => 'No hay Vote para esta zona';

  @override
  String get homePollsEmptySubtitle => 'No hay Vote disponibles para esta zona.';

  @override
  String get homePollsViewAllButton => 'Ver Vote';

  @override
  String homeNewsTitle(Object scope) {
    return 'Noticias principales ($scope)';
  }

  @override
  String get homeNewsErrorTitle => 'No se pueden cargar las noticias';

  @override
  String get homeNewsErrorSubtitle => 'Hubo un problema al cargar las noticias de esta zona.';

  @override
  String get homeNewsEmptyTitle => 'No hay noticias para esta zona';

  @override
  String get homeNewsEmptySubtitle => 'No hay noticias para este ámbito en este momento.';

  @override
  String get homeNewsViewAllButton => 'Ver todas las noticias';

  @override
  String get homeNewsBreakingBadge => 'ÚLTIMA HORA';

  @override
  String homeSocialTitle(Object scope) {
    return 'Voce ($scope)';
  }

  @override
  String get homeSocialErrorTitle => 'No se puede cargar Voce';

  @override
  String get homeSocialErrorSubtitle => 'Hubo un problema al cargar Voce para esta zona.';

  @override
  String get homeSocialEmptyTitle => 'No hay Voce para esta zona';

  @override
  String get homeSocialEmptySubtitle => 'No hay contenido de Voce para esta zona en este momento.';

  @override
  String get homeSocialViewFeedButton => 'Ver todos los Voce';

  @override
  String get pollDetail_title => 'Detalle del Vote';

  @override
  String get pollDetail_removeFromFavoritesTooltip => 'Eliminar de guardados';

  @override
  String get pollDetail_addToFavoritesTooltip => 'Guardar';

  @override
  String get pollDetail_chipAnonymous => 'Voto anónimo';

  @override
  String get pollDetail_chipPublic => 'Voto público';

  @override
  String get pollDetail_chipRestrictedGeo => 'Restringido al ámbito geográfico';

  @override
  String pollDetail_quorumReached(int currentVotes, int requiredVotes) {
    return 'Cuórum alcanzado ($currentVotes / $requiredVotes)';
  }

  @override
  String pollDetail_quorumNotReached(int currentVotes, int requiredVotes) {
    return 'Cuórum no alcanzado ($currentVotes / $requiredVotes)';
  }

  @override
  String get pollDetail_optionsTitle => 'Opciones';

  @override
  String get pollDetail_statusClosedMessage => 'Este Vote está cerrado.';

  @override
  String get pollDetail_statusScheduledMessage => 'Este Vote aún no está abierto.';

  @override
  String get pollDetail_statusNotAvailableMessage => 'La votación no está disponible.';

  @override
  String get pollDetail_voteSubmitted => '¡Voto enviado correctamente!';

  @override
  String get pollDetail_voteButton => 'Votar';

  @override
  String get pollDetail_resultsTitle => 'Resultados';

  @override
  String pollDetail_outcomePrefix(Object label) {
    return 'Resultado: $label';
  }

  @override
  String get pollDetail_noResults => 'Todavía no hay resultados disponibles.';

  @override
  String get pollDetail_resultsAfterVote => 'Los resultados serán visibles después de que votes.';

  @override
  String get pollDetail_resultsWhenClosed => 'Los resultados serán visibles cuando se cierre el Vote.';

  @override
  String get pollType_yesNo => 'Sí / No';

  @override
  String get pollType_singleChoice => 'Elección única';

  @override
  String get pollType_multipleChoice => 'Elección múltiple';

  @override
  String get pollType_approval => 'Aprobación';

  @override
  String get pollStatus_draft => 'Borrador';

  @override
  String get pollStatus_open => 'Abierto';

  @override
  String get pollStatus_closed => 'Cerrado';

  @override
  String get pollStatus_scheduled => 'Programado';

  @override
  String get pollGeo_global => 'Global';

  @override
  String get pollGeo_local => 'Local';

  @override
  String get pollOutcome_approved => 'Aprobado';

  @override
  String get pollOutcome_rejected => 'Rechazado';

  @override
  String get pollOutcome_tie => 'Empate';

  @override
  String get pollOutcome_noMajority => 'Sin mayoría';

  @override
  String get pollOutcome_notApplicable => 'No aplicable';

  @override
  String get pollList_title => 'Vote';

  @override
  String get pollList_scopeWorld => 'Mundo';

  @override
  String get pollList_scopeCountryFallback => 'País';

  @override
  String get pollList_scopeCityFallback => 'Ciudad';

  @override
  String get pollList_scopeDescriptionGlobal => 'Mostrando Vote globales.';

  @override
  String get pollList_scopeDescriptionCountry => 'Mostrando Vote para este país.';

  @override
  String get pollList_scopeDescriptionCity => 'Mostrando Vote para esta ciudad.';

  @override
  String get pollList_filterStatus_all => 'Todos';

  @override
  String get pollList_filterStatus_open => 'Abiertos';

  @override
  String get pollList_filterStatus_closed => 'Cerrados';

  @override
  String get pollList_sort_latest => 'Más recientes';

  @override
  String get pollList_sort_hottest => 'Más populares';

  @override
  String get pollList_filterScope_currentArea => 'Zona actual';

  @override
  String pollList_headerTitle(Object scopeLabel, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Vote encontrados',
      one: '1 Vote encontrado',
      zero: 'ningún Vote encontrado',
    );
    return '$scopeLabel · $_temp0';
  }

  @override
  String get pollList_createPollButton => 'Crear Vote';

  @override
  String get pollList_paginationHint => 'Desplázate para cargar más Vote…';

  @override
  String get pollList_emptyMessage => 'No hay Vote que coincidan con este filtro para esta zona.';

  @override
  String get pollType_ranked => 'Elección por orden de preferencia';

  @override
  String get pollType_score => 'Votación por puntuación';

  @override
  String get pollVisibility_whileOpen => 'Resultados visibles mientras está abierto';

  @override
  String get pollVisibility_afterVote => 'Resultados visibles después de votar';

  @override
  String get pollVisibility_afterClose => 'Resultados visibles después del cierre';

  @override
  String get pollCard_countryRestricted => 'Restringido por país';

  @override
  String pollCard_restrictedToCountry(Object countryName) {
    return 'Restringido a $countryName';
  }

  @override
  String pollCard_quorumLabel(int minVotes) {
    return 'Cuórum $minVotes';
  }

  @override
  String get pollCard_resultsVisibleChip => 'Resultados visibles';

  @override
  String get pollCard_resultsAfterVoteChip => 'Después de votar';

  @override
  String get pollCard_resultsAfterCloseChip => 'Después del cierre';

  @override
  String get pollCard_publicOfficialPublisher => 'Cargo público';

  @override
  String get pollCard_institutionPublisher => 'Institución';

  @override
  String get pollCard_representativePublisher => 'Representante';

  @override
  String pollCard_voteCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'votos',
      one: 'voto',
    );
    return '$_temp0';
  }

  @override
  String get pollCard_viewDetails => 'Ver detalles';

  @override
  String pollResult_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Resultados ($count votos)',
      one: 'Resultados (1 voto)',
      zero: 'Resultados (sin votos)',
    );
    return '$_temp0';
  }

  @override
  String get voteError_noSelection => 'Selecciona al menos una opción.';

  @override
  String get voteError_unauthorized => 'No tienes permiso para votar en este Vote.';

  @override
  String get voteError_generic => 'No se pudo enviar el voto. Inténtalo de nuevo.';

  @override
  String get commentSection_title => 'Comentarios';

  @override
  String get commentSection_sortLabel => 'Ordenar:';

  @override
  String get commentSection_sortOldest => 'Más antiguos';

  @override
  String get commentSection_sortNewest => 'Más recientes';

  @override
  String get commentSection_errorGeneric => 'Se produjo un error al cargar los comentarios.';

  @override
  String get commentSection_empty => 'Todavía no hay comentarios. Sé el primero en comentar.';

  @override
  String get commentSection_loadMore => 'Cargar más comentarios';

  @override
  String commentSection_replyingTo(Object snippet) {
    return 'Respondiendo a: $snippet';
  }

  @override
  String get commentSection_cancelReply => 'Cancelar';

  @override
  String get commentSection_inputHintRoot => 'Añadir un comentario...';

  @override
  String get commentSection_inputHintReply => 'Escribe una respuesta...';

  @override
  String get commentSection_deleteAction => 'Eliminar';

  @override
  String get commentSection_replyAction => 'Responder';

  @override
  String get commentSection_youBadge => 'Tú';

  @override
  String get newsDetail_title => 'Detalle de la noticia';

  @override
  String get newsDetail_breakingBadge => 'ÚLTIMA HORA';

  @override
  String get newsDetail_removeFromFavoritesTooltip => 'Eliminar de guardados';

  @override
  String get newsDetail_addToFavoritesTooltip => 'Guardar';

  @override
  String get newsDetail_bodyFallback => 'No hay texto adicional disponible para esta noticia.';

  @override
  String get newsDetail_footerMoreContext => 'Próximamente habrá más contexto y fuentes.';

  @override
  String get newsFeed_title => 'News';

  @override
  String get newsFeed_scopeWorld => 'Mundo';

  @override
  String get newsFeed_scopeCountry => 'País';

  @override
  String get newsFeed_scopeCity => 'Ciudad';

  @override
  String newsFeed_scopeLabel(Object scope) {
    return 'Ámbito: $scope';
  }

  @override
  String get newsFeed_scopeGlobalDescription => 'Mostrando noticias globales.';

  @override
  String get newsFeed_scopeCountryDescription => 'Mostrando noticias de este país.';

  @override
  String get newsFeed_scopeCityDescription => 'Mostrando noticias de esta ciudad.';

  @override
  String get newsFeed_emptyTitle => 'No hay noticias disponibles para esta zona.';

  @override
  String get newsFeed_emptySubtitle => 'Desliza para actualizar o inténtalo de nuevo más tarde.';

  @override
  String newsFeed_itemsFound(int count) {
    return '$count noticia(s) encontrada(s)';
  }

  @override
  String get newsFeed_loadingMoreHint => 'Desplázate para cargar más noticias…';

  @override
  String get newsFeed_errorTitle => 'No se pueden cargar las noticias';

  @override
  String get newsFeed_errorGeneric => 'Se produjo un error inesperado al cargar las noticias.';

  @override
  String get newsFeed_retryButton => 'Reintentar';

  @override
  String get newsCard_headerTitle => 'News';

  @override
  String get newsFeed_errorUnauthorized => 'La configuración de News no es válida (clave de API).';

  @override
  String get newsFeed_errorRateLimited => 'Demasiadas solicitudes. Inténtalo de nuevo en breve.';

  @override
  String get newsFeed_errorServerUnavailable => 'El servicio de News no está disponible temporalmente. Inténtalo de nuevo más tarde.';

  @override
  String get newsFeed_errorTimeout => 'La solicitud está tardando demasiado. Inténtalo de nuevo.';

  @override
  String get newsFeed_errorNetwork => 'Sin conexión. Comprueba tu conexión a Internet e inténtalo de nuevo.';

  @override
  String get newsFeed_moreTooltip => 'Más';

  @override
  String get newsFeed_actionCopyTitle => 'Copiar título';

  @override
  String get newsFeed_actionRefreshFeed => 'Actualizar feed';

  @override
  String get newsFeed_copiedTitleToast => 'Título copiado';

  @override
  String get newsFeed_languageTooltip => 'Idioma de News';

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
  String get newsFeed_languageLimitedHint => 'Fuentes limitadas en este idioma. Prueba AUTO.';

  @override
  String get newsTopic_all => 'Todo';

  @override
  String get newsTopic_world => 'Mundo';

  @override
  String get newsTopic_nation => 'Nacional';

  @override
  String get newsTopic_business => 'Negocios';

  @override
  String get newsTopic_technology => 'Tecnología';

  @override
  String get newsTopic_science => 'Ciencia';

  @override
  String get newsTopic_health => 'Salud';

  @override
  String get newsTopic_sports => 'Deportes';

  @override
  String get newsTopic_entertainment => 'Entretenimiento';

  @override
  String get newsDetail_openSource => 'Abrir artículo de la fuente';

  @override
  String get newsDetail_openSourceUnavailable => 'No se puede abrir el artículo de la fuente';

  @override
  String get socialFeedTitle => 'Voce';

  @override
  String get socialFeedCreatePostButton => 'Crear Voce';

  @override
  String get commonCancelButton => 'Cancelar';

  @override
  String get commonApplyButton => 'Aplicar';

  @override
  String get homeScopeChooseCountry => 'Elegir país';

  @override
  String get homeScopeCountrySearchHint => 'Buscar país o código...';

  @override
  String get homeScopeChooseCity => 'Elegir ciudad';

  @override
  String homeScopeCountryWithCode(String code) {
    return 'País: $code';
  }

  @override
  String get homeScopeCityFieldLabel => 'Ciudad';

  @override
  String get homeScopeCityExampleHint => 'Escribe una ciudad, p. ej. Merano';

  @override
  String get homeScopeCityRequiredError => 'Introduce una ciudad.';

  @override
  String get homeScopeCityNotFoundError => 'No se encontró la ciudad en el país seleccionado.';

  @override
  String get homeScopeCityVerificationError => 'No se puede verificar la ciudad. Inténtalo de nuevo.';

  @override
  String get homeScopeVerifyingButton => 'Verificando...';

  @override
  String get homeMapOpenButton => 'Abrir mapa';

  @override
  String get homeHeroHeadline => 'Da forma al futuro.\nJuntos.';

  @override
  String get homeHeroPollsAction => 'Vote';

  @override
  String get homeHeroNewsAction => 'News';

  @override
  String get homeHeroCreateAction => 'Crear';

  @override
  String get homeHeroExploreAction => 'Explorar';

  @override
  String get homeAccountMenuLabel => 'Cuenta';

  @override
  String get homeThemeSystemMenuItem => 'Tema: sistema';

  @override
  String get homeThemeLightMenuItem => 'Tema: claro';

  @override
  String get homeThemeDarkMenuItem => 'Tema: oscuro';

  @override
  String get profileAppLanguageTitle => 'Idioma de la app';

  @override
  String get profileAppLanguageSystem => 'Sistema';

  @override
  String get profileAppLanguageSystemDescription => 'Usa el idioma de tu dispositivo';

  @override
  String get profileAppLanguageItalian => 'Italiano';

  @override
  String get profileAppLanguageEnglish => 'Inglés';

  @override
  String get homeNotificationsTooltip => 'Notificaciones';

  @override
  String get postCard_authorFallback => 'Autor';

  @override
  String get postCard_globalLocation => 'Global';

  @override
  String get commonSaveButton => 'Guardar';

  @override
  String get commonDeleteButton => 'Eliminar';

  @override
  String get contentReport_menuAction => 'Denunciar contenido';

  @override
  String get contentReport_dialogTitle => 'Denunciar contenido';

  @override
  String get contentReport_authenticationRequired => 'Debes iniciar sesión para denunciar contenido';

  @override
  String get contentReport_submittedMessage => 'Denuncia enviada';

  @override
  String get contentReport_alreadySubmittedMessage => 'Ya has denunciado este contenido';

  @override
  String get contentReport_submitError => 'No se pudo enviar la denuncia';

  @override
  String get contentReport_sendButton => 'Enviar';

  @override
  String get contentReport_reasonSpam => 'Spam';

  @override
  String get contentReport_reasonHarassment => 'Acoso o abuso';

  @override
  String get contentReport_reasonHateSpeech => 'Discurso de odio';

  @override
  String get contentReport_reasonMisinformation => 'Desinformación';

  @override
  String get contentReport_reasonViolence => 'Violencia';

  @override
  String get contentReport_reasonOther => 'Otro';

  @override
  String get postDetail_title => 'Detalle de Voce';

  @override
  String get postDetail_favoriteUpdateError => 'No se pueden actualizar los elementos guardados';

  @override
  String get postDetail_shareMessage => 'Abre Social Vote para ver este Voce.';

  @override
  String get postDetail_shareError => 'No se puede compartir el Voce';

  @override
  String get postDetail_editDialogTitle => 'Editar Voce';

  @override
  String get postDetail_editTitleFieldLabel => 'Título';

  @override
  String get postDetail_editContentFieldLabel => 'Contenido';

  @override
  String get postDetail_editRequiredError => 'El título y el contenido son obligatorios.';

  @override
  String get postDetail_updateSuccess => 'Voce actualizado';

  @override
  String get postDetail_updateError => 'No se puede actualizar el Voce';

  @override
  String get postDetail_deleteDialogTitle => '¿Eliminar este Voce?';

  @override
  String get postDetail_deleteDialogMessage => 'Esta acción no se puede deshacer.';

  @override
  String get postDetail_deleteError => 'No se puede eliminar el Voce';

  @override
  String get postDetail_editMenuItem => 'Editar Voce';

  @override
  String get postDetail_deleteMenuItem => 'Eliminar Voce';

  @override
  String get postDetail_loadError => 'Se produjo un error al cargar el Voce.';

  @override
  String get postDetail_notFound => 'Voce no encontrado.';

  @override
  String get postDetail_errorTitle => 'Error';

  @override
  String get postDetail_authorFallback => 'Autor';

  @override
  String get postDetail_shareAction => 'Compartir';

  @override
  String get postDetail_saveAction => 'Guardar';

  @override
  String get postDetail_addToFavoritesTooltip => 'Guardar';

  @override
  String get postDetail_removeFromFavoritesTooltip => 'Eliminar de guardados';

  @override
  String get newsDetail_favoriteUpdateError => 'No se pueden actualizar los elementos guardados';

  @override
  String get newsDetail_shareMessage => 'Abre Social Vote para ver esta noticia.';

  @override
  String get newsDetail_shareError => 'No se puede compartir la noticia';

  @override
  String get newsDetail_shareTooltip => 'Compartir';

  @override
  String get authLoginPageTitle => 'Iniciar sesión';

  @override
  String get authLoginHeadline => 'Bienvenido de nuevo';

  @override
  String get authEmailLabel => 'Correo electrónico';

  @override
  String get authPasswordLabel => 'Contraseña';

  @override
  String get authRememberMeLabel => 'Recordarme';

  @override
  String get authForgotPasswordAction => '¿Olvidaste la contraseña?';

  @override
  String get authLoginButton => 'Iniciar sesión';

  @override
  String get authRegisterPrompt => '¿No tienes una cuenta?';

  @override
  String get authRegisterAction => 'Registrarse';

  @override
  String get authRegisterPageTitle => 'Registrarse';

  @override
  String get authRegisterHeadline => 'Crear una cuenta';

  @override
  String get authPersonalAccountOwnershipTitle => 'El inicio de sesión siempre pertenece a una persona';

  @override
  String get authPersonalAccountOwnershipBody => 'Si representas a una organización, crea tu cuenta personal. Después de iniciar sesión, puedes solicitar una Organización Verificada y gestionarla desde el Workspace.';

  @override
  String get authOrganizationPathAction => 'Cómo funciona para las organizaciones';

  @override
  String get authDisplayNameLabel => 'Nombre público';

  @override
  String get authUsernameLabel => 'Nombre de usuario';

  @override
  String get authCountryOfResidenceLabel => 'País de residencia';

  @override
  String get authCityOfResidenceLabel => 'Ciudad de residencia (opcional)';

  @override
  String get authConfirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get authLegalConsentPrefix => 'Confirmo que tengo al menos 18 años. Acepto los Términos de Servicio y confirmo que he leído la Política de Privacidad.';

  @override
  String get authTermsOfServiceAction => 'los Términos de Servicio';

  @override
  String get authPrivacyPolicyAction => 'la Política de Privacidad';

  @override
  String get authRegisterButton => 'Registrarse';

  @override
  String get authLoginPrompt => '¿Ya tienes una cuenta?';

  @override
  String get authLoginAction => 'Iniciar sesión';

  @override
  String get authForgotPasswordDialogTitle => 'Restablecer contraseña';

  @override
  String get authForgotPasswordDialogBody => 'Introduce la dirección de correo vinculada a tu cuenta. Te enviaremos un enlace para elegir una nueva contraseña.';

  @override
  String get authForgotPasswordSendButton => 'Enviar enlace';

  @override
  String get authPasswordResetEmailSent => 'Correo de restablecimiento enviado. Revisa tu bandeja de entrada.';

  @override
  String get authResetPasswordPageTitle => 'Restablecer contraseña';

  @override
  String get authResetPasswordHeadline => 'Elige una nueva contraseña';

  @override
  String get authNewPasswordLabel => 'Nueva contraseña';

  @override
  String get authConfirmNewPasswordLabel => 'Confirmar nueva contraseña';

  @override
  String get authUpdatePasswordButton => 'Actualizar contraseña';

  @override
  String get authPasswordUpdated => 'Contraseña actualizada correctamente.';

  @override
  String get authEmailConfirmationTitle => 'Revisa tu correo';

  @override
  String get authEmailConfirmationIntro => 'Hemos enviado un enlace de confirmación a:';

  @override
  String get authEmailConfirmationInstructions => 'Abre el enlace del mensaje para verificar tu dirección. Después de confirmarla, vuelve a la app e inicia sesión.';

  @override
  String get authBackToLoginButton => 'Volver al inicio de sesión';

  @override
  String get authUseAnotherEmailButton => 'Usar otra dirección de correo';

  @override
  String get authEmailRequiredError => 'Introduce tu correo electrónico.';

  @override
  String get authEmailInvalidError => 'Introduce una dirección de correo válida.';

  @override
  String get authPasswordRequiredError => 'Introduce tu contraseña.';

  @override
  String get authPasswordTooShortError => 'La contraseña debe tener al menos 8 caracteres.';

  @override
  String get authDisplayNameRequiredError => 'Introduce tu nombre público.';

  @override
  String get authDisplayNameTooShortError => 'El nombre público es demasiado corto.';

  @override
  String get authUsernameRequiredError => 'Introduce un nombre de usuario.';

  @override
  String get authUsernameInvalidError => 'Usa entre 3 y 20 caracteres: letras minúsculas, números y guiones bajos.';

  @override
  String get authUsernameAlreadyTakenError => 'El nombre de usuario ya está en uso.';

  @override
  String get authCountryRequiredError => 'Selecciona tu país de residencia.';

  @override
  String get authCityRequiredError => 'Introduce tu ciudad de residencia.';

  @override
  String get authConfirmPasswordRequiredError => 'Confirma tu contraseña.';

  @override
  String get authPasswordsDoNotMatchError => 'Las contraseñas no coinciden.';

  @override
  String get authLegalConsentRequiredError => 'Para registrarte, confirma que tienes al menos 18 años, acepta los Términos de Servicio y confirma que has leído la Política de Privacidad.';

  @override
  String get authForgotPasswordEmailRequiredError => 'Introduce el correo de la cuenta que quieres recuperar.';

  @override
  String get authInvalidCredentialsError => 'El correo o la contraseña no son válidos.';

  @override
  String get authEmailAlreadyRegisteredError => 'Este correo ya está registrado.';

  @override
  String get authEmailNotConfirmedError => 'Correo no confirmado. Revisa tu bandeja de entrada antes de iniciar sesión.';

  @override
  String get authTooManyAttemptsError => 'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.';

  @override
  String get authNetworkError => 'Error de red. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get authLoginGenericError => 'No se pudo iniciar sesión. Inténtalo de nuevo.';

  @override
  String get authRegisterGenericError => 'No se pudo completar el registro. Inténtalo de nuevo.';

  @override
  String get authPasswordResetGenericError => 'No se puede enviar el enlace de restablecimiento. Inténtalo de nuevo.';

  @override
  String get authPasswordUpdateGenericError => 'No se puede actualizar la contraseña. Inténtalo de nuevo.';

  @override
  String get authShowPasswordTooltip => 'Mostrar contraseña';

  @override
  String get authHidePasswordTooltip => 'Ocultar contraseña';

  @override
  String get authTermsPageTitle => 'Términos de Servicio';

  @override
  String get authPrivacyPageTitle => 'Política de Privacidad';

  @override
  String get authCloseButton => 'Cerrar';

  @override
  String get pollDetail_favoriteUpdateError => 'No se pueden actualizar los elementos guardados';

  @override
  String get pollDetail_shareMessage => 'Abre Social Vote para ver y votar en este Vote.';

  @override
  String get pollDetail_shareError => 'No se puede compartir el Vote';

  @override
  String get pollDetail_editPermissionError => 'Solo puedes editar tus propios Vote que no tengan votos registrados';

  @override
  String get pollDetail_editSuccessMessage => 'Vote actualizado';

  @override
  String get pollDetail_editMenuItem => 'Editar Vote';

  @override
  String get pollDetail_editSavingMenuItem => 'Guardando...';

  @override
  String get pollDetail_deletePermissionError => 'Solo puedes eliminar tus propios Vote';

  @override
  String get pollDetail_deleteError => 'No se puede eliminar el Vote';

  @override
  String get pollDetail_deleteDialogTitle => 'Eliminar Vote';

  @override
  String pollDetail_deleteDialogMessage(String title) {
    return '¿De verdad quieres eliminar \"$title\"? Esta acción no se puede deshacer.';
  }

  @override
  String get pollDetail_deleteMenuItem => 'Eliminar Vote';

  @override
  String get pollDetail_deleteDeletingMenuItem => 'Eliminando...';

  @override
  String get pollDetail_publicVotesAvailableTitle => 'Votos públicos disponibles';

  @override
  String get pollDetail_publicVotesAvailableMessage => 'Este Vote permite ver quién votó por cada opción.';

  @override
  String get pollDetail_publicVotesAction => 'Ver votos públicos';

  @override
  String get pollDetail_retryButton => 'Intentar de nuevo';

  @override
  String get pollDetail_voteErrorNoOption => 'Selecciona al menos una opción';

  @override
  String get pollDetail_voteErrorAuthenticationRequired => 'Debes iniciar sesión para votar';

  @override
  String get pollDetail_voteErrorClosed => 'Este Vote está cerrado';

  @override
  String get pollDetail_voteErrorAlreadyVoted => 'Ya has votado en este Vote';

  @override
  String get pollDetail_voteErrorGeneric => 'No se puede enviar el voto';

  @override
  String get pollDetail_publicVotesSheetTitle => 'Votos públicos';

  @override
  String get pollDetail_publicVotesSheetDescription => 'Aquí puedes ver quién votó por cada opción de este Vote.';

  @override
  String get pollDetail_publicVotesSearchHint => 'Buscar usuarios';

  @override
  String get pollDetail_publicVotesLoadError => 'No se pueden cargar los votos públicos';

  @override
  String get pollDetail_publicVotesEmpty => 'No hay votos públicos disponibles';

  @override
  String get pollDetail_publicVotesSearchEmpty => 'No se encontraron usuarios para esta búsqueda';

  @override
  String pollDetail_publicVotesResultsCount(int count) {
    return '$count resultados cargados';
  }

  @override
  String get pollDetail_publicVotesLoadMore => 'Cargar más';

  @override
  String get pollDetail_publicVotesUserFallback => 'Usuario';

  @override
  String get pollDetail_editDialogTitle => 'Editar Vote';

  @override
  String get pollDetail_editTitleFieldLabel => 'Título';

  @override
  String get pollDetail_editTitleRequired => 'El título es obligatorio';

  @override
  String get pollDetail_editDescriptionFieldLabel => 'Descripción';

  @override
  String get pollDetail_editError => 'No se puede actualizar el Vote';

  @override
  String get pollDetail_loadError => 'No se puede cargar el Vote';

  @override
  String get pollDetail_notFound => 'Vote no encontrado';

  @override
  String get profileEditPageTitle => 'Editar perfil';

  @override
  String get profileLoginRequiredMessage => 'Debes iniciar sesión para editar tu perfil.';

  @override
  String get profileAvatarUploading => 'Subiendo...';

  @override
  String get profileUploadAvatarButton => 'Subir avatar';

  @override
  String get profileDisplayNameLabel => 'Nombre para mostrar';

  @override
  String get profileDisplayNameRequiredError => 'El nombre para mostrar es obligatorio.';

  @override
  String get profileUsernameHint => 'p. ej. mario_roma';

  @override
  String get profileUsernameHelper => '3–20 caracteres: letras minúsculas, números y guiones bajos';

  @override
  String get profileAvatarUrlLabel => 'URL del avatar';

  @override
  String get profileBioLabel => 'Biografía';

  @override
  String get profileClearCountryButton => 'Borrar país';

  @override
  String get profileCityResidenceHelper => 'La ciudad de residencia se comprueba con el país seleccionado antes de guardar.';

  @override
  String get profileCityNotFoundError => 'No se encontró la ciudad en el país seleccionado.';

  @override
  String get profileCityVerificationError => 'No se puede verificar la ciudad en este momento.';

  @override
  String get profileAvatarUploadError => 'No se puede subir el avatar.';

  @override
  String get profileAccountSectionTitle => 'Cuenta';

  @override
  String get profileAccountEmailHelper => 'La dirección de correo de la cuenta no se puede cambiar desde esta pantalla.';

  @override
  String get profileChangePasswordAction => 'Cambiar contraseña';

  @override
  String get profileChangePasswordDescription => 'Establece una nueva contraseña para esta cuenta.';

  @override
  String get notificationsPageTitle => 'Notificaciones';

  @override
  String get notificationsMarkAllReadAction => 'Marcar todo como leído';

  @override
  String get notificationsNoTargetMessage => 'Esta notificación no tiene un destino disponible.';

  @override
  String get notificationsTargetUnavailableMessage => 'El contenido vinculado a esta notificación no está disponible.';

  @override
  String get notificationsLoadError => 'No se pueden cargar las notificaciones.';

  @override
  String get notificationsRetryButton => 'Intentar de nuevo';

  @override
  String get notificationsEmptyMessage => 'No hay notificaciones disponibles.';

  @override
  String get notificationsCommentReplyTitle => 'Nueva respuesta a tu comentario';

  @override
  String get notificationsMentionTitle => 'Te han mencionado';

  @override
  String get notificationsPollResultTitle => 'Actualización de Vote';

  @override
  String notificationsCommentReplySubtitle(String actor, String target) {
    return 'El usuario $actor respondió en $target';
  }

  @override
  String notificationsMentionSubtitle(String actor, String target) {
    return 'El usuario $actor te mencionó en $target';
  }

  @override
  String notificationsPollResultSubtitle(String target) {
    return 'Hay un nuevo resultado disponible en $target';
  }

  @override
  String get notificationsTargetPost => 'un Voce';

  @override
  String get notificationsTargetNews => 'una noticia';

  @override
  String get notificationsTargetPoll => 'un Vote';

  @override
  String get notificationsTargetVideo => 'un vídeo';

  @override
  String get notificationsTargetContent => 'contenido';

  @override
  String get notificationsUserFallback => 'usuario';

  @override
  String get profileDeleteAccountAction => 'Eliminar cuenta';

  @override
  String get profileDeleteAccountDescription => 'Eliminar permanentemente la cuenta y el acceso';

  @override
  String get profileDeleteAccountDialogTitle => 'Eliminar cuenta';

  @override
  String get profileDeleteAccountDialogMessage => 'Esta acción es permanente. La cuenta no se puede recuperar. Escribe DELETE para confirmar.';

  @override
  String get profileDeleteAccountConfirmationLabel => 'Confirmación de eliminación';

  @override
  String get profileDeleteAccountConfirmationHint => 'Escribe DELETE';

  @override
  String get profileDeleteAccountConfirmationError => 'Escribe DELETE para continuar.';

  @override
  String get profileDeleteAccountCancelButton => 'Cancelar';

  @override
  String get profileDeleteAccountConfirmButton => 'Eliminar permanentemente';

  @override
  String get profileDeleteAccountFailureMessage => 'No se puede eliminar la cuenta. Inténtalo de nuevo.';

  @override
  String get identityActorTypePerson => 'Persona';

  @override
  String get identityActorTypePublicOfficial => 'Cargo público';

  @override
  String get identityActorTypePublicInstitution => 'Institución pública';

  @override
  String get identityActorTypeVerifiedOrganization => 'Organización verificada';

  @override
  String get identityVerificationNotVerified => 'No verificado';

  @override
  String get identityVerificationLevel1 => 'Identidad verificada';

  @override
  String get identityVerificationLevel2 => 'Identidad verificada avanzada';

  @override
  String get identityBadgeLevel1 => 'Identidad verificada';

  @override
  String get identityBadgeLevel2 => 'Identidad verificada avanzada';

  @override
  String get identityBadgePublicOfficial => 'Cargo público';

  @override
  String get identityBadgePublicInstitution => 'Institución pública';

  @override
  String get identityBadgeVerifiedOrganization => 'Organización verificada';

  @override
  String get identityOrganizationNameLabel => 'Nombre de la organización';

  @override
  String get identityOrganizationNameRequired => 'Introduce el nombre de la organización.';

  @override
  String get identityInstitutionLevelMunicipality => 'Municipal';

  @override
  String get identityInstitutionLevelProvince => 'Provincial';

  @override
  String get identityInstitutionLevelRegion => 'Regional';

  @override
  String get identityInstitutionLevelMinistry => 'Ministerio';

  @override
  String get identityInstitutionLevelGovernment => 'Gobierno';

  @override
  String get identityInstitutionLevelPublicAgency => 'Agencia pública';

  @override
  String get identityInstitutionLevelOtherPublicBody => 'Otro organismo público';

  @override
  String get verificationRequestPersonLevel1 => 'Verificación de persona — Nivel 1';

  @override
  String get verificationRequestPersonLevel2 => 'Verificación de persona — Nivel 2';

  @override
  String get verificationRequestPublicOfficial => 'Verificación de cargo público';

  @override
  String get verificationRequestPublicInstitution => 'Verificación de institución pública';

  @override
  String get verificationRequestVerifiedOrganization => 'Verificación de organización';

  @override
  String get verificationCenterTitle => 'Verificación y tipo de cuenta';

  @override
  String get verificationCurrentAccountSection => 'Cuenta actual';

  @override
  String verificationAccountTypeValue(String accountType) {
    return 'Tipo de cuenta: $accountType';
  }

  @override
  String verificationLevelValue(String level) {
    return 'Nivel de verificación: $level';
  }

  @override
  String verificationOfficialTitleValue(String title) {
    return 'Cargo oficial: $title';
  }

  @override
  String verificationInstitutionNameValue(String name) {
    return 'Institución: $name';
  }

  @override
  String verificationOrganizationNameValue(String name) {
    return 'Organización: $name';
  }

  @override
  String verificationInstitutionLevelValue(String level) {
    return 'Nivel de la institución: $level';
  }

  @override
  String get verificationActiveRequestSection => 'Solicitud activa';

  @override
  String get verificationProfileUnchangedUntilApproval => 'Tu perfil actual no cambiará hasta que se apruebe la solicitud.';

  @override
  String get verificationCancelPendingAction => 'Cancelar solicitud pendiente';

  @override
  String get verificationPendingBlocksNewRequests => 'No puedes enviar una nueva solicitud mientras haya otra pendiente.';

  @override
  String get verificationNoActiveRequestSection => 'Sin solicitudes activas';

  @override
  String get verificationNoActiveRequestDescription => 'Actualmente no tienes solicitudes en revisión.';

  @override
  String get verificationLastRejectedSection => 'Última solicitud rechazada';

  @override
  String get verificationLastRejectedDescription => 'Tu última solicitud fue rechazada.';

  @override
  String get verificationRejectedCanResubmit => 'Tu perfil actual no ha cambiado. Puedes corregir la información y enviar una nueva solicitud.';

  @override
  String get verificationAvailableRequestsSection => 'Solicitudes disponibles';

  @override
  String get verificationRequestLevel1Title => 'Solicitar verificación de persona — Nivel 1';

  @override
  String get verificationRequestLevel1Subtitle => 'Verificación básica de identidad personal';

  @override
  String get verificationRequestLevel2Title => 'Solicitar verificación de persona — Nivel 2';

  @override
  String get verificationRequestLevel2Subtitle => 'Verificación avanzada de identidad personal';

  @override
  String get verificationRequestPublicOfficialTitle => 'Solicitar una cuenta de cargo público';

  @override
  String get verificationRequestPublicOfficialSubtitle => 'Requiere un cargo oficial y revisión';

  @override
  String get verificationRequestPublicInstitutionTitle => 'Solicitar una cuenta de institución pública';

  @override
  String get verificationRequestPublicInstitutionSubtitle => 'Requiere el nombre de la institución, su nivel y una revisión';

  @override
  String get verificationRequestOrganizationTitle => 'Solicitar una cuenta de organización verificada';

  @override
  String get verificationRequestOrganizationSubtitle => 'Requiere datos de la organización, función del representante y revisión de un administrador';

  @override
  String get verificationNoSelfServiceUpgrade => 'No hay opciones de verificación disponibles para el estado actual de tu cuenta.';

  @override
  String get verificationRequestSubmitSuccess => 'Solicitud enviada correctamente.';

  @override
  String get verificationRequestSubmitFailure => 'No se puede enviar la solicitud.';

  @override
  String get verificationOfficialTitleDialogTitle => 'Verificación de cargo público';

  @override
  String get verificationOfficialTitleLabel => 'Cargo oficial';

  @override
  String get verificationOfficialTitleHint => 'p. ej. Alcalde, Concejal, Ministro';

  @override
  String get verificationInstitutionDialogTitle => 'Verificación de institución pública';

  @override
  String get verificationInstitutionNameLabel => 'Nombre de la institución';

  @override
  String get verificationInstitutionNameHint => 'p. ej. Ayuntamiento de Roma';

  @override
  String get verificationInstitutionLevelLabel => 'Nivel de la institución';

  @override
  String get verificationOrganizationDialogTitle => 'Verificación de organización';

  @override
  String get verificationOrganizationNameHint => 'p. ej. Asociación Medio Ambiente Italia';

  @override
  String get verificationSubmitRequestAction => 'Enviar solicitud';

  @override
  String get verificationCancelDialogTitle => 'Cancelar solicitud';

  @override
  String get verificationCancelDialogBody => '¿Seguro que quieres cancelar la solicitud de verificación pendiente?';

  @override
  String get verificationCancelSuccess => 'Solicitud cancelada.';

  @override
  String get verificationCancelFailure => 'No se puede cancelar la solicitud.';

  @override
  String get verificationStatusPendingSuffix => 'solicitud en revisión';

  @override
  String get verificationStatusRejectedSuffix => 'última solicitud rechazada';

  @override
  String get verificationReviewPageTitle => 'Revisión de verificación';

  @override
  String get verificationReviewLoginRequired => 'Debes iniciar sesión para revisar solicitudes de verificación.';

  @override
  String verificationReviewPendingCount(int count) {
    return 'Solicitudes pendientes: $count';
  }

  @override
  String get verificationReviewNoPendingRequests => 'No hay solicitudes de verificación pendientes.';

  @override
  String get verificationReviewUserIdLabel => 'ID de usuario';

  @override
  String get verificationReviewSubmittedLabel => 'Enviada';

  @override
  String get verificationReviewOfficialTitleLabel => 'Cargo oficial';

  @override
  String get verificationReviewInstitutionLabel => 'Institución';

  @override
  String get verificationReviewOrganizationLabel => 'Organización';

  @override
  String get verificationReviewNoteLabel => 'Nota de revisión';

  @override
  String get verificationReviewRejectAction => 'Rechazar';

  @override
  String get verificationReviewApproveAction => 'Aprobar';

  @override
  String get verificationReviewApproveDialogTitle => 'Aprobar solicitud';

  @override
  String get verificationReviewRejectDialogTitle => 'Rechazar solicitud';

  @override
  String get verificationReviewApproveConfirmation => '¿Confirmar la aprobación de esta solicitud?';

  @override
  String get verificationReviewRejectConfirmation => '¿Confirmar el rechazo de esta solicitud?';

  @override
  String get verificationReviewOptionalNoteLabel => 'Nota de revisión opcional';

  @override
  String get verificationReviewRequiredNoteLabel => 'Motivo del rechazo';

  @override
  String get verificationReviewOptionalHelper => 'Opcional';

  @override
  String get verificationReviewRequiredHelper => 'Obligatorio al rechazar';

  @override
  String get verificationReviewRequiredNoteError => 'Introduce el motivo del rechazo.';

  @override
  String get verificationReviewApprovedSuccess => 'Solicitud aprobada.';

  @override
  String get verificationReviewRejectedSuccess => 'Solicitud rechazada.';

  @override
  String get verificationReviewOperationFailure => 'La operación ha fallado.';

  @override
  String get adminCenterTitle => 'Centro de administración';

  @override
  String get adminCenterDashboardNavigation => 'Panel';

  @override
  String get adminCenterUsersNavigation => 'Usuarios';

  @override
  String get adminCenterVerificationNavigation => 'Verificación';

  @override
  String get adminCenterReportsNavigation => 'Denuncias';

  @override
  String get adminCenterAuditNavigation => 'Auditoría';

  @override
  String get adminCenterAccountDetailsTitle => 'Detalles de la cuenta';

  @override
  String get adminCenterTryAgainAction => 'Intentar de nuevo';

  @override
  String get adminCenterRetryAction => 'Reintentar';

  @override
  String get adminCenterClearAction => 'Borrar';

  @override
  String get adminCenterApplyFiltersAction => 'Aplicar filtros';

  @override
  String get adminCenterAllDates => 'Todas las fechas';

  @override
  String get adminCenterAuditDateFilterHelp => 'Filtrar auditoría por fecha';

  @override
  String get adminCenterActorUserIdLabel => 'ID de usuario del actor';

  @override
  String get adminCenterActionLabel => 'Acción';

  @override
  String get adminCenterAuditActionHint => 'resolve_escalated_report';

  @override
  String get adminCenterTargetIdLabel => 'ID del objetivo';

  @override
  String get adminCenterOutcomeLabel => 'Resultado';

  @override
  String get adminCenterAllOutcomes => 'Todos los resultados';

  @override
  String get adminCenterOutcomeSuccess => 'Correcto';

  @override
  String get adminCenterOutcomeFailure => 'Fallo';

  @override
  String get adminCenterOutcomeDenied => 'Denegado';

  @override
  String get adminCenterOutcomeNoChange => 'Sin cambios';

  @override
  String get adminCenterOutcomeUnknown => 'Desconocido';

  @override
  String get adminCenterAuditUnavailableTitle => 'Auditoría no disponible';

  @override
  String get adminCenterAuditUnavailableMessage => 'Comprueba tu conexión y tus permisos e inténtalo de nuevo.';

  @override
  String get adminCenterNoAuditEntriesTitle => 'Sin entradas de auditoría';

  @override
  String get adminCenterNoAuditEntriesMessage => 'No hay entradas que coincidan con los filtros seleccionados.';

  @override
  String get adminCenterAuditIdLabel => 'ID de auditoría';

  @override
  String get adminCenterActorLabel => 'Actor';

  @override
  String get adminCenterReasonLabel => 'Motivo';

  @override
  String get adminCenterTimestampLabel => 'Fecha y hora';

  @override
  String get adminCenterErrorLabel => 'Error';

  @override
  String get adminCenterRecordedValuesTitle => 'Valores registrados';

  @override
  String get adminCenterPreviousValueLabel => 'Anterior';

  @override
  String get adminCenterNewValueLabel => 'Nuevo';

  @override
  String get adminCenterContentTypeLabel => 'Tipo de contenido';

  @override
  String get adminCenterAllContent => 'Todo el contenido';

  @override
  String get adminCenterPolls => 'Vote';

  @override
  String get adminCenterPosts => 'Voce';

  @override
  String get adminCenterNews => 'News';

  @override
  String get adminCenterAwaitingAdminDecision => 'Esperando decisión del administrador';

  @override
  String get adminCenterStatusLabel => 'Estado';

  @override
  String get adminCenterAllStatuses => 'Todos los estados';

  @override
  String get adminCenterStatusOpen => 'Abierto';

  @override
  String get adminCenterStatusInReview => 'En revisión';

  @override
  String get adminCenterStatusResolved => 'Resuelto';

  @override
  String get adminCenterStatusDismissed => 'Descartado';

  @override
  String get adminCenterAdminQueueUnavailableTitle => 'Cola de escalamiento administrativo no disponible';

  @override
  String get adminCenterReportsUnavailableTitle => 'Denuncias no disponibles';

  @override
  String get adminCenterConnectionTryAgainMessage => 'Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get adminCenterNoAdminReportsTitle => 'No hay denuncias pendientes de decisión administrativa';

  @override
  String get adminCenterNoReportsTitle => 'No hay denuncias';

  @override
  String get adminCenterNoAdminReportsMessage => 'No hay denuncias escaladas que requieran revisión de un administrador.';

  @override
  String get adminCenterNoReportsMessage => 'No hay denuncias que coincidan con los filtros seleccionados.';

  @override
  String get adminCenterSearchUsersHint => 'Buscar por nombre, usuario, correo o ID';

  @override
  String get adminCenterClearSearchTooltip => 'Borrar búsqueda';

  @override
  String get adminCenterUsersUnavailableTitle => 'Usuarios no disponibles';

  @override
  String get adminCenterNoUsersFoundTitle => 'No se encontraron usuarios';

  @override
  String get adminCenterNoUsersTitle => 'No hay usuarios';

  @override
  String get adminCenterNoUsersFoundMessage => 'Prueba con otro nombre, usuario, correo o ID.';

  @override
  String get adminCenterNoUsersMessage => 'No hay cuentas que mostrar.';

  @override
  String get adminCenterAccountUnavailableTitle => 'Cuenta no disponible';

  @override
  String get adminCenterBackToUsersAction => 'Volver a usuarios';

  @override
  String get adminCenterPublicIdentitySection => 'Identidad pública';

  @override
  String get adminCenterDisplayNameLabel => 'Nombre para mostrar';

  @override
  String get adminCenterNotProvided => 'No proporcionado';

  @override
  String get adminCenterUsernameLabel => 'Nombre de usuario';

  @override
  String get adminCenterUserIdLabel => 'ID de usuario';

  @override
  String get adminCenterIdentityTypeLabel => 'Tipo de identidad';

  @override
  String get adminCenterAccountSection => 'Cuenta';

  @override
  String get adminCenterTechnicalRoleLabel => 'Rol técnico';

  @override
  String get adminCenterRoleMirrorLabel => 'Reflejo del rol en el perfil';

  @override
  String get adminCenterRoleSynchronizationLabel => 'Sincronización de roles';

  @override
  String get adminCenterSynchronized => 'Sincronizado';

  @override
  String get adminCenterNotSynchronized => 'No sincronizado';

  @override
  String get adminCenterRoleNotSynchronized => 'Rol no sincronizado';

  @override
  String get adminCenterAccountStatusLabel => 'Estado de la cuenta';

  @override
  String get adminCenterSuspendedUntilLabel => 'Suspendida hasta';

  @override
  String get adminCenterAccountManagementSection => 'Gestión de la cuenta';

  @override
  String get adminCenterDangerZoneSection => 'Zona de peligro';

  @override
  String get adminCenterRoleManagementSection => 'Gestión de roles';

  @override
  String get adminCenterVerificationLevelLabel => 'Nivel de verificación';

  @override
  String get adminCenterVerificationStatusLabel => 'Estado de verificación';

  @override
  String get adminCenterAccessInformationSection => 'Información de acceso';

  @override
  String get adminCenterEmailLabel => 'Correo electrónico';

  @override
  String get adminCenterNotAvailable => 'No disponible';

  @override
  String get adminCenterEmailConfirmationLabel => 'Confirmación del correo';

  @override
  String get adminCenterNotConfirmed => 'No confirmado';

  @override
  String get adminCenterRegisteredLabel => 'Registrado';

  @override
  String get adminCenterLastAccessLabel => 'Último acceso';

  @override
  String get adminCenterLoadingDashboardTitle => 'Cargando panel';

  @override
  String get adminCenterLoadingDashboardMessage => 'Obteniendo los indicadores más recientes.';

  @override
  String get adminCenterDashboardUnavailableTitle => 'Panel no disponible';

  @override
  String get adminCenterIndicatorsUnavailableMessage => 'No se pudieron cargar los indicadores.';

  @override
  String get adminCenterVerificationPendingIndicator => 'Verificaciones pendientes';

  @override
  String get adminCenterOpenReportsIndicator => 'Denuncias abiertas';

  @override
  String get adminCenterSuspendedAccountsIndicator => 'Cuentas suspendidas';

  @override
  String get adminCenterStaffIndicator => 'Personal';

  @override
  String get adminCenterNoPendingWorkTitle => 'No hay trabajo pendiente';

  @override
  String get adminCenterNoPendingWorkMessage => 'No hay verificaciones, denuncias ni cuentas suspendidas pendientes.';

  @override
  String get adminCenterCouldNotUpdateUsers => 'No se pudo actualizar la lista de usuarios.';

  @override
  String get adminCenterCouldNotUpdateReports => 'No se pudo actualizar la cola de denuncias.';

  @override
  String get adminCenterUnnamedUser => 'Usuario sin nombre';

  @override
  String get adminCenterTemporarySuspensionTitle => 'Suspensión temporal';

  @override
  String get adminCenterReactivateDescription => 'Quita la suspensión inmediatamente y permite un nuevo inicio de sesión.';

  @override
  String get adminCenterSuspendDescription => 'Bloquea el acceso durante un tiempo limitado y finaliza todas las sesiones actuales.';

  @override
  String get adminCenterSuspensionUnavailableDescription => 'La suspensión requiere una cuenta sincronizada que no sea de administrador.';

  @override
  String get adminCenterReactivateAccountAction => 'Reactivar cuenta';

  @override
  String get adminCenterSuspendAccountAction => 'Suspender cuenta';

  @override
  String get adminCenterForceLogoutAction => 'Forzar cierre de sesión';

  @override
  String get adminCenterSuspendedForceLogoutDescription => 'La suspensión ya ha finalizado las sesiones actuales. Reactiva la cuenta antes de probar un cierre de sesión independiente.';

  @override
  String get adminCenterForceLogoutDescription => 'Finaliza todas las sesiones actuales sin suspender la cuenta.';

  @override
  String get adminCenterForceLogoutUnavailableDescription => 'El cierre de sesión forzado requiere una cuenta sincronizada que no sea de administrador.';

  @override
  String get adminCenterPermanentDeletionTitle => 'Eliminación permanente de la cuenta';

  @override
  String get adminCenterPermanentDeletionDescription => 'Elimina los datos de autenticación, finaliza todas las sesiones y anonimiza el registro público conservado.';

  @override
  String get adminCenterDeletionUnavailableDescription => 'La eliminación requiere una cuenta sincronizada que no sea de administrador.';

  @override
  String get adminCenterDeleteAccountPermanentlyAction => 'Eliminar cuenta permanentemente';

  @override
  String get adminCenterDurationOneHour => '1 hora';

  @override
  String get adminCenterDurationOneDay => '24 horas';

  @override
  String get adminCenterDurationSevenDays => '7 días';

  @override
  String get adminCenterDurationThirtyDays => '30 días';

  @override
  String get adminCenterSuspendImmediateEffect => 'La cuenta perderá el acceso inmediatamente y todas las sesiones actuales finalizarán.';

  @override
  String get adminCenterDurationLabel => 'Duración';

  @override
  String get adminCenterSuspendReasonHint => 'Explica por qué debe suspenderse esta cuenta';

  @override
  String get adminCenterReactivateReasonHint => 'Explica por qué puede reactivarse esta cuenta';

  @override
  String get adminCenterReactivateConfirmation => 'Confirmo que esta cuenta puede recuperar el acceso.';

  @override
  String get adminCenterReactivateFailure => 'No se pudo reactivar la cuenta. Comprueba su rol y estado e inténtalo de nuevo.';

  @override
  String get adminCenterReactivateSuccess => 'Cuenta reactivada. Ya se permite un nuevo inicio de sesión.';

  @override
  String get adminCenterForceLogoutFullDescription => 'Finaliza todas las sesiones actuales de esta cuenta. La cuenta permanece activa y puede volver a iniciar sesión.';

  @override
  String get adminCenterForceLogoutReasonHint => 'Explica por qué deben finalizarse las sesiones actuales';

  @override
  String get adminCenterForceLogoutConfirmation => 'Confirmo la finalización inmediata de todas las sesiones actuales de esta cuenta.';

  @override
  String get adminCenterForceLogoutFailure => 'No se pudo cerrar la sesión de la cuenta. Comprueba su rol y estado e inténtalo de nuevo.';

  @override
  String get adminCenterForceLogoutSuccess => 'Sesiones actuales finalizadas. La cuenta puede volver a iniciar sesión.';

  @override
  String get adminCenterSuspendFailure => 'No se pudo suspender la cuenta. Comprueba su rol y estado e inténtalo de nuevo.';

  @override
  String get adminCenterDeleteReasonHint => 'Explica por qué debe eliminarse esta cuenta';

  @override
  String get adminCenterTypeDeleteLabel => 'Escribe DELETE';

  @override
  String get adminCenterTypeAccountIdLabel => 'Escribe el ID completo de la cuenta';

  @override
  String get adminCenterDeletePermanentlyAction => 'Eliminar permanentemente';

  @override
  String get adminCenterDeleteIrreversibleWarning => 'Esta acción es irreversible. Se eliminarán los datos de autenticación y las sesiones actuales, se borrará el avatar y se anonimizará el registro público conservado. El registro de auditoría permanecerá.';

  @override
  String get adminCenterDeleteFailure => 'No se pudo eliminar la cuenta. Comprueba su rol, estado y valores de confirmación e inténtalo de nuevo.';

  @override
  String get adminCenterDeleteSuccess => 'Cuenta eliminada permanentemente y datos personales anonimizados.';

  @override
  String get adminCenterChangeTechnicalRoleTitle => 'Cambiar rol técnico';

  @override
  String get adminCenterChangeRoleDescription => 'Revisa el rol actual y el solicitado antes de confirmar.';

  @override
  String get adminCenterChangeRoleUnavailableDescription => 'Los cambios de rol requieren una cuenta sincronizada y no eliminada.';

  @override
  String get adminCenterChangeRoleAction => 'Cambiar rol';

  @override
  String get adminCenterChangePublicIdentityTitle => 'Cambiar identidad pública';

  @override
  String get adminCenterChangeIdentityDescription => 'Actualiza el tipo de cuenta pública y el nivel de verificación.';

  @override
  String get adminCenterChangeIdentityUnavailableDescription => 'Los cambios de identidad requieren una cuenta sincronizada que no sea de administrador.';

  @override
  String get adminCenterChangeIdentityAction => 'Cambiar identidad';

  @override
  String get adminCenterChoosePublicIdentityMessage => 'Elige el tipo de cuenta pública y su estado de verificación.';

  @override
  String get adminCenterPublicAccountTypeLabel => 'Tipo de cuenta pública';

  @override
  String get adminCenterPersonVerificationHelper => 'Nivel 1 y Nivel 2 solo están disponibles para Persona.';

  @override
  String get adminCenterNonPersonVerificationHelper => 'Las cuentas que no son Persona no utilizan Nivel 1 ni Nivel 2.';

  @override
  String get adminCenterBeforeLabel => 'Antes';

  @override
  String get adminCenterAfterLabel => 'Después';

  @override
  String get adminCenterIdentityReasonHint => 'Explica por qué debe cambiar la identidad pública';

  @override
  String get adminCenterIdentityConfirmation => 'Confirmo la identidad pública y el nivel de verificación mostrados arriba.';

  @override
  String get adminCenterIdentityChangeFailure => 'No se pudo cambiar la identidad pública. Comprueba el estado de la cuenta e inténtalo de nuevo.';

  @override
  String get adminCenterChooseTechnicalRoleMessage => 'Elige el nuevo rol técnico y registra por qué es necesario este cambio.';

  @override
  String get adminCenterNewTechnicalRoleLabel => 'Nuevo rol técnico';

  @override
  String get adminCenterSelectRole => 'Seleccionar un rol';

  @override
  String get adminCenterRoleSessionWarning => 'Este cambio finaliza la sesión activa del destinatario. Debe volver a iniciar sesión antes de seguir usando la cuenta.';

  @override
  String get adminCenterRoleReasonHint => 'Explica por qué debe cambiar el rol técnico';

  @override
  String get adminCenterRoleConfirmation => 'Confirmo el rol mostrado arriba y entiendo que el destinatario debe volver a iniciar sesión.';

  @override
  String get adminCenterRoleChangeFailure => 'No se pudo completar el cambio de rol. Comprueba el estado de la cuenta e inténtalo de nuevo.';

  @override
  String get adminCenterChangingRole => 'Cambiando rol';

  @override
  String get adminCenterConfirmRoleChange => 'Confirmar cambio de rol';

  @override
  String get adminCenterRoleUser => 'Usuario';

  @override
  String get adminCenterRoleModerator => 'Moderador';

  @override
  String get adminCenterRoleAdmin => 'Administrador';

  @override
  String get adminCenterAccountStatusActive => 'Activa';

  @override
  String get adminCenterAccountStatusSuspended => 'Suspendida';

  @override
  String get adminCenterAccountStatusDeleted => 'Eliminada';

  @override
  String get adminCenterVerificationStatusNone => 'Ninguno';

  @override
  String get adminCenterVerificationStatusPending => 'Pendiente';

  @override
  String get adminCenterVerificationStatusRejected => 'Rechazada';

  @override
  String get adminCenterVerificationNotVerified => 'No verificado';

  @override
  String get adminCenterVerificationLevel1 => 'Nivel 1';

  @override
  String get adminCenterVerificationLevel2 => 'Nivel 2';

  @override
  String get adminCenterReportSingular => 'denuncia';

  @override
  String get adminCenterReportPlural => 'denuncias';

  @override
  String get adminCenterUserSingular => 'usuario';

  @override
  String get adminCenterUserPlural => 'usuarios';

  @override
  String get adminCenterPoll => 'Vote';

  @override
  String get adminCenterPost => 'Voce';

  @override
  String get adminCenterUnknown => 'Desconocido';

  @override
  String get adminCenterContentHidden => 'Contenido oculto';

  @override
  String get adminCenterContentVisible => 'Contenido visible';

  @override
  String get adminCenterReportedByLabel => 'Denunciado por';

  @override
  String get adminCenterContentOwnerLabel => 'Propietario del contenido';

  @override
  String get adminCenterReviewReportAction => 'Revisar denuncia';

  @override
  String get adminCenterAdminDecisionAction => 'Decisión del administrador';

  @override
  String get adminCenterRestoreContentAction => 'Restaurar contenido';

  @override
  String get adminCenterHideContentAction => 'Ocultar contenido';

  @override
  String get adminCenterOpenProfileAction => 'Abrir perfil';

  @override
  String get adminCenterOpenContentAction => 'Abrir contenido';

  @override
  String get adminCenterDecisionNoViolation => 'Sin infracción';

  @override
  String get adminCenterDecisionViolationConfirmed => 'Infracción confirmada';

  @override
  String get adminCenterDecisionEscalateToAdmin => 'Escalar al administrador';

  @override
  String get adminCenterResolutionNoAccountAction => 'Sin acción sobre la cuenta';

  @override
  String get adminCenterResolutionAccountSuspended => 'Cuenta suspendida';

  @override
  String get adminCenterResolutionLogoutForced => 'Cierre de sesión forzado';

  @override
  String get adminCenterResolutionAccountDeleted => 'Cuenta eliminada';

  @override
  String get adminCenterReviewerLabel => 'Revisor';

  @override
  String get adminCenterDecisionDescriptionNoViolation => 'Descarta la denuncia porque el contenido no infringe las reglas actuales.';

  @override
  String get adminCenterDecisionDescriptionViolation => 'Confirma una infracción y mantiene el caso en revisión para la acción sobre el contenido gestionada en AC8.5.';

  @override
  String get adminCenterDecisionDescriptionEscalation => 'Escala el caso para una revisión del administrador a nivel de cuenta.';

  @override
  String get adminCenterChooseModerationOutcome => 'Elige el resultado de moderación para esta denuncia.';

  @override
  String get adminCenterDecisionAlreadyRecordedFailure => 'No se pudo registrar la decisión. Puede que la denuncia ya haya sido revisada. Actualiza la cola e inténtalo de nuevo.';

  @override
  String get adminCenterDecisionLabel => 'Decisión';

  @override
  String get adminCenterReportReasonLabel => 'Motivo de la denuncia';

  @override
  String get adminCenterReviewNoteLabel => 'Nota de revisión';

  @override
  String get adminCenterReviewNoteHint => 'Explica las pruebas y la decisión de moderación';

  @override
  String get adminCenterRecordingDecision => 'Registrando decisión';

  @override
  String get adminCenterConfirmDecision => 'Confirmar decisión';

  @override
  String get adminCenterAdministratorDecisionTitle => 'Decisión del administrador';

  @override
  String get adminCenterResolutionDescriptionNoAction => 'Cierra la denuncia escalada sin cambiar la cuenta.';

  @override
  String get adminCenterResolutionDescriptionSuspended => 'Cierra la denuncia después de que una suspensión correcta de la cuenta ya se haya registrado en el log de auditoría.';

  @override
  String get adminCenterResolutionDescriptionLogout => 'Cierra la denuncia después de que un cierre de sesión forzado correcto ya se haya registrado en el log de auditoría.';

  @override
  String get adminCenterResolutionDescriptionDeleted => 'Cierra la denuncia después de que una eliminación correcta de la cuenta ya se haya registrado en el log de auditoría.';

  @override
  String get adminCenterChooseFinalOutcome => 'Elige el resultado final del administrador para este escalamiento.';

  @override
  String get adminCenterAdminResolutionFailure => 'No se pudo registrar la decisión del administrador. Actualiza la cola e inténtalo de nuevo.';

  @override
  String get adminCenterAdminResolutionRequiresAction => 'Completa primero la acción correspondiente sobre la cuenta; después vuelve a esta denuncia y registra la decisión final del administrador.';

  @override
  String get adminCenterEscalationNoteLabel => 'Nota de escalamiento';

  @override
  String get adminCenterFinalOutcomeLabel => 'Resultado final';

  @override
  String get adminCenterAdministratorNoteLabel => 'Nota del administrador';

  @override
  String get adminCenterAdministratorNoteHint => 'Explica la decisión final a nivel de cuenta';

  @override
  String get adminCenterHideContentFailure => 'No se pudo ocultar el contenido. Actualiza la cola de denuncias e inténtalo de nuevo.';

  @override
  String get adminCenterRestoreContentFailure => 'No se pudo restaurar el contenido. Actualiza la cola de denuncias e inténtalo de nuevo.';

  @override
  String get adminCenterHideContentWarning => 'Esto elimina el contenido denunciado del acceso público. La acción puede revertirse más adelante desde el filtro de denuncias resueltas.';

  @override
  String get adminCenterRestoreContentWarning => 'Esto vuelve a hacer público el contenido denunciado.';

  @override
  String get adminCenterActionReasonLabel => 'Motivo de la acción';

  @override
  String get adminCenterHideContentReasonHint => 'Explica por qué debe ocultarse el contenido';

  @override
  String get adminCenterRestoreContentReasonHint => 'Explica por qué puede restaurarse el contenido';

  @override
  String get adminCenterHidingContent => 'Ocultando contenido';

  @override
  String get adminCenterRestoringContent => 'Restaurando contenido';

  @override
  String get adminCenterReportedProfileTitle => 'Perfil denunciado';

  @override
  String get adminCenterReportedProfileNotice => 'Este contexto del perfil procede de la cola protegida de denuncias. Las acciones administrativas sobre la cuenta siguen estando separadas.';

  @override
  String get adminCenterCouldNotRefreshIndicators => 'No se pudieron actualizar los indicadores.';

  @override
  String get adminCenterCouldNotRefreshAccount => 'No se pudieron actualizar los detalles de la cuenta.';

  @override
  String get adminCenterReportAlreadyReviewed => 'Esta denuncia ya ha sido revisada o ya no está pendiente.';

  @override
  String get adminCenterReportNotAwaitingAdmin => 'Esta denuncia no está esperando una decisión del administrador.';

  @override
  String get adminCenterConfirmedViolationRequired => 'Se requiere una infracción confirmada antes de cambiar la visibilidad del contenido.';

  @override
  String get adminCenterContentHiddenSuccess => 'El contenido denunciado se ha ocultado.';

  @override
  String get adminCenterContentRestoredSuccess => 'El contenido denunciado se ha restaurado.';

  @override
  String get adminCenterMissingContentId => 'Falta el identificador original del contenido.';

  @override
  String get adminCenterUnsupportedTargetType => 'Esta denuncia tiene un tipo de objetivo no compatible.';

  @override
  String get adminCenterOriginalContentUnavailable => 'El contenido original ya no está disponible.';

  @override
  String get adminCenterNoReportedProfile => 'No hay ningún perfil denunciado asociado a este contenido.';

  @override
  String adminCenterRoleChangedSuccess(String previousRole, String newRole) {
    return 'Rol técnico cambiado de $previousRole a $newRole. Se cerró la sesión del destinatario y debe volver a iniciar sesión.';
  }

  @override
  String adminCenterIdentityChangedSuccess(String actorType, String verificationLevel) {
    return 'Identidad pública cambiada a $actorType con $verificationLevel.';
  }

  @override
  String adminCenterAccountSuspendedSuccess(String dateTime) {
    return 'Cuenta suspendida hasta $dateTime. Se cerró la sesión del destinatario.';
  }

  @override
  String adminCenterReportDecisionRecorded(String decision) {
    return 'Decisión sobre la denuncia registrada: $decision.';
  }

  @override
  String adminCenterAdministratorDecisionRecorded(String decision) {
    return 'Decisión del administrador registrada: $decision.';
  }

  @override
  String adminCenterUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count usuarios',
      one: '$count usuario',
    );
    return '$_temp0';
  }

  @override
  String adminCenterReportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count denuncias',
      one: '$count denuncia',
    );
    return '$_temp0';
  }

  @override
  String adminCenterAccountValue(String account) {
    return 'Cuenta: $account';
  }

  @override
  String adminCenterSuspendedUntilValue(String dateTime) {
    return 'Suspendida hasta: $dateTime';
  }

  @override
  String adminCenterSuspendConfirmation(String dateTime) {
    return 'Confirmo la suspensión hasta $dateTime y la finalización inmediata de las sesiones actuales.';
  }

  @override
  String adminCenterAccountIdValue(String accountId) {
    return 'ID de cuenta: $accountId';
  }

  @override
  String adminCenterCurrentRoleValue(String role) {
    return 'Actual: $role';
  }

  @override
  String adminCenterTargetFallback(String targetType, String targetId) {
    return '$targetType $targetId';
  }

  @override
  String adminCenterMinimumCharactersRequired(int count) {
    return 'Se requiere una nota de al menos $count caracteres.';
  }

  @override
  String adminCenterMinimumReasonCharactersRequired(int count) {
    return 'Se requiere un motivo de al menos $count caracteres.';
  }

  @override
  String adminCenterPageOf(int currentPage, int totalPages) {
    return 'Página $currentPage de $totalPages';
  }

  @override
  String get profilePublicProfileSectionTitle => 'Perfil público';

  @override
  String get profileIdentityVerificationSectionTitle => 'Identidad y verificación';

  @override
  String get profilePreferencesSectionTitle => 'Preferencias';

  @override
  String get profileNotificationsSectionTitle => 'Notificaciones';

  @override
  String get profileActivitySectionTitle => 'Actividad personal';

  @override
  String get profileSecurityAccountSectionTitle => 'Seguridad y cuenta';

  @override
  String get profileThemeTitle => 'Tema';

  @override
  String get profileThemeSystem => 'Sistema';

  @override
  String get profileThemeSystemDescription => 'Sigue el tema del dispositivo';

  @override
  String get profileThemeLight => 'Claro';

  @override
  String get profileThemeDark => 'Oscuro';

  @override
  String get profileMyPollsTitle => 'Vote';

  @override
  String get profileMyPostsTitle => 'Voce';

  @override
  String get profileMyCommentsTitle => 'Mis comentarios';

  @override
  String get profileMyFavoritesTitle => 'Mis guardados';

  @override
  String get profileAccountConnectionsTitle => 'Seguidos y seguidores';

  @override
  String get accountConnectionsFollowingTab => 'Siguiendo';

  @override
  String get accountConnectionsFollowersTab => 'Seguidores';

  @override
  String get accountConnectionsEmptyFollowing => 'Todavía no sigues ninguna cuenta.';

  @override
  String get accountConnectionsEmptyFollowers => 'Todavía no tienes seguidores.';

  @override
  String get accountConnectionsLoadError => 'No se pueden cargar las cuentas. Inténtalo de nuevo.';

  @override
  String get profileMyFollowedScopesTitle => 'Mis zonas seguidas';

  @override
  String get profileLogoutAction => 'Cerrar sesión';

  @override
  String get profileLogoutDescription => 'Cerrar la sesión de la cuenta actual';

  @override
  String get profileLogoutDialogTitle => 'Cerrar sesión';

  @override
  String get profileLogoutDialogMessage => '¿Seguro que quieres cerrar la sesión de tu cuenta?';

  @override
  String get profileLogoutCancelButton => 'Cancelar';

  @override
  String get profileLogoutConfirmButton => 'Cerrar sesión';

  @override
  String get publicProfilePageTitle => 'Perfil público';

  @override
  String get publicProfileUserFallback => 'Usuario';

  @override
  String get publicProfileNoBio => 'No hay biografía disponible.';

  @override
  String get publicProfileResidenceLabel => 'Residencia';

  @override
  String get publicProfileResidenceUnknown => 'No especificada';

  @override
  String get publicProfileMemberSinceLabel => 'Miembro desde';

  @override
  String get publicProfileContentSectionTitle => 'Contenido público';

  @override
  String get publicProfilePollsAction => 'Vote';

  @override
  String get publicProfilePostsAction => 'Voce';

  @override
  String get publicProfileBlockUserAction => 'Bloquear usuario';

  @override
  String get publicProfileLoadError => 'No se puede cargar el perfil.';

  @override
  String get publicProfileNotFound => 'Perfil no disponible.';

  @override
  String get publicProfileUnblockUserAction => 'Desbloquear usuario';

  @override
  String get publicProfileBlockDialogTitle => '¿Bloquear a este usuario?';

  @override
  String get publicProfileBlockDialogMessage => 'Podrás desbloquearlo más tarde desde su perfil público.';

  @override
  String get publicProfileUnblockDialogTitle => '¿Desbloquear a este usuario?';

  @override
  String get publicProfileUnblockDialogMessage => 'El usuario dejará de estar en tu lista de bloqueados.';

  @override
  String get publicProfileBlockSuccess => 'Usuario bloqueado.';

  @override
  String get publicProfileUnblockSuccess => 'Usuario desbloqueado.';

  @override
  String get publicProfileBlockError => 'No se pudo actualizar el bloqueo. Inténtalo de nuevo.';

  @override
  String get publicProfileFollowersLabel => 'seguidores';

  @override
  String get publicProfileFollowingLabel => 'siguiendo';

  @override
  String get publicProfileFollowAction => 'Seguir';

  @override
  String get publicProfileUnfollowAction => 'Dejar de seguir';

  @override
  String get publicProfileFollowSuccess => 'Cuenta seguida.';

  @override
  String get publicProfileUnfollowSuccess => 'Has dejado de seguir la cuenta.';

  @override
  String get publicProfileFollowError => 'No se pudo actualizar el seguimiento. Inténtalo de nuevo.';

  @override
  String get publicProfileFollowRetry => 'Volver a cargar la información de seguimiento';

  @override
  String get contentLanguageFieldLabel => 'Idioma del contenido';

  @override
  String get contentLanguageFieldHelper => 'Selecciona el idioma en el que escribiste el contenido.';

  @override
  String get contentLanguageUndetermined => 'No especificado';

  @override
  String get createPollAdvancedOptionsTitle => 'Opciones avanzadas';

  @override
  String get createPollAdvancedOptionsSubtitle => 'Anonimato, visibilidad de resultados, cambios de voto y cuórum.';

  @override
  String get onboardingSkipButton => 'Omitir';

  @override
  String get onboardingNextButton => 'Siguiente';

  @override
  String get onboardingStartButton => 'Empezar';

  @override
  String get onboardingPollTitle => 'Vote';

  @override
  String get onboardingPollDescription => 'Participa en un Vote sobre temas que te importan o crea uno para recoger la opinión de la comunidad.';

  @override
  String get onboardingHeatIceTitle => 'Heat e Ice';

  @override
  String get onboardingHeatIceDescription => 'Usa Heat e Ice para mostrar con qué intensidad un contenido está atrayendo tu interés.';

  @override
  String get onboardingCivicMapTitle => 'Mapa Cívico';

  @override
  String get onboardingCivicMapDescription => 'Explora Vote, Voce y News en el mapa y descubre qué está ocurriendo en distintas zonas.';

  @override
  String get onboardingGeoScopeTitle => 'GeoScope';

  @override
  String get onboardingGeoScopeDescription => 'Elige el nivel geográfico que quieres seguir: mundo, país o ciudad.';

  @override
  String get onboardingVerificationTitle => 'Verificación de identidad';

  @override
  String get onboardingVerificationDescription => 'Algunos Vote pueden exigir un nivel de verificación para proteger la integridad de la votación.';

  @override
  String get pollDetail_voteReceiptButton => 'Comprobante de voto';

  @override
  String get pollDetail_voteReceiptTitle => 'Comprobante de voto';

  @override
  String get pollDetail_voteReceiptIdLabel => 'ID del comprobante';

  @override
  String get pollDetail_voteReceiptDateLabel => 'Registrado';

  @override
  String get pollDetail_voteReceiptPrivacy => 'Este comprobante confirma que tu voto fue registrado sin mostrar la opción que elegiste.';

  @override
  String get pollDetail_voteReceiptCloseButton => 'Cerrar';

  @override
  String get profileBiometricUnlockTitle => 'Desbloqueo biométrico';

  @override
  String get profileBiometricUnlockDescription => 'Protege tu sesión recordada con la huella digital o el reconocimiento biométrico del dispositivo.';

  @override
  String get profileBiometricRequiresRememberMe => 'Requiere que Recordarme esté activado.';

  @override
  String get profileBiometricUnavailable => 'La biometría no está disponible o no está configurada en este dispositivo.';

  @override
  String get profileBiometricEnableReason => 'Confirma tu biometría para activar el desbloqueo de Social Vote.';

  @override
  String get profileBiometricEnabledMessage => 'Desbloqueo biométrico activado.';

  @override
  String get profileBiometricDisabledMessage => 'Desbloqueo biométrico desactivado.';

  @override
  String get profileBiometricAuthFailedMessage => 'La autenticación biométrica no se completó.';

  @override
  String get biometricLockTitle => 'Social Vote está bloqueado';

  @override
  String get biometricLockMessage => 'Usa la biometría de tu dispositivo para desbloquear la sesión recordada.';

  @override
  String get biometricUnlockButton => 'Desbloquear';

  @override
  String get biometricUsePasswordButton => 'Usar contraseña';

  @override
  String get biometricUnlockReason => 'Desbloquea tu sesión de Social Vote.';

  @override
  String get biometricUnlockFailedMessage => 'El desbloqueo ha fallado. Inténtalo de nuevo o usa tu contraseña.';

  @override
  String get adminCenterOperationalActivityTitle => 'Actividad operativa';

  @override
  String get adminCenterOperationalActivitySubtitle => 'Contadores agregados. Sin seguimiento de presencia en línea en tiempo real.';

  @override
  String get adminCenterLast24HoursLabel => '24 horas';

  @override
  String get adminCenterLast7DaysLabel => '7 días';

  @override
  String get adminCenterNewUsersMetric => 'Nuevos registros';

  @override
  String get adminCenterRecentSignInsMetric => 'Inicios de sesión recientes';

  @override
  String get adminCenterPollsCreatedMetric => 'Vote creados';

  @override
  String get adminCenterPostsCreatedMetric => 'Voce creados';

  @override
  String get adminCenterAdminActionsMetric => 'Acciones de administrador';

  @override
  String get authPublicNameHelper => 'Este es el nombre que verán otros usuarios. Tu nombre de usuario se crea automáticamente.';

  @override
  String get adminCenterRefreshMarkersTooltip => 'Actualizar marcadores del globo';

  @override
  String get adminCenterMarkerDensityTitle => 'Densidad de marcadores del mundo';

  @override
  String get adminCenterMarkerDensitySubtitle => 'Controla el presupuesto visual de marcadores del Globo de Inicio sin cambiar las coordenadas reales ni la clasificación del contenido.';

  @override
  String get adminCenterMarkerDensityEmpty => 'Vacío';

  @override
  String get adminCenterMarkerDensityFull => 'Completo';

  @override
  String adminCenterMarkerDensityBudget(int count) {
    return 'Límite de Inicio: $count marcadores';
  }

  @override
  String get adminCenterMarkerDensitySaveError => 'No se puede guardar la densidad de marcadores del mundo.';

  @override
  String get adminCenterMarkerDensityBackendUnavailable => 'La configuración backend de marcadores del mundo aún no está disponible.';

  @override
  String get adminCenterQuickActionsTitle => 'Acciones rápidas de cuenta';

  @override
  String get adminCenterModerationSnapshotTitle => 'Resumen de moderación y actividad';

  @override
  String get adminCenterReportsReceivedMetric => 'Denuncias recibidas';

  @override
  String get adminCenterPendingReportsMetric => 'Denuncias pendientes';

  @override
  String get adminCenterConfirmedViolationsMetric => 'Infracciones confirmadas';

  @override
  String get adminCenterReportsFiledMetric => 'Denuncias presentadas';

  @override
  String get adminCenterCommentsCreatedMetric => 'Comentarios creados';

  @override
  String get adminCenterAdminActionsOnAccountMetric => 'Acciones de administrador sobre la cuenta';

  @override
  String get adminCenterLastReportReceivedLabel => 'Última denuncia recibida';

  @override
  String get adminCenterOpenFullAccountAction => 'Abrir controles completos de la cuenta';

  @override
  String get profileAppLanguageGerman => 'Alemán';

  @override
  String get profileAppLanguagePersian => 'Persa';

  @override
  String get discoveryPageTitle => 'Explorar';

  @override
  String get organizationWorkspaceTitle => 'Workspace de la organización';

  @override
  String get organizationPilotBannerTitle => 'Piloto gratuito';

  @override
  String get organizationPilotBannerBody => 'Las Sessions son gratuitas durante el piloto. Algunas funciones profesionales podrían pasar a ser de pago en el futuro; la facturación no está activa ahora.';

  @override
  String get organizationVerifiedLabel => 'Organización verificada';

  @override
  String get organizationEditProfile => 'Editar perfil de la organización';

  @override
  String get organizationCreateSession => 'Nueva Session';

  @override
  String get organizationNoSessions => 'Todavía no hay Sessions. Crea la primera para una reunión, taller o evento.';

  @override
  String get organizationSessionsTitle => 'Sessions en directo';

  @override
  String get organizationRequiresVerificationTitle => 'Se requiere una organización verificada';

  @override
  String get organizationRequiresVerificationBody => 'Este Workspace solo está disponible para cuentas aprobadas por Social Vote como organización verificada.';

  @override
  String get organizationProfileEditorTitle => 'Perfil de la organización';

  @override
  String get organizationLegalName => 'Nombre legal';

  @override
  String get organizationPublicName => 'Nombre público';

  @override
  String get organizationType => 'Tipo de organización';

  @override
  String get organizationCountryCode => 'Código de país';

  @override
  String get organizationCity => 'Ciudad';

  @override
  String get organizationWebsite => 'Sitio web oficial';

  @override
  String get organizationDescription => 'Descripción';

  @override
  String get organizationUploadCover => 'Cambiar portada';

  @override
  String get organizationUploadLogo => 'Cambiar logo';

  @override
  String get organizationMediaUpdated => 'Imagen de la organización actualizada.';

  @override
  String get organizationNamesRequired => 'El nombre legal y el nombre público son obligatorios.';

  @override
  String get organizationTypeAssociation => 'Asociación';

  @override
  String get organizationTypeNonprofit => 'Sin ánimo de lucro';

  @override
  String get organizationTypeCompany => 'Empresa';

  @override
  String get organizationTypeCooperative => 'Cooperativa';

  @override
  String get organizationTypeSports => 'Organización deportiva';

  @override
  String get organizationTypePublicBody => 'Organismo público';

  @override
  String get organizationTypeCommittee => 'Comité / grupo';

  @override
  String get organizationTypeOther => 'Otro';

  @override
  String get sessionCreateTitle => 'Crear Live Session';

  @override
  String get sessionTitleLabel => 'Título de la Session';

  @override
  String get sessionExpectedParticipants => 'Participantes previstos';

  @override
  String get sessionAccessMode => 'Acceso de participantes';

  @override
  String get sessionAccessOpen => 'Anónimo abierto';

  @override
  String get sessionAccessOpenHint => 'Cualquier persona con el enlace/código puede unirse. La prevención de duplicados se realiza con el mejor esfuerzo; este modo no garantiza una persona-un voto.';

  @override
  String get sessionAccessControlled => 'Anónimo controlado';

  @override
  String get sessionAccessControlledHint => 'Usa Access Pass anónimos de un solo uso. Social Vote almacena únicamente el hash del Access Pass y no vincula las opciones de voto con las credenciales de los participantes.';

  @override
  String get sessionResultsVisibility => 'Visibilidad de resultados';

  @override
  String get sessionResultsLive => 'En directo';

  @override
  String get sessionResultsAfterVote => 'Después de que el participante vote';

  @override
  String get sessionResultsAfterClose => 'Después de cerrar la pregunta';

  @override
  String get sessionResultsOrganizerOnly => 'Solo organizador';

  @override
  String get sessionCreateAction => 'Crear Session';

  @override
  String get sessionPilotLimit => 'Límite del piloto: de 1 a 250 participantes por Session.';

  @override
  String get sessionStatusDraft => 'Borrador';

  @override
  String get sessionStatusOpen => 'Abierta';

  @override
  String get sessionStatusClosed => 'Cerrada';

  @override
  String get sessionJoinCode => 'Código de acceso';

  @override
  String get sessionShareJoin => 'Compartir enlace de acceso';

  @override
  String get sessionCopyJoinLink => 'Copiar enlace';

  @override
  String get sessionGenerateTokens => 'Generar Access Pass';

  @override
  String get sessionGenerateTokensCount => 'Número de Access Pass';

  @override
  String get sessionTokensOneTimeTitle => 'Guarda estas credenciales ahora';

  @override
  String get sessionTokensOneTimeBody => 'Los Access Pass en texto plano solo se muestran en el resultado de este lote. Social Vote almacena únicamente sus hashes. Cópialos y distribúyelos de forma segura.';

  @override
  String get sessionCopyTokens => 'Copiar todos los enlaces';

  @override
  String get sessionTokensSavedAction => 'Los he guardado';

  @override
  String get sessionOpenAction => 'Abrir Session';

  @override
  String get sessionCloseAction => 'Cerrar Session';

  @override
  String get sessionCloseConfirm => '¿Cerrar la votación y crear la instantánea inmutable de Verified Result?';

  @override
  String get sessionQuestionsTitle => 'Preguntas';

  @override
  String get sessionAddQuestion => 'Añadir pregunta';

  @override
  String get sessionQuestionTitle => 'Pregunta';

  @override
  String get sessionQuestionType => 'Tipo de pregunta';

  @override
  String get sessionTypeYesNo => 'Sí / No';

  @override
  String get sessionTypeSingle => 'Elección única';

  @override
  String get sessionTypeMultiple => 'Elección múltiple';

  @override
  String get sessionOptions => 'Opciones';

  @override
  String get sessionOptionHint => 'Una opción por línea.';

  @override
  String get sessionMinSelections => 'Selecciones mínimas';

  @override
  String get sessionMaxSelections => 'Selecciones máximas';

  @override
  String get sessionAddAction => 'Añadir';

  @override
  String get sessionOpenQuestion => 'Abrir pregunta';

  @override
  String get sessionCloseQuestion => 'Cerrar pregunta';

  @override
  String get sessionNoQuestions => 'Todavía no hay preguntas.';

  @override
  String get sessionPresenterTitle => 'Presentador';

  @override
  String get sessionParticipantTitle => 'Social Vote Live';

  @override
  String get sessionJoinAction => 'Unirse a la Session';

  @override
  String get sessionTokenLabel => 'Token del participante';

  @override
  String get sessionTokenHint => 'SV-…';

  @override
  String get sessionWaitingQuestion => 'Esperando a que el organizador abra una pregunta…';

  @override
  String get sessionVoteAction => 'Enviar voto';

  @override
  String get sessionVoteReceived => 'Voto recibido';

  @override
  String get sessionResultsUnavailable => 'Los resultados todavía no son visibles según la política de esta Session.';

  @override
  String get sessionPrivacyNotice => 'El organizador define el propósito operativo y las preguntas de la Session. Social Vote procesa los datos técnicos necesarios para prestar y proteger el servicio. Los modos anónimos no exponen al organizador el vínculo entre una credencial de participante y una opción elegida. Los roles de privacidad pueden depender del contexto y de los acuerdos aplicables.';

  @override
  String get sessionNonBindingNotice => 'Las Sessions piloto son para consulta y participación. No constituyen una elección legal, una votación estatutaria de asamblea ni una certificación jurídicamente vinculante.';

  @override
  String get sessionOptionYes => 'Sí';

  @override
  String get sessionOptionNo => 'No';

  @override
  String get verifiedResultTitle => 'Verified Result';

  @override
  String get verifiedResultValid => 'Comprobación de integridad superada';

  @override
  String get verifiedResultInvalid => 'Comprobación de integridad fallida';

  @override
  String get verifiedResultReportId => 'ID del informe';

  @override
  String get verifiedResultHash => 'Hash SHA-256 del resultado';

  @override
  String get verifiedResultGeneratedBy => 'Generado y sellado en integridad por Social Vote';

  @override
  String get verifiedResultNotLegalCertificate => 'Este es un informe verificable de resultados agregados, no un certificado legal ni una certificación de una elección jurídicamente vinculante.';

  @override
  String get verifiedResultShare => 'Compartir enlace de verificación';

  @override
  String sessionResponses(int count) {
    return '$count respuestas';
  }

  @override
  String sessionResultVotes(int count) {
    return '$count votos';
  }

  @override
  String get organizationVerifiedIdentityLocked => 'El nombre y el país forman parte de la identidad verificada de la organización. Cambiarlos requerirá una nueva verificación. Puedes cambiar libremente la portada, el logo, el tipo, la ciudad, el sitio web y la descripción.';

  @override
  String get verifiedResultOpenedAt => 'Session abierta';

  @override
  String get verifiedResultEligibleCredentials => 'Credenciales habilitadas';

  @override
  String get verifiedResultIntegritySeal => 'Sello de integridad de Social Vote';

  @override
  String get organizationVerifiedNameLocked => 'El nombre verificado y el país están bloqueados. Cambiarlos requiere una nueva revisión de verificación.';

  @override
  String get sessionRetentionLabel => 'Retención de votos sin procesar';

  @override
  String get sessionRetention24h => '24 horas';

  @override
  String get sessionRetention7d => '7 días';

  @override
  String get sessionRetention30d => '30 días';

  @override
  String sessionRetentionValue(String value) {
    return 'Retención de votos sin procesar: $value';
  }

  @override
  String get verifiedResultPrintPdf => 'Descargar PDF';

  @override
  String get verifiedResultPdfError => 'No se puede descargar el PDF. Inténtalo de nuevo.';

  @override
  String get verifiedResultRestrictedTitle => 'Resultado restringido';

  @override
  String get verifiedResultRestrictedBody => 'Este Verified Result no está disponible públicamente. Inicia sesión con una cuenta de organización autorizada para verlo.';

  @override
  String get verifiedResultPrivateVerificationTitle => 'Verificación pública no disponible';

  @override
  String get verifiedResultPrivateVerificationBody => 'Este resultado está restringido al organizador. El ID del informe, SHA-256 y la comprobación de integridad siguen disponibles en el informe autorizado.';

  @override
  String get organizationAccountSectionTitle => 'Tus organizaciones';

  @override
  String get organizationManageAction => 'Gestionar';

  @override
  String get organizationViewPublicProfileAction => 'Ver perfil';

  @override
  String get organizationOfficialWebsiteAction => 'Sitio web oficial';

  @override
  String get organizationVerificationIntro => 'La verificación abarca tanto la existencia de la organización como tu autoridad para representarla. Social Vote revisará la información enviada antes de aprobarla.';

  @override
  String get organizationVerificationLegalName => 'Nombre legal';

  @override
  String get organizationVerificationPublicName => 'Nombre público';

  @override
  String get organizationVerificationType => 'Tipo de organización';

  @override
  String get organizationVerificationCountry => 'País';

  @override
  String get organizationVerificationCountryRequired => 'Selecciona el país de la organización.';

  @override
  String get organizationVerificationCity => 'Ciudad';

  @override
  String get organizationVerificationWebsite => 'Sitio web oficial';

  @override
  String get organizationVerificationRepresentativeRole => 'Tu función en la organización';

  @override
  String get organizationVerificationRegistryId => 'Identificador registral / fiscal / de la organización';

  @override
  String get organizationVerificationAuthorityNote => '¿Cómo podemos verificar que puedes representarla?';

  @override
  String get organizationVerificationAuthorityHelper => 'Indica brevemente tu función o la prueba que un administrador pueda verificar durante el piloto.';

  @override
  String get organizationVerificationRequired => 'Campo obligatorio.';

  @override
  String get sessionControlRoomTitle => 'Sala de Control de la Session';

  @override
  String get sessionSectionLive => 'En directo';

  @override
  String get sessionSectionQuestions => 'Preguntas';

  @override
  String get sessionSectionAccess => 'Acceso';

  @override
  String get sessionSectionSettings => 'Configuración';

  @override
  String get sessionStageAction => 'Abrir Stage';

  @override
  String get sessionAccessPassesTitle => 'Access Pass de participantes';

  @override
  String get sessionAccessPassesSubtitle => 'Cada pase abre esta Session Anónima Controlada sin que el participante tenga que escribir la credencial larga. Social Vote no almacena el pase en texto plano.';

  @override
  String get sessionAccessPass => 'Access Pass';

  @override
  String get sessionAccessPassDetected => 'Access Pass detectado';

  @override
  String get sessionAccessPassAutomatic => 'Tu pase personal está listo. Continúa para entrar en la Session de forma anónima.';

  @override
  String get sessionAccessPassFallback => 'Introducir pase manualmente';

  @override
  String get sessionAccessPassInvalid => 'Este Access Pass no es válido, ya no está disponible o la Session no está abierta.';

  @override
  String get sessionAccessPassPrintWarning => 'Imprime, guarda o distribuye estos pases ahora. Cuando salgas de esta pantalla, Social Vote no podrá volver a mostrar los pases en texto plano.';

  @override
  String get sessionExistingPassesHidden => 'Por seguridad, los pases generados anteriormente no se pueden volver a mostrar en texto plano. Genera nuevos Access Pass para obtener nuevos enlaces personales o códigos QR.';

  @override
  String get sessionCopyPassLinks => 'Copiar todos los enlaces';

  @override
  String get sessionCopyPassLink => 'Copiar este enlace';

  @override
  String get sessionControlledNeedsAccessPass => 'Antes de abrir una Session controlada, genera al menos un Access Pass.';

  @override
  String get sessionJoinedParticipants => 'Credenciales de acceso conectadas';

  @override
  String get sessionAccessesUsed => 'Accesos que votaron';

  @override
  String get sessionBallotsRecorded => 'Votos registrados';

  @override
  String get sessionQuestionsCompleted => 'Preguntas completadas';

  @override
  String get sessionCurrentQuestion => 'Pregunta actual';

  @override
  String get sessionNoOpenQuestionTitle => 'No hay ninguna pregunta abierta';

  @override
  String get sessionNoOpenQuestionBody => 'Los participantes están conectados y esperando. Abre la siguiente pregunta cuando estés listo.';

  @override
  String get sessionNotStartedTitle => 'La Session aún no ha comenzado';

  @override
  String get sessionNotStartedBody => 'Esta Session existe, pero todavía no está abierta. Mantén esta página abierta y espera a que el organizador la inicie.';

  @override
  String get sessionNoAccountRequired => 'No se requiere una cuenta de Social Vote';

  @override
  String get sessionReceiptDetails => 'Detalles del comprobante';

  @override
  String get sessionOpenAccessInstructions => 'Muestra o comparte este QR. Cualquier persona con el enlace puede entrar mientras la Session esté abierta.';

  @override
  String get sessionControlledAccessInstructions => 'Crea pases de acceso personales y entrega uno a cada participante. El QR de cada pase contiene automáticamente la credencial.';

  @override
  String get sessionControlRoomHint => 'Gestiona el acceso, las preguntas, el Stage proyectado y el Verified Result final desde un solo lugar.';

  @override
  String get sessionPresenterScreenTitle => 'Escenario en vivo';

  @override
  String get sessionStageWaiting => 'Esperando la siguiente pregunta';

  @override
  String get sessionStageScan => 'Escanea para unirte a la Session';

  @override
  String get sessionConfigurationTitle => 'Configuración de la Session';

  @override
  String get sessionAccessRecommended => 'Recomendado para reuniones controladas';

  @override
  String get sessionCreateIntroTitle => 'Configurar la reunión';

  @override
  String get sessionCreateIntroBody => 'Elige cómo entran los participantes, cuándo se muestran los resultados y durante cuánto tiempo se conservan los votos sin procesar. Esta configuración es aplicada por el backend.';

  @override
  String get verifiedCertificateNumber => 'Número de certificado';

  @override
  String get verifiedCertificateStatus => 'Estado de integridad';

  @override
  String get verifiedCertificateIntegrityVerified => 'INTEGRIDAD VERIFICADA';

  @override
  String get verifiedCertificateIntegrityFailed => 'COMPROBACIÓN DE INTEGRIDAD FALLIDA';

  @override
  String get verifiedCertificateOrganizationSection => 'Organización';

  @override
  String get verifiedCertificateSessionSection => 'Session';

  @override
  String get verifiedCertificateParticipationSection => 'Participación';

  @override
  String get verifiedCertificateResultsSection => 'Resultados verificados';

  @override
  String get verifiedCertificateIntegritySection => 'Integridad del resultado';

  @override
  String get verifiedCertificateLegalName => 'Nombre legal';

  @override
  String get verifiedCertificateOrganizationType => 'Tipo de organización';

  @override
  String get verifiedCertificateLocation => 'Ubicación';

  @override
  String get verifiedCertificateWebsite => 'Sitio web';

  @override
  String get verifiedCertificateVerification => 'Verificación';

  @override
  String get verifiedCertificateIssuedAt => 'Certificado emitido';

  @override
  String get verifiedCertificateAlgorithm => 'Algoritmo de integridad';

  @override
  String get verifiedCertificateSchema => 'Esquema del informe';

  @override
  String get verifiedCertificateJoinedCredentials => 'Credenciales conectadas';

  @override
  String get verifiedCertificateBallotsTotal => 'Votos registrados';

  @override
  String get verifiedCertificateQuestionsTotal => 'Preguntas';

  @override
  String get verifiedCertificatePrivacyModel => 'Modelo de resultados anónimos';

  @override
  String get verifiedCertificatePrivacyText => 'La instantánea inmutable contiene únicamente resultados agregados. No contiene la identidad de ningún participante, Access Pass en texto plano, secreto del participante ni ningún vínculo entre una credencial de participante y una opción de voto.';

  @override
  String get verifiedCertificateVerifyQr => 'Escanea este QR para verificar el informe en línea.';

  @override
  String get organizationDashboardTitle => 'Resumen de la organización';

  @override
  String get organizationActiveSessions => 'Sessions en directo';

  @override
  String get organizationVerifiedReports => 'Informes verificados';

  @override
  String get organizationTotalSessions => 'Total de Sessions';

  @override
  String get sessionPrivacyPolicyAction => 'Leer la Política de Privacidad';

  @override
  String get radioMondoTitle => 'Radio del Mundo';

  @override
  String get radioMondoDescription => 'Tres paisajes sonoros originales para explorar Social Vote. La reproducción solo comienza cuando eliges una pista.';

  @override
  String get radioMondoTrackClassical => 'Órbita clásica';

  @override
  String get radioMondoTrackRain => 'Lluvia sobre el mundo';

  @override
  String get radioMondoTrackYoung => 'Pulso joven';

  @override
  String get radioMondoPlaying => 'Reproduciendo ahora';

  @override
  String get radioMondoStopped => 'Radio del Mundo detenida';

  @override
  String get radioMondoStopAction => 'Detener';

  @override
  String get radioMondoPlaybackError => 'No se pudo reproducir el audio';

  @override
  String get radioMondoForegroundOnly => 'La reproducción se detiene cuando Social Vote se cierra, pasa a segundo plano o se oculta la pestaña del navegador.';

  @override
  String get adminCenterEditorialNavigation => 'World Briefs';

  @override
  String get worldBriefEditorTitle => 'World Briefs de Social Vote';

  @override
  String get worldBriefEditorDescription => 'Prepara resúmenes basados en evidencias, mantén visible la incertidumbre y decide qué aparece en News y en el Globo.';

  @override
  String get worldBriefAllStatuses => 'Todos los estados';

  @override
  String get worldBriefCreateAction => 'Crear brief';

  @override
  String get worldBriefDraftSaved => 'Borrador guardado';

  @override
  String get worldBriefPublished => 'Brief publicado';

  @override
  String get worldBriefWithdrawn => 'Brief retirado';

  @override
  String get worldBriefSaveError => 'No se pudo guardar el brief';

  @override
  String get worldBriefPublishError => 'No se pudo publicar el brief';

  @override
  String get worldBriefDraftDeleted => 'Borrador eliminado';

  @override
  String get worldBriefDeleteDraft => 'Eliminar borrador';

  @override
  String get worldBriefDeleteDraftConfirm => '¿Eliminar permanentemente este borrador no publicado?';

  @override
  String get worldBriefRetry => 'Intentar de nuevo';

  @override
  String get worldBriefStatusDraft => 'Borrador';

  @override
  String get worldBriefStatusPublished => 'Publicado';

  @override
  String get worldBriefStatusWithdrawn => 'Retirado';

  @override
  String get worldBriefSetupRequired => 'Backend editorial no preparado';

  @override
  String get worldBriefSetupRequiredBody => 'Aplica la migración de base de datos de World Brief incluida antes de usar esta sección.';

  @override
  String get worldBriefEmptyTitle => 'Todavía no hay World Briefs';

  @override
  String get worldBriefEmptyBody => 'Crea un borrador, documenta al menos dos fuentes y publica solo después de una revisión editorial.';

  @override
  String get worldBriefFeatured => 'Destacado';

  @override
  String get worldBriefOnGlobe => 'Mostrar en el Globo';

  @override
  String get worldBriefPriority => 'Prioridad';

  @override
  String get worldBriefEditAction => 'Editar';

  @override
  String get worldBriefPublishAction => 'Publicar';

  @override
  String get worldBriefWithdrawAction => 'Retirar';

  @override
  String get worldBriefSaveDraftAction => 'Guardar borrador';

  @override
  String get worldBriefLanguage => 'Idioma del brief';

  @override
  String get worldBriefTitleField => 'Titular';

  @override
  String get worldBriefWhatHappened => 'Qué ocurrió';

  @override
  String get worldBriefWhyItMatters => 'Por qué importa';

  @override
  String get worldBriefWhatIsUncertain => 'Qué sigue siendo incierto';

  @override
  String get worldBriefSources => 'URL de las fuentes';

  @override
  String get worldBriefSourcesHint => 'Una URL HTTPS por línea; al menos dos fuentes independientes.';

  @override
  String get worldBriefTwoSourcesRequired => 'Añade al menos dos fuentes.';

  @override
  String get worldBriefHttpsSourcesRequired => 'Todas las fuentes deben usar HTTPS.';

  @override
  String get worldBriefGlobeSection => 'Ubicación en el Globo';

  @override
  String get worldBriefGlobeRequiresPoint => 'La visibilidad en el Globo requiere una latitud y longitud válidas.';

  @override
  String get worldBriefCountryCode => 'Código de país';

  @override
  String get worldBriefCityId => 'ID de ciudad';

  @override
  String get worldBriefLocationLabel => 'Etiqueta de ubicación';

  @override
  String get worldBriefLatitude => 'Latitud';

  @override
  String get worldBriefLongitude => 'Longitud';

  @override
  String get worldBriefBreaking => 'Actualización urgente';

  @override
  String get worldBriefExpiry => 'Ventana de revisión o caducidad';

  @override
  String worldBriefExpiryDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get worldBriefRequiredField => 'Este campo es obligatorio.';

  @override
  String get worldBriefCoordinatesRequired => 'Introduce una coordenada válida.';

  @override
  String get profileHowItWorksTitle => 'Cómo funciona Social Vote';

  @override
  String get profileHowItWorksSubtitle => 'Personas, Organizaciones, Voce, Vote, Sessions y verificación.';

  @override
  String get profileMyPostsLoginRequired => 'Debes iniciar sesión para ver tus Voce.';

  @override
  String get profileMyPostsCreatedByYou => 'Voce creados por ti';

  @override
  String get profileMyPostsEmpty => 'Todavía no has creado ningún Voce.';

  @override
  String get profileMyPollsLoginRequired => 'Debes iniciar sesión para ver tus Vote.';

  @override
  String get profileMyPollsCreatedByYou => 'Vote creados por ti';

  @override
  String get profileMyPollsEmpty => 'Todavía no has creado ningún Vote.';

  @override
  String get profileMyCommentsLoginRequired => 'Debes iniciar sesión para ver tus comentarios.';

  @override
  String get profileMyCommentsEmpty => 'Todavía no has escrito ningún comentario.';

  @override
  String get profileFollowedScopesLoginRequired => 'Debes iniciar sesión.';

  @override
  String get profileFollowedScopesEmpty => 'Todavía no sigues ninguna zona.';

  @override
  String get profileFollowedScopeWorld => 'Mundo';

  @override
  String profileFollowedScopeCountry(String code) {
    return 'País: $code';
  }

  @override
  String profileFollowedScopeCity(String city) {
    return 'Ciudad: $city';
  }

  @override
  String profileFollowedScopeArea(double radius) {
    return 'Zona ($radius km)';
  }

  @override
  String get publicProfilePollsLoadError => 'No se pueden cargar los Vote públicos.';

  @override
  String get publicProfilePollsEmpty => 'No hay Vote públicos.';

  @override
  String get publicProfilePostsLoadError => 'No se pueden cargar los Voce públicos.';

  @override
  String get publicProfilePostsEmpty => 'No hay Voce públicos.';

  @override
  String get worldBriefSocialVoteView => 'Perspectiva de Social Vote';

  @override
  String get worldBriefSocialVoteViewHint => 'Análisis o punto de vista editorial de Social Vote. Mantenlo separado de los hechos informados y de la incertidumbre.';

  @override
  String get worldBriefSocialVoteViewPublicNote => 'Análisis editorial de Social Vote, claramente separado de los hechos informados arriba.';

  @override
  String get worldBriefIndependentSourcesRequired => 'Para publicar se requieren al menos dos fuentes HTTPS de dominios diferentes.';

  @override
  String get worldBriefPublishConfirmTitle => 'Comprobación final antes de publicar';

  @override
  String worldBriefPublishConfirmSources(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fuentes introducidas',
      one: '1 fuente introducida',
    );
    return '$_temp0';
  }

  @override
  String get worldBriefEnterpriseEditorTitle => 'Editor editorial profesional';

  @override
  String get worldBriefEnterpriseEditorHelp => 'Construye el brief por secciones. Social Vote gestiona automáticamente la ubicación técnica en el Globo: elige un país y una ciudad, no coordenadas.';

  @override
  String get worldBriefEditorialContentSection => 'Contenido editorial';

  @override
  String get worldBriefEditorialContentHelp => 'Mantén separados los hechos, la relevancia, la incertidumbre y la perspectiva de Social Vote. Esto facilita verificar y leer el brief.';

  @override
  String get worldBriefSourcesSection => 'Fuentes y verificación';

  @override
  String get worldBriefSourcesSectionHelp => 'Añade fuentes HTTPS verificables. Para publicar se requieren al menos dos dominios independientes.';

  @override
  String get worldBriefDistributionSection => 'Distribución';

  @override
  String get worldBriefDistributionHelp => 'Elige dónde aparece el brief. Al publicarlo queda disponible en News; su ubicación en el Globo es opcional.';

  @override
  String get worldBriefNewsDestination => 'Publicar en Social Vote News';

  @override
  String get worldBriefNewsDestinationHelp => 'Este es el destino principal de un World Brief una vez publicado.';

  @override
  String get worldBriefGlobeAutomaticHelp => 'Añade un marcador al Globo. Elige el lugar y Social Vote resolverá automáticamente la posición.';

  @override
  String get worldBriefPlacementMode => 'Ubicación del marcador';

  @override
  String get worldBriefPlacementCity => 'Ciudad / lugar';

  @override
  String get worldBriefPlacementCountry => 'Centro del país';

  @override
  String get worldBriefCountry => 'País';

  @override
  String get worldBriefCity => 'Ciudad o lugar';

  @override
  String get worldBriefCityHelp => 'Ejemplo: Teherán. No introduzcas latitud ni longitud.';

  @override
  String get worldBriefResolveLocation => 'Resolver ubicación';

  @override
  String get worldBriefCoordinatesAutomatic => 'Las coordenadas se gestionan automáticamente y no deben introducirse manualmente.';

  @override
  String worldBriefLocationResolved(String location) {
    return 'Ubicación lista: $location';
  }

  @override
  String get worldBriefChooseCountryFirst => 'Elige primero un país.';

  @override
  String get worldBriefChooseCityFirst => 'Introduce primero una ciudad o lugar.';

  @override
  String get worldBriefLocationNotResolved => 'No se pudo resolver una ubicación fiable. Comprueba el país y la ciudad e inténtalo de nuevo.';

  @override
  String get worldBriefVisibilitySection => 'Visibilidad y prioridad';

  @override
  String get worldBriefVisibilityHelp => 'Controla la prominencia editorial, la urgencia, el orden y la duración sin cambiar los hechos informados.';

  @override
  String get worldBriefFeaturedHelp => 'Da al brief más protagonismo en las superficies editoriales.';

  @override
  String get worldBriefBreakingHelp => 'Úsalo solo para acontecimientos realmente urgentes o que evolucionen rápidamente.';

  @override
  String get worldBriefPriorityHelp => '0 = prioridad normal/baja; 100 = prioridad editorial máxima. No cambia el estado de veracidad del contenido.';

  @override
  String get worldBriefExpiryHelp => 'Después de esta ventana, el brief no debería seguir activo sin otra revisión editorial.';

  @override
  String get profileAppLanguageSpanish => 'Español';

  @override
  String get profileAppLanguagePortuguese => 'Portugués';

  @override
  String get homeHeroPurpose => 'Descubre lo que importa, comparte tu Voce y participa en Vote.';

  @override
  String get commentSection_hideComments => 'Ocultar comentarios';

  @override
  String get commentSection_viewComments => 'Ver comentarios';

  @override
  String get commentSection_hideReplies => 'Ocultar respuestas';

  @override
  String commentSection_editing(String snippet) {
    return 'Editando: $snippet';
  }

  @override
  String get commentSection_editInputHint => 'Edita tu comentario';

  @override
  String commentSection_replyTo(String author) {
    return 'Responder a $author';
  }

  @override
  String get commentSection_userFallback => 'Usuario';

  @override
  String get commentSection_addError => 'No se pudo añadir el comentario.';

  @override
  String get commentSection_nestedReplyError => 'No se admiten respuestas anidadas de más de un nivel.';

  @override
  String get commentSection_addReplyError => 'No se pudo añadir la respuesta.';

  @override
  String get commentSection_editError => 'No se pudo editar el comentario.';

  @override
  String get commentSection_deleteError => 'No se pudo eliminar el comentario.';

  @override
  String get commentSection_edited => 'Editado';

  @override
  String get commentSection_editAction => 'Editar';
}
