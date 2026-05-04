# flutter_app_aethervault

Aethervault is a Flutter app for tracking decks and collections with Firebase auth and Scryfall-powered card search.

## Firebase setup

- Commit `lib/credentials/firebase_options.dart`; it is required for the app to start.
- Keep exported native credential files out of the repo: `lib/credentials/google-services.json`, `lib/credentials/GoogleService-Info.plist`, and `ios/Runner/GoogleService-Info.plist`.
- If you re-run `flutterfire configure`, make sure the Dart options file stays in place before the first push.

## Local development

- Run `flutter pub get` after cloning.
- Run `flutter analyze` before committing.
