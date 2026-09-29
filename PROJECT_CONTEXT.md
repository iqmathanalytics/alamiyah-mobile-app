# Alamiyah — Project Context

You are helping me build a cross-platform mobile app (iOS + Android) called
**Alamiyah** — an aesthetic, calm, spiritually-focused Islamic content app
centered on Dhikr (remembrance of Allah), Dua (supplications), and prayer-life
tools. It draws inspiration from the general category of apps like Dhikr &
Dua, Pillars: Prayer Times & Azan, and Muslim Pro — but it must NOT copy their
UI, layouts, illustrations, icons, color systems, or specific text/screen
structures. Treat those only as category references for what "good" looks
like in this space (calm colors, Arabic typography, card-based content,
smooth transitions). All final visual design, component structure, and
content architecture must be original.

## Tech Stack (locked)

| Concern | Choice | Notes |
|---|---|---|
| Framework | **Flutter** | Single codebase for iOS + Android |
| State management | **Riverpod** | Theme/prefs + Firestore streams; lighter than Bloc for this app |
| Backend | **Firebase** | Firestore (content + metadata), Storage (media), Auth (**admin only**), Cloud Messaging (reminders) |
| Media | Stream where possible | Avoid forcing full downloads |
| Local persistence | **Hive** | Theme/font prefs, bookmarks, Ramadan settings — on-device (no user login) |
| Admin access | **One codebase + hidden route** | Long-press logo / `/admin` deep link — not a separate app |

Regular users **never** authenticate.

## App Structure — Two Sides

### 1. Admin side (role-gated / hidden route)

- Multiple admin accounts via Firebase Auth (email/password or invite-based).
- Create, edit, delete, and schedule content: Text (Arabic + translation + transliteration + citation), Image, Video (upload or link).
- Content fields: title, category/tag(s), language(s), optional Arabic/transliteration/translation, optional audio reciter reference, publish/schedule datetime, author attribution, status (draft/published).
- YouTube livestream/video links for Live Feed.
- Moderation: list, filter by status/category/admin, soft-delete (not hard-delete).
- Roles: **owner** (manage admins) vs **contributor** (own content only).

### 2. User side (no login)

- Opens directly to home/feed — zero friction.
- Categorized content (Morning/Evening Adhkar, situational duas, Names of Allah, reflections, videos, Ramadan specials) in an aesthetic card/feed layout with smooth animations.
- Full customization (themes, font scaling, accents) — Phase 3.
- Bookmark/save content locally.
- Islamic (Hijri) calendar + Ramadan companion — Phase 5.
- Live Feed (admin-curated YouTube) — Phase 4.

## Design Language

- Calm, spiritual, uncluttered. Generous white/dark space. Soft shadows, rounded corners.
- Primary palette: deep emerald/forest (dark), sage/mint (light); warm off-white/cream neutrals; gold/brass sparingly as accent.
- Typography: geometric sans for UI; proper Arabic typeface (e.g. Noto Naskh Arabic / Amiri) for Arabic — RTL, visually prioritized.
- Micro-interactions: haptic on bookmark, fade category switches, animated theme crossfades.
- Consistent line-weight icon set — not generic Material defaults alone.

## Motion & Transitions (first-class)

- Every transition must feel fluid and intentional — no unstyled platform defaults.
- Shared easing: `easeInOutCubic` (or custom Curve) app-wide.
- Prefer Hero/shared-element from feed card → detail.
- Durations: micro ~150–200ms; screen/tab ~250–350ms; theme crossfade ~350–450ms.
- Respect Reduce Motion: shorten/simplify, do not remove entirely.

## Sound Design

- Subtle, non-musical: soft chimes, ticks, water-droplet / wind-chime tones — no instrumental melodies.
- Moments: bookmark confirm, chip/font tick, quiet tab swoosh, notification chime (2–3 options), theme settle.
- Do **not** use Adhan for generic UI sounds — only for opted-in prayer notifications.
- Global Sound Effects toggle (on by default); respect iOS silent switch and Android system sound settings.

## Non-Functional Requirements

- Responsive across phone sizes; tablet nice-to-have for v1.
- Offline-friendly: cache last-fetched content; bookmarks and daily adhkar viewable offline.
- Performance: compress on admin upload; lazy-load on user side.
- Accessibility: high font scaling; WCAG-minded contrast in all themes.

## Phase roadmap

| Phase | Focus |
|---|---|
| 0 | This context document |
| 1 | Flutter foundation + user shell + mocks |
| 2 | Admin CMS + live Firestore |
| 3 | Display customization system |
| 4 | Live Feed (YouTube) |
| 5 | Hijri calendar & Ramadan companion |
| 6 | Feed polish, motion, sound, QA — **implemented** |
