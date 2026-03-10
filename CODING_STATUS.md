# Coding Status

## What is already built

### Android app

The Android app already has:

- basic project scaffold
- Compose UI shell
- local persistence with Room and DataStore
- starter tasks
- custom task creation
- point rewards for task completion
- gentle streak tracking
- home screen with central avatar
- shop screen
- avatar screen
- settings screen
- seeded phrase system
- seeded shop items
- simple equipped cosmetic rendering

### Mac preview app

The Mac preview app already has:

- SwiftUI app scaffold
- local persistence
- home screen
- tasks screen
- shop screen
- avatar screen
- settings screen
- cozy avatar scene
- local phrase tapping
- local reward loop

## What is partially built

### Android app

- visual polish is partial
- animation polish is partial
- effect unlocks are partial
- shop preview depth is partial
- completed-task history views are partial
- full production-ready testing has not happened yet

### Mac preview app

- it is good for local product feel validation
- it is not feature-complete compared to a full shipping desktop app
- it exists as a support tool, not the primary shipping path

## What is still missing

- deeper content and unlock variety
- stronger visual polish
- more complete completion history
- more complete inventory/customization systems
- export/backup features
- real shipping QA on Android devices
- packaging/distribution decisions

## What should happen next

1. Run the Mac preview locally in Xcode.
2. Open the Android app in Android Studio.
3. Get the Android app running on an emulator.
4. Test the main reward loop end to end.
5. Write down UX issues after using both.
6. Improve the Android app first, since Android is the real target.
