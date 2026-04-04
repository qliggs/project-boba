# Phase 2 — Companion Polish + Readability + Background Safe Zones

## Context
Read `AGENTS.md` at the repo root before making changes. Phase 1 must be completed before this phase.

This phase assumes the app compiles, launches in `appKitWindowHostingFullApp` mode, and the phrase system has been expanded.

**Do not touch anything in `apps/android-app`.**
**Do not change the root architecture or launch mode.**
**This is targeted polish, not a redesign.**

---

## PART 1 — Companion visual polish

All changes in `CompanionVisuals.swift`. The avatar system already has `AvatarScene`, `SimpleBaseCompanion`, `SimpleAvatarBody`, `SimpleAvatarArm`, and `AvatarRig` / `AvatarPalette`.

### Read the current rig first
Before making changes, read and understand:
- `AvatarRig` — contains the numeric constants for body proportions, arm anchors, etc.
- `SimpleBaseCompanion` — assembles the body, head, belly, ears, eyes, nose
- `SimpleAvatarArm` — draws each arm
- Hat/scarf/eyewear/gloves/accessory overlay logic

### Adjustments to make

These are small, targeted tweaks. Change numeric values by small amounts (2-6 points typically). Do NOT restructure the view hierarchy.

1. **Lower arm/shoulder anchors**: Find the arm anchor Y offsets in `AvatarRig` or in the arm positioning logic. Shift them down by ~4-6 points so the companion doesn't look hunched or like the arms are growing from the neck.

2. **Shorten arms slightly**: Reduce arm length by ~6-10 points. The arms should feel stubby and cute, not dangling.

3. **Thicken and round the tail**: The tail shape (likely a narrow rounded rectangle or ellipse) should be wider and rounder. Increase width by ~4-6 points and ensure corner radius makes it feel soft/round. The tail should unmistakably read as a tail, not as a third leg.

4. **Improve paw/foot shapes**: Widen paws by ~3-5 points. Make them rounder. They should look like little bean-shaped feet, not thin stubs.

5. **Raise headwear (hat/beanie) position**: The equipped hat overlay should sit ~4-6 points higher on the head so it looks perched on top rather than pulled down over the face. Find the hat Y offset and adjust.

6. **Ears**: If bear/bunny ears exist, make sure they're clearly visible and not hidden under hats. If the hat overlaps ears, the ears should either poke through or the hat should sit above them.

### Design direction reminder
The companion should feel:
- Round, soft, plush-toy proportioned
- Clearly cute — Sanrio/Squishmallow energy
- Readable at the rendered size
- Each avatar kind (penguin, bear, bunny) should be clearly distinguishable

### Validation
- All three avatar kinds render correctly after changes
- Cosmetics (hat, scarf, eyewear, gloves, accessory) still align properly
- No visual clipping or misalignment
- Side-by-side mental comparison: the silhouette should feel cuter and more balanced
- Test with and without equipped cosmetics

---

## PART 2 — Homepage readability

Changes in `ContentView.swift`, specifically in `HomeView`, `HomeStatsRow`, `HomeCompanionSection`, `CompanionHero`, `TodayAtGlanceCard`, `QuickTasksCard`, and `CozyStat`.

### Current state
The home screen already has some readability work — the companion name sits on a capsule background, helper text has a capsule, cards have `BobaTheme.cardBackground` backgrounds. But readability against all 5 background scenes (snowy_nook, twilight_window, winter_market, fireplace_nook, underwater) may still have gaps.

### What to verify and fix

1. **Stats row (`HomeStatsRow` / `CozyStat`)**: The stats (Points, Daily, Weekly) need to be readable against ALL backgrounds. If they currently use `.ultraThinMaterial` or a semi-transparent background, verify contrast against the darkest background (twilight_window) and the lightest (snowy_nook). Strengthen the background opacity if needed — `BobaTheme.cardBackground.opacity(0.92)` or similar with a subtle border.

2. **Companion name capsule**: Already has a capsule background. Verify it's readable against all 5 backgrounds. The current `0.96` opacity should be strong enough but check.

