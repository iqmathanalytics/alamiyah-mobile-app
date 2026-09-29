## PHASE 0 — Project Context (paste first, save as `PROJECT_CONTEXT.md`)

```
You are helping me build a cross-platform mobile app (iOS + Android) called
"Alamiyah" — an aesthetic, calm, spiritually-focused Islamic content app
centered on Dhikr (remembrance of Allah), Dua (supplications), and prayer-life
tools. It draws inspiration from the general category of apps like Dhikr &
Dua, Pillars: Prayer Times & Azan, and Muslim Pro — but it must NOT copy their
UI, layouts, illustrations, icons, color systems, or specific text/screen
structures. Treat those only as category references for what "good" looks
like in this space (calm colors, Arabic typography, card-based content,
smooth transitions). All final visual design, component structure, and
content architecture must be original.

TECH STACK
- Framework: Flutter (single codebase for iOS + Android). If you strongly
  recommend React Native instead, tell me why before proceeding — otherwise
  default to Flutter.
- State management: Riverpod (or Bloc if you think it fits better — explain
  trade-off briefly).
- Backend: Firebase (Firestore for content + metadata, Firebase Storage for
  images/videos, Firebase Auth for ADMIN accounts only, Firebase Cloud
  Messaging for reminders/notifications). Regular users never authenticate.
- Media: video/audio should stream, not force full download, where possible.
- Local persistence: Hive or shared_preferences for user theme/font
  preferences, saved/bookmarked content, and Ramadan reminder settings —
  all stored on-device since there is no user login.

APP STRUCTURE — TWO SIDES
1. ADMIN SIDE (separate app build target OR a role-gated section reachable
   via a hidden/admin login screen — decide and justify which approach is
   cleaner for a single Flutter codebase; I lean toward one codebase with a
   role-based route, but open to your recommendation).
   - Multiple admin accounts can exist simultaneously (Firebase Auth,
     email/password or invite-based).
   - Admins can create, edit, delete, and schedule content of type:
     Text (with rich formatting: Arabic script + translation + transliteration
     fields, source/reference citation), Image, and Video (upload or link).
   - Every content item has: title, category/tag(s), language(s), optional
     Arabic text field, optional transliteration field, optional translation
     field, optional audio reciter reference, publish date/time (supports
     scheduling), author/admin attribution, status (draft/published).
   - Admins can also set YouTube livestream/video links for the "Live Feed"
     feature (see Phase 4).
   - Basic moderation: an admin can see a content list, filter by status/
     category/admin, and soft-delete (not hard-delete) items.

2. USER SIDE (no login required, ever)
   - Opens directly to a home/feed view — zero friction.
   - Browses categorized content (e.g. Morning Adhkar, Evening Adhkar,
     Dua for specific situations, Names of Allah, Quran reflections,
     Video reminders, Ramadan specials) presented in a highly aesthetic,
     card/feed-based layout with smooth animations (fade/slide transitions,
     subtle parallax on scroll, elegant loading skeletons — not spinners).
   - Full customization system (see Phase 3): theme (dark green / light
     green + more), font size scaling, accent color choices, smooth animated
     transitions between all theme changes (no jarring hard cuts).
   - Bookmark/save content locally (no account needed — stored on device).
   - Islamic (Hijri) calendar + Ramadan calendar with fasting reminders
     (see Phase 5).
   - Live Feed section showing admin-curated YouTube content in an
     attractive custom UI, tapping opens YouTube app/browser (see Phase 4).

DESIGN LANGUAGE (apply throughout every phase)
- Calm, spiritual, uncluttered. Generous white space (or "dark space" in
  dark mode). Soft shadows, rounded corners, no harsh contrast.
- Primary palette: greens (deep emerald/forest green for dark mode, sage/
  mint/light green for light mode), warm off-white or cream as a secondary
  neutral, gold/brass used sparingly as an accent for highlights (Ramadan
  mode, featured content) — never gaudy.
- Typography: a clean geometric sans-serif for UI text, a proper Arabic
  typeface (e.g. Noto Naskh Arabic, Lateef, or Amiri) for Quranic/Arabic
  text — Arabic text must render right-to-left correctly and be visually
  prioritized (larger, more elegant styling) over translations.
- Micro-interactions matter: subtle haptic feedback on bookmark/like,
  gentle fade transitions when switching categories, animated theme
  switching (colors should crossfade, not snap).
- Icons should feel custom/illustrated, not generic Material defaults —
  use a consistent line-weight icon set.

MOTION & TRANSITIONS — TREAT AS A FIRST-CLASS REQUIREMENT
- Every single transition in this app — screen navigation, tab switches,
  theme changes, card expansions, list reordering, modal open/close,
  button presses — must feel fluid, continuous, and intentional. No
  instant cuts, no default platform transitions left unstyled.
- Use consistent easing curves across the whole app (e.g. easeInOutCubic
  or a custom Curve) so motion feels like one coherent language, not a
  patchwork of different animation styles per screen.
- Prefer shared-element/hero transitions when moving from a feed card
  into its detail view (the card should visibly morph into the detail
  layout, not just fade out/in).
- Standard durations: micro-interactions (button press, bookmark toggle)
  ~150-200ms; screen/tab transitions ~250-350ms; theme crossfades
  ~350-450ms. Nothing should feel abrupt, but nothing should feel
  sluggish either — smooth and quick, not slow and floaty.
- Every animation should have a "reduce motion" fallback (respect the
  Reduce Motion toggle from Phase 3) that shortens/simplifies it rather
  than removing it entirely.

SOUND DESIGN — AESTHETIC, SUBTLE, ISLAMIC-APPROPRIATE
- The app should have a light, tasteful sound layer — never loud, never
  gamified/cartoonish, never anything that resembles music with
  instruments (keep it percussion-free and closer to soft chimes,
  gentle "tick"/"pop" tones, or nature-inspired tones like a soft water
  droplet or wind-chime, since instrumental music is a sensitivity point
  for many Muslim users — see note below).
- Suggested sound moments (all short, under ~400ms):
  - A soft, warm "confirmation" tone on bookmarking/saving content.
  - A gentle tactile "tick" on category chip selection and on font-size
    slider changes.
  - A subtle ambient swoosh on page/tab transitions (very quiet — barely
    perceptible, there to reinforce the motion, not to announce itself).
  - A calm chime for prayer-time/Suhoor/Iftar notifications, distinct
    from generic notification sounds, and configurable (users can pick
    from 2-3 tones or turn it off).
  - A soft "settle" tone when a theme change completes.
- IMPORTANT sensitivity note for Cursor to respect: many Muslim users
  avoid instrumental music. Do not use anything that sounds like a
  musical melody with a beat. Favor single-tone chimes, soft clicks, and
  nature-like sounds (water, wind) over anything musical. Also do NOT
  use actual Adhan (call to prayer) audio for generic UI sounds — reserve
  real Adhan audio only for the dedicated prayer-time notification if the
  user explicitly opts in to it in settings.
- All sound effects must be optional and controlled by a single global
  "Sound Effects" toggle in Display/Settings (see Phase 3), on by
  default but easy to mute. Respect the device's silent/mute switch on
  iOS and system sound settings on Android.
- Keep total sound asset footprint small (short, compressed audio files)
  so it doesn't bloat app size or add load latency.

NON-FUNCTIONAL REQUIREMENTS
- Fully responsive across phone sizes; tablet layout is a nice-to-have,
  not required in v1.
- Offline-friendly: last-fetched content should be cached and viewable
  without internet (especially bookmarks and daily adhkar).
- Performance: image/video assets should be compressed/optimized on
  upload (admin side) and lazy-loaded (user side).
- Accessibility: font scaling must go high enough to genuinely help
  low-vision users; maintain color-contrast standards in both themes.

Acknowledge you understand this context, then wait for Phase 1 instructions.
```

