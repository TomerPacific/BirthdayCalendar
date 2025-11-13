# Birthday Calendar - Copilot Instructions

## Project Summary
Birthday Calendar is a Flutter mobile app (3.1MB, ~1,694 lines Dart code across 40 files) that stores birthdays and sends notification reminders. Uses BLoC pattern for state management with flutter_bloc, shared_preferences for storage, flutter_local_notifications, and supports English/Hindi/German localization.

**Tech Stack**: Flutter 3.24.0+, Dart 3.5.0+, Android (API 35), iOS, Web. Key dependencies: flutter_bloc (8.1.5), shared_preferences (2.3.4), flutter_contacts (1.1.9+2), provider (6.0.2)

## Build and Validation (CRITICAL - Run in This Exact Order)

**Prerequisites**: Flutter 3.24.0+, Dart 3.5.0+, Java 12.x (Zulu), Android SDK API 35+, Gradle with `-Xmx1536M`

**ALWAYS run commands in this sequence** (matches CI pipeline in `.github/workflows/flutter_build.yml`):
```bash
dart pub get          # 10-20s - MUST run first
flutter pub get       # 10-30s - MUST run after dart pub get
flutter analyze       # 20-40s - Must pass
flutter test          # 30-60s - Must pass
```

**Build commands**:
- Android: `flutter build apk --release` (2-5 min, outputs to `build/app/outputs/flutter-apk/`)
- iOS: `flutter build ios` (macOS only, requires Xcode)
- Clean: `flutter clean` (then re-run `dart pub get` && `flutter pub get`)

**Common Issues**:
1. Gradle failures → Check Java 12.x, Gradle heap in `android/gradle.properties`
2. Package errors → `flutter clean` then `dart pub get` && `flutter pub get`
3. Platform errors → Notifications/contacts require platform-specific setup

**Tests** (3 files in `test/`): Widget tests, date utilities, storage. Use `WidgetsFlutterBinding.ensureInitialized()` and mock SharedPreferences with `SharedPreferences.setMockInitialValues({})`

## Project Architecture & Key Files

**Root Structure**:
- `.github/workflows/flutter_build.yml` - CI pipeline (runs on PRs: dart pub get → flutter pub get → analyze → test)
- `pubspec.yaml` - Dependencies (run `dart pub get` && `flutter pub get` after modifying)
- `l10n.yaml` - Localization config (arb files in `lib/l10n/`, run `flutter gen-l10n` after editing .arb)
- `android/app/build.gradle` - Android config (compileSdk 35, targetSdk 35, Java 17, Kotlin 2.0.20)
- `lib/main.dart` - App entry point
- `lib/constants.dart` - App-wide constants
- `test/` - 3 test files (widget tests, date utils, storage)

**lib/ Directory** (BLoC pattern with service layer):
```
lib/
├── main.dart                              # Entry point, dependency injection
├── constants.dart                         # Month numbers, storage keys
├── BirthdayCalendarDateUtils.dart         # Date utilities
├── model/user_birthday.dart               # Core data: name, date, hasNotification, phoneNumber
├── [Feature]Bloc/                         # State management (BirthdaysBloc, ThemeBloc, etc.)
├── page/                                  # UI screens (main_page/, birthday/, settings_page/)
├── widget/                                # Reusable components (calendar.dart, add_birthday_form.dart)
├── service/                               # Business logic (interface + *_impl.dart)
│   ├── contacts_service/                  # Contact management
│   ├── notification_service/              # Local notifications
│   ├── storage_service/                   # SharedPreferences wrapper
│   └── permission_service/                # Runtime permissions
└── l10n/                                  # app_en.arb, app_hi.arb, app_de.arb + generated files
```

**BLoC Pattern**: Each feature has BLoC for state (e.g., `BirthdaysBloc/BirthdaysBloc.dart` + `BirthdaysState.dart`). Services use interface + implementation pattern (`*_service.dart` + `*_service_impl.dart`). Data stored via SharedPreferences (no database).

**Android-specific**: Requires notification channels, contacts/notification permissions. Config in `android/app/build.gradle` (multiDex enabled, desugar enabled for Java 8+ APIs)

## Code Conventions & Making Changes

**Style**: snake_case files, PascalCase classes. Each BLoC has own directory with Bloc+State files. Services use interface + `_impl` suffix. Import order: Flutter, packages, relative.

**When modifying**:
- Run `dart pub get` && `flutter pub get` if modifying `pubspec.yaml`
- Run `flutter analyze` frequently to catch issues early
- Run `flutter test` before committing
- Update all .arb files (en, hi, de) for user-facing strings, then `flutter gen-l10n`
- Follow BLoC pattern for state - don't manage state in widgets
- Use existing services - don't duplicate service layer logic

**When adding features**:
- Create new BLoC if managing new state (Bloc + State files in directory)
- Add interface + implementation for services (`*_service.dart` + `*_service_impl.dart`)
- Add tests in `test/` following existing patterns (mock SharedPreferences)
- Update all 3 localization files (en, hi, de)

**Platform-specific**: Native code in `android/app/src/main/kotlin/` or `ios/Runner/` requires full rebuild

## Trust These Instructions
These instructions match the CI/CD pipeline and codebase. **Only search/explore if**: (1) info here is incomplete for your task, (2) you encounter errors contradicting these instructions, or (3) you need implementation details not covered. Always validate with: `dart pub get` → `flutter pub get` → `flutter analyze` → `flutter test`
