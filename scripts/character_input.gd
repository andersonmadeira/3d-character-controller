extends Node
class_name CharacterInput

signal movement_input_changed(new_input: Vector2)

func _process(delta: float) -> void:
	var input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	movement_input_changed.emit(input)