---

## PHASE 1 — Foundation: Project Setup + User-Side Skeleton

```
Using the PROJECT_CONTEXT.md we defined, set up the Flutter project
foundation:

1. Initialize the Flutter project with proper folder structure:
   /lib/core (theme, constants, utils, routing)
   /lib/features/home
   /lib/features/content (dhikr/dua text, image, video content)
   /lib/features/admin
   /lib/features/calendar
   /lib/features/live_feed
   /lib/data (models, repositories, Firebase services)
   /lib/shared (reusable widgets: cards, buttons, loaders, animated theme
   switcher)

2. Set up Firebase (Firestore, Storage, Auth, Messaging) — give me the
   exact steps/CLI commands to connect it, and create placeholder service
   classes (ContentRepository, AdminAuthService, StorageService) with
   clean interfaces I can wire up once my Firebase project is created.

3. Define the core Firestore data model as Dart models with json
   serialization:
   - ContentItem (id, type[text/image/video], title, category, tags,
     arabicText, transliteration, translation, mediaUrl, thumbnailUrl,
     authorId, authorName, status, createdAt, scheduledAt)
   - Category (id, name, iconRef, colorHint, sortOrder)
   - AdminUser (id, name, email, role)
   - LiveFeedLink (id, title, youtubeUrl, thumbnailUrl, isFeatured,
     addedBy, addedAt)

4. Build the USER SIDE app shell (no login):
   - Bottom navigation: Home (feed), Categories, Calendar, Live Feed,
     Saved/Bookmarks.
   - Home screen: a beautifully designed feed showing a mix of latest
     content (respect category + type), with a hero/featured card at the
     top (e.g. "Dua of the Day" or featured video), and a horizontally
     scrollable "Categories" chip row beneath it.
   - Use placeholder/mock data (a local JSON list of ~15 sample content
     items across text/image/video) so the UI is fully navigable before
     Firebase is wired live.
   - Implement smooth page transitions and a shimmer/skeleton loading
     state for the feed.

5. Set up basic app theming scaffolding (ThemeData for light-green and
   dark-green modes) even though full customization comes in Phase 3 —
   just get the toggle wired with an animated crossfade between themes.

Build this phase fully working and runnable before moving on. Show me the
folder structure and a summary of what was created.
```

