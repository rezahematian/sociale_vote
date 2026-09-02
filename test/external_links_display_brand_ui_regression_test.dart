import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('external links display and brand UI contract', () {
    final workspace = File(
      'lib/features/organization/presentation/pages/organization_workspace_page.dart',
    ).readAsStringSync();
    final editor = File(
      'lib/features/organization/presentation/pages/organization_profile_editor_page.dart',
    ).readAsStringSync();
    final publicProfile = File(
      'lib/features/profile/presentation/pages/public_user_profile_page.dart',
    ).readAsStringSync();
    final brandWidget = File(
      'lib/features/organization/presentation/widgets/organization_external_channel_icon.dart',
    ).readAsStringSync();
    final controller = File(
      'lib/features/organization/application/organization_workspace_controller.dart',
    ).readAsStringSync();

    // Workspace Organization must receive the already-loaded external links.
    expect(workspace, contains('externalLinks: _controller.externalLinks'));
    expect(workspace, contains("it: 'Canali ufficiali'"));
    expect(workspace, contains('OrganizationExternalChannelIcon'));
    expect(workspace, contains('OrganizationWebsiteIcon'));

    // Existing persistence/load behavior must remain connected to the editor.
    expect(controller, contains('externalLinks = await repository.listMyExternalLinks()'));
    expect(editor, contains('for (final link in widget.controller.externalLinks)'));
    expect(editor, contains('_externalController(link.provider).text = link.canonicalUrl'));
    expect(editor, contains('OrganizationExternalChannelIcon'));

    // Public profile switches from text buttons to compact recognizable icons.
    expect(publicProfile, contains('_OfficialChannelIconAction'));
    expect(publicProfile, contains('OrganizationWebsiteIcon'));
    expect(publicProfile, isNot(contains('Icon(_externalIcon(link.provider))')));

    for (final provider in <String>[
      'youtube',
      'linkedin',
      'whatsapp',
      'instagram',
      'telegram',
    ]) {
      expect(brandWidget.toLowerCase(), contains(provider));
    }
  });
}
