extends CharacterBody3D

@export var walk_speed: float = 5.0
@export var run_speed: float= 15.0
@export var gravity_multiplier: float = 1.0
@export var jump_velocity: float = 4.5

var _is_running: bool = false
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("run"):
		_is_running = false
	if event.is_action_pressed("run"):
		_is_running = true

func _physics_process(delta: float) -> void:
	# Handle gravity
	if not is_on_floor():
		velocity += get_gravity() * gravity_multiplier * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Handle movement velocity
	var speed := _get_movement_speed()
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	# Move
	move_and_slide()

func _get_movement_speed() -> float:
	return run_speed if _is_running else walk_speed
