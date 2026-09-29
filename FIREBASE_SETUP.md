# Firebase Setup — Alamiyah (Phase 2)

Complete these steps to unlock live admin CMS + user feed from Firestore.

## Prerequisites

- Google account
- Node.js / npm (already available on this machine)
- Flutter on PATH (`C:\src\flutter\bin`)
- Keep `GRADLE_USER_HOME` and `PUB_CACHE` on the **same drive** as the project (`E:\dev-cache\...`)

## 1. Create Firebase project

1. Open https://console.firebase.google.com/
2. **Add project** → e.g. `alamiyah-app`
3. Enable:
   - **Authentication** → Email/Password
   - **Firestore Database** (start in test mode briefly, then deploy rules below)
   - **Storage**
4. Register Android app with package `com.alamiyah.alamiyah`

## 2. Install CLIs (one-time)

```powershell
npm install -g firebase-tools
$env:PATH = "C:\src\flutter\bin;E:\dev-cache\pub-cache\bin;$env:PATH"
dart pub global activate flutterfire_cli
```

## 3. Configure FlutterFire

```powershell
$env:PATH = "C:\src\flutter\bin;E:\dev-cache\pub-cache\bin;$env:PATH"
$env:GRADLE_USER_HOME = "E:\dev-cache\gradle"
$env:PUB_CACHE = "E:\dev-cache\pub-cache"
cd e:\Alamiyah-Application

firebase login
flutterfire configure --project=YOUR_PROJECT_ID
```

This creates `lib/firebase_options.dart` and Android/iOS config files.

## 4. Enable in the app

1. In [`lib/data/services/firebase_config.dart`](lib/data/services/firebase_config.dart):

```dart
static const bool isConfigured = true;
```

2. In [`lib/main.dart`](lib/main.dart), change Firebase init to:

```dart
import 'firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## 5. Deploy security rules

```powershell
firebase deploy --only firestore:rules,storage
```

Project includes:

- [`firestore.rules`](firestore.rules)
- [`storage.rules`](storage.rules)

## 6. First admin

1. Long-press **Alamiyah** on the home app bar → Admin
2. Choose **First owner** → create name/email/password
3. Sign in → create content → Publish
4. Pull-to-refresh the user Home feed — published items appear live

Invite more admins from **Admins** tab (owners only). Invitees use **Accept invite**.

## Hybrid behavior

| `FirebaseConfig.isConfigured` | User feed | Admin |
|---|---|---|
| `false` | Mock JSON | Shows setup instructions |
| `true` | Firestore | Full CMS |

## Windows dual-drive note

If Kotlin build fails with “different roots”, ensure pub cache is on `E:`:

```powershell
[Environment]::SetEnvironmentVariable('PUB_CACHE', 'E:\dev-cache\pub-cache', 'User')
[Environment]::SetEnvironmentVariable('GRADLE_USER_HOME', 'E:\dev-cache\gradle', 'User')
```
