class_name State_Dash extends State

@export var dash_speed : float = 400.0
@export var dash_duration : float = 0.20
@export var dash_cooldown : float = 0.75
@export var dash_scale_x : float = 1.6
@export var dash_scale_y : float = 0.7
@export var dash_tilt_degrees : float = 28.0
@export var effect_offset : float = 18.0
@export var effect_leg_anchor_y : float = 10.0
@export var effect_side_y_adjust : float = -8.0

var _timer : float = 0.0
var _cooldown_until : float = 0.0
var _dash_direction : Vector2 = Vector2.ZERO
var _back_direction : Vector2 = Vector2.ZERO
var _flip : float = 1.0

@onready var idle : State_Idle = $"../Idle"
@onready var walk : State_Walk = $"../Walk"
@onready var dash_effect : Sprite2D = $"../../DashEffectSprite"

func _effect_anchor_y() -> float:
	var is_side : bool = absf(_dash_direction.x) > absf(_dash_direction.y)
	return effect_leg_anchor_y + (effect_side_y_adjust if is_side else 0.0)

func Enter() -> void:
	player.dash_started.emit()
	player.state_changed.emit("dash")
	player.is_invincible = true
	var fallback := Vector2(player.cardinal_direction.x, player.cardinal_direction.y).normalized()
	_dash_direction = player.direction if player.direction != Vector2.ZERO else fallback
	_back_direction = -_dash_direction
	if _back_direction == Vector2.ZERO:
		_back_direction = Vector2.DOWN
	_timer = 0.0
	_flip = player.FacingSign()
	dash_effect.position = Vector2(0.0, _effect_anchor_y())
	dash_effect.rotation = _back_direction.angle()
	dash_effect.visible = true
	player.sprite.scale = Vector2(_flip * dash_scale_x, dash_scale_y)
	player.sprite.rotation = _dash_direction.x * deg_to_rad(dash_tilt_degrees)
	player.UpdateAnimation("walk")

func Exit() -> void:
	player.dash_ended.emit()
	player.is_invincible = false
	dash_effect.visible = false
	dash_effect.position = Vector2(0.0, _effect_anchor_y())
	dash_effect.rotation = 0.0
	player.sprite.scale = Vector2(_flip, 1.0)
	player.sprite.rotation = 0.0
	_cooldown_until = Time.get_ticks_msec() / 1000.0 + dash_cooldown

func Process( _delta : float ) -> State:
	_timer += _delta
	var progress : float = min(_timer / dash_duration, 1.0)
	player.sprite.scale.x = _flip * lerp(dash_scale_x, 1.0, progress)
	player.sprite.scale.y = lerp(dash_scale_y, 1.0, progress)
	player.sprite.rotation = _dash_direction.x * deg_to_rad(dash_tilt_degrees * (1.0 - progress))
	player.velocity = _dash_direction * dash_speed
	var leg_anchor := Vector2(0.0, _effect_anchor_y())
	dash_effect.position = leg_anchor + (_back_direction * effect_offset * progress)
	dash_effect.frame = mini(int(progress * 4), 3)
	if _timer >= dash_duration:
		if player.direction != Vector2.ZERO:
			return walk
		return idle
	return null

func Physics( _delta : float ) -> State:
	return null

func HandleInput( _event : InputEvent ) -> State:
	return null

func is_ready() -> bool:
	return (Time.get_ticks_msec() / 1000.0) >= _cooldown_until
