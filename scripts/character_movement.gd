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
@export var gravity_multiplier: float = 1.0
@export var rotation_speed: float = 12.0
@export_group("Acceleration")
@export var ground_acceleration: float = 10
@export var ground_deceleration: float = 10
@export var air_acceleration: float = 4
@export var air_deceleration: float = 4
@export_group("Jump")
@export var fall_gravity: float = 45
@export var jump_height: float = 2
@export var jump_duration: float = 0.3
@export var apex_duration: float = 1

# TODO: Add option to control how long the player stays in the apex of the jump
# TODO: Implement variable jump height AND should only use apex duration if player hits apex fo the jump
# TODO: Implement double jump (Set the number of allowed consecutive jumps)
# TODO: Implement jump buffer
# TODO: Implement coyote time
# TODO: Walk over rocks and small obstacles?
# TODO: Wall jump?
# TODO: Procedurally generate pipes for the player to slide on https://www.youtube.com/watch?v=4nOEVPjVmjc&ab_channel=BeauSeymour

var _is_jumping: bool = false
var _is_running: bool = false
var _input: Vector2
var _direction: Vector3
var _is_grounded: bool = false
var _jump_gravity: float = fall_gravity
var _apex_time: float = 0
var _jump_requested: bool = false

func _ready() -> void:
	input.movement_input_changed.connect(_on_movement_input_changed)
	
func set_direction(dir: Vector3) -> void:
	_direction = dir

func _on_movement_input_changed(input: Vector2) -> void:
	_input = input

func _physics_process(delta: float) -> void:
	#print(_jump_requested)
	if body.is_on_floor() and not _jump_requested:
		_is_jumping = false
	
	if body.is_on_floor() and not _is_jumping:
		_apex_time = apex_duration
	
	# Grounded state changed
	if body.is_on_floor() != _is_grounded:
		_is_grounded = body.is_on_floor()
		grounded_state_changed.emit(_is_grounded)
		
		if _jump_requested:
			_is_jumping = true
			_jump_requested = false
	
	# TODO: Limit y velocity (aka gravity)
	if not body.is_on_floor():
		if body.velocity.y > 0:
			body.velocity.y -= _jump_gravity * delta
		else:
			if _apex_time > 0:
				body.velocity.y = 0
				_apex_time -= delta
			else:
				body.velocity.y -= fall_gravity * delta

	if input.was_jump_pressed_this_frame() and body.is_on_floor():
		_jump_requested = true
		body.velocity.y = _get_jump_force()
		_jump_gravity = body.velocity.y / jump_duration

	_update_movement_velocity(delta)

	body.move_and_slide()
	
	_update_model_rotation(delta)
	
func _get_jump_force() -> float:
	return 2 * jump_height / jump_duration

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
