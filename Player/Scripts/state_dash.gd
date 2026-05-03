class_name State_Dash extends State

@export var dash_speed : float = 400.0
@export var dash_duration : float = 0.20
@export var dash_cooldown : float = 0.75

var _timer : float = 0.0
var _cooldown : float = 0.0
var _dash_direction : Vector2 = Vector2.ZERO
var _flip : float = 1.0

@onready var idle : State_Idle = $"../Idle"
@onready var walk : State_Walk = $"../Walk"


func Enter() -> void:
	player.dash_started.emit()
	player.state_changed.emit("dash")
	_dash_direction = player.direction if player.direction != Vector2.ZERO else Vector2(player.cardinal_direction.x, player.cardinal_direction.y).normalized()
	_timer = 0.0
	_flip = sign(player.sprite.scale.x)
	player.sprite.scale = Vector2(_flip * 1.35, 0.8)
	player.sprite.rotation = _dash_direction.x * deg_to_rad(20.0)
	player.UpdateAnimation("walk")


func Exit() -> void:
	player.dash_ended.emit()
	player.sprite.scale = Vector2(_flip, 1.0)
	player.sprite.rotation = 0.0
	_cooldown = dash_cooldown


func Process( _delta : float ) -> State:
	_cooldown = max(0.0, _cooldown - _delta)
	_timer += _delta
	var progress : float = min(_timer / dash_duration, 1.0)
	player.sprite.scale.x = _flip * lerp(1.35, 1.0, progress)
	player.sprite.scale.y = lerp(0.8, 1.0, progress)
	player.velocity = _dash_direction * dash_speed
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
	return _cooldown <= 0.0
