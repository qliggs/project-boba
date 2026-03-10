# GitHub Push Guide

This guide assumes you want one clean GitHub repo for all of Project Boba.

That means:

- Android app
- Mac preview app
- docs

all live together in one repo.

## Step 1: Create the GitHub repo

1. Go to [https://github.com/new](https://github.com/new)
2. Pick a repo name.
   - Example: `project-boba`
3. Keep it empty.

That means:

- do not add a README there
- do not add a .gitignore there
- do not add a license there

### What you should expect to see

After creating it, GitHub will show you a page with commands.

## Step 2: Open Terminal

Open Terminal on your Mac.

Go into your Project Boba repo folder:

```bash
cd "/Users/quentinligginsjr/Documents/Quentin Liggins Jr/Project Boba"
```

### What this command means

`cd` means:
"go into this folder"

## Step 3: If git is not initialized yet

Only do this if needed:

```bash
git init
```

### What this command means

It turns the folder into a Git repo.

If Git is already set up, this step is not important.

## Step 4: Add all files

```bash
git add .
```

### What this command means

It tells Git:
"please include all the project files in the next save point"

## Step 5: Make your first commit

```bash
git commit -m "Initial Project Boba repo structure"
```

### What this command means

This makes a saved snapshot of the project.

The message after `-m` is the note attached to that snapshot.

## Step 6: Make sure the branch is called main

```bash
git branch -M main
```

### What this command means

It renames the main branch to `main`.

## Step 7A: Connect GitHub using HTTPS

Replace `YOUR_USERNAME` with your real GitHub username.

```bash
git remote add origin https://github.com/YOUR_USERNAME/project-boba.git
```

### What this command means

It tells your computer:
"this GitHub repo is the online home for this project"

## Step 7B: Connect GitHub using SSH

Use this only if you already set up SSH keys with GitHub.

```bash
git remote add origin git@github.com:YOUR_USERNAME/project-boba.git
```

### What this command means

Same idea as HTTPS, just using SSH instead.

## Step 8: Push to GitHub

```bash
git push -u origin main
```

### What this command means

It uploads your local repo to GitHub.

`-u` means:
"remember this connection for later pushes"

## Step 9: Future saves

After the first push, this is the normal pattern:

```bash
git add .
git commit -m "Describe what changed"
git push
```

### What that means

1. `git add .`
   - gather changes
2. `git commit -m "..."`
   - save a snapshot
3. `git push`
   - send it to GitHub

## If Git says origin already exists

Use this instead:

```bash
git remote set-url origin https://github.com/YOUR_USERNAME/project-boba.git
```

Or for SSH:

```bash
git remote set-url origin git@github.com:YOUR_USERNAME/project-boba.git
```

## If you want to check what Git sees

```bash
git status
```

### What this command means

It shows:

- changed files
- staged files
- files ready to commit

## Very simple summary

The four most important commands are:

```bash
git add .
git commit -m "Your message here"
git remote add origin https://github.com/YOUR_USERNAME/project-boba.git
git push -u origin main
```
