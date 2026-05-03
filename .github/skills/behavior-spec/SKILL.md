---
name: behavior-spec
description: "Define expected behavior, forbidden behavior, and concrete validation scenarios before implementation begins."
argument-hint: "Describe the requested feature or bugfix, the player-facing behavior, and what must not regress"
user-invocable: true
---

# Behavior Spec Skill

Use this workflow before writing code so implementation starts from explicit expected behavior.

## When to Use

- Before implementing a new gameplay or movement slice
- Before fixing a bug with unclear reproduction steps
- Before refactoring code that affects controls, state transitions, or visuals

## Goals

- Define what should happen in player-facing terms
- Define what must not happen
- Define how the change will be checked before and after coding
- Keep the implementation target narrow and falsifiable

## Procedure

1. State the smallest player-visible behavior change.
2. List allowed behavior after the change.
3. List forbidden behavior or regressions.
4. List concrete validation scenarios:
- input sequence
- expected state or animation
- expected non-result when relevant
5. Identify the owning files or states.
6. Hand off to `code-quality-guard` for pre-coding implementation planning.

## Guardrails

- Do not describe implementation first.
- Keep scenarios concrete and short.
- Prefer 3-6 validation scenarios over broad prose.

## Output Template

When this skill is used, return:

1. Behavior goal
2. Allowed behavior
3. Forbidden behavior
4. Validation scenarios
5. Likely code owners