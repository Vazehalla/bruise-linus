class_name State_Dash extends State

@export var dash_speed : float = 400.0
@export var dash_duration : float = 0.20
@export var dash_cooldown : float = 0.75

var _timer : float = 0.0
var _cooldown : float = 0.0
var _dash_direction : Vector2 = Vector2.ZERO

@onready var idle : State_Idle = $"../Idle"
@onready var walk : State_Walk = $"../Walk"


func Enter() -> void:
	_dash_direction = player.direction if player.direction != Vector2.ZERO else Vector2(player.cardinal_direction.x, player.cardinal_direction.y).normalized()
	_timer = 0.0
	player.UpdateAnimation("walk")


func Exit() -> void:
	_cooldown = dash_cooldown


func Process( _delta : float ) -> State:
	_cooldown = max(0.0, _cooldown - _delta)
	_timer += _delta
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
