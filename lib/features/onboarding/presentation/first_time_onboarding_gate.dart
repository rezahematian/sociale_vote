import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/features/home/presentation/pages/public_home_screen.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

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
      // Lo storage locale non deve mai impedire l'accesso all'app.
      completed = true;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _completed = completed;
      _loading = false;
    });
  }

  Future<void> _completeOnboarding() async {
    try {
      await AppDI.instance.storageService.writeBool(
        _completedKey,
        true,
      );
    } catch (_) {
      // Anche se la persistenza locale fallisce, la sessione corrente
      // deve poter proseguire normalmente.
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _completed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_completed) {
      return const PublicHomeScreen();
    }

    return _FirstTimeOnboardingPage(
      onComplete: _completeOnboarding,
    );
  }
}

class _FirstTimeOnboardingPage extends StatefulWidget {
  final Future<void> Function() onComplete;

  const _FirstTimeOnboardingPage({
    required this.onComplete,
  });

  @override
  State<_FirstTimeOnboardingPage> createState() =>
      _FirstTimeOnboardingPageState();
}

class _FirstTimeOnboardingPageState extends State<_FirstTimeOnboardingPage> {
  final PageController _pageController = PageController();

  int _currentPage = 0;
  bool _finishing = false;

  static const int _pageCount = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_finishing) {
      return;
    }

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

  List<_OnboardingStep> _steps(AppLocalizations l10n) {
    return [
      _OnboardingStep(
        icon: Icons.poll_outlined,
        title: l10n.onboardingPollTitle,
        description: l10n.onboardingPollDescription,
      ),
      _OnboardingStep(
        icon: Icons.local_fire_department_outlined,
        title: l10n.onboardingHeatIceTitle,
        description: l10n.onboardingHeatIceDescription,
      ),
      _OnboardingStep(
        icon: Icons.map_outlined,
        title: l10n.onboardingCivicMapTitle,
        description: l10n.onboardingCivicMapDescription,
      ),
      _OnboardingStep(
        icon: Icons.travel_explore_outlined,
        title: l10n.onboardingGeoScopeTitle,
        description: l10n.onboardingGeoScopeDescription,
      ),
      _OnboardingStep(
        icon: Icons.verified_user_outlined,
        title: l10n.onboardingVerificationTitle,
        description: l10n.onboardingVerificationDescription,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final steps = _steps(l10n);
    final isLastPage = _currentPage == steps.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: TextButton(
                  onPressed: _finishing ? null : _finish,
                  child: Text(l10n.onboardingSkipButton),
                ),
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

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
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
                        const SizedBox(height: 32),
                        Text(
                          step.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          step.description,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.45,
                            color: theme.textTheme.bodyLarge?.color
                                ?.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
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
                  const SizedBox(height: 22),
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isLastPage
                                    ? l10n.onboardingStartButton
                                    : l10n.onboardingNextButton,
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

  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
  });
}
