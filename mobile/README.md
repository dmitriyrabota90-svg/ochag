# Ochag Mobile

Flutter mobile foundation for Ochag.

## Stack

- Flutter
- Riverpod
- GoRouter
- Dio
- flutter_secure_storage
- intl / l10n
- Feature-first architecture

## Local Setup

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
```

Backend base URL can be overridden at runtime:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/v1
```
