extends Node3D
class_name ModelShatter
## 模型破碎效果 - 将模型分解成多个物理碎片飞散

const FRAGMENT_LIFETIME := 2.0  # 碎片存活时间
const FADE_DURATION := 0.5  # 淡出时间

## 碎片数据
var fragments: Array[RigidBody3D] = []


## 从目标模型生成破碎效果
static func shatter_model(model: Node3D, explosion_center: Vector3, force: float = 8.0, fragment_count: int = 12) -> ModelShatter:
	var shatter := ModelShatter.new()
	shatter.name = "ModelShatter"
	
	# 添加到场景树
	model.get_tree().root.add_child(shatter)
	shatter.global_position = model.global_position
	
	# 收集所有mesh
	var meshes: Array[Dictionary] = []
	shatter._collect_meshes(model, meshes)
	
	if meshes.is_empty():
		shatter.queue_free()
		return null
	
	# 生成碎片
	shatter._create_fragments(meshes, explosion_center, force, fragment_count)
	
	# 启动淡出和销毁计时
	shatter._start_fade_timer()
	
	return shatter


## 递归收集模型中的所有mesh信息
func _collect_meshes(node: Node, meshes: Array[Dictionary]) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh:
			meshes.append({
				"mesh": mesh_instance.mesh,
				"transform": mesh_instance.global_transform,
				"material": mesh_instance.get_active_material(0)
			})
	
	for child in node.get_children():
		_collect_meshes(child, meshes)


## 创建物理碎片
func _create_fragments(meshes: Array[Dictionary], explosion_center: Vector3, force: float, fragment_count: int) -> void:
	# 计算每个mesh分配的碎片数
	var fragments_per_mesh := maxi(1, fragment_count / maxi(1, meshes.size()))
	
	for mesh_data in meshes:
		var mesh: Mesh = mesh_data["mesh"]
		var mesh_transform: Transform3D = mesh_data["transform"]
		var material: Material = mesh_data["material"]
		
		# 获取mesh的AABB用于计算碎片分布
		var aabb := mesh.get_aabb()
		var mesh_center := mesh_transform * aabb.get_center()
		var mesh_size := aabb.size * mesh_transform.basis.get_scale()
		
		# 为这个mesh创建多个碎片
		for i in range(fragments_per_mesh):
			var fragment := _create_single_fragment(mesh, material, mesh_transform, mesh_center, mesh_size, explosion_center, force, i, fragments_per_mesh)
			if fragment:
				fragments.append(fragment)


## 创建单个碎片
func _create_single_fragment(original_mesh: Mesh, material: Material, mesh_transform: Transform3D, mesh_center: Vector3, mesh_size: Vector3, explosion_center: Vector3, force: float, index: int, total: int) -> RigidBody3D:
	var fragment := RigidBody3D.new()
	fragment.name = "Fragment_%d" % index
	add_child(fragment)
	
	# 计算碎片在原mesh内的随机位置
	var offset := Vector3(
		randf_range(-0.5, 0.5) * mesh_size.x * 0.8,
		randf_range(-0.5, 0.5) * mesh_size.y * 0.8,
		randf_range(-0.5, 0.5) * mesh_size.z * 0.8
	)
	fragment.global_position = mesh_center + offset
	
	# 创建碎片mesh（使用原mesh的缩小版或简单几何体）
	var mesh_instance := MeshInstance3D.new()
	fragment.add_child(mesh_instance)
	
	# 使用简化的box mesh作为碎片（更高效）
	var fragment_mesh := BoxMesh.new()
	var fragment_size := mesh_size / (sqrt(total) * 1.5)
	fragment_size = fragment_size.clamp(Vector3(0.05, 0.05, 0.05), Vector3(0.3, 0.3, 0.3))
	fragment_mesh.size = fragment_size
	
	# 应用原模型的材质
	if material:
		var frag_material := material.duplicate() as Material
		fragment_mesh.material = frag_material
	else:
		var default_mat := StandardMaterial3D.new()
		default_mat.albedo_color = Color(0.8, 0.6, 0.5)
		fragment_mesh.material = default_mat
	
	mesh_instance.mesh = fragment_mesh
	
	# 随机旋转
	fragment.rotation = Vector3(
		randf_range(0, TAU),
		randf_range(0, TAU),
		randf_range(0, TAU)
	)
	
	# 创建碰撞形状
	var collision := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = fragment_size
	collision.shape = box_shape
	fragment.add_child(collision)
	
	# 设置物理属性
	fragment.mass = 0.3
	fragment.gravity_scale = 2.0
	fragment.linear_damp = 0.2
	fragment.angular_damp = 0.2
	
	# 应用爆炸力 - 主要向Z轴负方向（远离玩家）分散
	var direction := (fragment.global_position - explosion_center).normalized()
	if direction.length_squared() < 0.01:
		direction = Vector3(randf_range(-0.3, 0.3), 0.5, -1.0).normalized()
	
	# 强化Z轴负方向，远离玩家飞散
	direction.z -= randf_range(0.8, 1.5)  # 主要向Z轴负方向飞散
	direction.y += randf_range(0.0, 0.2)  # 极少量向上
	direction.x += randf_range(-0.4, 0.4)  # 少量X轴随机
	direction = direction.normalized()
	
	# 大幅提高速度，增强冲击感
	var random_force := force * randf_range(1.2, 2.0)
	fragment.linear_velocity = direction * random_force
	fragment.angular_velocity = Vector3(
		randf_range(-20, 20),
		randf_range(-20, 20),
		randf_range(-20, 20)
	)
	
	return fragment


## 启动淡出计时器
func _start_fade_timer() -> void:
	# 等待一段时间后开始淡出
	await get_tree().create_timer(FRAGMENT_LIFETIME - FADE_DURATION).timeout
	
	if not is_inside_tree():
		return
	
	# 淡出所有碎片
	var tween := create_tween()
	tween.set_parallel(true)
	
	for fragment in fragments:
		if is_instance_valid(fragment):
			# 淡出材质
			for child in fragment.get_children():
				if child is MeshInstance3D:
					var mesh_inst := child as MeshInstance3D
					var mat: Material = mesh_inst.mesh.material
					if mat is StandardMaterial3D:
						var std_mat := mat as StandardMaterial3D
						std_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
						tween.tween_property(std_mat, "albedo_color:a", 0.0, FADE_DURATION)
	
	await tween.finished
	queue_free()
