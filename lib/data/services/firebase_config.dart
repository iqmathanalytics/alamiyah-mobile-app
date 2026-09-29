/// Firebase bootstrap gate.
///
/// Set [isConfigured] to `true` only after running:
/// `flutterfire configure` (generates `lib/firebase_options.dart`).
class FirebaseConfig {
  FirebaseConfig._();

  /// Flip to true after FlutterFire configure succeeds.
  static const bool isConfigured = true;
}
