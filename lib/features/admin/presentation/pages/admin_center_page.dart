import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/admin/entities/admin_entities.dart';
import 'package:sociale_vote/domain/admin/repositories/admin_repository.dart';
import 'package:sociale_vote/domain/admin/usecases/change_system_role.dart';
import 'package:sociale_vote/domain/admin/usecases/delete_admin_account.dart';
import 'package:sociale_vote/domain/admin/usecases/force_admin_logout.dart';
import 'package:sociale_vote/domain/admin/usecases/load_admin_audit.dart';
import 'package:sociale_vote/domain/admin/usecases/load_admin_dashboard.dart';
import 'package:sociale_vote/domain/admin/usecases/load_admin_reports.dart';
import 'package:sociale_vote/domain/admin/usecases/manage_admin_account_status.dart';
import 'package:sociale_vote/domain/admin/usecases/record_admin_report_decision.dart';
import 'package:sociale_vote/domain/admin/usecases/search_admin_users.dart';
import 'package:sociale_vote/domain/admin/usecases/set_report_content_visibility.dart';
import 'package:sociale_vote/domain/admin/usecases/set_admin_public_identity.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/role.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_status.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/features/map/application/civic_map_controller.dart';
import 'package:sociale_vote/features/map/presentation/widgets/world_globe_widget.dart';

enum AdminCenterSection { dashboard, users, verification, reports, audit }

AppLocalizations _adminL10n(BuildContext context) =>
    AppLocalizations.of(context)!;

typedef AdminCenterSectionBuilder = Widget Function(
    BuildContext context, AdminCenterSection section);

class AdminCenterPage extends StatefulWidget {
  final Role currentRole;
  final Future<void> Function() onRefresh;
  final Widget body;
  final AdminCenterSectionBuilder? sectionBuilder;

  const AdminCenterPage({
    super.key,
    required this.currentRole,
    required this.onRefresh,
    this.body = const SizedBox.shrink(),
    this.sectionBuilder,
  });

  @override
  State<AdminCenterPage> createState() => _AdminCenterPageState();
}

class _AdminCenterPageState extends State<AdminCenterPage> {
  static const double _desktopBreakpoint = 840;
  static const double _extendedRailBreakpoint = 1200;
  static const int _usersPerPage = 25;
  static const int _reportsPerPage = 25;
  static const Duration _userSearchDelay = Duration(milliseconds: 350);
  static const Uuid _uuid = Uuid();

  late final LoadAdminDashboard _loadAdminDashboard;
  late final LoadAdminAudit _loadAdminAudit;
  late final LoadAdminReports _loadAdminReports;
  late final RecordAdminReportDecision _recordAdminReportDecision;
  late final SetReportContentVisibility _setReportContentVisibility;
  late final SearchAdminUsers _searchAdminUsers;
  late final ChangeSystemRole _changeSystemRole;
  late final SetAdminPublicIdentity _setAdminPublicIdentity;
  late final SuspendAdminAccount _suspendAdminAccount;
  late final ReactivateAdminAccount _reactivateAdminAccount;
  late final ForceAdminLogout _forceAdminLogout;
  late final DeleteAdminAccount _deleteAdminAccount;
  late final AdminRepository _adminRepository;
  late final CivicMapController _adminGlobeController;
  final TextEditingController _userSearchController = TextEditingController();
  final TextEditingController _auditActorController = TextEditingController();
  final TextEditingController _auditActionController = TextEditingController();
  final TextEditingController _auditTargetController = TextEditingController();

  AdminDashboardSummary? _dashboardSummary;
  AdminReportQueuePage? _reportQueuePage;
  AdminUserSearchPage? _userSearchPage;
  AdminUserSummary? _selectedUser;
  AdminUserDetail? _userDetail;
  Timer? _userSearchDebounce;
  int _usersRequestGeneration = 0;
  int _userDetailRequestGeneration = 0;
  int _reportsRequestGeneration = 0;
  bool _isDashboardLoading = true;
  bool _dashboardLoadFailed = false;
  bool _isUsersLoading = false;
  bool _usersLoadFailed = false;
  bool _isUserDetailLoading = false;
  bool _userDetailLoadFailed = false;
  bool _isReportsLoading = false;
  bool _reportsLoadFailed = false;
  bool _isRefreshing = false;
  List<AdminAuditEntry> _auditEntries = const <AdminAuditEntry>[];
  bool _isAuditLoading = false;
  bool _auditLoadFailed = false;
  AdminAuditResult? _auditResultFilter;
  DateTimeRange? _auditDateRange;
  AdminReportStatus? _reportStatusFilter;
  AdminReportTargetType? _reportTargetTypeFilter;
  bool _showEscalatedReportsOnly = false;
  AdminCenterSection _selectedSection = AdminCenterSection.dashboard;
  Locale? _adminLocaleOverride;

  List<_AdminDestination> get _destinations {
    return [
      _AdminDestination(
        section: AdminCenterSection.dashboard,
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        label: _adminL10n(context).adminCenterDashboardNavigation,
      ),
      if (widget.currentRole == Role.admin)
        _AdminDestination(
          section: AdminCenterSection.users,
          icon: Icons.people_outline,
          selectedIcon: Icons.people,
          label: _adminL10n(context).adminCenterUsersNavigation,
        ),
      _AdminDestination(
        section: AdminCenterSection.verification,
        icon: Icons.verified_user_outlined,
        selectedIcon: Icons.verified_user,
        label: _adminL10n(context).adminCenterVerificationNavigation,
      ),
      _AdminDestination(
        section: AdminCenterSection.reports,
        icon: Icons.flag_outlined,
        selectedIcon: Icons.flag,
        label: _adminL10n(context).adminCenterReportsNavigation,
      ),
      if (widget.currentRole == Role.admin)
        _AdminDestination(
          section: AdminCenterSection.audit,
          icon: Icons.history_outlined,
          selectedIcon: Icons.history,
          label: _adminL10n(context).adminCenterAuditNavigation,
        ),
    ];
  }

  @override
  void initState() {
    super.initState();

    _adminRepository = AppDI.instance.adminRepository;
    _adminGlobeController =
        AppDI.instance.createCivicMapController(homePreview: true);
    _adminGlobeController.addListener(_handleAdminGlobeChanged);
    _loadAdminDashboard = LoadAdminDashboard(_adminRepository);
    _loadAdminAudit = LoadAdminAudit(_adminRepository);
    _loadAdminReports = LoadAdminReports(_adminRepository);
    _recordAdminReportDecision = RecordAdminReportDecision(_adminRepository);
    _setReportContentVisibility = SetReportContentVisibility(_adminRepository);
    _searchAdminUsers = SearchAdminUsers(_adminRepository);
    _changeSystemRole = ChangeSystemRole(_adminRepository);
    _setAdminPublicIdentity = SetAdminPublicIdentity(_adminRepository);
    _suspendAdminAccount = SuspendAdminAccount(_adminRepository);
    _reactivateAdminAccount = ReactivateAdminAccount(_adminRepository);
    _forceAdminLogout = ForceAdminLogout(_adminRepository);
    _deleteAdminAccount = DeleteAdminAccount(_adminRepository);
    unawaited(_loadDashboard(markLoading: false));
    unawaited(_loadAdminGlobe());
  }

  @override
  void dispose() {
    _adminGlobeController.removeListener(_handleAdminGlobeChanged);
    _adminGlobeController.dispose();
    _userSearchDebounce?.cancel();
    _userSearchController.dispose();
    _auditActorController.dispose();
    _auditActionController.dispose();
    _auditTargetController.dispose();
    super.dispose();
  }

  void _handleAdminGlobeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadAdminGlobe({bool forceRefresh = false}) async {
    try {
      if (forceRefresh && _adminGlobeController.currentScope != null) {
        await _adminGlobeController.refresh();
        return;
      }

      await _adminGlobeController.syncScope(
        GeoScope.world(),
        forceReload: forceRefresh,
        clearSelection: false,
      );
    } catch (_) {
      // Dashboard/admin controls must remain usable even if map content fails.
    }
  }

