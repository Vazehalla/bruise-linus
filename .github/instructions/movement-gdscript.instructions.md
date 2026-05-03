---
description: "Use when editing player movement, state machine, dash, jump, or Player/Scripts GDScript files. Enforces state-driven movement conventions and iterative implementation workflow for this repo."
applyTo: "Player/Scripts/**/*.gd"
---
# Movement GDScript Instructions

## Apply Existing Patterns First

- Keep movement logic in states that extend `State`.
- Keep `Player` as shared data holder and animation helper.
- Route transitions through `PlayerStateMachine.ChangeState` semantics (return state or `null`).

## State Design Rules

- One state should represent one gameplay intent.
- Keep `Enter`, `Exit`, `Process`, `Physics`, `HandleInput` explicit even when simple.
- Avoid hidden side effects in `_process` of unrelated nodes.
- Only add transition paths that are intentional and testable.

## Tuning and Feel

- Expose movement values with exports instead of hardcoded magic numbers.
- Preserve normalized directional movement for diagonals.
- Keep movement responsive: avoid unnecessary acceleration/inertia unless requested.

## Dash and Jump Introduction Rules

- Introduce dash and jump as isolated slices:
  1. add state and transitions
  2. add tuning values
  3. add animation and feedback hooks
- Do not merge multiple movement mechanics in one large change unless requested.

## Integration Contracts

- If a state changes motion behavior, verify animation calls still use `UpdateAnimation` and `AnimDirection` patterns.
- Keep collision movement on `CharacterBody2D` flow with `move_and_slide`.
- Preserve compatibility with existing attack state behavior unless task asks for cancel-window changes.

## Input Action Rules

- Reuse existing directional actions (`up`, `down`, `left`, `right`) for movement vectors.
- Introduce new movement actions with lowercase names (`dash`, `jump`).
- Keep input reads centralized in player/state flow; avoid scattering raw input polling across many nodes.

## Documentation Update Rules

- Any movement-related docs updated in the same task must be written in concise English.
- Use practical and factual wording only; avoid promotional or overly formal style.
