# Android Studio Walkthrough

This is the simple version.

## What you need

1. Install Android Studio.
2. Open Android Studio once and let it finish setup.
3. Make sure it installs:
   - Android SDK
   - Android emulator
   - a JDK it manages itself

## How to open Project Boba

1. Open Android Studio.
2. Click `Open`.
3. Pick this folder:
   `/Users/quentinligginsjr/Documents/Quentin Liggins Jr/Project Boba`
4. Wait.

Android Studio will start "syncing Gradle".

That just means:
"Please download and organize the Android building pieces."

If it asks to trust the project, say yes.

## How to make a fake Android phone

1. In Android Studio, find the `Device Manager`.
2. Click `Create Device`.
3. Pick a Pixel phone.
   - `Pixel 8` is fine.
4. Pick a system image.
   - Choose a recent stable image.
   - If it says `Download`, click it.
5. Finish setup.

Now you have a pretend phone living inside your Mac.

## How to run the Android app

1. Start the emulator from `Device Manager`.
2. At the top of Android Studio, look for the device dropdown.
3. Pick your emulator.
4. Make sure the run target says `app`.
5. Press the green `Run` triangle.

Android Studio will:
- build the app
- install it into the emulator
- open it

## If you want to test on your real Pixel

1. On the phone, enable `Developer options`.
2. Turn on `USB debugging`.
3. Plug the phone into your Mac.
4. Approve the computer on the phone if asked.
5. Pick the phone in Android Studio instead of the emulator.
6. Press `Run`.

## What to click in the app

Start with this:

1. Open `Home`.
2. Tap the avatar.
   - You should get a catchphrase.
3. Open quick tasks or the `Tasks` tab.
4. Complete a few tasks.
   - Points should go up.
   - The streak progress should move toward `3/3`.
5. Open `Shop`.
6. Buy a cosmetic or background once you have enough points.
7. Equip it.
8. Go back to `Home` or `Avatar`.
   - You should see the change.

## If something breaks

Common fixes:

1. Click `Sync Project with Gradle Files`.
2. Try `Build > Clean Project`.
3. Try `Build > Rebuild Project`.
4. Close and reopen Android Studio.

## Important note

This project was scaffolded outside a normal Android Studio environment, so the cleanest way to build and test it is inside Android Studio itself.
