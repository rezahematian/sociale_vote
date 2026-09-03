import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/app/localization/de_fallback.dart';

class HowSocialVoteWorksPage extends StatelessWidget {
  const HowSocialVoteWorksPage({super.key});

  String _text(
    BuildContext context, {
    required String it,
    required String en,
    required String de,
  }) {
    final language = Localizations.localeOf(context).languageCode.toLowerCase();
    if (language == 'it') return it;
    return deOrEnglish(context, english: en, german: de);
  }

  void _goHome(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    navigator.pushNamedAndRemoveUntil(AppRouter.home, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final loggedIn = AppDI.instance.currentUserId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _text(
            context,
            it: 'Come funziona Social Vote',
            en: 'How Social Vote works',
            de: 'So funktioniert Social Vote',
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 36),
            children: [
              _GuideHero(
                title: _text(
                  context,
                  it: 'Partecipazione per le persone. Strumenti professionali per le organizzazioni.',
                  en: 'Participation for people. Professional tools for organizations.',
                  de: 'Teilhabe für Menschen. Professionelle Werkzeuge für Organisationen.',
                ),
                body: _text(
                  context,
                  it: 'Social Vote è una piattaforma di partecipazione: scopri cosa succede, esprimi la tua Voce e partecipa ai Vote. Le organizzazioni possono usare un Workspace dedicato per comunicare, consultare e gestire Sessions.',
                  en: 'Social Vote is a participation platform: discover what is happening, share your Voce and take part in Vote. Organizations can use a dedicated Workspace to communicate, consult and run Sessions.',
                  de: 'Social Vote ist eine Plattform für Teilhabe: Entdecke, was passiert, teile deine Voce und nimm an Vote teil. Organisationen können einen eigenen Workspace für Kommunikation, Konsultationen und Sessions nutzen.',
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 760;
                  final people = _AudienceCard(
                    icon: Icons.person_outline_rounded,
                    title: _text(
                      context,
                      it: 'Per te',
                      en: 'For you',
                      de: 'Für dich',
                    ),
                    badge: _text(
                      context,
                      it: 'GRATUITO',
                      en: 'FREE',
                      de: 'KOSTENLOS',
                    ),
                    body: _text(
                      context,
                      it: 'L’uso personale resta gratuito. Nessuna pubblicità e nessun vantaggio di visibilità acquistabile.',
                      en: 'Personal use stays free. No advertising and no visibility advantage that can be bought.',
                      de: 'Die persönliche Nutzung bleibt kostenlos. Keine Werbung und kein käuflicher Sichtbarkeitsvorteil.',
                    ),
                    items: [
                      _text(context,
                          it: 'Pulse: contenuti rilevanti per te',
                          en: 'Pulse: content relevant to you',
                          de: 'Pulse: für dich relevante Inhalte'),
                      _text(context,
                          it: 'Pulse Now: ciò che si muove adesso',
                          en: 'Pulse Now: what is moving now',
                          de: 'Pulse Now: was gerade Aufmerksamkeit erhält'),
                      _text(context,
                          it: 'Civic Map: esplora attraverso i luoghi',
                          en: 'Civic Map: explore through places',
                          de: 'Civic Map: über Orte entdecken'),
                      _text(context,
                          it: 'Voce: pubblica un pensiero, una proposta o un aggiornamento',
                          en: 'Voce: publish a thought, proposal or update',
                          de: 'Voce: Gedanken, Vorschläge oder Updates veröffentlichen'),
                      _text(context,
                          it: 'Vote: crea o partecipa a una consultazione',
                          en: 'Vote: create or join a consultation',
                          de: 'Vote: Konsultationen erstellen oder daran teilnehmen'),
                      _text(context,
                          it: 'Segui persone, luoghi e organizzazioni',
                          en: 'Follow people, places and organizations',
                          de: 'Menschen, Orte und Organisationen folgen'),
                    ],
                  );
                  final business = _AudienceCard(
                    icon: Icons.apartment_rounded,
                    title: _text(
                      context,
                      it: 'Per organizzazioni',
                      en: 'For organizations',
                      de: 'Für Organisationen',
                    ),
                    badge: 'BUSINESS',
                    body: _text(
                      context,
                      it: 'Il tuo account personale resta l’accesso. Se gestisci un’organizzazione, il tuo ruolo ti permette di amministrare la sua identità pubblica separata.',
                      en: 'Your personal account remains your login. If you manage an organization, your role lets you administer its separate public identity.',
                      de: 'Dein persönliches Konto bleibt deine Anmeldung. Wenn du eine Organisation verwaltest, kannst du über deine Rolle ihre getrennte öffentliche Identität administrieren.',
                    ),
                    items: [
                      _text(context,
                          it: 'Voce ufficiale come organizzazione',
                          en: 'Official Voce as the organization',
                          de: 'Offizielle Voce als Organisation'),
                      _text(context,
                          it: 'Vote ufficiale per consultazioni pubbliche',
                          en: 'Official Vote for public consultations',
                          de: 'Offizielle Vote für öffentliche Konsultationen'),
                      _text(context,
                          it: 'Sessions con QR e partecipazione live',
                          en: 'Sessions with QR and live participation',
                          de: 'Sessions mit QR und Live-Teilnahme'),
                      _text(context,
                          it: 'Stage e risultati durante la Session',
                          en: 'Stage and results during the Session',
                          de: 'Stage und Ergebnisse während der Session'),
                      _text(context,
                          it: 'Verified Result con controllo di integrità',
                          en: 'Verified Result with integrity checking',
                          de: 'Verified Result mit Integritätsprüfung'),
                      _text(context,
                          it: 'Workspace unico per gestire il flusso Business',
                          en: 'One Workspace for the Business workflow',
                          de: 'Ein Workspace für den Business-Ablauf'),
                    ],
                  );

                  if (!wide) {
                    return Column(
                      children: [people, const SizedBox(height: 12), business],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: people),
                      const SizedBox(width: 12),
                      Expanded(child: business),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              _GuideSectionTitle(
                icon: Icons.tune_rounded,
                title: _text(
                  context,
                  it: 'Scegli lo strumento giusto',
                  en: 'Choose the right tool',
                  de: 'Wähle das passende Werkzeug',
                ),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 840 ? 3 : 1;
                  const spacing = 10.0;
                  final width = columns == 1
                      ? constraints.maxWidth
                      : (constraints.maxWidth - spacing * 2) / 3;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      SizedBox(
                        width: width,
                        child: _ToolCard(
                          icon: Icons.forum_outlined,
                          title: 'Voce',
                          body: _text(
                            context,
                            it: 'Per comunicare, proporre, raccontare o aprire una discussione. Può essere personale oppure ufficiale di un’organizzazione.',
                            en: 'For communicating, proposing, sharing or opening a discussion. It can be personal or official from an organization.',
                            de: 'Zum Kommunizieren, Vorschlagen, Berichten oder Eröffnen einer Diskussion. Persönlich oder offiziell von einer Organisation.',
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _ToolCard(
                          icon: Icons.how_to_vote_outlined,
                          title: 'Vote',
                          body: _text(
                            context,
                            it: 'Per porre una domanda e raccogliere scelte nel tempo. Le regole di partecipazione e visibilità dipendono dal Vote.',
                            en: 'For asking a question and collecting choices over time. Participation and visibility rules depend on the Vote.',
                            de: 'Um eine Frage zu stellen und Entscheidungen über einen Zeitraum zu sammeln. Teilnahme- und Sichtbarkeitsregeln hängen vom Vote ab.',
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _ToolCard(
                          icon: Icons.groups_2_outlined,
                          title: 'Session',
                          body: _text(
                            context,
                            it: 'Per riunioni, assemblee o consultazioni organizzate: domanda, QR, partecipazione, risultati e Verified Result.',
                            en: 'For meetings, assemblies or organized consultations: question, QR, participation, results and Verified Result.',
                            de: 'Für Sitzungen, Versammlungen oder organisierte Konsultationen: Frage, QR, Teilnahme, Ergebnisse und Verified Result.',
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              _GuideSectionTitle(
                icon: Icons.verified_user_outlined,
                title: _text(
                  context,
                  it: 'Verifica, fiducia e privacy',
                  en: 'Verification, trust and privacy',
                  de: 'Verifizierung, Vertrauen und Datenschutz',
                ),
              ),
              const SizedBox(height: 10),
              _InfoCard(
                items: [
                  _text(
                    context,
                    it: 'La verifica serve a ridurre account duplicati, partecipazioni non autorizzate e abusi quando una funzione richiede maggiore affidabilità.',
                    en: 'Verification helps reduce duplicate accounts, unauthorized participation and abuse when a function requires greater assurance.',
                    de: 'Verifizierung hilft, doppelte Konten, unberechtigte Teilnahme und Missbrauch zu reduzieren, wenn eine Funktion mehr Sicherheit benötigt.',
                  ),
                  _text(
                    context,
                    it: 'Social Vote deve chiedere solo il livello necessario e spiegare il motivo prima della richiesta.',
                    en: 'Social Vote should request only the necessary level and explain why before asking for it.',
                    de: 'Social Vote soll nur das notwendige Niveau verlangen und vorher erklären, warum es benötigt wird.',
                  ),
                  _text(
                    context,
                    it: 'I dati di verifica non sono il modello pubblicitario di Social Vote. La partecipazione personale non viene finanziata vendendo maggiore visibilità.',
                    en: 'Verification data is not Social Vote’s advertising model. Personal participation is not funded by selling greater visibility.',
                    de: 'Verifizierungsdaten sind nicht das Werbemodell von Social Vote. Persönliche Teilhabe wird nicht durch den Verkauf zusätzlicher Sichtbarkeit finanziert.',
                  ),
                  _text(
                    context,
                    it: 'La verifica dell’account e la scelta espressa in un Vote sono concetti separati; anonimato e accesso dipendono dalle regole della specifica consultazione.',
                    en: 'Account verification and the choice made in a Vote are separate concepts; anonymity and access depend on the rules of the specific consultation.',
                    de: 'Kontoverifizierung und die in einem Vote getroffene Wahl sind getrennte Konzepte; Anonymität und Zugang hängen von den Regeln der jeweiligen Konsultation ab.',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _NoticeCard(
                icon: Icons.verified_outlined,
                title: 'Verified Result',
                body: _text(
                  context,
                  it: 'Il Verified Result documenta il risultato prodotto dalla Session e consente di verificarne l’integrità tecnica. Non costituisce automaticamente certificazione notarile, elettorale o validità legale.',
                  en: 'Verified Result documents the result produced by a Session and allows its technical integrity to be checked. It does not automatically constitute notarization, electoral certification or legal validity.',
                  de: 'Verified Result dokumentiert das Ergebnis einer Session und ermöglicht die Prüfung seiner technischen Integrität. Es stellt nicht automatisch eine notarielle, wahlrechtliche oder rechtliche Zertifizierung dar.',
                ),
              ),
              const SizedBox(height: 16),
              _NoticeCard(
                icon: Icons.balance_outlined,
                title: _text(
                  context,
                  it: 'Il principio economico',
                  en: 'The economic principle',
                  de: 'Das wirtschaftliche Prinzip',
                ),
                body: _text(
                  context,
                  it: 'Le persone partecipano gratuitamente. Gli strumenti professionali Business possono sostenere i costi della piattaforma. Pagare non compra verifica, peso nei Vote o priorità artificiale in Pulse/Pulse Now.',
                  en: 'People participate for free. Professional Business tools can support the platform’s costs. Paying does not buy verification, weight in Vote or artificial priority in Pulse/Pulse Now.',
                  de: 'Menschen nehmen kostenlos teil. Professionelle Business-Werkzeuge können die Plattformkosten tragen. Bezahlen kauft weder Verifizierung noch mehr Gewicht in Vote oder künstliche Priorität in Pulse/Pulse Now.',
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: () => _goHome(context),
                    icon: const Icon(Icons.explore_outlined),
                    label: Text(
                      _text(
                        context,
                        it: 'Esplora Social Vote',
                        en: 'Explore Social Vote',
                        de: 'Social Vote entdecken',
                      ),
                    ),
                  ),
                  if (loggedIn)
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context)
                          .pushNamed(AppRouter.organizationWorkspace),
                      icon: const Icon(Icons.dashboard_outlined),
                      label: Text(
                        _text(
                          context,
                          it: 'Apri Workspace Business',
                          en: 'Open Business Workspace',
                          de: 'Business Workspace öffnen',
                        ),
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRouter.register),
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: Text(
                        _text(
                          context,
                          it: 'Inizia come persona',
                          en: 'Start as a person',
                          de: 'Als Person starten',
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _text(
                  context,
                  it: 'Durante il pilot Business, billing e pagamenti restano disattivati.',
                  en: 'During the Business pilot, billing and payments remain disabled.',
                  de: 'Während des Business-Piloten bleiben Abrechnung und Zahlungen deaktiviert.',
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideHero extends StatelessWidget {
  final String title;
  final String body;

  const _GuideHero({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primaryContainer.withValues(alpha: 0.82),
            colors.surfaceContainerHighest.withValues(alpha: 0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.primary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.hub_outlined, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'Social Vote',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 10),
          Text(body, style: theme.textTheme.bodyLarge?.copyWith(height: 1.45)),
        ],
      ),
    );
  }
}

class _AudienceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String badge;
  final String body;
  final List<String> items;

  const _AudienceCard({
    required this.icon,
    required this.title,
    required this.badge,
    required this.body,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                  child: Icon(icon),
                ),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    badge,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(body,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        size: 18, color: colors.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _GuideSectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _ToolCard(
      {required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 10),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(body,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<String> items;

  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.shield_outlined,
                          size: 19, color: colors.primary),
                      const SizedBox(width: 9),
                      Expanded(child: Text(item)),
                    ],
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _NoticeCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(body,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
