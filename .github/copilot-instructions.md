# Bruise Linus - Project Instructions

## Project Scope

- This project uses Godot 4.x and GDScript.
- Keep changes small and compatible with the current state machine architecture in Player/Scripts.
- Prefer iterative slices over large rewrites.

## Current Architecture

- Player movement and combat flow are state-driven.
- `Player` owns runtime data like `velocity`, `direction`, and animation helpers.
- `PlayerStateMachine` handles transitions and delegates to each `State` child.
- States return either the next state or `null`.

## Coding Conventions

- Use typed GDScript when practical (`: float`, `: Vector2`, typed arrays).
- Follow existing naming style to avoid churn:
  - classes: `State_Walk`, `State_Attack`
  - methods: `Initialize`, `ChangeState`, `SetDirection`, `UpdateAnimation`
- Keep method responsibilities narrow; avoid adding mixed concerns in one state.
- Avoid broad refactors unless explicitly requested.

## Movement Development Rules

- Movement features must integrate through the existing state machine, not bypass it.
- Add one movement behavior at a time (for example: dash before jump).
- Prefer exported tuning values (`@export`, `@export_range`) over hardcoded constants.
- Preserve immediate responsiveness in input and state transitions.
- Keep fake Z and movement readability explicit when jump logic is introduced.
- Preserve current input action naming conventions and add new movement actions consistently.

## Input Action Contract

- Existing actions are `up`, `down`, `left`, `right`, and `attack`.
- New movement actions should be added as `dash` and `jump` (lowercase snake_case style).
- Prefer updating input actions through the Godot editor to avoid malformed project config.

## Safe Change Process

1. Read impacted scripts in `Player/Scripts` first.
2. Run a behavior spec pass before writing code:
  - state the smallest intended behavior change
  - list what must happen and what must not happen
  - list the validation scenarios that will prove the change
3. Run a pre-coding quality gate before writing code:
  - list the smallest viable change
  - list complexity risks and how to avoid them
  - confirm state responsibilities stay narrow
4. Add or modify the smallest possible state logic.
5. Re-check transitions and forbidden transitions.
6. Surface assumptions when engine/editor validation cannot be run here.

## Behavior Spec Gate

- Treat `behavior-spec` as the first skill for gameplay and movement code tasks.
- Use it to define expected behavior and regression boundaries before implementation.
- Hand off from `behavior-spec` to `code-quality-guard` before writing code.

## Code Quality Gate

- Treat `code-quality-guard` as a default skill for code tasks.
- Use it after `behavior-spec` and again before commit/review.
- Avoid introducing helpers unless they reduce real duplication or branching.
- Prefer local, explicit code over clever abstractions.

## Documentation Rule

- When changing behavior, update movement docs in `docs/` in the same task.

## Documentation Standards

- All repository documentation must be written in English.
- Keep documents concise and easy to scan.
- Use factual, direct language; avoid marketing tone, hype, or sales phrasing.
- Write for a small two-developer hobby project: practical over formal.

## Commit Message Rules

- One line only.
- Lowercase throughout.
- Describe what changed, not why.
- No period at the end.
- Examples: `add dash state with cooldown`, `increase walk speed to 180`, `fix idle transition on zero input`
