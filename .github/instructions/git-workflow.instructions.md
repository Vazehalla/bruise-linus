---
description: "Use when writing commit messages, planning commits, or reviewing git history. Enforces concise lowercase commit message style for this repository."
---
# Git Workflow Rules

## Commit Messages

- One line only, lowercase, no period at end.
- Describe the concrete change, not the intent or phase name.
- Keep under 72 characters.

Good:
```
add dash state with cooldown
increase walk speed to 180
fix idle velocity reset on direction change
add jump and dash input actions to project
```

Bad:
```
Phase 2 - Dash implementation
WIP
Added the dash feature as per roadmap
Implement movement system improvements
```

## Commit Scope

- Each commit should be one logical change.
- Do not bundle unrelated changes.
- If a change requires scene and script edits together, commit them together.
