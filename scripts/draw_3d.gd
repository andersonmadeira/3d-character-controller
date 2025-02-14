@tool
extends Node

func line(p1: Vector3, p2: Vector3, color = Color.WHITE_SMOKE, duration_ms = 0):
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(p1)
	immediate_mesh.surface_add_vertex(p2)
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color

	return await _clean_up(mesh_instance, duration_ms)
	
## 0 -> Lasts ONLY for current physics frame
## > 1 -> Lasts X time duration.
func _clean_up(mesh_instance: MeshInstance3D, duration_ms: float):
	get_tree().get_root().add_child(mesh_instance)

	if duration_ms == 1:
		await get_tree().physics_frame
		mesh_instance.queue_free()
	elif duration_ms > 0:
		await get_tree().create_timer(duration_ms).timeout
		mesh_instance.queue_free()
	else:
		return mesh_instance
