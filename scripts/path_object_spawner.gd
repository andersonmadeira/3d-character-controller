@tool
extends Path3D
class_name PathObjectSpawner

@export var object_scene: PackedScene
@export_range(0, 100) var item_count: int = 1:
	set(value):
		item_count = value
		_spawn_items()
	get:
		return item_count

@onready var objects: Node3D = $Objects

func _spawn_items() -> void:
	if not is_inside_tree() or not object_scene:
		return
		
	var offsets = []
	var points = curve.tessellate_even_length()
	var up_vectors = curve.get_baked_up_vectors()
	
	for child in objects.get_children():
		child.queue_free()
	
	for i in range(item_count):
		offsets.append(float(i) / float(item_count+1))
		
	for offset_index in range(offsets.size()):
		var index = \
			clamp(int(points.size() * offsets[offset_index]), 0, points.size() - 1)
		var point = points[index]
		#var up_vector = up_vectors[index]
		
		var obj = Node3D.new()
		obj.name = "Object_"
		objects.add_child(obj)
		obj.translate(point)
		
		var instance = object_scene.instantiate()
		obj.add_child(instance)
		
		#if index + 1 > points.size() - 1:
			#obj.look_at(points[0], Vector3.RIGHT)
		#else:
			#obj.look_at(points[index + 1], Vector3.RIGHT)
			
		obj.owner = get_tree().edited_scene_root
		instance.owner = get_tree().edited_scene_root
	
