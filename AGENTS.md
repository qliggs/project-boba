AGENTS.md — Project Boba
What This Project Is
Project Boba is a cozy, warm, gamified to-do list app with a companion/avatar at the emotional center. Inspired in spirit by Finch (gentle encouragement, companion-first motivation, daily/weekly progress, cosmetics/inventory), but it is its own original product.
Long-term target: Android / Google Pixel. Current development: macOS preview app as the product sandbox.
Current Strategy
Do not work on Android yet. Use the macOS preview app to validate flows and interactions. Only port to Android once product behavior is stable.
Repo Structure
project-boba/
├── AGENTS.md
├── SESSION_HANDOFF.md
├── README.md, CODING_STATUS.md, PRODUCT_DECISIONS.md, etc.
├── apps/
│   ├── android-app/          # DO NOT TOUCH
│   └── macos-preview/
│       ├── Package.swift     # Swift 6.0, macOS 14+
│       └── Sources/ProjectBobaMac/
│           ├── ProjectBobaMacApp.swift                    # App entry, AppKit delegate adaptor
│           ├── PureAppKitInputIsolationAppDelegate.swift  # AppKit window hosting, 4 isolation modes
│           ├── InputIsolationRootView.swift               # SwiftUI roots hosted in AppKit
│           ├── ContentView.swift                          # All page views (~3,300 lines)
│           ├── CompanionVisuals.swift                     # Avatar rig, background scenes (~1,120 lines)
│           ├── Models.swift                               # Data models, AppState, shop inventory
│           └── BobaStore.swift                            # State management, persistence, validation
Critical Architecture: AppKit-Hosted SwiftUI
The typing bug
Pure SwiftUI App / WindowGroup lifecycle causes keyboard input to fail in this macOS target. This was isolated and proven through manual Xcode testing.
The fix
The app uses a manual AppKit NSWindow hosting SwiftUI content via NSHostingView. Default mode: appKitWindowHostingFullApp.
Launch flow

ProjectBobaMacApp.swift declares @NSApplicationDelegateAdaptor(PureAppKitInputIsolationAppDelegate.self)
The WindowGroup serves EmptyView() in AppKit modes
PureAppKitInputIsolationAppDelegate creates the real window in applicationDidFinishLaunching
The window hosts PreviewHostedRootView() → ContentView() via NSHostingView

Isolation modes (keep all of these)

.pureAppKitControls — raw NSTextField/NSTextView in AppKit
.appKitWindowHostingSwiftUI — NSHostingView with minimal SwiftUI typing probe
.appKitWindowHostingFullApp — NSHostingView with real app content (DEFAULT)
.minimalPureSwiftUIApp — the broken WindowGroup path, for debugging only

Current Feature State
Navigation
Custom BobaAppShell with segmented Picker: Home → Tasks → Shop → Companion → Settings
Name model

companionName — pet name (default: "Henry")
playerName — user's name (default: "", displayed as "friend")
Supportive phrases address the player, not the companion
Henry migration: legacy "Boba" → "Henry", custom names preserved

Task system

CRUD: add, edit, delete, move (reorder), toggle completion
Recurrence: .daily, .weekly, .oneOff
Weekly tasks need weekdays; one-off tasks need a due date
Validation: non-empty title, non-empty tags, weekly needs weekdays, min 5 points
Persisted to Application Support / state.json
Sheets: AddTaskSheet, TaskEditSheet
Filters: Today, Daily, Weekly, All
Gentle streak: 3 completed tasks qualifies a day

Companion visuals

3 avatar kinds: penguin, bear, bunny
Avatar rig with body, head, belly, ears, eyes, nose, arms, paws, tail
5 background scenes: snowy_nook, twilight_window, winter_market, fireplace_nook, underwater
Cosmetic overlays: hat, scarf, eyewear, gloves, accessory
Equip/unequip in store

Shop

9 items: beanie, scarf, glasses, mittens, star pin, 2 backgrounds, 2 phrase packs
Points-based purchase
Track affinity (required tag)

Phrases

6 base + 2 supportive pack + 2 whimsy pack = 10 total (needs expansion)
%s → displayPlayerName (player name or "friend")
Auto-dismiss after ~4.2 seconds

Product Direction
Tone
Cozy, warm, cute, gentle, rewarding, companion-first, emotionally supportive. No punishment, shame, guilt, or pressure.
Design

Soft visuals but readable and usable
Warm brown/cream palette (established in BobaTheme)
Fewer, better cosmetics over many weak placeholders
Backgrounds should become richer micro-scenes over time

Cosmetics philosophy

Headwear is the strongest category
Glasses need larger/thicker frames
Scarf placement needs polish
Underwater mini-set is desired eventually

Rules
DO NOT

Switch back to WindowGroup-hosted interactive UI
Remove the AppKit-hosted full-app mode
Remove isolation/debug modes
Giant companion visual rewrite (unless explicitly requested)
Touch Android unless the task clearly asks for it
Assume typing bugs are in the text fields (the bug is in the lifecycle)
Over-trust CLI swift build (use Xcode for real testing)

DO

Keep appKitWindowHostingFullApp as default
Keep all isolation modes available
Validate text entry works in any UI you modify
Use BobaStore persistence patterns (trim, normalize, validate)
Add new colors to BobaTheme, not inline
Commit compilable code
Summarize all changes at the end of each pass
