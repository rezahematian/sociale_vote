// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Social Vote';

  @override
  String get voteButton => 'Votar';

  @override
  String get createPollPageTitle => 'Criar Vote';

  @override
  String get createPollPageSubtitle => 'Defina uma nova votação cívica';

  @override
  String get createPollBasicInfoTitle => 'Informações básicas';

  @override
  String get createPollBasicInfoSubtitle => 'Defina os principais detalhes do Vote.';

  @override
  String get createPollTitleFieldLabel => 'Título *';

  @override
  String get createPollTitleFieldHelper => 'Uma pergunta ou afirmação clara e concisa.';

  @override
  String get createPollDescriptionFieldLabel => 'Descrição (opcional)';

  @override
  String get createPollVotingModelTitle => 'Como funciona a votação';

  @override
  String get createPollVotingModelSubtitle => 'Escolha se cada pessoa pode selecionar uma resposta ou várias respostas.';

  @override
  String get createPollTypeFieldLabel => 'Tipo de Vote';

  @override
  String createPollSelectionRules(int min, int max) {
    return 'Regras de seleção: mínimo $min, máximo $max seleções (ajustadas automaticamente com base no tipo de Vote e nas opções).';
  }

  @override
  String get createPollAllowVoteChangeTitle => 'Permitir que os votantes alterem seu voto';

  @override
  String get createPollAllowVoteChangeSubtitle => 'Até que o Vote seja encerrado.';

  @override
  String get createPollOptionsTitle => 'Respostas';

  @override
  String get createPollOptionsSubtitle => 'Insira pelo menos duas respostas para os votantes escolherem. Os campos marcados com * são obrigatórios.';

  @override
  String createPollOptionLabel(int index, Object requiredMarker) {
    return 'Opção $index$requiredMarker';
  }

  @override
  String get createPollRemoveOptionTooltip => 'Remover opção';

  @override
  String get createPollAddOptionButton => 'Adicionar opção';

  @override
  String get createPollParticipationPrivacyTitle => 'Participação e privacidade';

  @override
  String get createPollParticipationPrivacySubtitle => 'Decida quem pode votar e qual deve ser o nível de privacidade dos votos.';

  @override
  String get createPollWhoCanVoteLabel => 'Quem pode votar?';

  @override
  String get createPollParticipationEveryoneSubtitle => 'Qualquer usuário cadastrado pode participar.';

  @override
  String get createPollParticipationGeoScopeSubtitle => 'Limite este Vote a pessoas de um país específico.';

  @override
  String get createPollCountryFieldLabel => 'País para este Vote';

  @override
  String get createPollCountryFieldHelper => 'Este país definirá quem poderá participar deste Vote (futura integração com o backend).';

  @override
  String get createPollVoteAnonymityTitle => 'Anonimato do voto';

  @override
  String get createPollAnonymityAnonymousSubtitle => 'Opção padrão recomendada para plataformas de votação cívica.';

  @override
  String get createPollAnonymityPublicSubtitle => 'Use com cautela: os votos podem ser associados a identidades (recurso futuro).';

  @override
  String get createPollResultsValidityTitle => 'Resultados e validade';

  @override
  String get createPollResultsValiditySubtitle => 'Controle quando os resultados ficam visíveis e defina um quórum mínimo, se necessário.';

  @override
  String get createPollResultsVisibilityFieldLabel => 'Visibilidade dos resultados';

  @override
  String get createPollQuorumTitle => 'Quórum (opcional)';

  @override
  String get createPollQuorumSubtitle => 'Se definido, o Vote será considerado válido somente se atingir pelo menos este número de votos. Deixe em branco para não exigir quórum.';

  @override
  String get createPollQuorumMinVotesFieldLabel => 'Número mínimo de votos';

  @override
  String get createPollTimingTitle => 'Período';

  @override
  String get createPollTimingSubtitle => 'Defina quando o Vote deve ficar aberto para votação.';

  @override
  String get createPollStartDateLabel => 'Data de início';

  @override
  String get createPollEndDateLabel => 'Data de término';

  @override
  String get createPollChangeDateButtonLabel => 'Alterar';

  @override
  String get createPollTimingStatusInfo => 'O status inicial (aberto/agendado/encerrado) será determinado automaticamente com base nessas datas.';

  @override
  String get createPollSuccessMessage => 'Vote criado com sucesso';

  @override
  String get createPollSubmitCreatingLabel => 'Criando...';

  @override
  String get createPollSubmitLabel => 'Criar Vote';

  @override
  String get createPollPollTypeYesNoLabel => 'Sim / Não';

  @override
  String get createPollPollTypeSingleChoiceLabel => 'Uma resposta';

  @override
  String get createPollPollTypeMultipleChoiceLabel => 'Várias respostas';

  @override
  String get createPollPollTypeApprovalLabel => 'Votação por aprovação';

  @override
  String get createPollPollTypeRankedLabel => 'Escolha por ordem de preferência';

  @override
  String get createPollPollTypeScoreLabel => 'Pontuação / Avaliação';

  @override
  String get createPollParticipationScopeEveryoneLabel => 'Todos podem votar';

  @override
  String get createPollParticipationScopeGeoScopeOnlyLabel => 'Somente usuários de um país específico';

  @override
  String get createPollAnonymityLevelAnonymousLabel => 'Os votos são anônimos';

  @override
  String get createPollAnonymityLevelPublicLabel => 'Os votos são públicos (uso avançado / restrito)';

  @override
  String get createPollResultsVisibilityAlwaysLabel => 'Sempre visíveis (enquanto o Vote estiver aberto)';

  @override
  String get createPollResultsVisibilityAfterVoteLabel => 'Visíveis somente após votar';

  @override
  String get createPollResultsVisibilityAfterCloseLabel => 'Visíveis somente após o encerramento do Vote';

  @override
  String get homeLoginButton => 'Entrar';

  @override
  String get homeRegisterButton => 'Cadastrar-se';

  @override
  String get homeProfileButton => 'Perfil';

  @override
  String get homeLogoutButton => 'Sair';

  @override
  String get homeLogoutMessage => 'Sessão encerrada. Agora você está usando o app como visitante (somente leitura).';

  @override
  String get homeSearchHint => 'Buscar cidades, países, contas e conteúdo...';

  @override
  String get searchPageTitle => 'Buscar';

  @override
  String get searchInputHint => 'Buscar contas, Vote, News, Voce...';

  @override
  String get searchClearTooltip => 'Limpar busca';

  @override
  String get searchTypeAll => 'Tudo';

  @override
  String get searchTypePolls => 'Vote';

  @override
  String get searchTypeNews => 'News';

  @override
  String get searchTypePosts => 'Voce';

  @override
  String get searchTypeAccounts => 'Contas';

  @override
  String get searchSortHottest => 'Mais populares';

  @override
  String get searchSortLatest => 'Mais recentes';

  @override
  String get searchPollStatusAll => 'Todos os Vote';

  @override
  String get searchPollStatusOpen => 'Abertos';

  @override
  String get searchPollStatusClosed => 'Encerrados';

  @override
  String get searchIdleMessage => 'Digite um termo para começar a buscar.';

  @override
  String get searchErrorMessage => 'Ocorreu um erro durante a busca.';

  @override
  String get searchRetryButton => 'Tentar novamente';

  @override
  String get searchEmptyMessage => 'Nenhum resultado encontrado para esta busca.';

  @override
  String get searchContentUnavailable => 'Conteúdo indisponível';

  @override
  String get searchResultTypePoll => 'Vote';

  @override
  String get searchResultTypeNews => 'News';

  @override
  String get searchResultTypePost => 'Voce';

  @override
  String get searchResultTypeAccount => 'Conta';

  @override
  String get searchResultTypeMixed => 'Misto';

  @override
  String homeUserStatusLoggedIn(Object userId) {
    return 'Conectado como: $userId';
  }

  @override
  String get homeUserStatusGuest => 'Modo visitante: você pode apenas ler. Entre ou cadastre-se para votar, comentar e reagir.';

  @override
  String get homeScopeLabelWorld => 'Mundo – Votações e notícias globais';

  @override
  String get homeScopeLabelCountry => 'País – Votações e notícias nacionais';

  @override
  String get homeScopeLabelCity => 'Cidade – Votações e notícias locais';

  @override
  String get homeScopeShortWorld => 'Mundo';

  @override
  String get homeScopeShortCountry => 'País';

  @override
  String get homeScopeShortCity => 'Cidade';

  @override
  String get homeScopeChipWorld => 'Mundo';

  @override
  String get homeScopeChipItaly => 'Itália';

  @override
  String get homeScopeChipTorino => 'Turim';

  @override
  String get homeScopeChangedWorld => 'Escopo alterado para Mundo';

  @override
  String get homeScopeChangedItaly => 'Escopo alterado para Itália';

  @override
  String get homeScopeChangedTorino => 'Escopo alterado para Turim';

  @override
  String get followScopeButtonFollowed => 'Seguindo';

  @override
  String get followScopeButtonFollow => 'Seguir esta área';

  @override
  String get homeTrendingTitle => 'Pulse Now';

  @override
  String get homeTrendingError => 'Não foi possível carregar o Pulse Now para esta área.';

  @override
  String get homeTrendingEmpty => 'Não há conteúdo no Pulse Now para esta área no momento.';

  @override
  String homeForYouTitle(Object scope) {
    return 'Pulse ($scope)';
  }

  @override
  String get homeForYouError => 'Não foi possível carregar o Pulse para esta área.';

  @override
  String get homeForYouEmpty => 'Não há conteúdo sugerido no Pulse para esta área no momento.';

  @override
  String homePollsTitle(Object scope) {
    return 'Vote em destaque ($scope)';
  }

  @override
  String get homePollsEmptyTitle => 'Não há Vote para esta área';

  @override
  String get homePollsEmptySubtitle => 'Não há Vote disponíveis para esta área.';

  @override
  String get homePollsViewAllButton => 'Ver Vote';

  @override
  String homeNewsTitle(Object scope) {
    return 'Principais notícias ($scope)';
  }

  @override
  String get homeNewsErrorTitle => 'Não foi possível carregar as notícias';

  @override
  String get homeNewsErrorSubtitle => 'Houve um problema ao carregar as notícias desta área.';

  @override
  String get homeNewsEmptyTitle => 'Não há notícias para esta área';

  @override
  String get homeNewsEmptySubtitle => 'Não há notícias para este escopo no momento.';

  @override
  String get homeNewsViewAllButton => 'Ver todas as notícias';

  @override
  String get homeNewsBreakingBadge => 'URGENTE';

  @override
  String homeSocialTitle(Object scope) {
    return 'Voce ($scope)';
  }

  @override
  String get homeSocialErrorTitle => 'Não foi possível carregar Voce';

  @override
  String get homeSocialErrorSubtitle => 'Houve um problema ao carregar Voce para esta área.';

  @override
  String get homeSocialEmptyTitle => 'Não há Voce para esta área';

  @override
  String get homeSocialEmptySubtitle => 'Não há conteúdo de Voce para esta área no momento.';

  @override
  String get homeSocialViewFeedButton => 'Ver todos os Voce';

  @override
  String get pollDetail_title => 'Detalhes do Vote';

  @override
  String get pollDetail_removeFromFavoritesTooltip => 'Remover dos salvos';

  @override
  String get pollDetail_addToFavoritesTooltip => 'Salvar';

  @override
  String get pollDetail_chipAnonymous => 'Voto anônimo';

  @override
  String get pollDetail_chipPublic => 'Voto público';

  @override
  String get pollDetail_chipRestrictedGeo => 'Restrito ao escopo geográfico';

  @override
  String pollDetail_quorumReached(int currentVotes, int requiredVotes) {
    return 'Quórum atingido ($currentVotes / $requiredVotes)';
  }

  @override
  String pollDetail_quorumNotReached(int currentVotes, int requiredVotes) {
    return 'Quórum não atingido ($currentVotes / $requiredVotes)';
  }

  @override
  String get pollDetail_optionsTitle => 'Opções';

  @override
  String get pollDetail_statusClosedMessage => 'Este Vote está encerrado.';

  @override
  String get pollDetail_statusScheduledMessage => 'Este Vote ainda não está aberto.';

  @override
  String get pollDetail_statusNotAvailableMessage => 'A votação não está disponível.';

  @override
  String get pollDetail_voteSubmitted => 'Voto enviado com sucesso!';

  @override
  String get pollDetail_voteButton => 'Votar';

  @override
  String get pollDetail_resultsTitle => 'Resultados';

  @override
  String pollDetail_outcomePrefix(Object label) {
    return 'Resultado: $label';
  }

  @override
  String get pollDetail_noResults => 'Ainda não há resultados disponíveis.';

  @override
  String get pollDetail_resultsAfterVote => 'Os resultados ficarão visíveis após você votar.';

  @override
  String get pollDetail_resultsWhenClosed => 'Os resultados ficarão visíveis quando o Vote for encerrado.';

  @override
  String get pollType_yesNo => 'Sim / Não';

  @override
  String get pollType_singleChoice => 'Escolha única';

  @override
  String get pollType_multipleChoice => 'Escolha múltipla';

  @override
  String get pollType_approval => 'Aprovação';

  @override
  String get pollStatus_draft => 'Rascunho';

  @override
  String get pollStatus_open => 'Aberto';

  @override
  String get pollStatus_closed => 'Encerrado';

  @override
  String get pollStatus_scheduled => 'Agendado';

  @override
  String get pollGeo_global => 'Global';

  @override
  String get pollGeo_local => 'Local';

  @override
  String get pollOutcome_approved => 'Aprovado';

  @override
  String get pollOutcome_rejected => 'Rejeitado';

  @override
  String get pollOutcome_tie => 'Empate';

  @override
  String get pollOutcome_noMajority => 'Sem maioria';

  @override
  String get pollOutcome_notApplicable => 'Não aplicável';

  @override
  String get pollList_title => 'Vote';

  @override
  String get pollList_scopeWorld => 'Mundo';

  @override
  String get pollList_scopeCountryFallback => 'País';

  @override
  String get pollList_scopeCityFallback => 'Cidade';

  @override
  String get pollList_scopeDescriptionGlobal => 'Exibindo Vote globais.';

  @override
  String get pollList_scopeDescriptionCountry => 'Exibindo Vote para este país.';

  @override
  String get pollList_scopeDescriptionCity => 'Exibindo Vote para esta cidade.';

  @override
  String get pollList_filterStatus_all => 'Todos';

  @override
  String get pollList_filterStatus_open => 'Abertos';

  @override
  String get pollList_filterStatus_closed => 'Encerrados';

  @override
  String get pollList_sort_latest => 'Mais recentes';

  @override
  String get pollList_sort_hottest => 'Mais populares';

  @override
  String get pollList_filterScope_currentArea => 'Área atual';

  @override
  String pollList_headerTitle(Object scopeLabel, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Vote encontrados',
      one: '1 Vote encontrado',
      zero: 'nenhum Vote encontrado',
    );
    return '$scopeLabel · $_temp0';
  }

  @override
  String get pollList_createPollButton => 'Criar Vote';

  @override
  String get pollList_paginationHint => 'Role para carregar mais Vote…';

  @override
  String get pollList_emptyMessage => 'Não há Vote que correspondam a este filtro para esta área.';

  @override
  String get pollType_ranked => 'Escolha por ordem de preferência';

  @override
  String get pollType_score => 'Votação por pontuação';

  @override
  String get pollVisibility_whileOpen => 'Resultados visíveis enquanto estiver aberto';

  @override
  String get pollVisibility_afterVote => 'Resultados visíveis após votar';

  @override
  String get pollVisibility_afterClose => 'Resultados visíveis após o encerramento';

  @override
  String get pollCard_countryRestricted => 'Restrito por país';

  @override
  String pollCard_restrictedToCountry(Object countryName) {
    return 'Restrito a $countryName';
  }

  @override
  String pollCard_quorumLabel(int minVotes) {
    return 'Quórum $minVotes';
  }

  @override
  String get pollCard_resultsVisibleChip => 'Resultados visíveis';

  @override
  String get pollCard_resultsAfterVoteChip => 'Após votar';

  @override
  String get pollCard_resultsAfterCloseChip => 'Após o encerramento';

  @override
  String get pollCard_publicOfficialPublisher => 'Agente público';

  @override
  String get pollCard_institutionPublisher => 'Instituição';

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
  String get pollCard_viewDetails => 'Ver detalhes';

  @override
  String pollResult_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Resultados ($count votos)',
      one: 'Resultados (1 voto)',
      zero: 'Resultados (sem votos)',
    );
    return '$_temp0';
  }

  @override
  String get voteError_noSelection => 'Selecione pelo menos uma opção.';

  @override
  String get voteError_unauthorized => 'Você não tem permissão para votar neste Vote.';

  @override
  String get voteError_generic => 'Não foi possível enviar o voto. Tente novamente.';

  @override
  String get commentSection_title => 'Comentários';

  @override
  String get commentSection_sortLabel => 'Ordenar:';

  @override
  String get commentSection_sortOldest => 'Mais antigos';

  @override
  String get commentSection_sortNewest => 'Mais recentes';

  @override
  String get commentSection_errorGeneric => 'Ocorreu um erro ao carregar os comentários.';

  @override
  String get commentSection_empty => 'Ainda não há comentários. Seja o primeiro a comentar.';

  @override
  String get commentSection_loadMore => 'Carregar mais comentários';

  @override
  String commentSection_replyingTo(Object snippet) {
    return 'Respondendo a: $snippet';
  }

  @override
  String get commentSection_cancelReply => 'Cancelar';

  @override
  String get commentSection_inputHintRoot => 'Adicionar um comentário...';

  @override
  String get commentSection_inputHintReply => 'Escreva uma resposta...';

  @override
  String get commentSection_deleteAction => 'Excluir';

  @override
  String get commentSection_replyAction => 'Responder';

  @override
  String get commentSection_youBadge => 'Você';

  @override
  String get newsDetail_title => 'Detalhes da notícia';

  @override
  String get newsDetail_breakingBadge => 'URGENTE';

  @override
  String get newsDetail_removeFromFavoritesTooltip => 'Remover dos salvos';

  @override
  String get newsDetail_addToFavoritesTooltip => 'Salvar';

  @override
  String get newsDetail_bodyFallback => 'Não há texto adicional disponível para esta notícia.';

  @override
  String get newsDetail_footerMoreContext => 'Mais contexto e fontes em breve.';

  @override
  String get newsFeed_title => 'News';

  @override
  String get newsFeed_scopeWorld => 'Mundo';

  @override
  String get newsFeed_scopeCountry => 'País';

  @override
  String get newsFeed_scopeCity => 'Cidade';

  @override
  String newsFeed_scopeLabel(Object scope) {
    return 'Escopo: $scope';
  }

  @override
  String get newsFeed_scopeGlobalDescription => 'Exibindo notícias globais.';

  @override
  String get newsFeed_scopeCountryDescription => 'Exibindo notícias deste país.';

  @override
  String get newsFeed_scopeCityDescription => 'Exibindo notícias desta cidade.';

  @override
  String get newsFeed_emptyTitle => 'Não há notícias disponíveis para esta área.';

  @override
  String get newsFeed_emptySubtitle => 'Puxe para atualizar ou tente novamente mais tarde.';

  @override
  String newsFeed_itemsFound(int count) {
    return '$count notícia(s) encontrada(s)';
  }

  @override
  String get newsFeed_loadingMoreHint => 'Role para carregar mais notícias…';

  @override
  String get newsFeed_errorTitle => 'Não foi possível carregar as notícias';

  @override
  String get newsFeed_errorGeneric => 'Ocorreu um erro inesperado ao carregar as notícias.';

  @override
  String get newsFeed_retryButton => 'Tentar novamente';

  @override
  String get newsCard_headerTitle => 'News';

  @override
  String get newsFeed_errorUnauthorized => 'A configuração de News é inválida (chave de API).';

  @override
  String get newsFeed_errorRateLimited => 'Muitas solicitações. Tente novamente em instantes.';

  @override
  String get newsFeed_errorServerUnavailable => 'O serviço de News está temporariamente indisponível. Tente novamente mais tarde.';

  @override
  String get newsFeed_errorTimeout => 'A solicitação está demorando demais. Tente novamente.';

  @override
  String get newsFeed_errorNetwork => 'Sem conexão. Verifique sua internet e tente novamente.';

  @override
  String get newsFeed_moreTooltip => 'Mais';

  @override
  String get newsFeed_actionCopyTitle => 'Copiar título';

  @override
  String get newsFeed_actionRefreshFeed => 'Atualizar feed';

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
  String get newsFeed_languageLimitedHint => 'Fontes limitadas neste idioma. Tente AUTO.';

  @override
  String get newsTopic_all => 'Tudo';

  @override
  String get newsTopic_world => 'Mundo';

  @override
  String get newsTopic_nation => 'Nacional';

  @override
  String get newsTopic_business => 'Negócios';

  @override
  String get newsTopic_technology => 'Tecnologia';

  @override
  String get newsTopic_science => 'Ciência';

  @override
  String get newsTopic_health => 'Saúde';

  @override
  String get newsTopic_sports => 'Esportes';

  @override
  String get newsTopic_entertainment => 'Entretenimento';

  @override
  String get newsDetail_openSource => 'Abrir artigo da fonte';

  @override
  String get newsDetail_openSourceUnavailable => 'Não foi possível abrir o artigo da fonte';

  @override
  String get socialFeedTitle => 'Voce';

  @override
  String get socialFeedCreatePostButton => 'Criar Voce';

  @override
  String get commonCancelButton => 'Cancelar';

  @override
  String get commonApplyButton => 'Aplicar';

  @override
  String get homeScopeChooseCountry => 'Escolher país';

  @override
  String get homeScopeCountrySearchHint => 'Buscar país ou código...';

  @override
  String get homeScopeChooseCity => 'Escolher cidade';

  @override
  String homeScopeCountryWithCode(String code) {
    return 'País: $code';
  }

  @override
  String get homeScopeCityFieldLabel => 'Cidade';

  @override
  String get homeScopeCityExampleHint => 'Digite uma cidade, ex.: Merano';

  @override
  String get homeScopeCityRequiredError => 'Digite uma cidade.';

  @override
  String get homeScopeCityNotFoundError => 'Cidade não encontrada no país selecionado.';

  @override
  String get homeScopeCityVerificationError => 'Não foi possível verificar a cidade. Tente novamente.';

  @override
  String get homeScopeVerifyingButton => 'Verificando...';

  @override
  String get homeMapOpenButton => 'Abrir mapa';

  @override
  String get homeHeroHeadline => 'Dê forma ao futuro.\nJuntos.';

  @override
  String get homeHeroPollsAction => 'Vote';

  @override
  String get homeHeroNewsAction => 'News';

  @override
  String get homeHeroCreateAction => 'Criar';

  @override
  String get homeHeroExploreAction => 'Explorar';

  @override
  String get homeAccountMenuLabel => 'Conta';

  @override
  String get homeThemeSystemMenuItem => 'Tema: sistema';

  @override
  String get homeThemeLightMenuItem => 'Tema: claro';

  @override
  String get homeThemeDarkMenuItem => 'Tema: escuro';

  @override
  String get profileAppLanguageTitle => 'Idioma do app';

  @override
  String get profileAppLanguageSystem => 'Sistema';

  @override
  String get profileAppLanguageSystemDescription => 'Usa o idioma do seu dispositivo';

  @override
  String get profileAppLanguageItalian => 'Italiano';

  @override
  String get profileAppLanguageEnglish => 'Inglês';

  @override
  String get homeNotificationsTooltip => 'Notificações';

  @override
  String get postCard_authorFallback => 'Autor';

  @override
  String get postCard_globalLocation => 'Global';

  @override
  String get commonSaveButton => 'Salvar';

  @override
  String get commonDeleteButton => 'Excluir';

  @override
  String get contentReport_menuAction => 'Denunciar conteúdo';

  @override
  String get contentReport_dialogTitle => 'Denunciar conteúdo';

  @override
  String get contentReport_authenticationRequired => 'Você precisa estar conectado para denunciar conteúdo';

  @override
  String get contentReport_submittedMessage => 'Denúncia enviada';

  @override
  String get contentReport_alreadySubmittedMessage => 'Você já denunciou este conteúdo';

  @override
  String get contentReport_submitError => 'Não foi possível enviar a denúncia';

  @override
  String get contentReport_sendButton => 'Enviar';

  @override
  String get contentReport_reasonSpam => 'Spam';

  @override
  String get contentReport_reasonHarassment => 'Assédio ou abuso';

  @override
  String get contentReport_reasonHateSpeech => 'Discurso de ódio';

  @override
  String get contentReport_reasonMisinformation => 'Desinformação';

  @override
  String get contentReport_reasonViolence => 'Violência';

  @override
  String get contentReport_reasonOther => 'Outro';

  @override
  String get postDetail_title => 'Detalhes de Voce';

  @override
  String get postDetail_favoriteUpdateError => 'Não foi possível atualizar os itens salvos';

  @override
  String get postDetail_shareMessage => 'Abra o Social Vote para ver este Voce.';

  @override
  String get postDetail_shareError => 'Não foi possível compartilhar o Voce';

  @override
  String get postDetail_editDialogTitle => 'Editar Voce';

  @override
  String get postDetail_editTitleFieldLabel => 'Título';

  @override
  String get postDetail_editContentFieldLabel => 'Conteúdo';

  @override
  String get postDetail_editRequiredError => 'Título e conteúdo são obrigatórios.';

  @override
  String get postDetail_updateSuccess => 'Voce atualizado';

  @override
  String get postDetail_updateError => 'Não foi possível atualizar o Voce';

  @override
  String get postDetail_deleteDialogTitle => 'Excluir este Voce?';

  @override
  String get postDetail_deleteDialogMessage => 'Esta ação não pode ser desfeita.';

  @override
  String get postDetail_deleteError => 'Não foi possível excluir o Voce';

  @override
  String get postDetail_editMenuItem => 'Editar Voce';

  @override
  String get postDetail_deleteMenuItem => 'Excluir Voce';

  @override
  String get postDetail_loadError => 'Ocorreu um erro ao carregar o Voce.';

  @override
  String get postDetail_notFound => 'Voce não encontrado.';

  @override
  String get postDetail_errorTitle => 'Erro';

  @override
  String get postDetail_authorFallback => 'Autor';

  @override
  String get postDetail_shareAction => 'Compartilhar';

  @override
  String get postDetail_saveAction => 'Salvar';

  @override
  String get postDetail_addToFavoritesTooltip => 'Salvar';

  @override
  String get postDetail_removeFromFavoritesTooltip => 'Remover dos salvos';

  @override
  String get newsDetail_favoriteUpdateError => 'Não foi possível atualizar os itens salvos';

  @override
  String get newsDetail_shareMessage => 'Abra o Social Vote para ver esta notícia.';

  @override
  String get newsDetail_shareError => 'Não foi possível compartilhar a notícia';

  @override
  String get newsDetail_shareTooltip => 'Compartilhar';

  @override
  String get authLoginPageTitle => 'Entrar';

  @override
  String get authLoginHeadline => 'Bem-vindo de volta';

  @override
  String get authEmailLabel => 'E-mail';

  @override
  String get authPasswordLabel => 'Senha';

  @override
  String get authRememberMeLabel => 'Lembrar de mim';

  @override
  String get authForgotPasswordAction => 'Esqueceu a senha?';

  @override
  String get authLoginButton => 'Entrar';

  @override
  String get authRegisterPrompt => 'Não tem uma conta?';

  @override
  String get authRegisterAction => 'Cadastrar-se';

  @override
  String get authRegisterPageTitle => 'Cadastrar-se';

  @override
  String get authRegisterHeadline => 'Criar uma conta';

  @override
  String get authPersonalAccountOwnershipTitle => 'O login sempre pertence a uma pessoa';

  @override
  String get authPersonalAccountOwnershipBody => 'Se você representa uma organização, crie sua conta pessoal. Depois de entrar, você poderá solicitar uma Organização Verificada e gerenciá-la pelo Workspace.';

  @override
  String get authOrganizationPathAction => 'Como funciona para organizações';

  @override
  String get authDisplayNameLabel => 'Nome público';

  @override
  String get authUsernameLabel => 'Nome de usuário';

  @override
  String get authCountryOfResidenceLabel => 'País de residência';

  @override
  String get authCityOfResidenceLabel => 'Cidade de residência (opcional)';

  @override
  String get authConfirmPasswordLabel => 'Confirmar senha';

  @override
  String get authLegalConsentPrefix => 'Confirmo que tenho pelo menos 18 anos. Aceito os Termos de Serviço e confirmo que li a Política de Privacidade.';

  @override
  String get authTermsOfServiceAction => 'os Termos de Serviço';

  @override
  String get authPrivacyPolicyAction => 'a Política de Privacidade';

  @override
  String get authRegisterButton => 'Cadastrar-se';

  @override
  String get authLoginPrompt => 'Já tem uma conta?';

  @override
  String get authLoginAction => 'Entrar';

  @override
  String get authForgotPasswordDialogTitle => 'Redefinir senha';

  @override
  String get authForgotPasswordDialogBody => 'Digite o e-mail vinculado à sua conta. Enviaremos um link para você escolher uma nova senha.';

  @override
  String get authForgotPasswordSendButton => 'Enviar link';

  @override
  String get authPasswordResetEmailSent => 'E-mail de redefinição enviado. Verifique sua caixa de entrada.';

  @override
  String get authResetPasswordPageTitle => 'Redefinir senha';

  @override
  String get authResetPasswordHeadline => 'Escolha uma nova senha';

  @override
  String get authNewPasswordLabel => 'Nova senha';

  @override
  String get authConfirmNewPasswordLabel => 'Confirmar nova senha';

  @override
  String get authUpdatePasswordButton => 'Atualizar senha';

  @override
  String get authPasswordUpdated => 'Senha atualizada com sucesso.';

  @override
  String get authEmailConfirmationTitle => 'Verifique seu e-mail';

  @override
  String get authEmailConfirmationIntro => 'Enviamos um link de confirmação para:';

  @override
  String get authEmailConfirmationInstructions => 'Abra o link da mensagem para verificar seu endereço. Depois da confirmação, volte ao app e entre.';

  @override
  String get authBackToLoginButton => 'Voltar para o login';

  @override
  String get authUseAnotherEmailButton => 'Usar outro endereço de e-mail';

  @override
  String get authEmailRequiredError => 'Digite seu e-mail.';

  @override
  String get authEmailInvalidError => 'Digite um endereço de e-mail válido.';

  @override
  String get authPasswordRequiredError => 'Digite sua senha.';

  @override
  String get authPasswordTooShortError => 'A senha deve ter pelo menos 8 caracteres.';

  @override
  String get authDisplayNameRequiredError => 'Digite seu nome público.';

  @override
  String get authDisplayNameTooShortError => 'O nome público é muito curto.';

  @override
  String get authUsernameRequiredError => 'Digite um nome de usuário.';

  @override
  String get authUsernameInvalidError => 'Use de 3 a 20 caracteres: letras minúsculas, números e sublinhados.';

  @override
  String get authUsernameAlreadyTakenError => 'O nome de usuário já está em uso.';

  @override
  String get authCountryRequiredError => 'Selecione seu país de residência.';

  @override
  String get authCityRequiredError => 'Digite sua cidade de residência.';

  @override
  String get authConfirmPasswordRequiredError => 'Confirme sua senha.';

  @override
  String get authPasswordsDoNotMatchError => 'As senhas não coincidem.';

  @override
  String get authLegalConsentRequiredError => 'Para se cadastrar, confirme que tem pelo menos 18 anos, aceite os Termos de Serviço e confirme que leu a Política de Privacidade.';

  @override
  String get authForgotPasswordEmailRequiredError => 'Digite o e-mail da conta que você deseja recuperar.';

  @override
  String get authInvalidCredentialsError => 'E-mail ou senha inválidos.';

  @override
  String get authEmailAlreadyRegisteredError => 'Este e-mail já está cadastrado.';

  @override
  String get authEmailNotConfirmedError => 'E-mail não confirmado. Verifique sua caixa de entrada antes de entrar.';

  @override
  String get authTooManyAttemptsError => 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';

  @override
  String get authNetworkError => 'Erro de rede. Verifique sua conexão e tente novamente.';

  @override
  String get authLoginGenericError => 'Falha ao entrar. Tente novamente.';

  @override
  String get authRegisterGenericError => 'Falha no cadastro. Tente novamente.';

  @override
  String get authPasswordResetGenericError => 'Não foi possível enviar o link de redefinição. Tente novamente.';

  @override
  String get authPasswordUpdateGenericError => 'Não foi possível atualizar a senha. Tente novamente.';

  @override
  String get authShowPasswordTooltip => 'Mostrar senha';

  @override
  String get authHidePasswordTooltip => 'Ocultar senha';

  @override
  String get authTermsPageTitle => 'Termos de Serviço';

  @override
  String get authPrivacyPageTitle => 'Política de Privacidade';

  @override
  String get authCloseButton => 'Fechar';

  @override
  String get pollDetail_favoriteUpdateError => 'Não foi possível atualizar os itens salvos';

  @override
  String get pollDetail_shareMessage => 'Abra o Social Vote para ver e votar neste Vote.';

  @override
  String get pollDetail_shareError => 'Não foi possível compartilhar o Vote';

  @override
  String get pollDetail_editPermissionError => 'Você só pode editar seus próprios Vote sem votos registrados';

  @override
  String get pollDetail_editSuccessMessage => 'Vote atualizado';

  @override
  String get pollDetail_editMenuItem => 'Editar Vote';

  @override
  String get pollDetail_editSavingMenuItem => 'Salvando...';

  @override
  String get pollDetail_deletePermissionError => 'Você só pode excluir seus próprios Vote';

  @override
  String get pollDetail_deleteError => 'Não foi possível excluir o Vote';

  @override
  String get pollDetail_deleteDialogTitle => 'Excluir Vote';

  @override
  String pollDetail_deleteDialogMessage(String title) {
    return 'Deseja realmente excluir \"$title\"? Esta ação não pode ser desfeita.';
  }

  @override
  String get pollDetail_deleteMenuItem => 'Excluir Vote';

  @override
  String get pollDetail_deleteDeletingMenuItem => 'Excluindo...';

  @override
  String get pollDetail_publicVotesAvailableTitle => 'Votos públicos disponíveis';

  @override
  String get pollDetail_publicVotesAvailableMessage => 'Este Vote permite ver quem votou em cada opção.';

  @override
  String get pollDetail_publicVotesAction => 'Ver votos públicos';

  @override
  String get pollDetail_retryButton => 'Tentar novamente';

  @override
  String get pollDetail_voteErrorNoOption => 'Selecione pelo menos uma opção';

  @override
  String get pollDetail_voteErrorAuthenticationRequired => 'Você precisa estar conectado para votar';

  @override
  String get pollDetail_voteErrorClosed => 'Este Vote está encerrado';

  @override
  String get pollDetail_voteErrorAlreadyVoted => 'Você já votou neste Vote';

  @override
  String get pollDetail_voteErrorGeneric => 'Não foi possível enviar o voto';

  @override
  String get pollDetail_publicVotesSheetTitle => 'Votos públicos';

  @override
  String get pollDetail_publicVotesSheetDescription => 'Aqui você pode ver quem votou em cada opção deste Vote.';

  @override
  String get pollDetail_publicVotesSearchHint => 'Buscar usuários';

  @override
  String get pollDetail_publicVotesLoadError => 'Não foi possível carregar os votos públicos';

  @override
  String get pollDetail_publicVotesEmpty => 'Não há votos públicos disponíveis';

  @override
  String get pollDetail_publicVotesSearchEmpty => 'Nenhum usuário encontrado para esta busca';

  @override
  String pollDetail_publicVotesResultsCount(int count) {
    return '$count resultados carregados';
  }

  @override
  String get pollDetail_publicVotesLoadMore => 'Carregar mais';

  @override
  String get pollDetail_publicVotesUserFallback => 'Usuário';

  @override
  String get pollDetail_editDialogTitle => 'Editar Vote';

  @override
  String get pollDetail_editTitleFieldLabel => 'Título';

  @override
  String get pollDetail_editTitleRequired => 'O título é obrigatório';

  @override
  String get pollDetail_editDescriptionFieldLabel => 'Descrição';

  @override
  String get pollDetail_editError => 'Não foi possível atualizar o Vote';

  @override
  String get pollDetail_loadError => 'Não foi possível carregar o Vote';

  @override
  String get pollDetail_notFound => 'Vote não encontrado';

  @override
  String get profileEditPageTitle => 'Editar perfil';

  @override
  String get profileLoginRequiredMessage => 'Você precisa estar conectado para editar seu perfil.';

  @override
  String get profileAvatarUploading => 'Enviando...';

  @override
  String get profileUploadAvatarButton => 'Enviar avatar';

  @override
  String get profileDisplayNameLabel => 'Nome de exibição';

  @override
  String get profileDisplayNameRequiredError => 'O nome de exibição é obrigatório.';

  @override
  String get profileUsernameHint => 'ex.: mario_roma';

  @override
  String get profileUsernameHelper => '3–20 caracteres: letras minúsculas, números e sublinhados';

  @override
  String get profileAvatarUrlLabel => 'URL do avatar';

  @override
  String get profileBioLabel => 'Bio';

  @override
  String get profileClearCountryButton => 'Limpar país';

  @override
  String get profileCityResidenceHelper => 'A cidade de residência é verificada em relação ao país selecionado antes de salvar.';

  @override
  String get profileCityNotFoundError => 'Cidade não encontrada no país selecionado.';

  @override
  String get profileCityVerificationError => 'Não foi possível verificar a cidade agora.';

  @override
  String get profileAvatarUploadError => 'Não foi possível enviar o avatar.';

  @override
  String get profileAccountSectionTitle => 'Conta';

  @override
  String get profileAccountEmailHelper => 'O endereço de e-mail da conta não pode ser alterado nesta tela.';

  @override
  String get profileChangePasswordAction => 'Alterar senha';

  @override
  String get profileChangePasswordDescription => 'Defina uma nova senha para esta conta.';

  @override
  String get notificationsPageTitle => 'Notificações';

  @override
  String get notificationsMarkAllReadAction => 'Marcar tudo como lido';

  @override
  String get notificationsNoTargetMessage => 'Esta notificação não possui um destino disponível.';

  @override
  String get notificationsTargetUnavailableMessage => 'O conteúdo vinculado a esta notificação está indisponível.';

  @override
  String get notificationsLoadError => 'Não foi possível carregar as notificações.';

  @override
  String get notificationsRetryButton => 'Tentar novamente';

  @override
  String get notificationsEmptyMessage => 'Não há notificações disponíveis.';

  @override
  String get notificationsCommentReplyTitle => 'Nova resposta ao seu comentário';

  @override
  String get notificationsMentionTitle => 'Você foi mencionado';

  @override
  String get notificationsPollResultTitle => 'Atualização de Vote';

  @override
  String notificationsCommentReplySubtitle(String actor, String target) {
    return 'O usuário $actor respondeu em $target';
  }

  @override
  String notificationsMentionSubtitle(String actor, String target) {
    return 'O usuário $actor mencionou você em $target';
  }

  @override
  String notificationsPollResultSubtitle(String target) {
    return 'Um novo resultado está disponível em $target';
  }

  @override
  String get notificationsTargetPost => 'um Voce';

  @override
  String get notificationsTargetNews => 'uma notícia';

  @override
  String get notificationsTargetPoll => 'um Vote';

  @override
  String get notificationsTargetVideo => 'um vídeo';

  @override
  String get notificationsTargetContent => 'conteúdo';

  @override
  String get notificationsUserFallback => 'usuário';

  @override
  String get profileDeleteAccountAction => 'Excluir conta';

  @override
  String get profileDeleteAccountDescription => 'Excluir permanentemente a conta e o acesso';

  @override
  String get profileDeleteAccountDialogTitle => 'Excluir conta';

  @override
  String get profileDeleteAccountDialogMessage => 'Esta ação é permanente. A conta não poderá ser recuperada. Digite DELETE para confirmar.';

  @override
  String get profileDeleteAccountConfirmationLabel => 'Confirmação de exclusão';

  @override
  String get profileDeleteAccountConfirmationHint => 'Digite DELETE';

  @override
  String get profileDeleteAccountConfirmationError => 'Digite DELETE para continuar.';

  @override
  String get profileDeleteAccountCancelButton => 'Cancelar';

  @override
  String get profileDeleteAccountConfirmButton => 'Excluir permanentemente';

  @override
  String get profileDeleteAccountFailureMessage => 'Não foi possível excluir a conta. Tente novamente.';

  @override
  String get identityActorTypePerson => 'Pessoa';

  @override
  String get identityActorTypePublicOfficial => 'Agente público';

  @override
  String get identityActorTypePublicInstitution => 'Instituição pública';

  @override
  String get identityActorTypeVerifiedOrganization => 'Organização verificada';

  @override
  String get identityVerificationNotVerified => 'Não verificado';

  @override
  String get identityVerificationLevel1 => 'Identidade verificada';

  @override
  String get identityVerificationLevel2 => 'Identidade verificada avançada';

  @override
  String get identityBadgeLevel1 => 'Identidade verificada';

  @override
  String get identityBadgeLevel2 => 'Identidade verificada avançada';

  @override
  String get identityBadgePublicOfficial => 'Agente público';

  @override
  String get identityBadgePublicInstitution => 'Instituição pública';

  @override
  String get identityBadgeVerifiedOrganization => 'Organização verificada';

  @override
  String get identityOrganizationNameLabel => 'Nome da organização';

  @override
  String get identityOrganizationNameRequired => 'Digite o nome da organização.';

  @override
  String get identityInstitutionLevelMunicipality => 'Municipal';

  @override
  String get identityInstitutionLevelProvince => 'Provincial';

  @override
  String get identityInstitutionLevelRegion => 'Regional';

  @override
  String get identityInstitutionLevelMinistry => 'Ministério';

  @override
  String get identityInstitutionLevelGovernment => 'Governo';

  @override
  String get identityInstitutionLevelPublicAgency => 'Agência pública';

  @override
  String get identityInstitutionLevelOtherPublicBody => 'Outro órgão público';

  @override
  String get verificationRequestPersonLevel1 => 'Verificação de pessoa — Nível 1';

  @override
  String get verificationRequestPersonLevel2 => 'Verificação de pessoa — Nível 2';

  @override
  String get verificationRequestPublicOfficial => 'Verificação de agente público';

  @override
  String get verificationRequestPublicInstitution => 'Verificação de instituição pública';

  @override
  String get verificationRequestVerifiedOrganization => 'Verificação de organização';

  @override
  String get verificationCenterTitle => 'Verificação e tipo de conta';

  @override
  String get verificationCurrentAccountSection => 'Conta atual';

  @override
  String verificationAccountTypeValue(String accountType) {
    return 'Tipo de conta: $accountType';
  }

  @override
  String verificationLevelValue(String level) {
    return 'Nível de verificação: $level';
  }

  @override
  String verificationOfficialTitleValue(String title) {
    return 'Cargo oficial: $title';
  }

  @override
  String verificationInstitutionNameValue(String name) {
    return 'Instituição: $name';
  }

  @override
  String verificationOrganizationNameValue(String name) {
    return 'Organização: $name';
  }

  @override
  String verificationInstitutionLevelValue(String level) {
    return 'Nível da instituição: $level';
  }

  @override
  String get verificationActiveRequestSection => 'Solicitação ativa';

  @override
  String get verificationProfileUnchangedUntilApproval => 'Seu perfil atual não mudará até que a solicitação seja aprovada.';

  @override
  String get verificationCancelPendingAction => 'Cancelar solicitação pendente';

  @override
  String get verificationPendingBlocksNewRequests => 'Você não pode enviar uma nova solicitação enquanto houver outra pendente.';

  @override
  String get verificationNoActiveRequestSection => 'Sem solicitações ativas';

  @override
  String get verificationNoActiveRequestDescription => 'No momento, você não tem solicitações em análise.';

  @override
  String get verificationLastRejectedSection => 'Última solicitação rejeitada';

  @override
  String get verificationLastRejectedDescription => 'Sua última solicitação foi rejeitada.';

  @override
  String get verificationRejectedCanResubmit => 'Seu perfil atual não mudou. Você pode corrigir as informações e enviar uma nova solicitação.';

  @override
  String get verificationAvailableRequestsSection => 'Solicitações disponíveis';

  @override
  String get verificationRequestLevel1Title => 'Solicitar verificação de pessoa — Nível 1';

  @override
  String get verificationRequestLevel1Subtitle => 'Verificação básica de identidade pessoal';

  @override
  String get verificationRequestLevel2Title => 'Solicitar verificação de pessoa — Nível 2';

  @override
  String get verificationRequestLevel2Subtitle => 'Verificação avançada de identidade pessoal';

  @override
  String get verificationRequestPublicOfficialTitle => 'Solicitar uma conta de agente público';

  @override
  String get verificationRequestPublicOfficialSubtitle => 'Requer cargo oficial e análise';

  @override
  String get verificationRequestPublicInstitutionTitle => 'Solicitar uma conta de instituição pública';

  @override
  String get verificationRequestPublicInstitutionSubtitle => 'Requer nome da instituição, nível da instituição e análise';

  @override
  String get verificationRequestOrganizationTitle => 'Solicitar uma conta de organização verificada';

  @override
  String get verificationRequestOrganizationSubtitle => 'Requer dados da organização, função do representante e análise de um administrador';

  @override
  String get verificationNoSelfServiceUpgrade => 'Não há opções de verificação disponíveis para o status atual da sua conta.';

  @override
  String get verificationRequestSubmitSuccess => 'Solicitação enviada com sucesso.';

  @override
  String get verificationRequestSubmitFailure => 'Não foi possível enviar a solicitação.';

  @override
  String get verificationOfficialTitleDialogTitle => 'Verificação de agente público';

  @override
  String get verificationOfficialTitleLabel => 'Cargo oficial';

  @override
  String get verificationOfficialTitleHint => 'ex.: Prefeito, Vereador, Ministro';

  @override
  String get verificationInstitutionDialogTitle => 'Verificação de instituição pública';

  @override
  String get verificationInstitutionNameLabel => 'Nome da instituição';

  @override
  String get verificationInstitutionNameHint => 'ex.: Prefeitura de Roma';

  @override
  String get verificationInstitutionLevelLabel => 'Nível da instituição';

  @override
  String get verificationOrganizationDialogTitle => 'Verificação de organização';

  @override
  String get verificationOrganizationNameHint => 'ex.: Associação Meio Ambiente Itália';

  @override
  String get verificationSubmitRequestAction => 'Enviar solicitação';

  @override
  String get verificationCancelDialogTitle => 'Cancelar solicitação';

  @override
  String get verificationCancelDialogBody => 'Tem certeza de que deseja cancelar a solicitação de verificação pendente?';

  @override
  String get verificationCancelSuccess => 'Solicitação cancelada.';

  @override
  String get verificationCancelFailure => 'Não foi possível cancelar a solicitação.';

  @override
  String get verificationStatusPendingSuffix => 'solicitação em análise';

  @override
  String get verificationStatusRejectedSuffix => 'última solicitação rejeitada';

  @override
  String get verificationReviewPageTitle => 'Análise de verificação';

  @override
  String get verificationReviewLoginRequired => 'Você precisa estar conectado para analisar solicitações de verificação.';

  @override
  String verificationReviewPendingCount(int count) {
    return 'Solicitações pendentes: $count';
  }

  @override
  String get verificationReviewNoPendingRequests => 'Não há solicitações de verificação pendentes.';

  @override
  String get verificationReviewUserIdLabel => 'ID do usuário';

  @override
  String get verificationReviewSubmittedLabel => 'Enviada';

  @override
  String get verificationReviewOfficialTitleLabel => 'Cargo oficial';

  @override
  String get verificationReviewInstitutionLabel => 'Instituição';

  @override
  String get verificationReviewOrganizationLabel => 'Organização';

  @override
  String get verificationReviewNoteLabel => 'Nota da análise';

  @override
  String get verificationReviewRejectAction => 'Rejeitar';

  @override
  String get verificationReviewApproveAction => 'Aprovar';

  @override
  String get verificationReviewApproveDialogTitle => 'Aprovar solicitação';

  @override
  String get verificationReviewRejectDialogTitle => 'Rejeitar solicitação';

  @override
  String get verificationReviewApproveConfirmation => 'Confirmar a aprovação desta solicitação?';

  @override
  String get verificationReviewRejectConfirmation => 'Confirmar a rejeição desta solicitação?';

  @override
  String get verificationReviewOptionalNoteLabel => 'Nota opcional da análise';

  @override
  String get verificationReviewRequiredNoteLabel => 'Motivo da rejeição';

  @override
  String get verificationReviewOptionalHelper => 'Opcional';

  @override
  String get verificationReviewRequiredHelper => 'Obrigatório ao rejeitar';

  @override
  String get verificationReviewRequiredNoteError => 'Digite o motivo da rejeição.';

  @override
  String get verificationReviewApprovedSuccess => 'Solicitação aprovada.';

  @override
  String get verificationReviewRejectedSuccess => 'Solicitação rejeitada.';

  @override
  String get verificationReviewOperationFailure => 'A operação falhou.';

  @override
  String get adminCenterTitle => 'Central de Administração';

  @override
  String get adminCenterDashboardNavigation => 'Painel';

  @override
  String get adminCenterUsersNavigation => 'Usuários';

  @override
  String get adminCenterVerificationNavigation => 'Verificação';

  @override
  String get adminCenterReportsNavigation => 'Denúncias';

  @override
  String get adminCenterAuditNavigation => 'Auditoria';

  @override
  String get adminCenterAccountDetailsTitle => 'Detalhes da conta';

  @override
  String get adminCenterTryAgainAction => 'Tentar novamente';

  @override
  String get adminCenterRetryAction => 'Tentar novamente';

  @override
  String get adminCenterClearAction => 'Limpar';

  @override
  String get adminCenterApplyFiltersAction => 'Aplicar filtros';

  @override
  String get adminCenterAllDates => 'Todas as datas';

  @override
  String get adminCenterAuditDateFilterHelp => 'Filtrar auditoria por data';

  @override
  String get adminCenterActorUserIdLabel => 'ID do usuário ator';

  @override
  String get adminCenterActionLabel => 'Ação';

  @override
  String get adminCenterAuditActionHint => 'resolve_escalated_report';

  @override
  String get adminCenterTargetIdLabel => 'ID do alvo';

  @override
  String get adminCenterOutcomeLabel => 'Resultado';

  @override
  String get adminCenterAllOutcomes => 'Todos os resultados';

  @override
  String get adminCenterOutcomeSuccess => 'Sucesso';

  @override
  String get adminCenterOutcomeFailure => 'Falha';

  @override
  String get adminCenterOutcomeDenied => 'Negado';

  @override
  String get adminCenterOutcomeNoChange => 'Sem alteração';

  @override
  String get adminCenterOutcomeUnknown => 'Desconhecido';

  @override
  String get adminCenterAuditUnavailableTitle => 'Auditoria indisponível';

  @override
  String get adminCenterAuditUnavailableMessage => 'Verifique sua conexão e suas permissões e tente novamente.';

  @override
  String get adminCenterNoAuditEntriesTitle => 'Sem registros de auditoria';

  @override
  String get adminCenterNoAuditEntriesMessage => 'Não há registros que correspondam aos filtros selecionados.';

  @override
  String get adminCenterAuditIdLabel => 'ID da auditoria';

  @override
  String get adminCenterActorLabel => 'Ator';

  @override
  String get adminCenterReasonLabel => 'Motivo';

  @override
  String get adminCenterTimestampLabel => 'Data e hora';

  @override
  String get adminCenterErrorLabel => 'Erro';

  @override
  String get adminCenterRecordedValuesTitle => 'Valores registrados';

  @override
  String get adminCenterPreviousValueLabel => 'Anterior';

  @override
  String get adminCenterNewValueLabel => 'Novo';

  @override
  String get adminCenterContentTypeLabel => 'Tipo de conteúdo';

  @override
  String get adminCenterAllContent => 'Todo o conteúdo';

  @override
  String get adminCenterPolls => 'Vote';

  @override
  String get adminCenterPosts => 'Voce';

  @override
  String get adminCenterNews => 'News';

  @override
  String get adminCenterAwaitingAdminDecision => 'Aguardando decisão do administrador';

  @override
  String get adminCenterStatusLabel => 'Status';

  @override
  String get adminCenterAllStatuses => 'Todos os status';

  @override
  String get adminCenterStatusOpen => 'Aberto';

  @override
  String get adminCenterStatusInReview => 'Em análise';

  @override
  String get adminCenterStatusResolved => 'Resolvido';

  @override
  String get adminCenterStatusDismissed => 'Descartado';

  @override
  String get adminCenterAdminQueueUnavailableTitle => 'Fila de escalonamento administrativo indisponível';

  @override
  String get adminCenterReportsUnavailableTitle => 'Denúncias indisponíveis';

  @override
  String get adminCenterConnectionTryAgainMessage => 'Verifique sua conexão e tente novamente.';

  @override
  String get adminCenterNoAdminReportsTitle => 'Não há denúncias aguardando decisão do administrador';

  @override
  String get adminCenterNoReportsTitle => 'Não há denúncias';

  @override
  String get adminCenterNoAdminReportsMessage => 'Não há denúncias escaladas que exijam análise de um administrador.';

  @override
  String get adminCenterNoReportsMessage => 'Não há denúncias que correspondam aos filtros selecionados.';

  @override
  String get adminCenterSearchUsersHint => 'Buscar por nome, usuário, e-mail ou ID';

  @override
  String get adminCenterClearSearchTooltip => 'Limpar busca';

  @override
  String get adminCenterUsersUnavailableTitle => 'Usuários indisponíveis';

  @override
  String get adminCenterNoUsersFoundTitle => 'Nenhum usuário encontrado';

  @override
  String get adminCenterNoUsersTitle => 'Não há usuários';

  @override
  String get adminCenterNoUsersFoundMessage => 'Tente outro nome, usuário, e-mail ou ID.';

  @override
  String get adminCenterNoUsersMessage => 'Não há contas para exibir.';

  @override
  String get adminCenterAccountUnavailableTitle => 'Conta indisponível';

  @override
  String get adminCenterBackToUsersAction => 'Voltar para usuários';

  @override
  String get adminCenterPublicIdentitySection => 'Identidade pública';

  @override
  String get adminCenterDisplayNameLabel => 'Nome de exibição';

  @override
  String get adminCenterNotProvided => 'Não informado';

  @override
  String get adminCenterUsernameLabel => 'Nome de usuário';

  @override
  String get adminCenterUserIdLabel => 'ID do usuário';

  @override
  String get adminCenterIdentityTypeLabel => 'Tipo de identidade';

  @override
  String get adminCenterAccountSection => 'Conta';

  @override
  String get adminCenterTechnicalRoleLabel => 'Função técnica';

  @override
  String get adminCenterRoleMirrorLabel => 'Espelho da função no perfil';

  @override
  String get adminCenterRoleSynchronizationLabel => 'Sincronização de funções';

  @override
  String get adminCenterSynchronized => 'Sincronizado';

  @override
  String get adminCenterNotSynchronized => 'Não sincronizado';

  @override
  String get adminCenterRoleNotSynchronized => 'Função não sincronizada';

  @override
  String get adminCenterAccountStatusLabel => 'Status da conta';

  @override
  String get adminCenterSuspendedUntilLabel => 'Suspensa até';

  @override
  String get adminCenterAccountManagementSection => 'Gerenciamento da conta';

  @override
  String get adminCenterDangerZoneSection => 'Zona de risco';

  @override
  String get adminCenterRoleManagementSection => 'Gerenciamento de funções';

  @override
  String get adminCenterVerificationLevelLabel => 'Nível de verificação';

  @override
  String get adminCenterVerificationStatusLabel => 'Status da verificação';

  @override
  String get adminCenterAccessInformationSection => 'Informações de acesso';

  @override
  String get adminCenterEmailLabel => 'E-mail';

  @override
  String get adminCenterNotAvailable => 'Indisponível';

  @override
  String get adminCenterEmailConfirmationLabel => 'Confirmação do e-mail';

  @override
  String get adminCenterNotConfirmed => 'Não confirmado';

  @override
  String get adminCenterRegisteredLabel => 'Cadastrado';

  @override
  String get adminCenterLastAccessLabel => 'Último acesso';

  @override
  String get adminCenterLoadingDashboardTitle => 'Carregando painel';

  @override
  String get adminCenterLoadingDashboardMessage => 'Obtendo os indicadores mais recentes.';

  @override
  String get adminCenterDashboardUnavailableTitle => 'Painel indisponível';

  @override
  String get adminCenterIndicatorsUnavailableMessage => 'Não foi possível carregar os indicadores.';

  @override
  String get adminCenterVerificationPendingIndicator => 'Verificações pendentes';

  @override
  String get adminCenterOpenReportsIndicator => 'Denúncias abertas';

  @override
  String get adminCenterSuspendedAccountsIndicator => 'Contas suspensas';

  @override
  String get adminCenterStaffIndicator => 'Equipe';

  @override
  String get adminCenterNoPendingWorkTitle => 'Não há trabalho pendente';

  @override
  String get adminCenterNoPendingWorkMessage => 'Não há verificações, denúncias nem contas suspensas pendentes.';

  @override
  String get adminCenterCouldNotUpdateUsers => 'Não foi possível atualizar a lista de usuários.';

  @override
  String get adminCenterCouldNotUpdateReports => 'Não foi possível atualizar a fila de denúncias.';

  @override
  String get adminCenterUnnamedUser => 'Usuário sem nome';

  @override
  String get adminCenterTemporarySuspensionTitle => 'Suspensão temporária';

  @override
  String get adminCenterReactivateDescription => 'Remova a suspensão imediatamente e permita um novo login.';

  @override
  String get adminCenterSuspendDescription => 'Bloqueie o acesso por tempo limitado e encerre todas as sessões atuais.';

  @override
  String get adminCenterSuspensionUnavailableDescription => 'A suspensão exige uma conta sincronizada que não seja de administrador.';

  @override
  String get adminCenterReactivateAccountAction => 'Reativar conta';

  @override
  String get adminCenterSuspendAccountAction => 'Suspender conta';

  @override
  String get adminCenterForceLogoutAction => 'Forçar logout';

  @override
  String get adminCenterSuspendedForceLogoutDescription => 'A suspensão já encerrou as sessões atuais. Reative a conta antes de testar um logout separado.';

  @override
  String get adminCenterForceLogoutDescription => 'Encerre todas as sessões atuais sem suspender a conta.';

  @override
  String get adminCenterForceLogoutUnavailableDescription => 'O logout forçado exige uma conta sincronizada que não seja de administrador.';

  @override
  String get adminCenterPermanentDeletionTitle => 'Exclusão permanente da conta';

  @override
  String get adminCenterPermanentDeletionDescription => 'Exclua os dados de autenticação, encerre todas as sessões e anonimize o registro público mantido.';

  @override
  String get adminCenterDeletionUnavailableDescription => 'A exclusão exige uma conta sincronizada que não seja de administrador.';

  @override
  String get adminCenterDeleteAccountPermanentlyAction => 'Excluir conta permanentemente';

  @override
  String get adminCenterDurationOneHour => '1 hora';

  @override
  String get adminCenterDurationOneDay => '24 horas';

  @override
  String get adminCenterDurationSevenDays => '7 dias';

  @override
  String get adminCenterDurationThirtyDays => '30 dias';

  @override
  String get adminCenterSuspendImmediateEffect => 'A conta perderá o acesso imediatamente e todas as sessões atuais serão encerradas.';

  @override
  String get adminCenterDurationLabel => 'Duração';

  @override
  String get adminCenterSuspendReasonHint => 'Explique por que esta conta deve ser suspensa';

  @override
  String get adminCenterReactivateReasonHint => 'Explique por que esta conta pode ser reativada';

  @override
  String get adminCenterReactivateConfirmation => 'Confirmo que esta conta pode recuperar o acesso.';

  @override
  String get adminCenterReactivateFailure => 'Não foi possível reativar a conta. Verifique sua função e status e tente novamente.';

  @override
  String get adminCenterReactivateSuccess => 'Conta reativada. Um novo login agora é permitido.';

  @override
  String get adminCenterForceLogoutFullDescription => 'Encerre todas as sessões atuais desta conta. A conta permanece ativa e pode entrar novamente.';

  @override
  String get adminCenterForceLogoutReasonHint => 'Explique por que as sessões atuais devem ser encerradas';

  @override
  String get adminCenterForceLogoutConfirmation => 'Confirmo o encerramento imediato de todas as sessões atuais desta conta.';

  @override
  String get adminCenterForceLogoutFailure => 'Não foi possível desconectar a conta. Verifique sua função e status e tente novamente.';

  @override
  String get adminCenterForceLogoutSuccess => 'Sessões atuais encerradas. A conta pode entrar novamente.';

  @override
  String get adminCenterSuspendFailure => 'Não foi possível suspender a conta. Verifique sua função e status e tente novamente.';

  @override
  String get adminCenterDeleteReasonHint => 'Explique por que esta conta deve ser excluída';

  @override
  String get adminCenterTypeDeleteLabel => 'Digite DELETE';

  @override
  String get adminCenterTypeAccountIdLabel => 'Digite o ID completo da conta';

  @override
  String get adminCenterDeletePermanentlyAction => 'Excluir permanentemente';

  @override
  String get adminCenterDeleteIrreversibleWarning => 'Esta ação é irreversível. Os dados de autenticação e as sessões atuais serão removidos, o avatar será excluído e o registro público mantido será anonimizado. O registro de auditoria permanecerá.';

  @override
  String get adminCenterDeleteFailure => 'Não foi possível excluir a conta. Verifique sua função, status e valores de confirmação e tente novamente.';

  @override
  String get adminCenterDeleteSuccess => 'Conta excluída permanentemente e dados pessoais anonimizados.';

  @override
  String get adminCenterChangeTechnicalRoleTitle => 'Alterar função técnica';

  @override
  String get adminCenterChangeRoleDescription => 'Revise a função atual e a solicitada antes de confirmar.';

  @override
  String get adminCenterChangeRoleUnavailableDescription => 'Alterações de função exigem uma conta sincronizada e não excluída.';

  @override
  String get adminCenterChangeRoleAction => 'Alterar função';

  @override
  String get adminCenterChangePublicIdentityTitle => 'Alterar identidade pública';

  @override
  String get adminCenterChangeIdentityDescription => 'Atualize o tipo de conta pública e o nível de verificação.';

  @override
  String get adminCenterChangeIdentityUnavailableDescription => 'Alterações de identidade exigem uma conta sincronizada que não seja de administrador.';

  @override
  String get adminCenterChangeIdentityAction => 'Alterar identidade';

  @override
  String get adminCenterChoosePublicIdentityMessage => 'Escolha o tipo de conta pública e seu status de verificação.';

  @override
  String get adminCenterPublicAccountTypeLabel => 'Tipo de conta pública';

  @override
  String get adminCenterPersonVerificationHelper => 'Nível 1 e Nível 2 estão disponíveis somente para Pessoa.';

  @override
  String get adminCenterNonPersonVerificationHelper => 'Contas que não são Pessoa não usam Nível 1 nem Nível 2.';

  @override
  String get adminCenterBeforeLabel => 'Antes';

  @override
  String get adminCenterAfterLabel => 'Depois';

  @override
  String get adminCenterIdentityReasonHint => 'Explique por que a identidade pública deve mudar';

  @override
  String get adminCenterIdentityConfirmation => 'Confirmo a identidade pública e o nível de verificação mostrados acima.';

  @override
  String get adminCenterIdentityChangeFailure => 'Não foi possível alterar a identidade pública. Verifique o status da conta e tente novamente.';

  @override
  String get adminCenterChooseTechnicalRoleMessage => 'Escolha a nova função técnica e registre por que essa alteração é necessária.';

  @override
  String get adminCenterNewTechnicalRoleLabel => 'Nova função técnica';

  @override
  String get adminCenterSelectRole => 'Selecionar uma função';

  @override
  String get adminCenterRoleSessionWarning => 'Essa alteração encerra a sessão ativa do destinatário. Ele precisará entrar novamente antes de continuar usando a conta.';

  @override
  String get adminCenterRoleReasonHint => 'Explique por que a função técnica deve mudar';

  @override
  String get adminCenterRoleConfirmation => 'Confirmo a função mostrada acima e entendo que o destinatário deve entrar novamente.';

  @override
  String get adminCenterRoleChangeFailure => 'Não foi possível concluir a alteração da função. Verifique o status da conta e tente novamente.';

  @override
  String get adminCenterChangingRole => 'Alterando função';

  @override
  String get adminCenterConfirmRoleChange => 'Confirmar alteração da função';

  @override
  String get adminCenterRoleUser => 'Usuário';

  @override
  String get adminCenterRoleModerator => 'Moderador';

  @override
  String get adminCenterRoleAdmin => 'Administrador';

  @override
  String get adminCenterAccountStatusActive => 'Ativa';

  @override
  String get adminCenterAccountStatusSuspended => 'Suspensa';

  @override
  String get adminCenterAccountStatusDeleted => 'Excluída';

  @override
  String get adminCenterVerificationStatusNone => 'Nenhum';

  @override
  String get adminCenterVerificationStatusPending => 'Pendente';

  @override
  String get adminCenterVerificationStatusRejected => 'Rejeitada';

  @override
  String get adminCenterVerificationNotVerified => 'Não verificado';

  @override
  String get adminCenterVerificationLevel1 => 'Nível 1';

  @override
  String get adminCenterVerificationLevel2 => 'Nível 2';

  @override
  String get adminCenterReportSingular => 'denúncia';

  @override
  String get adminCenterReportPlural => 'denúncias';

  @override
  String get adminCenterUserSingular => 'usuário';

  @override
  String get adminCenterUserPlural => 'usuários';

  @override
  String get adminCenterPoll => 'Vote';

  @override
  String get adminCenterPost => 'Voce';

  @override
  String get adminCenterUnknown => 'Desconhecido';

  @override
  String get adminCenterContentHidden => 'Conteúdo oculto';

  @override
  String get adminCenterContentVisible => 'Conteúdo visível';

  @override
  String get adminCenterReportedByLabel => 'Denunciado por';

  @override
  String get adminCenterContentOwnerLabel => 'Proprietário do conteúdo';

  @override
  String get adminCenterReviewReportAction => 'Analisar denúncia';

  @override
  String get adminCenterAdminDecisionAction => 'Decisão do administrador';

  @override
  String get adminCenterRestoreContentAction => 'Restaurar conteúdo';

  @override
  String get adminCenterHideContentAction => 'Ocultar conteúdo';

  @override
  String get adminCenterOpenProfileAction => 'Abrir perfil';

  @override
  String get adminCenterOpenContentAction => 'Abrir conteúdo';

  @override
  String get adminCenterDecisionNoViolation => 'Sem violação';

  @override
  String get adminCenterDecisionViolationConfirmed => 'Violação confirmada';

  @override
  String get adminCenterDecisionEscalateToAdmin => 'Escalonar para administrador';

  @override
  String get adminCenterResolutionNoAccountAction => 'Nenhuma ação na conta';

  @override
  String get adminCenterResolutionAccountSuspended => 'Conta suspensa';

  @override
  String get adminCenterResolutionLogoutForced => 'Logout forçado';

  @override
  String get adminCenterResolutionAccountDeleted => 'Conta excluída';

  @override
  String get adminCenterReviewerLabel => 'Revisor';

  @override
  String get adminCenterDecisionDescriptionNoViolation => 'Descarta a denúncia porque o conteúdo não viola as regras atuais.';

  @override
  String get adminCenterDecisionDescriptionViolation => 'Confirma uma violação e mantém o caso em análise para a ação de conteúdo tratada em AC8.5.';

  @override
  String get adminCenterDecisionDescriptionEscalation => 'Escalona o caso para uma análise do administrador no nível da conta.';

  @override
  String get adminCenterChooseModerationOutcome => 'Escolha o resultado da moderação para esta denúncia.';

  @override
  String get adminCenterDecisionAlreadyRecordedFailure => 'Não foi possível registrar a decisão. A denúncia pode já ter sido analisada. Atualize a fila e tente novamente.';

  @override
  String get adminCenterDecisionLabel => 'Decisão';

  @override
  String get adminCenterReportReasonLabel => 'Motivo da denúncia';

  @override
  String get adminCenterReviewNoteLabel => 'Nota da análise';

  @override
  String get adminCenterReviewNoteHint => 'Explique as evidências e a decisão de moderação';

  @override
  String get adminCenterRecordingDecision => 'Registrando decisão';

  @override
  String get adminCenterConfirmDecision => 'Confirmar decisão';

  @override
  String get adminCenterAdministratorDecisionTitle => 'Decisão do administrador';

  @override
  String get adminCenterResolutionDescriptionNoAction => 'Encerra a denúncia escalada sem alterar a conta.';

  @override
  String get adminCenterResolutionDescriptionSuspended => 'Encerra a denúncia depois que uma suspensão bem-sucedida da conta já tiver sido registrada no log de auditoria.';

  @override
  String get adminCenterResolutionDescriptionLogout => 'Encerra a denúncia depois que um logout forçado bem-sucedido já tiver sido registrado no log de auditoria.';

  @override
  String get adminCenterResolutionDescriptionDeleted => 'Encerra a denúncia depois que uma exclusão bem-sucedida da conta já tiver sido registrada no log de auditoria.';

  @override
  String get adminCenterChooseFinalOutcome => 'Escolha o resultado final do administrador para este escalonamento.';

  @override
  String get adminCenterAdminResolutionFailure => 'Não foi possível registrar a decisão do administrador. Atualize a fila e tente novamente.';

  @override
  String get adminCenterAdminResolutionRequiresAction => 'Conclua primeiro a ação correspondente na conta; depois volte a esta denúncia e registre a decisão final do administrador.';

  @override
  String get adminCenterEscalationNoteLabel => 'Nota de escalonamento';

  @override
  String get adminCenterFinalOutcomeLabel => 'Resultado final';

  @override
  String get adminCenterAdministratorNoteLabel => 'Nota do administrador';

  @override
  String get adminCenterAdministratorNoteHint => 'Explique a decisão final no nível da conta';

  @override
  String get adminCenterHideContentFailure => 'Não foi possível ocultar o conteúdo. Atualize a fila de denúncias e tente novamente.';

  @override
  String get adminCenterRestoreContentFailure => 'Não foi possível restaurar o conteúdo. Atualize a fila de denúncias e tente novamente.';

  @override
  String get adminCenterHideContentWarning => 'Isso remove o conteúdo denunciado do acesso público. A ação poderá ser revertida depois pelo filtro de denúncias resolvidas.';

  @override
  String get adminCenterRestoreContentWarning => 'Isso torna o conteúdo denunciado público novamente.';

  @override
  String get adminCenterActionReasonLabel => 'Motivo da ação';

  @override
  String get adminCenterHideContentReasonHint => 'Explique por que o conteúdo deve ser ocultado';

  @override
  String get adminCenterRestoreContentReasonHint => 'Explique por que o conteúdo pode ser restaurado';

  @override
  String get adminCenterHidingContent => 'Ocultando conteúdo';

  @override
  String get adminCenterRestoringContent => 'Restaurando conteúdo';

  @override
  String get adminCenterReportedProfileTitle => 'Perfil denunciado';

  @override
  String get adminCenterReportedProfileNotice => 'Este contexto do perfil vem da fila protegida de denúncias. As ações administrativas na conta continuam separadas.';

  @override
  String get adminCenterCouldNotRefreshIndicators => 'Não foi possível atualizar os indicadores.';

  @override
  String get adminCenterCouldNotRefreshAccount => 'Não foi possível atualizar os detalhes da conta.';

  @override
  String get adminCenterReportAlreadyReviewed => 'Esta denúncia já foi analisada ou não está mais pendente.';

  @override
  String get adminCenterReportNotAwaitingAdmin => 'Esta denúncia não está aguardando uma decisão do administrador.';

  @override
  String get adminCenterConfirmedViolationRequired => 'É necessária uma violação confirmada antes de alterar a visibilidade do conteúdo.';

  @override
  String get adminCenterContentHiddenSuccess => 'O conteúdo denunciado foi ocultado.';

  @override
  String get adminCenterContentRestoredSuccess => 'O conteúdo denunciado foi restaurado.';

  @override
  String get adminCenterMissingContentId => 'O identificador original do conteúdo está ausente.';

  @override
  String get adminCenterUnsupportedTargetType => 'Esta denúncia possui um tipo de alvo não suportado.';

  @override
  String get adminCenterOriginalContentUnavailable => 'O conteúdo original não está mais disponível.';

  @override
  String get adminCenterNoReportedProfile => 'Nenhum perfil denunciado está associado a este conteúdo.';

  @override
  String adminCenterRoleChangedSuccess(String previousRole, String newRole) {
    return 'Função técnica alterada de $previousRole para $newRole. O destinatário foi desconectado e precisa entrar novamente.';
  }

  @override
  String adminCenterIdentityChangedSuccess(String actorType, String verificationLevel) {
    return 'Identidade pública alterada para $actorType com $verificationLevel.';
  }

  @override
  String adminCenterAccountSuspendedSuccess(String dateTime) {
    return 'Conta suspensa até $dateTime. O destinatário foi desconectado.';
  }

  @override
  String adminCenterReportDecisionRecorded(String decision) {
    return 'Decisão da denúncia registrada: $decision.';
  }

  @override
  String adminCenterAdministratorDecisionRecorded(String decision) {
    return 'Decisão do administrador registrada: $decision.';
  }

  @override
  String adminCenterUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count usuários',
      one: '$count usuário',
    );
    return '$_temp0';
  }

  @override
  String adminCenterReportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count denúncias',
      one: '$count denúncia',
    );
    return '$_temp0';
  }

  @override
  String adminCenterAccountValue(String account) {
    return 'Conta: $account';
  }

  @override
  String adminCenterSuspendedUntilValue(String dateTime) {
    return 'Suspensa até: $dateTime';
  }

  @override
  String adminCenterSuspendConfirmation(String dateTime) {
    return 'Confirmo a suspensão até $dateTime e o encerramento imediato das sessões atuais.';
  }

  @override
  String adminCenterAccountIdValue(String accountId) {
    return 'ID da conta: $accountId';
  }

  @override
  String adminCenterCurrentRoleValue(String role) {
    return 'Atual: $role';
  }

  @override
  String adminCenterTargetFallback(String targetType, String targetId) {
    return '$targetType $targetId';
  }

  @override
  String adminCenterMinimumCharactersRequired(int count) {
    return 'É necessária uma nota de pelo menos $count caracteres.';
  }

  @override
  String adminCenterMinimumReasonCharactersRequired(int count) {
    return 'É necessário um motivo de pelo menos $count caracteres.';
  }

  @override
  String adminCenterPageOf(int currentPage, int totalPages) {
    return 'Página $currentPage de $totalPages';
  }

  @override
  String get profilePublicProfileSectionTitle => 'Perfil público';

  @override
  String get profileIdentityVerificationSectionTitle => 'Identidade e verificação';

  @override
  String get profilePreferencesSectionTitle => 'Preferências';

  @override
  String get profileNotificationsSectionTitle => 'Notificações';

  @override
  String get profileActivitySectionTitle => 'Atividade pessoal';

  @override
  String get profileSecurityAccountSectionTitle => 'Segurança e conta';

  @override
  String get profileThemeTitle => 'Tema';

  @override
  String get profileThemeSystem => 'Sistema';

  @override
  String get profileThemeSystemDescription => 'Segue o tema do dispositivo';

  @override
  String get profileThemeLight => 'Claro';

  @override
  String get profileThemeDark => 'Escuro';

  @override
  String get profileMyPollsTitle => 'Vote';

  @override
  String get profileMyPostsTitle => 'Voce';

  @override
  String get profileMyCommentsTitle => 'Meus comentários';

  @override
  String get profileMyFavoritesTitle => 'Meus salvos';

  @override
  String get profileAccountConnectionsTitle => 'Seguindo e seguidores';

  @override
  String get accountConnectionsFollowingTab => 'Seguindo';

  @override
  String get accountConnectionsFollowersTab => 'Seguidores';

  @override
  String get accountConnectionsEmptyFollowing => 'Você ainda não segue nenhuma conta.';

  @override
  String get accountConnectionsEmptyFollowers => 'Você ainda não tem seguidores.';

  @override
  String get accountConnectionsLoadError => 'Não foi possível carregar as contas. Tente novamente.';

  @override
  String get profileMyFollowedScopesTitle => 'Minhas áreas seguidas';

  @override
  String get profileLogoutAction => 'Sair';

  @override
  String get profileLogoutDescription => 'Sair da conta atual';

  @override
  String get profileLogoutDialogTitle => 'Sair';

  @override
  String get profileLogoutDialogMessage => 'Tem certeza de que deseja sair da sua conta?';

  @override
  String get profileLogoutCancelButton => 'Cancelar';

  @override
  String get profileLogoutConfirmButton => 'Sair';

  @override
  String get publicProfilePageTitle => 'Perfil público';

  @override
  String get publicProfileUserFallback => 'Usuário';

  @override
  String get publicProfileNoBio => 'Nenhuma bio disponível.';

  @override
  String get publicProfileResidenceLabel => 'Residência';

  @override
  String get publicProfileResidenceUnknown => 'Não informada';

  @override
  String get publicProfileMemberSinceLabel => 'Membro desde';

  @override
  String get publicProfileContentSectionTitle => 'Conteúdo público';

  @override
  String get publicProfilePollsAction => 'Vote';

  @override
  String get publicProfilePostsAction => 'Voce';

  @override
  String get publicProfileBlockUserAction => 'Bloquear usuário';

  @override
  String get publicProfileLoadError => 'Não foi possível carregar o perfil.';

  @override
  String get publicProfileNotFound => 'Perfil indisponível.';

  @override
  String get publicProfileUnblockUserAction => 'Desbloquear usuário';

  @override
  String get publicProfileBlockDialogTitle => 'Bloquear este usuário?';

  @override
  String get publicProfileBlockDialogMessage => 'Você poderá desbloqueá-lo depois pelo perfil público.';

  @override
  String get publicProfileUnblockDialogTitle => 'Desbloquear este usuário?';

  @override
  String get publicProfileUnblockDialogMessage => 'O usuário deixará de estar na sua lista de bloqueados.';

  @override
  String get publicProfileBlockSuccess => 'Usuário bloqueado.';

  @override
  String get publicProfileUnblockSuccess => 'Usuário desbloqueado.';

  @override
  String get publicProfileBlockError => 'Não foi possível atualizar o bloqueio. Tente novamente.';

  @override
  String get publicProfileFollowersLabel => 'seguidores';

  @override
  String get publicProfileFollowingLabel => 'seguindo';

  @override
  String get publicProfileFollowAction => 'Seguir';

  @override
  String get publicProfileUnfollowAction => 'Deixar de seguir';

  @override
  String get publicProfileFollowSuccess => 'Conta seguida.';

  @override
  String get publicProfileUnfollowSuccess => 'Você deixou de seguir a conta.';

  @override
  String get publicProfileFollowError => 'Não foi possível atualizar o acompanhamento. Tente novamente.';

  @override
  String get publicProfileFollowRetry => 'Recarregar informações de acompanhamento';

  @override
  String get contentLanguageFieldLabel => 'Idioma do conteúdo';

  @override
  String get contentLanguageFieldHelper => 'Selecione o idioma em que você escreveu o conteúdo.';

  @override
  String get contentLanguageUndetermined => 'Não informado';

  @override
  String get createPollAdvancedOptionsTitle => 'Opções avançadas';

  @override
  String get createPollAdvancedOptionsSubtitle => 'Anonimato, visibilidade dos resultados, alteração de voto e quórum.';

  @override
  String get onboardingSkipButton => 'Pular';

  @override
  String get onboardingNextButton => 'Próximo';

  @override
  String get onboardingStartButton => 'Começar';

  @override
  String get onboardingPollTitle => 'Vote';

  @override
  String get onboardingPollDescription => 'Participe de um Vote sobre temas importantes para você ou crie um para coletar a opinião da comunidade.';

  @override
  String get onboardingHeatIceTitle => 'Heat e Ice';

  @override
  String get onboardingHeatIceDescription => 'Use Heat e Ice para mostrar com que intensidade um conteúdo está atraindo seu interesse.';

  @override
  String get onboardingCivicMapTitle => 'Mapa Cívico';

  @override
  String get onboardingCivicMapDescription => 'Explore Vote, Voce e News no mapa e descubra o que está acontecendo em diferentes áreas.';

  @override
  String get onboardingGeoScopeTitle => 'GeoScope';

  @override
  String get onboardingGeoScopeDescription => 'Escolha o nível geográfico que deseja seguir: mundo, país ou cidade.';

  @override
  String get onboardingVerificationTitle => 'Verificação de identidade';

  @override
  String get onboardingVerificationDescription => 'Alguns Vote podem exigir um nível de verificação para proteger a integridade da votação.';

  @override
  String get pollDetail_voteReceiptButton => 'Comprovante de voto';

  @override
  String get pollDetail_voteReceiptTitle => 'Comprovante de voto';

  @override
  String get pollDetail_voteReceiptIdLabel => 'ID do comprovante';

  @override
  String get pollDetail_voteReceiptDateLabel => 'Registrado';

  @override
  String get pollDetail_voteReceiptPrivacy => 'Este comprovante confirma que seu voto foi registrado sem mostrar a opção que você escolheu.';

  @override
  String get pollDetail_voteReceiptCloseButton => 'Fechar';

  @override
  String get profileBiometricUnlockTitle => 'Desbloqueio biométrico';

  @override
  String get profileBiometricUnlockDescription => 'Protege sua sessão lembrada com a impressão digital ou reconhecimento biométrico do dispositivo.';

  @override
  String get profileBiometricRequiresRememberMe => 'Exige que Lembrar de mim esteja ativado.';

  @override
  String get profileBiometricUnavailable => 'A biometria não está disponível ou não está configurada neste dispositivo.';

  @override
  String get profileBiometricEnableReason => 'Confirme sua biometria para ativar o desbloqueio do Social Vote.';

  @override
  String get profileBiometricEnabledMessage => 'Desbloqueio biométrico ativado.';

  @override
  String get profileBiometricDisabledMessage => 'Desbloqueio biométrico desativado.';

  @override
  String get profileBiometricAuthFailedMessage => 'A autenticação biométrica não foi concluída.';

  @override
  String get biometricLockTitle => 'Social Vote está bloqueado';

  @override
  String get biometricLockMessage => 'Use a biometria do seu dispositivo para desbloquear a sessão lembrada.';

  @override
  String get biometricUnlockButton => 'Desbloquear';

  @override
  String get biometricUsePasswordButton => 'Usar senha';

  @override
  String get biometricUnlockReason => 'Desbloqueie sua sessão do Social Vote.';

  @override
  String get biometricUnlockFailedMessage => 'Falha no desbloqueio. Tente novamente ou use sua senha.';

  @override
  String get adminCenterOperationalActivityTitle => 'Atividade operacional';

  @override
  String get adminCenterOperationalActivitySubtitle => 'Contadores agregados. Sem rastreamento de presença on-line em tempo real.';

  @override
  String get adminCenterLast24HoursLabel => '24 horas';

  @override
  String get adminCenterLast7DaysLabel => '7 dias';

  @override
  String get adminCenterNewUsersMetric => 'Novos cadastros';

  @override
  String get adminCenterRecentSignInsMetric => 'Logins recentes';

  @override
  String get adminCenterPollsCreatedMetric => 'Vote criados';

  @override
  String get adminCenterPostsCreatedMetric => 'Voce criados';

  @override
  String get adminCenterAdminActionsMetric => 'Ações administrativas';

  @override
  String get authPublicNameHelper => 'Este é o nome que outros usuários verão. Seu nome de usuário é criado automaticamente.';

  @override
  String get adminCenterRefreshMarkersTooltip => 'Atualizar marcadores do globo';

  @override
  String get adminCenterMarkerDensityTitle => 'Densidade de marcadores do mundo';

  @override
  String get adminCenterMarkerDensitySubtitle => 'Controla o limite visual de marcadores do Globo da Home sem alterar coordenadas reais nem a classificação do conteúdo.';

  @override
  String get adminCenterMarkerDensityEmpty => 'Vazio';

  @override
  String get adminCenterMarkerDensityFull => 'Completo';

  @override
  String adminCenterMarkerDensityBudget(int count) {
    return 'Limite da Home: $count marcadores';
  }

  @override
  String get adminCenterMarkerDensitySaveError => 'Não foi possível salvar a densidade de marcadores do mundo.';

  @override
  String get adminCenterMarkerDensityBackendUnavailable => 'As configurações de backend dos marcadores do mundo ainda não estão disponíveis.';

  @override
  String get adminCenterQuickActionsTitle => 'Ações rápidas da conta';

  @override
  String get adminCenterModerationSnapshotTitle => 'Resumo de moderação e atividade';

  @override
  String get adminCenterReportsReceivedMetric => 'Denúncias recebidas';

  @override
  String get adminCenterPendingReportsMetric => 'Denúncias pendentes';

  @override
  String get adminCenterConfirmedViolationsMetric => 'Violações confirmadas';

  @override
  String get adminCenterReportsFiledMetric => 'Denúncias enviadas';

  @override
  String get adminCenterCommentsCreatedMetric => 'Comentários criados';

  @override
  String get adminCenterAdminActionsOnAccountMetric => 'Ações administrativas na conta';

  @override
  String get adminCenterLastReportReceivedLabel => 'Última denúncia recebida';

  @override
  String get adminCenterOpenFullAccountAction => 'Abrir controles completos da conta';

  @override
  String get profileAppLanguageGerman => 'Alemão';

  @override
  String get profileAppLanguagePersian => 'Persa';

  @override
  String get discoveryPageTitle => 'Explorar';

  @override
  String get organizationWorkspaceTitle => 'Workspace da organização';

  @override
  String get organizationPilotBannerTitle => 'Piloto gratuito';

  @override
  String get organizationPilotBannerBody => 'As Sessions são gratuitas durante o piloto. Alguns recursos profissionais podem se tornar pagos no futuro; a cobrança não está ativa agora.';

  @override
  String get organizationVerifiedLabel => 'Organização verificada';

  @override
  String get organizationEditProfile => 'Editar perfil da organização';

  @override
  String get organizationCreateSession => 'Nova Session';

  @override
  String get organizationNoSessions => 'Ainda não há Sessions. Crie a primeira para uma reunião, oficina ou evento.';

  @override
  String get organizationSessionsTitle => 'Sessions ao vivo';

  @override
  String get organizationRequiresVerificationTitle => 'Organização verificada obrigatória';

  @override
  String get organizationRequiresVerificationBody => 'Este Workspace está disponível somente para contas aprovadas pelo Social Vote como organização verificada.';

  @override
  String get organizationProfileEditorTitle => 'Perfil da organização';

  @override
  String get organizationLegalName => 'Nome legal';

  @override
  String get organizationPublicName => 'Nome público';

  @override
  String get organizationType => 'Tipo de organização';

  @override
  String get organizationCountryCode => 'Código do país';

  @override
  String get organizationCity => 'Cidade';

  @override
  String get organizationWebsite => 'Site oficial';

  @override
  String get organizationDescription => 'Descrição';

  @override
  String get organizationUploadCover => 'Alterar capa';

  @override
  String get organizationUploadLogo => 'Alterar logotipo';

  @override
  String get organizationMediaUpdated => 'Imagem da organização atualizada.';

  @override
  String get organizationNamesRequired => 'Nome legal e nome público são obrigatórios.';

  @override
  String get organizationTypeAssociation => 'Associação';

  @override
  String get organizationTypeNonprofit => 'Sem fins lucrativos';

  @override
  String get organizationTypeCompany => 'Empresa';

  @override
  String get organizationTypeCooperative => 'Cooperativa';

  @override
  String get organizationTypeSports => 'Organização esportiva';

  @override
  String get organizationTypePublicBody => 'Órgão público';

  @override
  String get organizationTypeCommittee => 'Comitê / grupo';

  @override
  String get organizationTypeOther => 'Outro';

  @override
  String get sessionCreateTitle => 'Criar Live Session';

  @override
  String get sessionTitleLabel => 'Título da Session';

  @override
  String get sessionExpectedParticipants => 'Participantes esperados';

  @override
  String get sessionAccessMode => 'Acesso dos participantes';

  @override
  String get sessionAccessOpen => 'Anônimo aberto';

  @override
  String get sessionAccessOpenHint => 'Qualquer pessoa com o link/código pode entrar. A prevenção de duplicidade é feita em regime de melhor esforço; este modo não garante uma pessoa-um voto.';

  @override
  String get sessionAccessControlled => 'Anônimo controlado';

  @override
  String get sessionAccessControlledHint => 'Use Access Pass anônimos de uso único. O Social Vote armazena somente o hash do Access Pass e não vincula as escolhas de voto às credenciais dos participantes.';

  @override
  String get sessionResultsVisibility => 'Visibilidade dos resultados';

  @override
  String get sessionResultsLive => 'Ao vivo';

  @override
  String get sessionResultsAfterVote => 'Depois que o participante votar';

  @override
  String get sessionResultsAfterClose => 'Depois que a pergunta for encerrada';

  @override
  String get sessionResultsOrganizerOnly => 'Somente organizador';

  @override
  String get sessionCreateAction => 'Criar Session';

  @override
  String get sessionPilotLimit => 'Limite do piloto: de 1 a 250 participantes por Session.';

  @override
  String get sessionStatusDraft => 'Rascunho';

  @override
  String get sessionStatusOpen => 'Aberta';

  @override
  String get sessionStatusClosed => 'Encerrada';

  @override
  String get sessionJoinCode => 'Código de entrada';

  @override
  String get sessionShareJoin => 'Compartilhar link de entrada';

  @override
  String get sessionCopyJoinLink => 'Copiar link';

  @override
  String get sessionGenerateTokens => 'Gerar Access Pass';

  @override
  String get sessionGenerateTokensCount => 'Número de Access Pass';

  @override
  String get sessionTokensOneTimeTitle => 'Salve estas credenciais agora';

  @override
  String get sessionTokensOneTimeBody => 'Os Access Pass em texto simples aparecem somente no resultado deste lote. O Social Vote armazena apenas seus hashes. Copie e distribua-os com segurança.';

  @override
  String get sessionCopyTokens => 'Copiar todos os links';

  @override
  String get sessionTokensSavedAction => 'Eu os salvei';

  @override
  String get sessionOpenAction => 'Abrir Session';

  @override
  String get sessionCloseAction => 'Encerrar Session';

  @override
  String get sessionCloseConfirm => 'Encerrar a votação e criar o snapshot imutável de Verified Result?';

  @override
  String get sessionQuestionsTitle => 'Perguntas';

  @override
  String get sessionAddQuestion => 'Adicionar pergunta';

  @override
  String get sessionQuestionTitle => 'Pergunta';

  @override
  String get sessionQuestionType => 'Tipo de pergunta';

  @override
  String get sessionTypeYesNo => 'Sim / Não';

  @override
  String get sessionTypeSingle => 'Escolha única';

  @override
  String get sessionTypeMultiple => 'Escolha múltipla';

  @override
  String get sessionOptions => 'Opções';

  @override
  String get sessionOptionHint => 'Uma opção por linha.';

  @override
  String get sessionMinSelections => 'Seleções mínimas';

  @override
  String get sessionMaxSelections => 'Seleções máximas';

  @override
  String get sessionAddAction => 'Adicionar';

  @override
  String get sessionOpenQuestion => 'Abrir pergunta';

  @override
  String get sessionCloseQuestion => 'Encerrar pergunta';

  @override
  String get sessionNoQuestions => 'Ainda não há perguntas.';

  @override
  String get sessionPresenterTitle => 'Apresentador';

  @override
  String get sessionParticipantTitle => 'Social Vote Live';

  @override
  String get sessionJoinAction => 'Entrar na Session';

  @override
  String get sessionTokenLabel => 'Token do participante';

  @override
  String get sessionTokenHint => 'SV-…';

  @override
  String get sessionWaitingQuestion => 'Aguardando o organizador abrir uma pergunta…';

  @override
  String get sessionVoteAction => 'Enviar voto';

  @override
  String get sessionVoteReceived => 'Voto recebido';

  @override
  String get sessionResultsUnavailable => 'Os resultados ainda não estão visíveis segundo a política desta Session.';

  @override
  String get sessionPrivacyNotice => 'O organizador define a finalidade operacional e as perguntas da Session. O Social Vote processa os dados técnicos necessários para fornecer e proteger o serviço. Os modos anônimos não expõem ao organizador o vínculo entre a credencial do participante e uma escolha. Os papéis de privacidade podem depender do contexto e dos acordos aplicáveis.';

  @override
  String get sessionNonBindingNotice => 'As Sessions piloto destinam-se a consulta e participação. Elas não constituem eleição legal, votação estatutária de assembleia nem certificação juridicamente vinculante.';

  @override
  String get sessionOptionYes => 'Sim';

  @override
  String get sessionOptionNo => 'Não';

  @override
  String get verifiedResultTitle => 'Verified Result';

  @override
  String get verifiedResultValid => 'Verificação de integridade aprovada';

  @override
  String get verifiedResultInvalid => 'Falha na verificação de integridade';

  @override
  String get verifiedResultReportId => 'ID do relatório';

  @override
  String get verifiedResultHash => 'Hash SHA-256 do resultado';

  @override
  String get verifiedResultGeneratedBy => 'Gerado e selado quanto à integridade pelo Social Vote';

  @override
  String get verifiedResultNotLegalCertificate => 'Este é um relatório verificável de resultado agregado, não um certificado legal nem uma certificação de eleição juridicamente vinculante.';

  @override
  String get verifiedResultShare => 'Compartilhar link de verificação';

  @override
  String sessionResponses(int count) {
    return '$count respostas';
  }

  @override
  String sessionResultVotes(int count) {
    return '$count votos';
  }

  @override
  String get organizationVerifiedIdentityLocked => 'Nome e país fazem parte da identidade verificada da organização. Alterá-los exigirá uma nova verificação. Você pode alterar livremente capa, logotipo, tipo, cidade, site e descrição.';

  @override
  String get verifiedResultOpenedAt => 'Session aberta';

  @override
  String get verifiedResultEligibleCredentials => 'Credenciais elegíveis';

  @override
  String get verifiedResultIntegritySeal => 'Selo de integridade do Social Vote';

  @override
  String get organizationVerifiedNameLocked => 'O nome verificado e o país estão bloqueados. Alterá-los exige uma nova análise de verificação.';

  @override
  String get sessionRetentionLabel => 'Retenção de votos brutos';

  @override
  String get sessionRetention24h => '24 horas';

  @override
  String get sessionRetention7d => '7 dias';

  @override
  String get sessionRetention30d => '30 dias';

  @override
  String sessionRetentionValue(String value) {
    return 'Retenção de votos brutos: $value';
  }

  @override
  String get verifiedResultPrintPdf => 'Baixar PDF';

  @override
  String get verifiedResultPdfError => 'Não foi possível baixar o PDF. Tente novamente.';

  @override
  String get verifiedResultRestrictedTitle => 'Resultado restrito';

  @override
  String get verifiedResultRestrictedBody => 'Este Verified Result não está disponível publicamente. Entre com uma conta de organização autorizada para visualizá-lo.';

  @override
  String get verifiedResultPrivateVerificationTitle => 'Verificação pública indisponível';

  @override
  String get verifiedResultPrivateVerificationBody => 'Este resultado é restrito ao organizador. O ID do relatório, SHA-256 e a verificação de integridade continuam disponíveis no relatório autorizado.';

  @override
  String get organizationAccountSectionTitle => 'Suas organizações';

  @override
  String get organizationManageAction => 'Gerenciar';

  @override
  String get organizationViewPublicProfileAction => 'Ver perfil';

  @override
  String get organizationOfficialWebsiteAction => 'Site oficial';

  @override
  String get organizationVerificationIntro => 'A verificação cobre tanto a existência da organização quanto sua autoridade para representá-la. O Social Vote analisará as informações enviadas antes da aprovação.';

  @override
  String get organizationVerificationLegalName => 'Nome legal';

  @override
  String get organizationVerificationPublicName => 'Nome público';

  @override
  String get organizationVerificationType => 'Tipo de organização';

  @override
  String get organizationVerificationCountry => 'País';

  @override
  String get organizationVerificationCountryRequired => 'Selecione o país da organização.';

  @override
  String get organizationVerificationCity => 'Cidade';

  @override
  String get organizationVerificationWebsite => 'Site oficial';

  @override
  String get organizationVerificationRepresentativeRole => 'Sua função na organização';

  @override
  String get organizationVerificationRegistryId => 'Identificador de registro / fiscal / da organização';

  @override
  String get organizationVerificationAuthorityNote => 'Como podemos verificar que você pode representá-la?';

  @override
  String get organizationVerificationAuthorityHelper => 'Informe brevemente sua função ou a evidência que um administrador poderá verificar durante o piloto.';

  @override
  String get organizationVerificationRequired => 'Campo obrigatório.';

  @override
  String get sessionControlRoomTitle => 'Sala de Controle da Session';

  @override
  String get sessionSectionLive => 'Ao vivo';

  @override
  String get sessionSectionQuestions => 'Perguntas';

  @override
  String get sessionSectionAccess => 'Acesso';

  @override
  String get sessionSectionSettings => 'Configurações';

  @override
  String get sessionStageAction => 'Abrir Stage';

  @override
  String get sessionAccessPassesTitle => 'Access Pass de participantes';

  @override
  String get sessionAccessPassesSubtitle => 'Cada passe abre esta Session Anônima Controlada sem exigir que o participante digite a credencial longa. O Social Vote não armazena o passe em texto simples.';

  @override
  String get sessionAccessPass => 'Access Pass';

  @override
  String get sessionAccessPassDetected => 'Access Pass detectado';

  @override
  String get sessionAccessPassAutomatic => 'Seu passe pessoal está pronto. Continue para entrar na Session anonimamente.';

  @override
  String get sessionAccessPassFallback => 'Inserir passe manualmente';

  @override
  String get sessionAccessPassInvalid => 'Este Access Pass é inválido, já não está disponível ou a Session não está aberta.';

  @override
  String get sessionAccessPassPrintWarning => 'Imprima, salve ou distribua estes passes agora. Depois que você sair desta tela, o Social Vote não poderá mostrar novamente os passes em texto simples.';

  @override
  String get sessionExistingPassesHidden => 'Por segurança, passes gerados anteriormente não podem ser exibidos novamente em texto simples. Gere novos Access Pass para obter novos links pessoais ou códigos QR.';

  @override
  String get sessionCopyPassLinks => 'Copiar todos os links';

  @override
  String get sessionCopyPassLink => 'Copiar este link';

  @override
  String get sessionControlledNeedsAccessPass => 'Antes de abrir uma Session controlada, gere pelo menos um Access Pass.';

  @override
  String get sessionJoinedParticipants => 'Credenciais de acesso conectadas';

  @override
  String get sessionAccessesUsed => 'Acessos que votaram';

  @override
  String get sessionBallotsRecorded => 'Votos registrados';

  @override
  String get sessionQuestionsCompleted => 'Perguntas concluídas';

  @override
  String get sessionCurrentQuestion => 'Pergunta atual';

  @override
  String get sessionNoOpenQuestionTitle => 'Nenhuma pergunta está aberta';

  @override
  String get sessionNoOpenQuestionBody => 'Os participantes estão conectados e aguardando. Abra a próxima pergunta quando estiver pronto.';

  @override
  String get sessionNotStartedTitle => 'A Session ainda não começou';

  @override
  String get sessionNotStartedBody => 'Esta Session existe, mas ainda não está aberta. Mantenha esta página aberta e aguarde o organizador iniciá-la.';

  @override
  String get sessionNoAccountRequired => 'Não é necessária uma conta do Social Vote';

  @override
  String get sessionReceiptDetails => 'Detalhes do comprovante';

  @override
  String get sessionOpenAccessInstructions => 'Exiba ou compartilhe este QR. Qualquer pessoa com o link pode entrar enquanto a Session estiver aberta.';

  @override
  String get sessionControlledAccessInstructions => 'Crie passes de acesso pessoais e entregue um a cada participante. O QR de cada passe contém a credencial automaticamente.';

  @override
  String get sessionControlRoomHint => 'Gerencie o acesso, as perguntas, o Stage projetado e o Verified Result final em um só lugar.';

  @override
  String get sessionPresenterScreenTitle => 'Palco ao vivo';

  @override
  String get sessionStageWaiting => 'Aguardando a próxima pergunta';

  @override
  String get sessionStageScan => 'Escaneie para entrar na Session';

  @override
  String get sessionConfigurationTitle => 'Configuração da Session';

  @override
  String get sessionAccessRecommended => 'Recomendado para reuniões controladas';

  @override
  String get sessionCreateIntroTitle => 'Configurar a reunião';

  @override
  String get sessionCreateIntroBody => 'Escolha como os participantes entram, quando os resultados ficam visíveis e por quanto tempo os votos brutos são retidos. Essas configurações são aplicadas pelo backend.';

  @override
  String get verifiedCertificateNumber => 'Número do certificado';

  @override
  String get verifiedCertificateStatus => 'Status da integridade';

  @override
  String get verifiedCertificateIntegrityVerified => 'INTEGRIDADE VERIFICADA';

  @override
  String get verifiedCertificateIntegrityFailed => 'FALHA NA VERIFICAÇÃO DE INTEGRIDADE';

  @override
  String get verifiedCertificateOrganizationSection => 'Organização';

  @override
  String get verifiedCertificateSessionSection => 'Session';

  @override
  String get verifiedCertificateParticipationSection => 'Participação';

  @override
  String get verifiedCertificateResultsSection => 'Resultados verificados';

  @override
  String get verifiedCertificateIntegritySection => 'Integridade do resultado';

  @override
  String get verifiedCertificateLegalName => 'Nome legal';

  @override
  String get verifiedCertificateOrganizationType => 'Tipo de organização';

  @override
  String get verifiedCertificateLocation => 'Localização';

  @override
  String get verifiedCertificateWebsite => 'Site';

  @override
  String get verifiedCertificateVerification => 'Verificação';

  @override
  String get verifiedCertificateIssuedAt => 'Certificado emitido';

  @override
  String get verifiedCertificateAlgorithm => 'Algoritmo de integridade';

  @override
  String get verifiedCertificateSchema => 'Esquema do relatório';

  @override
  String get verifiedCertificateJoinedCredentials => 'Credenciais conectadas';

  @override
  String get verifiedCertificateBallotsTotal => 'Votos registrados';

  @override
  String get verifiedCertificateQuestionsTotal => 'Perguntas';

  @override
  String get verifiedCertificatePrivacyModel => 'Modelo de resultado anônimo';

  @override
  String get verifiedCertificatePrivacyText => 'O snapshot imutável contém somente resultados agregados. Ele não contém identidade de participante, Access Pass em texto simples, segredo do participante nem qualquer vínculo entre uma credencial de participante e uma escolha de voto.';

  @override
  String get verifiedCertificateVerifyQr => 'Escaneie este QR para verificar o relatório on-line.';

  @override
  String get organizationDashboardTitle => 'Visão geral da organização';

  @override
  String get organizationActiveSessions => 'Sessions ao vivo';

  @override
  String get organizationVerifiedReports => 'Relatórios verificados';

  @override
  String get organizationTotalSessions => 'Total de Sessions';

  @override
  String get sessionPrivacyPolicyAction => 'Ler a Política de Privacidade';

  @override
  String get radioMondoTitle => 'Rádio do Mundo';

  @override
  String get radioMondoDescription => 'Três paisagens sonoras originais para explorar o Social Vote. A reprodução começa somente quando você escolhe uma faixa.';

  @override
  String get radioMondoTrackClassical => 'Órbita clássica';

  @override
  String get radioMondoTrackRain => 'Chuva sobre o mundo';

  @override
  String get radioMondoTrackYoung => 'Pulso jovem';

  @override
  String get radioMondoPlaying => 'Tocando agora';

  @override
  String get radioMondoStopped => 'Rádio do Mundo parada';

  @override
  String get radioMondoStopAction => 'Parar';

  @override
  String get radioMondoPlaybackError => 'Não foi possível reproduzir o áudio';

  @override
  String get radioMondoForegroundOnly => 'A reprodução para quando o Social Vote é fechado, enviado para segundo plano ou quando a aba do navegador fica oculta.';

  @override
  String get adminCenterEditorialNavigation => 'World Briefs';

  @override
  String get worldBriefEditorTitle => 'World Briefs do Social Vote';

  @override
  String get worldBriefEditorDescription => 'Prepare briefings baseados em evidências, mantenha a incerteza visível e decida o que aparece em News e no Globo.';

  @override
  String get worldBriefAllStatuses => 'Todos os status';

  @override
  String get worldBriefCreateAction => 'Criar brief';

  @override
  String get worldBriefDraftSaved => 'Rascunho salvo';

  @override
  String get worldBriefPublished => 'Brief publicado';

  @override
  String get worldBriefWithdrawn => 'Brief retirado';

  @override
  String get worldBriefSaveError => 'Não foi possível salvar o brief';

  @override
  String get worldBriefPublishError => 'Não foi possível publicar o brief';

  @override
  String get worldBriefDraftDeleted => 'Rascunho excluído';

  @override
  String get worldBriefDeleteDraft => 'Excluir rascunho';

  @override
  String get worldBriefDeleteDraftConfirm => 'Excluir permanentemente este rascunho não publicado?';

  @override
  String get worldBriefRetry => 'Tentar novamente';

  @override
  String get worldBriefStatusDraft => 'Rascunho';

  @override
  String get worldBriefStatusPublished => 'Publicado';

  @override
  String get worldBriefStatusWithdrawn => 'Retirado';

  @override
  String get worldBriefSetupRequired => 'Backend editorial ainda não está pronto';

  @override
  String get worldBriefSetupRequiredBody => 'Aplique a migração de banco de dados do World Brief incluída antes de usar esta seção.';

  @override
  String get worldBriefEmptyTitle => 'Ainda não há World Briefs';

  @override
  String get worldBriefEmptyBody => 'Crie um rascunho, documente pelo menos duas fontes e publique somente após revisão editorial.';

  @override
  String get worldBriefFeatured => 'Destaque';

  @override
  String get worldBriefOnGlobe => 'Mostrar no Globo';

  @override
  String get worldBriefPriority => 'Prioridade';

  @override
  String get worldBriefEditAction => 'Editar';

  @override
  String get worldBriefPublishAction => 'Publicar';

  @override
  String get worldBriefWithdrawAction => 'Retirar';

  @override
  String get worldBriefSaveDraftAction => 'Salvar rascunho';

  @override
  String get worldBriefLanguage => 'Idioma do brief';

  @override
  String get worldBriefTitleField => 'Manchete';

  @override
  String get worldBriefWhatHappened => 'O que aconteceu';

  @override
  String get worldBriefWhyItMatters => 'Por que importa';

  @override
  String get worldBriefWhatIsUncertain => 'O que ainda é incerto';

  @override
  String get worldBriefSources => 'URLs das fontes';

  @override
  String get worldBriefSourcesHint => 'Uma URL HTTPS por linha; pelo menos duas fontes independentes.';

  @override
  String get worldBriefTwoSourcesRequired => 'Adicione pelo menos duas fontes.';

  @override
  String get worldBriefHttpsSourcesRequired => 'Todas as fontes devem usar HTTPS.';

  @override
  String get worldBriefGlobeSection => 'Posicionamento no Globo';

  @override
  String get worldBriefGlobeRequiresPoint => 'A visibilidade no Globo exige latitude e longitude válidas.';

  @override
  String get worldBriefCountryCode => 'Código do país';

  @override
  String get worldBriefCityId => 'ID da cidade';

  @override
  String get worldBriefLocationLabel => 'Rótulo da localização';

  @override
  String get worldBriefLatitude => 'Latitude';

  @override
  String get worldBriefLongitude => 'Longitude';

  @override
  String get worldBriefBreaking => 'Atualização urgente';

  @override
  String get worldBriefExpiry => 'Janela de revisão ou expiração';

  @override
  String worldBriefExpiryDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String get worldBriefRequiredField => 'Este campo é obrigatório.';

  @override
  String get worldBriefCoordinatesRequired => 'Digite uma coordenada válida.';

  @override
  String get profileHowItWorksTitle => 'Como o Social Vote funciona';

  @override
  String get profileHowItWorksSubtitle => 'Pessoas, Organizações, Voce, Vote, Sessions e verificação.';

  @override
  String get profileMyPostsLoginRequired => 'Você precisa estar conectado para ver seus Voce.';

  @override
  String get profileMyPostsCreatedByYou => 'Voce criados por você';

  @override
  String get profileMyPostsEmpty => 'Você ainda não criou nenhum Voce.';

  @override
  String get profileMyPollsLoginRequired => 'Você precisa estar conectado para ver seus Vote.';

  @override
  String get profileMyPollsCreatedByYou => 'Vote criados por você';

  @override
  String get profileMyPollsEmpty => 'Você ainda não criou nenhum Vote.';

  @override
  String get profileMyCommentsLoginRequired => 'Você precisa estar conectado para ver seus comentários.';

  @override
  String get profileMyCommentsEmpty => 'Você ainda não escreveu nenhum comentário.';

  @override
  String get profileFollowedScopesLoginRequired => 'Você precisa estar conectado.';

  @override
  String get profileFollowedScopesEmpty => 'Você ainda não segue nenhuma área.';

  @override
  String get profileFollowedScopeWorld => 'Mundo';

  @override
  String profileFollowedScopeCountry(String code) {
    return 'País: $code';
  }

  @override
  String profileFollowedScopeCity(String city) {
    return 'Cidade: $city';
  }

  @override
  String profileFollowedScopeArea(double radius) {
    return 'Área ($radius km)';
  }

  @override
  String get publicProfilePollsLoadError => 'Não foi possível carregar os Vote públicos.';

  @override
  String get publicProfilePollsEmpty => 'Não há Vote públicos.';

  @override
  String get publicProfilePostsLoadError => 'Não foi possível carregar os Voce públicos.';

  @override
  String get publicProfilePostsEmpty => 'Não há Voce públicos.';

  @override
  String get worldBriefSocialVoteView => 'Visão do Social Vote';

  @override
  String get worldBriefSocialVoteViewHint => 'Análise ou ponto de vista editorial do Social Vote. Mantenha-o separado dos fatos relatados e da incerteza.';

  @override
  String get worldBriefSocialVoteViewPublicNote => 'Análise editorial do Social Vote, claramente separada dos fatos relatados acima.';

  @override
  String get worldBriefIndependentSourcesRequired => 'A publicação exige pelo menos duas fontes HTTPS de domínios diferentes.';

  @override
  String get worldBriefPublishConfirmTitle => 'Verificação final antes de publicar';

  @override
  String worldBriefPublishConfirmSources(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fontes inseridas',
      one: '1 fonte inserida',
    );
    return '$_temp0';
  }

  @override
  String get worldBriefEnterpriseEditorTitle => 'Editor editorial profissional';

  @override
  String get worldBriefEnterpriseEditorHelp => 'Monte o brief por seção. O Social Vote cuida automaticamente do posicionamento técnico no Globo: escolha um país e uma cidade, não coordenadas.';

  @override
  String get worldBriefEditorialContentSection => 'Conteúdo editorial';

  @override
  String get worldBriefEditorialContentHelp => 'Mantenha separados os fatos, a relevância, a incerteza e a visão do Social Vote. Isso torna o brief mais fácil de verificar e ler.';

  @override
  String get worldBriefSourcesSection => 'Fontes e verificação';

  @override
  String get worldBriefSourcesSectionHelp => 'Adicione fontes HTTPS verificáveis. A publicação exige pelo menos dois domínios independentes.';

  @override
  String get worldBriefDistributionSection => 'Distribuição';

  @override
  String get worldBriefDistributionHelp => 'Escolha onde o brief aparece. A publicação o disponibiliza em News; o posicionamento no Globo é opcional.';

  @override
  String get worldBriefNewsDestination => 'Publicar no Social Vote News';

  @override
  String get worldBriefNewsDestinationHelp => 'Este é o principal destino de um World Brief depois de publicado.';

  @override
  String get worldBriefGlobeAutomaticHelp => 'Adiciona um marcador ao Globo. Escolha o local e o Social Vote resolve a posição automaticamente.';

  @override
  String get worldBriefPlacementMode => 'Posicionamento do marcador';

  @override
  String get worldBriefPlacementCity => 'Cidade / local';

  @override
  String get worldBriefPlacementCountry => 'Centro do país';

  @override
  String get worldBriefCountry => 'País';

  @override
  String get worldBriefCity => 'Cidade ou local';

  @override
  String get worldBriefCityHelp => 'Exemplo: Teerã. Não digite latitude nem longitude.';

  @override
  String get worldBriefResolveLocation => 'Resolver localização';

  @override
  String get worldBriefCoordinatesAutomatic => 'As coordenadas são tratadas automaticamente e não devem ser inseridas manualmente.';

  @override
  String worldBriefLocationResolved(String location) {
    return 'Localização pronta: $location';
  }

  @override
  String get worldBriefChooseCountryFirst => 'Escolha primeiro um país.';

  @override
  String get worldBriefChooseCityFirst => 'Digite primeiro uma cidade ou local.';

  @override
  String get worldBriefLocationNotResolved => 'Não foi possível resolver uma localização confiável. Verifique o país e a cidade e tente novamente.';

  @override
  String get worldBriefVisibilitySection => 'Visibilidade e prioridade';

  @override
  String get worldBriefVisibilityHelp => 'Controle o destaque editorial, a urgência, a ordenação e a duração sem alterar os fatos relatados.';

  @override
  String get worldBriefFeaturedHelp => 'Dê ao brief mais destaque nas superfícies editoriais.';

  @override
  String get worldBriefBreakingHelp => 'Use apenas para eventos realmente urgentes ou em rápida evolução.';

  @override
  String get worldBriefPriorityHelp => '0 = prioridade normal/baixa; 100 = prioridade editorial máxima. Isso não altera o status de veracidade do conteúdo.';

  @override
  String get worldBriefExpiryHelp => 'Após esta janela, o brief não deve permanecer ativo sem outra revisão editorial.';

  @override
  String get profileAppLanguageSpanish => 'Espanhol';

  @override
  String get profileAppLanguagePortuguese => 'Português';

  @override
  String get homeHeroPurpose => 'Descubra o que importa, compartilhe sua Voce e participe de Vote.';

  @override
  String get commentSection_hideComments => 'Ocultar comentários';

  @override
  String get commentSection_viewComments => 'Ver comentários';

  @override
  String get commentSection_hideReplies => 'Ocultar respostas';

  @override
  String commentSection_editing(String snippet) {
    return 'Editando: $snippet';
  }

  @override
  String get commentSection_editInputHint => 'Editar seu comentário';

  @override
  String commentSection_replyTo(String author) {
    return 'Responder a $author';
  }

  @override
  String get commentSection_userFallback => 'Usuário';

  @override
  String get commentSection_addError => 'Não foi possível adicionar o comentário.';

  @override
  String get commentSection_nestedReplyError => 'Respostas aninhadas além de um nível não são suportadas.';

  @override
  String get commentSection_addReplyError => 'Não foi possível adicionar a resposta.';

  @override
  String get commentSection_editError => 'Não foi possível editar o comentário.';

  @override
  String get commentSection_deleteError => 'Não foi possível excluir o comentário.';

  @override
  String get commentSection_edited => 'Editado';

  @override
  String get commentSection_editAction => 'Editar';
}
