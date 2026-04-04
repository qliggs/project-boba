# Phase 3 — UI Design Pass

## Context
Read `AGENTS.md` at the repo root before making changes. Phases 1 and 2 must be completed before this phase.

This phase assumes the app compiles, the phrase system is expanded, the companion has been polished, readability issues are resolved, and background safe zones are in place.

**Do not touch anything in `apps/android-app`.**
**Do not change the root architecture or launch mode.**
**Do not break existing functionality for visual changes.**

---

## Design Direction

### What Project Boba should feel like
This is a cozy, warm, emotionally supportive to-do app. The UI should feel like wrapping up in a soft blanket with a warm drink. Think:
- Studio Ghibli comfort scenes
- Sanrio character warmth
- Indie cozy games (Unpacking, A Short Hike, Cozy Grove)
- Soft morning light, warm wood tones, gentle textures

### What it should NOT feel like
- Corporate wellness app
- Generic flat design
- Harsh, high-contrast productivity tool
- Over-designed with too many competing visual elements
- "AI-generated app" with cookie-cutter components

### Color palette (already established in `BobaTheme`)
The existing warm brown/cream palette is correct for the product. Do not switch to blues, purples, or cool tones. The palette should evoke:
- Warm wood
- Cream paper
- Soft cocoa
- Autumn light
- Cozy interiors

### Typography
The app uses `.rounded` design for headers and system fonts for body text. This is appropriate. If adjusting:
- Headers should feel friendly and hand-crafted, not clinical
- Body text should be clear and readable above all else
- Use weight variation (`.medium`, `.semibold`, `.bold`) rather than size variation for hierarchy

---

## PART 1 — Card and container design system

### Current state
Cards throughout the app use `BobaTheme.cardBackground` with `RoundedRectangle` corners and occasional borders. This works but every card looks the same, and the overall feel is functional rather than delightful.

### What to improve

Create a small, reusable card system in `ContentView.swift` (or a new `BobaComponents.swift` if ContentView is already very long):

1. **`CozyCard` modifier or view wrapper**: A standard card container used across all pages. Properties:
   - Warm background (cream/off-white from `BobaTheme`)
   - Slightly rounded corners (20-24pt radius)
   - Very subtle shadow (tiny, warm-toned — not a harsh drop shadow)
   - Optional thin warm border
   - Consistent padding

2. **`FeaturedCard` variant**: For highlighted content (featured goal, active quest, special items). Slightly different background — maybe a warmer tone or a subtle gradient from cream to light peach. A faint accent border.

3. **`CompactCard` variant**: For smaller items like individual task rows, shop items. Slightly less padding, slightly less corner radius.

Apply these consistently across:
- Home page cards (stats, today at a glance, quick tasks, featured goal)
- Tasks page (task list items, add task form)
- Shop page (shop items, balance display)
- Companion page (look section, bag section)
- Settings page (sections)

### Validation
- Cards feel consistent across all pages
- The visual hierarchy is clear: featured > standard > compact
- No harsh visual breaks between pages — the app feels like one cohesive world
- Warm palette is preserved throughout

---

## PART 2 — Navigation and shell polish

### Current state
`BobaAppShell` uses a segmented `Picker` for navigation. This is functional but feels like a default macOS control rather than part of the cozy world.

### What to improve

1. **Custom tab bar feel**: Replace or style the segmented picker to feel warmer. Options:
   - Custom pill-shaped buttons with the `BobaTheme` palette
   - Soft selected state (warm brown fill with light text) and muted unselected state
   - Subtle transition animation between sections
   - SF Symbols should be visible alongside labels

2. **Section transitions**: When switching between tabs, a subtle crossfade or slide feels more polished than an instant swap. Keep it fast (0.15-0.2s) — don't make the user wait.

3. **Top bar area**: The shell header area (above the content) should feel like part of the cozy world, not a floating toolbar. Consider:
   - Matching the page background color
   - A very subtle bottom border or shadow to separate from scrollable content
   - The app name or a small companion icon in the top bar (optional)

### Validation
- Navigation feels warm and intentional, not like a default system control
- Selected/unselected states are clearly distinguishable
- Tab switching feels smooth
- The navigation bar feels like part of the app's personality

---

## PART 3 — Home screen composition

### Current state
The home screen has stats, companion, today-at-a-glance, featured goal, and quick tasks. These are functional but the overall composition could feel more intentional.

### What to improve

1. **Visual flow**: The eye should travel: companion (emotional center) → stats (quick status) → today's tasks (actionable). Make sure the visual weight supports this flow. The companion should feel like the hero of the page, not just one card among many.

2. **Stats row refinement**: The stats (Points, Daily progress, Weekly progress) should feel like cozy little badges, not data cells. Consider:
   - Pill or capsule shapes with warm fills
   - Small contextual icons (a star for points, a sun for daily, a calendar leaf for weekly)
   - The numbers should be prominent but warm, not clinical

3. **Today at a Glance**: This card should feel like a gentle morning checklist, not a progress dashboard. The progress indicator should be encouraging. Consider:
   - A warm-toned progress bar (not default blue)
   - Friendly language: "3 of 5 little wins today" rather than "3/5 completed"
   - A subtle celebration state when all tasks are done

4. **Quick tasks list**: Individual task rows should feel tappable and satisfying. The completion checkmark should feel rewarding — not just a functional toggle.

