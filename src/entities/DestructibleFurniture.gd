extends StaticBody3D
class_name DestructibleFurniture
## 可破坏家具 - 被射击后触发碎片效果并消失

signal destroyed

## 破坏参数
@export var destruction_force: float = 12.0  ## 爆炸力度
@export var fragment_count: int = 10  ## 碎片数量 (8-12)

## 模型引用
var model_instance: Node3D = null


func _ready() -> void:
	add_to_group("destructible")


## 设置家具模型（由 FurnitureConverter 调用）
func setup_model(model: Node3D) -> void:
	model_instance = model
	add_child(model_instance)
	# 从mesh自动生成碰撞形状
	_create_collision_from_mesh(model_instance)


## 破坏家具
func destroy() -> void:
	destroyed.emit()
	
	# 播放破坏音效
	AudioManager.play_sfx_3d("furniture_break", global_position)
	
	# 触发碎片效果
	if model_instance:
		ModelShatter.shatter_model(model_instance, global_position, destruction_force, fragment_count)
	
	# 销毁自身
	queue_free()


## 从mesh创建碰撞形状（参考 Enemy.gd 实现）
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
				# 应用mesh的变换（使用局部变换累积，避免 global_transform 在未加入场景树时的问题）
				collision_shape.transform = _get_local_transform_relative_to(mesh_instance, model_instance)
				add_child(collision_shape)
	
	for child in node.get_children():
		_create_collision_from_mesh(child)


func _get_local_transform_relative_to(node: Node3D, root: Node3D) -> Transform3D:
	"""计算节点相对于根节点的本地变换（不依赖 global_transform）"""
	var result := Transform3D.IDENTITY
	var current := node
	while current != null and current != root:
		result = current.transform * result
		var parent := current.get_parent()
		if parent is Node3D:
			current = parent
		else:
			break
	return result
