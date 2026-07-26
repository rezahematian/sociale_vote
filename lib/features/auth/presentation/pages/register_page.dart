import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/features/auth/presentation/widgets/register_form.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider(
      create: (_) => AppDI.instance.createAuthController(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.authRegisterPageTitle),
        ),
        body: const SafeArea(
          child: _RegisterPageBody(),
        ),
      ),
    );
  }
}

class _RegisterPageBody extends StatelessWidget {
  const _RegisterPageBody();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final isNarrow = mediaQuery.size.width < 600;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = isNarrow ? 20.0 : 32.0;
          final verticalPadding = isNarrow ? 24.0 : 40.0;
          final availableHeight =
              constraints.maxHeight - bottomInset - (verticalPadding * 2);

          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              verticalPadding,
              horizontalPadding,
              verticalPadding + bottomInset,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: availableHeight > 0 ? availableHeight : 0,
              ),
              child: Align(
                alignment: isNarrow ? Alignment.topCenter : Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: const RegisterForm(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
