# Project Structure

This file explains the repo layout in simple terms.

## Root folder

This repo root is meant to be beginner-friendly.

At the top level, you should mainly see:

- docs
- app folders
- `.gitignore`

## Main folders

### `apps/`

This folder contains the actual apps.

It has two subfolders:

1. `apps/android-app`
2. `apps/macos-preview`

### `apps/android-app/`

This is the real Android app project.

This is the primary shipping path.

Important files and folders:

- `apps/android-app/app/`
  - the Android app module
- `apps/android-app/app/src/main/java/`
  - Android Kotlin source code
- `apps/android-app/app/src/main/res/`
  - Android resources like strings, themes, and icons
- `apps/android-app/app/src/main/AndroidManifest.xml`
  - Android app manifest
- `apps/android-app/build.gradle.kts`
  - Android project build config
- `apps/android-app/settings.gradle.kts`
  - Android project module settings
- `apps/android-app/gradlew`
  - Gradle wrapper launcher
- `apps/android-app/gradle/`
  - Gradle wrapper files

### `apps/macos-preview/`

This is the Mac preview app.

This is not the main shipping target.

It exists so you can quickly test the product feel on your Mac.

Important files and folders:

- `apps/macos-preview/Package.swift`
  - Swift package definition
- `apps/macos-preview/Sources/ProjectBobaMac/`
  - SwiftUI app source code
- `apps/macos-preview/Sources/ProjectBobaMac/ProjectBobaMacApp.swift`
  - Mac app entry point
- `apps/macos-preview/Sources/ProjectBobaMac/ContentView.swift`
  - main UI views
- `apps/macos-preview/Sources/ProjectBobaMac/BobaStore.swift`
  - local app state and persistence
- `apps/macos-preview/Sources/ProjectBobaMac/Models.swift`
  - Mac preview data models

## Root docs

### `README.md`

The beginner landing page for the repo.

### `SETUP_GUIDE_BEGINNER.md`

The easiest possible guide for running the Mac preview and Android app.

### `GITHUB_PUSH_GUIDE.md`

The easiest possible guide for getting this repo onto GitHub.

### `PROJECT_STRUCTURE.md`

This file.

### `CODING_STATUS.md`

A plain-English snapshot of what is built, what is partial, and what is next.

### `PRODUCT_DECISIONS.md`

This is where shared product decisions should be documented.

If we make new big product calls later, they should go there first.

Examples:

- emotional tone
- progression rules
- shop philosophy
- streak behavior
- tag logic
- scope changes

## Which code belongs to Android?

Everything in:

`apps/android-app`

That is the real product path.

## Which code belongs to macOS preview?

Everything in:

`apps/macos-preview`

That is the local Mac validation path.

## Rule of thumb

If you are unsure where to make a new product decision:

1. write the decision in `PRODUCT_DECISIONS.md`
2. then update Android
3. then update Mac preview if it helps testing
