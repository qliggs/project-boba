# Phase 1 — Verification Pass + Phrase Expansion + Targeted Fixes

## Context
Read `AGENTS.md` at the repo root before making changes.

The macOS preview app has already been through a major stabilization pass. The AppKit-hosted architecture is in place, the name model is split (`companionName` / `playerName`), task CRUD exists (add/edit/delete), and the companion visuals have been extracted. This phase is about **hardening what exists** and addressing the gaps the stabilization pass left behind.

**Do not touch anything in `apps/android-app`.**
**Do not change the root architecture or launch mode.**

---

## PART 1 — Verification and small compile/runtime fixes

Before changing anything, read through these files and flag any obvious issues:

1. `ProjectBobaMacApp.swift` — confirm `appKitWindowHostingFullApp` is default
2. `PureAppKitInputIsolationAppDelegate.swift` — confirm all 4 isolation modes exist
3. `InputIsolationRootView.swift` — confirm `PreviewHostedRootView` wraps `ContentView()`
4. `BobaStore.swift` — confirm add/edit/delete task flows, Henry migration, `displayPlayerName` fallback
5. `Models.swift` — confirm `companionName`, `playerName`, `TaskRecurrence`, `BobaWeekday`
6. `ContentView.swift` — confirm `AddTaskSheet`, `TaskEditSheet`, `RenameCompanionSheet`, `ProfileNameSheet` exist
7. `CompanionVisuals.swift` — confirm `AvatarScene`, `BackgroundScene`, avatar rig

If any of these files have compile errors, fix them. If any view references a function or property that doesn't exist in the store, fix the reference. The goal is a clean compile with zero warnings related to our code.

### Specific things to check and fix if broken:
- `AddTaskSheet` save button should be disabled when title is blank OR tags are empty OR (recurrence is `.weekly` and no weekdays selected)
- `TaskEditSheet` save button should follow the same validation rules
- After saving a new task or editing a task, the task filter on the Tasks page should switch to `All` so the saved task is visible
- Cancel on any sheet should dismiss without mutating store data
- `deleteTask` should work on non-starter tasks (starter tasks should either be non-deletable or show a confirmation)

### Validation
- App compiles cleanly
- App launches in `appKitWindowHostingFullApp` mode
- All sheets open and dismiss correctly
- Save button enablement matches validation rules

---

## PART 2 — Expand the supportive phrase system

### Current state
The phrase pool in `BobaStore.swift` (`availablePhrases`) has:
- 6 base phrases
- 2 supportive pack phrases (gated by `phrases_supportive` ownership)
- 2 whimsy pack phrases (gated by `phrases_whimsy` ownership)

This is too few. Tapping the companion quickly cycles through repeats.

### What to do

**Expand base phrases to 18-20.** All phrases use `%s` which gets replaced with `displayPlayerName` (player's name, or `"friend"` fallback). The tone should be:

Warm and gentle — like a kind friend, not a corporate wellness poster. Mix of:
- Sincere encouragement that acknowledges small effort ("showing up counts")
- Gentle humor that doesn't undercut the warmth
- Cozy/comfort imagery (tea, blankets, warm light, soft mornings)
- "Small wins matter" energy without being preachy
- Occasional playful self-awareness from the companion

Write original phrases. Here are tonal directions (do NOT copy these verbatim, write your own):
- Acknowledging that just trying is an achievement
- Celebrating tiny routines as meaningful
- Light humor about being cozy or round
- Warmth about mornings, evenings, small rituals
- Encouragement that doesn't create pressure
- The companion noticing and being proud

**Expand supportive pack to 6 phrases.** Same `%s` pattern. These should be slightly more emotionally direct — the kind of thing someone buys when they want the app to feel more personal.

**Expand whimsy pack to 6 phrases.** Same `%s` pattern. These should be playful, silly, and personality-forward — the companion being a goofball.

### Validation
- Tapping the companion produces noticeably more variety
- Phrases use `%s` correctly (substituted with player name or "friend")
- No phrase references the companion's name — they all address the player
- Tone across the three pools feels distinct: base (warm/balanced), supportive (emotionally direct), whimsy (playful/silly)
- No duplicate or near-duplicate phrases across pools

---

## PART 3 — Settings page improvements

### Current state
The Settings page (`SettingsView` in `ContentView.swift`) is minimal — just a sound toggle and a description string.

### What to add

1. **Profile section** at the top:
   - Show current `playerName` with an edit button (opens `ProfileNameSheet`)
   - Show current `companionName` with an edit button (opens `RenameCompanionSheet`)
   - Helper text: "Your name is used in supportive phrases. Your companion's name appears on the home screen."

2. **Preview data section** at the bottom:
   - The `resetPreviewData()` and `grantTestPoints()` functions already exist in `BobaStore`
   - Add buttons for "Reset All Data" (with confirmation alert) and "Add Test Points (+200)"
   - Label this section "Preview Tools" with a note that these are for testing

3. **App info section**:
   - Simple text: "Project Boba — macOS Preview" and a version note like "Preview Build"

### Validation
- Settings page shows profile names and allows editing
- Reset data works (with confirmation) and returns to starter state
- Grant test points adds 200 points
- Sound toggle still works

---

## PART 4 — Task list UX improvements

### Current state
The Tasks page has add/edit/delete functionality but a few UX gaps.

### What to improve

1. **Empty state**: If there are no tasks matching the current filter, show a friendly empty state message instead of a blank area. Something like "No tasks here yet" with context based on the active filter.

2. **Completed task visual distinction**: Tasks that are completed today (for daily) or this week (for weekly) should have a subtle visual indicator — a checkmark, a muted style, or a strikethrough. The `isTaskCompleted()` function already exists on the store.

3. **Task count in filter pills**: If the task filter pills (Today / Daily / Weekly / All) exist, show the count of tasks in each filter. E.g., "Daily (8)" or "All (14)".

4. **Confirm before deleting**: If delete doesn't already have a confirmation step, add one — especially for non-starter tasks. A simple `.alert` is fine.

### Validation
- Empty state shows when a filter has no tasks
- Completed tasks are visually distinguishable from open tasks
- Filter pills show task counts
- Delete has a confirmation step
- No existing functionality is broken

---

## Deliverables
At the end, provide a summary of:
1. Every file modified and what changed
2. Any compile issues found and fixed
3. Total phrase counts per pool (base, supportive, whimsy)
4. What was added to Settings
5. What task list UX improvements were made
6. Confirm `appKitWindowHostingFullApp` remains the default
7. Anything that needs manual Xcode verification
