# Alamiyah

Calm, spiritually-focused Islamic content app (Dhikr, Dua, prayer-life tools)
built with Flutter for iOS and Android.

See [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) for product and design rules.
See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) before wiring live backend (Phase 2).

## Phase 1 status

Runnable user shell with mock content — no Firebase project required.

```bash
# Ensure Flutter is on PATH (this machine: C:\src\flutter\bin)
flutter pub get
flutter run
```

### Hidden admin route

Long-press the **Alamiyah** title on any tab app bar, or navigate to `/admin`.

## Stack

- Flutter + Riverpod + go_router
- Hive (theme + bookmarks)
- Firebase packages declared; init gated by `FirebaseConfig.isConfigured`
