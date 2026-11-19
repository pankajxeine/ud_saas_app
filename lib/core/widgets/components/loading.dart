import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final String title;
  const Loading({super.key, this.title = 'Loading'});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: _loadingCard(context, title),
    );
  }
}

Widget _loadingCard(BuildContext context, String label) {
  final theme = Theme.of(context);
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      const SizedBox(
        width: 120,
        height: 48,
        child: Center(child: CircularProgressIndicator()),
      ),
      const SizedBox(height: 12),
      Text(label, style: theme.textTheme.bodySmall),
    ],
  );
}
