extends Node3D
class_name MovingPlatform

@export var speed: float = 1
@export var idle_time: float = 1
@export var destination: Vector3
@onready var animatable_body: AnimatableBody3D = $AnimatableBody3D
@onready var idle_timer: Timer = $IdleTimer

enum Direction { Forward, Backward }

var _origin: Vector3
var _current_target: Vector3
var _direction: Direction = Direction.Backward
var _stopped: bool = true

func _ready() -> void:
	_origin = global_position
	_current_target = destination

func _physics_process(delta: float) -> void:
	if _stopped:
		return

	# FIXME: This is not going to the end, need a way to check that reached destination, using tweens?
	animatable_body.global_position = \
		animatable_body.global_position.lerp(_current_target, delta * speed)
		
	var distance = animatable_body.global_position.distance_squared_to(_current_target)
	
	print(distance)
	
	if distance < 0.1:
		_stop()

func _stop() -> void:
	_stopped = true
	idle_timer.wait_time = idle_time
	idle_timer.start()

func _on_idle_timer_timeout() -> void:
	_switch_direction()
	_stopped = false

func _switch_direction() -> void:
	if _direction == Direction.Forward:
		_direction = Direction.Backward
		_current_target = _origin
	else:
		_direction = Direction.Forward
		_current_target = destination
