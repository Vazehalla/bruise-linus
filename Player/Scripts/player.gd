class_name Player extends CharacterBody2D

signal move_started
signal move_stopped
signal dash_started
signal dash_ended
signal jump_started
signal jump_landed
signal state_changed(new_state : String)

var cardinal_direction : Vector2 = Vector2.DOWN
var move_octant : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
var z_height : float = 0.0
var is_invincible : bool = false

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D
@onready var shadow : Sprite2D = $Sprite2D/ShadowSprite
@onready var state_machine : PlayerStateMachine = $StateMachine

signal DirectionChanged( new_direction : Vector2 )

func _ready() -> void:
	state_machine.Initialize(self)

func _process(_delta: float) -> void:
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()


func _physics_process(_delta: float) -> void:
	move_and_slide()


func SetDirection() -> bool:
	if direction == Vector2.ZERO:
		return false

	var new_octant : Vector2 = MovementOctant()
	var new_direction : Vector2 = CardinalDirectionFromOctant(new_octant)
	ApplyFacingFromOctant(new_octant)

	if new_direction == cardinal_direction and new_octant == move_octant:
		return false

	cardinal_direction = new_direction
	move_octant = new_octant
	DirectionChanged.emit( new_direction )
	return true


func MovementOctant() -> Vector2:
	return Vector2(sign(direction.x), sign(direction.y))


func CardinalDirectionFromOctant(octant : Vector2) -> Vector2:
	# Keep 3-direction animation rows, while still tracking 8-way octants.
	if octant.y != 0.0:
		return Vector2.UP if octant.y < 0.0 else Vector2.DOWN
	return Vector2.LEFT if octant.x < 0.0 else Vector2.RIGHT


func ApplyFacingFromOctant(octant : Vector2) -> void:
	# Horizontal facing should follow current horizontal input when available.
	if octant.x != 0.0:
		sprite.scale.x = -1.0 if octant.x < 0.0 else 1.0
		return

	if cardinal_direction == Vector2.LEFT:
		sprite.scale.x = -1.0
	elif cardinal_direction == Vector2.RIGHT:
		sprite.scale.x = 1.0


func FacingSign() -> float:
	return -1.0 if sprite.scale.x < 0.0 else 1.0


func UpdateAnimation( state : String ) -> void:
	animation_player.play( state + "_" + AnimDirection() )

func AnimDirection() -> String:
	if move_octant.y > 0.0:
		return "down"
	if move_octant.y < 0.0:
		return "up"
	return "side"
