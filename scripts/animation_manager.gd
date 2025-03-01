extends Node
class_name CharacterAnimation

@export var input: CharacterInput
@export var movement: CharacterMovement
@export var animation_player: AnimationPlayer
@export var animation_data: CharacterAnimationData

var _current_animation: String
var _movement_input: Vector2
var _is_grounded: bool

func _ready() -> void:
	input.movement_input_changed.connect(_on_movement_input_changed)
	movement.grounded_state_changed.connect(_on_grounded_state_changed)

func _on_movement_input_changed(input: Vector2) -> void:
	_movement_input = input
		
func _on_grounded_state_changed(is_grounded: bool) -> void:
	_is_grounded = is_grounded
	
func _change_animation(animation: String, blend = 0.2) -> void:
	if _current_animation != animation:
		animation_player.play(animation, blend)
		_current_animation = animation
		
func _process(delta: float) -> void:
	if _is_grounded:
		if not is_equal_approx(_movement_input.length(), 0):
			_change_animation(animation_data.run)
		else:
			_change_animation(animation_data.idle)
	else:
		_change_animation(animation_data.fall, 0.1)
	
