extends CharacterBody3D
class_name Player

@onready var movement: CharacterMovement = $CharacterMovement
@onready var input: CharacterInput = $CharacterInput
@onready var camera_controller: CameraController = $CameraController

var _movement_input: Vector2

func _ready() -> void:
	input.movement_input_changed.connect(_on_movement_input_changed)

func _on_movement_input_changed(movement_input: Vector2) -> void:
	_movement_input = movement_input

func _process(delta: float) -> void:
	var dir = Vector3(_movement_input.x, 0, _movement_input.y).rotated(Vector3.UP, camera_controller.rotation.y)
	movement.set_direction(dir)
	
