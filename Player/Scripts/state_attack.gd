class_name State_Attack extends State

var attacking : bool = false
var _hit_effect_play_id : int = 0

@export var attack_sound : AudioStream
@export_range(1, 20, 0.5) var decelerate_speed : float = 5.0
@export var hit_effect_duration : float = 0.12
@export var hit_effect_frames : int = 4
@onready var animation_attack: AnimationPlayer = \
		$"../../Sprite2D/AttackEffectSprite/AnimationPlayer"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var audio: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"
@onready var idle: State_Idle = $"../Idle"
@onready var walk: State_Walk = $"../Walk"
@onready var dash: State_Dash = $"../Dash"
@onready var hurt_box: HurtBox = $"../../Interactions/HurtBox"
@onready var on_hit_effect: Sprite2D = $"../../OnHitEffectSprite"



func Enter() -> void:
	player.state_changed.emit("attack")
	player.UpdateAnimation("attack")
	animation_attack.play( "attack_" + player.AnimDirection() )
	animation_player.animation_finished.connect( EndAttack )
	if not hurt_box.area_entered.is_connected(_on_hurt_box_area_entered):
		hurt_box.area_entered.connect(_on_hurt_box_area_entered)
	audio.stream = attack_sound
	audio.pitch_scale = randf_range( 0.9, 1.1 )
	audio.play()
	attacking = true

	await get_tree().create_timer( 0.01 ).timeout
	hurt_box.monitoring = true

func Exit() -> void:
	animation_player.animation_finished.disconnect( EndAttack )
	if hurt_box.area_entered.is_connected(_on_hurt_box_area_entered):
		hurt_box.area_entered.disconnect(_on_hurt_box_area_entered)
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


func _on_hurt_box_area_entered(a: Area2D) -> void:
	if a is HitBox:
		_play_hit_effect(a.global_position)


func _play_hit_effect(hit_position: Vector2) -> void:
	_hit_effect_play_id += 1
	var play_id := _hit_effect_play_id
	var frame_count := maxi(hit_effect_frames, 1)
	var step := hit_effect_duration / float(frame_count)
	on_hit_effect.global_position = hit_position
	on_hit_effect.frame = 0
	on_hit_effect.visible = true

	for i in range(frame_count):
		if play_id != _hit_effect_play_id:
			return
		on_hit_effect.frame = i
		await get_tree().create_timer(step).timeout

	if play_id == _hit_effect_play_id:
		on_hit_effect.visible = false
