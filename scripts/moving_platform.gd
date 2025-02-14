@tool
extends Node3D
class_name MovingPlatform

# TODO: In the editor, trace a line from origin to destination to help designing the level

@export var move_time: float = 5
@export var idle_time: float = 2
@export var destination: Vector3:
	set(val):
		destination = val
		_on_destination_changed(val)
@onready var animatable_body: AnimatableBody3D = $AnimatableBody3D
@onready var idle_timer: Timer = $IdleTimer

enum Direction { Forward, Backward }

var _origin: Vector3
var _current_target: Vector3
var _direction: Direction = Direction.Backward

var _debug_line: MeshInstance3D

func _ready() -> void:
	_origin = global_position
	_current_target = destination
	
	if not Engine.is_editor_hint():
		_move()

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		_on_destination_changed(destination)

func _exit_tree() -> void:
	if Engine.is_editor_hint():
		print('Goodbye!')

func _on_destination_changed(new_destination: Vector3) -> void:
	if Engine.is_editor_hint() and is_inside_tree():
		if _debug_line:
			_debug_line.queue_free()
		
		_debug_line = await Draw3D.line(global_position, new_destination)

func _move() -> void:
	var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(animatable_body, "global_position", _current_target, move_time)
	tween.tween_callback(_finish_movement)

func _finish_movement() -> void:
	idle_timer.wait_time = idle_time
	idle_timer.start()

func _on_idle_timer_timeout() -> void:
	_switch_direction()
	_move()

func _switch_direction() -> void:
	if _direction == Direction.Forward:
		_direction = Direction.Backward
		_current_target = _origin
	else:
		_direction = Direction.Forward
		_current_target = destination