### Validation
- Home screen feels like opening a warm little world
- Visual hierarchy guides the eye naturally
- Stats feel cozy, not clinical
- Task completion feels satisfying

---

## PART 4 — Tasks page refinement

### Current state
The Tasks page has a filter bar, task list, and add/edit sheets. Functional but plain.

### What to improve

1. **Task rows**: Each task should feel like a little card or note. Consider:
   - Tag chips with warm colors (each tag category could have a subtle color association)
   - Points displayed in a warm badge
   - Clear visual distinction between open and completed tasks (completed = muted, maybe slightly smaller)
   - The completion toggle should feel tactile

2. **Tag chip colors**: Currently all tag chips look the same. Assign subtle, warm color associations:
   - Hygiene → soft blue-green (spa/clean)
   - Chores → warm amber (home/cabin)
   - Work → muted slate (focused)
   - Self-care → soft pink (gentle)
   - Mental health → lavender (calm)
   - Social → warm coral (connection)
   - Health → fresh green (vitality)
   - Creative → soft gold (playful)
   
   These should be gentle tints, not saturated primary colors. Think watercolor washes, not markers.

3. **Add Task sheet**: The sheet should feel inviting, not like a form. Warm backgrounds, clear labels, encouraging microcopy. The tag selection area should use the colored chips from above.

4. **Empty states**: Per Phase 1, if empty states were added, make sure they feel friendly and encouraging, not sad. Maybe a tiny companion silhouette with a speech bubble.

### Validation
- Tasks page feels cohesive with the rest of the app
- Tags have gentle, distinguishable colors
- Task completion feels satisfying
- Add/edit sheets feel inviting
- Empty states feel encouraging

---

## PART 5 — Shop page refinement

### Current state
The Shop page lists items with buy/equip buttons. Functional but flat.

### What to improve

1. **Shop item cards**: Each item should feel like a little treasure to discover. Consider:
   - A slightly warmer or special background for the card
   - The item title should feel like a label on a gift
   - The price should feel approachable, not transactional
   - "Track affinity" should feel like flavor text, not a requirement label

2. **Owned vs. unowned distinction**: Owned items should feel collected and warm (a subtle glow or badge). Unowned items should feel aspirational but not out of reach.

3. **Equip/unequip**: The equip state should feel active and proud. The item card could have a subtle highlight or border change when equipped.

4. **Balance display**: The points balance at the top should feel like a cozy wallet or pouch, not a bank balance. Warm styling, maybe a small coin or star icon.

### Validation
- Shop feels like browsing a cozy market, not a storefront
- Owned items feel like cherished possessions
- The balance display feels warm and personal
- Buy/equip interactions are clear

---

## PART 6 — Companion page refinement

### Current state
The Companion page has Look (avatar selection, name) and Bag (owned items) sub-sections with a pill selector.

### What to improve

1. **Look section**: The avatar preview should feel central and proud. The avatar kind selection (penguin/bear/bunny) should feel like choosing a friend, not selecting from a dropdown. Consider:
   - Larger avatar preview with the background scene behind it (mini version)
   - Avatar kind cards that show a small preview of each option
   - The rename button should feel gentle and accessible

2. **Bag section**: Owned cosmetics should feel like a warm collection — a little treasure box. Consider:
   - Grid layout instead of a list for cosmetics
   - Small preview icons or color swatches for each item
   - "Equipped" badge on active items
   - Categorized by type (hats, scarves, etc.) with gentle section headers

3. **Pill selector (Look / Bag)**: Should match the nav bar styling — warm, cozy, not default system style.

### Validation
- Companion page feels like a personal, warm space
- Avatar preview is prominent and appealing
- Bag feels like a collection, not a settings list
- Sub-section switching is smooth and styled

---

## Implementation notes

### File organization
`ContentView.swift` is already 3,200+ lines. If this phase adds significant new component code, consider extracting reusable components into a new `BobaComponents.swift` file. Move into it:
- `CozyCard` / `FeaturedCard` / `CompactCard` modifiers
- `CozyStat` (already exists)
- `TagChip` (already exists)
- `FlowLayout` (already exists)
- `PillSelector` (if it exists)
- Any new reusable UI building blocks

Keep page-level views (`HomeView`, `TasksView`, `ShopView`, `AvatarView`, `SettingsView`) in `ContentView.swift`.

### Color discipline
All new colors should go through `BobaTheme` as static properties. Do not hardcode `Color(red:green:blue:)` inline. If adding tag-specific colors, add them as a static function or dictionary on `BobaTheme`.

### Animation discipline
Keep animations fast and subtle. The app should feel responsive, not sluggish. Max 0.25s for transitions. Use `.spring` with moderate damping for anything that should feel organic. Do not add animations to every element — use them where they create delight (task completion, tab switching, phrase bubble).

### Accessibility baseline
- All text should meet WCAG AA contrast ratio against its background
- Interactive elements should have clear tap targets (minimum 44×44 conceptually)
- Don't rely solely on color to convey state — use shape, icon, or label too

---

## Deliverables
At the end, provide a summary of:
1. Every file created and modified
2. New reusable components created (card system, etc.)
3. Navigation/shell changes
4. Per-page summary of visual improvements
5. Tag color assignments
6. Any new `BobaTheme` properties added
7. Confirm root architecture was not changed
8. Anything that needs manual Xcode verification
9. Before/after description of the overall feel change
