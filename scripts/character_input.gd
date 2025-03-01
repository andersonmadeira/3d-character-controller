extends Node
class_name CharacterInput

signal movement_input_changed(new_input: Vector2)
signal camera_input_changed(new_input: Vector2)
signal zoom(factor: float)
	
func was_jump_pressed_this_frame() -> bool:
	return Input.is_action_just_pressed("jump")
	
func _unhandled_input(event: InputEvent) -> void:
	var movement_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	movement_input_changed.emit(movement_input)
	
	var camera_input = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	camera_input_changed.emit(camera_input)
	
	if event.is_action_pressed("zoom_in"):
		zoom.emit(-1)

	if event.is_action_pressed("zoom_out"):
		zoom.emit(1)
