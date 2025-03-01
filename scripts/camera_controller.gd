extends Node3D
class_name CameraController

@export var follow_target: Node3D
@export var follow_speed: float = 4.0
@export var zoom_speed: float = 7
@export var min_zoom: float = 3
@export var max_zoom: float = 20
@export var mouse_sensitivity = 0.0015

@onready var inner_gimbal: Node3D = $InnerGimbal
@onready var spring_arm: SpringArm3D = $InnerGimbal/SpringArm3D

var _is_mouse_controlling: bool = false
var _target_zoom: int

func _ready() -> void:
	_target_zoom = spring_arm.spring_length
	
func _physics_process(delta: float) -> void:
	global_position = follow_target.global_position
	# NOTE: lerping ended up weird idk
	#global_position = lerp(global_position, follow_target.global_position, follow_speed * delta)
	
func _process(delta: float) -> void:
	_update_zoom(delta)
	
func _update_zoom(delta: float) -> void:
	var zoom = lerpf(spring_arm.spring_length, _target_zoom, delta * zoom_speed)
	spring_arm.spring_length = zoom

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_is_mouse_controlling = event.is_pressed()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if _is_mouse_controlling else Input.MOUSE_MODE_VISIBLE
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_in()
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_out()
		
	if event is InputEventMouseMotion and _is_mouse_controlling:
		inner_gimbal.rotation.x -= event.relative.y * mouse_sensitivity
		inner_gimbal.rotation_degrees.x = clamp(inner_gimbal.rotation_degrees.x, -60.0, 00.0)
		rotation.y -= event.relative.x * mouse_sensitivity

func _zoom(factor: int) -> void:
	_target_zoom += factor
	_target_zoom = clamp(_target_zoom, min_zoom, max_zoom)

func _zoom_in() -> void:
	_zoom(-1)
	
func _zoom_out() -> void:
	_zoom(1)
