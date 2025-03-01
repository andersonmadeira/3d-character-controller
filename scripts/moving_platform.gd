extends Node3D
class_name MovingPlatform

@export var move_time: float = 5
@export var idle_time: float = 2

@onready var path_follow: PathFollow3D = $Path3D/PathFollow3D
@onready var idle_timer: Timer = $IdleTimer
@onready var path_3d: Path3D = $Path3D

var _current_target: int = 1

func _ready() -> void:
	_move()

func _move() -> void:
	var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(path_follow, "progress_ratio", _current_target, move_time)
	tween.tween_callback(_finish_movement)

func _finish_movement() -> void:
	idle_timer.wait_time = idle_time
	idle_timer.start()

func _on_idle_timer_timeout() -> void:
	_switch_direction()
	_move()

func _switch_direction() -> void:
	_current_target = 0 if _current_target == 1 else 1
