---
name: movement-iteration
description: "Design and implement movement-system slices in this Godot project. Use when working on Player/Scripts movement states, dash, jump, transitions, tuning variables, or movement feel iteration."
argument-hint: "Describe the movement slice to build, expected feel, and whether to update docs"
user-invocable: true
---

# Movement Iteration Skill

Use this workflow to make movement progress quickly without destabilizing the state machine.

## When to Use

- Adding a new movement slice (for example dash, jump, movement lock)
- Refining game feel (speed, duration, cooldown, responsiveness)
- Tightening state transitions and forbidden transitions
- Syncing movement docs with current behavior

## Repository Context

- Movement architecture is state-driven in `Player/Scripts`.
- `Player` exposes direction, velocity, and animation helpers.
- `PlayerStateMachine` delegates to state methods and applies transitions.
- Load [codebase-state.md](./references/codebase-state.md) for exact node paths, animation naming, existing exports, and copy-paste implementation patterns for dash and jump.

## Procedure

1. Define one slice only.
2. Confirm expected transitions into and out of the slice.
3. Implement minimal code change in relevant state files.
4. Expose tuning values via exported variables.
5. Keep animation and movement updates consistent with current helpers.
6. Update docs in `docs/` with the implemented behavior and open TODOs.
7. Report what is implemented vs intentionally deferred.

## Quality Gates

- No broad architecture rewrite unless explicitly requested.
- No hidden transition paths.
- Movement remains responsive under frequent direction changes.
- State logic stays readable and local to its purpose.

## Output Template

When this skill is used, return:

1. Slice goal
2. Files changed
3. Transition changes
4. Tunables added or modified
5. Risks and next micro-iteration
