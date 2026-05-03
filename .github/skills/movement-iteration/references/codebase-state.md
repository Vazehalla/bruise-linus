# Current Codebase State Reference

Use this as a quick lookup when implementing movement slices.

## Scene Hierarchy

```
Player (CharacterBody2D)
├── CollisionShape2D
├── Sprite2D
│   ├── AttackEffectSprite (Sprite2D)
│   │   └── AnimationPlayer        ← attack effect animations
│   └── ShadowSprite (Sprite2D)    ← use for jump fake-Z readability
├── AnimationPlayer                ← main player animations
├── StateMachine (Node)
│   ├── Idle   (State_Idle)
│   ├── Walk   (State_Walk)
│   └── Attack (State_Attack)
├── Camera2D
└── Audio (Node2D)
    └── AudioStreamPlayer2D
```

## Animation Convention

Pattern: `{state}_{direction}`  
Directions: `down`, `up`, `side` (left = side + `sprite.scale.x = -1`)

Known animations: `idle_down`, `idle_up`, `idle_side`, `walk_down`, `walk_up`, `walk_side`, `attack_down`, `attack_up`, `attack_side`

## State Contract

Every state extends `State` and must implement:

```gdscript
func Enter() -> void
func Exit() -> void
func Process(_delta: float) -> State   # return next state or null
func Physics(_delta: float) -> State
func HandleInput(_event: InputEvent) -> State
```

## Existing Input Actions

`up`, `down`, `left`, `right`, `attack`  
Not yet defined: `dash`, `jump` — must be added in Godot editor.

## Existing Exported Variables

| State | Variable | Type | Default |
|-------|----------|------|---------|
| State_Walk | move_speed | float | 100.0 |
| State_Attack | decelerate_speed | float | 5.0 |
| State_Attack | attack_sound | AudioStream | — |

## What Does Not Exist Yet

- `State_Dash`, `State_Jump`
- `dash` and `jump` input actions
- Signal declarations on Player
- `z_height` variable on Player
- Cooldown pattern (no Timer nodes, no float countdown)
- Forbidden transition enforcement beyond `null` return

## Node Path Patterns (for @onready)

From a state node (`StateMachine/Idle`):

```gdscript
@onready var walk: State_Walk = $"../Walk"
@onready var dash: State_Dash = $"../Dash"
@onready var jump: State_Jump = $"../Jump"
```

From a state node reaching Player nodes:

```gdscript
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var shadow: Sprite2D = $"../../Sprite2D/ShadowSprite"
@onready var audio: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"
```

## Dash Implementation Pattern

```gdscript
class_name State_Dash extends State

@export var dash_speed: float = 400.0
@export var dash_duration: float = 0.20
@export var dash_cooldown: float = 0.75

var _timer: float = 0.0
var _cooldown: float = 0.0
var _dash_direction: Vector2 = Vector2.ZERO

@onready var idle: State_Idle = $"../Idle"

func Enter() -> void:
    _dash_direction = player.direction if player.direction != Vector2.ZERO else player.cardinal_direction
    _timer = 0.0
    player.velocity = _dash_direction * dash_speed

func Process(delta: float) -> State:
    _cooldown = max(0.0, _cooldown - delta)
    _timer += delta
    if _timer >= dash_duration:
        return idle
    return null

func Exit() -> void:
    _cooldown = dash_cooldown
```

## Jump Implementation Pattern

```gdscript
class_name State_Jump extends State

@export var jump_duration: float = 0.40
@export var jump_height: float = 16.0

var _t: float = 0.0

@onready var idle: State_Idle = $"../Idle"
@onready var sprite: Sprite2D = $"../../Sprite2D"
@onready var shadow: Sprite2D = $"../../Sprite2D/ShadowSprite"

func Enter() -> void:
    _t = 0.0

func Process(delta: float) -> State:
    _t += delta / jump_duration
    if _t >= 1.0:
        _t = 1.0
        sprite.position.y = 0.0
        return idle
    var z := jump_height * 4.0 * _t * (1.0 - _t)
    sprite.position.y = -z
    return null

func Exit() -> void:
    sprite.position.y = 0.0
```
