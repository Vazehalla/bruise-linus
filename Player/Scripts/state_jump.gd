class_name State_Jump extends State

@export var jump_duration : float = 0.40
@export var jump_height : float = 16.0

var _t : float = 0.0

@onready var idle : State_Idle = $"../Idle"
@onready var walk : State_Walk = $"../Walk"


func Enter() -> void:
	player.jump_started.emit()
	player.state_changed.emit("jump")
	_t = 0.0
	player.sprite.scale.y = 0.7
	player.UpdateAnimation("walk")


func Exit() -> void:
	player.jump_landed.emit()
	player.z_height = 0.0
	player.sprite.position.y = 0.0
	player.sprite.scale.y = 1.0
	player.shadow.scale = Vector2.ONE


func Process( _delta : float ) -> State:
	_t += _delta / jump_duration
	if _t >= 1.0:
		if player.direction != Vector2.ZERO:
			return walk
		return idle

	player.z_height = jump_height * 4.0 * _t * (1.0 - _t)
	player.sprite.position.y = -player.z_height
	player.sprite.scale.y = 1.0 + 0.3 * sin(PI * _t)
	var shadow_scale : float = 1.0 - (player.z_height / jump_height) * 0.4
	player.shadow.scale = Vector2(shadow_scale, shadow_scale)

	if player.direction != Vector2.ZERO:
		player.velocity = player.direction * 80.0
		player.SetDirection()
	else:
		player.velocity = Vector2.ZERO

	return null


func Physics( _delta : float ) -> State:
	return null


func HandleInput( _event : InputEvent ) -> State:
	return null
