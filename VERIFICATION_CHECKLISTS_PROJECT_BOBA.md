# Manual Xcode Verification Checklists

Run these in Xcode on your Mac after each phase. These are things Claude Code cannot verify — they require actual runtime testing.

---

## Pre-Phase 1 Baseline Check
Run this BEFORE starting any Phase work to confirm the repo is in a good state.

- [ ] Open `apps/macos-preview` in Xcode
- [ ] Build succeeds (Cmd+B)
- [ ] Run the app (Cmd+R)
- [ ] App window appears with the real UI (not a blank/empty window)
- [ ] Home tab loads with companion avatar visible
- [ ] Tap the companion → phrase bubble appears and auto-dismisses
- [ ] Navigate to Tasks tab → task list visible
- [ ] Navigate to Companion tab → Look and Bag sub-sections accessible
- [ ] Navigate to Settings tab → sound toggle visible
- [ ] Type in any text field (e.g., try adding a task) → typing works
- [ ] Quit and relaunch → state persists

If ANY of these fail, do not start Phase 1. Debug from the baseline.

---

## After Phase 1

### Core functionality
- [ ] App compiles and launches
- [ ] Typing works in all text fields (task title, task notes, companion name, player name)

### Task flows
- [ ] Add Task: enter title + select tags → Save creates the task
- [ ] Add Task: blank title → Save button is disabled
- [ ] Add Task: no tags selected → Save button is disabled
- [ ] Add Task: weekly recurrence with no weekdays → Save button is disabled
- [ ] Edit Task: tap edit on an existing task → sheet opens with pre-filled data
- [ ] Edit Task: modify title → Save updates the task
- [ ] Edit Task: Cancel → no changes to the task
- [ ] Delete Task: delete a non-starter task → task is removed
- [ ] Delete Task: confirmation dialog appears before deletion
- [ ] After save, the filter switches to All and the task is visible
- [ ] Quit and relaunch → all tasks persist

### Name model
- [ ] Default companion name shows as "Henry" (fresh state or migrated from "Boba")
- [ ] Rename companion works (Companion tab or Settings)
- [ ] Player name can be set (Settings)
- [ ] Tap companion → phrase says "friend" (if no player name) or your name (if set)
- [ ] Phrase does NOT use the companion's name

### Settings
- [ ] Player name and companion name shown with edit buttons
- [ ] Reset data works (returns to starter state after confirmation)
- [ ] Grant test points adds 200 points
- [ ] Sound toggle works

### Phrases
- [ ] Tap companion multiple times → notice more variety than before
- [ ] No phrase feels broken or shows raw "%s"

---

## After Phase 2

### Companion visuals
- [ ] Penguin avatar looks correct (arms, paws, body proportions)
- [ ] Bear avatar looks correct (ears visible, tail reads as tail)
- [ ] Bunny avatar looks correct (ears visible, tail round)
- [ ] Equipped hat sits properly on head (not too low)
- [ ] Equipped scarf sits at neck level
- [ ] Equipped glasses sit on face correctly
- [ ] Equipped gloves/mittens align with arms
- [ ] Accessory pin is visible

### Readability
- [ ] Switch to each background (buy from shop or set via test points):
  - [ ] Snowy Nook: all home text readable
  - [ ] Twilight Window: all home text readable
  - [ ] Winter Market: all home text readable
  - [ ] Fireplace Nook: all home text readable
  - [ ] Underwater: all home text readable
- [ ] Stats row readable on all backgrounds
- [ ] Companion name capsule readable on all backgrounds
- [ ] Phrase bubble readable on all backgrounds

### Background safe zones
- [ ] No background scene element creates a strong line through the avatar's body/head
- [ ] Avatar is clearly distinguishable from the background on all scenes

### Phrase bubble
- [ ] Phrase bubble appears and disappears smoothly
- [ ] Long phrases wrap correctly (don't overflow)
- [ ] Points burst animation doesn't collide with phrase bubble

---

## After Phase 3

### Overall feel
- [ ] The app feels cohesive — like one warm world across all tabs
- [ ] Navigation switching feels smooth and styled (not default system picker)
- [ ] Cards are consistent across all pages

### Per-page checks
- [ ] Home: stats feel cozy, companion is the hero, tasks feel actionable
- [ ] Tasks: tag chips have gentle color coding, completed tasks look different from open
- [ ] Shop: items feel like treasures, balance display is warm
- [ ] Companion: avatar preview is prominent, Bag feels like a collection
- [ ] Settings: sections are clearly organized

### Tag colors
- [ ] Each tag has a subtly different warm color
- [ ] Colors are gentle tints, not saturated

### Task completion
- [ ] Completing a task feels satisfying (visual + optional sound)
- [ ] The checkmark/toggle is clear and tappable

### No regressions
- [ ] Typing still works everywhere
- [ ] Tasks still persist across relaunch
- [ ] All sheets still open and dismiss correctly
- [ ] Companion name is still "Henry" by default
- [ ] Phrases still use player name correctly

---

## Quick Smoke Test (run anytime)
If you just want a 2-minute sanity check:

1. Build and run
2. Type a task title → typing works
3. Save the task → it appears in the list
4. Tap the companion → phrase appears with your name or "friend"
5. Switch between all 5 tabs → no crashes
6. Quit and relaunch → task is still there
