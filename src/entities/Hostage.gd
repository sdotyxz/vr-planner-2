extends StaticBody3D
class_name Hostage
## 人质 - 使用随机3D模型，碰撞形状自动从mesh生成

signal died

## 人质模型场景列表
const HOSTAGE_MODELS: Array[String] = [
	"res://assets/scenes/hostage_1.tscn",
	"res://assets/scenes/hostage_2.tscn",
]

var model_instance: Node3D = null


func _ready() -> void:
	add_to_group("hostage")
	_randomize_model()


func _randomize_model() -> void:
	# 移除现有模型和碰撞形状
	for child in get_children():
		child.queue_free()
	
	# 随机选择模型
	if HOSTAGE_MODELS.size() > 0:
		var random_index := randi() % HOSTAGE_MODELS.size()
		var model_scene := load(HOSTAGE_MODELS[random_index]) as PackedScene
		if model_scene:
			model_instance = model_scene.instantiate()
			add_child(model_instance)
			
			# 从mesh自动生成碰撞形状
			_create_collision_from_mesh(model_instance)


func _create_collision_from_mesh(node: Node) -> void:
	"""递归遍历节点树，为每个MeshInstance3D创建碰撞形状并添加到当前 StaticBody3D"""
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh:
			# 从mesh创建凸包形状
			var convex_shape := mesh_instance.mesh.create_convex_shape()
			if convex_shape:
				var collision_shape := CollisionShape3D.new()
				collision_shape.shape = convex_shape
				# 应用mesh的变换（包括模型的缩放）
				collision_shape.transform = _get_global_transform_relative_to(mesh_instance, self)
				add_child(collision_shape)
	
	for child in node.get_children():
		_create_collision_from_mesh(child)


func _get_global_transform_relative_to(node: Node3D, relative_to: Node3D) -> Transform3D:
	"""获取节点相对于另一个节点的变换"""
	return relative_to.global_transform.affine_inverse() * node.global_transform


func hit() -> void:
	died.emit()
	
	# 生成模型破碎效果 - 高速向前飞散
	if model_instance:
		ModelShatter.shatter_model(model_instance, global_position, 15.0, 18)
	
	queue_free()


func _set_model_color(color: Color) -> void:
	# 递归设置模型颜色
	_apply_color_to_node(model_instance, color)


func _apply_color_to_node(node: Node, color: Color) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		var material := mesh_instance.get_active_material(0)
		if material is StandardMaterial3D:
			var mat := material.duplicate() as StandardMaterial3D
			mat.albedo_color = color
			mesh_instance.set_surface_override_material(0, mat)
	
	for child in node.get_children():
		_apply_color_to_node(child, color)
