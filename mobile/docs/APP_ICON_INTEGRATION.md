# App Icon Integration

The project is prepared to generate launcher icons from one final PNG asset.

## Source icon

- Put the final PNG here: `assets/app_icon/app_icon.png`
- Required format: PNG.
- Recommended size: `1024x1024`.
- Recommended background: opaque, no transparency, because Android and web launcher surfaces can render transparent icons differently.
- Do not commit temporary drafts as `app_icon.png`; use this path only for the approved final icon.

## Generator

The project uses `flutter_launcher_icons` as a development-only package.

Run from `mobile/`:

```sh
dart run flutter_launcher_icons
```

If dependencies were not fetched yet, run this first:

```sh
flutter pub get
```

## Platforms updated

The current configuration updates:

- Android launcher icons.
- Web favicon and web app icons.
- Windows `.ico` launcher icon.

## Config location

Launcher icon settings are stored in `flutter_launcher_icons.yaml`.

The generator expects the final source file to exist before running. Until `assets/app_icon/app_icon.png` is added, icon generation will fail by design.
