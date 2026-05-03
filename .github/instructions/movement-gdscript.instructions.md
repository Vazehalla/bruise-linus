---
description: "Use when editing player movement, state machine, dash, jump, or Player/Scripts GDScript files. Enforces state-driven movement conventions and iterative implementation workflow for this repo."
applyTo: "Player/Scripts/**/*.gd"
---
# Movement GDScript Instructions

## Apply Existing Patterns First

- Keep movement logic in states that extend `State`.
- Keep `Player` as shared data holder and animation helper.
- Route transitions through `PlayerStateMachine.ChangeState` semantics (return state or `null`).

## Behavior Spec Gate (Required)

- Before editing movement code, define:
  1. the smallest intended behavior change
  2. the allowed behavior after the change
  3. forbidden behavior or regressions
  4. concrete validation scenarios
- Use the `behavior-spec` skill first on movement tasks.

## Pre-Coding Quality Gate (Required)

- Before editing code, run a short preflight:
  1. define the smallest intended behavior change
  2. list likely complexity risks (branching, duplication, mixed concerns)
  3. decide where logic should live so each state keeps one intent
- Use the `code-quality-guard` skill after `behavior-spec` for this preflight on movement tasks.
- If a requested change needs wider refactor, split into iterative slices instead of one broad patch.

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
