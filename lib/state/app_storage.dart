// Where the App preferences live (spec §1.1/§1.3): `window.localStorage` on
// web through the existing web bridge, a no-op everywhere else (tests inject
// a memory-backed instance).
//
// Split out of `app_state.dart` so both the shell state and the Theme
// Studio's site-wide theme model can depend on it without importing each
// other.

import '../web_bridge.dart';

/// Reads and writes the app preference keys.
class AppStorage {
  /// Creates the default, platform-selecting storage.
  const AppStorage();

  /// Reads [key], or null.
  String? read(String key) => webLocalStorageRead(key);

  /// Writes [key] = [value]. An empty [value] clears the entry (the bridge
  /// has no `removeItem`, matching the shell's existing convention).
  void write(String key, String value) => webLocalStorageWrite(key, value);
}

/// localStorage keys for the theme preferences.
const String kAppPresetKey = 'app.theme.presetId';
const String kAppBrightnessKey = 'app.theme.brightness';

/// localStorage key of the whole Theme Studio document (D7).
///
/// The document is the source of truth for every token, so it is stored as
/// one canonical preset JSON rather than as a bag of scalar overrides: a
/// reload then restores exactly what the user built, including fonts, shadow
/// atoms and both colour blocks.
const String kAppThemeDocumentKey = 'App.theme.document';

/// localStorage key of the Theme Studio switch animation (P7-TS1).
///
/// Chrome, not content: it is stored beside the document (never inside it),
/// so it survives `Reset` and never leaks into `Get Code` exports.
const String kAppTransitionKey = 'app.theme.transition';

/// How a site-wide theme switch animates (P7-TS1, rail `Transition` row).
///
/// Every variant is snapshot based — the content tree builds exactly once
/// per commit and only the old frame's raster animates — and reduced motion
/// always swaps instantly regardless of the choice.
enum AppThemeTransition {
  /// Instant swap, no snapshot, no animation.
  none,

  /// The old frame fades over the new one (~250 ms).
  fade,

  /// An expanding hole reveals the new frame from the tap point (~350 ms).
  circular,

  /// The old frame slides away, revealing the new one (~300 ms).
  wipe,

  /// The old frame blurs as it dissolves into the new one (~300 ms).
  blur;

  /// Parses a stored [name]; unknown values fall back to [fade].
  static AppThemeTransition parse(String? name) => switch (name) {
    'none' => AppThemeTransition.none,
    'circular' => AppThemeTransition.circular,
    'wipe' => AppThemeTransition.wipe,
    'blur' => AppThemeTransition.blur,
    _ => AppThemeTransition.fade,
  };
}

/// The rail label of [transition].
String appTransitionLabel(AppThemeTransition transition) =>
    switch (transition) {
      AppThemeTransition.none => 'None',
      AppThemeTransition.fade => 'Fade',
      AppThemeTransition.circular => 'Circular',
      AppThemeTransition.wipe => 'Wipe',
      AppThemeTransition.blur => 'Blur',
    };
