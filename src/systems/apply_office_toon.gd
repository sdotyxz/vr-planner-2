@tool
extends EditorScript

## Editor script to batch apply toon shader to all office furniture models in a scene.
## Usage: Open your scene, then run this script from Script menu -> Run.

const OFFICE_TOON_MATERIAL = preload("res://assets/materials/office_toon.tres")

func _run() -> void:
	var editor := EditorInterface.get_editor_interface() if Engine.has_singleton("EditorInterface") else null
	var edited_scene := get_scene()
	
	if edited_scene == null:
		push_error("No scene is open!")
		return
	
	print("Applying toon shader to office models...")
	var count := _apply_toon_recursive(edited_scene)
	print("Applied toon shader to %d mesh instances" % count)

func _apply_toon_recursive(node: Node) -> int:
	var count := 0
	
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		count += _apply_toon_to_mesh_instance(mesh_instance)
	
	for child in node.get_children():
		count += _apply_toon_recursive(child)
	
	return count

func _apply_toon_to_mesh_instance(mesh_instance: MeshInstance3D) -> int:
	var mesh := mesh_instance.mesh
	if mesh == null:
		return 0
	
	var applied := 0
	for i in range(mesh.get_surface_count()):
		var existing_mat := mesh_instance.get_active_material(i)
		
		# Skip if already using toon shader
		if existing_mat is ShaderMaterial:
			var shader_mat := existing_mat as ShaderMaterial
			if shader_mat.shader and "complete_toon" in shader_mat.shader.resource_path:
				continue
		
		# Create toon material
		var toon_mat := OFFICE_TOON_MATERIAL.duplicate() as ShaderMaterial
		
		# Extract texture/color from existing material
		if existing_mat is StandardMaterial3D:
			var std_mat := existing_mat as StandardMaterial3D
			if std_mat.albedo_texture:
				toon_mat.set_shader_parameter("base_texture", std_mat.albedo_texture)
			toon_mat.set_shader_parameter("color", std_mat.albedo_color)
		
		mesh_instance.set_surface_override_material(i, toon_mat)
		applied += 1
	
	return applied
