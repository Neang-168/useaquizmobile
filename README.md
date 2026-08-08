# Pre-Study IT Knowledge Assessment System — Flutter App

A high-fidelity, fully navigable Flutter frontend for the *Pre-Study IT Knowledge
Assessment System* (Android Mobile App Development case study, University of Southeast Asia).

This is the **mobile frontend only**. It's built to be wired up to your own backend
(e.g. your `useaquizweb` Laravel API) later — see "Connecting your own backend" below.

## Design system
- Material Design 3, Inter typography (`google_fonts`)
- Primary Blue `#2563EB`, Secondary Emerald `#10B981`
- 20px rounded corners, soft shadows/glassmorphism cards, gradient heroes
- `lib/theme/app_theme.dart` is the single source of truth for colors, type, and card styles

## Screens implemented (all wired together with real navigation)
1. Splash → 2. Login (email/ID + password + Remember me + Google) → 3. Home Dashboard
4. Subject List (search + semester filter) · 5. Assessment Details · 6. Assessment Instructions
7. Quiz (timer, flag, previous/next) · 8. Submit Confirmation (dialog on last question)
9. Assessment Result (score, performance level, feedback) · 10. Answer Review (green/red indicators)
11. Assessment History (search + status filter) · 12. Notifications · 13. Student Profile
(with Settings, Notifications toggle, Dark Mode toggle, Logout)

Bottom navigation (Home / Subjects / Assessments / History / Profile) is shared across the
main tab screens.

## Run it
```bash
flutter pub get
flutter run
```

Out of the box, every screen runs on **bundled demo data** (`lib/data/mock_data.dart`) —
no backend required. That's the same data path it falls back to later if your real API
is ever unreachable, so the app never shows a blank/broken screen.

## Connecting your own backend

All network code is isolated in one place, so wiring this up to your Laravel API means
touching a small, well-defined surface rather than every screen:

```
lib/
  config/api_config.dart      # <- set your API base URL here
  services/
    api_client.dart           # thin http wrapper: headers, timeouts, error handling
    app_repository.dart       # <- the actual adaptor layer, one method per screen's data need
    session.dart              # persists the auth token (SharedPreferences)
  models/models.dart          # Subject, Assessment, Question, HistoryItem, Notification,
                               # Student, SubmissionResult — each has a fromJson(...)
```

**Screens never call the network directly** — they only call `AppRepository.instance.*`.
That means adapting to your Laravel routes/response shapes is a matter of editing
`app_repository.dart` and `models.dart`, not touching any of the 13 screen files.

### Steps to wire it up

1. **Set the base URL** — `lib/config/api_config.dart`, or pass it at run time:
   ```bash
   flutter run --dart-define=API_BASE_URL=https://your-laravel-app.test/api
   ```
2. **Match your Laravel routes.** `app_repository.dart` currently expects REST-ish paths
   like `POST /auth/login`, `GET /subjects`, `GET /assessments/:id`,
   `POST /assessments/:id/submit`, `GET /history`, `GET /notifications`, `GET /profile`.
   Rename the paths in each method to whatever your `routes/api.php` actually exposes.
3. **Match your JSON shape.** Each model's `fromJson` currently expects the field names
   shown in `models.dart` (e.g. `Subject.fromJson` reads `name`, `code`, `semester`,
   `totalAssessments`, `completed`). If your Laravel API returns different field names
   (common with Eloquent's default snake_case, e.g. `total_assessments`), update the
   `fromJson` factories to match — that's the only place the mapping lives.
4. **Auth**: if you're using Laravel Sanctum/Passport, `login()` in `app_repository.dart`
   just needs to hit your token endpoint and store whatever token comes back via
   `Session.saveToken(...)`; `ApiClient` already attaches it as `Authorization: Bearer <token>`
   to every subsequent request.
5. **Icons/colors from the API**: if your backend will send icon/color hints per subject or
   assessment, `models.dart` has `iconFromKey()` / `colorFromHex()` helpers already set up
   for that — extend the icon-key switch statement with whatever keys you decide to send.

### Demo-mode fallback

`AppRepository` currently catches connectivity failures and falls back to
`MockData` so the UI is always navigable, even with no backend at all — handy while
you're still building out the Laravel side. Once your API is solid, you can remove
the fallback branches in `app_repository.dart` if you'd rather surface real errors instead.

## Project structure
```
lib/
  main.dart
  config/api_config.dart      # API base URL (override with --dart-define=API_BASE_URL=...)
  theme/app_theme.dart        # colors, typography, card/button styles
  models/models.dart          # data models + fromJson — the JSON contract with your backend
  services/
    api_client.dart           # thin http wrapper: base URL, auth header, timeouts, errors
    app_repository.dart       # the adaptor layer — edit this to match your Laravel API
    session.dart              # persists the auth token
  data/mock_data.dart         # bundled demo content, used as the offline fallback
  widgets/common_widgets.dart # bottom nav, section headers, badges, empty/skeleton states, demo banner
  screens/                    # one file per screen, listed above
android/ ios/ web/ windows/ linux/ macos/  # native platform runners (flutter create scaffolding)
```

## Notes
- The quiz timer auto-submits when time runs out.
- Submit Confirmation is implemented as a dialog shown from the last quiz question (per the
  spec's flow), rather than a separate route, since it's a modal step within the quiz.
- Dark mode has a toggle in Profile but isn't wired to a real dark `ColorScheme` yet.
