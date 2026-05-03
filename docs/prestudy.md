# Movement System Prestudy

Project: Bruise Linus  
Date: 2026-05-03

This document covers the current codebase state, gaps relative to the movement design, and a phased implementation roadmap.

---

## 1. Codebase Analysis

### 1.1 Scene Hierarchy

```
Player (CharacterBody2D)
├── CollisionShape2D        circle shape, good for isometric
├── Sprite2D                main player sprite
│   ├── AttackEffectSprite  attack hit effect sprite
│   │   └── AnimationPlayer attack effect animations
│   └── ShadowSprite        shadow sprite (already exists, usable for jump)
├── AnimationPlayer         player animations (idle/walk/attack per direction)
├── StateMachine (Node)
│   ├── Idle  (State_Idle)
│   ├── Walk  (State_Walk)
│   └── Attack (State_Attack)
├── Camera2D                follows player directly
└── Audio (Node2D)
    └── AudioStreamPlayer2D attack sound
```

### 1.2 Scripts Overview

**player.gd**
- Reads directional input each frame via `Input.get_axis`.
- Stores `direction` (normalized Vector2) and `cardinal_direction`.
- Calls `move_and_slide()` in `_physics_process`.
- `SetDirection()` snaps to 4 cardinals; returns `true` when direction changes.
- `UpdateAnimation(state)` calls `animation_player.play(state + "_" + AnimDirection())`.
- `AnimDirection()` returns `"down"`, `"up"`, or `"side"`. Left is handled by `sprite.scale.x = -1`.

**player_state_machine.gd**
- Collects all `State` children on `Initialize`.
- Delegates `Process`, `Physics`, `HandleInput` to the current state each frame.
- `ChangeState` calls `Exit` on the outgoing state and `Enter` on the incoming.
- Stores `prev_state` but nothing uses it yet.
- Process mode disabled until `Initialize` completes.

**state.gd** (base class)
- `static var player : Player` shared across all states.
- Five overridable hooks: `Enter`, `Exit`, `Process`, `Physics`, `HandleInput`.
- All return `null` by default (stay in current state).

**state_idle.gd**
- On `Enter`: plays `idle_<direction>` animation.
- `Process`: returns `walk` if direction is non-zero; zeroes velocity otherwise.
- `HandleInput`: returns `attack` on attack press.

**state_walk.gd**
- `@export var move_speed : float = 100.0`
- `Process`: sets velocity, updates direction and animation, returns `idle` if no input.
- `HandleInput`: returns `attack` on attack press.

**state_attack.gd**
- `@export var attack_sound : AudioStream`
- `@export_range(1, 20, 0.5) var decelerate_speed : float = 5.0`
- `Enter`: plays animations, connects `animation_finished` signal, plays audio.
- `Process`: decelerates velocity; exits to idle or walk when attack finishes.
- `HandleInput`: returns `null` — no input is accepted mid-attack.

### 1.3 Animation Convention

Animation names follow the pattern `{state}_{direction}`:

- Directions: `down`, `up`, `side`
- Left-facing: mirror of `side` via `sprite.scale.x = -1`
- Known animation names in scene: `attack_down`, `attack_up`, `attack_side`

New animations for dash and jump must follow the same pattern.

### 1.4 Existing Input Actions

Defined in `project.godot`:

| Action | Key |
|--------|-----|
| up | W / Arrow Up |
| down | S / Arrow Down |
| left | A / Arrow Left |
| right | D / Arrow Right |
| attack | Z |

`dash` and `jump` are not defined yet.

---

## 2. What is Working

- State machine transitions correctly between idle, walk, and attack.
- Input reading is centralized in `player.gd`.
- Collision movement via `CharacterBody2D` and `move_and_slide` works.
- Attack deceleration uses a clean pattern reusable for dash wind-down.
- `ShadowSprite` node already exists and is available for jump fake-Z readability.
- `animation_finished` signal connection pattern established in attack state.
- Audio pipeline exists and is connected.

---

## 3. Gaps vs. Movement Design

