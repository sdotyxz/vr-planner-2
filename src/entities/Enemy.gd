extends StaticBody3D
class_name Enemy
## 敌人 - 使用随机3D模型，碰撞形状自动从mesh生成

signal died

## 是否有关联的人质（击杀后救出人质，额外加分）
var has_linked_hostage: bool = false

## 头部锚点引用（用于射击提示定位）
var head_anchor: Marker3D = null

## 敌人模型场景列表
const ENEMY_MODELS: Array[String] = [
	"res://assets/scenes/enemy_1.tscn",
	"res://assets/scenes/enemy_2.tscn",
	"res://assets/scenes/enemy_3.tscn",
	"res://assets/scenes/enemy_4.tscn",
	"res://assets/scenes/enemy_5.tscn",
	"res://assets/scenes/enemy_6.tscn",
	"res://assets/scenes/enemy_7.tscn",
	"res://assets/scenes/enemy_8.tscn",
	"res://assets/scenes/enemy_9.tscn",
]

var model_instance: Node3D = null


func _ready() -> void:
	add_to_group("enemy")
	_randomize_model()


func _randomize_model() -> void:
	# 移除现有模型和碰撞形状
	for child in get_children():
		child.queue_free()
	
	# 随机选择模型
	if ENEMY_MODELS.size() > 0:
		var random_index := randi() % ENEMY_MODELS.size()
		var model_scene := load(ENEMY_MODELS[random_index]) as PackedScene
		if model_scene:
			model_instance = model_scene.instantiate()
			add_child(model_instance)
			
			# 获取头部锚点引用
			head_anchor = model_instance.get_node_or_null("HeadAnchor") as Marker3D
			
			# 从mesh自动生成碰撞形状
			_create_collision_from_mesh(model_instance)


func _randomize_rotation() -> void:
	# 随机Y轴旋转（0到360度）
	rotation.y = randf() * TAU


func look_at_target(target_pos: Vector3) -> void:
	# 朝向目标位置（只旋转Y轴）
	var direction := target_pos - global_position
	direction.y = 0  # 忽略高度差
	if direction.length_squared() > 0.001:
		look_at(global_position + direction, Vector3.UP)
		# look_at让-Z指向目标，但模型前面是+Z，需要旋转180度
		rotation.y += PI


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


## 获取头部锚点的世界坐标
## 如果没有头部锚点，返回默认位置（敌人位置 + 默认高度偏移）
func get_head_position() -> Vector3:
	if head_anchor and is_instance_valid(head_anchor):
		return head_anchor.global_position
	# 默认回退：使用固定偏移（胸部位置）
	return global_position + Vector3(0, 1.2, 0)


func die() -> void:
	died.emit()
	
	# 播放死亡音效
	AudioManager.play_sfx_3d("enemy_die", global_position, -5.0)
	
	# 生成模型破碎效果 - 高速向前飞散
	if model_instance:
		ModelShatter.shatter_model(model_instance, global_position, 18.0, 20)
	
	queue_free()
