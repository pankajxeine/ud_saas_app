import 'package:flutter/material.dart' hide IconButton, Theme;
import 'package:trina_grid/trina_grid.dart';
import 'package:ud_sass_app/core/widgets/components/tooltip_button.dart';
import 'package:ud_sass_app/ui/dashcn/components/button.dart';
import 'package:ud_sass_app/ui/dashcn/src/foundation/icons/bootstrap_icons.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart';

import '../../layouts/responsive.dart';

class PaginationFooter extends StatefulWidget {
  final TrinaGridStateManager stateManager;

  const PaginationFooter({super.key, required this.stateManager});

  @override
  State<PaginationFooter> createState() => _PaginationFooterState();
}

class _PaginationFooterState extends State<PaginationFooter> {
  // Define available page sizes including the default
  final List<int> availablePageSizes = [10, 20, 25, 40, 50, 100];

  // Controller for the page input field
  final TextEditingController _pageController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colors;
    // Ensure state manager is properly initialized and has data
    if (widget.stateManager.refRows.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get pagination values from state manager
    final currentPage = widget.stateManager.page;
    final pageSize = widget.stateManager.pageSize;
    final totalPage = widget.stateManager.totalPage;
    final totalRows = widget.stateManager.refRows.length;

    // Update the text controller when current page changes
    if (_pageController.text != currentPage.toString()) {
      _pageController.text = currentPage.toString();
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        //color: cs.cardForeground,
        border: Border(top: BorderSide(color: cs.border)),
      ),
      child: Row(
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: availablePageSizes.contains(pageSize) ? pageSize : null,
              hint: const Text('Rows'),
              isDense: true,
              items: availablePageSizes
                  .map(
                    (size) => DropdownMenuItem<int>(
                      value: size,
                      child: Text('$size / page'),
                    ),
                  )
                  .toList(),
              onChanged: (newSize) {
                if (newSize != null) {
                  widget.stateManager.setPageSize(newSize);
                  widget.stateManager.setPage(1);
                  setState(() {});
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          // Page navigation controls
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TooltipButton(
                  size: ButtonSize.icon,
                  onPressed: currentPage > 1 ? () => _goToPage(1) : null,
                  label: 'First Page',
                  child: const Icon(BootstrapIcons.chevronBarLeft),
                ),
                const SizedBox(width: 8),
                TooltipButton(
                  variant: ButtonVariant.outline,
                  size: ButtonSize.icon,
                  onPressed: currentPage > 1
                      ? () => _goToPage(currentPage - 1)
                      : null,
                  label: 'Previous Page',
                  child: const Icon(BootstrapIcons.chevronLeft),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    // color: cs.accent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cs.primary),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Page $currentPage of $totalPage ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),

                      // Direct page input field
                      // SizedBox(
                      //   width: 50,
                      //   child: TextField(
                      //     controller: _pageController,
                      //     textAlign: TextAlign.center,
                      //     keyboardType: TextInputType.number,
                      //     style: TextStyle(
                      //       fontWeight: FontWeight.bold,
                      //       color: cs.primaryForeground,
                      //     ),
                      //     // decoration: InputDecoration(
                      //     //   border: InputBorder.none,
                      //     //   contentPadding: EdgeInsets.zero,
                      //     //   isDense: true,
                      //     // ),
                      //     // onSubmitted: (value) {
                      //     //   _goToPageFromInput(value);
                      //     // },
                      //     // onEditingComplete: () {
                      //     //   _goToPageFromInput(_pageController.text);
                      //     // },
                      //   ),
                      // ),
                    ],
                  ),
                ),
                TooltipButton(
                  size: ButtonSize.icon,
                  onPressed: currentPage < totalPage
                      ? () => _goToPage(currentPage + 1)
                      : null,
                  label: 'Next Page',
                  child: const Icon(BootstrapIcons.chevronRight),
                ),
                const SizedBox(width: 8),
                TooltipButton(
                  size: ButtonSize.icon,
                  onPressed: currentPage < totalPage
                      ? () => _goToPage(totalPage)
                      : null,
                  label: 'Last Page',
                  child: const Icon(BootstrapIcons.chevronBarRight),
                ),
              ],
            ),
          ),
          // Total records display
          Visibility(
            visible: !ResponsiveLayout.isMobile(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: cs.primaryForeground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(BootstrapIcons.infoCircle, size: 16, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(
                    '$totalRows total records',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToPage(int page) {
    widget.stateManager.setPage(page);
    setState(() {}); // Trigger rebuild to update UI
  }

  // void _goToPageFromInput(String input) {
  //   final page = int.tryParse(input);
  //   if (page != null && page >= 1 && page <= widget.stateManager.totalPage) {
  //     _goToPage(page);
  //   } else {
  //     // Reset to current page if input is invalid
  //     _pageController.text = widget.stateManager.page.toString();
  //     // Show a brief feedback that the input was invalid
  //     // ScaffoldMessenger.of(context).showSnackBar(
  //     //   SnackBar(
  //     //     content: Text(
  //     //       'Please enter a valid page number between 1 and ${widget.stateManager.totalPage}',
  //     //     ),
  //     //     duration: const Duration(seconds: 2),
  //     //     backgroundColor: Colors.red,
  //     //   ),
  //     // );
  //   }
  // }
}