| Gap | Detail |
|-----|--------|
| No `dash` input action | Must be added in Godot editor |
| No `jump` input action | Must be added in Godot editor |
| No `State_Dash` | New state file and scene node needed |
| No `State_Jump` | New state file and scene node needed |
| No forbidden transition enforcement | Attack blocks input but has no reusable lock mechanism |
| No signal/event system | Player emits no signals; hooks are not connected |
| `move_speed` is 100.0 | Design target is 180–220 px/s; needs tuning |
| `SetDirection` resolves only 4 cardinals | Diagonal directions collapse to last resolved axis |
| No `z_height` variable | Needed for jump sprite offset |
| No cooldown pattern | No timer or countdown pattern exists yet |
| No locked state | Hitstun and external locks have no dedicated state |

---

## 4. Technical Notes

### Dash cooldown options

Option A: `Timer` node child of `State_Dash`, check `is_stopped()` before allowing re-entry.  
Option B: `var _cooldown_remaining : float` decremented in `Process`.

Option B requires no extra scene node and matches the project's current pattern.

### Jump fake-Z approach

```
# in State_Jump.Process(delta)
_t += delta / jump_duration          # 0.0 → 1.0
var z = jump_height * 4.0 * _t * (1.0 - _t)    # parabola
player.sprite.position.y = -z
player.shadow.scale = Vector2(1.0 - z / jump_height * 0.4, ...)
```

`ShadowSprite` is a child of `Sprite2D`, so it needs a reference on Player or passed from the state.

### Signals

No signal infrastructure exists. Signals should be declared on `Player` and emitted in state `Enter`/`Exit` methods:

```gdscript
# player.gd
signal move_started
signal move_stopped
signal dash_started
signal dash_ended
signal jump_started
signal jump_landed
signal state_changed(new_state: String)
```

### Transition additions

Each new state must be wired as `@onready` in the states that can transition into it:

- `State_Idle`: add `@onready var dash`, `@onready var jump`
- `State_Walk`: add `@onready var dash`, `@onready var jump`
- `State_Attack`: no transitions to dash or jump until cancel windows are designed

---

## 5. Implementation Roadmap

### Phase 0 — Prepare (no code)

1. Add `dash` input action in Godot editor (suggested key: Shift).
2. Add `jump` input action in Godot editor (suggested key: Space).
3. Note all current animation names that exist in `AnimationPlayer`.

### Phase 1 — Baseline tuning

1. Adjust `move_speed` in `State_Walk` to 180–220 range.
2. Verify movement feels responsive at new speed.
3. No new states yet.

### Phase 2 — Dash slice

Files to create or change:

- `Player/Scripts/state_dash.gd` (new)
- `Player/player.tscn` → add `Dash` node under `StateMachine`
- `Player/Scripts/state_idle.gd` → add dash and transition reference
- `Player/Scripts/state_walk.gd` → add dash and transition reference

Behavior:
- Lock direction at dash start.
- Apply `dash_speed` for `dash_duration` seconds.
- Block input during dash.
- Return to `idle` or `walk` on completion.
- Enforce cooldown before re-entry.

Exports needed on `State_Dash`:

```gdscript
@export var dash_speed : float = 400.0
@export var dash_duration : float = 0.20
@export var dash_cooldown : float = 0.75
```

### Phase 3 — Jump slice

Files to create or change:

- `Player/Scripts/state_jump.gd` (new)
- `Player/player.tscn` → add `Jump` node under `StateMachine`
- `Player/Scripts/player.gd` → add `z_height : float`, shadow reference
- `Player/Scripts/state_idle.gd` → add jump transition
- `Player/Scripts/state_walk.gd` → add jump transition

Behavior:
- Track `_t` (0→1) over `jump_duration`.
- Offset `Sprite2D.position.y` by parabola value.
- Scale `ShadowSprite` to show distance from ground.
- On land: reset offsets, transition to idle or walk.

Exports needed on `State_Jump`:

```gdscript
@export var jump_duration : float = 0.40
@export var jump_height : float = 16.0
```

### Phase 4 — Signal hooks

Files to change:

- `Player/Scripts/player.gd` → declare signals
- `Player/Scripts/state_idle.gd`, `state_walk.gd`, `state_dash.gd`, `state_jump.gd` → emit signals in Enter/Exit

### Phase 5 — Tuning pass

No code changes. Adjust exported values in the Godot inspector only:

- `move_speed`
- `dash_speed`, `dash_duration`, `dash_cooldown`
- `jump_duration`, `jump_height`

---

## 6. Out of Scope

- Dash class variants (reserved for post-MVP).
- Full hitstun / locked state (not blocking MVP).
- Signal consumers (animation, VFX, SFX) beyond what already exists.
- Camera system or target lock.
