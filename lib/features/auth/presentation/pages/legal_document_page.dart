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
    notice: 'BOZZA OPERATIVA. Questo testo serve per il test del flusso di '
        'registrazione. Prima della pubblicazione devono essere inseriti i '
        'dati legali del gestore, i contatti ufficiali, la giurisdizione '
        'applicabile e una revisione professionale.',
    sections: [
      _LegalSection(
        title: '1. Servizio',
        body: 'Sociale_Vote è una piattaforma civica e sociale che permette '
            'agli utenti di creare e partecipare a sondaggi, pubblicare '
            'contenuti, commentare, reagire, seguire aree geografiche e '
            'consultare notizie.',
      ),
      _LegalSection(
        title: '2. Account',
        body: 'L’utente deve fornire informazioni corrette, proteggere le '
            'proprie credenziali e usare un solo account personale salvo '
            'autorizzazione esplicita. L’utente è responsabile delle attività '
            'svolte tramite il proprio account.',
      ),
      _LegalSection(
        title: '3. Contenuti e comportamento',
        body: 'Non sono ammessi contenuti illegali, ingannevoli, minacciosi, '
            'discriminatori o abusivi, spam, impersonificazione, '
            'manipolazione dei voti o violazioni dei diritti di terzi. I '
            'contenuti possono essere segnalati, limitati o rimossi secondo '
            'le regole di moderazione.',
      ),
      _LegalSection(
        title: '4. Sondaggi e informazioni civiche',
        body: 'I sondaggi presenti nell’app non costituiscono elezioni '
            'ufficiali, referendum legalmente vincolanti o consulenza '
            'professionale, salvo indicazione espressa e verificabile. '
            'L’utente deve valutare autonomamente attendibilità e contesto '
            'dei contenuti.',
      ),
      _LegalSection(
        title: '5. Contenuti dell’utente',
        body: 'L’utente conserva i diritti sui propri contenuti e concede al '
            'servizio la licenza tecnica necessaria per conservarli, '
            'mostrarli, distribuirli nell’app e moderarli per il '
            'funzionamento della piattaforma.',
      ),
      _LegalSection(
        title: '6. Disponibilità e modifiche',
        body: 'Il servizio può cambiare, essere sospeso o subire interruzioni. '
            'Non è garantita una disponibilità continua o priva di errori. '
            'Le funzioni possono essere aggiornate per sicurezza, conformità '
            'o miglioramento del prodotto.',
      ),
      _LegalSection(
        title: '7. Sospensione e chiusura',
        body: 'Gli account possono essere limitati o sospesi in caso di '
            'violazioni, rischi di sicurezza, abuso o obblighi di legge. '
            'Prima della release sarà disponibile una procedura chiara per '
            'richiedere la cancellazione dell’account.',
      ),
      _LegalSection(
        title: '8. Versione definitiva',
        body: 'La versione legale definitiva, la data di entrata in vigore, '
            'i dati del gestore e i contatti ufficiali devono essere '
            'inseriti prima della release pubblica.',
      ),
    ],
  );

  static const _LegalDocument _termsEnglish = _LegalDocument(
    notice: 'OPERATIONAL DRAFT. This text is provided to test the registration '
        'flow. Before release it must include the operator’s legal details, '
        'official contacts, applicable jurisdiction and professional review.',
    sections: [
      _LegalSection(
        title: '1. Service',
        body: 'Sociale_Vote is a civic and social platform that lets users '
            'create and participate in polls, publish content, comment, '
            'react, follow geographic areas and read news.',
      ),
      _LegalSection(
        title: '2. Account',
        body: 'Users must provide accurate information, protect their '
            'credentials and use one personal account unless explicitly '
            'authorised. Users are responsible for activity performed '
            'through their account.',
      ),
      _LegalSection(
        title: '3. Content and conduct',
        body: 'Illegal, deceptive, threatening, discriminatory or abusive '
            'content, spam, impersonation, vote manipulation and '
            'infringement of third-party rights are prohibited. Content may '
            'be reported, restricted or removed under the moderation rules.',
      ),
      _LegalSection(
        title: '4. Polls and civic information',
        body: 'Polls in the app are not official elections, legally binding '
            'referendums or professional advice unless explicitly and '
            'verifiably stated. Users must independently assess the '
            'reliability and context of content.',
      ),
      _LegalSection(
        title: '5. User content',
        body: 'Users retain ownership of their content and grant the service '
            'the technical licence needed to store, display, distribute '
            'within the app and moderate that content for operation of the '
            'platform.',
      ),
      _LegalSection(
        title: '6. Availability and changes',
        body: 'The service may change, be suspended or experience '
            'interruptions. Continuous or error-free availability is not '
            'guaranteed. Features may be updated for security, compliance or '
            'product improvement.',
      ),
      _LegalSection(
        title: '7. Suspension and closure',
        body: 'Accounts may be restricted or suspended for violations, '
            'security risks, abuse or legal obligations. A clear account '
            'deletion request procedure will be available before release.',
      ),
      _LegalSection(
        title: '8. Final version',
        body: 'The final legal version, effective date, operator details and '
            'official contacts must be inserted before public release.',
      ),
    ],
  );

  static const _LegalDocument _privacyItalian = _LegalDocument(
    notice: 'BOZZA OPERATIVA. Questo testo serve per il test del flusso di '
        'registrazione. Prima della pubblicazione devono essere aggiunti '
        'identità e contatti del titolare, contatto privacy, tempi precisi di '
        'conservazione, trasferimenti internazionali e percorso esterno di '
        'cancellazione account.',
    sections: [
      _LegalSection(
        title: '1. Dati trattati',
        body: 'Sociale_Vote può trattare dati account come email, nome '
            'visualizzato e username; dati profilo come paese e città di '
            'residenza, avatar, biografia e stato di verifica; contenuti e '
            'interazioni come sondaggi, voti, post, commenti, reazioni, '
            'preferiti, segnalazioni e notifiche; dati geografici scelti '
            'dall’utente; dati tecnici, di sicurezza, errore, prestazione e '
            'analytics essenziali.',
      ),
      _LegalSection(
        title: '2. Finalità',
        body: 'I dati sono utilizzati per creare e proteggere l’account, '
            'fornire le funzioni civiche e sociali, mostrare contenuti '
            'pertinenti allo scope, prevenire abusi, moderare la piattaforma, '
            'inviare notifiche e migliorare stabilità e prestazioni.',
      ),
      _LegalSection(
        title: '3. Fornitori tecnici',
        body: 'L’app utilizza servizi tecnici come Supabase per '
            'autenticazione, database e backend e Firebase per alcune '
            'funzioni tecniche e analytics sui runtime supportati. Le '
            'notizie possono provenire da provider esterni.',
      ),
      _LegalSection(
        title: '4. Visibilità',
        body: 'Nome visualizzato, username, indicatori di verifica e contenuti '
            'pubblicati possono essere visibili agli altri utenti. La '
            'visibilità dei voti dipende dalle regole del singolo sondaggio.',
      ),
      _LegalSection(
        title: '5. Conservazione e sicurezza',
        body: 'I dati sono conservati per il tempo necessario a fornire il '
            'servizio, proteggere la piattaforma e rispettare gli obblighi '
            'applicabili. Sono adottate misure tecniche ragionevoli, ma '
            'nessun sistema può garantire sicurezza assoluta.',
      ),
      _LegalSection(
        title: '6. Diritti e cancellazione',
        body: 'L’utente può richiedere accesso, correzione, cancellazione, '
            'limitazione, opposizione e portabilità quando applicabili. '
            'Prima della release deve essere disponibile una procedura '
            'chiara di cancellazione account sia nell’app sia tramite una '
            'risorsa web ufficiale.',
      ),
      _LegalSection(
        title: '7. Posizione e permessi',
        body: 'La posizione precisa viene richiesta solo quando l’utente '
            'sceglie funzioni che la richiedono. Il permesso può essere '
            'negato o revocato dalle impostazioni del dispositivo.',
      ),
      _LegalSection(
        title: '8. Minori',
        body: 'La soglia di età, le misure per i minori e gli eventuali '
            'consensi parentali devono essere definiti prima della '
            'pubblicazione nei Paesi interessati.',
      ),
      _LegalSection(
        title: '9. Versione definitiva',
        body: 'La versione finale deve indicare titolare, contatti, basi '
            'giuridiche, destinatari, tempi di conservazione, trasferimenti, '
            'autorità di controllo e data di efficacia.',
      ),
    ],
  );

  static const _LegalDocument _privacyEnglish = _LegalDocument(
    notice: 'OPERATIONAL DRAFT. This text is provided to test the registration '
        'flow. Before release it must include the controller’s identity and '
        'contact details, a privacy contact, precise retention periods, '
        'international transfers and the external account-deletion route.',
    sections: [
      _LegalSection(
        title: '1. Data processed',
        body: 'Sociale_Vote may process account data such as email, display '
            'name and username; profile data such as country and city of '
            'residence, avatar, biography and verification status; content '
            'and interactions such as polls, votes, posts, comments, '
            'reactions, favourites, reports and notifications; geographic '
            'data selected by the user; and technical, security, error, '
            'performance and essential analytics data.',
      ),
      _LegalSection(
        title: '2. Purposes',
        body: 'Data is used to create and protect accounts, provide civic and '
            'social features, show content relevant to the selected scope, '
            'prevent abuse, moderate the platform, send notifications and '
            'improve stability and performance.',
      ),
      _LegalSection(
        title: '3. Technical providers',
        body: 'The app uses technical services such as Supabase for '
            'authentication, database and backend functions and Firebase for '
            'certain technical and analytics functions on supported '
            'runtimes. News may come from external providers.',
      ),
      _LegalSection(
        title: '4. Visibility',
        body: 'Display name, username, verification indicators and published '
            'content may be visible to other users. Vote visibility depends '
            'on the rules of each poll.',
      ),
      _LegalSection(
        title: '5. Retention and security',
        body: 'Data is retained for as long as necessary to provide the '
            'service, protect the platform and meet applicable obligations. '
            'Reasonable technical safeguards are used, but no system can '
            'guarantee absolute security.',
      ),
      _LegalSection(
        title: '6. Rights and deletion',
        body: 'Users may request access, correction, deletion, restriction, '
            'objection and portability where applicable. Before release, a '
            'clear account-deletion procedure must be available both in the '
            'app and through an official web resource.',
      ),
      _LegalSection(
        title: '7. Location and permissions',
        body: 'Precise location is requested only when the user chooses a '
            'feature that requires it. Permission can be denied or revoked '
            'in device settings.',
      ),
      _LegalSection(
        title: '8. Children',
        body: 'The age threshold, safeguards for children and any parental '
            'consent requirements must be defined before release for the '
            'relevant countries.',
      ),
      _LegalSection(
        title: '9. Final version',
        body: 'The final version must identify the controller, contacts, legal '
            'bases, recipients, retention periods, transfers, supervisory '
            'authority and effective date.',
      ),
    ],
  );
}