  @override
  void didUpdateWidget(covariant AdminCenterPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentRole != widget.currentRole &&
        !_destinations.any(
          (destination) => destination.section == _selectedSection,
        )) {
      _selectedSection = AdminCenterSection.dashboard;
      _clearSelectedUser();
    }
  }

  void _setAdminLocale(String value) {
    final locale = switch (value) {
      'it' => const Locale('it'),
      'en' => const Locale('en'),
      _ => null,
    };

    if (_adminLocaleOverride == locale) {
      return;
    }

    setState(() {
      _adminLocaleOverride = locale;
    });
  }

  Widget _buildLanguageSelector() {
    return PopupMenuButton<String>(
      initialValue: _adminLocaleOverride?.languageCode ?? 'auto',
      onSelected: _setAdminLocale,
      icon: const Icon(Icons.language_outlined),
      itemBuilder: (_) => const [
        PopupMenuItem<String>(
          value: 'auto',
          child: Row(
            children: [
              Icon(Icons.settings_suggest_outlined),
              SizedBox(width: 12),
              Text('AUTO'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'it',
          child: Row(
            children: [
              Icon(Icons.language),
              SizedBox(width: 12),
              Text('Italiano'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              Icon(Icons.language),
              SizedBox(width: 12),
              Text('English'),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _refresh() async {
    final showingUserDetail =
        _selectedSection == AdminCenterSection.users && _selectedUser != null;
    final selectedSectionLoading = (_selectedSection ==
                AdminCenterSection.dashboard &&
            _isDashboardLoading) ||
        (_selectedSection == AdminCenterSection.users &&
            (showingUserDetail ? _isUserDetailLoading : _isUsersLoading)) ||
        (_selectedSection == AdminCenterSection.reports && _isReportsLoading) ||
        (_selectedSection == AdminCenterSection.audit && _isAuditLoading);

    if (_isRefreshing || selectedSectionLoading) {
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    try {
      await widget.onRefresh();

      if (!mounted) {
        return;
      }

      if (_selectedSection == AdminCenterSection.users) {
        final selectedUser = _selectedUser;

        if (selectedUser != null) {
          await _loadUserDetail(selectedUser, markLoading: _userDetail == null);
        } else {
          await _loadUsers(
            page: _userSearchPage?.page ?? 1,
            markLoading: _userSearchPage == null,
          );
        }
      } else if (_selectedSection == AdminCenterSection.reports) {
        await _loadReports(
          offset: _reportQueuePage?.offset ?? 0,
          markLoading: _reportQueuePage == null,
        );
      } else if (_selectedSection == AdminCenterSection.audit) {
        await _loadAudit(markLoading: _auditEntries.isEmpty);
      } else {
        await _loadDashboard(markLoading: _dashboardSummary == null);
        if (_selectedSection == AdminCenterSection.dashboard) {
          await _loadAdminGlobe(forceRefresh: true);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          if (_selectedSection == AdminCenterSection.users) {
            if (_selectedUser != null) {
              _userDetailLoadFailed = true;
            } else {
              _usersLoadFailed = true;
            }
          } else if (_selectedSection == AdminCenterSection.reports) {
            _reportsLoadFailed = true;
          } else if (_selectedSection == AdminCenterSection.audit) {
            _auditLoadFailed = true;
          } else {
            _dashboardLoadFailed = true;
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _loadDashboard({bool markLoading = true}) async {
    if (markLoading && mounted) {
      setState(() {
        _isDashboardLoading = true;
        _dashboardLoadFailed = false;
      });
    }

    try {
      final summary = await _loadAdminDashboard();

      if (!mounted) {
        return;
      }

      setState(() {
        _dashboardSummary = summary;
        _isDashboardLoading = false;
        _dashboardLoadFailed = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isDashboardLoading = false;
        _dashboardLoadFailed = true;
      });
    }
  }

  Future<void> _loadUsers({int page = 1, bool markLoading = true}) async {
    final requestGeneration = ++_usersRequestGeneration;
    final query = _userSearchController.text.trim();

    if (mounted) {
      setState(() {
        _isUsersLoading = true;
        _usersLoadFailed = false;
        if (markLoading) {
          _userSearchPage = null;
        }
      });
    }

    try {
      final result = await _searchAdminUsers(
        query: query,
        page: page,
        perPage: _usersPerPage,
      );

      if (!mounted || requestGeneration != _usersRequestGeneration) {
        return;
      }

      setState(() {
        _userSearchPage = result;
        _isUsersLoading = false;
        _usersLoadFailed = false;
      });
    } catch (_) {
      if (!mounted || requestGeneration != _usersRequestGeneration) {
        return;
      }

      setState(() {
        _isUsersLoading = false;
        _usersLoadFailed = true;
      });
    }
  }

  Future<void> _loadUserDetail(
    AdminUserSummary user, {
    bool markLoading = true,
  }) async {
    final requestGeneration = ++_userDetailRequestGeneration;

    if (mounted) {
      setState(() {
        _isUserDetailLoading = true;
        _userDetailLoadFailed = false;
        if (markLoading) {
          _userDetail = null;
        }
      });
    }

    try {
      final detail = await _adminRepository.getUserDetail(userId: user.id);

      if (!mounted ||
          requestGeneration != _userDetailRequestGeneration ||
          _selectedUser?.id != user.id) {
        return;
      }

      setState(() {
        _selectedUser = detail.toSummary();
        _userDetail = detail;
        _isUserDetailLoading = false;
        _userDetailLoadFailed = false;
      });
    } catch (_) {
      if (!mounted ||
          requestGeneration != _userDetailRequestGeneration ||
          _selectedUser?.id != user.id) {
        return;
      }

      setState(() {
        _isUserDetailLoading = false;
        _userDetailLoadFailed = true;
      });
    }
  }

  void _onUserSearchChanged(String _) {
    _usersRequestGeneration++;
    _userSearchDebounce?.cancel();
    _userSearchDebounce = Timer(_userSearchDelay, () {
      if (mounted) {
        unawaited(_loadUsers(page: 1));
      }
    });
    setState(() {});
  }

  void _clearUserSearch() {
    _userSearchDebounce?.cancel();
    _userSearchController.clear();
    setState(() {});
    unawaited(_loadUsers(page: 1));
  }

  void _openUserDetail(AdminUserSummary user) {
    setState(() {
      _selectedUser = user;
      _userDetail = null;
      _isUserDetailLoading = true;
      _userDetailLoadFailed = false;
    });
    unawaited(_loadUserDetail(user, markLoading: false));
  }

  void _closeUserDetail() {
    if (_selectedUser == null) {
      return;
    }

    setState(_clearSelectedUser);
  }

  void _clearSelectedUser() {
    _userDetailRequestGeneration++;
    _selectedUser = null;
    _userDetail = null;
    _isUserDetailLoading = false;
    _userDetailLoadFailed = false;
  }

  Future<void> _openChangeRoleDialog(AdminUserDetail detail) async {
    final operationId = _uuid.v4();
    final changedRole = await showDialog<Role>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _AdminRoleChangeDialog(
          detail: detail,
          onConfirm: ({required Role role, required String reason}) {
            return _changeSystemRole(
              operationId: operationId,
              targetUserId: detail.id,
              role: role,
              reason: reason,
            );
          },
        );
      },
    );

    if (!mounted || changedRole == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _adminL10n(context).adminCenterRoleChangedSuccess(
            _adminRoleLabel(context, detail.systemRole),
            _adminRoleLabel(context, changedRole),
          ),
        ),
      ),
    );

    final selectedUser = _selectedUser;
    if (selectedUser == null || selectedUser.id != detail.id) {
      return;
    }

    await _loadUserDetail(selectedUser, markLoading: false);

    if (!mounted) {
      return;
    }

    unawaited(_loadUsers(page: _userSearchPage?.page ?? 1, markLoading: false));
  }

  Future<void> _loadReports({int offset = 0, bool markLoading = true}) async {
    final requestGeneration = ++_reportsRequestGeneration;

    if (mounted) {
      setState(() {
        _isReportsLoading = true;
        _reportsLoadFailed = false;
        if (markLoading) {
          _reportQueuePage = null;
        }
      });
    }

    try {
      final result = _showEscalatedReportsOnly
          ? await _adminRepository.getEscalatedReportQueue(
              limit: _reportsPerPage,
              offset: offset,
            )
          : await _loadAdminReports(
              status: _reportStatusFilter,
              targetType: _reportTargetTypeFilter,
              limit: _reportsPerPage,
              offset: offset,
            );

      if (!mounted || requestGeneration != _reportsRequestGeneration) {
        return;
      }

      setState(() {
        _reportQueuePage = result;
        _isReportsLoading = false;
        _reportsLoadFailed = false;
      });
    } catch (_) {
      if (!mounted || requestGeneration != _reportsRequestGeneration) {
        return;
      }

      setState(() {
        _isReportsLoading = false;
        _reportsLoadFailed = true;
      });
    }
  }

  Future<void> _openPublicIdentityDialog(AdminUserDetail detail) async {
    final operationId = _uuid.v4();
    final changedIdentity = await showDialog<_AdminPublicIdentitySelection>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _AdminPublicIdentityDialog(
          detail: detail,
          onConfirm: ({
            required ActorType actorType,
            required VerificationLevel verificationLevel,
            required String reason,
          }) {
            return _setAdminPublicIdentity(
              operationId: operationId,
              targetUserId: detail.id,
              actorType: actorType,
              verificationLevel: verificationLevel,
              reason: reason,
            );
          },
        );
      },
    );

    if (!mounted || changedIdentity == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _adminL10n(context).adminCenterIdentityChangedSuccess(
            _actorTypeLabel(context, changedIdentity.actorType),
            _verificationLevelLabel(
              context,
              changedIdentity.verificationLevel,
            ),
          ),
        ),
      ),
    );

    final selectedUser = _selectedUser;
    if (selectedUser == null || selectedUser.id != detail.id) {
      return;
    }

    await _loadUserDetail(selectedUser, markLoading: false);

    if (!mounted) {
      return;
    }

    unawaited(_loadDashboard(markLoading: false));
  }

  Future<void> _openSuspendAccountDialog(AdminUserDetail detail) async {
    if (widget.currentRole != Role.admin ||
        !detail.canReceiveAdminActions ||
        detail.isSuspended) {
      return;
    }

    final operationId = _uuid.v4();
    final suspendedUntil = await showDialog<DateTime>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _AdminSuspendAccountDialog(
          detail: detail,
          onConfirm: (
              {required DateTime suspendedUntil, required String reason}) {
            return _suspendAdminAccount(
              operationId: operationId,
              targetUserId: detail.id,
              suspendedUntil: suspendedUntil,
              reason: reason,
            );
          },
        );
      },
    );

    if (!mounted || suspendedUntil == null) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _adminL10n(context).adminCenterAccountSuspendedSuccess(
              _formatDateTime(context, suspendedUntil),
            ),
          ),
        ),
      );

    final selectedUser = _selectedUser;
    if (selectedUser == null || selectedUser.id != detail.id) {
      return;
    }

    await _loadUserDetail(selectedUser, markLoading: false);

    if (!mounted) {
      return;
    }

    unawaited(_loadUsers(page: _userSearchPage?.page ?? 1, markLoading: false));
    unawaited(_loadDashboard(markLoading: false));
  }

  Future<void> _openReactivateAccountDialog(AdminUserDetail detail) async {
    if (widget.currentRole != Role.admin ||
        !detail.canReceiveAdminActions ||
        !detail.isSuspended) {
      return;
    }

    final operationId = _uuid.v4();
    final reactivated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _AdminAccountActionDialog(
          detail: detail,
          title: _adminL10n(context).adminCenterReactivateAccountAction,
          description: _adminL10n(context).adminCenterReactivateDescription,
          reasonHint: _adminL10n(context).adminCenterReactivateReasonHint,
          confirmationText:
              _adminL10n(context).adminCenterReactivateConfirmation,
          submitLabel: _adminL10n(context).adminCenterReactivateAccountAction,
          failureMessage: _adminL10n(context).adminCenterReactivateFailure,
          onConfirm: ({required String reason}) {
            return _reactivateAdminAccount(
              operationId: operationId,
              targetUserId: detail.id,
              reason: reason,
            );
          },
        );
      },
    );

    if (!mounted || reactivated != true) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _adminL10n(context).adminCenterReactivateSuccess,
          ),
        ),
      );

    final selectedUser = _selectedUser;
    if (selectedUser == null || selectedUser.id != detail.id) {
      return;
    }

    await _loadUserDetail(selectedUser, markLoading: false);

    if (!mounted) {
      return;
    }

    unawaited(_loadUsers(page: _userSearchPage?.page ?? 1, markLoading: false));
    unawaited(_loadDashboard(markLoading: false));
  }

  Future<void> _openForceLogoutDialog(AdminUserDetail detail) async {
    if (widget.currentRole != Role.admin ||
        !detail.canReceiveAdminActions ||
        detail.isSuspended) {
      return;
    }

    final operationId = _uuid.v4();
    final loggedOut = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _AdminAccountActionDialog(
          detail: detail,
          title: _adminL10n(context).adminCenterForceLogoutAction,
          description:
              _adminL10n(context).adminCenterForceLogoutFullDescription,
          reasonHint: _adminL10n(context).adminCenterForceLogoutReasonHint,
          confirmationText:
              _adminL10n(context).adminCenterForceLogoutConfirmation,
          submitLabel: _adminL10n(context).adminCenterForceLogoutAction,
          failureMessage: _adminL10n(context).adminCenterForceLogoutFailure,
          onConfirm: ({required String reason}) {
            return _forceAdminLogout(
              operationId: operationId,
              targetUserId: detail.id,
              reason: reason,
            );
          },
        );
      },
    );

    if (!mounted || loggedOut != true) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _adminL10n(context).adminCenterForceLogoutSuccess,
          ),
        ),
      );

    final selectedUser = _selectedUser;
    if (selectedUser == null || selectedUser.id != detail.id) {
      return;
    }

    await _loadUserDetail(selectedUser, markLoading: false);
  }

  Future<void> _openDeleteAccountDialog(AdminUserDetail detail) async {
    if (widget.currentRole != Role.admin ||
        !detail.canReceiveAdminActions ||
        detail.isAdmin) {
      return;
    }

    final operationId = _uuid.v4();
    final deleted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _AdminDeleteAccountDialog(
          detail: detail,
          onConfirm: ({
            required String reason,
            required String confirmation,
            required String accountIdentifier,
          }) {
            return _deleteAdminAccount(
              operationId: operationId,
              targetUserId: detail.id,
              reason: reason,
              confirmation: confirmation,
              accountIdentifier: accountIdentifier,
            );
          },
        );
      },
    );

    if (!mounted || deleted != true) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(_adminL10n(context).adminCenterDeleteSuccess),
        ),
      );

    setState(_clearSelectedUser);
    unawaited(_loadUsers(page: _userSearchPage?.page ?? 1, markLoading: false));
    unawaited(_loadDashboard(markLoading: false));
  }

  Future<void> _openReportDecisionDialog(AdminReportEntry report) async {
    if (!report.canRecordModerationDecision) {
      _showReportNavigationMessage(
        _adminL10n(context).adminCenterReportAlreadyReviewed,
      );
      return;
    }

    final recordedDecision = await showDialog<AdminReportDecision>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _AdminReportDecisionDialog(
          report: report,
          onConfirm: ({
            required AdminReportDecision decision,
            required String reviewNote,
          }) {
            return _recordAdminReportDecision(
              reportId: report.id,
              decision: decision,
              reviewNote: reviewNote,
            );
          },
        );
      },
    );

    if (!mounted || recordedDecision == null) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _adminL10n(context).adminCenterReportDecisionRecorded(
              _adminReportDecisionLabel(context, recordedDecision),
            ),
          ),
        ),
      );

    await _loadReports(
      offset: _reportQueuePage?.offset ?? 0,
      markLoading: false,
    );

    if (!mounted) {
      return;
    }

    unawaited(_loadDashboard(markLoading: false));
  }

  Future<void> _openAdminResolutionDialog(AdminReportEntry report) async {
    if (widget.currentRole != Role.admin || !report.canResolveAdminEscalation) {
      _showReportNavigationMessage(
        _adminL10n(context).adminCenterReportNotAwaitingAdmin,
      );
      return;
    }

    final resolution = await showDialog<AdminReportResolution>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _AdminReportResolutionDialog(
          report: report,
          onConfirm: ({
            required AdminReportResolution resolution,
            required String resolutionNote,
          }) {
            return _adminRepository.resolveEscalatedReport(
              reportId: report.id,
              resolution: resolution,
              resolutionNote: resolutionNote,
            );
          },
        );
      },
    );

    if (!mounted || resolution == null) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _adminL10n(context).adminCenterAdministratorDecisionRecorded(
              _adminReportResolutionLabel(context, resolution),
            ),
          ),
        ),
      );

    await _loadReports(
      offset: _reportQueuePage?.offset ?? 0,
      markLoading: false,
    );

    if (!mounted) {
      return;
    }

    unawaited(_loadDashboard(markLoading: false));
  }

  Future<void> _openReportContentVisibilityDialog(
    AdminReportEntry report,
  ) async {
    if (!report.canChangeContentVisibility) {
      _showReportNavigationMessage(
        _adminL10n(context).adminCenterConfirmedViolationRequired,
      );
      return;
    }

    final requestedHiddenState = !report.contentIsHidden;
    final changedState = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _AdminReportContentVisibilityDialog(
          report: report,
          requestedHiddenState: requestedHiddenState,
          onConfirm: ({required bool isHidden, required String reason}) {
            return _setReportContentVisibility(
              reportId: report.id,
              isHidden: isHidden,
              reason: reason,
            );
          },
        );
      },
    );

    if (!mounted || changedState == null) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            changedState
                ? _adminL10n(context).adminCenterContentHiddenSuccess
                : _adminL10n(context).adminCenterContentRestoredSuccess,
          ),
        ),
      );

    await _loadReports(
      offset: _reportQueuePage?.offset ?? 0,
      markLoading: false,
    );

    if (!mounted) {
      return;
    }

    unawaited(_loadDashboard(markLoading: false));
  }

  Future<void> _openReportTarget(AdminReportEntry report) async {
    final targetId = report.targetId.trim();
    final l10n = _adminL10n(context);
    if (targetId.isEmpty) {
      _showReportNavigationMessage(
        l10n.adminCenterMissingContentId,
      );
      return;
    }

    try {
      switch (report.targetType) {
        case AdminReportTargetType.poll:
          await Navigator.of(
            context,
          ).pushNamed(AppRouter.pollDetail, arguments: targetId);
          return;
        case AdminReportTargetType.post:
          await Navigator.of(
            context,
          ).pushNamed(AppRouter.socialDetail, arguments: targetId);
          return;
        case AdminReportTargetType.news:
          final navigator = Navigator.of(context);
          final news = await AppDI.instance.getNewsDetail(EntityId(targetId));
          if (!navigator.mounted) {
            return;
          }
          await navigator.pushNamed(AppRouter.newsDetail, arguments: news);
          return;
        case AdminReportTargetType.unknown:
          _showReportNavigationMessage(
            l10n.adminCenterUnsupportedTargetType,
          );
          return;
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showReportNavigationMessage(
        l10n.adminCenterOriginalContentUnavailable,
      );
    }
  }

  Future<void> _openReportedProfile(AdminReportEntry report) async {
    if (!report.hasReportedUser) {
      _showReportNavigationMessage(
        _adminL10n(context).adminCenterNoReportedProfile,
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return _AdminReportedProfileSheet(report: report);
      },
    );
  }

  void _showReportNavigationMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loadAudit({bool markLoading = true}) async {
    if (_isAuditLoading) {
      return;
    }

    if (markLoading && mounted) {
      setState(() {
        _isAuditLoading = true;
        _auditLoadFailed = false;
      });
    } else {
      _isAuditLoading = true;
      _auditLoadFailed = false;
    }

    try {
      final entries = await _loadAdminAudit(
        actorUserId: _auditActorController.text,
        action: _auditActionController.text,
        targetId: _auditTargetController.text,
        result: _auditResultFilter,
        from: _auditDateRange?.start,
        to: _auditDateRange == null
            ? null
            : DateTime(
                _auditDateRange!.end.year,
                _auditDateRange!.end.month,
                _auditDateRange!.end.day,
                23,
                59,
                59,
                999,
              ),
        limit: 100,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _auditEntries = entries;
        _auditLoadFailed = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _auditLoadFailed = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAuditLoading = false;
        });
      } else {
        _isAuditLoading = false;
      }
    }
  }

  void _clearAuditFilters() {
    _auditActorController.clear();
    _auditActionController.clear();
    _auditTargetController.clear();
    setState(() {
      _auditResultFilter = null;
      _auditDateRange = null;
    });
    unawaited(_loadAudit());
  }

  Future<void> _selectAuditDateRange() async {
    if (_isAuditLoading) {
      return;
    }

    final now = DateTime.now();
    final selectedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year, now.month, now.day),
      initialDateRange: _auditDateRange,
      helpText: _adminL10n(context).adminCenterAuditDateFilterHelp,
    );

    if (!mounted || selectedRange == null) {
      return;
    }

    setState(() {
      _auditDateRange = selectedRange;
    });
  }

  String _auditDateRangeLabel(BuildContext context) {
    final range = _auditDateRange;
    if (range == null) {
      return _adminL10n(context).adminCenterAllDates;
    }

    final localizations = MaterialLocalizations.of(context);
    final from = localizations.formatMediumDate(range.start);
    final to = localizations.formatMediumDate(range.end);
    return from == to ? from : '$from – $to';
  }

  Widget _buildAuditSection(BuildContext context) {
    final hasFilters = _auditActorController.text.trim().isNotEmpty ||
        _auditActionController.text.trim().isNotEmpty ||
        _auditTargetController.text.trim().isNotEmpty ||
        _auditResultFilter != null ||
        _auditDateRange != null;

    return Column(
      key: const ValueKey(AdminCenterSection.audit),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _auditActorController,
                  enabled: !_isAuditLoading,
                  maxLength: 36,
                  decoration: InputDecoration(
                    labelText: _adminL10n(context).adminCenterActorUserIdLabel,
                    border: const OutlineInputBorder(),
                    counterText: '',
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => unawaited(_loadAudit()),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(
                width: 230,
                child: TextField(
                  controller: _auditActionController,
                  enabled: !_isAuditLoading,
                  maxLength: LoadAdminAudit.maximumActionLength,
                  decoration: InputDecoration(
                    labelText: _adminL10n(context).adminCenterActionLabel,
                    hintText: _adminL10n(context).adminCenterAuditActionHint,
                    border: const OutlineInputBorder(),
                    counterText: '',
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => unawaited(_loadAudit()),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _auditTargetController,
                  enabled: !_isAuditLoading,
                  maxLength: LoadAdminAudit.maximumTargetIdLength,
                  decoration: InputDecoration(
                    labelText: _adminL10n(context).adminCenterTargetIdLabel,
                    border: const OutlineInputBorder(),
                    counterText: '',
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => unawaited(_loadAudit()),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<AdminAuditResult?>(
                  initialValue: _auditResultFilter,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: _adminL10n(context).adminCenterOutcomeLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem<AdminAuditResult?>(
                      value: null,
                      child: Text(
                        _adminL10n(context).adminCenterAllOutcomes,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem<AdminAuditResult?>(
                      value: AdminAuditResult.success,
                      child: Text(
                        _adminL10n(context).adminCenterOutcomeSuccess,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem<AdminAuditResult?>(
                      value: AdminAuditResult.failure,
                      child: Text(
                        _adminL10n(context).adminCenterOutcomeFailure,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem<AdminAuditResult?>(
                      value: AdminAuditResult.denied,
                      child: Text(
                        _adminL10n(context).adminCenterOutcomeDenied,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem<AdminAuditResult?>(
                      value: AdminAuditResult.noop,
                      child: Text(
                        _adminL10n(context).adminCenterOutcomeNoChange,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  onChanged: _isAuditLoading
                      ? null
                      : (value) {
                          setState(() {
                            _auditResultFilter = value;
                          });
                        },
                ),
              ),
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _isAuditLoading ? null : _selectAuditDateRange,
                  icon: const Icon(Icons.date_range_outlined),
                  label: Text(_auditDateRangeLabel(context)),
                ),
              ),
              FilledButton.icon(
                onPressed:
                    _isAuditLoading ? null : () => unawaited(_loadAudit()),
                icon: const Icon(Icons.filter_alt_outlined),
                label: Text(_adminL10n(context).adminCenterApplyFiltersAction),
              ),
              TextButton(
                onPressed:
                    _isAuditLoading || !hasFilters ? null : _clearAuditFilters,
                child: Text(_adminL10n(context).adminCenterClearAction),
              ),
            ],
          ),
        ),
        if (_isAuditLoading) const LinearProgressIndicator(),
        Expanded(child: _buildAuditResults(context)),
      ],
    );
  }

  Widget _buildAuditResults(BuildContext context) {
    if (_auditLoadFailed) {
      return _AdminSectionState(
        icon: Icons.error_outline,
        iconColor: Theme.of(context).colorScheme.error,
        title: _adminL10n(context).adminCenterAuditUnavailableTitle,
        message: _adminL10n(context).adminCenterAuditUnavailableMessage,
        actionLabel: _adminL10n(context).adminCenterTryAgainAction,
        onAction: () => _loadAudit(),
        actionInProgress: _isAuditLoading,
      );
    }

    if (_isAuditLoading && _auditEntries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_auditEntries.isEmpty) {
      return _AdminSectionState(
        icon: Icons.history_toggle_off_outlined,
        title: _adminL10n(context).adminCenterNoAuditEntriesTitle,
        message: _adminL10n(context).adminCenterNoAuditEntriesMessage,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadAudit(markLoading: false),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        itemCount: _auditEntries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final entry = _auditEntries[index];
          final targetId = entry.targetId?.trim();
          final errorCode = entry.errorCode?.trim();

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SelectableText(
                        entry.action,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Chip(
                          label: Text(
                              _adminAuditResultLabel(context, entry.result))),
                      Chip(label: Text(entry.targetType)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                      '${_adminL10n(context).adminCenterAuditIdLabel}: ${entry.id}'),
                  SelectableText(
                    '${_adminL10n(context).adminCenterActorLabel}: ${entry.actorUserId} '
                    '(${_adminRoleLabel(context, entry.actorRole)})',
                  ),
                  if (targetId != null && targetId.isNotEmpty)
                    SelectableText(
                        '${_adminL10n(context).adminCenterTargetIdLabel}: $targetId'),
                  SelectableText(
                      '${_adminL10n(context).adminCenterReasonLabel}: ${entry.reason}'),
                  SelectableText(
                    '${_adminL10n(context).adminCenterTimestampLabel}: '
                    '${_formatDateTime(context, entry.createdAt)}',
                  ),
                  if (errorCode != null && errorCode.isNotEmpty)
                    SelectableText(
                        '${_adminL10n(context).adminCenterErrorLabel}: $errorCode'),
                  if (entry.previousValue.isNotEmpty ||
                      entry.newValue.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      title: Text(
                          _adminL10n(context).adminCenterRecordedValuesTitle),
                      children: [
                        if (entry.previousValue.isNotEmpty)
                          SelectableText(
                            '${_adminL10n(context).adminCenterPreviousValueLabel}: '
                            '${entry.previousValue}',
                          ),
                        if (entry.newValue.isNotEmpty)
                          SelectableText(
                            '${_adminL10n(context).adminCenterNewValueLabel}: '
                            '${entry.newValue}',
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedContent(BuildContext context) {
    if (_selectedSection == AdminCenterSection.dashboard) {
      return _buildDesktopDashboard(context);
    }

    if (_selectedSection == AdminCenterSection.users) {
      if (_selectedUser != null) {
        return _buildUserDetailSection(context);
      }

      return _buildUsersSection(context);
    }

    if (_selectedSection == AdminCenterSection.reports) {
      return _buildReportsSection(context);
    }

    if (_selectedSection == AdminCenterSection.audit) {
      return _buildAuditSection(context);
    }

    return KeyedSubtree(
      key: ValueKey(_selectedSection),
      child:
          widget.sectionBuilder?.call(context, _selectedSection) ?? widget.body,
    );
  }

  void _selectSection(AdminCenterSection section) {
    if (section == _selectedSection) {
      if (section == AdminCenterSection.users && _selectedUser != null) {
        _closeUserDetail();
      }
      return;
    }

    setState(() {
      _selectedSection = section;
      if (section != AdminCenterSection.users) {
        _clearSelectedUser();
      }
    });

    if (section == AdminCenterSection.users &&
        _userSearchPage == null &&
        !_isUsersLoading) {
      unawaited(_loadUsers());
    }

    if (section == AdminCenterSection.audit &&
        _auditEntries.isEmpty &&
        !_isAuditLoading) {
      unawaited(_loadAudit());
    }

    if (section == AdminCenterSection.reports &&
        _reportQueuePage == null &&
        !_isReportsLoading) {
      unawaited(_loadReports());
    }
  }

  Widget _buildReportsSection(BuildContext context) {
    final page = _reportQueuePage;

    return Column(
      key: const ValueKey(AdminCenterSection.reports),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              SizedBox(
                width: 190,
                child: DropdownButtonFormField<AdminReportTargetType?>(
                  initialValue: _reportTargetTypeFilter,
                  decoration: InputDecoration(
                    labelText: _adminL10n(context).adminCenterContentTypeLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem<AdminReportTargetType?>(
                      value: null,
                      child: Text(_adminL10n(context).adminCenterAllContent),
                    ),
                    DropdownMenuItem<AdminReportTargetType?>(
                      value: AdminReportTargetType.poll,
                      child: Text(_adminL10n(context).adminCenterPolls),
                    ),
                    DropdownMenuItem<AdminReportTargetType?>(
                      value: AdminReportTargetType.post,
                      child: Text(_adminL10n(context).adminCenterPosts),
                    ),
                    DropdownMenuItem<AdminReportTargetType?>(
                      value: AdminReportTargetType.news,
                      child: Text(_adminL10n(context).adminCenterNews),
                    ),
                  ],
                  onChanged: _isReportsLoading || _showEscalatedReportsOnly
                      ? null
                      : (value) {
                          setState(() {
                            _reportTargetTypeFilter = value;
                          });
                          unawaited(_loadReports());
                        },
                ),
              ),
              if (widget.currentRole == Role.admin)
                FilterChip(
                  avatar: const Icon(
                    Icons.admin_panel_settings_outlined,
                    size: 18,
                  ),
                  label: Text(
                      _adminL10n(context).adminCenterAwaitingAdminDecision),
                  selected: _showEscalatedReportsOnly,
                  onSelected: _isReportsLoading
                      ? null
                      : (selected) {
                          setState(() {
                            _showEscalatedReportsOnly = selected;
                          });
                          unawaited(_loadReports());
                        },
                ),
              SizedBox(
                width: 190,
                child: DropdownButtonFormField<AdminReportStatus?>(
                  initialValue: _reportStatusFilter,
                  decoration: InputDecoration(
                    labelText: _adminL10n(context).adminCenterStatusLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem<AdminReportStatus?>(
                      value: null,
                      child: Text(_adminL10n(context).adminCenterAllStatuses),
                    ),
                    DropdownMenuItem<AdminReportStatus?>(
                      value: AdminReportStatus.open,
                      child: Text(_adminL10n(context).adminCenterStatusOpen),
                    ),
                    DropdownMenuItem<AdminReportStatus?>(
                      value: AdminReportStatus.inReview,
                      child:
                          Text(_adminL10n(context).adminCenterStatusInReview),
                    ),
                    DropdownMenuItem<AdminReportStatus?>(
                      value: AdminReportStatus.resolved,
                      child:
                          Text(_adminL10n(context).adminCenterStatusResolved),
                    ),
                    DropdownMenuItem<AdminReportStatus?>(
                      value: AdminReportStatus.dismissed,
                      child:
                          Text(_adminL10n(context).adminCenterStatusDismissed),
                    ),
                  ],
                  onChanged: _isReportsLoading || _showEscalatedReportsOnly
                      ? null
                      : (value) {
                          setState(() {
                            _reportStatusFilter = value;
                          });
                          unawaited(_loadReports());
                        },
                ),
              ),
            ],
          ),
        ),
        if (_isReportsLoading && page != null)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(child: _buildReportsResults(context)),
      ],
    );
  }

  Widget _buildReportsResults(BuildContext context) {
    final page = _reportQueuePage;

    if (_isReportsLoading && page == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reportsLoadFailed && page == null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AdminDashboardStateCard(
            icon: Icons.error_outline,
            iconColor: Theme.of(context).colorScheme.error,
            title: _showEscalatedReportsOnly
                ? _adminL10n(context).adminCenterAdminQueueUnavailableTitle
                : _adminL10n(context).adminCenterReportsUnavailableTitle,
            message: _adminL10n(context).adminCenterConnectionTryAgainMessage,
            actionLabel: _adminL10n(context).adminCenterTryAgainAction,
            onAction: () => _loadReports(),
            actionInProgress: _isReportsLoading,
          ),
        ],
      );
    }

    if (page == null) {
      return const SizedBox.shrink();
    }

    if (page.reports.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AdminDashboardStateCard(
            icon: _showEscalatedReportsOnly
                ? Icons.admin_panel_settings_outlined
                : Icons.flag_outlined,
            title: _showEscalatedReportsOnly
                ? _adminL10n(context).adminCenterNoAdminReportsTitle
                : _adminL10n(context).adminCenterNoReportsTitle,
            message: _showEscalatedReportsOnly
                ? _adminL10n(context).adminCenterNoAdminReportsMessage
                : _adminL10n(context).adminCenterNoReportsMessage,
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        key: ValueKey(
          '${_showEscalatedReportsOnly ? 'admin-escalated' : 'standard'}-'
          '${_reportTargetTypeFilter?.storageKey ?? 'all'}-'
          '${_reportStatusFilter?.storageKey ?? 'all'}-${page.offset}',
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        itemCount: page.reports.length + 2,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _AdminReportsResultHeader(
              totalCount: page.totalCount,
              loadFailed: _reportsLoadFailed,
              retryInProgress: _isReportsLoading,
              onRetry: () =>
                  _loadReports(offset: page.offset, markLoading: false),
            );
          }

          if (index <= page.reports.length) {
            final report = page.reports[index - 1];

            return _AdminReportCard(
              report: report,
              onOpenTarget: () => _openReportTarget(report),
              onOpenReportedProfile: report.hasReportedUser
                  ? () => _openReportedProfile(report)
                  : null,
              onRecordDecision: report.canRecordModerationDecision
                  ? () => _openReportDecisionDialog(report)
                  : null,
              onResolveAdminEscalation: widget.currentRole == Role.admin &&
                      report.canResolveAdminEscalation
                  ? () => _openAdminResolutionDialog(report)
                  : null,
              onChangeContentVisibility: report.canChangeContentVisibility
                  ? () => _openReportContentVisibilityDialog(report)
                  : null,
            );
          }

          return _AdminReportsPagination(
            page: page,
            loading: _isReportsLoading,
            onPrevious: page.hasPrevious
                ? () => _loadReports(
                      offset: page.offset >= page.limit
                          ? page.offset - page.limit
                          : 0,
                      markLoading: false,
                    )
                : null,
            onNext: page.hasMore
                ? () => _loadReports(
                      offset: page.offset + page.limit,
                      markLoading: false,
                    )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildUsersSection(BuildContext context) {
    final page = _userSearchPage;

    return Column(
      key: const ValueKey(AdminCenterSection.users),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _userSearchController,
            maxLength: SearchAdminUsers.maximumQueryLength,
            textInputAction: TextInputAction.search,
            onChanged: _onUserSearchChanged,
            onSubmitted: (_) {
              _userSearchDebounce?.cancel();
              unawaited(_loadUsers(page: 1));
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: _adminL10n(context).adminCenterSearchUsersHint,
              counterText: '',
              border: const OutlineInputBorder(),
              suffixIcon: _userSearchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip:
                          _adminL10n(context).adminCenterClearSearchTooltip,
                      onPressed: _clearUserSearch,
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
        ),
        if (_isUsersLoading && page != null)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(child: _buildUsersResults(context)),
      ],
    );
  }

  Widget _buildUsersResults(BuildContext context) {
    final page = _userSearchPage;

    if (_isUsersLoading && page == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_usersLoadFailed && page == null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AdminDashboardStateCard(
            icon: Icons.error_outline,
            iconColor: Theme.of(context).colorScheme.error,
            title: _adminL10n(context).adminCenterUsersUnavailableTitle,
            message: _adminL10n(context).adminCenterConnectionTryAgainMessage,
            actionLabel: _adminL10n(context).adminCenterTryAgainAction,
            onAction: () => _loadUsers(),
            actionInProgress: _isUsersLoading,
          ),
        ],
      );
    }

    if (page == null) {
      return const SizedBox.shrink();
    }

    if (page.users.isEmpty) {
      final hasQuery = _userSearchController.text.trim().isNotEmpty;

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AdminDashboardStateCard(
            icon: hasQuery ? Icons.search_off : Icons.people_outline,
            title: hasQuery
                ? _adminL10n(context).adminCenterNoUsersFoundTitle
                : _adminL10n(context).adminCenterNoUsersTitle,
            message: hasQuery
                ? _adminL10n(context).adminCenterNoUsersFoundMessage
                : _adminL10n(context).adminCenterNoUsersMessage,
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        key: ValueKey('${_userSearchController.text.trim()}-${page.page}'),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        itemCount: page.users.length + 2,
        separatorBuilder: (context, index) {
          if (index == 0 || index == page.users.length) {
            return const SizedBox(height: 12);
          }
          return const SizedBox(height: 8);
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return _AdminUsersResultHeader(
              totalCount: page.totalCount,
              loadFailed: _usersLoadFailed,
              retryInProgress: _isUsersLoading,
              onRetry: () => _loadUsers(page: page.page, markLoading: false),
            );
          }

          if (index <= page.users.length) {
            final user = page.users[index - 1];

            return _AdminUserCard(
              user: user,
              onTap: () => _openUserDetail(user),
            );
          }

          return _AdminUsersPagination(
            page: page,
            loading: _isUsersLoading,
            onPrevious: page.hasPreviousPage
                ? () => _loadUsers(page: page.page - 1, markLoading: false)
                : null,
            onNext: page.hasNextPage
                ? () => _loadUsers(page: page.page + 1, markLoading: false)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildUserDetailSection(BuildContext context) {
    final selectedUser = _selectedUser;
    final detail = _userDetail;

    if (selectedUser == null) {
      return const SizedBox.shrink();
    }

    if (_isUserDetailLoading && detail == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userDetailLoadFailed && detail == null) {
      return ListView(
        key: ValueKey('user-detail-error-${selectedUser.id}'),
        padding: const EdgeInsets.all(16),
        children: [
          _AdminDashboardStateCard(
            icon: Icons.error_outline,
            iconColor: Theme.of(context).colorScheme.error,
            title: _adminL10n(context).adminCenterAccountUnavailableTitle,
            message: _adminL10n(context).adminCenterConnectionTryAgainMessage,
            actionLabel: _adminL10n(context).adminCenterTryAgainAction,
            onAction: () => _loadUserDetail(selectedUser),
            actionInProgress: _isUserDetailLoading,
          ),
        ],
      );
    }

    if (detail == null) {
      return const SizedBox.shrink();
    }

    final email = detail.email?.trim();
    final displayName = detail.displayName?.trim();
    final username = detail.username?.trim();

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        key: ValueKey('user-detail-${detail.id}'),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (_isUserDetailLoading) const LinearProgressIndicator(minHeight: 2),
          if (_userDetailLoadFailed) ...[
            _AdminUserDetailRefreshError(
              retryInProgress: _isUserDetailLoading,
              onRetry: () => _loadUserDetail(selectedUser, markLoading: false),
            ),
            const SizedBox(height: 12),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _closeUserDetail,
              icon: const Icon(Icons.arrow_back),
              label: Text(_adminL10n(context).adminCenterBackToUsersAction),
            ),
          ),
          const SizedBox(height: 4),
          _AdminUserDetailHeader(detail: detail),
          const SizedBox(height: 12),
          _AdminUserDetailSection(
            title: _adminL10n(context).adminCenterPublicIdentitySection,
            children: [
              _AdminUserDetailField(
                icon: Icons.badge_outlined,
                label: _adminL10n(context).adminCenterDisplayNameLabel,
                value: displayName == null || displayName.isEmpty
                    ? _adminL10n(context).adminCenterNotProvided
                    : displayName,
              ),
              _AdminUserDetailField(
                icon: Icons.alternate_email,
                label: _adminL10n(context).adminCenterUsernameLabel,
                value: username == null || username.isEmpty
                    ? _adminL10n(context).adminCenterNotProvided
                    : '@$username',
              ),
              _AdminUserDetailField(
                icon: Icons.fingerprint,
                label: _adminL10n(context).adminCenterUserIdLabel,
                value: detail.id,
                selectable: true,
              ),
              _AdminUserDetailField(
                icon: Icons.account_circle_outlined,
                label: _adminL10n(context).adminCenterIdentityTypeLabel,
                value: _actorTypeLabel(context, detail.actorType),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AdminUserDetailSection(
            title: _adminL10n(context).adminCenterAccountSection,
            children: [
              _AdminUserDetailField(
                icon: Icons.admin_panel_settings_outlined,
                label: _adminL10n(context).adminCenterTechnicalRoleLabel,
                value: _adminRoleLabel(context, detail.systemRole),
              ),
              _AdminUserDetailField(
                icon: Icons.sync_outlined,
                label: _adminL10n(context).adminCenterRoleMirrorLabel,
                value: _adminRoleLabel(context, detail.mirrorRole),
              ),
              _AdminUserDetailField(
                icon: detail.roleSynchronized ? Icons.sync : Icons.sync_problem,
                label: _adminL10n(context).adminCenterRoleSynchronizationLabel,
                value: detail.roleSynchronized
                    ? _adminL10n(context).adminCenterSynchronized
                    : _adminL10n(context).adminCenterNotSynchronized,
                valueColor: detail.roleSynchronized
                    ? null
                    : Theme.of(context).colorScheme.error,
              ),
              _AdminUserDetailField(
                icon: detail.isSuspended
                    ? Icons.person_off_outlined
                    : Icons.person_outline,
                label: _adminL10n(context).adminCenterAccountStatusLabel,
                value: _adminAccountStatusLabel(context, detail.accountStatus),
              ),
              if (detail.suspendedUntil != null)
                _AdminUserDetailField(
                  icon: Icons.event_busy_outlined,
                  label: _adminL10n(context).adminCenterSuspendedUntilLabel,
                  value: _formatDateTime(context, detail.suspendedUntil!),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _AdminUserDetailSection(
            title: _adminL10n(context).adminCenterAccountManagementSection,
            children: [
              _AdminAccountManagementActions(
                isSuspended: detail.isSuspended,
                enabled: detail.canReceiveAdminActions,
                onSuspendPressed: () => _openSuspendAccountDialog(detail),
                onReactivatePressed: () => _openReactivateAccountDialog(detail),
                onForceLogoutPressed: () => _openForceLogoutDialog(detail),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AdminUserDetailSection(
            title: _adminL10n(context).adminCenterDangerZoneSection,
            children: [
              _AdminDeleteAccountAction(
                enabled: detail.canReceiveAdminActions,
                onPressed: () => _openDeleteAccountDialog(detail),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AdminUserDetailSection(
            title: _adminL10n(context).adminCenterRoleManagementSection,
            children: [
              _AdminUserRoleAction(
                currentRole: detail.systemRole,
                enabled: detail.roleSynchronized && !detail.isDeleted,
                onPressed: () => _openChangeRoleDialog(detail),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AdminUserDetailSection(
            title: _adminL10n(context).adminCenterVerificationNavigation,
            children: [
              _AdminUserDetailField(
                icon: Icons.workspace_premium_outlined,
                label: _adminL10n(context).adminCenterVerificationLevelLabel,
                value:
                    _verificationLevelLabel(context, detail.verificationLevel),
              ),
              _AdminUserDetailField(
                icon: Icons.verified_user_outlined,
                label: _adminL10n(context).adminCenterVerificationStatusLabel,
                value: _adminVerificationStatusLabel(
                  context,
                  detail.verificationStatus,
                ),
              ),
              _AdminPublicIdentityAction(
                actorType: detail.actorType,
                verificationLevel: detail.verificationLevel,
                enabled: detail.canReceiveAdminActions,
                onPressed: () => _openPublicIdentityDialog(detail),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AdminUserDetailSection(
            title: _adminL10n(context).adminCenterAccessInformationSection,
            children: [
              _AdminUserDetailField(
                icon: Icons.email_outlined,
                label: _adminL10n(context).adminCenterEmailLabel,
                value: email == null || email.isEmpty
                    ? _adminL10n(context).adminCenterNotAvailable
                    : email,
                selectable: true,
              ),
              _AdminUserDetailField(
                icon: detail.emailConfirmedAt == null
                    ? Icons.mark_email_unread_outlined
                    : Icons.mark_email_read_outlined,
                label: _adminL10n(context).adminCenterEmailConfirmationLabel,
                value: detail.emailConfirmedAt == null
                    ? _adminL10n(context).adminCenterNotConfirmed
                    : _formatDateTime(context, detail.emailConfirmedAt!),
              ),
              _AdminUserDetailField(
                icon: Icons.person_add_alt_outlined,
                label: _adminL10n(context).adminCenterRegisteredLabel,
                value: _formatDateTime(context, detail.createdAt),
              ),
              _AdminUserDetailField(
                icon: Icons.login_outlined,
                label: _adminL10n(context).adminCenterLastAccessLabel,
                value: detail.lastSignInAt == null
                    ? _adminL10n(context).adminCenterNotAvailable
                    : _formatDateTime(context, detail.lastSignInAt!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openAdminGlobeItem(CivicMapItem item) async {
    final targetId = item.targetRef.id.trim();
    if (targetId.isEmpty) {
      return;
    }

    try {
      switch (item.type) {
        case CivicMapItemType.poll:
          await Navigator.of(context).pushNamed(
            AppRouter.pollDetail,
            arguments: targetId,
          );
          return;
        case CivicMapItemType.post:
          await Navigator.of(context).pushNamed(
            AppRouter.socialDetail,
            arguments: targetId,
          );
          return;
        case CivicMapItemType.news:
          final navigator = Navigator.of(context);
          final news = await AppDI.instance.getNewsDetail(EntityId(targetId));
          if (!navigator.mounted) {
            return;
          }
          await navigator.pushNamed(AppRouter.newsDetail, arguments: news);
          return;
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showReportNavigationMessage(
        _adminL10n(context).adminCenterOriginalContentUnavailable,
      );
    }
  }

  String _formatDateTime(BuildContext context, DateTime value) {
    final localValue = value.toLocal();
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatMediumDate(localValue);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(localValue),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    return '$date, $time';
  }

  Widget _buildDashboardIndicators(BuildContext context) {
    final summary = _dashboardSummary;

    if (_isDashboardLoading && summary == null) {
      return _AdminDashboardStateCard(
        progressIndicator: true,
        title: _adminL10n(context).adminCenterLoadingDashboardTitle,
        message: _adminL10n(context).adminCenterLoadingDashboardMessage,
      );
    }

    if (_dashboardLoadFailed && summary == null) {
      return _AdminDashboardStateCard(
        icon: Icons.error_outline,
        iconColor: Theme.of(context).colorScheme.error,
        title: _adminL10n(context).adminCenterDashboardUnavailableTitle,
        message: _adminL10n(context).adminCenterConnectionTryAgainMessage,
        actionLabel: _adminL10n(context).adminCenterTryAgainAction,
        onAction: _refresh,
        actionInProgress: _isRefreshing,
      );
    }

    if (summary == null) {
      return _AdminDashboardStateCard(
        icon: Icons.error_outline,
        iconColor: Theme.of(context).colorScheme.error,
        title: _adminL10n(context).adminCenterDashboardUnavailableTitle,
        message: _adminL10n(context).adminCenterIndicatorsUnavailableMessage,
        actionLabel: _adminL10n(context).adminCenterTryAgainAction,
        onAction: _refresh,
        actionInProgress: _isRefreshing,
      );
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final indicators = <_AdminIndicator>[
      _AdminIndicator(
        label: _adminL10n(context).adminCenterVerificationPendingIndicator,
        value: summary.pendingVerificationRequests,
        icon: Icons.verified_user_outlined,
        section: AdminCenterSection.verification,
      ),
      _AdminIndicator(
        label: _adminL10n(context).adminCenterOpenReportsIndicator,
        value: summary.openReports,
        icon: Icons.flag_outlined,
        section: AdminCenterSection.reports,
      ),
      _AdminIndicator(
        label: _adminL10n(context).adminCenterSuspendedAccountsIndicator,
        value: summary.suspendedAccounts,
        icon: Icons.person_off_outlined,
        section:
            widget.currentRole == Role.admin ? AdminCenterSection.users : null,
      ),
      _AdminIndicator(
        label: _adminL10n(context).adminCenterUsersNavigation,
        value: summary.totalUsers,
        icon: Icons.people_outline,
        section:
            widget.currentRole == Role.admin ? AdminCenterSection.users : null,
      ),
      _AdminIndicator(
        label: _adminL10n(context).adminCenterStaffIndicator,
        value: summary.staffUsers,
        icon: Icons.admin_panel_settings_outlined,
      ),
    ];

    final operationalMetrics = <({
      String label,
      int last24Hours,
      int last7Days,
      IconData icon,
    })>[
      (
        label: _adminL10n(context).adminCenterRecentSignInsMetric,
        last24Hours: summary.recentSignIns24h,
        last7Days: summary.recentSignIns7d,
        icon: Icons.login_rounded,
      ),
      (
        label: _adminL10n(context).adminCenterNewUsersMetric,
        last24Hours: summary.newUsers24h,
        last7Days: summary.newUsers7d,
        icon: Icons.person_add_alt_1_outlined,
      ),
      (
        label: _adminL10n(context).adminCenterPollsCreatedMetric,
        last24Hours: summary.pollsCreated24h,
        last7Days: summary.pollsCreated7d,
        icon: Icons.poll_outlined,
      ),
      (
        label: _adminL10n(context).adminCenterPostsCreatedMetric,
        last24Hours: summary.postsCreated24h,
        last7Days: summary.postsCreated7d,
        icon: Icons.forum_outlined,
      ),
      (
        label: _adminL10n(context).adminCenterAdminActionsMetric,
        last24Hours: summary.adminActions24h,
        last7Days: summary.adminActions7d,
        icon: Icons.admin_panel_settings_outlined,
      ),
    ];

    final hasPendingWork =
        summary.pendingWork > 0 || summary.suspendedAccounts > 0;

    Color indicatorAccent(int index) {
      return switch (index) {
        0 => colors.tertiary,
        1 => colors.error,
        2 => colors.secondary,
        _ => colors.primary,
      };
    }

    Widget buildPriorityCard(
      _AdminIndicator indicator,
      int index, {
      double? width,
      double? height,
    }) {
      final accent = indicatorAccent(index);

      return SizedBox(
        width: width,
        height: height,
        child: Material(
          color: colors.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: indicator.section == null
                ? null
                : () => _selectSection(indicator.section!),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: accent.withValues(alpha: 0.24)),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Icon(indicator.icon, size: 20, color: accent),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${indicator.value}',
                            maxLines: 1,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            indicator.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (indicator.section != null)
                      Icon(
                        Icons.north_east_rounded,
                        size: 16,
                        color: accent.withValues(alpha: 0.78),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget buildPriorityGrid(double width) {
      final columns = switch (width) {
        >= 1120 => 5,
        >= 720 => 3,
        >= 480 => 2,
        _ => 1,
      };

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: 78,
        ),
        itemCount: indicators.length,
        itemBuilder: (context, index) {
          return buildPriorityCard(indicators[index], index);
        },
      );
    }

    Widget buildOperationalMetricCard(int index) {
      final metric = operationalMetrics[index];
      final accent = index == 0 ? colors.tertiary : colors.primary;

      return DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.66),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Icon(metric.icon, size: 19, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _AdminOperationalValue(
                            label:
                                _adminL10n(context).adminCenterLast24HoursLabel,
                            value: metric.last24Hours,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _AdminOperationalValue(
                            label:
                                _adminL10n(context).adminCenterLast7DaysLabel,
                            value: metric.last7Days,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildOperationalPanel(double width) {
      final columns = width >= 460 ? 2 : 1;

      return DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.65),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.monitor_heart_outlined,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _adminL10n(context)
                              .adminCenterOperationalActivityTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _adminL10n(context)
                              .adminCenterOperationalActivitySubtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 96,
                ),
                itemCount: operationalMetrics.length,
                itemBuilder: (context, index) {
                  return buildOperationalMetricCard(index);
                },
              ),
            ],
          ),
        ),
      );
    }

    Widget buildGlobe(double size) {
      return SizedBox.square(
        dimension: size,
        child: WorldGlobeWidget(
          items: _adminGlobeController.visibleItems,
          interactionProfile: WorldGlobeInteractionProfile.home,
          onItemTap: (item) {
            unawaited(_openAdminGlobeItem(item));
          },
          onUseClassicMap: () {
            unawaited(Navigator.of(context).pushNamed(AppRouter.civicMap));
          },
        ),
      );
    }

    Widget buildGlobePanel(double width) {
      final markerCount = _adminGlobeController.visibleItems.length;
      final globeSize = width < 380 ? width - 20 : 360.0;

      return DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.65),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.public_rounded, color: colors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'World · $markerCount marker',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: _adminL10n(context).adminCenterDashboardNavigation,
                    onPressed: () {
                      unawaited(
                        Navigator.of(context).pushNamed(AppRouter.civicMap),
                      );
                    },
                    icon: const Icon(Icons.open_in_full_rounded),
                  ),
                ],
              ),
              if (_adminGlobeController.isLoading ||
                  _adminGlobeController.isRefreshing)
                const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: Center(
                  child: buildGlobe(globeSize),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildCommandDeck(double width) {
      final isWide = width >= 980;

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.surfaceContainerHighest.withValues(alpha: 0.72),
              colors.surface.withValues(alpha: 0.95),
              colors.primaryContainer.withValues(alpha: 0.34),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.72),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.admin_panel_settings_rounded,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _adminL10n(context).adminCenterTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _adminRoleLabel(context, widget.currentRole),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.66),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: hasPendingWork
                          ? colors.errorContainer
                          : colors.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      hasPendingWork
                          ? '${summary.pendingWork + summary.suspendedAccounts}'
                          : _adminL10n(context).adminCenterNoPendingWorkTitle,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: hasPendingWork
                            ? colors.onErrorContainer
                            : colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, innerConstraints) {
                  return buildPriorityGrid(innerConstraints.maxWidth);
                },
              ),
              const SizedBox(height: 14),
              if (isWide)
                SizedBox(
                  height: 430,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 10,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return buildOperationalPanel(constraints.maxWidth);
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 11,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return buildGlobePanel(constraints.maxWidth);
                          },
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      height: width < 520 ? 360 : 392,
                      child: buildGlobePanel(constraints.maxWidth),
                    );
                  },
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return buildOperationalPanel(constraints.maxWidth);
                  },
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_dashboardLoadFailed) ...[
          _AdminDashboardRefreshError(
            retryInProgress: _isRefreshing,
            onRetry: _refresh,
          ),
          const SizedBox(height: 12),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            return buildCommandDeck(constraints.maxWidth);
          },
        ),
        const SizedBox(height: 18),
        _buildDashboardShortcuts(context),
      ],
    );
  }

  Widget _buildDashboardShortcuts(BuildContext context) {
    final destinations = _destinations
        .where(
          (destination) => destination.section != AdminCenterSection.dashboard,
        )
        .toList(growable: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = switch (constraints.maxWidth) {
          < 380 => 1,
          < 760 => 2,
          _ => destinations.length > 4 ? 4 : destinations.length,
        };

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 88,
          ),
          itemCount: destinations.length,
          itemBuilder: (context, index) {
            final destination = destinations[index];

            return Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _selectSection(destination.section),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        destination.icon,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          destination.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDesktopDashboard(BuildContext context) {
    return CustomScrollView(
      key: const ValueKey(AdminCenterSection.dashboard),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(child: _buildDashboardIndicators(context)),
        ),
      ],
    );
  }

  Widget _buildMobileDashboard(BuildContext context) {
    return CustomScrollView(
      key: const ValueKey(AdminCenterSection.dashboard),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(child: _buildDashboardIndicators(context)),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    if (_selectedSection == AdminCenterSection.dashboard) {
      return _buildMobileDashboard(context);
    }

    return _buildSelectedContent(context);
  }

  Widget _buildDesktopLayout(BuildContext context, {required bool extendRail}) {
    final destinations = _destinations;
    final selectedIndex = destinations.indexWhere(
      (destination) => destination.section == _selectedSection,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NavigationRail(
          extended: extendRail,
          selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
          groupAlignment: -1,
          onDestinationSelected: (index) {
            _selectSection(destinations[index].section);
          },
          destinations: [
            for (final destination in destinations)
              NavigationRailDestination(
                icon: Icon(destination.icon),
                selectedIcon: Icon(destination.selectedIcon),
                label: Text(destination.label),
              ),
          ],
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(child: _buildSelectedContent(context)),
      ],
    );
  }

  Widget _buildAdminCenterScaffold(BuildContext context) {
    final materialLocalizations = MaterialLocalizations.of(context);
    final isMobileLayout =
        MediaQuery.sizeOf(context).width < _desktopBreakpoint;
    final showingUserDetail =
        _selectedSection == AdminCenterSection.users && _selectedUser != null;
    final currentDestination = _destinations.firstWhere(
      (destination) => destination.section == _selectedSection,
      orElse: () => _destinations.first,
    );

    return Scaffold(
      appBar: AppBar(
        leading: showingUserDetail ||
                (isMobileLayout &&
                    _selectedSection != AdminCenterSection.dashboard)
            ? IconButton(
                tooltip: materialLocalizations.backButtonTooltip,
                onPressed: () {
                  if (showingUserDetail) {
                    _closeUserDetail();
                  } else {
                    _selectSection(AdminCenterSection.dashboard);
                  }
                },
                icon: const Icon(Icons.arrow_back),
              )
            : null,
        title: Text(
          showingUserDetail
              ? _adminL10n(context).adminCenterAccountDetailsTitle
              : isMobileLayout &&
                      _selectedSection != AdminCenterSection.dashboard
                  ? currentDestination.label
                  : _adminL10n(context).adminCenterTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (!isMobileLayout) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Chip(
                avatar: const Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 18,
                ),
                label: Text(_adminRoleLabel(context, widget.currentRole)),
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 4),
          ],
          _buildLanguageSelector(),
          const SizedBox(width: 4),
          if (_isRefreshing ||
              (_selectedSection == AdminCenterSection.dashboard &&
                  _isDashboardLoading &&
                  _dashboardSummary == null) ||
              (_selectedSection == AdminCenterSection.users &&
                  (showingUserDetail
                      ? _isUserDetailLoading && _userDetail == null
                      : _isUsersLoading && _userSearchPage == null)) ||
              (_selectedSection == AdminCenterSection.reports &&
                  _isReportsLoading &&
                  _reportQueuePage == null))
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              tooltip: materialLocalizations.refreshIndicatorSemanticLabel,
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < _desktopBreakpoint) {
              return _buildMobileLayout(context);
            }

            return _buildDesktopLayout(
              context,
              extendRail: constraints.maxWidth >= _extendedRailBreakpoint,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = _adminLocaleOverride;

    if (locale == null) {
      return _buildAdminCenterScaffold(context);
    }

    return Localizations.override(
      context: context,
      locale: locale,
      child: Builder(builder: _buildAdminCenterScaffold),
    );
  }
}

class _AdminSectionState extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool actionInProgress;

  const _AdminSectionState({
    required this.icon,
    this.iconColor,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.actionInProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 42,
              color:
                  iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: actionInProgress ? null : onAction,
                child: actionInProgress
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AdminDestination {
  final AdminCenterSection section;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  _AdminDestination({
    required this.section,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class _AdminIndicator {
  final String label;
  final int value;
  final IconData icon;
  final AdminCenterSection? section;

  const _AdminIndicator({
    required this.label,
    required this.value,
    required this.icon,
    this.section,
  });
}

class _AdminOperationalValue extends StatelessWidget {
  final String label;
  final int value;

  const _AdminOperationalValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.textTheme.labelSmall?.color?.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }
}

class _AdminOrbitPainter extends CustomPainter {
  final Color color;

  const _AdminOrbitPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final shortest = size.shortestSide;
    for (final factor in <double>[0.46, 0.62, 0.78]) {
      canvas.drawCircle(center, shortest * factor / 2, paint);
    }

    final axisPaint = Paint()
      ..color = color.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(center.dx, 28),
      Offset(center.dx, size.height - 28),
      axisPaint,
    );
    canvas.drawLine(
      Offset(28, center.dy),
      Offset(size.width - 28, center.dy),
      axisPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AdminOrbitPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _AdminUsersResultHeader extends StatelessWidget {
  final int totalCount;
  final bool loadFailed;
  final bool retryInProgress;
  final Future<void> Function() onRetry;

  const _AdminUsersResultHeader({
    required this.totalCount,
    required this.loadFailed,
    required this.retryInProgress,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _adminL10n(context).adminCenterUsersCount(totalCount),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (loadFailed) ...[
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _adminL10n(context).adminCenterCouldNotUpdateUsers,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: retryInProgress
                        ? null
                        : () {
                            unawaited(onRetry());
                          },
                    child: Text(_adminL10n(context).adminCenterRetryAction),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AdminUserCard extends StatelessWidget {
  final AdminUserSummary user;
  final VoidCallback onTap;

  const _AdminUserCard({required this.user, required this.onTap});

  String _title(BuildContext context) {
    final displayName = user.displayName?.trim();

    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final username = user.username?.trim();

    if (username != null && username.isNotEmpty) {
      return username;
    }

    return _adminL10n(context).adminCenterUnnamedUser;
  }

  String _avatarLabel(BuildContext context) {
    final value = _title(context).trim();
    return value.isEmpty ? '?' : value.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final username = user.username?.trim();

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(child: Text(_avatarLabel(context))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (username != null && username.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '@$username',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _AdminUserAttribute(
                          icon: Icons.admin_panel_settings_outlined,
                          label: _adminRoleLabel(context, user.systemRole),
                        ),
                        _AdminUserAttribute(
                          icon: user.isSuspended
                              ? Icons.person_off_outlined
                              : Icons.person_outline,
                          label: _adminAccountStatusLabel(
                              context, user.accountStatus),
                        ),
                        if (!user.roleSynchronized)
                          _AdminUserAttribute(
                            icon: Icons.sync_problem,
                            label: _adminL10n(context)
                                .adminCenterRoleNotSynchronized,
                            color: theme.colorScheme.error,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminUserDetailHeader extends StatelessWidget {
  final AdminUserDetail detail;

  const _AdminUserDetailHeader({required this.detail});

  String _title(BuildContext context) {
    final displayName = detail.displayName?.trim();

    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final username = detail.username?.trim();

    if (username != null && username.isNotEmpty) {
      return username;
    }

    return _adminL10n(context).adminCenterUnnamedUser;
  }

  String _avatarLabel(BuildContext context) {
    final value = _title(context).trim();
    return value.isEmpty ? '?' : value.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final username = detail.username?.trim();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              child: Text(_avatarLabel(context),
                  style: theme.textTheme.titleLarge),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (username != null && username.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '@$username',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _AdminUserAttribute(
                        icon: Icons.admin_panel_settings_outlined,
                        label: _adminRoleLabel(context, detail.systemRole),
                      ),
                      _AdminUserAttribute(
                        icon: detail.isSuspended
                            ? Icons.person_off_outlined
                            : Icons.person_outline,
                        label: _adminAccountStatusLabel(
                            context, detail.accountStatus),
                      ),
                      if (!detail.roleSynchronized)
                        _AdminUserAttribute(
                          icon: Icons.sync_problem,
                          label: _adminL10n(context)
                              .adminCenterRoleNotSynchronized,
                          color: theme.colorScheme.error,
                        ),
                    ],
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

class _AdminUserDetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _AdminUserDetailSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            for (var index = 0; index < children.length; index++) ...[
              if (index > 0) const Divider(height: 1),
              children[index],
            ],
          ],
        ),
      ),
    );
  }
}

class _AdminUserDetailField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool selectable;
  final Color? valueColor;

  const _AdminUserDetailField({
    required this.icon,
    required this.label,
    required this.value,
    this.selectable = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
      color: valueColor,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                if (selectable)
                  SelectableText(value, style: valueStyle)
                else
                  Text(value, style: valueStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminAccountManagementActions extends StatelessWidget {
  final bool isSuspended;
  final bool enabled;
  final Future<void> Function() onSuspendPressed;
  final Future<void> Function() onReactivatePressed;
  final Future<void> Function() onForceLogoutPressed;

  const _AdminAccountManagementActions({
    required this.isSuspended,
    required this.enabled,
    required this.onSuspendPressed,
    required this.onReactivatePressed,
    required this.onForceLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _adminL10n(context).adminCenterTemporarySuspensionTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isSuspended
                ? _adminL10n(context).adminCenterReactivateDescription
                : enabled
                    ? _adminL10n(context).adminCenterSuspendDescription
                    : _adminL10n(context)
                        .adminCenterSuspensionUnavailableDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: enabled
                  ? () {
                      unawaited(
                        isSuspended
                            ? onReactivatePressed()
                            : onSuspendPressed(),
                      );
                    }
                  : null,
              icon: Icon(
                isSuspended ? Icons.person_outline : Icons.person_off_outlined,
              ),
              label: Text(
                isSuspended
                    ? _adminL10n(context).adminCenterReactivateAccountAction
                    : _adminL10n(context).adminCenterSuspendAccountAction,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 12),
          Text(
            _adminL10n(context).adminCenterForceLogoutAction,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isSuspended
                ? _adminL10n(context).adminCenterSuspendedForceLogoutDescription
                : enabled
                    ? _adminL10n(context).adminCenterForceLogoutDescription
                    : _adminL10n(context)
                        .adminCenterForceLogoutUnavailableDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: enabled && !isSuspended
                  ? () {
                      unawaited(onForceLogoutPressed());
                    }
                  : null,
              icon: const Icon(Icons.logout),
              label: Text(_adminL10n(context).adminCenterForceLogoutAction),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminDeleteAccountAction extends StatelessWidget {
  final bool enabled;
  final Future<void> Function() onPressed;

  const _AdminDeleteAccountAction({
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _adminL10n(context).adminCenterPermanentDeletionTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            enabled
                ? _adminL10n(context).adminCenterPermanentDeletionDescription
                : _adminL10n(context).adminCenterDeletionUnavailableDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              onPressed: enabled
                  ? () {
                      unawaited(onPressed());
                    }
                  : null,
              icon: const Icon(Icons.delete_forever_outlined),
              label: Text(_adminL10n(context)
                  .adminCenterDeleteAccountPermanentlyAction),
            ),
          ),
        ],
      ),
    );
  }
}

String _adminSuspensionDurationLabel(
  BuildContext context,
  _AdminSuspensionDuration duration,
) {
  final l10n = _adminL10n(context);
  switch (duration) {
    case _AdminSuspensionDuration.oneHour:
      return l10n.adminCenterDurationOneHour;
    case _AdminSuspensionDuration.oneDay:
      return l10n.adminCenterDurationOneDay;
    case _AdminSuspensionDuration.sevenDays:
      return l10n.adminCenterDurationSevenDays;
    case _AdminSuspensionDuration.thirtyDays:
      return l10n.adminCenterDurationThirtyDays;
  }
}

Duration _adminSuspensionDurationValue(_AdminSuspensionDuration duration) {
  switch (duration) {
    case _AdminSuspensionDuration.oneHour:
      return const Duration(hours: 1);
    case _AdminSuspensionDuration.oneDay:
      return const Duration(days: 1);
    case _AdminSuspensionDuration.sevenDays:
      return const Duration(days: 7);
    case _AdminSuspensionDuration.thirtyDays:
      return const Duration(days: 30);
  }
}

enum _AdminSuspensionDuration {
  oneHour,
  oneDay,
  sevenDays,
  thirtyDays,
}

class _AdminSuspendAccountDialog extends StatefulWidget {
  final AdminUserDetail detail;
  final Future<void> Function({
    required DateTime suspendedUntil,
    required String reason,
  }) onConfirm;

  const _AdminSuspendAccountDialog({
    required this.detail,
    required this.onConfirm,
  });

  @override
  State<_AdminSuspendAccountDialog> createState() =>
      _AdminSuspendAccountDialogState();
}

class _AdminSuspendAccountDialogState
    extends State<_AdminSuspendAccountDialog> {
  static const int _maximumReasonLength = 1000;

  final TextEditingController _reasonController = TextEditingController();
  _AdminSuspensionDuration _selectedDuration = _AdminSuspensionDuration.oneDay;
  late DateTime _suspendedUntil;
  bool _confirmed = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _canSubmit {
    final reason = _reasonController.text.trim();

    return !_isSubmitting &&
        reason.isNotEmpty &&
        reason.length <= _maximumReasonLength &&
        _suspendedUntil.isAfter(DateTime.now().toUtc()) &&
        _confirmed;
  }

  String get _accountLabel {
    final displayName = widget.detail.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final username = widget.detail.username?.trim();
    if (username != null && username.isNotEmpty) {
      return '@$username';
    }

    final email = widget.detail.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }

    return widget.detail.id;
  }

  @override
  void initState() {
    super.initState();
    _updateSuspendedUntil();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _updateSuspendedUntil() {
    _suspendedUntil = DateTime.now().toUtc().add(
          _adminSuspensionDurationValue(_selectedDuration),
        );
  }

  void _clearConfirmation() {
    _confirmed = false;
    _errorMessage = null;
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.onConfirm(
        suspendedUntil: _suspendedUntil,
        reason: _reasonController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(_suspendedUntil);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _errorMessage = _adminL10n(context).adminCenterSuspendFailure;
      });
    }
  }

  String _formatDateTime(BuildContext context, DateTime value) {
    final localValue = value.toLocal();
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatMediumDate(localValue);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(localValue),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    return '$date, $time';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      scrollable: true,
      title: Text(_adminL10n(context).adminCenterSuspendAccountAction),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _adminL10n(context).adminCenterAccountValue(_accountLabel),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _adminL10n(context).adminCenterSuspendImmediateEffect,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<_AdminSuspensionDuration>(
              initialValue: _selectedDuration,
              decoration: InputDecoration(
                labelText: _adminL10n(context).adminCenterDurationLabel,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final duration in _AdminSuspensionDuration.values)
                  DropdownMenuItem<_AdminSuspensionDuration>(
                    value: duration,
                    child: Text(
                      _adminSuspensionDurationLabel(context, duration),
                    ),
                  ),
              ],
              onChanged: _isSubmitting
                  ? null
                  : (duration) {
                      if (duration == null) {
                        return;
                      }

                      setState(() {
                        _selectedDuration = duration;
                        _updateSuspendedUntil();
                        _clearConfirmation();
                      });
                    },
            ),
            const SizedBox(height: 12),
            _AdminUserAttribute(
              icon: Icons.event_busy_outlined,
              label: _adminL10n(context).adminCenterSuspendedUntilValue(
                _formatDateTime(context, _suspendedUntil),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              enabled: !_isSubmitting,
              minLines: 2,
              maxLines: 4,
              maxLength: _maximumReasonLength,
              decoration: InputDecoration(
                labelText: _adminL10n(context).adminCenterReasonLabel,
                hintText: _adminL10n(context).adminCenterSuspendReasonHint,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(_clearConfirmation);
              },
            ),
            CheckboxListTile(
              value: _confirmed,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                _adminL10n(context).adminCenterSuspendConfirmation(
                  _formatDateTime(context, _suspendedUntil),
                ),
              ),
              onChanged: _isSubmitting || _reasonController.text.trim().isEmpty
                  ? null
                  : (value) {
                      setState(() {
                        _confirmed = value ?? false;
                        _errorMessage = null;
                      });
                    },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: Text(_adminL10n(context).commonCancelButton),
        ),
        FilledButton(
          onPressed: _canSubmit ? _submit : null,
          child: _isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_adminL10n(context).adminCenterSuspendAccountAction),
        ),
      ],
    );
  }
}

class _AdminAccountActionDialog extends StatefulWidget {
  final AdminUserDetail detail;
  final String title;
  final String description;
  final String reasonHint;
  final String confirmationText;
  final String submitLabel;
  final String failureMessage;
  final Future<void> Function({required String reason}) onConfirm;

  const _AdminAccountActionDialog({
    required this.detail,
    required this.title,
    required this.description,
    required this.reasonHint,
    required this.confirmationText,
    required this.submitLabel,
    required this.failureMessage,
    required this.onConfirm,
  });

  @override
  State<_AdminAccountActionDialog> createState() =>
      _AdminAccountActionDialogState();
}

class _AdminAccountActionDialogState extends State<_AdminAccountActionDialog> {
  static const int _maximumReasonLength = 1000;

  final TextEditingController _reasonController = TextEditingController();
  bool _confirmed = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _canSubmit {
    final reason = _reasonController.text.trim();

    return !_isSubmitting &&
        reason.isNotEmpty &&
        reason.length <= _maximumReasonLength &&
        _confirmed;
  }

  String get _accountLabel {
    final displayName = widget.detail.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final username = widget.detail.username?.trim();
    if (username != null && username.isNotEmpty) {
      return '@$username';
    }

    final email = widget.detail.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }

    return widget.detail.id;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.onConfirm(reason: _reasonController.text.trim());

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _errorMessage = widget.failureMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      scrollable: true,
      title: Text(widget.title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _adminL10n(context).adminCenterAccountValue(_accountLabel),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              enabled: !_isSubmitting,
              minLines: 2,
              maxLines: 4,
              maxLength: _maximumReasonLength,
              decoration: InputDecoration(
                labelText: _adminL10n(context).adminCenterReasonLabel,
                hintText: widget.reasonHint,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(() {
                  _confirmed = false;
                  _errorMessage = null;
                });
              },
            ),
            CheckboxListTile(
              value: _confirmed,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(widget.confirmationText),
              onChanged: _isSubmitting || _reasonController.text.trim().isEmpty
                  ? null
                  : (value) {
                      setState(() {
                        _confirmed = value ?? false;
                        _errorMessage = null;
                      });
                    },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  Navigator.of(context).pop(false);
                },
          child: Text(_adminL10n(context).commonCancelButton),
        ),
        FilledButton(
          onPressed: _canSubmit ? _submit : null,
          child: _isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.submitLabel),
        ),
      ],
    );
  }
}

class _AdminDeleteAccountDialog extends StatefulWidget {
  final AdminUserDetail detail;
  final Future<void> Function({
    required String reason,
    required String confirmation,
    required String accountIdentifier,
  }) onConfirm;

  const _AdminDeleteAccountDialog({
    required this.detail,
    required this.onConfirm,
  });

  @override
  State<_AdminDeleteAccountDialog> createState() =>
      _AdminDeleteAccountDialogState();
}

class _AdminDeleteAccountDialogState extends State<_AdminDeleteAccountDialog> {
  static const int _maximumReasonLength = 1000;

  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _confirmationController = TextEditingController();
  final TextEditingController _accountIdentifierController =
      TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _canSubmit {
    final reason = _reasonController.text.trim();
    final confirmation = _confirmationController.text;
    final accountIdentifier =
        _accountIdentifierController.text.trim().toLowerCase();

    return !_isSubmitting &&
        reason.isNotEmpty &&
        reason.length <= _maximumReasonLength &&
        confirmation == 'DELETE' &&
        accountIdentifier == widget.detail.id.toLowerCase();
  }

  String get _accountLabel {
    final displayName = widget.detail.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final username = widget.detail.username?.trim();
    if (username != null && username.isNotEmpty) {
      return '@$username';
    }

    final email = widget.detail.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }

    return widget.detail.id;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _confirmationController.dispose();
    _accountIdentifierController.dispose();
    super.dispose();
  }

  void _onInputChanged(String _) {
    setState(() {
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.onConfirm(
        reason: _reasonController.text.trim(),
        confirmation: _confirmationController.text,
        accountIdentifier: _accountIdentifierController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _errorMessage = _adminL10n(context).adminCenterDeleteFailure;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      scrollable: true,
      title: Text(
        _adminL10n(context).adminCenterDeleteAccountPermanentlyAction,
        style: TextStyle(color: theme.colorScheme.error),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _adminL10n(context).adminCenterAccountValue(_accountLabel),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _adminL10n(context).adminCenterDeleteIrreversibleWarning,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              enabled: !_isSubmitting,
              minLines: 2,
              maxLines: 4,
              maxLength: _maximumReasonLength,
              decoration: InputDecoration(
                labelText: _adminL10n(context).adminCenterReasonLabel,
                hintText: _adminL10n(context).adminCenterDeleteReasonHint,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
              onChanged: _onInputChanged,
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _confirmationController,
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                labelText: _adminL10n(context).adminCenterTypeDeleteLabel,
                border: const OutlineInputBorder(),
              ),
              autocorrect: false,
              enableSuggestions: false,
              onChanged: _onInputChanged,
            ),
            const SizedBox(height: 12),
            SelectableText(
              _adminL10n(context).adminCenterAccountIdValue(widget.detail.id),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _accountIdentifierController,
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                labelText: _adminL10n(context).adminCenterTypeAccountIdLabel,
                border: const OutlineInputBorder(),
              ),
              autocorrect: false,
              enableSuggestions: false,
              onChanged: _onInputChanged,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  Navigator.of(context).pop(false);
                },
          child: Text(_adminL10n(context).commonCancelButton),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: _canSubmit ? _submit : null,
          child: _isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_adminL10n(context).adminCenterDeletePermanentlyAction),
        ),
      ],
    );
  }
}

class _AdminUserRoleAction extends StatelessWidget {
  final Role currentRole;
  final bool enabled;
  final Future<void> Function() onPressed;

  const _AdminUserRoleAction({
    required this.currentRole,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _adminL10n(context).adminCenterChangeTechnicalRoleTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            enabled
                ? _adminL10n(context).adminCenterChangeRoleDescription
                : _adminL10n(context)
                    .adminCenterChangeRoleUnavailableDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _AdminUserAttribute(
                icon: Icons.admin_panel_settings_outlined,
                label: _adminL10n(context).adminCenterCurrentRoleValue(
                  _adminRoleLabel(context, currentRole),
                ),
              ),
              FilledButton.icon(
                onPressed: enabled
                    ? () {
                        unawaited(onPressed());
                      }
                    : null,
                icon: const Icon(Icons.swap_horiz),
                label: Text(_adminL10n(context).adminCenterChangeRoleAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminPublicIdentitySelection {
  final ActorType actorType;
  final VerificationLevel verificationLevel;

  const _AdminPublicIdentitySelection({
    required this.actorType,
    required this.verificationLevel,
  });
}

class _AdminPublicIdentityAction extends StatelessWidget {
  final ActorType actorType;
  final VerificationLevel verificationLevel;
  final bool enabled;
  final Future<void> Function() onPressed;

  const _AdminPublicIdentityAction({
    required this.actorType,
    required this.verificationLevel,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _adminL10n(context).adminCenterChangePublicIdentityTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            enabled
                ? _adminL10n(context).adminCenterChangeIdentityDescription
                : _adminL10n(context)
                    .adminCenterChangeIdentityUnavailableDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _AdminUserAttribute(
                icon: Icons.badge_outlined,
                label: _actorTypeLabel(context, actorType),
              ),
              _AdminUserAttribute(
                icon: Icons.workspace_premium_outlined,
                label: _verificationLevelLabel(context, verificationLevel),
              ),
              FilledButton.icon(
                onPressed: enabled
                    ? () {
                        unawaited(onPressed());
                      }
                    : null,
                icon: const Icon(Icons.manage_accounts_outlined),
                label:
                    Text(_adminL10n(context).adminCenterChangeIdentityAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminPublicIdentityDialog extends StatefulWidget {
  final AdminUserDetail detail;
  final Future<void> Function({
    required ActorType actorType,
    required VerificationLevel verificationLevel,
    required String reason,
  }) onConfirm;

  const _AdminPublicIdentityDialog({
    required this.detail,
    required this.onConfirm,
  });

  @override
  State<_AdminPublicIdentityDialog> createState() =>
      _AdminPublicIdentityDialogState();
}

class _AdminPublicIdentityDialogState
    extends State<_AdminPublicIdentityDialog> {
  final TextEditingController _reasonController = TextEditingController();
  late ActorType _selectedActorType;
  late VerificationLevel _selectedVerificationLevel;
  bool _confirmed = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _hasChanged {
    return _selectedActorType != widget.detail.actorType ||
        _selectedVerificationLevel != widget.detail.verificationLevel;
  }

  bool get _canSubmit {
    return !_isSubmitting &&
        _hasChanged &&
        _reasonController.text.trim().isNotEmpty &&
        _confirmed;
  }

  @override
  void initState() {
    super.initState();
    _selectedActorType = widget.detail.actorType;
    _selectedVerificationLevel = widget.detail.actorType == ActorType.citizen
        ? widget.detail.verificationLevel
        : VerificationLevel.none;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.onConfirm(
        actorType: _selectedActorType,
        verificationLevel: _selectedVerificationLevel,
        reason: _reasonController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(
        _AdminPublicIdentitySelection(
          actorType: _selectedActorType,
          verificationLevel: _selectedVerificationLevel,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _errorMessage = _adminL10n(context).adminCenterIdentityChangeFailure;
      });
    }
  }

  void _clearConfirmation() {
    _confirmed = false;
    _errorMessage = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPerson = _selectedActorType == ActorType.citizen;

    return AlertDialog(
      scrollable: true,
      title: Text(_adminL10n(context).adminCenterChangePublicIdentityTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _adminL10n(context).adminCenterChoosePublicIdentityMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ActorType>(
              initialValue: _selectedActorType,
              decoration: InputDecoration(
                labelText:
                    _adminL10n(context).adminCenterPublicAccountTypeLabel,
                border: const OutlineInputBorder(),
              ),
              isExpanded: true,
              items: [
                for (final actorType in ActorType.values)
                  DropdownMenuItem<ActorType>(
                    value: actorType,
                    child: Text(_actorTypeLabel(context, actorType)),
                  ),
              ],
              onChanged: _isSubmitting
                  ? null
                  : (actorType) {
                      if (actorType == null) {
                        return;
                      }

                      setState(() {
                        _selectedActorType = actorType;
                        if (actorType != ActorType.citizen) {
                          _selectedVerificationLevel = VerificationLevel.none;
                        }
                        _clearConfirmation();
                      });
                    },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<VerificationLevel>(
              key: ValueKey(_selectedVerificationLevel),
              initialValue: _selectedVerificationLevel,
              decoration: InputDecoration(
                labelText:
                    _adminL10n(context).adminCenterVerificationLevelLabel,
                helperText: isPerson
                    ? _adminL10n(context).adminCenterPersonVerificationHelper
                    : _adminL10n(context)
                        .adminCenterNonPersonVerificationHelper,
                border: const OutlineInputBorder(),
              ),
              isExpanded: true,
              items: [
                for (final level in VerificationLevel.values)
                  DropdownMenuItem<VerificationLevel>(
                    value: level,
                    child: Text(_verificationLevelLabel(context, level)),
                  ),
              ],
              onChanged: _isSubmitting || !isPerson
                  ? null
                  : (level) {
                      if (level == null) {
                        return;
                      }

                      setState(() {
                        _selectedVerificationLevel = level;
                        _clearConfirmation();
                      });
                    },
            ),
            const SizedBox(height: 16),
            _AdminIdentitySummaryCard(
              label: _adminL10n(context).adminCenterBeforeLabel,
              actorType: widget.detail.actorType,
              verificationLevel: widget.detail.verificationLevel,
              icon: Icons.history,
            ),
            const SizedBox(height: 8),
            _AdminIdentitySummaryCard(
              label: _adminL10n(context).adminCenterAfterLabel,
              actorType: _selectedActorType,
              verificationLevel: _selectedVerificationLevel,
              icon: Icons.arrow_forward,
              emphasized: _hasChanged,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              enabled: !_isSubmitting,
              minLines: 2,
              maxLines: 4,
              maxLength: SetAdminPublicIdentity.maximumReasonLength,
              decoration: InputDecoration(
                labelText: _adminL10n(context).adminCenterReasonLabel,
                hintText: _adminL10n(context).adminCenterIdentityReasonHint,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(_clearConfirmation);
              },
            ),
            CheckboxListTile(
              value: _confirmed,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                _adminL10n(context).adminCenterIdentityConfirmation,
              ),
              onChanged: _isSubmitting ||
                      !_hasChanged ||
                      _reasonController.text.trim().isEmpty
                  ? null
                  : (value) {
                      setState(() {
                        _confirmed = value ?? false;
                        _errorMessage = null;
                      });
                    },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: Text(_adminL10n(context).commonCancelButton),
        ),
        FilledButton(
          onPressed: _canSubmit ? _submit : null,
          child: _isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_adminL10n(context).adminCenterChangeIdentityAction),
        ),
      ],
    );
  }
}

class _AdminIdentitySummaryCard extends StatelessWidget {
  final String label;
  final ActorType actorType;
  final VerificationLevel verificationLevel;
  final IconData icon;
  final bool emphasized;

  const _AdminIdentitySummaryCard({
    required this.label,
    required this.actorType,
    required this.verificationLevel,
    required this.icon,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: emphasized
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              icon,
              color: emphasized
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: emphasized
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_actorTypeLabel(context, actorType)} · '
                    '${_verificationLevelLabel(context, verificationLevel)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: emphasized
                          ? theme.colorScheme.onPrimaryContainer
                          : null,
                      fontWeight: FontWeight.w700,
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

String _actorTypeLabel(BuildContext context, ActorType actorType) {
  final l10n = _adminL10n(context);
  switch (actorType) {
    case ActorType.citizen:
      return l10n.identityActorTypePerson;
    case ActorType.publicOfficial:
      return l10n.identityActorTypePublicOfficial;
    case ActorType.institution:
      return l10n.identityActorTypePublicInstitution;
    case ActorType.organization:
      return l10n.identityActorTypeVerifiedOrganization;
  }
}

String _verificationLevelLabel(
  BuildContext context,
  VerificationLevel verificationLevel,
) {
  final l10n = _adminL10n(context);
  switch (verificationLevel) {
    case VerificationLevel.none:
      return l10n.adminCenterVerificationNotVerified;
    case VerificationLevel.level1:
      return l10n.adminCenterVerificationLevel1;
    case VerificationLevel.level2:
      return l10n.adminCenterVerificationLevel2;
  }
}

String _adminRoleLabel(BuildContext context, Role role) {
  final l10n = _adminL10n(context);
  switch (role) {
    case Role.user:
      return l10n.adminCenterRoleUser;
    case Role.moderator:
      return l10n.adminCenterRoleModerator;
    case Role.admin:
      return l10n.adminCenterRoleAdmin;
  }
}

String _adminAccountStatusLabel(
  BuildContext context,
  AdminAccountStatus status,
) {
  final l10n = _adminL10n(context);
  switch (status) {
    case AdminAccountStatus.active:
      return l10n.adminCenterAccountStatusActive;
    case AdminAccountStatus.suspended:
      return l10n.adminCenterAccountStatusSuspended;
    case AdminAccountStatus.deleted:
      return l10n.adminCenterAccountStatusDeleted;
    case AdminAccountStatus.unknown:
      return l10n.adminCenterUnknown;
  }
}

String _adminAuditResultLabel(BuildContext context, AdminAuditResult result) {
  final l10n = _adminL10n(context);
  switch (result) {
    case AdminAuditResult.success:
      return l10n.adminCenterOutcomeSuccess;
    case AdminAuditResult.failure:
      return l10n.adminCenterOutcomeFailure;
    case AdminAuditResult.denied:
      return l10n.adminCenterOutcomeDenied;
    case AdminAuditResult.noop:
      return l10n.adminCenterOutcomeNoChange;
    case AdminAuditResult.unknown:
      return l10n.adminCenterOutcomeUnknown;
  }
}

String _adminVerificationStatusLabel(
  BuildContext context,
  VerificationStatus status,
) {
  final l10n = _adminL10n(context);
  switch (status) {
    case VerificationStatus.none:
      return l10n.adminCenterVerificationStatusNone;
    case VerificationStatus.pending:
      return l10n.adminCenterVerificationStatusPending;
    case VerificationStatus.rejected:
      return l10n.adminCenterVerificationStatusRejected;
  }
}

String _adminReportTargetTypeLabel(
  BuildContext context,
  AdminReportTargetType targetType,
) {
  final l10n = _adminL10n(context);
  switch (targetType) {
    case AdminReportTargetType.poll:
      return l10n.adminCenterPoll;
    case AdminReportTargetType.post:
      return l10n.adminCenterPost;
    case AdminReportTargetType.news:
      return l10n.adminCenterNews;
    case AdminReportTargetType.unknown:
      return l10n.adminCenterUnknown;
  }
}

String _adminReportStatusLabel(
  BuildContext context,
  AdminReportStatus status,
) {
  final l10n = _adminL10n(context);
  switch (status) {
    case AdminReportStatus.open:
      return l10n.adminCenterStatusOpen;
    case AdminReportStatus.inReview:
      return l10n.adminCenterStatusInReview;
    case AdminReportStatus.resolved:
      return l10n.adminCenterStatusResolved;
    case AdminReportStatus.dismissed:
      return l10n.adminCenterStatusDismissed;
    case AdminReportStatus.unknown:
      return l10n.adminCenterUnknown;
  }
}

class _AdminRoleChangeDialog extends StatefulWidget {
  final AdminUserDetail detail;
  final Future<void> Function({required Role role, required String reason})
      onConfirm;

  const _AdminRoleChangeDialog({required this.detail, required this.onConfirm});

  @override
  State<_AdminRoleChangeDialog> createState() => _AdminRoleChangeDialogState();
}

class _AdminRoleChangeDialogState extends State<_AdminRoleChangeDialog> {
  final TextEditingController _reasonController = TextEditingController();
  Role? _selectedRole;
  bool _confirmed = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _canSubmit {
    final selectedRole = _selectedRole;

    return !_isSubmitting &&
        selectedRole != null &&
        selectedRole != widget.detail.systemRole &&
        _reasonController.text.trim().isNotEmpty &&
        _confirmed;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final selectedRole = _selectedRole;
    if (!_canSubmit || selectedRole == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.onConfirm(
        role: selectedRole,
        reason: _reasonController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(selectedRole);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _errorMessage = _adminL10n(context).adminCenterRoleChangeFailure;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedRole = _selectedRole;

    return AlertDialog(
      scrollable: true,
      title: Text(_adminL10n(context).adminCenterChangeTechnicalRoleTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _adminL10n(context).adminCenterChooseTechnicalRoleMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Role>(
              initialValue: selectedRole,
              decoration: InputDecoration(
                labelText: _adminL10n(context).adminCenterNewTechnicalRoleLabel,
                border: const OutlineInputBorder(),
              ),
              isExpanded: true,
              items: [
                for (final role in Role.values)
                  DropdownMenuItem<Role>(
                    value: role,
                    enabled: role != widget.detail.systemRole,
                    child: Text(_adminRoleLabel(context, role)),
                  ),
              ],
              onChanged: _isSubmitting
                  ? null
                  : (role) {
                      setState(() {
                        _selectedRole = role;
                        _confirmed = false;
                        _errorMessage = null;
                      });
                    },
            ),
            const SizedBox(height: 16),
            _AdminRoleSummaryCard(
              label: _adminL10n(context).adminCenterBeforeLabel,
              role: _adminRoleLabel(context, widget.detail.systemRole),
              icon: Icons.history,
            ),
            const SizedBox(height: 8),
            _AdminRoleSummaryCard(
              label: _adminL10n(context).adminCenterAfterLabel,
              role: selectedRole == null
                  ? _adminL10n(context).adminCenterSelectRole
                  : _adminRoleLabel(context, selectedRole),
              icon: Icons.arrow_forward,
              emphasized: selectedRole != null,
            ),
            const SizedBox(height: 16),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.logout,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _adminL10n(context).adminCenterRoleSessionWarning,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              enabled: !_isSubmitting,
              minLines: 2,
              maxLines: 4,
              maxLength: ChangeSystemRole.maximumReasonLength,
              decoration: InputDecoration(
                labelText: _adminL10n(context).adminCenterReasonLabel,
                hintText: _adminL10n(context).adminCenterRoleReasonHint,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(() {
                  _confirmed = false;
                  _errorMessage = null;
                });
              },
            ),
            CheckboxListTile(
              value: _confirmed,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                _adminL10n(context).adminCenterRoleConfirmation,
              ),
              onChanged: _isSubmitting ||
                      selectedRole == null ||
                      selectedRole == widget.detail.systemRole ||
                      _reasonController.text.trim().isEmpty
                  ? null
                  : (value) {
                      setState(() {
                        _confirmed = value ?? false;
                        _errorMessage = null;
                      });
                    },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: Text(_adminL10n(context).commonCancelButton),
        ),
        FilledButton.icon(
          onPressed: _canSubmit
              ? () {
                  unawaited(_submit());
                }
              : null,
          icon: _isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: Text(
            _isSubmitting
                ? _adminL10n(context).adminCenterChangingRole
                : _adminL10n(context).adminCenterConfirmRoleChange,
          ),
        ),
      ],
    );
  }
}

class _AdminRoleSummaryCard extends StatelessWidget {
  final String label;
  final String role;
  final IconData icon;
  final bool emphasized;

  const _AdminRoleSummaryCard({
    required this.label,
    required this.role,
    required this.icon,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: emphasized
            ? colors.primaryContainer
            : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: emphasized
                  ? colors.onPrimaryContainer
                  : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: emphasized
                          ? colors.onPrimaryContainer
                          : colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: emphasized
                          ? colors.onPrimaryContainer
                          : colors.onSurface,
                      fontWeight: FontWeight.w700,
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

class _AdminUserAttribute extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _AdminUserAttribute({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = color ?? theme.colorScheme.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: foreground.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: foreground),
            const SizedBox(width: 5),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminReportsResultHeader extends StatelessWidget {
  final int totalCount;
  final bool loadFailed;
  final bool retryInProgress;
  final Future<void> Function() onRetry;

  const _AdminReportsResultHeader({
    required this.totalCount,
    required this.loadFailed,
    required this.retryInProgress,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _adminL10n(context).adminCenterReportsCount(totalCount),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (loadFailed) ...[
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _adminL10n(context).adminCenterCouldNotUpdateReports,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: retryInProgress
                        ? null
                        : () {
                            unawaited(onRetry());
                          },
                    child: Text(_adminL10n(context).adminCenterRetryAction),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AdminReportCard extends StatelessWidget {
  final AdminReportEntry report;
  final Future<void> Function() onOpenTarget;
  final Future<void> Function()? onOpenReportedProfile;
  final Future<void> Function()? onRecordDecision;
  final Future<void> Function()? onResolveAdminEscalation;
  final Future<void> Function()? onChangeContentVisibility;

  const _AdminReportCard({
    required this.report,
    required this.onOpenTarget,
    required this.onOpenReportedProfile,
    required this.onRecordDecision,
    required this.onResolveAdminEscalation,
    required this.onChangeContentVisibility,
  });

  String _targetTypeLabel(BuildContext context) {
    return _adminReportTargetTypeLabel(context, report.targetType);
  }

  IconData get _targetTypeIcon {
    switch (report.targetType) {
      case AdminReportTargetType.poll:
        return Icons.how_to_vote_outlined;
      case AdminReportTargetType.post:
        return Icons.forum_outlined;
      case AdminReportTargetType.news:
        return Icons.newspaper_outlined;
      case AdminReportTargetType.unknown:
        return Icons.help_outline;
    }
  }

  String _statusLabel(BuildContext context) {
    if (report.status == AdminReportStatus.inReview &&
        report.moderationDecision == AdminReportDecision.escalateToAdmin) {
      return _adminL10n(context).adminCenterAwaitingAdminDecision;
    }

    return _adminReportStatusLabel(context, report.status);
  }

  String _targetLabel(BuildContext context) {
    final title = report.targetTitle?.trim();
    if (title != null && title.isNotEmpty) {
      return title;
    }
    return _adminL10n(context).adminCenterTargetFallback(
      _targetTypeLabel(context),
      report.targetId,
    );
  }

  String? get _reportedProfileLabel {
    final displayName = report.reportedDisplayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final username = report.reportedUsername?.trim();
    if (username != null && username.isNotEmpty) {
      return '@$username';
    }

    final userId = report.reportedUserId?.trim();
    if (userId != null && userId.isNotEmpty) {
      return userId;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final materialLocalizations = MaterialLocalizations.of(context);
    final createdAt = report.createdAt.toLocal();
    final createdLabel = '${materialLocalizations.formatShortDate(createdAt)} '
        '${materialLocalizations.formatTimeOfDay(TimeOfDay.fromDateTime(createdAt))}';
    final statusColor =
        report.status.isPending ? colors.primary : colors.onSurfaceVariant;
    final reportedProfileLabel = _reportedProfileLabel;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _AdminUserAttribute(
                  icon: _targetTypeIcon,
                  label: _targetTypeLabel(context),
                ),
                _AdminUserAttribute(
                  icon: report.status.isPending
                      ? Icons.pending_actions_outlined
                      : Icons.task_alt_outlined,
                  label: _statusLabel(context),
                  color: statusColor,
                ),
                if (report.moderationDecision ==
                    AdminReportDecision.violationConfirmed)
                  _AdminUserAttribute(
                    icon: report.contentIsHidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    label: report.contentIsHidden
                        ? _adminL10n(context).adminCenterContentHidden
                        : _adminL10n(context).adminCenterContentVisible,
                    color:
                        report.contentIsHidden ? colors.error : colors.tertiary,
                  ),
                _AdminUserAttribute(
                  icon: Icons.schedule_outlined,
                  label: createdLabel,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _targetLabel(context),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              report.reason,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${_adminL10n(context).adminCenterTargetIdLabel}: ${report.targetId}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_adminL10n(context).adminCenterReportedByLabel}: ${report.reporterUserId}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            if (reportedProfileLabel != null) ...[
              const SizedBox(height: 4),
              Text(
                '${_adminL10n(context).adminCenterContentOwnerLabel}: $reportedProfileLabel',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
            if (report.hasModerationDecision) ...[
              const SizedBox(height: 12),
              _AdminReportDecisionSummary(report: report),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                if (onRecordDecision != null)
                  FilledButton.icon(
                    onPressed: () {
                      unawaited(onRecordDecision!());
                    },
                    icon: const Icon(Icons.gavel_outlined),
                    label:
                        Text(_adminL10n(context).adminCenterReviewReportAction),
                  ),
                if (onResolveAdminEscalation != null)
                  FilledButton.icon(
                    onPressed: () {
                      unawaited(onResolveAdminEscalation!());
                    },
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: Text(
                        _adminL10n(context).adminCenterAdminDecisionAction),
                  ),
                if (onChangeContentVisibility != null)
                  FilledButton.tonalIcon(
                    onPressed: () {
                      unawaited(onChangeContentVisibility!());
                    },
                    icon: Icon(
                      report.contentIsHidden
                          ? Icons.restore_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    label: Text(
                      report.contentIsHidden
                          ? _adminL10n(context).adminCenterRestoreContentAction
                          : _adminL10n(context).adminCenterHideContentAction,
                    ),
                  ),
                if (onOpenReportedProfile != null)
                  OutlinedButton.icon(
                    onPressed: () {
                      unawaited(onOpenReportedProfile!());
                    },
                    icon: const Icon(Icons.person_outline),
                    label:
                        Text(_adminL10n(context).adminCenterOpenProfileAction),
                  ),
                FilledButton.tonalIcon(
                  onPressed: report.hasOriginalTarget
                      ? () {
                          unawaited(onOpenTarget());
                        }
                      : null,
                  icon: const Icon(Icons.open_in_new),
                  label: Text(_adminL10n(context).adminCenterOpenContentAction),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _adminReportDecisionLabel(
  BuildContext context,
  AdminReportDecision decision,
) {
  final l10n = _adminL10n(context);
  switch (decision) {
    case AdminReportDecision.noViolation:
      return l10n.adminCenterDecisionNoViolation;
    case AdminReportDecision.violationConfirmed:
      return l10n.adminCenterDecisionViolationConfirmed;
    case AdminReportDecision.escalateToAdmin:
      return l10n.adminCenterDecisionEscalateToAdmin;
    case AdminReportDecision.unknown:
      return l10n.adminCenterUnknown;
  }
}

String _adminReportResolutionLabel(
  BuildContext context,
  AdminReportResolution resolution,
) {
  final l10n = _adminL10n(context);
  switch (resolution) {
    case AdminReportResolution.noAccountAction:
      return l10n.adminCenterResolutionNoAccountAction;
    case AdminReportResolution.accountSuspended:
      return l10n.adminCenterResolutionAccountSuspended;
    case AdminReportResolution.logoutForced:
      return l10n.adminCenterResolutionLogoutForced;
    case AdminReportResolution.accountDeleted:
      return l10n.adminCenterResolutionAccountDeleted;
    case AdminReportResolution.unknown:
      return l10n.adminCenterUnknown;
  }
}

class _AdminReportDecisionSummary extends StatelessWidget {
  final AdminReportEntry report;

  const _AdminReportDecisionSummary({required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final decision = report.moderationDecision;
    final reviewNote = report.reviewNote?.trim();
    final reviewedBy = report.reviewedBy?.trim();
    final reviewedAt = report.reviewedAt;

    if (decision == null) {
      return const SizedBox.shrink();
    }

    String? reviewedLabel;
    if (reviewedAt != null) {
      final localValue = reviewedAt.toLocal();
      final localizations = MaterialLocalizations.of(context);
      reviewedLabel = '${localizations.formatShortDate(localValue)} '
          '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(localValue))}';
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.fact_check_outlined,
                  size: 20,
                  color: colors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _adminReportDecisionLabel(context, decision),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (reviewNote != null && reviewNote.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(reviewNote, style: theme.textTheme.bodyMedium),
            ],
            if ((reviewedBy != null && reviewedBy.isNotEmpty) ||
                reviewedLabel != null) ...[
              const SizedBox(height: 8),
              Text(
                [
                  if (reviewedBy != null && reviewedBy.isNotEmpty)
                    '${_adminL10n(context).adminCenterReviewerLabel}: $reviewedBy',
                  if (reviewedLabel != null) reviewedLabel,
                ].join(' · '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AdminReportDecisionDialog extends StatefulWidget {
  final AdminReportEntry report;
  final Future<void> Function({
    required AdminReportDecision decision,
    required String reviewNote,
  }) onConfirm;

  const _AdminReportDecisionDialog({
    required this.report,
    required this.onConfirm,
  });

  @override
  State<_AdminReportDecisionDialog> createState() =>
      _AdminReportDecisionDialogState();
}

class _AdminReportDecisionDialogState
    extends State<_AdminReportDecisionDialog> {
  final TextEditingController _reviewNoteController = TextEditingController();
  AdminReportDecision? _selectedDecision;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _canSubmit {
    final noteLength = _reviewNoteController.text.trim().length;

    return !_isSubmitting &&
        _selectedDecision != null &&
        noteLength >= RecordAdminReportDecision.minimumReviewNoteLength &&
        noteLength <= RecordAdminReportDecision.maximumReviewNoteLength;
  }

  String get _decisionDescription {
    final l10n = _adminL10n(context);
    switch (_selectedDecision) {
      case AdminReportDecision.noViolation:
        return l10n.adminCenterDecisionDescriptionNoViolation;
      case AdminReportDecision.violationConfirmed:
        return l10n.adminCenterDecisionDescriptionViolation;
      case AdminReportDecision.escalateToAdmin:
        return l10n.adminCenterDecisionDescriptionEscalation;
      case AdminReportDecision.unknown:
      case null:
        return l10n.adminCenterChooseModerationOutcome;
    }
  }

  @override
  void dispose() {
    _reviewNoteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final decision = _selectedDecision;
    if (!_canSubmit || decision == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.onConfirm(
        decision: decision,
        reviewNote: _reviewNoteController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(decision);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _errorMessage =
            _adminL10n(context).adminCenterDecisionAlreadyRecordedFailure;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final targetTitle = widget.report.targetTitle?.trim();

    return AlertDialog(
      scrollable: true,
      title: Text(_adminL10n(context).adminCenterReviewReportAction),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              targetTitle == null || targetTitle.isEmpty
                  ? _adminL10n(context).adminCenterTargetFallback(
                      _adminReportTargetTypeLabel(
                        context,
                        widget.report.targetType,
                      ),
                      widget.report.targetId,
                    )
                  : targetTitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_adminL10n(context).adminCenterReportReasonLabel}: '
              '${widget.report.reason}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AdminReportDecision>(
              initialValue: _selectedDecision,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: _adminL10n(context).adminCenterDecisionLabel,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem<AdminReportDecision>(
                  value: AdminReportDecision.noViolation,
                  child: Text(
                    _adminReportDecisionLabel(
                      context,
                      AdminReportDecision.noViolation,
                    ),
                  ),
                ),
                DropdownMenuItem<AdminReportDecision>(
                  value: AdminReportDecision.violationConfirmed,
                  child: Text(
                    _adminReportDecisionLabel(
                      context,
                      AdminReportDecision.violationConfirmed,
                    ),
                  ),
                ),
                DropdownMenuItem<AdminReportDecision>(
                  value: AdminReportDecision.escalateToAdmin,
                  child: Text(
                    _adminReportDecisionLabel(
                      context,
                      AdminReportDecision.escalateToAdmin,
                    ),
                  ),
                ),
              ],
              onChanged: _isSubmitting
                  ? null
                  : (decision) {
                      setState(() {
                        _selectedDecision = decision;
                        _errorMessage = null;
                      });
                    },
            ),
            const SizedBox(height: 10),
            Text(
              _decisionDescription,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reviewNoteController,
              enabled: !_isSubmitting,
              minLines: 3,
              maxLines: 6,
              maxLength: RecordAdminReportDecision.maximumReviewNoteLength,
              decoration: InputDecoration(
                labelText: _adminL10n(context).adminCenterReviewNoteLabel,
                hintText: _adminL10n(context).adminCenterReviewNoteHint,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(() {
                  _errorMessage = null;
                });
              },
            ),
            Text(
              _adminL10n(context).adminCenterMinimumCharactersRequired(
                RecordAdminReportDecision.minimumReviewNoteLength,
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, color: colors.onErrorContainer),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: Text(_adminL10n(context).commonCancelButton),
        ),
        FilledButton.icon(
          onPressed: _canSubmit
              ? () {
                  unawaited(_submit());
                }
              : null,
          icon: _isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: Text(
            _isSubmitting
                ? _adminL10n(context).adminCenterRecordingDecision
                : _adminL10n(context).adminCenterConfirmDecision,
          ),
        ),
      ],
    );
  }
}

class _AdminReportResolutionDialog extends StatefulWidget {
  final AdminReportEntry report;
  final Future<void> Function({
    required AdminReportResolution resolution,
    required String resolutionNote,
  }) onConfirm;

  const _AdminReportResolutionDialog({
    required this.report,
    required this.onConfirm,
  });

  @override
  State<_AdminReportResolutionDialog> createState() =>
      _AdminReportResolutionDialogState();
}

class _AdminReportResolutionDialogState
    extends State<_AdminReportResolutionDialog> {
  static const int _minimumNoteLength = 3;
  static const int _maximumNoteLength = 2000;

  final TextEditingController _noteController = TextEditingController();
  AdminReportResolution? _selectedResolution;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _canSubmit {
    final noteLength = _noteController.text.trim().length;

    return !_isSubmitting &&
        _selectedResolution != null &&
        noteLength >= _minimumNoteLength &&
        noteLength <= _maximumNoteLength;
  }

  String get _resolutionDescription {
    final l10n = _adminL10n(context);
    switch (_selectedResolution) {
      case AdminReportResolution.noAccountAction:
        return l10n.adminCenterResolutionDescriptionNoAction;
      case AdminReportResolution.accountSuspended:
        return l10n.adminCenterResolutionDescriptionSuspended;
      case AdminReportResolution.logoutForced:
        return l10n.adminCenterResolutionDescriptionLogout;
      case AdminReportResolution.accountDeleted:
        return l10n.adminCenterResolutionDescriptionDeleted;
      case AdminReportResolution.unknown:
      case null:
        return l10n.adminCenterChooseFinalOutcome;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final resolution = _selectedResolution;
    if (!_canSubmit || resolution == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.onConfirm(
        resolution: resolution,
        resolutionNote: _noteController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(resolution);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _errorMessage = resolution == AdminReportResolution.noAccountAction
            ? _adminL10n(context).adminCenterAdminResolutionFailure
            : _adminL10n(context).adminCenterAdminResolutionRequiresAction;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final targetTitle = widget.report.targetTitle?.trim();
    final escalationNote = widget.report.reviewNote?.trim().isNotEmpty == true
        ? widget.report.reviewNote!.trim()
        : _adminL10n(context).adminCenterNotAvailable;

    return AlertDialog(
      scrollable: true,
      title: Text(_adminL10n(context).adminCenterAdministratorDecisionTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              targetTitle == null || targetTitle.isEmpty
                  ? _adminL10n(context).adminCenterTargetFallback(
                      _adminReportTargetTypeLabel(
                        context,
                        widget.report.targetType,
                      ),
                      widget.report.targetId,
                    )
                  : targetTitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_adminL10n(context).adminCenterEscalationNoteLabel}: '
              '$escalationNote',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AdminReportResolution>(
              initialValue: _selectedResolution,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: _adminL10n(context).adminCenterFinalOutcomeLabel,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem<AdminReportResolution>(
                  value: AdminReportResolution.noAccountAction,
                  child: Text(
                    _adminReportResolutionLabel(
                      context,
                      AdminReportResolution.noAccountAction,
                    ),
                  ),
                ),
                DropdownMenuItem<AdminReportResolution>(
                  value: AdminReportResolution.accountSuspended,
                  child: Text(
                    _adminReportResolutionLabel(
                      context,
                      AdminReportResolution.accountSuspended,
                    ),
                  ),
                ),
                DropdownMenuItem<AdminReportResolution>(
                  value: AdminReportResolution.logoutForced,
                  child: Text(
                    _adminReportResolutionLabel(
                      context,
                      AdminReportResolution.logoutForced,
                    ),
                  ),
                ),
                DropdownMenuItem<AdminReportResolution>(
                  value: AdminReportResolution.accountDeleted,
                  child: Text(
                    _adminReportResolutionLabel(
                      context,
                      AdminReportResolution.accountDeleted,
                    ),
                  ),
                ),
              ],
              onChanged: _isSubmitting
                  ? null
                  : (resolution) {
                      setState(() {
                        _selectedResolution = resolution;
                        _errorMessage = null;
                      });
                    },
            ),
            const SizedBox(height: 10),
            Text(
              _resolutionDescription,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              enabled: !_isSubmitting,
              minLines: 3,
              maxLines: 6,
              maxLength: _maximumNoteLength,
              decoration: InputDecoration(
                labelText:
                    _adminL10n(context).adminCenterAdministratorNoteLabel,
                hintText: _adminL10n(context).adminCenterAdministratorNoteHint,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(() {
                  _errorMessage = null;
                });
              },
            ),
            Text(
              _adminL10n(context).adminCenterMinimumCharactersRequired(
                _minimumNoteLength,
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, color: colors.onErrorContainer),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: Text(_adminL10n(context).commonCancelButton),
        ),
        FilledButton.icon(
          onPressed: _canSubmit
              ? () {
                  unawaited(_submit());
                }
              : null,
          icon: _isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: Text(
            _isSubmitting
                ? _adminL10n(context).adminCenterRecordingDecision
                : _adminL10n(context).adminCenterConfirmDecision,
          ),
        ),
      ],
    );
  }
}

class _AdminReportContentVisibilityDialog extends StatefulWidget {
  final AdminReportEntry report;
  final bool requestedHiddenState;
  final Future<void> Function({required bool isHidden, required String reason})
      onConfirm;

  const _AdminReportContentVisibilityDialog({
    required this.report,
    required this.requestedHiddenState,
    required this.onConfirm,
  });

  @override
  State<_AdminReportContentVisibilityDialog> createState() =>
      _AdminReportContentVisibilityDialogState();
}

class _AdminReportContentVisibilityDialogState
    extends State<_AdminReportContentVisibilityDialog> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _canSubmit {
    final reasonLength = _reasonController.text.trim().length;

    return !_isSubmitting &&
        reasonLength >= SetReportContentVisibility.minimumReasonLength &&
        reasonLength <= SetReportContentVisibility.maximumReasonLength;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.onConfirm(
        isHidden: widget.requestedHiddenState,
        reason: _reasonController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(widget.requestedHiddenState);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _errorMessage = widget.requestedHiddenState
            ? _adminL10n(context).adminCenterHideContentFailure
            : _adminL10n(context).adminCenterRestoreContentFailure;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final targetTitle = widget.report.targetTitle?.trim();
    final actionLabel = widget.requestedHiddenState
        ? _adminL10n(context).adminCenterHideContentAction
        : _adminL10n(context).adminCenterRestoreContentAction;

    return AlertDialog(
      scrollable: true,
      title: Text(actionLabel),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              targetTitle == null || targetTitle.isEmpty
                  ? _adminL10n(context).adminCenterTargetFallback(
                      _adminReportTargetTypeLabel(
                        context,
                        widget.report.targetType,
                      ),
                      widget.report.targetId,
                    )
                  : targetTitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: widget.requestedHiddenState
                    ? colors.errorContainer
                    : colors.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  widget.requestedHiddenState
                      ? _adminL10n(context).adminCenterHideContentWarning
                      : _adminL10n(context).adminCenterRestoreContentWarning,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: widget.requestedHiddenState
                        ? colors.onErrorContainer
                        : colors.onSecondaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              enabled: !_isSubmitting,
              minLines: 3,
              maxLines: 6,
              maxLength: SetReportContentVisibility.maximumReasonLength,
              decoration: InputDecoration(
                labelText: _adminL10n(context).adminCenterActionReasonLabel,
                hintText: widget.requestedHiddenState
                    ? _adminL10n(context).adminCenterHideContentReasonHint
                    : _adminL10n(context).adminCenterRestoreContentReasonHint,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(() {
                  _errorMessage = null;
                });
              },
            ),
            Text(
              _adminL10n(context).adminCenterMinimumReasonCharactersRequired(
                SetReportContentVisibility.minimumReasonLength,
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, color: colors.onErrorContainer),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: Text(_adminL10n(context).commonCancelButton),
        ),
        FilledButton.icon(
          onPressed: _canSubmit
              ? () {
                  unawaited(_submit());
                }
              : null,
          icon: _isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  widget.requestedHiddenState
                      ? Icons.visibility_off_outlined
                      : Icons.restore_outlined,
                ),
          label: Text(
            _isSubmitting
                ? (widget.requestedHiddenState
                    ? _adminL10n(context).adminCenterHidingContent
                    : _adminL10n(context).adminCenterRestoringContent)
                : actionLabel,
          ),
        ),
      ],
    );
  }
}

class _AdminReportedProfileSheet extends StatelessWidget {
  final AdminReportEntry report;

  const _AdminReportedProfileSheet({required this.report});

  String _displayName(BuildContext context) {
    final displayName = report.reportedDisplayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final username = report.reportedUsername?.trim();
    if (username != null && username.isNotEmpty) {
      return '@$username';
    }

    return _adminL10n(context).adminCenterReportedProfileTitle;
  }

  String? get _username {
    final username = report.reportedUsername?.trim();
    if (username == null || username.isEmpty) {
      return null;
    }
    return '@$username';
  }

  String _reportedActorTypeLabel(BuildContext context) {
    final actorType = report.reportedActorType;
    return actorType == null
        ? _adminL10n(context).adminCenterNotAvailable
        : _actorTypeLabel(context, actorType);
  }

  String _reportedVerificationLabel(BuildContext context) {
    final level = report.reportedVerificationLevel;
    return level == null
        ? _adminL10n(context).adminCenterNotAvailable
        : _verificationLevelLabel(context, level);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final avatarUrl = report.reportedAvatarUrl?.trim();
    final username = _username;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _AdminReportedProfileAvatar(
                  avatarUrl: avatarUrl,
                  fallbackLabel: _displayName(context),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (username != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          username,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _AdminUserDetailSection(
              title: _adminL10n(context).adminCenterReportedProfileTitle,
              children: [
                _AdminUserDetailField(
                  icon: Icons.badge_outlined,
                  label: _adminL10n(context).adminCenterPublicIdentitySection,
                  value: _reportedActorTypeLabel(context),
                ),
                _AdminUserDetailField(
                  icon: Icons.verified_user_outlined,
                  label: _adminL10n(context).adminCenterVerificationNavigation,
                  value: _reportedVerificationLabel(context),
                ),
                _AdminUserDetailField(
                  icon: Icons.fingerprint,
                  label: _adminL10n(context).adminCenterUserIdLabel,
                  value: report.reportedUserId ??
                      _adminL10n(context).adminCenterNotAvailable,
                  selectable: true,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _adminL10n(context).adminCenterReportedProfileNotice,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminReportedProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String fallbackLabel;

  const _AdminReportedProfileAvatar({
    required this.avatarUrl,
    required this.fallbackLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final initial = fallbackLabel.trim().isEmpty
        ? '?'
        : fallbackLabel.trim().characters.first.toUpperCase();

    return Container(
      width: 56,
      height: 56,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.secondaryContainer,
      ),
      child: avatarUrl == null || avatarUrl!.isEmpty
          ? Center(
              child: Text(
                initial,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.onSecondaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : Image.network(
              avatarUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    initial,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colors.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _AdminReportsPagination extends StatelessWidget {
  final AdminReportQueuePage page;
  final bool loading;
  final Future<void> Function()? onPrevious;
  final Future<void> Function()? onNext;

  const _AdminReportsPagination({
    required this.page,
    required this.loading,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final materialLocalizations = MaterialLocalizations.of(context);
    final currentPage = (page.offset ~/ page.limit) + 1;
    final totalPages = page.totalCount == 0
        ? 1
        : (page.totalCount + page.limit - 1) ~/ page.limit;

    return Row(
      children: [
        Expanded(
          child: Text(
            _adminL10n(context).adminCenterPageOf(currentPage, totalPages),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        IconButton(
          tooltip: materialLocalizations.previousPageTooltip,
          onPressed: loading || onPrevious == null
              ? null
              : () {
                  unawaited(onPrevious!());
                },
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          tooltip: materialLocalizations.nextPageTooltip,
          onPressed: loading || onNext == null
              ? null
              : () {
                  unawaited(onNext!());
                },
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _AdminUsersPagination extends StatelessWidget {
  final AdminUserSearchPage page;
  final bool loading;
  final Future<void> Function()? onPrevious;
  final Future<void> Function()? onNext;

  const _AdminUsersPagination({
    required this.page,
    required this.loading,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final materialLocalizations = MaterialLocalizations.of(context);
    final totalPages = page.totalPages == 0 ? 1 : page.totalPages;

    return Row(
      children: [
        Expanded(
          child: Text(
            _adminL10n(context).adminCenterPageOf(page.page, totalPages),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        IconButton(
          tooltip: materialLocalizations.previousPageTooltip,
          onPressed: loading || onPrevious == null
              ? null
              : () {
                  unawaited(onPrevious!());
                },
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          tooltip: materialLocalizations.nextPageTooltip,
          onPressed: loading || onNext == null
              ? null
              : () {
                  unawaited(onNext!());
                },
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _AdminDashboardStateCard extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final bool progressIndicator;
  final String title;
  final String message;
  final String? actionLabel;
  final Future<void> Function()? onAction;
  final bool actionInProgress;

  const _AdminDashboardStateCard({
    this.icon,
    this.iconColor,
    this.progressIndicator = false,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.actionInProgress = false,
  }) : assert(
          (actionLabel == null && onAction == null) ||
              (actionLabel != null && onAction != null),
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (progressIndicator)
              const SizedBox.square(
                dimension: 36,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            else
              Icon(
                icon,
                size: 40,
                color: iconColor ?? theme.colorScheme.onSurfaceVariant,
              ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: actionInProgress
                    ? null
                    : () async {
                        await onAction!();
                      },
                icon: actionInProgress
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AdminDashboardRefreshError extends StatelessWidget {
  final bool retryInProgress;
  final Future<void> Function() onRetry;

  const _AdminDashboardRefreshError({
    required this.retryInProgress,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      color: colors.errorContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colors.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _adminL10n(context).adminCenterCouldNotRefreshIndicators,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onErrorContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: retryInProgress
                  ? null
                  : () async {
                      await onRetry();
                    },
              child: Text(_adminL10n(context).adminCenterRetryAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminUserDetailRefreshError extends StatelessWidget {
  final bool retryInProgress;
  final Future<void> Function() onRetry;

  const _AdminUserDetailRefreshError({
    required this.retryInProgress,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      color: colors.errorContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colors.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _adminL10n(context).adminCenterCouldNotRefreshAccount,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onErrorContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: retryInProgress
                  ? null
                  : () async {
                      await onRetry();
                    },
              child: Text(_adminL10n(context).adminCenterRetryAction),
            ),
          ],
        ),
      ),
    );
  }
}