3. **Phrase bubble (`CompanionBubble` in CompanionVisuals.swift)**: This appears when the user taps the companion. Verify it's readable against all backgrounds. If it uses a white/light background, it should be fine, but check the text color has enough contrast.

4. **Today at a Glance card**: Should have a solid enough card background to be universally readable.

5. **Quick Tasks card**: Same — verify card background strength.

6. **Featured Goal card**: If it exists, verify readability.

### General rule
Every piece of text on the home screen should be readable against every background scene. If in doubt, strengthen the card/capsule background opacity rather than changing text color. The warm, cozy palette should be preserved — don't switch to high-contrast black-on-white, just ensure the existing warm tones have enough backing.

### Validation
- All text on Home is readable against all 5 background scenes
- No layout changes — only contrast/opacity/background adjustments
- The warm/cozy visual feel is preserved

---

## PART 3 — Background safe zones

Changes in `CompanionVisuals.swift`, in the individual background scene views (`TwilightWindowScene`, `WinterMarketScene`, `FireplaceNookScene`, `UnderwaterScene`, `SnowyNookScene`).

### Problem
Background scene elements (window bars, kelp, snowflakes, fireplace flames, market lanterns) can visually merge with the companion avatar when they occupy the center of the screen.

### What to do

1. **Define a safe zone**: The companion avatar renders in roughly a 260×320 area centered horizontally and positioned in the upper-center of the home screen. Background scene elements should avoid strong lines, high-contrast shapes, or busy detail in this center zone.

2. **Review each scene**:
   - `TwilightWindowScene`: If window frame bars cross the center, move them further apart horizontally or higher vertically
   - `WinterMarketScene`: If lanterns or stall shapes occupy the center, shift them to the sides
   - `UnderwaterScene`: If kelp or bubbles are in the center, move kelp to the edges and keep bubbles small/subtle in the center area
   - `FireplaceNookScene`: If flames or mantle elements are centered, ensure they're below the avatar zone
   - `SnowyNookScene`: If any elements cross center, adjust

3. **Subtle avatar backdrop**: The avatar already renders on a `CompanionBubble` (a circle behind it). If the circle's opacity is too low to separate the avatar from busy backgrounds, consider bumping it from its current value to slightly higher (try +0.04-0.06 opacity). Don't make it a solid white disc — just enough to create visual breathing room.

### Validation
- The companion avatar is clearly readable against all 5 backgrounds
- No background scene element creates a strong line through the avatar's head/body area
- The backgrounds still feel like rich micro-scenes, not empty voids
- The separation is subtle, not jarring

---

## PART 4 — Companion bubble and phrase display polish

### Current state
`CompanionBubble` in `CompanionVisuals.swift` displays the phrase when the user taps the companion. The phrase auto-dismisses after ~4.2 seconds.

### What to improve

1. **Phrase bubble positioning**: The bubble currently offsets from the top-right of the companion hero area. Verify it doesn't overlap the companion's face or get clipped by the screen edge. Adjust offset if needed.

2. **Phrase bubble animation**: The current transition is `.scale(scale: 0.9).combined(with: .opacity)`. This is fine. If it feels abrupt, consider a slightly softer spring (longer response, lower damping). Don't over-animate.

3. **Phrase bubble sizing**: Long phrases might cause the bubble to become very wide or wrap awkwardly. Set a `maxWidth` of ~280-300 on the bubble text so it wraps neatly. Verify with the longest phrase in the expanded pool.

4. **Points burst display**: When a task is completed, `latestPointsBurst` shows a "+X" animation. Verify this still renders correctly and doesn't collide with the phrase bubble.

### Validation
- Phrase bubble appears and disappears smoothly
- Bubble doesn't overlap the companion's face
- Long phrases wrap correctly within the bubble
- Points burst and phrase bubble don't collide visually

---

## Deliverables
At the end, provide a summary of:
1. Every file modified and what changed
2. Specific companion rig values changed (before → after for each adjustment)
3. What readability fixes were made on the home screen
4. What background safe zone adjustments were made per scene
5. What phrase bubble display improvements were made
6. Confirm that the root architecture was not changed
7. Anything that needs manual Xcode verification
