// Font families available to the Theme Studio font rows.
//
// The pickers only offer families declared in `App/pubspec.yaml`.
//
// Every entry here must also be listed in `App/pubspec.yaml` under
// `flutter: fonts:` so the file exists in both a `flutter run` and a
// compiled bundle.

import 'package:flutter/services.dart';

/// One bundled family: the CSS-ish spec stored in the app and the
/// asset the loader fetches.
class AppFontFamily {
  /// Creates an entry.
  const AppFontFamily({
    required this.label,
    required this.family,
    required this.assets,
  });

  /// The row label / tooltip name.
  final String label;

  /// The family list stored in the app (what `ThemeFonts` carries).
  final String family;

  /// The asset paths to load, in order.
  final List<String> assets;
}

/// The families offered by the `Heading font` row.
const List<AppFontFamily> kAppHeadingFonts = <AppFontFamily>[
  AppFontFamily(label: 'Default', family: '', assets: <String>[]),
  AppFontFamily(label: 'Geist Sans', family: 'GeistSans', assets: <String>[]),
];

/// The families offered by the `Body font` row.
const List<AppFontFamily> kAppBodyFonts = <AppFontFamily>[
  AppFontFamily(label: 'Default', family: '', assets: <String>[]),
  AppFontFamily(label: 'Geist Sans', family: 'GeistSans', assets: <String>[]),
];

/// The families offered by the `Mono` row (`AnyFamily`).
const List<AppFontFamily> kAppMonoFonts = <AppFontFamily>[
  AppFontFamily(label: 'Default', family: '', assets: <String>[]),
  AppFontFamily(label: 'Geist Mono', family: 'GeistMono', assets: <String>[]),
];

/// The families already loaded this session, keyed by family name.
///
/// A family is either a bundled `pubspec` entry (empty [AppFontFamily
/// .assets] — Geist is already declared) or loaded on demand; both are
/// cached so a re-pick costs nothing.
final Set<String> _loadedFonts = <String>{};

/// Whether [family] has already been made available to the text engine.
bool appFontLoaded(String family) => _loadedFonts.contains(family);

/// Loads [family] (and any family in [extras]) through [FontLoader].
///
/// Families declared in `pubspec.yaml` need no loader call, so only the
/// families with assets are loaded. Unknown or missing families fail
/// silently: the family then falls back to the bundled default, which is
/// what a real font picker must do on a flaky network.
Future<void> loadAppFonts(
  String family, {
  Set<String> extras = const <String>{},
}) async {
  final Set<String> pending = <String>{
    for (final String name in <String>{family, ...extras})
      if (name.isNotEmpty &&
          !_loadedFonts.contains(name) &&
          (appFontAsset(name)?.isNotEmpty ?? false))
        name,
  };
  for (final String name in pending) {
    _loadedFonts.add(name);
    final List<String> paths = appFontAsset(name)!;
    final FontLoader loader = FontLoader(name);
    for (final String path in paths) {
      loader.addFont(rootBundle.load(path));
    }
    try {
      await loader.load();
    } on Object {
      // Offline or missing asset: keep the default family rather than break
      // the site. The selection still persists and applies on the next load.
      _loadedFonts.remove(name);
    }
  }
}

/// The asset paths for [family], or null when it is a declared family.
///
/// Returns an empty list for the `pubspec` families (Geist, the bundled
/// default), so they never go through [FontLoader].
List<String>? appFontAsset(String family) {
  for (final AppFontFamily entry in <AppFontFamily>[
    ...kAppHeadingFonts,
    ...kAppBodyFonts,
    ...kAppMonoFonts,
  ]) {
    if (entry.family == family) {
      return entry.assets;
    }
  }
  return null;
}
