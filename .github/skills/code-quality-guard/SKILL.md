---
name: code-quality-guard
description: "Run a pre-coding and pre-commit quality gate that keeps complexity low, responsibilities clear, and behavior explicit."
argument-hint: "Describe intended behavior change, files likely affected, and if this is pre-coding, post-coding, or both"
user-invocable: true
---

# Code Quality Guard Skill

Use this workflow after `behavior-spec` and before finalizing changes.

## When to Use

- Before writing code for any gameplay or movement task
- After implementing a slice and before commit/review
- When code starts to duplicate logic or grow hard to reason about
- During bugfixes that touch multiple states or transitions

## Required Order

1. Run `behavior-spec` first.
2. Run `code-quality-guard` second.
3. Implement the smallest viable slice.
4. Run validation and a final quality pass.

## Goals

- Preserve behavior unless change is explicitly requested
- Remove avoidable complexity and repeated logic
- Keep state methods focused on one responsibility
- Keep naming and data flow obvious at a glance
- Decide boundaries early so complexity is not introduced in the first place

## Procedure

1. Pre-coding preflight:
- define the smallest behavior change
- list 2-3 complexity risks
- choose ownership of logic (which state/file owns what)
2. Read only the files relevant to the task.
3. Mark complexity hotspots:
- nested branching
- duplicated expressions
- mixed concerns inside one method
4. Implement with small, behavior-preserving edits:
- extract tiny helper methods
- replace magic values with exported tunables or constants when needed
- remove dead comments, no-op code, and misleading names
5. Re-check state transitions and forbidden transitions.
6. Run script validation (`gdparse`) on changed `.gd` files.
7. Post-coding quality pass:
- confirm no unnecessary abstraction was introduced
- confirm complexity is lower or unchanged vs baseline
8. Summarize what was planned to avoid complexity and what was cleaned.

## Guardrails

- No architecture rewrites unless explicitly requested
- No hidden behavior changes in a quality-only pass
- Keep refactors local to affected files
- Prefer 1-2 small helpers over deep utility abstractions
- If complexity reduction conflicts with delivery, prefer simpler delivery and note follow-up cleanup

## Output Template

When this skill is used, return:

1. Preflight decisions
2. Scope reviewed
3. Complexity reductions made
4. Behavior changes: none or explicit list
5. Validation result
6. Optional next cleanup slice
