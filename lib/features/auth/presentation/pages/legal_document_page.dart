import 'package:flutter/material.dart';

import 'package:sociale_vote/l10n/app_localizations.dart';

enum LegalDocumentType {
  terms,
  privacy,
}

class LegalDocumentPage extends StatelessWidget {
  final LegalDocumentType type;

  const LegalDocumentPage({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isItalian = Localizations.localeOf(context).languageCode == 'it';
    final document = _LegalDocument.forType(
      type,
      isItalian: isItalian,
    );

    final title = switch (type) {
      LegalDocumentType.terms => l10n.authTermsPageTitle,
      LegalDocumentType.privacy => l10n.authPrivacyPageTitle,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: SelectionArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DraftNotice(text: document.notice),
                    const SizedBox(height: 24),
                    for (final section in document.sections) ...[
                      Text(
                        section.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        section.body,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                            ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.authCloseButton),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DraftNotice extends StatelessWidget {
  final String text;

  const _DraftNotice({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.tertiary.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: colors.onTertiaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onTertiaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalSection {
  final String title;
  final String body;

  const _LegalSection({
    required this.title,
    required this.body,
  });
}

class _LegalDocument {
  final String notice;
  final List<_LegalSection> sections;

  const _LegalDocument({
    required this.notice,
    required this.sections,
  });

  factory _LegalDocument.forType(
    LegalDocumentType type, {
    required bool isItalian,
  }) {
    if (type == LegalDocumentType.terms) {
      return isItalian ? _termsItalian : _termsEnglish;
    }

    return isItalian ? _privacyItalian : _privacyEnglish;
  }

  static const _LegalDocument _termsItalian = _LegalDocument(
    notice: 'TERMINI PRE-RELEASE — aggiornati il 3 agosto 2026. Il gestore, '
        'il contatto ufficiale, l’età minima e la legge applicabile sono '
        'definiti. Prima della pubblicazione resta necessaria una revisione '
        'professionale e, se richiesto, la definizione di un recapito '
        'professionale e della procedura formale di ricorso.',
    sections: [
      _LegalSection(
        title: '1. Gestore e accettazione',
        body: 'Social Vote è gestito da Reza Hematian, contattabile a '
            'socialvote@hotmail.com. Creando un account o usando le funzioni '
            'autenticate, l’utente dichiara di aver letto e accettato questi '
            'Termini e l’Informativa sulla privacy. Se non li accetta, non '
            'deve creare un account o usare tali funzioni.',
      ),
      _LegalSection(
        title: '2. Servizio e stato pre-release',
        body: 'Social Vote è una piattaforma civica e sociale che permette di '
            'creare e partecipare a sondaggi, pubblicare contenuti, '
            'commentare, reagire, usare funzioni geografiche e consultare '
            'notizie. Il servizio è in fase pre-release: funzioni, limiti e '
            'disponibilità possono cambiare per sicurezza, conformità o '
            'miglioramento del prodotto.',
      ),
      _LegalSection(
        title: '3. Età minima e account',
        body: 'Per creare un account è necessario avere almeno 14 anni. Se la '
            'legge applicabile richiede un’età superiore o l’autorizzazione '
            'di chi esercita la responsabilità genitoriale, si applica tale '
            'requisito. L’utente deve fornire informazioni corrette, '
            'proteggere le credenziali e usare un solo account, salvo account '
            'istituzionali o organizzativi espressamente autorizzati. Non è '
            'consentito cedere, vendere o condividere l’account.',
      ),
      _LegalSection(
        title: '4. Regole di comportamento',
        body: 'Sono vietati contenuti o attività illegali, ingannevoli, '
            'minacciosi, discriminatori, molesti o abusivi; sfruttamento di '
            'minori; spam; impersonificazione; manipolazione di voti o '
            'segnalazioni; accessi non autorizzati; diffusione illecita di '
            'dati personali; e violazioni di copyright o altri diritti di '
            'terzi. L’utente resta responsabile dei contenuti e delle azioni '
            'eseguite con il proprio account.',
      ),
      _LegalSection(
        title: '5. Contenuti dell’utente',
        body: 'L’utente conserva i diritti sui contenuti che pubblica e '
            'conferma di avere le autorizzazioni necessarie. Con la '
            'pubblicazione concede a Social Vote una licenza non esclusiva e '
            'limitata a conservare, riprodurre, adattare tecnicamente, '
            'mostrare e distribuire il contenuto nella piattaforma, nonché a '
            'moderarlo per fornire e proteggere il servizio. La licenza cessa '
            'quando il contenuto viene eliminato, salvo copie tecniche o dati '
            'minimizzati conservati lecitamente come descritto '
            'nell’Informativa sulla privacy.',
      ),
      _LegalSection(
        title: '6. Sondaggi, News e posizione',
        body: 'I sondaggi non sono elezioni ufficiali, referendum legalmente '
            'vincolanti, rilevazioni statisticamente rappresentative o '
            'consulenza professionale, salvo indicazione espressa e '
            'verificabile. Le News provengono da fonti esterne: titoli, '
            'contenuti, disponibilità e accuratezza restano responsabilità '
            'delle rispettive fonti. Le funzioni di posizione sono '
            'facoltative e l’utente deve evitare di pubblicare luoghi o dati '
            'che espongano sé stesso o terzi a rischi.',
      ),
      _LegalSection(
        title: '7. Segnalazioni e moderazione',
        body: 'Utenti e contenuti possono essere segnalati. Moderatori e '
            'amministratori autorizzati possono esaminare segnalazioni, '
            'limitare o ripristinare contenuti, sospendere o riattivare '
            'account, revocare sessioni o adottare altre misure proporzionate '
            'per violazioni, abuso, sicurezza o obblighi di legge. Quando '
            'possibile, il motivo della decisione viene comunicato. L’utente '
            'può chiederne il riesame scrivendo a socialvote@hotmail.com con '
            'le informazioni necessarie a identificare account e decisione.',
      ),
      _LegalSection(
        title: '8. Cancellazione e cessazione',
        body: 'L’utente può eliminare definitivamente il proprio account '
            'dall’app mediante conferma forte. Gli effetti della '
            'cancellazione e gli eventuali dati minimizzati conservati '
            'lecitamente sono descritti nell’Informativa sulla privacy. '
            'Social Vote può limitare o chiudere un account in caso di '
            'violazioni gravi o ripetute, per rischio di sicurezza, obbligo '
            'legale o impossibilità di continuare a fornire il servizio.',
      ),
      _LegalSection(
        title: '9. Proprietà intellettuale',
        body: 'Il software, il nome, la grafica e gli elementi originali di '
            'Social Vote sono protetti dalle norme applicabili. Marchi, News '
            'e contenuti di terzi appartengono ai rispettivi titolari. Questi '
            'Termini non trasferiscono all’utente diritti sul servizio o sui '
            'contenuti di terzi oltre a quanto necessario per il normale '
            'utilizzo dell’app.',
      ),
      _LegalSection(
        title: '10. Disponibilità e responsabilità',
        body: 'Social Vote adotta misure ragionevoli per sicurezza e '
            'continuità, ma non garantisce un servizio ininterrotto o privo di '
            'errori, né l’accuratezza dei contenuti pubblicati dagli utenti o '
            'da fonti esterne. Nulla in questi Termini limita i diritti del '
            'consumatore o le responsabilità che non possono essere escluse '
            'dalla legge applicabile.',
      ),
      _LegalSection(
        title: '11. Modifiche ai Termini',
        body: 'I Termini possono essere aggiornati per modifiche del servizio, '
            'sicurezza, legge o conformità. Le modifiche sostanziali saranno '
            'comunicate nell’app o tramite un canale appropriato prima della '
            'loro efficacia, quando richiesto. Se è necessario un nuovo '
            'consenso, l’utente dovrà accettare la versione aggiornata per '
            'continuare a usare le funzioni interessate.',
      ),
      _LegalSection(
        title: '12. Legge applicabile e contatti',
        body: 'Si applica la legge italiana, fatti salvi i diritti '
            'inderogabili riconosciuti al consumatore dalla legge del Paese '
            'in cui risiede. Foro e strumenti di risoluzione delle '
            'controversie sono quelli previsti dalle norme inderogabili '
            'applicabili. Per richieste sui Termini, moderazione o account è '
            'possibile scrivere a socialvote@hotmail.com.',
      ),
    ],
  );

  static const _LegalDocument _termsEnglish = _LegalDocument(
    notice: 'PRE-RELEASE TERMS — updated on 3 August 2026. The operator, '
        'official contact, minimum age and applicable law have been defined. '
        'Professional review is still required before publication, together '
        'with a professional postal contact and formal appeal procedure if '
        'required.',
    sections: [
      _LegalSection(
        title: '1. Operator and acceptance',
        body: 'Social Vote is operated by Reza Hematian, who can be contacted '
            'at socialvote@hotmail.com. By creating an account or using '
            'authenticated features, users confirm that they have read and '
            'accepted these Terms and the Privacy Notice. Users who do not '
            'accept them must not create an account or use those features.',
      ),
      _LegalSection(
        title: '2. Service and pre-release status',
        body: 'Social Vote is a civic and social platform for creating and '
            'participating in polls, publishing content, commenting, '
            'reacting, using geographic features and reading News. The '
            'service is in pre-release: features, limits and availability may '
            'change for security, compliance or product improvement.',
      ),
      _LegalSection(
        title: '3. Minimum age and accounts',
        body: 'A user must be at least 14 years old to create an account. If '
            'applicable law requires a higher age or authorisation from a '
            'holder of parental responsibility, that requirement applies. '
            'Users must provide accurate information, protect their '
            'credentials and use one account, except for expressly authorised '
            'institutional or organisational accounts. Accounts must not be '
            'transferred, sold or shared.',
      ),
      _LegalSection(
        title: '4. Rules of conduct',
        body: 'Illegal, deceptive, threatening, discriminatory, harassing or '
            'abusive content or activity is prohibited, as are child '
            'exploitation, spam, impersonation, manipulation of votes or '
            'reports, unauthorised access, unlawful disclosure of personal '
            'data and infringement of copyright or other third-party rights. '
            'Users remain responsible for content and actions performed '
            'through their account.',
      ),
      _LegalSection(
        title: '5. User content',
        body: 'Users retain rights in the content they publish and confirm '
            'that they have the required permissions. By publishing, users '
            'grant Social Vote a non-exclusive licence limited to storing, '
            'reproducing, technically adapting, displaying and distributing '
            'the content within the platform, and moderating it to provide '
            'and protect the service. The licence ends when the content is '
            'deleted, except for technical copies or minimised data lawfully '
            'retained as described in the Privacy Notice.',
      ),
      _LegalSection(
        title: '6. Polls, News and location',
        body: 'Polls are not official elections, legally binding referendums, '
            'statistically representative surveys or professional advice '
            'unless expressly and verifiably stated. News comes from external '
            'sources; titles, content, availability and accuracy remain the '
            'responsibility of the relevant source. Location features are '
            'optional, and users must avoid publishing places or data that '
            'could expose themselves or others to risk.',
      ),
      _LegalSection(
        title: '7. Reports and moderation',
        body: 'Users and content may be reported. Authorised moderators and '
            'administrators may review reports, restrict or restore content, '
            'suspend or reactivate accounts, revoke sessions or take other '
            'proportionate measures for violations, abuse, security or legal '
            'obligations. Where possible, reasons for a decision are '
            'communicated. Users may request review by emailing '
            'socialvote@hotmail.com with the information needed to identify '
            'the account and decision.',
      ),
      _LegalSection(
        title: '8. Deletion and termination',
        body: 'Users can permanently delete their account in the app using '
            'strong confirmation. The effects of deletion and any minimised '
            'data lawfully retained are explained in the Privacy Notice. '
            'Social Vote may restrict or close an account for serious or '
            'repeated violations, security risk, legal obligation or an '
            'inability to continue providing the service.',
      ),
      _LegalSection(
        title: '9. Intellectual property',
        body: 'The software, name, graphics and original elements of Social '
            'Vote are protected by applicable law. Third-party trademarks, '
            'News and content belong to their respective owners. These Terms '
            'do not transfer rights in the service or third-party content '
            'beyond what is needed for normal use of the app.',
      ),
      _LegalSection(
        title: '10. Availability and liability',
        body: 'Social Vote takes reasonable measures for security and '
            'continuity but does not guarantee uninterrupted or error-free '
            'operation or the accuracy of content published by users or '
            'external sources. Nothing in these Terms limits consumer rights '
            'or liability that cannot be excluded under applicable law.',
      ),
      _LegalSection(
        title: '11. Changes to the Terms',
        body: 'The Terms may be updated for service changes, security, law or '
            'compliance. Material changes will be communicated in the app or '
            'through an appropriate channel before taking effect where '
            'required. If renewed acceptance is necessary, users must accept '
            'the updated version to continue using the affected features.',
      ),
      _LegalSection(
        title: '12. Applicable law and contact',
        body: 'Italian law applies, without prejudice to mandatory consumer '
            'rights under the law of the user’s country of residence. Courts '
            'and dispute-resolution mechanisms are those provided by '
            'applicable mandatory rules. Questions about these Terms, '
            'moderation or accounts can be sent to '
            'socialvote@hotmail.com.',
      ),
    ],
  );

  static const _LegalDocument _privacyItalian = _LegalDocument(
    notice: 'INFORMATIVA PRE-RELEASE — aggiornata il 3 agosto 2026. I dati '
        'del titolare, il contatto privacy e l’età minima sono definiti. '
        'Prima della pubblicazione devono essere completati il controllo '
        'consenso Analytics, la gestione dei dati particolari eventualmente '
        'rivelati da voti e contenuti e la verifica dei tempi di conservazione '
        'e dei trasferimenti internazionali.',
    sections: [
      _LegalSection(
        title: '1. Titolare e contatti',
        body: 'Il titolare del trattamento di Social Vote è Reza Hematian, '
            'persona fisica. Per richieste privacy e per esercitare i propri '
            'diritti è possibile scrivere a socialvote@hotmail.com. '
            'L’indirizzo di residenza non viene pubblicato; un eventuale '
            'recapito postale professionale sarà definito prima della '
            'pubblicazione quando richiesto dalla normativa o dagli store.',
      ),
      _LegalSection(
        title: '2. Dati trattati',
        body: 'Social Vote tratta i dati necessari all’account, tra cui '
            'email, identificativo utente e dati di autenticazione gestiti da '
            'Supabase; dati del profilo come nome visualizzato, username, '
            'paese, città, biografia, avatar, tipo di identità e stato di '
            'verifica; dati delle richieste di verifica come qualifica '
            'ufficiale, nome dell’istituzione o dell’organizzazione, esito e '
            'note di revisione; contenuti e interazioni come sondaggi, scelte '
            'di voto, post, commenti, reazioni, preferiti, segnalazioni e '
            'notifiche; dati di posizione scelti dall’utente; eventi tecnici '
            'e di utilizzo descritti di seguito.',
      ),
      _LegalSection(
        title: '3. Finalità e basi giuridiche',
        body: 'I dati sono usati per registrare e proteggere l’account, '
            'fornire sondaggi e funzioni sociali, personalizzare lo scope '
            'geografico, gestire verifiche, notifiche e preferenze, prevenire '
            'abusi, moderare contenuti e account, assicurare il servizio e '
            'rispondere a richieste legali. La base giuridica è l’esecuzione '
            'del servizio richiesto dall’utente; per sicurezza, prevenzione '
            'degli abusi e difesa dei diritti è il legittimo interesse del '
            'titolare; quando necessario è l’adempimento di obblighi di legge. '
            'La posizione precisa è usata soltanto dopo la scelta e il '
            'permesso dell’utente. Eventuali trattamenti basati sul consenso '
            'possono essere revocati senza pregiudicare quelli già effettuati.',
      ),
      _LegalSection(
        title: '4. Visibilità e dati particolari',
        body: 'Nome visualizzato, username, avatar, indicatori di verifica e '
            'contenuti pubblicati possono essere visibili ad altri utenti e '
            'sul Web. La visibilità delle scelte di voto dipende dalle regole '
            'del sondaggio. Contenuti, sondaggi e voti possono rivelare '
            'opinioni politiche, convinzioni o altri dati particolari. '
            'L’utente non deve pubblicare dati particolari propri o di terzi '
            'se non è necessario e lecito. Prima della release pubblica '
            'devono essere definite e implementate le condizioni specifiche '
            'richieste dall’articolo 9 GDPR per tali dati.',
      ),
      _LegalSection(
        title: '5. Posizione e geocodifica',
        body: 'La posizione precisa viene richiesta solo quando l’utente '
            'sceglie di usare la posizione del dispositivo per un post o un '
            'sondaggio. Il permesso può essere negato o revocato nelle '
            'impostazioni del dispositivo. Se applicata al contenuto, la '
            'posizione può includere coordinate, paese e città ed essere '
            'salvata insieme al contenuto. Per trasformare le coordinate in '
            'un luogo può essere usato il servizio di geocodifica del sistema '
            'operativo e, come fallback, Nominatim di OpenStreetMap, al quale '
            'vengono inviate le coordinate necessarie alla richiesta.',
      ),
      _LegalSection(
        title: '6. Analytics e memoria locale',
        body: 'Sui runtime supportati Social Vote usa Firebase Analytics per '
            'misurare schermate ed eventi come registrazione, accesso, '
            'creazione di post o sondaggi, commenti e voti. Gli eventi possono '
            'contenere identificativi tecnici del contenuto, caratteristiche '
            'dell’azione, informazioni sul dispositivo e identificatori '
            'generati dal servizio, ma non il testo di post o commenti né la '
            'password. Lingua, tema, preferenze News e opzione “Ricordami” '
            'possono essere conservati localmente sul dispositivo. Prima '
            'della release pubblica la raccolta Analytics non essenziale deve '
            'essere subordinata alle scelte e al consenso richiesti dalla '
            'normativa applicabile.',
      ),
      _LegalSection(
        title: '7. Fornitori e trasferimenti',
        body: 'Supabase fornisce autenticazione, database, archiviazione file, '
            'funzioni backend e servizi realtime. Google Firebase fornisce '
            'Analytics e componenti tecnici sui runtime supportati. I servizi '
            'di geocodifica del dispositivo e OpenStreetMap Nominatim possono '
            'ricevere le coordinate quando la funzione di posizione è usata. '
            'Le News provengono da fonti esterne e vengono elaborate dal '
            'backend. Questi fornitori possono trattare dati in Paesi esterni '
            'allo Spazio economico europeo applicando, quando necessario, '
            'decisioni di adeguatezza, clausole contrattuali standard o altre '
            'garanzie previste dalla legge. Configurazioni, regioni e garanzie '
            'devono essere verificate prima della pubblicazione.',
      ),
      _LegalSection(
        title: '8. Moderazione, staff e sicurezza',
        body: 'Segnalazioni, richieste di verifica e contenuti possono essere '
            'esaminati da moderatori o amministratori autorizzati. Per '
            'violazioni, abuso o rischi di sicurezza, contenuti possono essere '
            'nascosti o ripristinati e account possono essere sospesi, '
            'riattivati, disconnessi o eliminati. Le azioni sensibili dello '
            'staff producono registri di audit minimizzati per responsabilità '
            'e sicurezza. Sono usati controlli di accesso, sessioni protette e '
            'altre misure tecniche, ma nessun sistema è completamente privo '
            'di rischio.',
      ),
      _LegalSection(
        title: '9. Conservazione e cancellazione account',
        body: 'Account, profilo e contenuti sono conservati finché necessari '
            'a fornire il servizio o fino alla cancellazione, salvo esigenze '
            'di sicurezza, moderazione, difesa di diritti o obblighi di legge. '
            'L’utente può eliminare definitivamente l’account dall’app con '
            'conferma forte. L’email, l’avatar e i dati personali del profilo '
            'vengono eliminati o anonimizzati. Alcuni contenuti storici, '
            'riferimenti tecnici, segnalazioni e registri di audit possono '
            'rimanere in forma anonimizzata o minimizzata per preservare '
            'l’integrità delle discussioni, prevenire abusi e documentare '
            'azioni amministrative. I periodi applicabili alle singole '
            'categorie devono essere riesaminati prima della release.',
      ),
      _LegalSection(
        title: '10. Diritti',
        body: 'Nei casi previsti dalla legge l’utente può chiedere accesso, '
            'rettifica, cancellazione, limitazione, opposizione, portabilità '
            'e revoca del consenso scrivendo a socialvote@hotmail.com. Può '
            'inoltre proporre reclamo al Garante per la protezione dei dati '
            'personali o all’autorità di controllo competente. Potrà essere '
            'richiesta una verifica ragionevole dell’identità prima di '
            'rispondere alla richiesta.',
      ),
      _LegalSection(
        title: '11. Minori',
        body: 'Social Vote è destinato a persone di almeno 14 anni. Chi ha '
            'meno di 14 anni non deve creare un account o usare le funzioni '
            'sociali. Se la legge del Paese dell’utente richiede un’età '
            'superiore o l’autorizzazione di chi esercita la responsabilità '
            'genitoriale, si applica tale requisito. Se viene rilevato un '
            'account di un minore non autorizzato, il titolare può limitarlo '
            'o eliminarlo e invita il genitore o tutore a contattare '
            'socialvote@hotmail.com.',
      ),
      _LegalSection(
        title: '12. Vendita dati e pubblicità',
        body: 'Social Vote non vende i dati personali degli utenti e non usa '
            'i dati dichiarati in questa informativa per pubblicità '
            'personalizzata. Eventuali future funzioni pubblicitarie o nuovi '
            'fornitori richiederanno un aggiornamento preventivo '
            'dell’informativa e delle scelte disponibili all’utente.',
      ),
      _LegalSection(
        title: '13. Modifiche ed efficacia',
        body: 'Questa è una versione pre-release aggiornata il 3 agosto 2026. '
            'Le modifiche sostanziali saranno comunicate nell’app o tramite '
            'un canale appropriato. La versione destinata alla pubblicazione '
            'dovrà essere riesaminata dopo il completamento dei punti indicati '
            'nell’avviso iniziale.',
      ),
    ],
  );

  static const _LegalDocument _privacyEnglish = _LegalDocument(
    notice: 'PRE-RELEASE NOTICE — updated on 3 August 2026. The controller, '
        'privacy contact and minimum age have been defined. Before public '
        'release, Analytics consent controls, the handling of special-category '
        'data potentially revealed by votes and content, retention periods '
        'and international transfers must be completed and verified.',
    sections: [
      _LegalSection(
        title: '1. Controller and contact details',
        body: 'The controller for Social Vote is Reza Hematian, acting as an '
            'individual. Privacy requests and data-subject rights can be sent '
            'to socialvote@hotmail.com. The controller’s home address is not '
            'published; a professional postal contact will be defined before '
            'release if required by applicable law or app stores.',
      ),
      _LegalSection(
        title: '2. Data processed',
        body: 'Social Vote processes account data required for the service, '
            'including email address, user identifier and authentication data '
            'managed by Supabase; profile data such as display name, username, '
            'country, city, biography, avatar, public identity type and '
            'verification status; verification-request data such as official '
            'title, institution or organisation name, outcome and review '
            'notes; content and interactions such as polls, voting choices, '
            'posts, comments, reactions, favourites, reports and '
            'notifications; location data chosen by the user; and technical '
            'and usage events described below.',
      ),
      _LegalSection(
        title: '3. Purposes and legal bases',
        body: 'Data is used to register and secure accounts, provide polls and '
            'social features, personalise geographic scope, manage '
            'verification, notifications and preferences, prevent abuse, '
            'moderate content and accounts, secure the service and respond to '
            'legal requests. The legal basis is performance of the service '
            'requested by the user; security, abuse prevention and the defence '
            'of rights rely on the controller’s legitimate interests; legal '
            'obligations apply where required. Precise location is used only '
            'after the user chooses the feature and grants permission. Any '
            'consent-based processing can be withdrawn without affecting '
            'processing already carried out lawfully.',
      ),
      _LegalSection(
        title: '4. Visibility and special-category data',
        body: 'Display name, username, avatar, verification indicators and '
            'published content may be visible to other users and on the Web. '
            'The visibility of voting choices depends on each poll’s rules. '
            'Content, polls and votes may reveal political opinions, beliefs '
            'or other special-category data. Users must not publish their own '
            'or another person’s special-category data unless doing so is '
            'necessary and lawful. Before public release, Social Vote must '
            'define and implement the specific conditions required by '
            'Article 9 GDPR for such data.',
      ),
      _LegalSection(
        title: '5. Location and geocoding',
        body: 'Precise location is requested only when a user chooses to use '
            'the device location for a post or poll. Permission can be denied '
            'or revoked in device settings. When applied to content, location '
            'may include coordinates, country and city and may be stored with '
            'that content. The operating system’s geocoding service may be '
            'used to turn coordinates into a place and OpenStreetMap '
            'Nominatim may be used as a fallback; the coordinates required for '
            'the request are then sent to that service.',
      ),
      _LegalSection(
        title: '6. Analytics and local storage',
        body: 'On supported runtimes Social Vote uses Firebase Analytics to '
            'measure screens and events such as registration, login, creating '
            'posts or polls, comments and votes. Events may include technical '
            'content identifiers, action characteristics, device information '
            'and identifiers generated by the service, but not post or comment '
            'text or passwords. Language, theme, News preferences and the '
            '“Remember me” option may be stored locally on the device. Before '
            'public release, non-essential Analytics collection must be made '
            'subject to the choices and consent required by applicable law.',
      ),
      _LegalSection(
        title: '7. Providers and transfers',
        body: 'Supabase provides authentication, database, file storage, '
            'backend functions and realtime services. Google Firebase '
            'provides Analytics and technical components on supported '
            'runtimes. Device geocoding services and OpenStreetMap Nominatim '
            'may receive coordinates when the location feature is used. News '
            'comes from external sources and is processed by the backend. '
            'These providers may process data outside the European Economic '
            'Area using adequacy decisions, standard contractual clauses or '
            'other safeguards where required. Configurations, regions and '
            'safeguards must be verified before release.',
      ),
      _LegalSection(
        title: '8. Moderation, staff and security',
        body: 'Reports, verification requests and content may be reviewed by '
            'authorised moderators or administrators. In response to '
            'violations, abuse or security risks, content may be hidden or '
            'restored and accounts may be suspended, reactivated, signed out '
            'or deleted. Sensitive staff actions create minimised audit logs '
            'for accountability and security. Access controls, protected '
            'sessions and other technical safeguards are used, but no system '
            'is completely risk-free.',
      ),
      _LegalSection(
        title: '9. Retention and account deletion',
        body: 'Accounts, profiles and content are retained while needed to '
            'provide the service or until deletion, subject to security, '
            'moderation, legal-defence and legal-obligation requirements. '
            'Users can permanently delete their account in the app using a '
            'strong confirmation. Email address, avatar and personal profile '
            'data are deleted or anonymised. Some historical content, '
            'technical references, reports and audit records may remain in '
            'anonymised or minimised form to preserve discussion integrity, '
            'prevent abuse and document administrative actions. Retention '
            'periods for each category must be reviewed before release.',
      ),
      _LegalSection(
        title: '10. Rights',
        body: 'Where provided by law, users may request access, correction, '
            'erasure, restriction, objection, portability and withdrawal of '
            'consent by writing to socialvote@hotmail.com. Users may also '
            'lodge a complaint with the Italian Data Protection Authority or '
            'their competent supervisory authority. Reasonable identity '
            'verification may be requested before a request is fulfilled.',
      ),
      _LegalSection(
        title: '11. Children',
        body: 'Social Vote is intended for people aged 14 or older. A person '
            'under 14 must not create an account or use social features. If '
            'the user’s country requires a higher age or authorisation from a '
            'holder of parental responsibility, that requirement applies. If '
            'an unauthorised child account is identified, the controller may '
            'restrict or delete it and asks the parent or guardian to contact '
            'socialvote@hotmail.com.',
      ),
      _LegalSection(
        title: '12. Data sales and advertising',
        body: 'Social Vote does not sell users’ personal data and does not use '
            'the data described in this notice for personalised advertising. '
            'Any future advertising feature or new provider will require a '
            'prior update to this notice and to the choices available to '
            'users.',
      ),
      _LegalSection(
        title: '13. Changes and effective date',
        body: 'This is a pre-release version updated on 3 August 2026. '
            'Material changes will be communicated in the app or through an '
            'appropriate channel. The publication version must be reviewed '
            'after the items listed in the opening notice have been '
            'completed.',
      ),
    ],
  );
}
