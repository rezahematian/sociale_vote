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
    notice: 'Versione aggiornata al 16 agosto 2026. Sito ufficiale: '
        'socialevote.com. Social Vote è destinato esclusivamente a persone '
        'di almeno 18 anni.',
    sections: [
      _LegalSection(
        title: '1. Gestore, contatti e accettazione',
        body: 'Social Vote è gestito da Reza Hematian. Il sito ufficiale è '
            'socialevote.com e il contatto per account, supporto e questioni '
            'relative ai presenti Termini è socialvote@hotmail.com. Creando '
            'un account, l’utente conferma di avere almeno 18 anni, accetta '
            'questi Termini e conferma di aver letto l’Informativa sulla '
            'privacy. Chi non accetta i Termini non deve creare o usare un '
            'account.',
      ),
      _LegalSection(
        title: '2. Il servizio',
        body: 'Social Vote è una piattaforma civica e sociale che consente di '
            'consultare contenuti pubblici, partecipare a sondaggi, pubblicare '
            'post e commenti, usare reazioni e preferiti, consultare News e '
            'utilizzare funzioni geografiche e Civic Map. Alcune funzioni '
            'richiedono autenticazione o un livello di verifica specifico. '
            'Il servizio può essere modificato, sospeso o aggiornato per '
            'sicurezza, conformità, manutenzione o miglioramento del prodotto.',
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
            'scrivere a socialvote@hotmail.com indicando le informazioni '
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
            'account è possibile scrivere a socialvote@hotmail.com. I Termini '
            'sono disponibili pubblicamente su socialevote.com/terms.',
      ),
    ],
  );

  static const _LegalDocument _termsEnglish = _LegalDocument(
    notice: 'Version updated on 16 August 2026. Official website: '
        'socialevote.com. Social Vote is intended only for people aged 18 or '
        'older.',
    sections: [
      _LegalSection(
        title: '1. Operator, contact and acceptance',
        body: 'Social Vote is operated by Reza Hematian. The official website '
            'is socialevote.com and the contact address for accounts, support '
            'and these Terms is socialvote@hotmail.com. By creating an '
            'account, users confirm that they are at least 18 years old, '
            'accept these Terms and confirm that they have read the Privacy '
            'Policy. Anyone who does not accept the Terms must not create or '
            'use an account.',
      ),
      _LegalSection(
        title: '2. The service',
        body: 'Social Vote is a civic and social platform that allows people '
            'to read public content, participate in polls, publish posts and '
            'comments, use reactions and favourites, read News and use '
            'geographic features and Civic Map. Some features require '
            'authentication or a specific verification level. The service '
            'may be changed, suspended or updated for security, compliance, '
            'maintenance or product improvement.',
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
            'emailing socialvote@hotmail.com with enough information to '
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
            'to socialvote@hotmail.com. The Terms are publicly available at '
            'socialevote.com/terms.',
      ),
    ],
  );

  static const _LegalDocument _privacyItalian = _LegalDocument(
    notice: 'Informativa aggiornata al 16 agosto 2026. Sito ufficiale: '
        'socialevote.com. Social Vote è destinato esclusivamente a persone '
        'di almeno 18 anni.',
    sections: [
      _LegalSection(
        title: '1. Titolare e contatti',
        body: 'Il titolare del trattamento di Social Vote è Reza Hematian. '
            'Per richieste privacy e per esercitare i diritti previsti dalla '
            'normativa è possibile scrivere a socialvote@hotmail.com. Il sito '
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
            'socialvote@hotmail.com. Può essere richiesta una verifica '
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
        body: 'Questa informativa è aggiornata al 16 agosto 2026. Le modifiche '
            'sostanziali saranno comunicate tramite l’app o un altro canale '
            'appropriato quando richiesto. La versione pubblica è disponibile '
            'su socialevote.com/privacy.',
      ),
    ],
  );

  static const _LegalDocument _privacyEnglish = _LegalDocument(
    notice: 'Privacy Policy updated on 16 August 2026. Official website: '
        'socialevote.com. Social Vote is intended only for people aged 18 or '
        'older.',
    sections: [
      _LegalSection(
        title: '1. Controller and contact details',
        body: 'The controller for Social Vote is Reza Hematian. Privacy '
            'requests and data-subject rights may be sent to '
            'socialvote@hotmail.com. The official website is socialevote.com.',
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
            'may be sent to socialvote@hotmail.com. Reasonable identity '
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
        body: 'This Privacy Policy is updated as of 16 August 2026. Material '
            'changes will be communicated through the app or another '
            'appropriate channel where required. The public version is '
            'available at socialevote.com/privacy.',
      ),
    ],
  );
}
