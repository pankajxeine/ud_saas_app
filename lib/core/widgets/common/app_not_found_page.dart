import 'package:flutter/material.dart' hide Theme;
import 'package:ud_sass_app/core/navigation/app_navigation.dart';
import 'package:ud_sass_app/ui/dashcn/components/button.dart';
import 'package:ud_sass_app/ui/dashcn/theme.dart';
import 'app_page_frame.dart';

class AppNotFoundPage extends StatelessWidget {
  const AppNotFoundPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => AppPageFrame(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_outlined, size: 36),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).typography.h3),
            const SizedBox(height: 8),
            Button(
              variant: ButtonVariant.link,
              onPressed: () => context.go('/'),
              child: const Text('Return to control panel'),
            ),
          ],
        ),
      ),
    ),
  );
}
