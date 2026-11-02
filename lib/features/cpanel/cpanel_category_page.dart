import 'package:flutter/material.dart' hide Theme;
import '../../core/widgets/common/common_widgets.dart';
import 'cpanel_catalog.dart';
import 'cpanel_data_helpers.dart';
import 'widgets/cpanel_widgets.dart';

class CpanelCategoryPage extends StatefulWidget {
  const CpanelCategoryPage({super.key, required this.categorySlug});

  final String categorySlug;

  @override
  State<CpanelCategoryPage> createState() => _CpanelCategoryPageState();
}

class _CpanelCategoryPageState extends State<CpanelCategoryPage> {
  late final CpanelCategory? _category = cpanelCategoryFor(widget.categorySlug);
  late final Map<String, Future<int?>> _metricCounts = {
    for (final metric in _category?.metrics ?? const <CpanelMetric>[])
      metric.label: loadCpanelCount(metric.endpoint),
  };

  @override
  Widget build(BuildContext context) {
    final category = _category;
    if (category == null) {
      return const AppNotFoundPage(title: 'Category not found');
    }

    return AppPageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CpanelBreadcrumb(category: category),
          const SizedBox(height: 18),
          AppPageHeading(
            eyebrow: 'CONTROL PANEL / ${category.title.toUpperCase()}',
            title: category.title,
            description: category.description,
            icon: category.icon,
            accent: category.accent,
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final metric in category.metrics)
                CpanelLiveMetricCard(
                  metric: metric,
                  accent: category.accent,
                  count: _metricCounts[metric.label]!,
                ),
            ],
          ),
          const SizedBox(height: 30),
          for (final group in category.groups) ...[
            AppSectionHeading(
                title: group.title,
                trailing:
                    '${group.features.length} ${group.features.length == 1 ? 'feature' : 'features'}'),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1000
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
                    for (final feature in group.features)
                      SizedBox(
                        width: width,
                        child: CpanelFeatureCard(
                            feature: feature, accent: category.accent),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}