---

## PHASE 2 — Admin Side: Content Management

```
Now build the ADMIN side, connected to the same Firestore backend:

1. Admin authentication: simple, clean email/password login screen
   (Firebase Auth) reachable via a subtle route (e.g. long-press on app
   logo, or a hidden "/admin" deep link) — not exposed in the user's main
   navigation.

2. Admin dashboard:
   - Overview stats (total content items, by type, by category, pending
     drafts).
   - Content list with filters (category, type, status, author) and
     search.

3. Content creation/edit flow, one form per type but sharing a common
   base:
   - TEXT content: fields for Arabic text (RTL input), transliteration,
     translation, source/reference, category, tags, publish
     now/schedule toggle.
   - IMAGE content: image picker/upload to Firebase Storage with
     auto-compression, caption, category.
   - VIDEO content: either direct upload (compressed) OR paste a video
     URL (e.g. YouTube/Vimeo embed link) — admin chooses which.
   - All forms should autosave drafts locally so an admin doesn't lose
     work.

4. Multi-admin support: show author attribution on every content item;
   allow an "owner" admin role that can manage other admins (invite/
   deactivate) vs a "contributor" admin role that can only manage their
   own content.

5. Basic content moderation screen: list of all published content with
   quick soft-delete/unpublish actions.

Keep the admin UI clean and functional — it does not need the same level
of decorative polish as the user side, but should still feel consistent
with the app's visual identity (same color system, calmer/denser layout
since it's a work tool).

Wire this fully to Firestore/Storage (replace the Phase 1 mock data with
real queries) and confirm content created here appears live in the user
feed from Phase 1.
```

---

## PHASE 3 — User Customization System

```
Build the full appearance-customization system on the user side:

1. A "Display Settings" screen (accessible from Home or a settings icon)
   with:
   - Theme mode: Light Green, Dark Green, plus 1–2 additional aesthetic
     variants (e.g. "Sepia/Warm" and "Midnight Blue-Green") — think of
     these like reading-app themes (à la Kindle) but Islamic-appropriate.
   - Font size slider (small → extra large) that scales all text content
     (Arabic, transliteration, translation) smoothly and immediately,
     with a live preview card on the same screen.
   - Accent color picker (a curated palette of 5–6 tasteful accent colors,
     not a full color wheel, to keep it aesthetic and on-brand).
   - Arabic font style picker (2–3 curated Arabic typefaces).
   - A toggle for "Reduce motion" for accessibility.
   - A "Sound Effects" master toggle (on by default) plus a small picker
     for the notification chime tone (2-3 curated calm tones).

2. All theme/preference changes must animate smoothly — crossfade
   background/surface colors over ~300-400ms, no flash or hard cut. Use
   the same eased crossfade approach for every other transition in the
   app referenced in Phase 0's Motion & Transitions section — this
   screen should visibly demonstrate that smoothness (e.g. the live
   preview card should animate its own theme/font changes in real time
   as the user adjusts each control, with the subtle "tick" and "settle"
   sound effects from Phase 0 playing as feedback while adjusting).
   Persist all preferences locally (Hive/shared_preferences) so they
   survive app restarts, with zero account/login involved.

3. Apply the customization system app-wide: verify every content card,
   the calendar, and the live feed screen all correctly respect the
   chosen theme, font size, and accent color.

Show me a short before/after description of how the theming architecture
works (e.g. ThemeExtension usage) so I understand how to add more themes
later.
```

---

## PHASE 4 — Live Feed (YouTube Integration)

