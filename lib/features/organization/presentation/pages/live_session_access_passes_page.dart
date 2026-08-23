import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/organization/entities/live_session_models.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/session_pdf_service.dart';

class LiveSessionAccessPassesPage extends StatelessWidget {
  final LiveSessionSummary session;
  final List<String> tokens;

  const LiveSessionAccessPassesPage({
    super.key,
    required this.session,
    required this.tokens,
  });

  String _passUrl(String token) {
    final base = Uri.parse(AppRouter.publicSessionJoinUrl(session.joinCode));
    return base
        .replace(fragment: 'pass=${Uri.encodeComponent(token)}')
        .toString();
  }

  Future<void> _copyLinks(BuildContext context) async {
    final links = tokens.map(_passUrl).join('\n');
    await Clipboard.setData(ClipboardData(text: links));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(AppLocalizations.of(context)!.sessionCopyPassLinks)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sessionAccessPassesTitle),
        actions: [
          IconButton(
            onPressed: () => _copyLinks(context),
            tooltip: l10n.sessionCopyPassLinks,
            icon: const Icon(Icons.copy_all_rounded),
          ),
          IconButton(
            onPressed: () => SessionPdfService.printAccessPasses(
              session: session,
              tokens: tokens,
              l10n: l10n,
            ),
            tooltip: l10n.verifiedResultPrintPdf,
            icon: const Icon(Icons.print_outlined),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.sessionAccessPassesTitle,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(l10n.sessionAccessPassesSubtitle),
                            const SizedBox(height: 8),
                            Text(
                              l10n.sessionAccessPassPrintWarning,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      session.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                      '${tokens.length} ${l10n.sessionAccessPass.toLowerCase()}'),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                  '${session.organizationName ?? 'Social Vote'} · ${session.joinCode}'),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 960
                      ? 3
                      : constraints.maxWidth >= 620
                          ? 2
                          : 1;
                  final width =
                      (constraints.maxWidth - ((columns - 1) * 12)) / columns;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List<Widget>.generate(tokens.length, (index) {
                      final token = tokens[index];
                      return SizedBox(
                        width: width,
                        child: _AccessPassCard(
                          session: session,
                          token: token,
                          passUrl: _passUrl(token),
                          number: index + 1,
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: () => _copyLinks(context),
                    icon: const Icon(Icons.copy_all_rounded),
                    label: Text(l10n.sessionCopyPassLinks),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => SessionPdfService.printAccessPasses(
                      session: session,
                      tokens: tokens,
                      l10n: l10n,
                    ),
                    icon: const Icon(Icons.print_outlined),
                    label: Text(l10n.verifiedResultPrintPdf),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccessPassCard extends StatelessWidget {
  final LiveSessionSummary session;
  final String token;
  final String passUrl;
  final int number;

  const _AccessPassCard({
    required this.session,
    required this.token,
    required this.passUrl,
    required this.number,
  });

  Future<void> _copySingleLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: passUrl));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(AppLocalizations.of(context)!.sessionCopyPassLink)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage:
                      (session.organizationLogoUrl ?? '').trim().isNotEmpty
                          ? NetworkImage(session.organizationLogoUrl!.trim())
                          : null,
                  child: (session.organizationLogoUrl ?? '').trim().isEmpty
                      ? const Icon(Icons.apartment_rounded, size: 18)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.organizationName ?? 'Social Vote',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${l10n.sessionAccessPass} #$number',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.verified_rounded,
                    color: theme.colorScheme.primary, size: 20),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              session.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: QrImageView(data: passUrl, size: 170),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.sessionNoAccountRequired,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Divider(height: 22),
            Text(l10n.sessionAccessPassFallback,
                style: theme.textTheme.labelSmall),
            const SizedBox(height: 4),
            SelectableText(
              token,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${l10n.sessionJoinCode}: ${session.joinCode}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _copySingleLink(context),
              icon: const Icon(Icons.link_rounded, size: 18),
              label: Text(l10n.sessionCopyPassLink),
            ),
          ],
        ),
      ),
    );
  }
}
