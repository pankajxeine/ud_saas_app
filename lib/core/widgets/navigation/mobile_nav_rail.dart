import 'package:flutter/material.dart'
    hide ButtonStyle, Scaffold, NavigationBar, Divider, Card, Checkbox;

import 'package:ud_sass_app/ui/shadcn/components/control/button/button.dart';
import 'package:ud_sass_app/ui/shadcn/components/display/divider/divider.dart';
import 'package:ud_sass_app/ui/shadcn/components/form/checkbox/checkbox.dart';
import 'package:ud_sass_app/ui/shadcn/components/form/select/select.dart';
import 'package:ud_sass_app/ui/shadcn/components/layout/card/card.dart';
import 'package:ud_sass_app/ui/shadcn/components/layout/outlined_container/outlined_container.dart';
import 'package:ud_sass_app/ui/shadcn/components/layout/scaffold/scaffold.dart';
import 'package:ud_sass_app/ui/shadcn/components/navigation/navigation_bar/navigation_bar.dart';
import 'package:ud_sass_app/ui/shadcn/components/overlay/overlay/overlay.dart';

import 'package:ud_sass_app/ui/shadcn/shared/icons/bootstrap_icons.dart';
// import 'package:ud_sass_app/ui/shadcn/shared/theme/generated_colors.dart';

class MobileModeNavRail extends StatefulWidget {
  const MobileModeNavRail({super.key});

  @override
  State<MobileModeNavRail> createState() => _MobileModeNavRailState();
}

class _MobileModeNavRailState extends State<MobileModeNavRail> {
  int selected = 0;

  NavigationBarAlignment alignment = NavigationBarAlignment.spaceAround;
  bool expands = true;
  NavigationLabelType labelType = NavigationLabelType.none;
  bool customButtonStyle = true;
  bool expanded = true;

  NavigationItem buildButton(String label, IconData icon) {
    return NavigationItem(
      style: customButtonStyle
          ? const ButtonStyle.muted(density: ButtonDensity.icon)
          : null,
      selectedStyle: customButtonStyle
          ? const ButtonStyle.fixed(density: ButtonDensity.icon)
          : null,
      label: Text(label),
      child: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedContainer(
      width: 500,
      height: 400,
      child: Scaffold(
        footers: [
          const Divider(),
          NavigationBar(
            alignment: alignment,
            labelType: labelType,
            expanded: expanded,
            expands: expands,
            onSelected: (index) {
              setState(() {
                selected = index;
              });
            },
            index: selected,
            children: [
              buildButton('Home', BootstrapIcons.house),
              buildButton('Explore', BootstrapIcons.compass),
              buildButton('Library', BootstrapIcons.musicNoteList),
              buildButton('Profile', BootstrapIcons.person),
              buildButton('App', BootstrapIcons.appIndicator),
            ],
          ),
        ],
        child: Container(
          color: Colors.primaries[Colors.primaries.length - selected - 1],
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 8,
              spacing: 8,
              children: [
                // Configure how the items are distributed across the bar.
                Select<NavigationBarAlignment>(
                  value: alignment,
                  itemBuilder:
                      (BuildContext context, NavigationBarAlignment item) {
                    return Text(item.name);
                  },
                  popupWidthConstraint: PopoverConstraint.anchorFixedSize,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        alignment = value;
                      });
                    }
                  },
                  popup: SelectPopup(
                      items: SelectItemList(children: [
                    for (var value in NavigationBarAlignment.values)
                      SelectItemButton(
                        value: value,
                        child: Text(value.name),
                      ),
                  ])),
                ),
                // Control how labels are shown for each navigation item.
                Select<NavigationLabelType>(
                  value: labelType,
                  itemBuilder:
                      (BuildContext context, NavigationLabelType item) {
                    return Text(item.name);
                  },
                  popupWidthConstraint: PopoverConstraint.anchorFixedSize,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        labelType = value;
                      });
                    }
                  },
                  popup: SelectPopup(
                      items: SelectItemList(children: [
                    for (var value in NavigationLabelType.values)
                      SelectItemButton(
                        value: value,
                        child: Text(value.name),
                      ),
                  ])),
                ),
                // Whether the navigation bar can expand to fill width.
                Checkbox(
                  state:
                      expands ? CheckboxState.checked : CheckboxState.unchecked,
                  onChanged: (value) {
                    setState(() {
                      expands = value == CheckboxState.checked;
                    });
                  },
                  trailing: const Text('Expands'),
                ),
                // Use custom button styles for normal vs selected states.
                Checkbox(
                  state: customButtonStyle
                      ? CheckboxState.checked
                      : CheckboxState.unchecked,
                  onChanged: (value) {
                    setState(() {
                      customButtonStyle = value == CheckboxState.checked;
                    });
                  },
                  trailing: const Text('Custom Button Style'),
                ),
                // Toggle the expanded label behavior.
                Checkbox(
                  state: expanded
                      ? CheckboxState.checked
                      : CheckboxState.unchecked,
                  onChanged: (value) {
                    setState(() {
                      expanded = value == CheckboxState.checked;
                    });
                  },
                  trailing: const Text('Expanded'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
