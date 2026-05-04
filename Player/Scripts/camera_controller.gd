class_name CameraController extends Camera2D

# -- Tunables --
@export var follow_speed_x : float = 12.0
@export var follow_speed_y : float = 12.0
@export var deadzone_width : float = 16.0
@export var deadzone_height : float = 10.0
@export var look_ahead_distance : float = 14.0
@export var look_ahead_recover_speed : float = 10.0
@export var base_zoom : Vector2 = Vector2(0.34, 0.306)
@export var colossus_zoom : Vector2 = Vector2(0.24, 0.216)
@export var zoom_transition_speed : float = 3.5
@export var shake_default_amplitude : float = 2.0
@export var shake_default_duration : float = 0.10
@export var shake_decay_rate : float = 25.0
@export var max_shake_amplitude : float = 4.0
@export var world_bounds_enabled : bool = false
@export var world_bounds : Rect2 = Rect2(-512.0, -512.0, 1024.0, 1024.0)

# -- Runtime fields --
var _target : Player
var _smooth_pos : Vector2 = Vector2.ZERO
var _look_ahead_offset : Vector2 = Vector2.ZERO
var _is_moving : bool = false
var _shake_amplitude : float = 0.0
var _shake_time_left : float = 0.0
var _shake_offset : Vector2 = Vector2.ZERO
var _zoom_target : Vector2 = Vector2.ONE
var _rng : RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_zoom_target = base_zoom
	zoom = base_zoom
	var parent := get_parent()
	if parent is Player:
		set_target(parent as Player)


func set_target(player : Player) -> void:
	_target = player
	_smooth_pos = player.global_position
	if not player.move_started.is_connected(_on_move_started):
		player.move_started.connect(_on_move_started)
	if not player.move_stopped.is_connected(_on_move_stopped):
		player.move_stopped.connect(_on_move_stopped)
	if not player.dash_started.is_connected(_on_dash_started):
		player.dash_started.connect(_on_dash_started)
	if not player.dash_ended.is_connected(_on_dash_ended):
		player.dash_ended.connect(_on_dash_ended)
	if not player.jump_started.is_connected(_on_jump_started):
		player.jump_started.connect(_on_jump_started)
	if not player.jump_landed.is_connected(_on_jump_landed):
		player.jump_landed.connect(_on_jump_landed)
	if not player.state_changed.is_connected(_on_state_changed):
		player.state_changed.connect(_on_state_changed)


func _physics_process(delta : float) -> void:
	if not _target:
		return
	_update_look_ahead(delta)
	_smooth_pos = _solve_deadzone(_target.global_position + _look_ahead_offset, delta)
	if world_bounds_enabled:
		_smooth_pos = _apply_bounds(_smooth_pos)
	_update_shake(delta)
	global_position = _smooth_pos + _shake_offset
	zoom = zoom.lerp(_zoom_target, zoom_transition_speed * delta)


func _update_look_ahead(delta : float) -> void:
	var target_offset : Vector2 = Vector2.ZERO
	if _is_moving:
		target_offset = _target.direction * look_ahead_distance
	_look_ahead_offset = _look_ahead_offset.lerp(target_offset, look_ahead_recover_speed * delta)


func _solve_deadzone(target_pos : Vector2, delta : float) -> Vector2:
	var half_w : float = deadzone_width * 0.5
	var half_h : float = deadzone_height * 0.5
	var diff : Vector2 = target_pos - _smooth_pos
	var desired : Vector2 = _smooth_pos

	if diff.x > half_w:
		desired.x = target_pos.x - half_w
	elif diff.x < -half_w:
		desired.x = target_pos.x + half_w

	if diff.y > half_h:
		desired.y = target_pos.y - half_h
	elif diff.y < -half_h:
		desired.y = target_pos.y + half_h

	return Vector2(
		lerpf(_smooth_pos.x, desired.x, follow_speed_x * delta),
		lerpf(_smooth_pos.y, desired.y, follow_speed_y * delta)
	)


func _apply_bounds(pos : Vector2) -> Vector2:
	return Vector2(
		clampf(pos.x, world_bounds.position.x, world_bounds.end.x),
		clampf(pos.y, world_bounds.position.y, world_bounds.end.y)
	)


func set_colossus_mode(active : bool) -> void:
	_zoom_target = colossus_zoom if active else base_zoom


func _update_shake(delta : float) -> void:
	if _shake_time_left <= 0.0:
		_shake_amplitude = 0.0
		_shake_offset = Vector2.ZERO
		return
	_shake_time_left -= delta
	_shake_amplitude = maxf(0.0, _shake_amplitude - shake_decay_rate * delta)
	_shake_offset = Vector2(
		_rng.randf_range(-_shake_amplitude, _shake_amplitude),
		_rng.randf_range(-_shake_amplitude, _shake_amplitude)
	)


func request_shake(amplitude : float = -1.0, duration : float = -1.0) -> void:
	var amp : float = shake_default_amplitude if amplitude < 0.0 else amplitude
	var dur : float = shake_default_duration if duration < 0.0 else duration
	_shake_amplitude = minf(_shake_amplitude + amp, max_shake_amplitude)
	_shake_time_left = maxf(_shake_time_left, dur)


func _on_move_started() -> void:
	_is_moving = true


func _on_move_stopped() -> void:
	_is_moving = false


func _on_dash_started() -> void:
	pass


func _on_dash_ended() -> void:
	pass


func _on_jump_started() -> void:
	pass


func _on_jump_landed() -> void:
	request_shake()


func _on_state_changed(_new_state : String) -> void:
	pass
