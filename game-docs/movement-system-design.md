# Movement System Design v3

Project: Bruise Linus  
Engine: Godot 4.x  
Perspective: Isometric 2.5D pixel action

## 1. Goal

Define a practical movement core that feels responsive, readable, and reliable.
This document describes what the system must do now, what is deferred, and how systems connect.

## 2. Design Principles

1. Immediate response to input.
2. Clear player intent in all movement states.
3. Movement supports combat positioning.
4. Simple navigation, no platforming precision.
5. Expandable architecture for later class modifiers.

## 3. In Scope (MVP)

1. 8-direction movement with normalized diagonal speed.
2. Dash as short evasive reposition.
3. Combat jump with fake Z (not traversal jump).
4. State machine control for movement transitions.
5. Collision-safe movement in tight spaces.
6. Tuning variables exposed in editor.
7. Event hooks for animation, VFX, and SFX.

## 4. Out of Scope (Now)

1. Class-specific dash variants.
2. Full combat cancel system.
3. Traversal abilities (blink, grapples, leap tools).
4. Advanced camera AI or target lock logic.

## 5. Movement Capabilities

The system must:

1. Move with stable velocity and no unintended drift.
2. Resolve direction changes quickly and consistently.
3. Dash in all directions with cooldown control.
4. Run jump arc timing with visible landing readability.
5. Block forbidden transitions (for example from locked states).

## 6. Core Modules

## 6.1 Input Layer

- Reads directional input and action intents (`dash`, `jump`).
- Outputs normalized movement intent each frame.

## 6.2 Locomotion Core

- Handles idle and move velocity.
- Applies collision movement through CharacterBody2D flow.

## 6.3 Dash Module

- Handles start, duration, direction lock, and cooldown.
- Optional brief invulnerability window if enabled.

## 6.4 Jump Module (Fake Z)

- Handles jump timing, arc value, and landing.
- Uses visual separation (sprite offset and shadow readability).

## 6.5 Movement State Machine

Required states:

- idle (implemented)
- move (implemented)
- dash (implemented)
- jump (implemented)
- locked (planned: used for ability use, hit-stun, and cutscene lock)

State machine responsibilities:

- allow valid transitions
- reject invalid transitions
- enforce input priority when intents overlap

## 6.6 Feedback Hooks

- Emit movement events.
- Let animation/VFX/SFX systems react without hard coupling.

## 7. Integration Contract

Movement should emit:

1. move_started
2. move_stopped
3. dash_started
4. dash_ended
5. jump_started
6. jump_landed
7. state_changed

Consumers:

- animation controller
- VFX manager
- SFX manager
- combat resolver

## 8. Tuning Variables

Minimum tunables:

- walk_speed
- dash_speed
- dash_duration
- dash_cooldown
- jump_duration
- jump_height

All values should be editable in the Godot inspector.

## 9. Acceptance Criteria

Movement is acceptable when:

1. Idle, move, dash, and jump switch without input lag feel.
2. Dash behavior is consistent in all directions.
3. Jump landing point is readable during the full jump.
4. Player does not frequently stick in corners.
5. Feel can be tuned without code changes.
6. Feedback systems react through movement hooks.

## 10. Iteration Plan

1. Finalize state rules and tunables. (done)
2. Implement movement baseline (idle and move). (done)
3. Add dash slice and test. (done)
4. Add jump slice and test. (done)
5. Connect feedback hooks. (done)
6. Run short tuning passes with small value changes only. (done)
7. Add locked state for ability use and hit-stun. (next)
