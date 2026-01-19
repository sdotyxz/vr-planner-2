extends StaticBody3D
class_name Hostage
## 人质 - 使用随机3D模型，碰撞形状自动从mesh生成

signal died

## 人质模型场景列表
const HOSTAGE_MODELS: Array[String] = [
	"res://assets/scenes/hostage_1.tscn",
	"res://assets/scenes/hostage_2.tscn",
]

## 开门时的对话台词
const BREACH_DIALOGUES: Array[String] = [
	# 通用/程序相关
	"救命啊！",
	"别误伤我！",
	"保护年终奖！",
	"又要加班了！",
	"Bug太多了！",
	"编译不过！",
	"代码要回滚！",
	"空指针！",
	"内存泄漏！",
	"线上要爆炸！",
	# 策划相关
	"数值又要改！",
	"表格配错了！",
	"流程图呢！",
	"原型还没画！",
	"玩法要重做！",
	"关卡要调整！",
	"平衡性崩了！",
	"体验不对！",
	"节奏太慢了！",
	"难度太高了！",
	# 美术相关
	"贴图还没画！",
	"模型穿帮了！",
	"动画卡住了！",
	"颜色不对！",
	"风格要统一！",
	"分辨率太低！",
	"UV炸了！",
	"法线反了！",
	"骨骼断了！",
	"特效太卡了！",
	# PM相关
	"排期又变了！",
	"需求没对齐！",
	"会议要开始！",
	"进度落后了！",
	"资源不够！",
	"风险预警！",
	"依赖卡住了！",
	"优先级变了！",
	"老板要汇报！",
	"版本延期了！",
]

## 被救出时的对话台词
const RESCUED_DIALOGUES: Array[String] = [
	# 通用/程序相关
	"谢谢！",
	"终于安全了！",
	"Build Success!",
	"下班咯！",
	"代码没丢！",
	"年终奖有救了！",
	"测试通过！",
	"没有Bug！",
	"完美运行！",
	"全绿通过！",
	# 策划相关
	"数值平衡了！",
	"玩法成型了！",
	"体验优化好了！",
	"流程跑通了！",
	"关卡设计完成！",
	"文档写完了！",
	"表格配好了！",
	"原型通过了！",
	"评审过了！",
	"方案确定了！",
	# 美术相关
	"贴图画完了！",
	"模型做好了！",
	"动画流畅了！",
	"配色完美！",
	"风格统一了！",
	"特效炸裂！",
	"渲染完成！",
	"效果拉满！",
	"视觉震撼！",
	"美术过审了！",
	# PM相关
	"排期搞定了！",
	"需求对齐了！",
	"会议结束了！",
	"进度追上了！",
	"资源到位了！",
	"风险解除！",
	"依赖解决了！",
	"优先级确定！",
	"汇报通过了！",
	"准时发版！",
]

var model_instance: Node3D = null
var head_anchor: Marker3D = null


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
			
			# 获取头顶锚点
			head_anchor = model_instance.get_node_or_null("HeadAnchor") as Marker3D
			
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


## 设置人质模型为绿色安全材质
func set_safe_material() -> void:
	var green_material := load("res://assets/materials/green_safe.tres") as Material
	if green_material and model_instance:
		_apply_material_to_node(model_instance, green_material)


func _apply_material_to_node(node: Node, material: Material) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		mesh_instance.set_surface_override_material(0, material)
	
	for child in node.get_children():
		_apply_material_to_node(child, material)


## 获取头顶位置（用于生成对话气泡）
func get_head_position() -> Vector3:
	if head_anchor and is_instance_valid(head_anchor):
		return head_anchor.global_position
	# 回退：固定偏移
	return global_position + Vector3(0, 1.8, 0)


## 显示开门时的对话（红色 - 求救）
func show_breach_dialogue() -> void:
	if BREACH_DIALOGUES.size() > 0:
		var random_text := BREACH_DIALOGUES[randi() % BREACH_DIALOGUES.size()]
		VFXManager.spawn_dialogue_popup(get_head_position(), random_text, Color(1.0, 0.3, 0.3, 1.0))


## 显示被救出时的对话（绿色 - 救出）
func show_rescued_dialogue() -> void:
	if RESCUED_DIALOGUES.size() > 0:
		var random_text := RESCUED_DIALOGUES[randi() % RESCUED_DIALOGUES.size()]
		VFXManager.spawn_dialogue_popup(get_head_position(), random_text, Color(0.3, 1.0, 0.4, 1.0))
