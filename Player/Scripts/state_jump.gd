class_name State_Jump extends State

@export var jump_duration : float = 0.40
@export var jump_height : float = 16.0
@export var jump_air_speed : float = 80.0
@export var jump_start_scale_x : float = 1.2
@export var jump_start_scale_y : float = 0.65
@export var jump_scale_x_drop : float = 0.35
@export var jump_scale_y_gain : float = 0.7
@export var jump_shadow_scale_drop : float = 0.4

var _t : float = 0.0

@onready var idle : State_Idle = $"../Idle"
@onready var walk : State_Walk = $"../Walk"

func Enter() -> void:
	player.jump_started.emit()
	player.move_started.emit()
	player.state_changed.emit("jump")
	_t = 0.0
	player.sprite.scale.x = player.FacingSign() * jump_start_scale_x
	player.sprite.scale.y = jump_start_scale_y
	player.UpdateAnimation("walk")


func Exit() -> void:
	player.jump_landed.emit()
	player.z_height = 0.0
	player.sprite.position.y = 0.0
	player.sprite.scale = Vector2(player.FacingSign(), 1.0)
	player.shadow.scale = Vector2.ONE

func Process( _delta : float ) -> State:
	_t += _delta / jump_duration
	if _t >= 1.0:
		if player.direction != Vector2.ZERO:
			return walk
		return idle

	player.z_height = jump_height * 4.0 * _t * (1.0 - _t)
	player.sprite.position.y = -player.z_height
	var squash_stretch : float = sin(PI * _t)
	var jump_scale_x : float = jump_start_scale_x - jump_scale_x_drop * squash_stretch
	player.sprite.scale.x = player.FacingSign() * jump_scale_x
	player.sprite.scale.y = jump_start_scale_y + jump_scale_y_gain * squash_stretch
	var shadow_scale : float = 1.0 - (player.z_height / jump_height) * jump_shadow_scale_drop
	player.shadow.scale = Vector2(shadow_scale, shadow_scale)

	if player.direction != Vector2.ZERO:
		player.velocity = player.direction * jump_air_speed
		player.UpdateDirection()
	else:
		player.velocity = Vector2.ZERO

	return null

func Physics( _delta : float ) -> State:
	return null

func HandleInput( _event : InputEvent ) -> State:
	return null
