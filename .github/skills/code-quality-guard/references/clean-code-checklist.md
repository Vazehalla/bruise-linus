# Clean Code Checklist

Use this checklist during cleanup passes.

## Pre-Coding

- Smallest behavior change is stated before edits.
- Logic ownership is decided (which state/file owns the change).
- Top complexity risks are listed before implementation.

## Readability

- Names explain intent without extra comments.
- Each method has one clear responsibility.
- Control flow avoids unnecessary nesting.

## Complexity

- Duplicate logic extracted once when practical.
- Conditionals are short and explicit.
- Magic numbers are either obvious or promoted to tunables.

## State Safety

- Enter/Exit reset temporary visual state.
- Process/Physics/HandleInput responsibilities are not mixed.
- Transition targets are explicit and local.

## Behavior Preservation

- Cleanup pass does not silently change behavior.
- Any intentional behavior change is called out clearly.

## Validation

- Run `gdparse` on changed `.gd` files.
- Mention any unverified assumptions when engine runtime was not tested.
