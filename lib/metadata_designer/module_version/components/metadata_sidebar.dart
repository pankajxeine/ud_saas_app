// import 'package:flutter/dart' as material;
import 'package:flutter/widgets.dart';
import 'package:ud_sass_app/ui/dashcn/src/components/sidebar/sidebar.dart';
import 'package:ud_sass_app/ui/dashcn/src/components/divider/divider.dart';
import 'package:ud_sass_app/ui/dashcn/src/foundation/icons/lucide_icons.dart';
import 'package:ud_sass_app/ui/dashcn/src/theme/theme.dart';

class MetadataSidebar extends StatelessWidget {
  final String selectedSection;
  final ValueChanged<String> onSectionSelected;

  const MetadataSidebar({
    super.key,
    required this.selectedSection,
    required this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colors.background,

      child: DashboardSidebar(
        title: "Desinger Editor",
        sections: _sampleSections(context),
        // selectedId: _selected,
        //onSelected: (String id) => setState(() => _selected = id),
        collapsed: true,
        onUserPressed: () {},
      ),
    );
  }

  /// Sample navigation shared by the examples.
  List<SidebarSection> _sampleSections([BuildContext? context]) {
    return const <SidebarSection>[
      SidebarSection(
        label: 'Main',
        items: <SidebarItem>[
          SidebarItem(label: 'General', icon: LucideIcons.settings2),
          SidebarItem(label: 'API', icon: LucideIcons.appWindow, badge: '12'),
          SidebarItem(label: 'Grid & Search', icon: LucideIcons.grid2x2),
          SidebarItem(label: 'Fields', icon: LucideIcons.view),
          SidebarItem(label: 'Details', icon: LucideIcons.view),
          SidebarItem(label: 'Preview', icon: LucideIcons.view),
          SidebarItem(label: 'Preview', icon: LucideIcons.view),
        ],
      ),
      SidebarSection(
        label: 'Json Editor',
        items: <SidebarItem>[
          SidebarItem(label: 'Settings', icon: LucideIcons.settings),
          SidebarItem(label: 'Preview', icon: LucideIcons.circleHelp),
        ],
      ),
    ];
  }

  // Widget _buildHeader(BuildContext context) {
  //   return Padding(
  //     padding: const EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Metadata Designer',
  //           style: Theme.of(
  //             context,
  //           ).typography.medium.copyWith(fontWeight: FontWeight.w700),
  //         ),
  //         const SizedBox(height: 4),
  //         Text(
  //           'Configure your entity',
  //           style: Theme.of(
  //             context,
  //           ).typography.small.copyWith(color: Coclors.grey),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildItem(BuildContext context, _SidebarItem item) {
  //   final bool selected = selectedSection == item.id;

  //   final colorScheme = Theme.of(context).colors;

  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 4),
  //     child: Material(
  //       color: selected
  //           ? colorScheme.primary.withValues(alpha: 0.10)
  //           : Colors.transparent,
  //       borderRadius: BorderRadius.circular(8),
  //       child: InkWell(
  //         borderRadius: BorderRadius.circular(8),
  //         onTap: () => onSectionSelected(item.id),
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //           child: Row(
  //             children: [
  //               Icon(
  //                 item.icon,
  //                 size: 19,
  //                 color: selected
  //                     ? colorScheme.primary
  //                     : colorScheme.onSurfaceVariant,
  //               ),
  //               const SizedBox(width: 10),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       item.title,
  //                       maxLines: 1,
  //                       overflow: TextOverflow.ellipsis,
  //                       style: TextStyle(
  //                         fontSize: 13,
  //                         fontWeight: selected
  //                             ? FontWeight.w600
  //                             : FontWeight.w500,
  //                         color: selected
  //                             ? colorScheme.primary
  //                             : colorScheme.onSurface,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 2),
  //                     Text(
  //                       item.subtitle,
  //                       maxLines: 1,
  //                       overflow: TextOverflow.ellipsis,
  //                       style: TextStyle(
  //                         fontSize: 10,
  //                         color: colorScheme.onSurfaceVariant,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               if (selected)
  //                 Icon(
  //                   Icons.chevron_right,
  //                   size: 18,
  //                   color: colorScheme.primary,
  //                 ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(LucideIcons.info, size: 16, color: Color(0xFFB42318)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Metadata configuration',
              style: Theme.of(
                context,
              ).typography.small.copyWith(color: Color(0xFFB42318)),
            ),
          ),
        ],
      ),
    );
  }
}

// class _SidebarItem {
//   final String id;
//   final String title;
//   final String subtitle;
//   final IconData icon;

//   const _SidebarItem({
//     required this.id,
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//   });
// }
