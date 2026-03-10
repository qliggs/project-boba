# MacOS Preview Walkthrough

The Mac preview app lives here:

`/Users/quentinligginsjr/Documents/Quentin Liggins Jr/Project Boba/macos-preview/ProjectBobaMac`

## What it is

This is a native SwiftUI Mac preview app.

It exists so you can prove the product feel on your Mac:
- cozy home screen
- avatar
- tasks
- points
- gentle streaks
- shop
- customization

It does not replace the Android app.

It is the Mac-side proving ground.

## Best way to open it

1. Install full Xcode from the Mac App Store.
2. Open Xcode once.
3. If Xcode asks to install extra components, let it.
4. In Terminal, run:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

That tells your Mac to use full Xcode instead of only the command-line tools.

## How to run the Mac preview

Option A: use Xcode

1. Open Xcode.
2. Choose `Open a project or file`.
3. Open this folder:
   `/Users/quentinligginsjr/Documents/Quentin Liggins Jr/Project Boba/macos-preview/ProjectBobaMac`
4. Wait for Xcode to load the Swift package.
5. Press the `Run` button.

Option B: use Terminal after Xcode is installed

```bash
cd "/Users/quentinligginsjr/Documents/Quentin Liggins Jr/Project Boba/macos-preview/ProjectBobaMac"
swift run
```

## What to test first

1. Tap the avatar on Home.
2. Complete a few quick tasks.
3. Watch points increase.
4. Reach `3/3` for today.
5. Open Shop and buy an item.
6. Equip it.
7. Go back to Home.

## Where the Mac app saves data

It stores local state in your Mac user Application Support folder.

That means your progress should stay on your Mac between launches.

## Important note

This host could not fully build the Mac preview because the installed command-line Swift toolchain and SDK do not match each other. On a normal Mac with full Xcode selected, this is the right way to run it.
