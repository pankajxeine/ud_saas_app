import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ud_sass_app/templates/shadcn_app_template.dart';
import 'package:ud_sass_app/ui/shadcn/components/layout/scaffold/scaffold.dart'
    as shadcn_scaffold;
import 'package:ud_sass_app/ui/shadcn/components/navigation/navigation_bar/navigation_bar.dart'
    as navigation_bar;

void main() {
  testWidgets(
    'renders the shadcn app shell with header, sidebar, content and footer',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ShadcnAppTemplate(
            title: 'Workspace overview',
            currentRoute: '/dashboard',
            content: Center(child: Text('Main content')),
          ),
        ),
      );

      expect(find.byType(shadcn_scaffold.AppBar), findsOneWidget);
      expect(find.byType(navigation_bar.NavigationSidebar), findsOneWidget);
      expect(find.text('Workspace overview'), findsOneWidget);
      expect(find.text('Main content'), findsOneWidget);
      expect(find.text('© 2025 Workspace'), findsOneWidget);
    },
  );
}
