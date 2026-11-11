import 'package:flutter/widgets.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart';
import 'package:ud_sass_app/ui/dashcn/src/components/border_loading/border_loading.dart';
import 'package:ud_sass_app/ui/dashcn/src/foundation/gap.dart';

class Loading extends StatelessWidget {
  final String title;
  const Loading({super.key, this.title = 'Loading'});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: _borderLoadingCard(
        context,
        title,
        const BorderLoading(child: SizedBox(width: 120, height: 48)),
      ),
    );
  }
}

Widget _borderLoadingCard(BuildContext context, String label, Widget child) {
  final theme = Theme.of(context);
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      child,
      Gap(theme.spacing.sm),
      Text(
        label,
        style: TextStyle(fontSize: 12, color: theme.colors.mutedForeground),
      ),
    ],
  );
}
