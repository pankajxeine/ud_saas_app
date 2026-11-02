import 'package:flutter/material.dart' hide Theme;
import '../../core/widgets/common/common_widgets.dart';
import 'cpanel_catalog.dart';
import 'widgets/cpanel_widgets.dart';

class CpanelHomePage extends StatelessWidget {
  const CpanelHomePage({super.key});

  @override
  Widget build(BuildContext context) => AppPageFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppPageHeading(
              eyebrow: 'CONTROL PANEL',
              title: 'Control panel',
              description:
                  'Manage access, organizations, subscriptions, and platform operations.',
            ),
            const SizedBox(height: 24),
            const Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                AppMetricCard(
                    label: 'Categories',
                    value: '7',
                    icon: Icons.grid_view_rounded,
                    accent: Color(0xFF356AC3)),
                AppMetricCard(
                    label: 'Manageable modules',
                    value: '57',
                    icon: Icons.widgets_outlined,
                    accent: Color(0xFF167D72)),
                AppMetricCard(
                    label: 'Access layers',
                    value: '2',
                    icon: Icons.security_outlined,
                    accent: Color(0xFF7356A4)),
              ],
            ),
            const SizedBox(height: 30),
            const AppSectionHeading(
                title: 'Management areas',
                trailing: 'Select an area to continue'),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1040
                    ? 3
                    : constraints.maxWidth >= 680
                        ? 2
                        : 1;
                const spacing = 14.0;
                final width =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final category in cpanelCategories)
                      SizedBox(
                        width: width,
                        child: CpanelCategoryCard(category: category),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      );
}
