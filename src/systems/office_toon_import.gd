@tool
extends EditorScenePostImport

## Post-import script to apply toon shader to office furniture models.
## Assign this script to the model's import settings under "Import Script/Path".

const TOON_SHADER = preload("res://Shaders/complete_toon.gdshader")

func _post_import(scene: Node) -> Object:
	_apply_toon_shader_recursive(scene)
	return scene

func _apply_toon_shader_recursive(node: Node) -> void:
	# Apply to MeshInstance3D nodes
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		_apply_toon_to_mesh_instance(mesh_instance)
	
	# Recurse into children
	for child in node.get_children():
		_apply_toon_shader_recursive(child)

func _apply_toon_to_mesh_instance(mesh_instance: MeshInstance3D) -> void:
	var mesh := mesh_instance.mesh
	if mesh == null:
		return
	
	# Apply toon material to all surfaces
	for i in range(mesh.get_surface_count()):
		# Get existing material to extract texture if needed
		var existing_mat := mesh.surface_get_material(i)
		
		# Create a new ShaderMaterial with toon shader
		var toon_mat := ShaderMaterial.new()
		toon_mat.shader = TOON_SHADER
		
		# Default toon shader parameters
		toon_mat.set_shader_parameter("specular", Color(0.3, 0.3, 0.3, 0.4))
		toon_mat.set_shader_parameter("fresnel", Color(0.2, 0.2, 0.2, 0.2))
		toon_mat.set_shader_parameter("uv_scale", Vector2(1, 1))
		toon_mat.set_shader_parameter("uv_offset", Vector2(0, 0))
		
		# Try to get texture/color from existing material
		if existing_mat is StandardMaterial3D:
			var std_mat := existing_mat as StandardMaterial3D
			if std_mat.albedo_texture:
				toon_mat.set_shader_parameter("base_texture", std_mat.albedo_texture)
				toon_mat.set_shader_parameter("color", Color.WHITE)
			else:
				toon_mat.set_shader_parameter("color", std_mat.albedo_color)
		else:
			toon_mat.set_shader_parameter("color", Color(0.7, 0.7, 0.7, 1.0))
		
		mesh_instance.set_surface_override_material(i, toon_mat)
