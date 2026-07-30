import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/admin/entities/admin_entities.dart';
import 'package:sociale_vote/domain/admin/repositories/admin_repository.dart';
import 'package:sociale_vote/domain/admin/usecases/change_system_role.dart';
import 'package:sociale_vote/domain/admin/usecases/load_admin_dashboard.dart';
import 'package:sociale_vote/domain/admin/usecases/search_admin_users.dart';
import 'package:sociale_vote/domain/identity/value_objects/role.dart';

enum AdminCenterSection {
  dashboard,
  users,
  verification,
  reports,
  audit,
}

typedef AdminCenterSectionBuilder = Widget Function(
  BuildContext context,
  AdminCenterSection section,
);

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
  static const Duration _userSearchDelay = Duration(milliseconds: 350);
  static const Uuid _uuid = Uuid();

  late final LoadAdminDashboard _loadAdminDashboard;
  late final SearchAdminUsers _searchAdminUsers;
  late final ChangeSystemRole _changeSystemRole;
  late final AdminRepository _adminRepository;
  final TextEditingController _userSearchController = TextEditingController();

  AdminDashboardSummary? _dashboardSummary;
  AdminUserSearchPage? _userSearchPage;
  AdminUserSummary? _selectedUser;
  AdminUserDetail? _userDetail;
  Timer? _userSearchDebounce;
  int _usersRequestGeneration = 0;
  int _userDetailRequestGeneration = 0;
  bool _isDashboardLoading = true;
  bool _dashboardLoadFailed = false;
  bool _isUsersLoading = false;
  bool _usersLoadFailed = false;
  bool _isUserDetailLoading = false;
  bool _userDetailLoadFailed = false;
  bool _isRefreshing = false;
  AdminCenterSection _selectedSection = AdminCenterSection.dashboard;

  List<_AdminDestination> get _destinations {
    return [
      const _AdminDestination(
        section: AdminCenterSection.dashboard,
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        label: 'Dashboard',
      ),
      if (widget.currentRole == Role.admin)
        const _AdminDestination(
          section: AdminCenterSection.users,
          icon: Icons.people_outline,
          selectedIcon: Icons.people,
          label: 'Users',
        ),
      const _AdminDestination(
        section: AdminCenterSection.verification,
        icon: Icons.verified_user_outlined,
        selectedIcon: Icons.verified_user,
        label: 'Verification',
      ),
      const _AdminDestination(
        section: AdminCenterSection.reports,
        icon: Icons.flag_outlined,
        selectedIcon: Icons.flag,
        label: 'Reports',
      ),
      if (widget.currentRole == Role.admin)
        const _AdminDestination(
          section: AdminCenterSection.audit,
          icon: Icons.history_outlined,
          selectedIcon: Icons.history,
          label: 'Audit',
        ),
    ];
  }

  @override
  void initState() {
    super.initState();

    _adminRepository = AppDI.instance.adminRepository;
    _loadAdminDashboard = LoadAdminDashboard(
      _adminRepository,
    );
    _searchAdminUsers = SearchAdminUsers(
      _adminRepository,
    );
    _changeSystemRole = ChangeSystemRole(
      _adminRepository,
    );
    unawaited(_loadDashboard(markLoading: false));
  }

  @override
  void dispose() {
    _userSearchDebounce?.cancel();
    _userSearchController.dispose();
    super.dispose();
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

  Future<void> _refresh() async {
    final showingUserDetail =
        _selectedSection == AdminCenterSection.users && _selectedUser != null;
    final selectedSectionLoading =
        (_selectedSection == AdminCenterSection.dashboard &&
                _isDashboardLoading) ||
            (_selectedSection == AdminCenterSection.users &&
                (showingUserDetail ? _isUserDetailLoading : _isUsersLoading));

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
          await _loadUserDetail(
            selectedUser,
            markLoading: _userDetail == null,
          );
        } else {
          await _loadUsers(
            page: _userSearchPage?.page ?? 1,
            markLoading: _userSearchPage == null,
          );
        }
      } else {
        await _loadDashboard(
          markLoading: _dashboardSummary == null,
        );
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

  Future<void> _loadDashboard({
    bool markLoading = true,
  }) async {
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

  Future<void> _loadUsers({
    int page = 1,
    bool markLoading = true,
  }) async {
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
      final detail = await _adminRepository.getUserDetail(
        userId: user.id,
      );

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
    _userSearchDebounce = Timer(
      _userSearchDelay,
      () {
        if (mounted) {
          unawaited(_loadUsers(page: 1));
        }
      },
    );
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

  Future<void> _openChangeRoleDialog(
    AdminUserDetail detail,
  ) async {
    final operationId = _uuid.v4();
    final changedRole = await showDialog<Role>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _AdminRoleChangeDialog(
          detail: detail,
          onConfirm: ({
            required Role role,
            required String reason,
          }) {
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
          'Technical role changed from '
          '${detail.systemRole.storageKey} to '
          '${changedRole.storageKey}. The recipient was signed out '
          'and must sign in again.',
        ),
      ),
    );

    final selectedUser = _selectedUser;
    if (selectedUser == null || selectedUser.id != detail.id) {
      return;
    }

    await _loadUserDetail(
      selectedUser,
      markLoading: false,
    );

    if (!mounted) {
      return;
    }

    unawaited(
      _loadUsers(
        page: _userSearchPage?.page ?? 1,
        markLoading: false,
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
              hintText: 'Search by name, username, email or ID',
              counterText: '',
              border: const OutlineInputBorder(),
              suffixIcon: _userSearchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: _clearUserSearch,
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
        ),
        if (_isUsersLoading && page != null)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: _buildUsersResults(context),
        ),
      ],
    );
  }

  Widget _buildUsersResults(BuildContext context) {
    final page = _userSearchPage;

    if (_isUsersLoading && page == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_usersLoadFailed && page == null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AdminDashboardStateCard(
            icon: Icons.error_outline,
            iconColor: Theme.of(context).colorScheme.error,
            title: 'Users unavailable',
            message: 'Check your connection and try again.',
            actionLabel: 'Try again',
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
            title: hasQuery ? 'No users found' : 'No users',
            message: hasQuery
                ? 'Try a different name, username, email or ID.'
                : 'There are no accounts to display.',
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        key: ValueKey(
          '${_userSearchController.text.trim()}-${page.page}',
        ),
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
              onRetry: () => _loadUsers(
                page: page.page,
                markLoading: false,
              ),
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
                ? () => _loadUsers(
                      page: page.page - 1,
                      markLoading: false,
                    )
                : null,
            onNext: page.hasNextPage
                ? () => _loadUsers(
                      page: page.page + 1,
                      markLoading: false,
                    )
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
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_userDetailLoadFailed && detail == null) {
      return ListView(
        key: ValueKey('user-detail-error-${selectedUser.id}'),
        padding: const EdgeInsets.all(16),
        children: [
          _AdminDashboardStateCard(
            icon: Icons.error_outline,
            iconColor: Theme.of(context).colorScheme.error,
            title: 'Account unavailable',
            message: 'Check your connection and try again.',
            actionLabel: 'Try again',
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
              onRetry: () => _loadUserDetail(
                selectedUser,
                markLoading: false,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _closeUserDetail,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to users'),
            ),
          ),
          const SizedBox(height: 4),
          _AdminUserDetailHeader(detail: detail),
          const SizedBox(height: 12),
          _AdminUserDetailSection(
            title: 'Public identity',
            children: [
              _AdminUserDetailField(
                icon: Icons.badge_outlined,
                label: 'Display name',
                value: displayName == null || displayName.isEmpty
                    ? 'Not provided'
                    : displayName,
              ),
              _AdminUserDetailField(
                icon: Icons.alternate_email,
                label: 'Username',
                value: username == null || username.isEmpty
                    ? 'Not provided'
                    : '@$username',
              ),
              _AdminUserDetailField(
                icon: Icons.fingerprint,
                label: 'User ID',
                value: detail.id,
                selectable: true,
              ),
              _AdminUserDetailField(
                icon: Icons.account_circle_outlined,
                label: 'Identity type',
                value: detail.actorType.name,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AdminUserDetailSection(
            title: 'Account',
            children: [
              _AdminUserDetailField(
                icon: Icons.admin_panel_settings_outlined,
                label: 'Technical role',
                value: detail.systemRole.storageKey,
              ),
              _AdminUserDetailField(
                icon: Icons.sync_outlined,
                label: 'Profile role mirror',
                value: detail.mirrorRole.storageKey,
              ),
              _AdminUserDetailField(
                icon: detail.roleSynchronized ? Icons.sync : Icons.sync_problem,
                label: 'Role synchronization',
                value: detail.roleSynchronized
                    ? 'Synchronized'
                    : 'Not synchronized',
                valueColor: detail.roleSynchronized
                    ? null
                    : Theme.of(context).colorScheme.error,
              ),
              _AdminUserDetailField(
                icon: detail.isSuspended
                    ? Icons.person_off_outlined
                    : Icons.person_outline,
                label: 'Account status',
                value: detail.accountStatus.storageKey,
              ),
              if (detail.suspendedUntil != null)
                _AdminUserDetailField(
                  icon: Icons.event_busy_outlined,
                  label: 'Suspended until',
                  value: _formatDateTime(
                    context,
                    detail.suspendedUntil!,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _AdminUserDetailSection(
            title: 'Role management',
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
            title: 'Verification',
            children: [
              _AdminUserDetailField(
                icon: Icons.workspace_premium_outlined,
                label: 'Verification level',
                value: detail.verificationLevel.name,
              ),
              _AdminUserDetailField(
                icon: Icons.verified_user_outlined,
                label: 'Verification status',
                value: detail.verificationStatus.name,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AdminUserDetailSection(
            title: 'Access information',
            children: [
              _AdminUserDetailField(
                icon: Icons.email_outlined,
                label: 'Email',
                value: email == null || email.isEmpty ? 'Not available' : email,
                selectable: true,
              ),
              _AdminUserDetailField(
                icon: detail.emailConfirmedAt == null
                    ? Icons.mark_email_unread_outlined
                    : Icons.mark_email_read_outlined,
                label: 'Email confirmation',
                value: detail.emailConfirmedAt == null
                    ? 'Not confirmed'
                    : _formatDateTime(
                        context,
                        detail.emailConfirmedAt!,
                      ),
              ),
              _AdminUserDetailField(
                icon: Icons.person_add_alt_outlined,
                label: 'Registered',
                value: _formatDateTime(context, detail.createdAt),
              ),
              _AdminUserDetailField(
                icon: Icons.login_outlined,
                label: 'Last access',
                value: detail.lastSignInAt == null
                    ? 'Not available'
                    : _formatDateTime(
                        context,
                        detail.lastSignInAt!,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(
    BuildContext context,
    DateTime value,
  ) {
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
      return const _AdminDashboardStateCard(
        progressIndicator: true,
        title: 'Loading dashboard',
        message: 'Retrieving the latest indicators.',
      );
    }

    if (_dashboardLoadFailed && summary == null) {
      return _AdminDashboardStateCard(
        icon: Icons.error_outline,
        iconColor: Theme.of(context).colorScheme.error,
        title: 'Dashboard unavailable',
        message: 'Check your connection and try again.',
        actionLabel: 'Try again',
        onAction: _refresh,
        actionInProgress: _isRefreshing,
      );
    }

    if (summary == null) {
      return _AdminDashboardStateCard(
        icon: Icons.error_outline,
        iconColor: Theme.of(context).colorScheme.error,
        title: 'Dashboard unavailable',
        message: 'The indicators could not be loaded.',
        actionLabel: 'Try again',
        onAction: _refresh,
        actionInProgress: _isRefreshing,
      );
    }

    final indicators = <_AdminIndicator>[
      _AdminIndicator(
        label: 'Verification pending',
        value: summary.pendingVerificationRequests,
        icon: Icons.verified_user_outlined,
      ),
      _AdminIndicator(
        label: 'Open reports',
        value: summary.openReports,
        icon: Icons.flag_outlined,
      ),
      _AdminIndicator(
        label: 'Suspended accounts',
        value: summary.suspendedAccounts,
        icon: Icons.person_off_outlined,
      ),
      _AdminIndicator(
        label: 'Users',
        value: summary.totalUsers,
        icon: Icons.people_outline,
      ),
      _AdminIndicator(
        label: 'Staff',
        value: summary.staffUsers,
        icon: Icons.admin_panel_settings_outlined,
      ),
    ];

    final hasPendingWork = summary.pendingVerificationRequests > 0 ||
        summary.openReports > 0 ||
        summary.suspendedAccounts > 0;

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
        if (!hasPendingWork) ...[
          const _AdminDashboardStateCard(
            icon: Icons.check_circle_outline,
            title: 'No pending work',
            message: 'Verification, reports, and suspended accounts are clear.',
          ),
          const SizedBox(height: 12),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = switch (constraints.maxWidth) {
              < 360 => 1,
              < 700 => 2,
              < 1100 => 3,
              _ => 5,
            };

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 132,
              ),
              itemCount: indicators.length,
              itemBuilder: (context, index) {
                final indicator = indicators[index];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          indicator.icon,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const Spacer(),
                        Text(
                          '${indicator.value}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          indicator.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDesktopDashboard(BuildContext context) {
    return CustomScrollView(
      key: const ValueKey(AdminCenterSection.dashboard),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: _buildDashboardIndicators(context),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileDashboard(BuildContext context) {
    final destinations = _destinations
        .where(
          (destination) => destination.section != AdminCenterSection.dashboard,
        )
        .toList(growable: false);

    return CustomScrollView(
      key: const ValueKey(AdminCenterSection.dashboard),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          sliver: SliverToBoxAdapter(
            child: _buildDashboardIndicators(context),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.crossAxisExtent < 360 ? 1 : 2;

              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 112,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final destination = destinations[index];

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _selectSection(destination.section),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                destination.icon,
                                size: 30,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                destination.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: destinations.length,
                ),
              );
            },
          ),
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

  Widget _buildDesktopLayout(
    BuildContext context, {
    required bool extendRail,
  }) {
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
        Expanded(
          child: _buildSelectedContent(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
              ? 'Account details'
              : isMobileLayout &&
                      _selectedSection != AdminCenterSection.dashboard
                  ? currentDestination.label
                  : 'Admin Center',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Chip(
              avatar: isMobileLayout
                  ? null
                  : const Icon(
                      Icons.admin_panel_settings_outlined,
                      size: 18,
                    ),
              label: Text(widget.currentRole.storageKey.toUpperCase()),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 4),
          if (_isRefreshing ||
              (_selectedSection == AdminCenterSection.dashboard &&
                  _isDashboardLoading &&
                  _dashboardSummary == null) ||
              (_selectedSection == AdminCenterSection.users &&
                  (showingUserDetail
                      ? _isUserDetailLoading && _userDetail == null
                      : _isUsersLoading && _userSearchPage == null)))
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
}

class _AdminDestination {
  final AdminCenterSection section;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _AdminDestination({
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

  const _AdminIndicator({
    required this.label,
    required this.value,
    required this.icon,
  });
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
          '$totalCount ${totalCount == 1 ? 'user' : 'users'}',
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
                      'Could not update the user list.',
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
                    child: const Text('Retry'),
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

  const _AdminUserCard({
    required this.user,
    required this.onTap,
  });

  String get _title {
    final displayName = user.displayName?.trim();

    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final username = user.username?.trim();

    if (username != null && username.isNotEmpty) {
      return username;
    }

    return 'Unnamed user';
  }

  String get _avatarLabel {
    final value = _title.trim();
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
              CircleAvatar(
                child: Text(_avatarLabel),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
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
                          label: user.systemRole.storageKey,
                        ),
                        _AdminUserAttribute(
                          icon: user.isSuspended
                              ? Icons.person_off_outlined
                              : Icons.person_outline,
                          label: user.accountStatus.storageKey,
                        ),
                        if (!user.roleSynchronized)
                          _AdminUserAttribute(
                            icon: Icons.sync_problem,
                            label: 'Role not synchronized',
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

  const _AdminUserDetailHeader({
    required this.detail,
  });

  String get _title {
    final displayName = detail.displayName?.trim();

    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final username = detail.username?.trim();

    if (username != null && username.isNotEmpty) {
      return username;
    }

    return 'Unnamed user';
  }

  String get _avatarLabel {
    final value = _title.trim();
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
              child: Text(
                _avatarLabel,
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title,
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
                        label: detail.systemRole.storageKey,
                      ),
                      _AdminUserAttribute(
                        icon: detail.isSuspended
                            ? Icons.person_off_outlined
                            : Icons.person_outline,
                        label: detail.accountStatus.storageKey,
                      ),
                      if (!detail.roleSynchronized)
                        _AdminUserAttribute(
                          icon: Icons.sync_problem,
                          label: 'Role not synchronized',
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

  const _AdminUserDetailSection({
    required this.title,
    required this.children,
  });

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
                  SelectableText(
                    value,
                    style: valueStyle,
                  )
                else
                  Text(
                    value,
                    style: valueStyle,
                  ),
              ],
            ),
          ),
        ],
      ),
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
            'Change technical role',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            enabled
                ? 'Review the current and requested role before confirming.'
                : 'Role changes require a synchronized, non-deleted account.',
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
                label: 'Current: ${currentRole.storageKey}',
              ),
              FilledButton.icon(
                onPressed: enabled
                    ? () {
                        unawaited(onPressed());
                      }
                    : null,
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Change role'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminRoleChangeDialog extends StatefulWidget {
  final AdminUserDetail detail;
  final Future<void> Function({
    required Role role,
    required String reason,
  }) onConfirm;

  const _AdminRoleChangeDialog({
    required this.detail,
    required this.onConfirm,
  });

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
        _errorMessage = 'The role change could not be completed. '
            'Check the account state and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedRole = _selectedRole;

    return AlertDialog(
      scrollable: true,
      title: const Text('Change technical role'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose the new technical role and record why this '
              'change is required.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Role>(
              initialValue: selectedRole,
              decoration: const InputDecoration(
                labelText: 'New technical role',
                border: OutlineInputBorder(),
              ),
              isExpanded: true,
              items: [
                for (final role in Role.values)
                  DropdownMenuItem<Role>(
                    value: role,
                    enabled: role != widget.detail.systemRole,
                    child: Text(role.storageKey),
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
              label: 'Before',
              role: widget.detail.systemRole.storageKey,
              icon: Icons.history,
            ),
            const SizedBox(height: 8),
            _AdminRoleSummaryCard(
              label: 'After',
              role: selectedRole?.storageKey ?? 'Select a role',
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
                        'This change ends the recipient’s active session. '
                        'They must sign in again before continuing to use '
                        'the account.',
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
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'Explain why the technical role must change',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
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
              title: const Text(
                'I confirm the role shown above and understand that '
                'the recipient must sign in again.',
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
          child: const Text('Cancel'),
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
            _isSubmitting ? 'Changing role' : 'Confirm role change',
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
        border: Border.all(
          color: foreground.withValues(alpha: 0.35),
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 5,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: foreground,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: foreground,
              ),
            ),
          ],
        ),
      ),
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
            'Page ${page.page} of $totalPages',
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
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 44),
                ),
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
            Icon(
              Icons.error_outline,
              color: colors.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Could not refresh the indicators.',
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
              child: const Text('Retry'),
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
            Icon(
              Icons.error_outline,
              color: colors.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Could not refresh the account details.',
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
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
