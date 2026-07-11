# ALU Bridge

A mobile app connecting ALU students seeking internship experience with verified ALU student-led ventures. Ventures post roles once verified; students discover, filter, and apply with a live skill-match score; founders run applicants through a pipeline; and messaging opens once an applicant is shortlisted.

## Stack

- **Flutter / Dart**
- **Firebase**: Authentication (email/password), Cloud Firestore. Firebase Storage is not wired up — the project stayed on the Spark (free) plan, and Storage now requires Blaze, so CV/logo uploads use plain link/text fields instead of file uploads. See "Known limitations" below.
- **flutter_bloc** (`Bloc` for multi-event flows, `Cubit` for simpler load/save state) for state management
- **get_it** for dependency injection, **equatable** for value equality, **intl** for date formatting, **google_fonts** for the type system

## Setup

1. Install Flutter (stable channel) and the Firebase CLI (`npm install -g firebase-tools`) and FlutterFire CLI (`dart pub global activate flutterfire_cli`).
2. Create a Firebase project. Enable **Authentication → Email/Password** and **Firestore Database** (production mode).
3. From the project root, run:
   ```
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart` (gitignored — regenerate it yourself; it's not committed since it's tied to a specific Firebase project).
4. Publish `firestore.rules` (in this repo) to your project: Firebase Console → Firestore Database → Rules → paste and Publish.
5. `flutter pub get`, then `flutter run`.

Venture verification has no in-app reviewer screen (a deliberate scope decision — see the technical report). To verify a venture for testing, edit its document in Firestore Console: `ventures/{id}.verification.status` → `"verified"`.

## Architecture

- `lib/main.dart` → `lib/bootstrap.dart` (Firebase init, get_it registration, error zone) → `lib/app.dart` (`MaterialApp`, theme, router, and a **global** `BlocListener<AuthBloc>` that redirects the whole app between onboarding/student-shell/founder-shell based on auth status — this is what makes signing out from deep inside a shell correctly bounce back to onboarding).
- **Feature-first** structure under `lib/features/`: `auth`, `ventures`, `opportunities`, `applications`, `profile`, `messaging`, `shell`. Each feature owns its `data/` (repositories), `models/`, `bloc/` or `cubit/`, and `view/`.
- **State management**: `Bloc` where a screen has multiple real events to react to (auth, opportunity form, discovery, applications, applicants, chat); `Cubit` where it's just async load/save state (venture status, profile builder, verification submit). Screen-scoped blocs/cubits that outlive a single page (e.g. `DiscoveryBloc`, `VentureCubit`) are created once at the shell level and shared across tabs via `BlocProvider`/`MultiBlocProvider`; one-shot page blocs are created per-page.
- **Firestore reads**: composite `where` + `orderBy` queries were avoided throughout (they require manually-created indexes); repositories filter server-side on a single field and sort client-side instead.
- **Match score**: `lib/features/applications/data/match_score.dart` is a standalone pure function (skill-overlap percentage) with no Firebase dependency, computed once at application submission and stored on the record.

## Testing

- `test/features/applications/match_score_test.dart` — unit tests for the match-score function.
- `test/features/applications/applications_bloc_test.dart` — a `bloc_test` against `ApplicationsBloc`, using `fake_cloud_firestore` to verify it only surfaces the signed-in student's own applications.
- `test/widget_test.dart` — smoke test for the onboarding page.

Run with `flutter test`.

## Known limitations / deliberate scope decisions

- **No file uploads**: Firebase Storage needs the Blaze plan; the project stayed on Spark. Venture verification "proof" and student CVs are plain URL/text fields rather than uploaded files.
- **No admin/reviewer UI**: venture verification approval is done by editing Firestore directly (see Setup). This mirrors an operational/admin function outside the app's two user roles (student, founder).
- **No offline banner**: real connectivity detection needs a plugin (`connectivity_plus`) that wasn't added to keep the dependency set to what was agreed at project start.
