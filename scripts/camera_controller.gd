extends Node3D
class_name CameraController

# TODO: Add gamepad camera zoom

@export var input: CharacterInput
@export var follow_speed: float = 4.0
@export var zoom_speed: float = 7
@export var min_zoom: float = 3
@export var max_zoom: float = 20
@export var mouse_sensitivity = 0.0015
@export var gamepad_sensitivity = 0.025

@onready var inner_gimbal: Node3D = $InnerGimbal
@onready var spring_arm: SpringArm3D = $InnerGimbal/SpringArm3D

var _is_mouse_controlling: bool = false
var _target_zoom: int
var _camera_controller_input: Vector2

func _ready() -> void:
	_target_zoom = spring_arm.spring_length
	input.camera_input_changed.connect(_on_camera_input_changed)
	input.zoom.connect(_on_camera_zoom)
	
func _on_camera_input_changed(input: Vector2) -> void:
	_camera_controller_input = input

func _on_camera_zoom(factor: float) -> void:
	_zoom(factor)

func _process(delta: float) -> void:
	_update_zoom(delta)
	_process_gamepad_rotation()
	
func _update_zoom(delta: float) -> void:
	var zoom = lerpf(spring_arm.spring_length, _target_zoom, delta * zoom_speed)
	spring_arm.spring_length = zoom

func _unhandled_input(event: InputEvent) -> void:
	_process_mouse_rotation(event)
	
func _process_gamepad_rotation() -> void:
	inner_gimbal.rotation.x -= _camera_controller_input.y * gamepad_sensitivity
	inner_gimbal.rotation_degrees.x = clamp(inner_gimbal.rotation_degrees.x, -90.0, -10.0)
	rotation.y -= _camera_controller_input.x * gamepad_sensitivity
	
func _process_mouse_rotation(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_is_mouse_controlling = event.is_pressed()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if _is_mouse_controlling else Input.MOUSE_MODE_VISIBLE
		
	if event is InputEventMouseMotion and _is_mouse_controlling:
		inner_gimbal.rotation.x -= event.relative.y * mouse_sensitivity
		inner_gimbal.rotation_degrees.x = clamp(inner_gimbal.rotation_degrees.x, -60.0, 00.0)
		rotation.y -= event.relative.x * mouse_sensitivity

func _zoom(factor: int) -> void:
	_target_zoom += factor
	_target_zoom = clamp(_target_zoom, min_zoom, max_zoom)
