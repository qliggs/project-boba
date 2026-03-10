# Project Boba

Project Boba is a cozy, calming, avatar-first to-do and self-care app.

It is being built mainly for Android.

The goal is to make everyday tasks feel warm, supportive, and rewarding without shame, punishment, or pressure.

## Why this repo has two apps

This repo contains two app paths on purpose:

1. `apps/android-app`
   - This is the real target product.
   - This is the app we are actually trying to ship.
   - Android is the primary platform.

2. `apps/macos-preview`
   - This is a local Mac preview app.
   - It exists so you can quickly test the product feel on your Mac while the Android app is still being finalized.
   - It is not the shipping target.

## Which app is the real one?

The real app is the Android app in:

`apps/android-app`

## Which app is just for local preview/testing?

The Mac preview app is in:

`apps/macos-preview`

It is a support tool for local product validation on your Mac.

## Start Here

If you want the easiest path, do this:

1. Read [SETUP_GUIDE_BEGINNER.md](/Users/quentinligginsjr/Documents/Quentin%20Liggins%20Jr/Project%20Boba/SETUP_GUIDE_BEGINNER.md).
2. Open the Mac preview first from `apps/macos-preview`.
3. Once that launches, open the Android app from `apps/android-app` in Android Studio.
4. Run the Android app on an emulator.
5. Read [CODING_STATUS.md](/Users/quentinligginsjr/Documents/Quentin%20Liggins%20Jr/Project%20Boba/CODING_STATUS.md) to see what is built and what is next.

## Repo map

- [PROJECT_STRUCTURE.md](/Users/quentinligginsjr/Documents/Quentin%20Liggins%20Jr/Project%20Boba/PROJECT_STRUCTURE.md)
- [SETUP_GUIDE_BEGINNER.md](/Users/quentinligginsjr/Documents/Quentin%20Liggins%20Jr/Project%20Boba/SETUP_GUIDE_BEGINNER.md)
- [GITHUB_PUSH_GUIDE.md](/Users/quentinligginsjr/Documents/Quentin%20Liggins%20Jr/Project%20Boba/GITHUB_PUSH_GUIDE.md)
- [CODING_STATUS.md](/Users/quentinligginsjr/Documents/Quentin%20Liggins%20Jr/Project%20Boba/CODING_STATUS.md)
- [PRODUCT_DECISIONS.md](/Users/quentinligginsjr/Documents/Quentin%20Liggins%20Jr/Project%20Boba/PRODUCT_DECISIONS.md)

## Beginner summary

If you feel lost, remember this:

- Mac preview app = easiest place to see the product feeling on your Mac.
- Android app = the real thing we are building toward.
- Root docs = your instructions.

## Important setup notes

- For the Mac preview app, use full Xcode.
- For the Android app, use Android Studio.
- Android Studio should manage the Android SDK and emulator for you.
- The Android app expects a normal Android Studio setup with Android Studio's embedded JDK, which should be Java 17-compatible.

## Current app folders

- Android app: [apps/android-app](/Users/quentinligginsjr/Documents/Quentin%20Liggins%20Jr/Project%20Boba/apps/android-app)
- Mac preview app: [apps/macos-preview](/Users/quentinligginsjr/Documents/Quentin%20Liggins%20Jr/Project%20Boba/apps/macos-preview)
