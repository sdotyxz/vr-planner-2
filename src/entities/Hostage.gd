extends StaticBody3D
class_name Hostage
## 人质 - 绿色圆柱，误杀会扣分

@onready var mesh: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	add_to_group("hostage")


func hit() -> void:
	# 人质被击中的反馈（闪烁红色）
	if mesh and mesh.mesh:
		var mat := mesh.get_active_material(0)
		if mat is StandardMaterial3D:
			var standard_mat: StandardMaterial3D = mat as StandardMaterial3D
			var original_color: Color = standard_mat.albedo_color
			standard_mat.albedo_color = Color.RED
			await get_tree().create_timer(0.2).timeout
			standard_mat.albedo_color = original_color
