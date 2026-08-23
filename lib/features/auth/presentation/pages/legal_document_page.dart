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
    final languageCode =
        Localizations.localeOf(context).languageCode.toLowerCase();
    final document = _LegalDocument.forType(
      type,
      languageCode: languageCode,
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
    required String languageCode,
  }) {
    final isItalian = languageCode == 'it';
    final isGerman = languageCode == 'de';

    if (type == LegalDocumentType.terms) {
      if (isItalian) return _termsItalian;
      if (isGerman) return _termsGerman;
      return _termsEnglish;
    }

    if (isItalian) return _privacyItalian;
    if (isGerman) return _privacyGerman;
    return _privacyEnglish;
  }

  static const _LegalDocument _termsItalian = _LegalDocument(
    notice: 'Versione aggiornata al 23 agosto 2026. Sito ufficiale: '
        'socialevote.com. Social Vote è destinato esclusivamente a persone '
        'di almeno 18 anni.',
    sections: [
      _LegalSection(
        title: '1. Gestore, contatti e accettazione',
        body: 'Social Vote è gestito da Reza Hematian. Il sito ufficiale è '
            'socialevote.com e il contatto per account, supporto e questioni '
            'relative ai presenti Termini è support@socialevote.com. Creando '
            'un account, l’utente conferma di avere almeno 18 anni, accetta '
            'questi Termini e conferma di aver letto l’Informativa sulla '
            'privacy. Chi non accetta i Termini non deve creare o usare un '
            'account.',
      ),
      _LegalSection(
        title: '2. Il servizio',
        body: 'Social Vote è una piattaforma civica e sociale che consente di '
            'consultare contenuti pubblici, usare Pulse e Pulse Now, '
            'partecipare a Vote (sondaggi e consultazioni), pubblicare Voci, '
            'commentare, reagire, salvare contenuti, consultare News e usare '
            'funzioni geografiche e Civic Map. Il servizio include inoltre '
            'profili Organization, Workspace per soggetti autorizzati e '
            'Sessions per consultazioni o partecipazione live. Alcune '
            'funzioni richiedono autenticazione, autorizzazioni o uno stato di '
            'verifica specifico. Il servizio può essere modificato, sospeso o '
            'aggiornato per sicurezza, conformità, manutenzione o '
            'miglioramento del prodotto.',
      ),
      _LegalSection(
        title: '3. Età, account e credenziali',
        body: 'Per creare un account è necessario avere almeno 18 anni. '
            'L’utente deve fornire informazioni corrette, proteggere le '
            'credenziali e non consentire a terzi di usare il proprio account. '
            'Social Vote può applicare controlli contro abuso, account '
            'multipli, email temporanee, riuso abusivo di credenziali o altre '
            'condotte incompatibili con la sicurezza del servizio. Il nome '
            'utente iniziale può essere generato automaticamente dal sistema e '
            'può essere modificato in seguito secondo le regole disponibili '
            'nel profilo.',
      ),
      _LegalSection(
        title: '4. Regole di comportamento',
        body: 'Sono vietati contenuti o attività illegali, fraudolenti, '
            'ingannevoli, minacciosi, discriminatori, molesti o abusivi; '
            'impersonificazione; spam; manipolazione di voti, segnalazioni o '
            'sistemi di verifica; accessi non autorizzati; diffusione illecita '
            'di dati personali; sfruttamento di minori; e violazioni di '
            'copyright o di altri diritti di terzi. È inoltre vietato tentare '
            'di aggirare limitazioni tecniche, controlli di sicurezza o regole '
            'di partecipazione.',
      ),
      _LegalSection(
        title: '5. Contenuti dell’utente',
        body: 'L’utente conserva i diritti sui contenuti che pubblica e '
            'dichiara di avere i diritti e le autorizzazioni necessari. Con la '
            'pubblicazione concede a Social Vote una licenza non esclusiva, '
            'limitata a quanto necessario per ospitare, riprodurre, adattare '
            'tecnicamente, mostrare, distribuire e moderare il contenuto '
            'all’interno del servizio. La gestione dei dati dopo la '
            'cancellazione è descritta nell’Informativa sulla privacy.',
      ),
      _LegalSection(
        title: '6. Sondaggi, voti, News e posizione',
        body: 'Salvo indicazione espressa e verificabile, i sondaggi di Social '
            'Vote non sono elezioni ufficiali, referendum legalmente '
            'vincolanti, rilevazioni statisticamente rappresentative o '
            'consulenza professionale. Le regole di partecipazione e '
            'visibilità possono variare da sondaggio a sondaggio. Le News '
            'provengono da fonti esterne e possono essere soggette a ritardi, '
            'modifiche o indisponibilità. Le funzioni di posizione sono '
            'facoltative e devono essere usate senza esporre indebitamente '
            'dati personali propri o di terzi.',
      ),
      _LegalSection(
        title: '7. Segnalazioni, moderazione e riesame',
        body: 'Contenuti e account possono essere segnalati. Moderatori e '
            'amministratori autorizzati possono esaminare le segnalazioni e, '
            'quando necessario, nascondere o ripristinare contenuti, '
            'sospendere o riattivare account, revocare sessioni o adottare '
            'altre misure proporzionate per violazioni, abuso, sicurezza o '
            'obblighi di legge. Quando applicabile, il motivo della decisione '
            'viene reso disponibile. Per chiedere un riesame è possibile '
            'scrivere a support@socialevote.com indicando le informazioni '
            'necessarie a identificare account, contenuto e decisione.',
      ),
      _LegalSection(
        title: '8. Cancellazione dell’account e cessazione',
        body: 'L’utente può chiedere la cancellazione dell’account dall’app '
            'mediante la procedura prevista oppure tramite la pagina pubblica '
            'di cancellazione disponibile sul sito ufficiale. Gli effetti '
            'della cancellazione sui diversi tipi di dati sono descritti '
            'nell’Informativa sulla privacy. Social Vote può limitare o '
            'chiudere un account per violazioni gravi o ripetute, rischio di '
            'sicurezza, obbligo legale o impossibilità di continuare a fornire '
            'il servizio.',
      ),
      _LegalSection(
        title: '9. Proprietà intellettuale e contenuti di terzi',
        body: 'Il software, il nome, la grafica e gli elementi originali di '
            'Social Vote sono protetti dalle norme applicabili. Marchi, News '
            'e altri contenuti di terzi appartengono ai rispettivi titolari. '
            'Questi Termini non trasferiscono diritti ulteriori rispetto a '
            'quelli necessari per il normale uso del servizio.',
      ),
      _LegalSection(
        title: '10. Disponibilità e responsabilità',
        body: 'Social Vote adotta misure ragionevoli per sicurezza e '
            'continuità, ma non garantisce che il servizio sia sempre '
            'disponibile, privo di errori o che i contenuti pubblicati da '
            'utenti o fonti esterne siano completi o accurati. Nulla nei '
            'presenti Termini limita diritti dei consumatori o responsabilità '
            'che non possono essere escluse dalla legge applicabile.',
      ),
      _LegalSection(
        title: '11. Modifiche ai Termini',
        body: 'I Termini possono essere aggiornati per modifiche del servizio, '
            'sicurezza, legge o conformità. Le modifiche sostanziali saranno '
            'comunicate con un mezzo appropriato quando richiesto. Se una '
            'modifica richiede una nuova accettazione, l’utente dovrà '
            'accettare la versione aggiornata prima di continuare a usare le '
            'funzioni interessate.',
      ),
      _LegalSection(
        title: '12. Legge applicabile e contatti',
        body: 'Si applica la legge italiana, fatti salvi i diritti '
            'inderogabili riconosciuti all’utente dalla normativa applicabile '
            'nel proprio Paese. Per richieste sui Termini, moderazione o '
            'account è possibile scrivere a support@socialevote.com. I Termini '
            'sono disponibili pubblicamente su socialevote.com/terms.',
      ),
      _LegalSection(
        title: '13. Organizations, membership e identità ufficiale',
        body:
            'Un account personale può gestire una Organization separata tramite '
            'membership e ruoli autorizzati. Chi agisce per una Organization '
            'dichiara di avere l’autorità necessaria per rappresentarla o '
            'gestirne le funzioni. I dati e i contenuti pubblicati come '
            'Organization devono essere corretti e non ingannevoli. La verifica '
            'di una Organization è distinta dai servizi a pagamento e non può '
            'essere acquistata. Social Vote può sospendere o rivedere accessi al '
            'Workspace quando vengono meno autorizzazione, sicurezza o requisiti '
            'di verifica.',
      ),
      _LegalSection(
        title: '14. Sessions, Access Pass e responsabilità dell’organizzatore',
        body: 'Le Sessions consentono consultazioni o partecipazione live in '
            'modalità Anonima aperta o Anonima controllata. La modalità aperta '
            'usa controlli best-effort e non garantisce una persona-un voto. La '
            'modalità controllata usa Access Pass anonimi monouso; Social Vote '
            'conserva gli hash necessari alla verifica del pass e separa la '
            'credenziale tecnica dalla scheda di voto. L’organizzatore definisce '
            'scopo operativo, domande, visibilità dei risultati e periodo di '
            'conservazione disponibile e deve fornire informative e basi '
            'giuridiche adeguate al proprio caso d’uso. Nel pilot le Sessions '
            'non devono essere usate come elezioni ufficiali, votazioni '
            'statutarie legalmente vincolanti o sostituti di procedure che '
            'richiedono requisiti legali o tecnici ulteriori.',
      ),
      _LegalSection(
        title: '15. Verified Result e integrità',
        body:
            'Alla chiusura di una Session può essere creato un Verified Result '
            'con snapshot aggregato, identificativo del report e controllo di '
            'integrità SHA-256. Quando la policy lo consente, il report può '
            'essere verificato tramite URL o QR pubblico; con risultati Solo '
            'organizzatore la verifica pubblica è disabilitata. Il controllo di '
            'integrità serve a rilevare modifiche rispetto allo snapshot '
            'sigillato: non costituisce certificazione notarile, elettorale, '
            'statutaria o legalmente vincolante. L’anonimato tecnico non elimina '
            'il rischio che una domanda o il contesto scelti dall’organizzatore '
            'rendano una risposta indirettamente identificabile.',
      ),
      _LegalSection(
        title: '16. Pilot Business e future funzioni a pagamento',
        body: 'Organizations e Sessions sono attualmente disponibili nel pilot '
            'secondo le condizioni mostrate nel prodotto, senza billing '
            'automatico. Eventuali futuri piani Business, limiti o funzioni a '
            'pagamento saranno presentati separatamente con prezzi, condizioni '
            'e accettazione applicabili prima di qualsiasi addebito. Un '
            'pagamento non conferisce né garantisce uno stato di verifica. Gli '
            'utenti Business restano responsabili della liceità delle proprie '
            'domande, contenuti, finalità e modalità di utilizzo del servizio.',
      ),
    ],
  );

  static const _LegalDocument _termsEnglish = _LegalDocument(
    notice: 'Version updated on 23 August 2026. Official website: '
        'socialevote.com. Social Vote is intended only for people aged 18 or '
        'older.',
    sections: [
      _LegalSection(
        title: '1. Operator, contact and acceptance',
        body: 'Social Vote is operated by Reza Hematian. The official website '
            'is socialevote.com and the contact address for accounts, support '
            'and these Terms is support@socialevote.com. By creating an '
            'account, users confirm that they are at least 18 years old, '
            'accept these Terms and confirm that they have read the Privacy '
            'Policy. Anyone who does not accept the Terms must not create or '
            'use an account.',
      ),
      _LegalSection(
        title: '2. The service',
        body: 'Social Vote is a civic and social platform that allows people '
            'to read public content, use Pulse and Pulse Now, participate in '
            'Vote (polls and consultations), publish Voci, comment, react, '
            'save content, read News and use geographic features and Civic '
            'Map. The service also includes Organization profiles, Workspaces '
            'for authorised managers and Sessions for live consultation or '
            'participation. Some features require authentication, permission '
            'or a specific verification status. The service may be changed, '
            'suspended or updated for security, compliance, maintenance or '
            'product improvement.',
      ),
      _LegalSection(
        title: '3. Age, accounts and credentials',
        body: 'Users must be at least 18 years old to create an account. Users '
            'must provide accurate information, protect their credentials and '
            'must not allow others to use their account. Social Vote may apply '
            'controls against abuse, multiple accounts, disposable email '
            'addresses, abusive credential reuse or other conduct that '
            'conflicts with service security. The initial username may be '
            'generated automatically by the system and may later be changed '
            'subject to the profile rules available at that time.',
      ),
      _LegalSection(
        title: '4. Rules of conduct',
        body: 'Illegal, fraudulent, deceptive, threatening, discriminatory, '
            'harassing or abusive content or activity is prohibited, as are '
            'impersonation, spam, manipulation of votes, reports or '
            'verification systems, unauthorised access, unlawful disclosure '
            'of personal data, child exploitation and infringement of '
            'copyright or other third-party rights. Attempts to bypass '
            'technical restrictions, security controls or participation rules '
            'are also prohibited.',
      ),
      _LegalSection(
        title: '5. User content',
        body: 'Users retain rights in the content they publish and confirm '
            'that they have the rights and permissions required to do so. By '
            'publishing, users grant Social Vote a non-exclusive licence '
            'limited to what is necessary to host, reproduce, technically '
            'adapt, display, distribute and moderate the content within the '
            'service. Data handling after account deletion is described in '
            'the Privacy Policy.',
      ),
      _LegalSection(
        title: '6. Polls, votes, News and location',
        body: 'Unless expressly and verifiably stated otherwise, Social Vote '
            'polls are not official elections, legally binding referendums, '
            'statistically representative surveys or professional advice. '
            'Participation and visibility rules may vary between polls. News '
            'comes from external sources and may be delayed, changed or '
            'unavailable. Location features are optional and must be used '
            'without unnecessarily exposing personal data belonging to the '
            'user or third parties.',
      ),
      _LegalSection(
        title: '7. Reports, moderation and review',
        body: 'Content and accounts may be reported. Authorised moderators '
            'and administrators may review reports and, where needed, hide or '
            'restore content, suspend or reactivate accounts, revoke sessions '
            'or take other proportionate measures for violations, abuse, '
            'security or legal obligations. Where applicable, reasons for a '
            'decision are made available. A review may be requested by '
            'emailing support@socialevote.com with enough information to '
            'identify the account, content and decision.',
      ),
      _LegalSection(
        title: '8. Account deletion and termination',
        body: 'Users may request account deletion through the in-app procedure '
            'or the public deletion page on the official website. The effects '
            'of deletion on different categories of data are described in the '
            'Privacy Policy. Social Vote may restrict or close an account for '
            'serious or repeated violations, security risk, legal obligation '
            'or an inability to continue providing the service.',
      ),
      _LegalSection(
        title: '9. Intellectual property and third-party content',
        body: 'The software, name, graphics and original elements of Social '
            'Vote are protected by applicable law. Third-party trademarks, '
            'News and other content belong to their respective owners. These '
            'Terms do not transfer rights beyond those needed for normal use '
            'of the service.',
      ),
      _LegalSection(
        title: '10. Availability and liability',
        body: 'Social Vote takes reasonable measures for security and '
            'continuity but does not guarantee that the service will always be '
            'available or error-free, or that content published by users or '
            'external sources will be complete or accurate. Nothing in these '
            'Terms limits consumer rights or liability that cannot be excluded '
            'under applicable law.',
      ),
      _LegalSection(
        title: '11. Changes to the Terms',
        body: 'The Terms may be updated for service changes, security, law or '
            'compliance. Material changes will be communicated through an '
            'appropriate channel where required. If a change requires renewed '
            'acceptance, users must accept the updated version before '
            'continuing to use the affected features.',
      ),
      _LegalSection(
        title: '12. Applicable law and contact',
        body: 'Italian law applies, without prejudice to mandatory rights '
            'available to users under the law applicable in their country. '
            'Questions about these Terms, moderation or accounts can be sent '
            'to support@socialevote.com. The Terms are publicly available at '
            'socialevote.com/terms.',
      ),
      _LegalSection(
        title: '13. Organizations, membership and official identity',
        body: 'A personal account may manage a separate Organization through '
            'membership and authorised roles. Anyone acting for an Organization '
            'represents that they have the authority needed to represent or '
            'manage it. Information and content published as an Organization '
            'must be accurate and not misleading. Organization verification is '
            'separate from paid services and cannot be purchased. Social Vote '
            'may suspend or review Workspace access where authority, security or '
            'verification requirements are no longer met.',
      ),
      _LegalSection(
        title: '14. Sessions, Access Passes and organizer responsibilities',
        body: 'Sessions support live consultation or participation using Open '
            'Anonymous or Controlled Anonymous access. Open Anonymous uses '
            'best-effort duplicate controls and does not guarantee '
            'one-person-one-vote. Controlled Anonymous uses one-time anonymous '
            'Access Passes; Social Vote stores the hashes needed to validate the '
            'pass and keeps the technical credential separate from the ballot. '
            'The organizer defines the operational purpose, questions, result '
            'visibility and available retention period and must provide '
            'appropriate notices and lawful grounds for its own use case. '
            'During the pilot, Sessions must not be used as official elections, '
            'legally binding statutory votes or substitutes for procedures that '
            'require additional legal or technical requirements.',
      ),
      _LegalSection(
        title: '15. Verified Result and integrity',
        body: 'When a Session closes, a Verified Result may be created with an '
            'aggregate snapshot, report identifier and SHA-256 integrity check. '
            'Where the policy allows, the report may be verified through a '
            'public URL or QR code; for Organizer Only results, public '
            'verification is disabled. The integrity check is intended to '
            'detect changes compared with the sealed snapshot; it is not '
            'notarial, electoral, statutory or legally binding certification. '
            'Technical anonymity does not remove the risk that questions or '
            'context chosen by an organizer may make a response indirectly '
            'identifiable.',
      ),
      _LegalSection(
        title: '16. Business pilot and future paid features',
        body: 'Organizations and Sessions are currently available under the '
            'pilot conditions shown in the product, with no automatic billing. '
            'Any future Business plans, limits or paid features will be '
            'presented separately with applicable pricing, terms and acceptance '
            'before any charge. Payment does not confer or guarantee verified '
            'status. Business users remain responsible for the lawfulness of '
            'their questions, content, purposes and use of the service.',
      ),
    ],
  );

  static const _LegalDocument _privacyItalian = _LegalDocument(
    notice: 'Informativa aggiornata al 23 agosto 2026. Sito ufficiale: '
        'socialevote.com. Social Vote è destinato esclusivamente a persone '
        'di almeno 18 anni.',
    sections: [
      _LegalSection(
        title: '1. Titolare e contatti',
        body: 'Il titolare del trattamento di Social Vote è Reza Hematian. '
            'Per richieste privacy e per esercitare i diritti previsti dalla '
            'normativa è possibile scrivere a support@socialevote.com. Il sito '
            'ufficiale è socialevote.com.',
      ),
      _LegalSection(
        title: '2. Dati trattati',
        body: 'Social Vote può trattare dati di account e autenticazione, '
            'inclusi email, identificativo utente e sessione; dati del profilo '
            'come nome pubblico, username inizialmente generato dal sistema, '
            'paese e città di residenza, biografia, avatar, identità pubblica '
            'e stato di verifica; dati delle richieste di verifica; sondaggi, '
            'voti, post, commenti, reazioni, preferiti, segnalazioni e '
            'notifiche; dati di posizione scelti dall’utente; preferenze '
            'dell’app; e dati tecnici necessari a sicurezza, funzionamento e '
            'diagnostica del servizio.',
      ),
      _LegalSection(
        title: '3. Finalità e basi giuridiche',
        body: 'I dati sono trattati per creare e gestire l’account, fornire '
            'sondaggi e funzioni sociali, applicare regole di partecipazione, '
            'gestire profilo e verifiche, mostrare contenuti pertinenti allo '
            'scope geografico scelto, inviare comunicazioni transazionali, '
            'prevenire abusi, moderare contenuti e account, proteggere il '
            'servizio e adempiere obblighi legali. A seconda del trattamento, '
            'le basi giuridiche possono includere l’esecuzione del servizio '
            'richiesto dall’utente, il legittimo interesse alla sicurezza e '
            'alla prevenzione degli abusi, l’adempimento di obblighi di legge '
            'e, quando richiesto, il consenso.',
      ),
      _LegalSection(
        title: '4. Dati pubblici e dati particolari',
        body: 'Nome pubblico, username, avatar, badge di verifica e contenuti '
            'pubblicati possono essere visibili ad altri utenti e, per i '
            'contenuti pubblici, sul Web. Sondaggi, voti o contenuti possono '
            'rivelare opinioni politiche, convinzioni o altri dati particolari '
            'ai sensi della normativa sulla protezione dei dati. Social Vote '
            'non usa tali dati per pubblicità personalizzata o per dedurre '
            'profili politici a fini commerciali. Quando un trattamento '
            'richiede una specifica condizione prevista dall’articolo 9 GDPR, '
            'tale condizione deve essere applicabile prima del trattamento.',
      ),
      _LegalSection(
        title: '5. Posizione, residenza e GeoScope',
        body: 'Il paese e la città di residenza del profilo sono separati '
            'dallo scope geografico di navigazione e dalla località associata '
            'a un contenuto. La città di residenza è facoltativa. Quando '
            'l’utente inserisce una città, Social Vote può verificarla tramite '
            'Nominatim di OpenStreetMap. Se l’utente sceglie funzioni basate '
            'sulla posizione del dispositivo, possono essere trattate '
            'coordinate e informazioni di località necessarie alla funzione. '
            'I permessi di posizione possono essere negati o revocati nelle '
            'impostazioni del dispositivo.',
      ),
      _LegalSection(
        title: '6. Memoria locale, sessioni e Firebase',
        body: 'L’app può conservare localmente preferenze come lingua, tema, '
            'News e impostazione “Ricordami”. Quando “Ricordami” è attivo, '
            'una sessione tecnica di autenticazione Supabase può essere '
            'conservata localmente; al logout la sessione viene rimossa. '
            'Firebase Analytics è configurato con la raccolta disattivata. '
            'Componenti Firebase possono generare automaticamente un Firebase '
            'Installation ID (FID), identificatore tecnico distinto per '
            'installazione che non identifica direttamente una persona o un '
            'dispositivo fisico. Social Vote non usa Advertising ID per '
            'pubblicità personalizzata.',
      ),
      _LegalSection(
        title: '7. Fornitori e destinatari',
        body: 'Supabase fornisce autenticazione, database, storage e funzioni '
            'backend. Google Firebase fornisce componenti tecnici e hosting '
            'Web sui runtime configurati. Brevo può essere utilizzato per '
            'l’invio di email transazionali tramite la configurazione SMTP. '
            'OpenStreetMap Nominatim può ricevere dati di località necessari '
            'alla geocodifica. Fonti e provider News possono elaborare le '
            'richieste necessarie a fornire notizie. Dati possono inoltre '
            'essere comunicati ad autorità o altri soggetti quando richiesto '
            'dalla legge o necessario per tutelare diritti e sicurezza.',
      ),
      _LegalSection(
        title: '8. Trasferimenti internazionali',
        body: 'Alcuni fornitori possono trattare dati al di fuori dello Spazio '
            'economico europeo. Quando il GDPR lo richiede, i trasferimenti '
            'devono avvenire sulla base di una decisione di adeguatezza, '
            'clausole contrattuali standard o altro meccanismo valido previsto '
            'dalla normativa applicabile.',
      ),
      _LegalSection(
        title: '9. Moderazione, sicurezza e audit',
        body: 'Segnalazioni, richieste di verifica e contenuti possono essere '
            'esaminati da moderatori o amministratori autorizzati. In risposta '
            'a violazioni, abuso o rischi di sicurezza, contenuti possono '
            'essere nascosti o ripristinati e account possono essere sospesi, '
            'riattivati, disconnessi o eliminati. Alcune azioni amministrative '
            'e di sicurezza producono registri di audit minimizzati necessari '
            'per responsabilità, sicurezza e difesa dei diritti.',
      ),
      _LegalSection(
        title: '10. Conservazione e cancellazione account',
        body: 'I dati sono conservati per il tempo necessario alle finalità '
            'descritte e secondo gli obblighi applicabili. Quando un account '
            'viene eliminato, l’account Auth è cancellato; post, sondaggi e '
            'commenti propri vengono eliminati; profilo, avatar, preferiti, '
            'notifiche, sessioni e altri dati personali previsti dalla '
            'procedura vengono eliminati. Voti e reazioni su contenuti altrui '
            'possono essere mantenuti in forma anonimizzata per preservare '
            'risultati e statistiche storiche. Un riferimento tecnico '
            'anonimizzato può essere mantenuto dove necessario all’integrità '
            'referenziale. Registri amministrativi o di sicurezza possono '
            'essere conservati in forma minimizzata quando necessari per '
            'sicurezza, responsabilità o obblighi legali.',
      ),
      _LegalSection(
        title: '11. Diritti dell’interessato',
        body: 'Nei casi previsti dalla legge, l’utente può chiedere accesso, '
            'rettifica, cancellazione, limitazione, opposizione e portabilità '
            'dei propri dati, nonché revocare un consenso quando il trattamento '
            'si basa sul consenso. Le richieste possono essere inviate a '
            'support@socialevote.com. Può essere richiesta una verifica '
            'ragionevole dell’identità. L’utente può inoltre proporre reclamo '
            'al Garante per la protezione dei dati personali o all’autorità di '
            'controllo competente.',
      ),
      _LegalSection(
        title: '12. Età minima, vendita dati e pubblicità',
        body: 'Social Vote è destinato esclusivamente a persone di almeno 18 '
            'anni. Social Vote non vende i dati personali degli utenti e non '
            'usa i dati descritti in questa informativa per pubblicità '
            'personalizzata. Eventuali future funzioni pubblicitarie o nuovi '
            'trattamenti richiederanno un aggiornamento dell’informativa e, '
            'quando necessario, delle scelte disponibili all’utente.',
      ),
      _LegalSection(
        title: '13. Modifiche ed efficacia',
        body: 'Questa informativa è aggiornata al 23 agosto 2026. Le modifiche '
            'sostanziali saranno comunicate tramite l’app o un altro canale '
            'appropriato quando richiesto. La versione pubblica è disponibile '
            'su socialevote.com/privacy.',
      ),
      _LegalSection(
        title: '14. Organizations, membership e dati del Workspace',
        body: 'Per creare, verificare e gestire una Organization, Social Vote '
            'può trattare denominazione legale e nome pubblico, tipo di '
            'organizzazione, Paese e città, sito, descrizione, logo e copertina, '
            'stato di verifica, dati ed evidenze forniti nella richiesta, ruolo '
            'del rappresentante e dati di membership come account membro, ruolo '
            'e stato. I dati destinati al profilo pubblico della Organization '
            'possono essere visibili sul Web; dati interni di membership, audit '
            'e verifica sono limitati agli accessi autorizzati secondo le '
            'relative funzioni e policy.',
      ),
      _LegalSection(
        title: '15. Sessions e dati dei partecipanti',
        body: 'Una Session può includere titolo, configurazione, domande e '
            'opzioni, stato, modalità di accesso, visibilità dei risultati, '
            'numero previsto di partecipanti, contatori e periodo di '
            'conservazione. In Controlled Anonymous gli Access Pass in chiaro '
            'sono mostrati all’organizzatore solo quando vengono generati; il '
            'backend conserva l’hash necessario alla validazione. Al '
            'partecipante viene assegnata una credenziale tecnica della Session '
            'che può essere conservata localmente nel browser per impedire '
            'duplicazioni ordinarie e mantenere lo stato. La scheda di voto è '
            'separata e non contiene campi che colleghino identità, Access Pass '
            'o credenziale partecipante alla scelta. In Open Anonymous i '
            'controlli contro duplicazioni e abuso sono best-effort e non '
            'costituiscono garanzia una persona-un voto.',
      ),
      _LegalSection(
        title: '16. Conservazione Sessions e Verified Result',
        body: 'Per le schede grezze di una Session l’organizzatore sceglie tra '
            'i periodi disponibili nel prodotto: 24 ore, 7 giorni o 30 giorni. '
            'I dati tecnici strettamente necessari a sicurezza, controllo '
            'anti-abuso o integrità possono seguire periodi diversi quando '
            'necessario e consentito. Alla chiusura può essere conservato un '
            'Verified Result come snapshot aggregato immutabile con Report ID, '
            'versione/schema e hash SHA-256, per preservare integrità e storico '
            'del risultato. Se la visibilità è Solo organizzatore, il report '
            'non è disponibile tramite verifica pubblica; negli altri casi '
            'previsti può essere accessibile tramite URL o QR di verifica.',
      ),
      _LegalSection(
        title: '17. Ruoli privacy nelle Sessions di una Organization',
        body: 'Quando una Organization usa Sessions per proprie finalità, la '
            'qualificazione dei ruoli privacy dipende dal contesto concreto, '
            'dalle finalità e dagli accordi applicabili. L’organizzatore '
            'definisce normalmente lo scopo operativo e le domande della '
            'Session; Social Vote tratta i dati necessari a fornire, proteggere '
            'e documentare il servizio. Quando Social Vote tratta dati per '
            'conto di un soggetto che agisce come titolare, può essere '
            'necessario un accordo sul trattamento dei dati ai sensi della '
            'normativa applicabile. Questa informativa non assegna in modo '
            'automatico lo stesso ruolo giuridico a ogni possibile Session.',
      ),
      _LegalSection(
        title: '18. Pilot Business e categorie particolari di dati',
        body: 'Nel pilot Business Social Vote raccomanda di non usare Sessions '
            'per raccogliere categorie particolari di dati, dati di minori, '
            'monitoraggio dei dipendenti o altre informazioni ad alto rischio '
            'senza una valutazione specifica. L’organizzatore deve evitare '
            'domande non necessarie e verificare la base giuridica e le '
            'condizioni applicabili quando le risposte possono rivelare dati '
            'particolari. Social Vote non utilizza le scelte nelle Sessions per '
            'pubblicità personalizzata.',
      ),
    ],
  );

  static const _LegalDocument _privacyEnglish = _LegalDocument(
    notice: 'Privacy Policy updated on 23 August 2026. Official website: '
        'socialevote.com. Social Vote is intended only for people aged 18 or '
        'older.',
    sections: [
      _LegalSection(
        title: '1. Controller and contact details',
        body: 'The controller for Social Vote is Reza Hematian. Privacy '
            'requests and data-subject rights may be sent to '
            'support@socialevote.com. The official website is socialevote.com.',
      ),
      _LegalSection(
        title: '2. Data processed',
        body: 'Social Vote may process account and authentication data, '
            'including email address, user identifier and session data; '
            'profile data such as public name, a system-generated initial '
            'username, country and city of residence, biography, avatar, '
            'public identity and verification status; verification-request '
            'data; polls, votes, posts, comments, reactions, favourites, '
            'reports and notifications; location data chosen by the user; app '
            'preferences; and technical data needed for security, operation '
            'and diagnostics.',
      ),
      _LegalSection(
        title: '3. Purposes and legal bases',
        body: 'Data is processed to create and manage accounts, provide polls '
            'and social features, apply participation rules, manage profiles '
            'and verification, show content relevant to the selected '
            'geographic scope, send transactional communications, prevent '
            'abuse, moderate content and accounts, protect the service and '
            'comply with legal obligations. Depending on the processing, the '
            'legal basis may include performance of the service requested by '
            'the user, legitimate interests in security and abuse prevention, '
            'compliance with legal obligations and, where required, consent.',
      ),
      _LegalSection(
        title: '4. Public data and special-category data',
        body:
            'Public name, username, avatar, verification badges and published '
            'content may be visible to other users and, for public content, on '
            'the Web. Polls, votes or content may reveal political opinions, '
            'beliefs or other special-category data under data-protection law. '
            'Social Vote does not use such data for personalised advertising '
            'or to infer political profiles for commercial purposes. Where '
            'processing requires a specific condition under Article 9 GDPR, '
            'that condition must apply before the processing takes place.',
      ),
      _LegalSection(
        title: '5. Location, residence and GeoScope',
        body: 'Profile country and city of residence are separate from the '
            'geographic navigation scope and from the location attached to '
            'content. City of residence is optional. When a city is entered, '
            'Social Vote may verify it using OpenStreetMap Nominatim. If the '
            'user chooses device-location features, coordinates and place '
            'information needed for that feature may be processed. Location '
            'permissions can be denied or revoked in device settings.',
      ),
      _LegalSection(
        title: '6. Local storage, sessions and Firebase',
        body: 'The app may store preferences such as language, theme, News '
            'settings and the “Remember me” choice locally. When “Remember '
            'me” is enabled, a technical Supabase authentication session may '
            'be stored locally; it is removed on logout. Firebase Analytics '
            'is configured with collection disabled. Firebase components may '
            'automatically generate a Firebase Installation ID (FID), a '
            'technical identifier that is different for each installation '
            'and does not directly identify a person or physical device. '
            'Social Vote does not use Advertising ID for personalised '
            'advertising.',
      ),
      _LegalSection(
        title: '7. Providers and recipients',
        body: 'Supabase provides authentication, database, storage and backend '
            'functions. Google Firebase provides technical components and Web '
            'hosting on configured runtimes. Brevo may be used to deliver '
            'transactional email through the configured SMTP service. '
            'OpenStreetMap Nominatim may receive location data required for '
            'geocoding. News sources and providers may process requests '
            'needed to provide News. Data may also be disclosed to authorities '
            'or other recipients where required by law or necessary to '
            'protect rights and security.',
      ),
      _LegalSection(
        title: '8. International transfers',
        body: 'Some providers may process data outside the European Economic '
            'Area. Where the GDPR requires safeguards, transfers must rely on '
            'an adequacy decision, standard contractual clauses or another '
            'valid mechanism under applicable law.',
      ),
      _LegalSection(
        title: '9. Moderation, security and audit',
        body: 'Reports, verification requests and content may be reviewed by '
            'authorised moderators or administrators. In response to '
            'violations, abuse or security risks, content may be hidden or '
            'restored and accounts may be suspended, reactivated, signed out '
            'or deleted. Some administrative and security actions create '
            'minimised audit records needed for accountability, security and '
            'the defence of rights.',
      ),
      _LegalSection(
        title: '10. Retention and account deletion',
        body: 'Data is retained for as long as needed for the purposes '
            'described and applicable obligations. When an account is '
            'deleted, the Auth account is deleted; the user’s own posts, polls '
            'and comments are deleted; the profile, avatar, favourites, '
            'notifications, sessions and other personal data covered by the '
            'deletion procedure are removed. Votes and reactions on other '
            'people’s content may be retained in anonymised form to preserve '
            'historical results and statistics. An anonymised technical '
            'reference may remain where needed for referential integrity. '
            'Administrative or security records may be retained in minimised '
            'form where needed for security, accountability or legal '
            'obligations.',
      ),
      _LegalSection(
        title: '11. Data-subject rights',
        body: 'Where provided by law, users may request access, correction, '
            'erasure, restriction, objection and portability, and may '
            'withdraw consent where processing is based on consent. Requests '
            'may be sent to support@socialevote.com. Reasonable identity '
            'verification may be requested. Users may also lodge a complaint '
            'with the Italian Data Protection Authority or another competent '
            'supervisory authority.',
      ),
      _LegalSection(
        title: '12. Minimum age, data sales and advertising',
        body: 'Social Vote is intended only for people aged 18 or older. '
            'Social Vote does not sell users’ personal data and does not use '
            'the data described in this notice for personalised advertising. '
            'Future advertising features or new processing will require an '
            'update to this notice and, where necessary, to the choices '
            'available to users.',
      ),
      _LegalSection(
        title: '13. Changes and effective date',
        body: 'This Privacy Policy is updated as of 23 August 2026. Material '
            'changes will be communicated through the app or another '
            'appropriate channel where required. The public version is '
            'available at socialevote.com/privacy.',
      ),
      _LegalSection(
        title: '14. Organizations, membership and Workspace data',
        body: 'To create, verify and manage an Organization, Social Vote may '
            'process legal and public name, organization type, country and '
            'city, website, description, logo and cover, verification status, '
            'data and evidence submitted with a request, representative role '
            'and membership data such as member account, role and status. Data '
            'intended for the public Organization profile may be visible on the '
            'Web; internal membership, audit and verification data is limited '
            'to authorised access under the relevant features and policies.',
      ),
      _LegalSection(
        title: '15. Sessions and participant data',
        body: 'A Session may include its title, configuration, questions and '
            'options, status, access mode, result visibility, expected '
            'participant count, counters and retention period. In Controlled '
            'Anonymous, plaintext Access Passes are shown to the organizer only '
            'when they are generated; the backend stores the hash needed for '
            'validation. A participant receives a technical Session credential '
            'that may be stored locally in the browser to prevent ordinary '
            'duplicates and preserve state. The ballot is separate and does '
            'not contain fields linking identity, Access Pass or participant '
            'credential to the choice. In Open Anonymous, duplicate and abuse '
            'controls are best-effort and do not constitute a '
            'one-person-one-vote guarantee.',
      ),
      _LegalSection(
        title: '16. Session retention and Verified Result',
        body: 'For raw Session ballots, the organizer selects one of the '
            'retention periods available in the product: 24 hours, 7 days or '
            '30 days. Technical data strictly necessary for security, abuse '
            'prevention or integrity may follow different periods where '
            'necessary and permitted. When the Session closes, a Verified '
            'Result may be retained as an immutable aggregate snapshot with '
            'Report ID, version/schema and SHA-256 hash to preserve integrity '
            'and the historical result. If visibility is Organizer Only, the '
            'report is not available through public verification; in other '
            'supported cases it may be accessible through a verification URL '
            'or QR code.',
      ),
      _LegalSection(
        title: '17. Privacy roles for Organization Sessions',
        body:
            'When an Organization uses Sessions for its own purposes, privacy '
            'roles depend on the specific context, purposes and applicable '
            'agreements. The organizer normally defines the operational '
            'purpose and Session questions; Social Vote processes data needed '
            'to provide, secure and document the service. Where Social Vote '
            'processes personal data on behalf of an entity acting as '
            'controller, a data-processing agreement may be required under '
            'applicable law. This Privacy Policy does not automatically assign '
            'the same legal role to every possible Session.',
      ),
      _LegalSection(
        title: '18. Business pilot and special-category data',
        body: 'During the Business pilot, Social Vote recommends not using '
            'Sessions to collect special-category data, children’s data, '
            'employee monitoring information or other high-risk information '
            'without a specific assessment. Organizers should avoid unnecessary '
            'questions and verify the applicable lawful basis and conditions '
            'where answers may reveal special-category data. Social Vote does '
            'not use Session choices for personalised advertising.',
      ),
    ],
  );

  static const _LegalDocument _termsGerman = _LegalDocument(
    notice: 'Version aktualisiert am 23. August 2026. Offizielle Website: '
        'socialevote.com. Social Vote richtet sich ausschließlich an Personen '
        'ab 18 Jahren.',
    sections: [
      _LegalSection(
        title: '1. Betreiber, Kontakt und Zustimmung',
        body: 'Social Vote wird von Reza Hematian betrieben. Die offizielle '
            'Website ist socialevote.com; die Kontaktadresse für Konten, '
            'Support und diese Nutzungsbedingungen ist support@socialevote.com. '
            'Mit der Erstellung eines Kontos bestätigt die nutzende Person, '
            'mindestens 18 Jahre alt zu sein, diese Nutzungsbedingungen zu '
            'akzeptieren und die Datenschutzerklärung gelesen zu haben. Wer '
            'diese Bedingungen nicht akzeptiert, darf kein Konto erstellen '
            'oder verwenden.',
      ),
      _LegalSection(
        title: '2. Der Dienst',
        body: 'Social Vote ist eine bürgerorientierte und soziale Plattform. '
            'Sie ermöglicht das Lesen öffentlicher Inhalte, die Nutzung von '
            'Pulse und Pulse Now, die Teilnahme an Vote (Umfragen und '
            'Konsultationen), die Veröffentlichung von Voci, Kommentare, '
            'Reaktionen und gespeicherte Inhalte, das Lesen von News sowie die '
            'Nutzung geografischer Funktionen und der Civic Map. Der Dienst '
            'umfasst außerdem Organization-Profile, Workspaces für autorisierte '
            'Verwaltende und Sessions für Live-Konsultation oder Beteiligung. '
            'Einige Funktionen erfordern Anmeldung, Berechtigung oder einen '
            'bestimmten Verifizierungsstatus. Der Dienst kann aus Gründen der '
            'Sicherheit, Compliance, Wartung oder Produktverbesserung geändert, '
            'vorübergehend ausgesetzt oder aktualisiert werden.',
      ),
      _LegalSection(
        title: '3. Alter, Konten und Zugangsdaten',
        body: 'Für die Erstellung eines Kontos ist ein Mindestalter von 18 '
            'Jahren erforderlich. Nutzende müssen korrekte Angaben machen, '
            'ihre Zugangsdaten schützen und dürfen anderen Personen die '
            'Nutzung ihres Kontos nicht gestatten. Social Vote kann Maßnahmen '
            'gegen Missbrauch, Mehrfachkonten, Wegwerf-E-Mail-Adressen, '
            'missbräuchliche Wiederverwendung von Zugangsdaten oder anderes '
            'sicherheitswidriges Verhalten einsetzen. Der anfängliche '
            'Benutzername kann automatisch vom System erzeugt und später '
            'gemäß den jeweils verfügbaren Profilregeln geändert werden.',
      ),
      _LegalSection(
        title: '4. Verhaltensregeln',
        body: 'Verboten sind rechtswidrige, betrügerische, irreführende, '
            'bedrohende, diskriminierende, belästigende oder missbräuchliche '
            'Inhalte oder Handlungen sowie Identitätstäuschung, Spam, die '
            'Manipulation von Abstimmungen, Meldungen oder '
            'Verifizierungssystemen, unbefugter Zugriff, die rechtswidrige '
            'Offenlegung personenbezogener Daten, die Ausbeutung Minderjähriger '
            'und die Verletzung von Urheberrechten oder sonstigen Rechten '
            'Dritter. Auch der Versuch, technische Beschränkungen, '
            'Sicherheitskontrollen oder Teilnahmeregeln zu umgehen, ist '
            'untersagt.',
      ),
      _LegalSection(
        title: '5. Inhalte der Nutzenden',
        body: 'Nutzende behalten ihre Rechte an den von ihnen veröffentlichten '
            'Inhalten und bestätigen, über die hierfür erforderlichen Rechte '
            'und Genehmigungen zu verfügen. Mit der Veröffentlichung wird '
            'Social Vote eine nicht ausschließliche Lizenz eingeräumt, soweit '
            'dies erforderlich ist, um den Inhalt innerhalb des Dienstes zu '
            'hosten, zu vervielfältigen, technisch anzupassen, anzuzeigen, zu '
            'verbreiten und zu moderieren. Der Umgang mit Daten nach der '
            'Löschung eines Kontos ist in der Datenschutzerklärung beschrieben.',
      ),
      _LegalSection(
        title: '6. Umfragen, Stimmen, Nachrichten und Standort',
        body: 'Sofern nicht ausdrücklich und überprüfbar anders angegeben, '
            'sind Social-Vote-Umfragen keine offiziellen Wahlen, rechtlich '
            'bindenden Referenden, statistisch repräsentativen Erhebungen oder '
            'professionelle Beratung. Teilnahme- und Sichtbarkeitsregeln '
            'können je nach Umfrage variieren. Nachrichten stammen aus externen '
            'Quellen und können verzögert, geändert oder nicht verfügbar sein. '
            'Standortfunktionen sind freiwillig und müssen so verwendet werden, '
            'dass personenbezogene Daten der nutzenden Person oder Dritter '
            'nicht unnötig offengelegt werden.',
      ),
      _LegalSection(
        title: '7. Meldungen, Moderation und Überprüfung',
        body: 'Inhalte und Konten können gemeldet werden. Autorisierte '
            'Moderatoren und Administratoren dürfen Meldungen prüfen und, '
            'soweit erforderlich, Inhalte ausblenden oder wiederherstellen, '
            'Konten sperren oder reaktivieren, Sitzungen widerrufen oder andere '
            'verhältnismäßige Maßnahmen wegen Verstößen, Missbrauch, '
            'Sicherheitsrisiken oder rechtlichen Pflichten ergreifen. Soweit '
            'anwendbar, werden Gründe für eine Entscheidung bereitgestellt. '
            'Eine Überprüfung kann per E-Mail an support@socialevote.com '
            'beantragt werden; dabei müssen genügend Angaben zur Identifizierung '
            'des Kontos, Inhalts und der Entscheidung gemacht werden.',
      ),
      _LegalSection(
        title: '8. Kontolöschung und Beendigung',
        body: 'Nutzende können die Löschung ihres Kontos über das Verfahren in '
            'der App oder über die öffentliche Löschseite auf der offiziellen '
            'Website beantragen. Die Auswirkungen der Löschung auf verschiedene '
            'Datenkategorien sind in der Datenschutzerklärung beschrieben. '
            'Social Vote kann ein Konto bei schweren oder wiederholten '
            'Verstößen, Sicherheitsrisiken, rechtlichen Verpflichtungen oder '
            'wenn der Dienst nicht weiter bereitgestellt werden kann, '
            'einschränken oder schließen.',
      ),
      _LegalSection(
        title: '9. Geistiges Eigentum und Inhalte Dritter',
        body: 'Software, Name, Grafik und originäre Elemente von Social Vote '
            'sind nach den anwendbaren Vorschriften geschützt. Marken, '
            'Nachrichten und sonstige Inhalte Dritter gehören ihren jeweiligen '
            'Rechteinhabern. Diese Bedingungen übertragen keine Rechte, die '
            'über das für die normale Nutzung des Dienstes erforderliche Maß '
            'hinausgehen.',
      ),
      _LegalSection(
        title: '10. Verfügbarkeit und Haftung',
        body: 'Social Vote trifft angemessene Maßnahmen für Sicherheit und '
            'Kontinuität, garantiert jedoch nicht, dass der Dienst jederzeit '
            'verfügbar oder fehlerfrei ist oder dass von Nutzenden oder '
            'externen Quellen veröffentlichte Inhalte vollständig oder '
            'zutreffend sind. Diese Bedingungen beschränken keine '
            'Verbraucherrechte oder Haftung, die nach dem anwendbaren Recht '
            'nicht ausgeschlossen werden können.',
      ),
      _LegalSection(
        title: '11. Änderungen der Nutzungsbedingungen',
        body: 'Die Nutzungsbedingungen können wegen Änderungen am Dienst, aus '
            'Sicherheitsgründen, aufgrund gesetzlicher Anforderungen oder zur '
            'Compliance aktualisiert werden. Wesentliche Änderungen werden, '
            'soweit erforderlich, über einen geeigneten Kanal mitgeteilt. '
            'Erfordert eine Änderung eine erneute Zustimmung, muss die '
            'aktualisierte Fassung akzeptiert werden, bevor die betroffenen '
            'Funktionen weiter genutzt werden.',
      ),
      _LegalSection(
        title: '12. Anwendbares Recht und Kontakt',
        body: 'Es gilt italienisches Recht, unbeschadet zwingender Rechte, die '
            'Nutzenden nach dem in ihrem Land anwendbaren Recht zustehen. '
            'Fragen zu diesen Bedingungen, zur Moderation oder zu Konten '
            'können an support@socialevote.com gesendet werden. Die '
            'Nutzungsbedingungen sind öffentlich unter '
            'socialevote.com/terms verfügbar.',
      ),
      _LegalSection(
        title: '13. Organizations, Mitgliedschaften und offizielle Identität',
        body: 'Ein persönliches Konto kann eine getrennte Organization über '
            'Mitgliedschaften und autorisierte Rollen verwalten. Wer für eine '
            'Organization handelt, erklärt, über die erforderliche Befugnis zur '
            'Vertretung oder Verwaltung zu verfügen. Als Organization '
            'veröffentlichte Angaben und Inhalte müssen richtig und dürfen nicht '
            'irreführend sein. Die Verifizierung einer Organization ist von '
            'bezahlten Diensten getrennt und kann nicht gekauft werden. Social '
            'Vote kann den Workspace-Zugang aussetzen oder überprüfen, wenn '
            'Befugnis, Sicherheit oder Verifizierungsanforderungen nicht mehr '
            'erfüllt sind.',
      ),
      _LegalSection(
        title: '14. Sessions, Access Passes und Pflichten des Organisators',
        body:
            'Sessions ermöglichen Live-Konsultation oder Beteiligung als Open '
            'Anonymous oder Controlled Anonymous. Open Anonymous verwendet '
            'bestmögliche Duplikatkontrollen und garantiert nicht eine Person – '
            'eine Stimme. Controlled Anonymous verwendet einmalige anonyme '
            'Access Passes; Social Vote speichert die zur Prüfung erforderlichen '
            'Hashes und hält die technischen Zugangsdaten von der Stimmabgabe '
            'getrennt. Der Organisator legt operativen Zweck, Fragen, '
            'Ergebnis-Sichtbarkeit und verfügbaren Aufbewahrungszeitraum fest '
            'und muss für seinen Anwendungsfall geeignete Hinweise und '
            'Rechtsgrundlagen sicherstellen. Im Pilot dürfen Sessions nicht als '
            'offizielle Wahlen, rechtsverbindliche Satzungsabstimmungen oder '
            'Ersatz für Verfahren mit zusätzlichen rechtlichen oder technischen '
            'Anforderungen verwendet werden.',
      ),
      _LegalSection(
        title: '15. Verified Result und Integrität',
        body: 'Beim Schließen einer Session kann ein Verified Result mit '
            'aggregiertem Snapshot, Report-ID und SHA-256-Integritätsprüfung '
            'erstellt werden. Soweit die Policy dies erlaubt, kann der Report '
            'über eine öffentliche URL oder einen QR-Code verifiziert werden; '
            'bei Ergebnissen nur für den Organisator ist die öffentliche '
            'Verifizierung deaktiviert. Die Integritätsprüfung dient dazu, '
            'Änderungen gegenüber dem versiegelten Snapshot zu erkennen; sie ist '
            'keine notarielle, wahlrechtliche, satzungsrechtliche oder '
            'rechtsverbindliche Zertifizierung. Technische Anonymität schließt '
            'nicht aus, dass Fragen oder Kontext des Organisators eine Antwort '
            'indirekt identifizierbar machen.',
      ),
      _LegalSection(
        title: '16. Business-Pilot und zukünftige kostenpflichtige Funktionen',
        body: 'Organizations und Sessions stehen derzeit gemäß den im Produkt '
            'angezeigten Pilotbedingungen ohne automatische Abrechnung zur '
            'Verfügung. Zukünftige Business-Pläne, Limits oder kostenpflichtige '
            'Funktionen werden vor einer Belastung separat mit Preisen, '
            'Bedingungen und erforderlicher Zustimmung dargestellt. Eine '
            'Zahlung verleiht oder garantiert keinen Verifizierungsstatus. '
            'Business-Nutzende bleiben für die Rechtmäßigkeit ihrer Fragen, '
            'Inhalte, Zwecke und Nutzung des Dienstes verantwortlich.',
      ),
    ],
  );

  static const _LegalDocument _privacyGerman = _LegalDocument(
    notice: 'Datenschutzerklärung aktualisiert am 23. August 2026. Offizielle '
        'Website: socialevote.com. Social Vote richtet sich ausschließlich an '
        'Personen ab 18 Jahren.',
    sections: [
      _LegalSection(
        title: '1. Verantwortlicher und Kontakt',
        body: 'Verantwortlicher für Social Vote ist Reza Hematian. Anfragen '
            'zum Datenschutz und zur Ausübung von Betroffenenrechten können an '
            'support@socialevote.com gesendet werden. Die offizielle Website '
            'ist socialevote.com.',
      ),
      _LegalSection(
        title: '2. Verarbeitete Daten',
        body:
            'Social Vote kann Konto- und Authentifizierungsdaten verarbeiten, '
            'einschließlich E-Mail-Adresse, Benutzerkennung und Sitzungsdaten; '
            'Profildaten wie öffentlicher Name, ein vom System erzeugter '
            'anfänglicher Benutzername, Wohnsitzland und -stadt, Biografie, '
            'Avatar, öffentliche Identität und Verifizierungsstatus; Daten aus '
            'Verifizierungsanfragen; Umfragen, Stimmen, Beiträge, Kommentare, '
            'Reaktionen, Favoriten, Meldungen und Benachrichtigungen; vom '
            'Nutzer gewählte Standortdaten; App-Einstellungen sowie technische '
            'Daten, die für Sicherheit, Betrieb und Diagnose erforderlich sind.',
      ),
      _LegalSection(
        title: '3. Zwecke und Rechtsgrundlagen',
        body: 'Daten werden verarbeitet, um Konten zu erstellen und zu '
            'verwalten, Umfragen und soziale Funktionen bereitzustellen, '
            'Teilnahmeregeln anzuwenden, Profile und Verifizierung zu verwalten, '
            'für den gewählten geografischen Bereich relevante Inhalte '
            'anzuzeigen, Transaktionsnachrichten zu versenden, Missbrauch zu '
            'verhindern, Inhalte und Konten zu moderieren, den Dienst zu '
            'schützen und rechtliche Verpflichtungen zu erfüllen. Je nach '
            'Verarbeitung können die Rechtsgrundlagen die Erfüllung des vom '
            'Nutzer angeforderten Dienstes, berechtigte Interessen an '
            'Sicherheit und Missbrauchsprävention, rechtliche Verpflichtungen '
            'und, soweit erforderlich, eine Einwilligung umfassen.',
      ),
      _LegalSection(
        title: '4. Öffentliche Daten und besondere Kategorien',
        body:
            'Öffentlicher Name, Benutzername, Avatar, Verifizierungsabzeichen '
            'und veröffentlichte Inhalte können für andere Nutzende und bei '
            'öffentlichen Inhalten auch im Web sichtbar sein. Umfragen, Stimmen '
            'oder Inhalte können politische Meinungen, Überzeugungen oder '
            'andere besondere Kategorien personenbezogener Daten im Sinne des '
            'Datenschutzrechts erkennen lassen. Social Vote nutzt solche Daten '
            'nicht für personalisierte Werbung oder zur kommerziellen '
            'Ableitung politischer Profile. Soweit eine Verarbeitung eine '
            'besondere Voraussetzung nach Artikel 9 DSGVO erfordert, muss '
            'diese Voraussetzung vor der Verarbeitung vorliegen.',
      ),
      _LegalSection(
        title: '5. Standort, Wohnsitz und GeoScope',
        body: 'Land und Stadt des Wohnsitzes im Profil sind vom geografischen '
            'Navigationsbereich und vom Standort eines Inhalts getrennt. Die '
            'Wohnsitzstadt ist optional. Bei Eingabe einer Stadt kann Social '
            'Vote diese über OpenStreetMap Nominatim überprüfen. Wenn die '
            'nutzende Person Geräte-Standortfunktionen verwendet, können die '
            'für diese Funktion erforderlichen Koordinaten und Ortsangaben '
            'verarbeitet werden. Standortberechtigungen können in den '
            'Geräteeinstellungen verweigert oder widerrufen werden.',
      ),
      _LegalSection(
        title: '6. Lokaler Speicher, Sitzungen und Firebase',
        body: 'Die App kann Einstellungen wie Sprache, Design, '
            'Nachrichteneinstellungen und die Auswahl „Angemeldet bleiben“ '
            'lokal speichern. Wenn „Angemeldet bleiben“ aktiviert ist, kann '
            'eine technische Supabase-Authentifizierungssitzung lokal '
            'gespeichert werden; beim Abmelden wird sie entfernt. Firebase '
            'Analytics ist mit deaktivierter Datenerfassung konfiguriert. '
            'Firebase-Komponenten können automatisch eine Firebase '
            'Installation ID (FID) erzeugen, eine technische Kennung, die pro '
            'Installation unterschiedlich ist und weder eine Person noch ein '
            'physisches Gerät unmittelbar identifiziert. Social Vote verwendet '
            'die Advertising ID nicht für personalisierte Werbung.',
      ),
      _LegalSection(
        title: '7. Anbieter und Empfänger',
        body: 'Supabase stellt Authentifizierung, Datenbank, Speicher und '
            'Backend-Funktionen bereit. Google Firebase stellt auf den '
            'konfigurierten Laufzeitumgebungen technische Komponenten und '
            'Webhosting bereit. Brevo kann für Transaktions-E-Mails über den '
            'konfigurierten SMTP-Dienst verwendet werden. OpenStreetMap '
            'Nominatim kann Standortdaten erhalten, die für Geokodierung '
            'erforderlich sind. Nachrichtenquellen und -anbieter können '
            'Anfragen verarbeiten, die zur Bereitstellung der Nachrichten '
            'erforderlich sind. Daten können außerdem an Behörden oder andere '
            'Empfänger offengelegt werden, wenn dies gesetzlich vorgeschrieben '
            'oder zum Schutz von Rechten und Sicherheit erforderlich ist.',
      ),
      _LegalSection(
        title: '8. Internationale Übermittlungen',
        body: 'Einige Anbieter können Daten außerhalb des Europäischen '
            'Wirtschaftsraums verarbeiten. Soweit die DSGVO Schutzmaßnahmen '
            'verlangt, müssen Übermittlungen auf einem '
            'Angemessenheitsbeschluss, Standardvertragsklauseln oder einem '
            'anderen gültigen Mechanismus nach dem anwendbaren Recht beruhen.',
      ),
      _LegalSection(
        title: '9. Moderation, Sicherheit und Audit',
        body: 'Meldungen, Verifizierungsanfragen und Inhalte können von '
            'autorisierten Moderatoren oder Administratoren geprüft werden. '
            'Bei Verstößen, Missbrauch oder Sicherheitsrisiken können Inhalte '
            'ausgeblendet oder wiederhergestellt und Konten gesperrt, '
            'reaktiviert, abgemeldet oder gelöscht werden. Bestimmte '
            'administrative und sicherheitsbezogene Maßnahmen erzeugen '
            'minimierte Audit-Datensätze, soweit diese für Rechenschaft, '
            'Sicherheit und die Verteidigung von Rechten erforderlich sind.',
      ),
      _LegalSection(
        title: '10. Aufbewahrung und Kontolöschung',
        body:
            'Daten werden so lange gespeichert, wie dies für die beschriebenen '
            'Zwecke und anwendbaren Verpflichtungen erforderlich ist. Bei '
            'Löschung eines Kontos wird das Auth-Konto gelöscht; eigene '
            'Beiträge, Umfragen und Kommentare werden gelöscht; Profil, Avatar, '
            'Favoriten, Benachrichtigungen, Sitzungen und andere vom '
            'Löschverfahren erfasste personenbezogene Daten werden entfernt. '
            'Stimmen und Reaktionen auf Inhalte anderer Personen können in '
            'anonymisierter Form erhalten bleiben, um historische Ergebnisse '
            'und Statistiken zu bewahren. Eine anonymisierte technische '
            'Referenz kann bestehen bleiben, soweit dies für die referenzielle '
            'Integrität erforderlich ist. Administrative oder '
            'Sicherheitsaufzeichnungen können in minimierter Form gespeichert '
            'bleiben, soweit dies für Sicherheit, Rechenschaft oder rechtliche '
            'Pflichten erforderlich ist.',
      ),
      _LegalSection(
        title: '11. Rechte der betroffenen Person',
        body: 'Soweit gesetzlich vorgesehen, können Nutzende Auskunft, '
            'Berichtigung, Löschung, Einschränkung, Widerspruch und '
            'Datenübertragbarkeit verlangen sowie eine Einwilligung widerrufen, '
            'wenn die Verarbeitung auf Einwilligung beruht. Anfragen können an '
            'support@socialevote.com gesendet werden. Eine angemessene '
            'Identitätsprüfung kann verlangt werden. Nutzende können außerdem '
            'Beschwerde bei der italienischen Datenschutzaufsichtsbehörde oder '
            'einer anderen zuständigen Aufsichtsbehörde einlegen.',
      ),
      _LegalSection(
        title: '12. Mindestalter, Datenverkauf und Werbung',
        body: 'Social Vote richtet sich ausschließlich an Personen ab 18 '
            'Jahren. Social Vote verkauft keine personenbezogenen Daten der '
            'Nutzenden und verwendet die in dieser Erklärung beschriebenen '
            'Daten nicht für personalisierte Werbung. Künftige Werbefunktionen '
            'oder neue Verarbeitungen erfordern eine Aktualisierung dieser '
            'Erklärung und, soweit erforderlich, der den Nutzenden '
            'bereitgestellten Auswahlmöglichkeiten.',
      ),
      _LegalSection(
        title: '13. Änderungen und Stand',
        body: 'Diese Datenschutzerklärung hat den Stand 23. August 2026. '
            'Wesentliche Änderungen werden, soweit erforderlich, über die App '
            'oder einen anderen geeigneten Kanal mitgeteilt. Die öffentliche '
            'Fassung ist unter socialevote.com/privacy verfügbar.',
      ),
      _LegalSection(
        title: '14. Organizations, Mitgliedschaften und Workspace-Daten',
        body: 'Zur Erstellung, Verifizierung und Verwaltung einer Organization '
            'kann Social Vote rechtlichen und öffentlichen Namen, '
            'Organisationstyp, Land und Stadt, Website, Beschreibung, Logo und '
            'Titelbild, Verifizierungsstatus, mit einem Antrag übermittelte '
            'Daten und Nachweise, Rolle der vertretenden Person sowie '
            'Mitgliedschaftsdaten wie Mitgliedskonto, Rolle und Status '
            'verarbeiten. Für das öffentliche Organization-Profil bestimmte '
            'Daten können im Web sichtbar sein; interne Mitgliedschafts-, '
            'Audit- und Verifizierungsdaten sind gemäß den jeweiligen '
            'Funktionen und Policies auf autorisierte Zugriffe beschränkt.',
      ),
      _LegalSection(
        title: '15. Sessions und Teilnehmerdaten',
        body: 'Eine Session kann Titel, Konfiguration, Fragen und Optionen, '
            'Status, Zugangsmodus, Ergebnis-Sichtbarkeit, erwartete '
            'Teilnehmerzahl, Zähler und Aufbewahrungszeitraum umfassen. Bei '
            'Controlled Anonymous werden Access Passes im Klartext dem '
            'Organisator nur bei ihrer Erzeugung angezeigt; das Backend '
            'speichert den für die Validierung erforderlichen Hash. Ein '
            'Teilnehmer erhält technische Session-Zugangsdaten, die lokal im '
            'Browser gespeichert werden können, um gewöhnliche Duplikate zu '
            'verhindern und den Status zu erhalten. Die Stimmabgabe ist '
            'getrennt und enthält keine Felder, die Identität, Access Pass oder '
            'Teilnehmerzugang mit der Auswahl verknüpfen. Bei Open Anonymous '
            'sind Duplikat- und Missbrauchskontrollen bestmöglich und keine '
            'Garantie für eine Person – eine Stimme.',
      ),
      _LegalSection(
        title: '16. Aufbewahrung von Sessions und Verified Result',
        body:
            'Für rohe Session-Stimmabgaben wählt der Organisator einen der im '
            'Produkt verfügbaren Aufbewahrungszeiträume: 24 Stunden, 7 Tage '
            'oder 30 Tage. Technische Daten, die für Sicherheit, '
            'Missbrauchsschutz oder Integrität unbedingt erforderlich sind, '
            'können, soweit erforderlich und zulässig, anderen Zeiträumen '
            'unterliegen. Beim Schließen kann ein Verified Result als '
            'unveränderlicher aggregierter Snapshot mit Report-ID, '
            'Version/Schema und SHA-256-Hash aufbewahrt werden. Bei Sichtbarkeit '
            'nur für den Organisator ist der Report nicht öffentlich '
            'verifizierbar; in anderen unterstützten Fällen kann er über '
            'Verifizierungs-URL oder QR-Code erreichbar sein.',
      ),
      _LegalSection(
        title: '17. Datenschutzrollen bei Organization-Sessions',
        body: 'Wenn eine Organization Sessions für eigene Zwecke verwendet, '
            'hängen die Datenschutzrollen vom konkreten Kontext, den Zwecken '
            'und den anwendbaren Vereinbarungen ab. Der Organisator legt '
            'normalerweise den operativen Zweck und die Fragen der Session '
            'fest; Social Vote verarbeitet die zur Bereitstellung, Absicherung '
            'und Dokumentation des Dienstes erforderlichen Daten. Soweit Social '
            'Vote personenbezogene Daten im Auftrag eines Verantwortlichen '
            'verarbeitet, kann nach anwendbarem Recht eine Vereinbarung zur '
            'Auftragsverarbeitung erforderlich sein. Diese '
            'Datenschutzerklärung weist nicht automatisch jeder möglichen '
            'Session dieselbe rechtliche Rolle zu.',
      ),
      _LegalSection(
        title: '18. Business-Pilot und besondere Kategorien von Daten',
        body: 'Im Business-Pilot empfiehlt Social Vote, Sessions nicht ohne '
            'spezifische Bewertung zur Erhebung besonderer Kategorien '
            'personenbezogener Daten, von Daten Minderjähriger, zur '
            'Mitarbeiterüberwachung oder für andere risikoreiche Informationen '
            'zu verwenden. Organisatoren sollten unnötige Fragen vermeiden und '
            'die anwendbare Rechtsgrundlage und Voraussetzungen prüfen, wenn '
            'Antworten besondere Kategorien von Daten offenbaren können. '
            'Social Vote verwendet Session-Entscheidungen nicht für '
            'personalisierte Werbung.',
      ),
    ],
  );
}
