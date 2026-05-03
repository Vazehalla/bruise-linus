class_name State_Walk extends State

@export var move_speed : float = 180.0

@onready var idle : State = $"../Idle"
@onready var attack : State_Attack = $"../Attack"
@onready var dash : State_Dash = $"../Dash"
@onready var jump : State_Jump = $"../Jump"


# What happens when the player enters this State?
func Enter() -> void:
	player.move_started.emit()
	player.state_changed.emit("walk")
	player.sprite.rotation = 0.0
	player.sprite.scale.y = 1.0
	player.UpdateAnimation("walk")

# What happens when the player exits this State?
func Exit() -> void:
	player.sprite.rotation = 0.0

# What happenns during the _process update in this State?
func Process( _delta: float ) -> State:
	if player.direction == Vector2.ZERO:
		return idle
	
	player.velocity = player.direction * move_speed
	
	if player.SetDirection():
		player.UpdateAnimation("walk")
	
	if player.direction.x != 0.0 and player.direction.y != 0.0:
		player.sprite.rotation = deg_to_rad(12.0 * sign(player.direction.x))
	else:
		player.sprite.rotation = 0.0
	
	return null

# What happens during the _physics_process in this State?
func Physics( _delta : float) -> State:
	return null

#What happens with input events in this State?
func HandleInput( _event : InputEvent ) -> State:
	if _event.is_action_pressed("attack"):
		return attack
	if _event.is_action_pressed("dash") and dash.is_ready():
		return dash
	if _event.is_action_pressed("jump"):
		return jump
	return null
