// import 'package:flutter/dart' as material;
import 'package:flutter/widgets.dart';
import 'package:ud_sass_app/ui/dashcn/src/components/sidebar/sidebar.dart';
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
        selectedId: selectedSection,
        sections: _sampleSections(context),
        // selectedId: _selected,
        onSelected: (String id) => {print("ID : $id"), onSectionSelected(id)},
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
          SidebarItem(
            id: "general",
            label: 'General',
            icon: LucideIcons.settings2,
          ),
          SidebarItem(
            id: "api",
            label: 'API',
            icon: LucideIcons.appWindow,
            badge: '12',
          ),
          SidebarItem(
            id: "grid",
            label: 'Grid & Search',
            icon: LucideIcons.grid2x2,
          ),
          SidebarItem(id: "fields", label: 'Fields', icon: LucideIcons.view),
          SidebarItem(id: "preview", label: 'Details', icon: LucideIcons.view),
          SidebarItem(id: "json", label: 'Preview', icon: LucideIcons.view),
        ],
      ),
    ];
  }
}
