# Project Boba Session Handoff

## What This Repo Is
Project Boba contains:

- `apps/android-app`
  - The real shipping target.
  - Android-first product path.
- `apps/macos-preview`
  - A native macOS preview app used as a local product-validation harness.
  - This is not the shipping target.

This handoff is mainly about the macOS preview app, because that is where the recent debugging and stabilization work happened.

## Current Top-Level Status

### Android
- Android work is preserved.
- Android was **not** touched during the latest stabilization passes.

### macOS Preview
- The macOS preview app is currently expected to run through a **manual AppKit `NSWindow` hosting SwiftUI via `NSHostingView`**.
- This is the important architecture decision that unlocked working keyboard input on macOS.
- Do **not** switch the interactive preview app back to pure `WindowGroup` / SwiftUI scene-hosted UI unless there is a very strong reason and fresh proof.

## The Key Root-Cause Discovery
We spent a long time chasing text entry failures in the macOS preview app.

The decisive isolation result was:

- `pureAppKitControls` works
- `appKitWindowHostingSwiftUI` works
- `minimalPureSwiftUIApp` fails

This means:

- raw keyboard input is fine
- `NSTextField` / `NSTextView` are fine
- SwiftUI `TextField` / `TextEditor` are fine when hosted inside AppKit
- `NSHostingView` is fine
- the break happens in the **SwiftUI `App` / `Scene` / `WindowGroup` lifecycle path** for this target/environment

Because of that, the preview app now defaults to the known-good architecture:

- manual AppKit window
- SwiftUI content hosted inside that window

## Current Default macOS Architecture

### Default Launch Mode
File:
- `apps/macos-preview/Sources/ProjectBobaMac/ProjectBobaMacApp.swift`

Current default:
- `rootInputIsolationMode = .appKitWindowHostingFullApp`

Important behavior:
- The `App` still has a compile-safe `WindowGroup`.
- In AppKit-hosting modes, the `WindowGroup` only hosts `EmptyView()`.
- The real interactive preview UI comes from the AppKit delegate-created window, not from the `WindowGroup`.

### AppKit Delegate
File:
- `apps/macos-preview/Sources/ProjectBobaMac/PureAppKitInputIsolationAppDelegate.swift`

This file now contains the root launch behavior for these modes:

- `.pureAppKitControls`
  - Manual `NSWindow` + raw `NSTextField` / `NSTextView`
- `.appKitWindowHostingSwiftUI`
  - Manual `NSWindow` + `NSHostingView(rootView: SwiftUIInputIsolationView())`
- `.appKitWindowHostingFullApp`
  - Manual `NSWindow` + `NSHostingView(rootView: PreviewHostedRootView())`
- `.minimalPureSwiftUIApp`
  - Delegate returns early; SwiftUI `WindowGroup` path is used only for isolation/debugging

### Hosted SwiftUI Roots
File:
- `apps/macos-preview/Sources/ProjectBobaMac/InputIsolationRootView.swift`

Relevant views:

- `SwiftUIInputIsolationView`
  - Minimal typing probe used for debugging the input boundary
- `PreviewHostedRootView`
  - Hosts `ContentView()`
  - This is what the AppKit full-app mode puts into `NSHostingView`

## Important macOS Files

### Root / Launch
- `apps/macos-preview/Sources/ProjectBobaMac/ProjectBobaMacApp.swift`
- `apps/macos-preview/Sources/ProjectBobaMac/PureAppKitInputIsolationAppDelegate.swift`
- `apps/macos-preview/Sources/ProjectBobaMac/InputIsolationRootView.swift`

### Product / App State
- `apps/macos-preview/Sources/ProjectBobaMac/Models.swift`
- `apps/macos-preview/Sources/ProjectBobaMac/BobaStore.swift`

### Main UI
- `apps/macos-preview/Sources/ProjectBobaMac/ContentView.swift`
- `apps/macos-preview/Sources/ProjectBobaMac/CompanionVisuals.swift`

## Current Name Model

### Persisted Names
Names are split into:

- `playerName`
- `companionName`

Files:
- `apps/macos-preview/Sources/ProjectBobaMac/Models.swift`
- `apps/macos-preview/Sources/ProjectBobaMac/BobaStore.swift`

### Intended Behavior
- `companionName`
  - The pet/companion name shown in the UI
  - Default should be `Henry`
- `playerName`
  - The human/user name
  - Used in supportive phrases
  - Fallback is `friend` if blank

### Henry Migration
Currently already implemented in two places:

1. `Models.swift`
   - During decode, legacy `avatarName` / untouched `Boba` is mapped to `Henry`
2. `BobaStore.swift`
   - Startup migration also upgrades blank or untouched `Boba` to `Henry`

Customized names should be preserved.

## Current Task System Status

### Task State / Persistence
Files:
- `apps/macos-preview/Sources/ProjectBobaMac/BobaStore.swift`
- `apps/macos-preview/Sources/ProjectBobaMac/Models.swift`

Tasks are persisted to:
- Application Support
- `state.json`

