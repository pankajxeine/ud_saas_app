import 'dart:convert';

import 'package:flutter/material.dart' hide Theme, Card, Divider, Tooltip;
import 'package:ud_sass_app/core/navigation/app_navigation.dart';
import 'package:ud_sass_app/ui/dashcn/dashcn.dart';
import '../../../core/widgets/common/common_widgets.dart';
import '../cpanel_catalog.dart';

class CpanelLiveMetricCard extends StatelessWidget {
  const CpanelLiveMetricCard({
    super.key,
    required this.metric,
    required this.accent,
    required this.count,
  });

  final CpanelMetric metric;
  final Color accent;
  final Future<int?> count;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: count,
      builder: (context, snapshot) => AppMetricCard(
        label: metric.label,
        value: snapshot.connectionState == ConnectionState.waiting
            ? '…'
            : snapshot.data?.toString() ?? '—',
        icon: metric.icon,
        accent: accent,
      ),
    );
  }
}

class CpanelCategoryCard extends StatelessWidget {
  const CpanelCategoryCard({super.key, required this.category});

  final CpanelCategory category;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;
    return Button(
      variant: ButtonVariant.ghost,
      onPressed: () => context.go(category.path),
      child: Container(
        constraints: const BoxConstraints(minHeight: 154),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIconTile(icon: category.icon, accent: category.accent),
                const Spacer(),
                Icon(
                  Icons.arrow_outward_rounded,
                  size: 18,
                  color: colors.mutedForeground,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              category.title,
              style: Theme.of(
                context,
              ).typography.h4.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 5),
            Text(
              category.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).typography.small.copyWith(color: colors.mutedForeground),
            ),
            const SizedBox(height: 12),
            Text(
              '${category.featureCount} features',
              style: Theme.of(context).typography.textSmall.copyWith(
                color: category.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CpanelFeatureCard extends StatelessWidget {
  const CpanelFeatureCard({
    super.key,
    required this.feature,
    required this.accent,
  });

  final CpanelFeature feature;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;
    return Button(
      onPressed: () => context.push('/cpanel/modules/${feature.slug}'),
      child: Container(
        constraints: const BoxConstraints(minHeight: 132),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIconTile(icon: feature.icon, accent: accent, size: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.title,
                    style: Theme.of(
                      context,
                    ).typography.large.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    feature.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).typography.small.copyWith(color: colors.mutedForeground),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Open module',
                        style: Theme.of(context).typography.textSmall.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 14, color: accent),
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

class CpanelBreadcrumb extends StatelessWidget {
  const CpanelBreadcrumb({super.key, required this.category, this.current});

  final CpanelCategory category;
  final String? current;

  @override
  Widget build(BuildContext context) => AppBreadcrumb(
    homeLabel: 'Control panel',
    items: [
      AppBreadcrumbItem(
        label: category.title,
        onPressed: () => context.go(category.path),
      ),
    ],
    current: current,
  );
}

class CpanelModuleDataPanel extends StatelessWidget {
  const CpanelModuleDataPanel({
    super.key,
    required this.feature,
    required this.loading,
    required this.error,
    required this.rows,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.searchController,
    required this.onSearchChanged,
    required this.onPrevious,
    required this.onNext,
    required this.onRetry,
  });

  final CpanelFeature feature;
  final bool loading;
  final String? error;
  final List<Map<String, dynamic>> rows;
  final int? total;
  final int page;
  final int pageSize;
  final TextEditingController searchController;
  final VoidCallback onSearchChanged;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;
    final columns = rows.isEmpty
        ? const <String>[]
        : rows.first.keys
              .where(
                (key) => !RegExp(
                  r'password|secret|token|credential',
                  caseSensitive: false,
                ).hasMatch(key),
              )
              .toList();
    final totalPages = total == null
        ? null
        : (total! / pageSize).ceil().clamp(1, 1 << 30);
    return Card(
      padding: EdgeInsets.zero,
      borderColor: const ThemedColor.ref(ColorRef.border, alpha: .2),
      borderWidth: 1,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final info = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Records',
                      style: Theme.of(
                        context,
                      ).typography.large.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${total ?? rows.length} total',
                      style: Theme.of(context).typography.small.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                );
                final search = Input(
                  controller: searchController,
                  onChanged: (_) => onSearchChanged(),
                  placeholder: const Text('Search this page'),
                  borderRadius: BorderRadius.circular(8),
                  filled: true,
                  features: const [
                    InputLeadingFeature(Icon(Icons.search, size: 18)),
                  ],
                );
                if (constraints.maxWidth < 560) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [info, const SizedBox(height: 12), search],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: info),
                    SizedBox(width: 250, child: search),
                  ],
                );
              },
            ),
          ),
          const Divider(),
          if (loading)
            const SizedBox(
              height: 240,
              child: Center(child: Progress(semanticsLabel: 'Loading')),
            )
          else if (error != null)
            SizedBox(
              height: 240,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_outlined, size: 30),
                    const SizedBox(height: 10),
                    const Text('Could not load this module.'),
                    const SizedBox(height: 10),
                    Button(
                      variant: ButtonVariant.outline,
                      onPressed: onRetry,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh),
                          SizedBox(width: 8),
                          Text('Retry'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (rows.isEmpty)
            SizedBox(
              height: 220,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 34,
                      color: colors.mutedForeground,
                    ),
                    const SizedBox(height: 10),
                    const Text('No records found'),
                    const SizedBox(height: 4),
                    Text(
                      feature.endpoint,
                      style: Theme.of(context).typography.small.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Table(
                  defaultColumnWidth: const FixedColumnWidth(170),
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: colors.border.withValues(alpha: .16),
                    ),
                  ),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: colors.muted),
                      children: [
                        for (final column in columns)
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              _humanize(column),
                              style: Theme.of(context).typography.small
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                    for (final row in rows)
                      TableRow(
                        children: [
                          for (final column in columns)
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                _displayValue(row[column]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    totalPages == null
                        ? 'Page $page'
                        : 'Page $page of $totalPages',
                    style: Theme.of(
                      context,
                    ).typography.small.copyWith(color: colors.mutedForeground),
                  ),
                ),
                Tooltip(
                  tooltip: (_) => const Text('Previous page'),
                  child: Button(
                    variant: ButtonVariant.ghost,
                    onPressed: onPrevious,
                    child: const Icon(Icons.chevron_left),
                  ),
                ),
                Tooltip(
                  tooltip: (_) => const Text('Next page'),
                  child: Button(
                    variant: ButtonVariant.ghost,
                    onPressed: onNext,
                    child: const Icon(Icons.chevron_right),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CpanelSensitiveNotice extends StatelessWidget {
  const CpanelSensitiveNotice({super.key, required this.feature});

  final CpanelFeature feature;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colors;
    return Card(
      padding: const EdgeInsets.all(24),
      borderColor: const ThemedColor.ref(ColorRef.border, alpha: .2),
      borderWidth: 1,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, size: 28),
          const SizedBox(height: 12),
          Text(
            'Protected module',
            style: Theme.of(
              context,
            ).typography.large.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            feature.description,
            style: Theme.of(
              context,
            ).typography.p.copyWith(color: colors.mutedForeground),
          ),
          const SizedBox(height: 10),
          const Text(
            'Records are intentionally not loaded into the generic browser.',
          ),
        ],
      ),
    );
  }
}

String _humanize(String value) => value
    .replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (match) => '${match[1]} ${match[2]}',
    )
    .replaceAll('_', ' ')
    .split(' ')
    .where((part) => part.isNotEmpty)
    .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
    .join(' ');

String _displayValue(dynamic value) {
  if (value == null) return '—';
  if (value is Map || value is List) return jsonEncode(value);
  return value.toString();
}
