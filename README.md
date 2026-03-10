# Project Boba

Project Boba is an Android-first, local-only cozy self-care and to-do app built for a single private user. The v0 app centers the avatar on the home screen, rewards completed tasks with points immediately, and lets those points unlock a small shop of cosmetics, phrase packs, and backgrounds.

## Product Summary

- Warm winter aesthetic with a calm, supportive tone.
- One unified master task list with starter tasks and custom task creation.
- Fixed starter tag system for gentle reward-track expansion later.
- Gentle streak logic: 3 completed tasks qualifies a day, with no punishment for misses.
- Tap-to-speak avatar catchphrases with cooldown and optional name personalization.
- Small but functional shop for cosmetics, phrase packs, effects, and backgrounds.

## Assumptions

- v0 uses simple Compose-drawn avatar/background visuals instead of custom illustration assets.
- Local persistence is enough for now, but data models are split cleanly for future backup/export.
- Android native is preferred over cross-platform abstraction for speed and maintainability.
- Completion feedback is intentionally soft: haptics, a short tone, a point burst, and a small avatar hop.

## Architecture

- UI: Jetpack Compose + Material 3 with a custom cozy theme.
- Navigation: `navigation-compose`.
- State: single app `ViewModel` coordinating repository-backed flows.
- Persistence:
  - Room for tasks, completions, progress, phrases, shop inventory, and ownership.
  - DataStore Preferences for avatar selections and lightweight settings.
- Layers:
  - `data/local`
  - `data/repository`
  - `core`
  - `ui`
  - `ui/theme`

## Screens

- Home: central avatar scene, background, streak/points summary, quick task panel, catchphrases.
- Tasks: master list, starter content, custom task creation with tags and point values.
- Shop: purchase and equip flow using earned points.
- Avatar: avatar choice and naming.
- Settings: light comfort toggles and v0 summary.

## Build Note

This repo includes a Gradle wrapper pinned to Gradle `8.2.1`. The current host where the app was scaffolded only exposes JDK `25.0.2`, which is too new for reliable Android/AGP verification here. Open the project in Android Studio or run it with a JDK 17-compatible Android setup to build and launch.

## Local Preview

The intended way to preview the app is:

1. Open the project in Android Studio.
2. Let Gradle sync.
3. Use an Android emulator or a connected Pixel device with USB debugging enabled.
4. Run the `app` configuration.

If you use a local terminal instead of Android Studio, run `./gradlew assembleDebug` in a JDK 17-compatible Android environment and install the generated debug APK.
