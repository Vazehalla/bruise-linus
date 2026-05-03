class_name State_Idle extends State

@onready var walk : State_Walk = $"../Walk"
@onready var attack : State_Attack = $"../Attack"
@onready var dash : State_Dash = $"../Dash"
@onready var jump : State_Jump = $"../Jump"

func Enter() -> void:
	player.move_stopped.emit()
	player.state_changed.emit("idle")
	player.sprite.rotation = 0.0
	player.sprite.scale.y = 1.0
	player.UpdateAnimation("idle")

func Exit() -> void:
	pass

func Process( _delta: float ) -> State:
	if player.direction != Vector2.ZERO:
		return walk
	player.velocity = Vector2.ZERO
	return null

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
