# Setup Guide For Beginners

This guide is written like you have never done this before.

That is okay.

You do not need to know the scary words yet.

## Part 1: Install Xcode for the Mac preview app

### What Xcode is

Xcode is the main Apple app used to open and run Mac and iPhone apps.

Think of it like:
"the app-building app for Apple stuff."

### How to install it

1. Open the `App Store` on your Mac.
2. Search for `Xcode`.
3. Click `Get` or `Install`.
4. Wait.

It is a big download.

### What you should expect to see

- A progress bar in the App Store.
- After it installs, you should see `Xcode` in your Applications folder.

### Common mistake

Problem:
You only have "Command Line Tools" and not full Xcode.

Fix:
Install full Xcode from the App Store.

## Part 2: Open and run the Mac preview app

### Where it is

The Mac preview app lives here:

`apps/macos-preview`

### How to open it

1. Open `Xcode`.
2. Click `Open a project or file`.
3. Open this folder:
   `/Users/quentinligginsjr/Documents/Quentin Liggins Jr/Project Boba/apps/macos-preview`

Xcode can open Swift packages directly, so this is okay.

### What you should expect to see

- Xcode opens a project-like window.
- You should see Swift files on the left.
- You should see a Run button near the top.

### How to run it

1. Press the Run button.
2. Wait for Xcode to build.
3. A Mac app window should open.

### What you should expect inside the app

You should see:

- a cozy home screen
- an avatar in the middle
- tasks
- points
- shop
- avatar customization

### Common mistakes

Problem:
Xcode says it needs extra components.

Fix:
Let it install them.

Problem:
The app does not run and Xcode shows lots of red text.

Fix:
Close Xcode, reopen it, and try again.

Problem:
You opened the wrong folder.

Fix:
Make sure you opened:
`apps/macos-preview`

## Part 3: Install Android Studio

### What Android Studio is

Android Studio is the main app used to build Android apps.

Think of it like:
"Xcode, but for Android."

### How to install it

1. Go to the Android Studio download page.
2. Download Android Studio for Mac.
3. Install it.
4. Open it once and let it finish first-time setup.

### What you should expect to see

- A setup wizard.
- Downloads for Android SDK pieces.
- A welcome screen when it is done.

### JDK note

If Android Studio asks which JDK to use, use the JDK that Android Studio manages itself.

That is the safest beginner choice.

### Common mistake

Problem:
You skip the first-time setup.

Fix:
Open Android Studio again and let it finish.

## Part 4: Open and run the Android app

### Where it is

The Android app lives here:

`apps/android-app`

### How to open it

1. Open Android Studio.
2. Click `Open`.
3. Open this folder:
   `/Users/quentinligginsjr/Documents/Quentin Liggins Jr/Project Boba/apps/android-app`

### What you should expect to see

- Android Studio opens the project.
- It may say `Gradle Sync` is running.
- It may download some Android pieces.

This is normal.

### Common mistake

Problem:
You open the repo root instead of the Android app folder.

Fix:
Open:
`apps/android-app`

Not the whole repo root.

## Part 5: Test on the Android emulator

### What the emulator is

The emulator is a fake Android phone inside your Mac.

### How to create it

1. In Android Studio, open `Device Manager`.
2. Click `Create Device`.
3. Pick a Pixel phone.
   - `Pixel 8` is fine.
4. Pick a recent stable Android image.
5. Download it if asked.
6. Finish.

### What you should expect to see

- A virtual phone listed in Device Manager.
- You can press play on it.

### How to run the app on it

1. Start the emulator.
2. At the top of Android Studio, choose that emulator.
3. Make sure the run target says `app`.
4. Press the green Run triangle.

### What you should expect to see

- The Android app builds.
- It gets installed on the fake phone.
- The app opens.

### Common mistakes

Problem:
The emulator is not started.

Fix:
Start it first from Device Manager.

Problem:
Android Studio says it is still syncing.

Fix:
Wait until syncing is done.

Problem:
The Run button is gray.

Fix:
Make sure a device is selected.

## Part 6: Test on a real Pixel

### What you need

- your Pixel phone
- a USB cable

### How to turn on phone testing

1. Open `Settings` on the phone.
2. Go to `About phone`.
3. Tap `Build number` many times.
4. The phone should say you are now a developer.
5. Go back.
6. Open `Developer options`.
7. Turn on `USB debugging`.

### What you should expect to see

- A new settings area called `Developer options`.
- A switch for `USB debugging`.

### How to run the app on the phone

1. Plug the Pixel into your Mac.
2. Approve the computer on the phone if asked.
3. In Android Studio, choose your phone from the device list.
4. Press Run.

### What you should expect to see

- Android Studio installs the app to the phone.
- The app opens on the phone.

### Common mistakes

Problem:
The phone does not show up in Android Studio.

Fix:
- unplug and replug the cable
- unlock the phone
- approve USB debugging on the phone

Problem:
The cable charges but does not connect.

Fix:
Try a different USB cable.

## Part 7: What to test first

When the app opens, do this:

1. Tap the avatar.
2. Complete a few tasks.
3. Watch the points go up.
4. Reach 3 completed tasks for the day goal.
5. Buy something in the shop.
6. Equip it.
7. Go back to Home and Avatar.

## Part 8: If things go wrong

### Android Studio fixes

Try these in order:

1. Wait a little longer.
2. Click `Sync Project with Gradle Files`.
3. Click `Build > Clean Project`.
4. Click `Build > Rebuild Project`.
5. Close and reopen Android Studio.

### Xcode fixes

Try these in order:

1. Close and reopen Xcode.
2. Open the correct folder again.
3. Let Xcode install anything it asks for.

## The most important thing to remember

If you want the easiest first win:

1. Open the Mac preview first.
2. Then open the Android app.

That gives you a quick visible result before the Android setup work.