```
Build the Live Feed feature:

1. Admin side: extend the admin dashboard with a "Live Feed" management
   screen where an admin can add/edit/remove YouTube links, each with a
   title, optional description, auto-fetched or manually-set thumbnail,
   and a "Featured" flag (only one or two items can be Featured at a
   time, shown prominently).

2. User side: build a dedicated Live Feed tab with:
   - A large featured hero card at top for the "Featured" livestream/video
     (auto-fetch the YouTube thumbnail via the video ID; overlay a subtle
     play button and gradient for legibility).
   - A scrollable list/grid of other live feed items below, each as an
     attractive card with thumbnail, title, and a small "Watch on
     YouTube" indicator/icon.
   - Tapping any card opens the YouTube app if installed, otherwise the
     browser (use url_launcher with youtube:// scheme fallback to https).
   - Add a subtle "pulse" or "live" animation badge for any item marked
     as currently live (admin sets an isLiveNow flag).

3. Handle empty/error states gracefully (no internet, no live content
   yet) with a calm, on-brand illustration/message rather than a generic
   error screen.

Confirm the tap-to-YouTube flow works correctly on both iOS and Android
simulators/devices.
```

---

## PHASE 5 — Islamic Calendar & Ramadan Companion

```
Build the calendar features:

1. Islamic (Hijri) calendar view:
   - Convert Gregorian ↔ Hijri (use a reliable package, e.g. hijri or
     adhan for date conversion — pick and justify).
   - Show current Hijri date prominently on Home.
   - Full calendar screen showing the month in Hijri, with important
     Islamic dates/events highlighted (e.g. Ramadan start, Eid, Laylatul
     Qadr estimated nights, Ashura, etc.) pulled from a static reference
     data set I can edit.

2. Ramadan Companion mode (auto-activates when Ramadan is detected, or
   can be manually previewed):
   - Ramadan calendar showing all 30 fasting days, each day showing
     Suhoor end time / Iftar time (based on device location + a prayer-
     times calculation package, e.g. adhan-dart).
   - Daily fasting reminder notifications (Suhoor reminder ~30-45 min
     before Fajr, Iftar reminder at Maghrib) via local notifications —
     configurable on/off per user.
   - A simple daily tracker: user can mark each day as "Fasted" locally
     (streak counter, no login/cloud sync needed — just on-device,
     framed positively, not guilt-inducing).
   - A "Ramadan extras" section: daily featured dua, a Laylatul Qadr
     countdown/highlight in the last 10 nights, and a Zakat/charity
     reminder card linking out (admin-configurable link).

3. Prayer time integration (supporting feature, since dhikr/dua content
   often ties to prayer times): show today's 5 prayer times + next-prayer
   countdown on Home, calculated from device location with a manual
   city-search fallback if location permission is denied.

Test that all reminders fire correctly and that Hijri date conversion
matches known reference dates.
```

---

## PHASE 6 — Feed Polish, Animations & Final Aesthetic Pass

```
Final polish pass across the whole user-side app:

1. Add a real content feed algorithm (not just reverse-chronological):
   mix in "Daily Dhikr", "Featured Dua", recent videos, and category
   spotlights in a visually varied feed (alternate full-width hero cards,
   two-column image grids, and text-quote cards for rhythm).

2. Add satisfying micro-animations: bookmark heart/star bounce, category
   chip selection animation, pull-to-refresh with a custom Islamic-
   themed animation (e.g. a subtle crescent/lantern motif — original
   artwork, not copied from any existing app), smooth shared-element
   transition when opening a content item from the feed into detail view.
   Every one of these should feel continuous and eased per the Motion &
   Transitions standards set in Phase 0 — no default/unstyled platform
   animations should remain anywhere in the app at this point.

3. Implement the full sound effects layer from Phase 0's Sound Design
   section: source or generate short, calm, non-musical audio assets
   (soft chime, gentle tick, subtle swoosh, warm confirmation tone,
   settle tone) and wire each to its corresponding interaction
   (bookmark, chip selection, tab/page transition, theme-change
   completion, prayer/fasting notification). Use a lightweight audio
   package (e.g. audioplayers or just_audio) with pre-loaded short
   assets so there's no playback lag. Respect the global Sound Effects
   toggle and device silent-mode/system settings at every trigger point.

4. Build a polished content detail view per type (text/image/video) with
   share, bookmark, font-size quick-adjust, and "more like this" related
   content at the bottom — opened via the shared-element transition from
   the feed, with a soft confirmation tone on bookmark actions here too.

5. Add a simple onboarding (3-4 screens, skippable) shown only on first
   launch, explaining the no-login philosophy and letting the user pick
   their initial theme preference, animated with the same smooth
   transition language as the rest of the app.

6. Full QA pass: test dark/light green + extra themes, font scaling
   extremes, offline mode, RTL Arabic rendering, both iOS/Android builds
   for visual consistency, AND a dedicated "motion & sound" pass —
   confirm every transition in the app is smooth with no jank/frame
   drops, every sound effect fires correctly and respects the mute
   toggle and device silent switch, and nothing feels abrupt or jarring
   anywhere in the app.

Give me a final checklist of what's implemented vs. what remains before
this is release-ready for TestFlight/Play Store internal testing.
```