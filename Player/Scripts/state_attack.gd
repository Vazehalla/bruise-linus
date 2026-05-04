class_name State_Attack extends State

var attacking : bool = false

@export var attack_sound : AudioStream
@export_range(1, 20, 0.5) var decelerate_speed : float = 5.0
@onready var animation_attack: AnimationPlayer = \
		$"../../Sprite2D/AttackEffectSprite/AnimationPlayer"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var audio: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"
@onready var idle: State_Idle = $"../Idle"
@onready var walk: State_Walk = $"../Walk"
@onready var dash: State_Dash = $"../Dash"
@onready var hurt_box: HurtBox = $"../../Interactions/HurtBox"



func Enter() -> void:
	player.state_changed.emit("attack")
	player.UpdateAnimation("attack")
	animation_attack.play( "attack_" + player.AnimDirection() )
	animation_player.animation_finished.connect( EndAttack )
	audio.stream = attack_sound
	audio.pitch_scale = randf_range( 0.9, 1.1 )
	audio.play()
	attacking = true
	
	
	await get_tree().create_timer( 0.01 ).timeout
	hurt_box.monitoring = true
	pass

func Exit() -> void:
	animation_player.animation_finished.disconnect( EndAttack )
	attacking = false
	hurt_box.monitoring = false

func Process( _delta: float ) -> State:
	player.velocity -= player.velocity * decelerate_speed * _delta
	if attacking == false:
		if player.direction == Vector2.ZERO:
			return idle
		return walk
	return null

func Physics( _delta : float) -> State:
	return null

func HandleInput( _event : InputEvent ) -> State:
	if _event.is_action_pressed("dash") and dash.is_ready():
		return dash
	return null


func EndAttack( _newAnimName : String ) -> void:
	attacking = false
