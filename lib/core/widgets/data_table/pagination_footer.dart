import 'package:trina_grid/trina_grid.dart';
import 'package:ud_sass_app/core/widgets/components/tooltip_button.dart';
import 'package:ud_sass_app/ui/shadcn/components/layout/flex/flex.dart';
import 'package:ud_sass_app/ui/shadcn/shared/icons/bootstrap_icons.dart';
import 'package:ud_sass_app/ui/shadcn/shared/theme/theme.dart';

import '../../layouts/responsive.dart';

class PaginationFooter extends StatefulWidget {
  final TrinaGridStateManager stateManager;

  const PaginationFooter({super.key, required this.stateManager});

  @override
  State<PaginationFooter> createState() => _PaginationFooterState();
}

class _PaginationFooterState extends State<PaginationFooter> {
  // Define available page sizes including the default
  final List<int> availablePageSizes = [10, 20, 40, 50, 100];

  // Controller for the page input field
  final TextEditingController _pageController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Ensure state manager is properly initialized and has data
    if (widget.stateManager.refRows.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get pagination values from state manager
    final currentPage = widget.stateManager.page;
    //final pageSize = widget.stateManager.pageSize;
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
          // Page size selector
          // Row(
          //   children: [
          //     const Text('Rows per page:'),
          //     const SizedBox(width: 8),
          //     DropdownButton<int>(
          //       value: pageSize,
          //       items: availablePageSizes.map((size) {
          //         return DropdownMenuItem(value: size, child: Text('$size'));
          //       }).toList(),
          //       onChanged: (newSize) {
          //         if (newSize != null) {
          //           widget.stateManager.setPageSize(newSize);
          //           widget.stateManager.setPage(1);
          //           setState(() {});
          //         }
          //       },
          //     ),
          //   ],
          // ),
          const SizedBox(width: 24),
          // Page navigation controls
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TooltipButton(
                  icon: const Icon(BootstrapIcons.chevronBarLeft),
                  onPressed: currentPage > 1 ? () => _goToPage(1) : null,
                  tooltip: 'First Page',
                ),
                TooltipButton(
                  icon: const Icon(BootstrapIcons.chevronLeft),
                  onPressed:
                      currentPage > 1 ? () => _goToPage(currentPage - 1) : null,
                  tooltip: 'Previous Page',
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
                  icon: const Icon(BootstrapIcons.chevronRight),
                  onPressed: currentPage < totalPage
                      ? () => _goToPage(currentPage + 1)
                      : null,
                  tooltip: 'Next Page',
                ),
                TooltipButton(
                  icon: const Icon(BootstrapIcons.chevronBarRight),
                  onPressed: currentPage < totalPage
                      ? () => _goToPage(totalPage)
                      : null,
                  tooltip: 'Last Page',
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
          )
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
