extends Node
class_name CharacterMovement

signal grounded_state_changed(is_grounded: bool)

@export var walk_speed: float = 5.0
@export var run_speed: float= 15.0
@export var acceleration = 10.0
@export var gravity_multiplier: float = 1.0
@export var jump_velocity: float = 4.5
@export var input: CharacterInput
@export var body: CharacterBody3D
@export var visual: Node3D
@export var rotation_speed: float = 12.0

# TODO: Add gamepad camera rotation
# TODO: Add gamepad camera zoom
# TODO: Add acceleration option to movement
# TODO: Add deceleration option to movement
# TODO: After these TWO ^ add air control option to movement
# TODO: Add option to control how long the player stays in the apex of the jump
# TODO: Implement variable jump height
# TODO: Implement double jump (Set the number of allowed consecutive jumps)
# TODO: Implement jump buffer
# TODO: Implement coyote time
# TODO: Walk over rocks and small obstacles?
# TODO: Wall jump?
# TODO: Procedurally generate pipes for the player to slide on https://www.youtube.com/watch?v=4nOEVPjVmjc&ab_channel=BeauSeymour

var _is_running: bool = false
var _input: Vector2
var _direction: Vector3
var _is_grounded: bool

func _ready() -> void:
	input.movement_input_changed.connect(_on_movement_input_changed)
	
func set_direction(dir: Vector3) -> void:
	_direction = dir

func _on_movement_input_changed(input: Vector2) -> void:
	_input = input

func _unhandled_input(event: InputEvent) -> void:
	# TODO: Only start or stop running if grounded?
	if event.is_action_released("run"):
		_is_running = false
	if event.is_action_pressed("run"):
		_is_running = true

func _physics_process(delta: float) -> void:
	if body.is_on_floor() != _is_grounded:
		_is_grounded = body.is_on_floor()
		grounded_state_changed.emit(_is_grounded)
	
	# Handle gravity
	# TODO: Limit y velocity (aka gravity)
	if not body.is_on_floor():
		body.velocity += body.get_gravity() * gravity_multiplier * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and body.is_on_floor():
		body.velocity.y = jump_velocity

	# Handle movement velocity
	_update_movement_velocity(delta)

	# Move
	body.move_and_slide()
	
	# Update rotation
	_update_model_rotation(delta)

func _update_movement_velocity(delta: float) -> void:
	var velocity_y = body.velocity.y
	body.velocity.y = 0
	
	var speed := _get_movement_speed()
	
	body.velocity = lerp(body.velocity, _direction * speed, acceleration * delta)
	body.velocity.y = velocity_y

func _get_movement_speed() -> float:
	return run_speed if _is_running else walk_speed

func _update_model_rotation(delta: float) -> void:
	if _input.length() > 0:
		var direction_basis := Basis.looking_at(_direction)
		var q_from := visual.transform.basis.get_rotation_quaternion()
		var q_to := direction_basis.get_rotation_quaternion()
		visual.basis = Basis(q_from.slerp(q_to, delta * rotation_speed))
