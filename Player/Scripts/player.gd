class_name Player extends CharacterBody2D

signal move_started
signal move_stopped
signal dash_started
signal dash_ended
signal jump_started
signal jump_landed
signal state_changed(new_state : String)

# One of UP / DOWN / LEFT / RIGHT — controls which animation row to play.
var facing_cardinal : Vector2 = Vector2.DOWN
# Sign-only input vector, e.g. (1,1) for down-right. Controls diagonal visuals and sprite flip.
var facing : Vector2 = Vector2.DOWN
# Normalized raw input, e.g. (0.71, 0.71). Used for velocity and movement math.
var direction : Vector2 = Vector2.ZERO
var z_height : float = 0.0
var is_invincible : bool = false

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D
@onready var shadow : Sprite2D = $Sprite2D/ShadowSprite
@onready var state_machine : PlayerStateMachine = $StateMachine

signal direction_changed( new_direction : Vector2 )

func _ready() -> void:
	state_machine.Initialize(self)

func _process(_delta: float) -> void:
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()


func _physics_process(_delta: float) -> void:
	move_and_slide()


# Called by states each frame when there is input. Updates facing, cardinal direction,
# sprite flip, and emits direction_changed if the direction actually changed.
# Returns true if something changed, so states know when to refresh the animation.
func UpdateDirection() -> bool:
	if direction == Vector2.ZERO:
		return false

	var new_octant : Vector2 = _MovementOctant()
	var new_cardinal : Vector2 = _CardinalFromOctant(new_octant)

	if new_cardinal == facing_cardinal and new_octant == facing:
		return false

	facing_cardinal = new_cardinal
	facing = new_octant
	_UpdateSpriteFacing(new_octant)
	direction_changed.emit( new_cardinal )
	return true


func _MovementOctant() -> Vector2:
	return Vector2(sign(direction.x), sign(direction.y))


func _CardinalFromOctant(octant : Vector2) -> Vector2:
	# Collapses 8-way input into 4-way for animation row selection.
	if octant.y != 0.0:
		return Vector2.UP if octant.y < 0.0 else Vector2.DOWN
	return Vector2.LEFT if octant.x < 0.0 else Vector2.RIGHT


func _UpdateSpriteFacing(octant : Vector2) -> void:
	# Horizontal input takes priority for the sprite flip direction.
	if octant.x != 0.0:
		sprite.scale.x = -1.0 if octant.x < 0.0 else 1.0
		return

	if facing_cardinal == Vector2.LEFT:
		sprite.scale.x = -1.0
	elif facing_cardinal == Vector2.RIGHT:
		sprite.scale.x = 1.0


func FacingSign() -> float:
	return -1.0 if sprite.scale.x < 0.0 else 1.0


func UpdateAnimation( state : String ) -> void:
	animation_player.play( state + "_" + AnimDirection() )

func AnimDirection() -> String:
	if facing.y > 0.0:
		return "down"
	if facing.y < 0.0:
		return "up"
	return "side"
