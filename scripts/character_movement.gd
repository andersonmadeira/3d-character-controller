extends Node
class_name CharacterMovement

signal grounded_state_changed(is_grounded: bool)

@export_group("Dependencies")
@export var input: CharacterInput
@export var body: CharacterBody3D
@export var visual: Node3D
@export_group("Movement")
@export var walk_speed: float = 5.0
@export var run_speed: float= 15.0
@export var jump_gravity_multiplier: float = 2.0
@export var fall_gravity_multiplier: float = 4.0
@export var rotation_speed: float = 12.0
@export_group("Acceleration")
@export var ground_acceleration: float = 10
@export var ground_deceleration: float = 10
@export var air_acceleration: float = 4
@export var air_deceleration: float = 4
@export_group("Jump")
@export var jump_force: float = 11
@export var min_jump_time: float = 0.25
@export var max_jump_height: float = 2
@export var apex_duration: float = 0.2
@export var max_fall_speed: float = -20

# TODO: Differentiate jumping from falling, when falling the player is using apex and variable jump logics

# TODO: Only show blob shadow when above a certain height (below that it is not needed)
# TODO: Fix: if too close to platforms and jumps, the decal is being spawned at the top (head) of the player

# TODO: Clean up code after variable jump height
# TODO: Implement double jump (Set the number of allowed consecutive jumps)
# TODO: Implement jump buffer
# TODO: Implement coyote time
# TODO: Investigate if variable jump needs improvement, it doesn't feel 100% right
# TODO: Stretch and squash player when jumping and landing

# TODO: Procedurally generate pipes for the player to slide on https://www.youtube.com/watch?v=4nOEVPjVmjc&ab_channel=BeauSeymour
# TODO: After this ^ if player jumps from too high it should change to "hard fall" animation and squash even more and slowly grow back to original size (mario vibes)

var _is_jumping: bool = false
var _is_running: bool = false
var _input: Vector2
var _direction: Vector3
var _is_grounded: bool = false
var _apex_time: float = 0
var _jump_requested: bool = false
var _jump_hold_time: float = 0
var _is_jump_being_held: bool = false
var _start_jump_y_position: float = 0
var _jump_height: float = 0
var _jump_held_overshoot: bool = false
var _reached_apex: bool = false
var _old_is_jumping: bool = false
var _jump_time: float = 0

func _ready() -> void:
	input.movement_input_changed.connect(_on_movement_input_changed)
	input.jump_pressed.connect(_on_jump_pressed)
	input.jump_released.connect(_on_jump_released)
	
func _on_jump_pressed() -> void:
	# Only start jumping when on floor
	if body.is_on_floor():
		_jump_time = 0
		_jump_hold_time = 0
		_reached_apex = false
		_is_jump_being_held = true
		
		_start_jump_y_position = body.global_position.y
	
func _on_jump_released() -> void:
	# Avoid resetting jump mid air
	if _is_jump_being_held and body.velocity.y >= 0:
		_is_jump_being_held = false
		
		# If released, only stop if reached min jump time
		if _jump_time >= min_jump_time:
			_stop_jumping()
	
func set_direction(dir: Vector3) -> void:
	_direction = dir

func _on_movement_input_changed(input: Vector2) -> void:
	_input = input
	
func _process(delta: float) -> void:
	if _is_jump_being_held or _jump_time <= min_jump_time:
		_jump_time += delta
		_jump_height = body.global_position.y - _start_jump_y_position
		
		if _jump_time >= min_jump_time and not _is_jump_being_held:
			_stop_jumping()

		if _jump_height >= max_jump_height:
			_reached_apex = true
			_stop_jumping()
		
func _stop_jumping() -> void:
	body.velocity.y = 0

func _physics_process(delta: float) -> void:
	if body.is_on_floor() and not _jump_requested:
		_is_jumping = false
	
	# TODO: Do I really need _is_jumping here?
	if body.is_on_floor() and not _is_jumping:
		_apex_time = apex_duration
	
	# Grounded state changed
	if body.is_on_floor() != _is_grounded:
		_is_grounded = body.is_on_floor()
		grounded_state_changed.emit(_is_grounded)
		
		#if not _is_grounded and _jump_requested:
			#_start_jump_y_position = body.global_position.y
		
		if _jump_requested:
			_is_jumping = true
			_jump_requested = false
	
	# TODO: Limit y velocity (aka gravity)
	if not body.is_on_floor():
		if body.velocity.y > 0 and not _reached_apex:
			body.velocity += body.get_gravity() * jump_gravity_multiplier * delta
		else:
			if _apex_time > 0 and _reached_apex and _is_jump_being_held and _is_jumping:
				body.velocity.y = 0
				_apex_time -= delta
			elif _jump_time >= min_jump_time:
				body.velocity += body.get_gravity() * fall_gravity_multiplier * delta
				
				if body.velocity.y < max_fall_speed:
					body.velocity.y = max_fall_speed
					
				print('Fall speed: ', body.velocity.y)

	if input.was_jump_pressed_this_frame() and body.is_on_floor():
		_jump_requested = true
		body.velocity.y = jump_force

	_update_movement_velocity(delta)

	body.move_and_slide()
	
	_update_model_rotation(delta)

func _update_movement_velocity(delta: float) -> void:
	var velocity_y = body.velocity.y
	body.velocity.y = 0
	
	var speed := _get_movement_speed()
	
	var accel := _get_movement_acceleration()
	body.velocity = lerp(body.velocity, _direction * speed, accel * delta)
	body.velocity.y = velocity_y
	
func _get_movement_acceleration() -> float:
	var accel: float = 0
	
	if body.is_on_floor():
		accel = ground_acceleration if _input != Vector2.ZERO else ground_deceleration
	else:
		accel = air_acceleration if _input != Vector2.ZERO else air_deceleration
	
	return accel

func _get_movement_speed() -> float:
	return run_speed if _is_running else walk_speed

func _update_model_rotation(delta: float) -> void:
	if _input.length() > 0 and _direction != Vector3.ZERO:
		var direction_basis := Basis.looking_at(_direction)
		var q_from := visual.transform.basis.get_rotation_quaternion()
		var q_to := direction_basis.get_rotation_quaternion()
		visual.basis = Basis(q_from.slerp(q_to, delta * rotation_speed))
