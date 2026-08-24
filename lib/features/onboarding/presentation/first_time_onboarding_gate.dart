import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/features/home/presentation/pages/public_home_screen.dart';

class FirstTimeOnboardingGate extends StatefulWidget {
  const FirstTimeOnboardingGate({super.key});

  @override
  State<FirstTimeOnboardingGate> createState() =>
      _FirstTimeOnboardingGateState();
}

class _FirstTimeOnboardingGateState extends State<FirstTimeOnboardingGate> {
  static const String _completedKey = 'first_time_onboarding_v1_completed';

  bool _loading = true;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    bool completed = false;

    try {
      completed =
          await AppDI.instance.storageService.readBool(_completedKey) ?? false;
    } catch (_) {
      // Local storage must never block access to the app.
      completed = true;
    }

    if (!mounted) return;

    setState(() {
      _completed = completed;
      _loading = false;
    });
  }

  Future<void> _completeOnboarding() async {
    try {
      await AppDI.instance.storageService.writeBool(_completedKey, true);
    } catch (_) {
      // Even if persistence fails, the current session must continue.
    }

    if (!mounted) return;

    setState(() {
      _completed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_completed) {
      return const PublicHomeScreen();
    }

    return _FirstTimeOnboardingPage(onComplete: _completeOnboarding);
  }
}

class _FirstTimeOnboardingPage extends StatefulWidget {
  final Future<void> Function() onComplete;

  const _FirstTimeOnboardingPage({required this.onComplete});

  @override
  State<_FirstTimeOnboardingPage> createState() =>
      _FirstTimeOnboardingPageState();
}

class _FirstTimeOnboardingPageState extends State<_FirstTimeOnboardingPage> {
  final PageController _pageController = PageController();

  int _currentPage = 0;
  bool _finishing = false;

  static const int _pageCount = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _text({
    required String it,
    required String en,
    required String de,
  }) {
    final language = Localizations.localeOf(context).languageCode.toLowerCase();
    if (language == 'it') return it;
    if (language == 'de') return de;
    return en;
  }

  Future<void> _finish() async {
    if (_finishing) return;

    setState(() {
      _finishing = true;
    });

    await widget.onComplete();
  }

  Future<void> _next() async {
    if (_currentPage >= _pageCount - 1) {
      await _finish();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  List<_OnboardingStep> _steps() {
    return [
      _OnboardingStep(
        icon: Icons.travel_explore_rounded,
        title: _text(
          it: 'Scopri cosa conta',
          en: 'Discover what matters',
          de: 'Entdecke, was zählt',
        ),
        description: _text(
          it: 'Pulse ti aiuta a scoprire contenuti rilevanti, Pulse Now mostra ciò che si muove adesso e Civic Map collega Voce, Vote e notizie ai luoghi.',
          en: 'Pulse helps you discover relevant content, Pulse Now shows what is moving now, and Civic Map connects Voce, Vote and news to places.',
          de: 'Pulse hilft dir, relevante Inhalte zu entdecken, Pulse Now zeigt, was gerade Aufmerksamkeit erhält, und Civic Map verbindet Voce, Vote und Nachrichten mit Orten.',
        ),
        badge: _text(it: 'ESPLORA', en: 'EXPLORE', de: 'ENTDECKEN'),
      ),
      _OnboardingStep(
        icon: Icons.how_to_vote_outlined,
        title: _text(
          it: 'Esprimi la tua Voce. Partecipa ai Vote.',
          en: 'Share your Voce. Take part in Vote.',
          de: 'Teile deine Voce. Nimm an Vote teil.',
        ),
        description: _text(
          it: 'Per le persone Social Vote resta gratuito: pubblica una Voce, crea o partecipa a un Vote, commenta e segui persone, luoghi e organizzazioni. Nessuna pubblicità e nessuna visibilità acquistabile.',
          en: 'For people, Social Vote stays free: publish a Voce, create or join a Vote, comment and follow people, places and organizations. No advertising and no visibility that can be bought.',
          de: 'Für Menschen bleibt Social Vote kostenlos: Veröffentliche eine Voce, erstelle oder nutze Vote, kommentiere und folge Menschen, Orten und Organisationen. Keine Werbung und keine käufliche Sichtbarkeit.',
        ),
        badge: _text(
            it: 'PER TE · GRATUITO',
            en: 'FOR YOU · FREE',
            de: 'FÜR DICH · KOSTENLOS'),
      ),
      _OnboardingStep(
        icon: Icons.apartment_rounded,
        title: _text(
          it: 'Persone e organizzazioni, ruoli diversi',
          en: 'People and organizations, different roles',
          de: 'Menschen und Organisationen, unterschiedliche Rollen',
        ),
        description: _text(
          it: 'Il tuo account personale può gestire un’organizzazione separata. Dal Business Workspace un’organizzazione può pubblicare Voce e Vote ufficiali e gestire Sessions con QR, Stage e Verified Result. La verifica serve a ridurre duplicazioni e abusi, non a vendere dati o rendere un voto automaticamente legale.',
          en: 'Your personal account can manage a separate organization. From the Business Workspace an organization can publish official Voce and Vote and run Sessions with QR, Stage and Verified Result. Verification helps reduce duplication and abuse; it is not for selling data or making a vote automatically legally binding.',
          de: 'Dein persönliches Konto kann eine separate Organisation verwalten. Im Business Workspace kann eine Organisation offizielle Voce und Vote veröffentlichen und Sessions mit QR, Stage und Verified Result durchführen. Verifizierung reduziert Duplikate und Missbrauch; sie dient nicht dem Datenverkauf und macht eine Abstimmung nicht automatisch rechtsverbindlich.',
        ),
        badge: 'BUSINESS · TRUST',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = _steps();
    final isLastPage = _currentPage == steps.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  Text(
                    'Social Vote',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _finishing ? null : _finish,
                    child: Text(
                      _text(it: 'Salta', en: 'Skip', de: 'Überspringen'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: steps.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final step = steps[index];

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 18,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - 36,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 104,
                                height: 104,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  step.icon,
                                  size: 52,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 26),
                              Chip(
                                visualDensity: VisualDensity.compact,
                                label: Text(
                                  step.badge,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                step.title,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  height: 1.08,
                                ),
                              ),
                              const SizedBox(height: 14),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 680),
                                child: Text(
                                  step.description,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    height: 1.48,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      steps.length,
                      (index) {
                        final selected = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: selected ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _finishing ? null : _next,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: _finishing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                isLastPage
                                    ? _text(
                                        it: 'Entra in Social Vote',
                                        en: 'Enter Social Vote',
                                        de: 'Social Vote öffnen',
                                      )
                                    : _text(
                                        it: 'Avanti',
                                        en: 'Next',
                                        de: 'Weiter',
                                      ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingStep {
  final IconData icon;
  final String title;
  final String description;
  final String badge;

  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.badge,
  });
}
