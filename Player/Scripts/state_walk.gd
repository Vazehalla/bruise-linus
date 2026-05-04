class_name State_Walk extends State

@export var move_speed : float = 180.0
@export var diagonal_up_tilt_degrees : float = 14.0
@export var diagonal_down_tilt_degrees : float = 20.0
@export var diagonal_up_scale_y : float = 1.04
@export var diagonal_down_scale_y : float = 0.94

@onready var idle : State = $"../Idle"
@onready var attack : State_Attack = $"../Attack"
@onready var dash : State_Dash = $"../Dash"
@onready var jump : State_Jump = $"../Jump"

func Enter() -> void:
	player.move_started.emit()
	player.state_changed.emit("walk")
	player.sprite.rotation = 0.0
	player.sprite.scale.y = 1.0
	player.UpdateAnimation("walk")

func Exit() -> void:
	player.sprite.rotation = 0.0

func Process( _delta: float ) -> State:
	if player.direction == Vector2.ZERO:
		return idle
	player.velocity = player.direction * move_speed
	if player.SetDirection():
		player.UpdateAnimation("walk")
	ApplyDiagonalVisuals(player.move_octant)
	return null


func ApplyDiagonalVisuals(octant : Vector2) -> void:
	if octant.x == 0.0 or octant.y == 0.0:
		player.sprite.rotation = 0.0
		player.sprite.scale.y = 1.0
		return

	if octant.y < 0.0:
		player.sprite.rotation = deg_to_rad(diagonal_up_tilt_degrees * octant.x)
		player.sprite.scale.y = diagonal_up_scale_y
		return

	player.sprite.rotation = deg_to_rad(diagonal_down_tilt_degrees * octant.x)
	player.sprite.scale.y = diagonal_down_scale_y

func Physics( _delta : float) -> State:
	return null

func HandleInput( _event : InputEvent ) -> State:
	if _event.is_action_pressed("attack"):
		return attack
	if _event.is_action_pressed("dash") and dash.is_ready():
		return dash
	if _event.is_action_pressed("jump"):
		return jump
	return null
