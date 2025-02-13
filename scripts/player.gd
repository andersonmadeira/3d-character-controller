extends CharacterBody3D

@export var walk_speed: float = 5.0
@export var run_speed: float= 15.0
@export var acceleration = 4.0
@export var gravity_multiplier: float = 1.0
@export var jump_velocity: float = 4.5
@export var camera_controller: CameraController
@export var body: MeshInstance3D
@export var rotation_speed: float = 12.0

# TODO: Fix textures getting blurred from far camera
# TODO: Implement variable jump height
# TODO: Implement double jump (Set the number of allowed consecutive jumps)
# TODO: Implement jump buffer
# TODO: Implement coyote time
# TODO: Procedurally generate pipes for the player to slide on https://www.youtube.com/watch?v=4nOEVPjVmjc&ab_channel=BeauSeymour

var _is_running: bool = false
var _movement_input: Vector2
var _movement_direction: Vector3
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("run"):
		_is_running = false
	if event.is_action_pressed("run"):
		_is_running = true

func _physics_process(delta: float) -> void:
	# Handle gravity
	# TODO: Limit y velocity (aka gravity)
	if not is_on_floor():
		velocity += get_gravity() * gravity_multiplier * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Handle movement velocity
	_update_movement_velocity(delta)

	# Move
	move_and_slide()
	
	# Update rotation
	_update_model_rotation(delta)
	
func _update_movement_velocity(delta: float) -> void:
	var velocity_y = velocity.y
	velocity.y = 0
	
	_movement_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	_movement_direction = Vector3(_movement_input.x, 0, _movement_input.y).rotated(Vector3.UP, camera_controller.rotation.y)
	var speed := _get_movement_speed()
	
	velocity = lerp(velocity, _movement_direction * speed, acceleration * delta)
	velocity.y = velocity_y

func _get_movement_speed() -> float:
	return run_speed if _is_running else walk_speed

func _update_model_rotation(delta: float) -> void:
	# TODO: This rotation must be towards the movement direction, not exactly the camera, maybe that's why I had the Orientation node?
	if _movement_input.length() > 0:
		body.rotation.y = lerp_angle(body.rotation.y, camera_controller.rotation.y, rotation_speed * delta)
