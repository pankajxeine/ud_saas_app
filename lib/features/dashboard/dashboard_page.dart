import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:ud_sass_app/core/navigation/app_navigation.dart';
import 'package:intl/intl.dart';
import 'package:ud_sass_app/core/config/local_storage.dart';
import 'package:ud_sass_app/features/cpanel/cpanel_pages.dart';
import 'package:ud_sass_app/ui/dashcn/components/button.dart';
import 'package:ud_sass_app/ui/dashcn/src/foundation/icons/bootstrap_icons.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const _metrics = <_DashboardMetric>[
    _DashboardMetric(
      title: 'Administrator users',
      value: '1,284',
      detail: 'Sample total · 18 added this month',
      icon: BootstrapIcons.people,
      accent: Color(0xFF167D72),
      route: '/cpanel/modules/admin_users',
    ),
    _DashboardMetric(
      title: 'Roles',
      value: '34',
      detail: 'Sample total · 6 role templates',
      icon: BootstrapIcons.badge3d,
      accent: Color(0xFF356AC3),
      route: '/cpanel/modules/roles',
    ),
    _DashboardMetric(
      title: 'Permission grants',
      value: '128',
      detail: 'Sample total · across 18 modules',
      icon: BootstrapIcons.lock,
      accent: Color(0xFF7356A4),
      route: '/cpanel/modules/role_module_permissions',
    ),
    _DashboardMetric(
      title: 'Organizations',
      value: '62',
      detail: 'Sample total · 4 awaiting setup',
      icon: BootstrapIcons.lock,
      accent: Color(0xFF3C758A),
      route: '/cpanel/modules/institutes',
    ),
    _DashboardMetric(
      title: 'Packages',
      value: '18',
      detail: 'Sample total · 12 currently active',
      icon: BootstrapIcons.lock,
      accent: Color(0xFFBA6A22),
      route: '/cpanel/modules/packages',
    ),
    _DashboardMetric(
      title: 'Open tickets',
      value: '07',
      detail: 'Sample total · 2 marked urgent',
      icon: BootstrapIcons.lock,
      accent: Color(0xFFB4515C),
      route: '/cpanel/modules/service_tickets',
    ),
  ];

  DateTime _now = DateTime.now();
  String? _username;
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _loadUsername();
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  Future<void> _loadUsername() async {
    try {
      final savedName = await AppLocalStorage().read(StorageKeys.username.name);
      if (!mounted) return;
      setState(() {
        final value = savedName?.toString().trim();
        _username = value == null || value.isEmpty ? null : value;
      });
    } catch (_) {
      if (mounted) setState(() => _username = null);
    }
  }

  String get _greeting {
    if (_now.hour < 12) return 'Good morning';
    if (_now.hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;
    final displayName = _username ?? 'there';
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Breadcrumb(),
              const SizedBox(height: 18),
              _WelcomePanel(
                greeting: '$_greeting, $displayName',
                date: DateFormat('EEEE, MMMM d, y').format(_now),
                time: DateFormat('h:mm:ss a').format(_now),
              ),
              const SizedBox(height: 28),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Workspace overview',
                          style: Theme.of(
                            context,
                          ).typography.h3.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'A quick view of the teams and systems you manage.',
                          style: Theme.of(context).typography.p.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.muted,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'SAMPLE METRICS',
                      style: Theme.of(context).typography.small.copyWith(
                        color: colors.mutedForeground,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1040
                      ? 3
                      : constraints.maxWidth >= 620
                      ? 2
                      : 1;
                  const gap = 14.0;
                  final width =
                      (constraints.maxWidth - gap * (columns - 1)) / columns;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final metric in _metrics)
                        SizedBox(
                          width: width,
                          child: _MetricTile(metric: metric),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Management areas',
                      style: Theme.of(
                        context,
                      ).typography.h3.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    '${cpanelCategories.length} categories',
                    style: Theme.of(
                      context,
                    ).typography.small.copyWith(color: colors.mutedForeground),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1040
                      ? 3
                      : constraints.maxWidth >= 650
                      ? 2
                      : 1;
                  const gap = 12.0;
                  final width =
                      (constraints.maxWidth - gap * (columns - 1)) / columns;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final category in cpanelCategories)
                        SizedBox(
                          width: width,
                          child: _CategoryLink(category: category),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardMetric {
  const _DashboardMetric({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
    required this.accent,
    required this.route,
  });

  final String title;
  final String value;
  final String detail;
  final IconData icon;
  final Color accent;
  final String route;
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb();

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colors.mutedForeground;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 7,
      children: [
        Text(
          'Workspace',
          style: Theme.of(context).typography.medium.copyWith(color: muted),
        ),
        Icon(BootstrapIcons.chevronLeft, size: 16, color: muted),
        Text(
          'Control panel',
          style: Theme.of(context).typography.medium.copyWith(color: muted),
        ),
        Icon(BootstrapIcons.chevronRight, size: 16, color: muted),
        Text(
          'Dashboard',
          style: Theme.of(
            context,
          ).typography.medium.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({
    required this.greeting,
    required this.date,
    required this.time,
  });

  final String greeting;
  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF173F3A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF245E54)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dateBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LOCAL TIME',
                style: TextStyle(
                  color: Color(0xFF9FD3C9),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                time,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: const TextStyle(color: Color(0xFFC1D8D4), fontSize: 12),
              ),
            ],
          );
          final greetingBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CONTROL PANEL',
                style: TextStyle(
                  color: Color(0xFF9FD3C9),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                greeting,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).typography.medium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Here is what is happening across your workspace today.',
                style: TextStyle(color: Color(0xFFC1D8D4)),
              ),
            ],
          );

          if (constraints.maxWidth < 560) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                greetingBlock,
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.only(top: 14),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFF37685F))),
                  ),
                  child: dateBlock,
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: greetingBlock),
              const SizedBox(width: 28),
              Container(
                constraints: const BoxConstraints(minWidth: 195),
                padding: const EdgeInsets.only(left: 24),
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: Color(0xFF37685F))),
                ),
                child: dateBlock,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric});

  final _DashboardMetric metric;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;
    return Button(
      onPressed: () => context.push(metric.route),
      child: Container(
        constraints: const BoxConstraints(minHeight: 158),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: metric.accent.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(metric.icon, color: metric.accent, size: 19),
                ),
                const Spacer(),
                Icon(
                  BootstrapIcons.arrowDownRightCircle,
                  size: 17,
                  color: colors.mutedForeground,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              metric.title,
              style: Theme.of(
                context,
              ).typography.small.copyWith(color: colors.mutedForeground),
            ),
            const SizedBox(height: 2),
            Text(
              metric.value,
              style: Theme.of(
                context,
              ).typography.x2Large.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            Text(
              metric.detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).typography.small.copyWith(color: colors.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryLink extends StatelessWidget {
  const _CategoryLink({required this.category});

  final CpanelCategory category;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;
    return Button(
      onPressed: () => context.push(category.path),
      child: Container(
        constraints: const BoxConstraints(minHeight: 92),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: category.accent.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(category.icon, size: 19, color: category.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).typography.large.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${category.featureCount} features',
                    style: Theme.of(
                      context,
                    ).typography.small.copyWith(color: colors.mutedForeground),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              BootstrapIcons.arrowDownLeftCircle,
              size: 17,
              color: category.accent,
            ),
          ],
        ),
      ),
    );
  }
}
