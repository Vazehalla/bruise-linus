# Git Cheat Sheet

## Daily Workflow

1. Check where you are:
```bash
git status
git branch
```

2. Get latest changes from remote:
```bash
git fetch
git pull
```

3. Create or switch to your working branch:
```bash
git switch -c feature/my-change
# if the branch already exists:
git switch feature/my-change
```

4. Stage files you changed:
```bash
git add .
# or:
git add path/to/file
```

5. Commit with a short message:
```bash
git commit -m "describe your change"
```

6. Push your branch:
```bash
git push -u origin feature/my-change
```

## Core Commands

```bash
git status          # show changed files and staging state
git branch          # list local branches
git branch <name>   # create a new branch
git switch -c <name> # create and switch to a new branch
git switch <name>   # switch branch
git add <file>      # stage one file
git add .           # stage all changes
git commit -m "..." # create commit from staged changes
git fetch           # download remote updates (no merge)
git pull            # fetch + merge/rebase into current branch
git push            # upload commits to remote
git log --oneline   # compact commit history
```

## Quick Rule

`fetch/pull -> edit -> add -> commit -> push`