That is why tasks should survive relaunch.

### Add/Edit Task Flow
File:
- `apps/macos-preview/Sources/ProjectBobaMac/ContentView.swift`

Important current behavior:

- Add Task and Edit Task are in native sheets.
- Typing now works through the AppKit-hosted root architecture.
- Save buttons are aligned with the store’s actual validation rules:
  - title cannot be blank
  - tags cannot be empty
  - weekly tasks need at least one weekday
- After Add/Edit save, the task filter switches to `All`
  - this prevents a newly saved task from appearing to “disappear” if the current filter hides it

### Store Validation
File:
- `apps/macos-preview/Sources/ProjectBobaMac/BobaStore.swift`

`updateTask(_:)` now normalizes and validates:

- trimmed title
- trimmed notes
- minimum points
- sorted tags
- sorted weekdays
- one-off due date handling

### What Was a Real Failure Mode
Previously, a task could seem not to save because:

- the store rejected it
- but the sheet still dismissed
- or the saved task landed outside the current filter

The latest pass reduced that risk by aligning button enablement to store validation and forcing the post-save filter to `All`.

## Current UI / Product Recovery State

### Home Readability
File:
- `apps/macos-preview/Sources/ProjectBobaMac/ContentView.swift`

Small safe fixes made:
- companion name now sits on a readable capsule
- helper text capsule was strengthened slightly

This was meant to improve readability on busy backgrounds without changing layout structure.

### Companion Polish
File:
- `apps/macos-preview/Sources/ProjectBobaMac/CompanionVisuals.swift`

Small safe polish changes made:
- shoulder anchors lowered slightly
- arms shortened slightly
- tails thickened/rounded
- paws widened slightly
- Mooncap raised slightly

This was intentionally **not** a full avatar refactor.

### Background Safe Zones
File:
- `apps/macos-preview/Sources/ProjectBobaMac/CompanionVisuals.swift`

Small scene-composition fixes made:
- Twilight Window bars moved farther out/up
- Underwater kelp moved away from the avatar-safe center area

Purpose:
- reduce strong background lines directly behind the avatar’s head/body

## Current Navigation / Structure
File:
- `apps/macos-preview/Sources/ProjectBobaMac/ContentView.swift`

The macOS preview currently uses a custom top shell (`BobaAppShell`) with a segmented `Picker`.

This is the current state of the preview app.
Do not casually rewrite it in a new session unless there is a specific reason.

## Important Debug / Isolation Modes to Keep
File:
- `apps/macos-preview/Sources/ProjectBobaMac/InputIsolationRootView.swift`

Keep these modes available:

- `.pureAppKitControls`
- `.appKitWindowHostingSwiftUI`
- `.appKitWindowHostingFullApp`
- `.minimalPureSwiftUIApp`

These are valuable because they encode the proven debugging boundary:

- AppKit path works
- SwiftUI-in-AppKit path works
- pure SwiftUI App/WindowGroup path fails in this target/environment

## Things the Next Session Should Not Accidentally Undo

1. Do **not** switch the interactive preview app back to `WindowGroup`-hosted SwiftUI.
2. Do **not** remove the AppKit-hosted full-app mode.
3. Do **not** assume typing bugs are inside the text fields themselves.
4. Do **not** restart a giant companion visual rewrite unless explicitly requested.
5. Do **not** touch Android unless the task clearly asks for Android work.

## Recommended Starting Files for a New Session

If the next session is about the macOS preview app, start here:

1. `apps/macos-preview/Sources/ProjectBobaMac/ProjectBobaMacApp.swift`
2. `apps/macos-preview/Sources/ProjectBobaMac/PureAppKitInputIsolationAppDelegate.swift`
3. `apps/macos-preview/Sources/ProjectBobaMac/InputIsolationRootView.swift`
4. `apps/macos-preview/Sources/ProjectBobaMac/BobaStore.swift`
5. `apps/macos-preview/Sources/ProjectBobaMac/ContentView.swift`
6. `apps/macos-preview/Sources/ProjectBobaMac/CompanionVisuals.swift`
7. `apps/macos-preview/Sources/ProjectBobaMac/Models.swift`

## Practical Testing Notes

### What to Run
Use Xcode on the Mac for real verification.

### Why CLI build output is not a reliable signal here
Local `swift build` attempts from this Codex environment have been unreliable because of:

- Swift toolchain / SDK mismatch
- local module cache permission issues

So:
- trust Xcode runtime testing on the Mac
- do not over-trust CLI build failures from this environment unless they are clearly syntax errors

## Suggested Next Session Focus
Good next-session targets:

1. Verify Add Task and Edit Task end-to-end in Xcode after the latest task-flow stabilization.
2. Check rename companion / profile name flows now that typing works through the AppKit-hosted root.
3. Do small UI/product fixes only after confirming no regressions in input and persistence.

## Short Summary for the Next Session

If you only remember one thing, remember this:

> The macOS preview app now works because the real SwiftUI UI is hosted inside a manual AppKit `NSWindow` via `NSHostingView`. Keep that architecture intact.

