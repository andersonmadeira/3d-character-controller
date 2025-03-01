extends ShapeCast3D

@onready var collision_shape: CollisionShape3D = $"../CollisionShape3D"

@onready var decal: Decal = $"../Decal"
@onready var player: CharacterBody3D = $".."

var _offset: float
var _col_id: int
var _obj_below_feet: Node3D

func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	if not player.is_on_floor():
		decal.visible = is_colliding()
		
		if is_colliding() and get_collider(0).get_instance_id() != _col_id:
			_col_id = get_collider(0).get_instance_id()
			print(_col_id)
			_obj_below_feet = get_collider(0)
			_offset = _obj_below_feet.global_position.y - get_collision_point(0).y

		if decal.visible:
			var pos = Vector3(\
			player.global_position.x, _obj_below_feet.global_position.y - _offset, player.global_position.z)
			#print(pos)
			decal.global_position = pos
	else:
		decal.visible = false
		_col_id = 0
		_offset = player.global_position.y
