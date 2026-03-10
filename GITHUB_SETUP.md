# GitHub Setup

This is the simple version.

## Big picture

You currently have:

- the Android app in the main project folder
- the Mac preview app in `macos-preview/ProjectBobaMac`

If you want two GitHub repos, the clean setup is:

1. one repo for Android
2. one repo for Mac preview

## Easiest way

Use GitHub Desktop if you want the least painful setup.

You can still use the Terminal if you want, but GitHub Desktop is friendlier.

## First: create the repos on GitHub

Go to [https://github.com/new](https://github.com/new) twice.

Create:

1. `project-boba-android`
2. `project-boba-macos`

Do not add:
- README
- .gitignore
- license

Leave them empty.

## Android repo setup

Your Android repo root should be:

`/Users/quentinligginsjr/Documents/Quentin Liggins Jr/Project Boba`

Terminal version:

```bash
cd "/Users/quentinligginsjr/Documents/Quentin Liggins Jr/Project Boba"
git init
git add .
git commit -m "Initial Android and project scaffold"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/project-boba-android.git
git push -u origin main
```

If you want the Android repo to exclude the Mac preview folder, add this line to `.gitignore` first:

```gitignore
macos-preview/
```

## Mac repo setup

If you want a separate Mac repo, copy or move this folder into its own folder first:

`/Users/quentinligginsjr/Documents/Quentin Liggins Jr/Project Boba/macos-preview/ProjectBobaMac`

Example destination:

`/Users/quentinligginsjr/Documents/Quentin Liggins Jr/Project Boba Mac`

Then:

```bash
cd "/Users/quentinligginsjr/Documents/Quentin Liggins Jr/Project Boba Mac"
git init
git add .
git commit -m "Initial macOS preview app"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/project-boba-macos.git
git push -u origin main
```

## Easier repo strategy

If you do not want repo juggling yet, use one GitHub repo first.

That is simpler.

You can keep:

- Android app
- Mac preview app
- docs

all in one repo for now.

Then split later if it starts getting messy.

## Recommended answer

Right now, I recommend:

1. keep one repo first
2. get Android Studio working
3. get the Mac preview opening in Xcode
4. only split into two repos after both apps are launching

That is lower-risk.

## If you want me to help next

I can help you with either:

1. turning this into one clean Git repo now
2. preparing it to split into two repos cleanly
3. adding a better `.gitignore` and README structure
