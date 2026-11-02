import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ud_sass_app/core/navigation/app_route_definition.dart';
import 'package:ud_sass_app/ui/dashcn/components/app.dart';

PageRoute<T> _buildTestPageRoute<T>(
  RouteSettings settings,
  WidgetBuilder builder,
) => MaterialPageRoute<T>(settings: settings, builder: builder);

void main() {
  test('matches generated route patterns and extracts path parameters', () {
    final AppRouteDefinition route = AppRouteDefinition(
      path: '/items/:id/edit',
      builder: (parameters) => Text(parameters['id']!),
    );

    expect(route.build(Uri.parse('/items/42/edit?tab=details')), isA<Text>());
    expect(route.build(Uri.parse('/items/42')), isNull);
    expect(route.specificity, 2);
  });

  testWidgets('uses imperative named routes and supports push and pop', (
    tester,
  ) async {
    Route<dynamic> buildRoute(RouteSettings settings) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (context) => Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(settings.name ?? 'No route name'),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/details'),
                  child: const Text('Open details'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(
      DashcnApp(
        initialRoute: '/home',
        routes: const <String, WidgetBuilder>{},
        onGenerateRoute: buildRoute,
        onGenerateInitialRoutes: (initialRoute) => <Route<dynamic>>[
          buildRoute(RouteSettings(name: initialRoute)),
        ],
        onUnknownRoute: buildRoute,
        pageRouteBuilder: _buildTestPageRoute,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('/home'), findsOneWidget);

    await tester.tap(find.text('Open details'));
    await tester.pumpAndSettle();
    expect(find.text('/details'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('/home'), findsOneWidget);
  });
}
