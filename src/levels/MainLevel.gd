extends Node3D
class_name MainLevel
## 主关卡 - 轨道移动到门口 -> 开门 -> 射击 -> 清除敌人 -> 下一关

@onready var rail_system: RailSystem = $RailSystem
@onready var front_door: Door = $FrontDoor
@onready var back_door: Door = $BackDoor
@onready var entities: Node3D = $Entities
@onready var player: Player = $Player
@onready var hud: HUD = $UI/HUD
@onready var start_ui: Control = $UI/StartUI
@onready var game_over_ui: Control = $UI/GameOverUI
@onready var covers_container: Node3D = $Covers

# GameOver UI 元素
@onready var score_label: Label = $UI/GameOverUI/VBoxContainer/ScoreLabel
@onready var rooms_label: Label = $UI/GameOverUI/VBoxContainer/RoomsLabel
@onready var kills_label: Label = $UI/GameOverUI/VBoxContainer/KillsLabel

## 关卡配置
@export_group("Level Settings")
@export var base_time: float = 20.0  ## 第一关时间（秒）
@export var base_enemy_count: int = 4  ## 第一关敌人数量
@export var base_cover_count: int = 2  ## 第一关掩体数量
@export var hostage_count: int = 1  ## 人质数量（固定）

## 时间曲线配置（X轴为关卡数，Y轴为时间乘数）
@export_group("Difficulty Curves")
@export var time_curve: Curve  ## 时间曲线：关卡越高，时间乘数
@export var enemy_curve: Curve  ## 敌人曲线：关卡越高，敌人乘数
@export var cover_curve: Curve  ## 掩体曲线：关卡越高，掩体乘数

## 生成区域节点配置（通过场景中的节点定义区域）
@export_group("Spawn Areas")
@export_node_path("SpawnArea") var enemy_spawn_area_path: NodePath  ## 敌人生成区域
@export_node_path("SpawnArea") var hostage_spawn_area_path: NodePath  ## 人质生成区域
@export_node_path("SpawnArea") var door_avoid_area_path: NodePath  ## 门区域（避开）

var enemy_spawn_area: SpawnArea
var hostage_spawn_area: SpawnArea
var door_avoid_area: SpawnArea

var enemies_alive: int = 0
var current_room: int = 1
var time_remaining: float = 0.0
var timer_active: bool = false
var cover_positions: Array[Vector3] = []  ## 当前掩体位置列表
var shooting_hints: Array[Node3D] = []  ## 当前射击提示列表
var hint_to_enemy: Dictionary = {}  ## 射击提示到敌人的映射 {hint: enemy}

## 射击提示场景
var shooting_hint_scene: PackedScene = preload("res://assets/vfx/ShootingHint.tscn")


func _ready() -> void:
	# 添加到 main_level 组，方便其他节点查找
	add_to_group("main_level")
	
	# 获取 SpawnArea 节点引用
	if enemy_spawn_area_path:
		enemy_spawn_area = get_node_or_null(enemy_spawn_area_path) as SpawnArea
	if hostage_spawn_area_path:
		hostage_spawn_area = get_node_or_null(hostage_spawn_area_path) as SpawnArea
	if door_avoid_area_path:
		door_avoid_area = get_node_or_null(door_avoid_area_path) as SpawnArea
	
	# 初始化默认曲线（如果没有配置）
	_init_default_curves()
	
	# 连接信号
	if rail_system:
		rail_system.reached_waypoint1.connect(_on_reached_waypoint1)
		rail_system.door_ready_to_open.connect(_on_door_ready_to_open)
		rail_system.passed_door.connect(_on_passed_door)
		rail_system.reached_waypoint2.connect(_on_reached_waypoint2)
		rail_system.reached_waypoint3.connect(_on_reached_waypoint3)
		rail_system.ready_to_teleport.connect(_on_ready_to_teleport)
	
	if front_door:
		front_door.door_opened.connect(_on_front_door_opened)
	
	# 隐藏开始界面
	if start_ui:
		start_ui.visible = false
	if game_over_ui:
		game_over_ui.visible = false
	if hud:
		hud.visible = true
	
	# 直接开始游戏
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_respawn_enemies()
	GameManager.set_state(GameManager.GameState.PLAYING)
	await get_tree().create_timer(0.5).timeout
	if rail_system:
		rail_system.start_moving()


func _init_default_curves() -> void:
	# 时间曲线默认值：随关卡增加，时间略微增加
	if not time_curve:
		time_curve = Curve.new()
		time_curve.add_point(Vector2(0.0, 1.0))  # 第1关：1.0倍
		time_curve.add_point(Vector2(0.5, 1.2))  # 中期：1.2倍
		time_curve.add_point(Vector2(1.0, 1.5))  # 后期：1.5倍
	
	# 敌人曲线默认值：随关卡增加，敌人数量增加
	if not enemy_curve:
		enemy_curve = Curve.new()
		enemy_curve.add_point(Vector2(0.0, 1.0))  # 第1关：1.0倍
		enemy_curve.add_point(Vector2(0.5, 1.5))  # 中期：1.5倍
		enemy_curve.add_point(Vector2(1.0, 2.5))  # 后期：2.5倍
	
	# 掩体曲线默认值：随关卡增加，掩体数量增加
	if not cover_curve:
		cover_curve = Curve.new()
		cover_curve.add_point(Vector2(0.0, 1.0))  # 第1关：1.0倍
		cover_curve.add_point(Vector2(0.5, 1.5))  # 中期：1.5倍
		cover_curve.add_point(Vector2(1.0, 2.0))  # 后期：2.0倍


func _process(delta: float) -> void:
	# 手动同步玩家位置到轨道
	if player and rail_system:
		var path_follow = rail_system.get_node_or_null("PathFollow3D")
		if path_follow:
			player.global_position = path_follow.global_position
	
	# 倒计时逻辑
	if timer_active and time_remaining > 0:
		time_remaining -= delta
		_update_timer_display()
		
		if time_remaining <= 0:
			time_remaining = 0
			_on_time_up()


func _update_timer_display() -> void:
	if hud and hud.timer_label:
		var seconds := int(ceil(time_remaining))
		hud.timer_label.text = "%02d" % seconds
		
		# 时间紧迫时变红
		if time_remaining <= 5.0:
			hud.timer_label.add_theme_color_override("font_color", Color.RED)
		else:
			hud.timer_label.remove_theme_color_override("font_color")


func _on_time_up() -> void:
	_trigger_game_over()


## 触发游戏失败（射击提示变红或杀死人质）
func _trigger_game_over() -> void:
	# 防止重复触发
	if GameManager.current_state == GameManager.GameState.GAME_OVER:
		return
	
	GameManager.set_state(GameManager.GameState.GAME_OVER)
	
	# 禁用玩家控制
	if player:
		player.disable_control()
	
	# 延迟后显示结算界面
	await get_tree().create_timer(1.0).timeout
	_show_game_over_ui()


func _count_enemies() -> void:
	enemies_alive = 0
	if entities:
		for child in entities.get_children():
			if child is Enemy:
				enemies_alive += 1
				if not child.died.is_connected(_on_enemy_died):
					child.died.connect(_on_enemy_died)


func _on_reached_waypoint1() -> void:
	# 到达路径点1（门前），在此停留并准备开门
	GameManager.set_state(GameManager.GameState.BREACH)
	await get_tree().create_timer(0.2).timeout  # 短暂停留
	# 开门并继续移动
	if rail_system:
		rail_system.open_door_and_pass()


func _on_door_ready_to_open() -> void:
	# 打开门
	if front_door:
		front_door.open()


func _on_front_door_opened() -> void:
	# 门打开完成（如果需要特殊处理）
	pass


func _on_passed_door() -> void:
	# 穿过门，继续移动到路径点2
	pass


func _on_reached_waypoint2() -> void:
	# 到达路径点2（射击位置），停留并开始射击
	GameManager.set_state(GameManager.GameState.PLAYING)
	
	# 生成射击提示（逐个生成，从2倍缩放到1倍）
	_spawn_shooting_hints()
	
	# 启用玩家控制（可以开火和转视角）
	if player:
		player.enable_control()


func _on_reached_waypoint3() -> void:
	# 到达路径点3，准备传送回路径点1
	await get_tree().create_timer(0.5).timeout
	_teleport_and_restart()


func _on_ready_to_teleport() -> void:
	# 传送完成，准备开始下一关
	pass


func _start_timer() -> void:
	time_remaining = _get_level_time()
	timer_active = true
	_update_timer_display()


## 生成射击提示 - 逐个在敌人位置生成，从2倍缩放到1倍
func _spawn_shooting_hints() -> void:
	# 清除之前的射击提示
	_clear_shooting_hints()
	
	# 收集所有敌人
	var enemies: Array[Node] = []
	if entities:
		for child in entities.get_children():
			if child is Enemy:
				enemies.append(child)
	
	if enemies.is_empty():
		return
	
	# 随机打乱敌人顺序
	enemies.shuffle()
	
	# 逐个生成射击提示
	for i in range(enemies.size()):
		# 等待随机间隔（0.5到1秒）
		if i > 0:
			var delay := randf_range(0.5, 1.0)
			await get_tree().create_timer(delay).timeout
		
		# 检查敌人是否仍然有效
		if not is_instance_valid(enemies[i]):
			continue
		
		var enemy: Enemy = enemies[i]
		
		# 在敌人判定点生成射击提示（敌人中心偏上，大约胸部位置）
		var hint := shooting_hint_scene.instantiate() as Node3D
		add_child(hint)
		hint.global_position = enemy.global_position + Vector3(0, 1.2, 0)
		shooting_hints.append(hint)
		hint_to_enemy[hint] = enemy  # 记录映射关系
		
		# 为每个实例创建独立的材质副本，避免颜色修改影响其他实例
		if hint is Sprite3D:
			var sprite := hint as Sprite3D
			if sprite.material_override:
				sprite.material_override = sprite.material_override.duplicate()
				# 初始颜色为绿色
				var mat := sprite.material_override as StandardMaterial3D
				if mat:
					mat.albedo_color = Color(0.3, 1.0, 0.3, 0.9)
		
		# 初始缩放为2倍
		hint.scale = Vector3(2.0, 2.0, 2.0)
		
		# 创建缩放动画：从2倍缩放到1倍，持续2秒
		var tween := create_tween()
		tween.tween_property(hint, "scale", Vector3(1.0, 1.0, 1.0), 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		
		# 2秒内从绿色渐变到红色，变红后触发游戏失败
		_animate_hint_color(hint, enemy)
		
		# 连接敌人死亡信号，敌人死亡时移除对应的射击提示
		if not enemy.died.is_connected(_on_enemy_died_remove_hint.bind(hint)):
			enemy.died.connect(_on_enemy_died_remove_hint.bind(hint))


## 敌人死亡时移除对应的射击提示
func _on_enemy_died_remove_hint(hint: Node3D) -> void:
	if is_instance_valid(hint):
		# 淡出动画
		var tween := create_tween()
		tween.tween_property(hint, "modulate:a", 0.0, 0.2)
		tween.tween_callback(hint.queue_free)
		shooting_hints.erase(hint)
		hint_to_enemy.erase(hint)


## 清除所有射击提示
func _clear_shooting_hints() -> void:
	for hint in shooting_hints:
		if is_instance_valid(hint):
			hint.queue_free()
	shooting_hints.clear()
	hint_to_enemy.clear()


## 检查屏幕位置是否命中射击提示，返回对应的敌人（如果有）
## screen_pos: 屏幕坐标（鼠标位置）
## camera: 用于投影的相机
## 返回: 命中的敌人，如果没有命中返回 null
func check_shooting_hint_hit(screen_pos: Vector2, cam: Camera3D) -> Enemy:
	if not cam:
		return null
	
	var viewport_size := cam.get_viewport().get_visible_rect().size
	var closest_enemy: Enemy = null
	var closest_dist: float = INF
	
	for hint in shooting_hints:
		if not is_instance_valid(hint):
			continue
		
		var enemy: Enemy = hint_to_enemy.get(hint, null) as Enemy
		if not enemy or not is_instance_valid(enemy):
			continue
		
		# 获取射击提示的世界位置
		var hint_world_pos: Vector3 = hint.global_position
		
		# 检查是否在相机前方
		if not cam.is_position_behind(hint_world_pos):
			# 投影到屏幕坐标
			var hint_screen_pos := cam.unproject_position(hint_world_pos)
			
			# 计算射击提示在屏幕上的半径（根据缩放和距离）
			var distance_to_cam := cam.global_position.distance_to(hint_world_pos)
			# 基础半径（像素），根据距离调整
			var base_radius: float = 60.0 * hint.scale.x  # 考虑缩放动画
			var screen_radius: float = base_radius * (5.0 / maxf(distance_to_cam, 1.0))
			screen_radius = clampf(screen_radius, 30.0, 150.0)  # 限制范围
			
			# 检查鼠标是否在范围内
			var dist_to_hint := screen_pos.distance_to(hint_screen_pos)
			if dist_to_hint <= screen_radius and dist_to_hint < closest_dist:
				closest_dist = dist_to_hint
				closest_enemy = enemy
	
	return closest_enemy## 2秒内从绿色渐变到红色，变红后触发游戏失败
func _animate_hint_color(hint: Node3D, enemy: Enemy) -> void:
	if not hint is Sprite3D:
		return
	
	var sprite := hint as Sprite3D
	if not sprite.material_override or not sprite.material_override is StandardMaterial3D:
		return
	
	var mat := sprite.material_override as StandardMaterial3D
	
	# 创建颜色渐变动画：2秒内从绿色变红色
	var color_tween := create_tween()
	color_tween.tween_property(mat, "albedo_color", Color(1.0, 0.3, 0.3, 0.9), 2.0).set_ease(Tween.EASE_IN)
	
	# 2秒后检查并触发游戏失败
	await get_tree().create_timer(2.0).timeout
	
	# 检查提示和敌人是否都还有效
	if not is_instance_valid(hint) or not is_instance_valid(enemy):
		return
	
	# 检查游戏是否已经结束
	if GameManager.current_state == GameManager.GameState.GAME_OVER:
		return
	
	# 射击提示变红 = 游戏失败
	_trigger_game_over()


func _get_level_time() -> float:
	# 根据曲线计算当前关卡时间
	var progress := clampf((current_room - 1) / 20.0, 0.0, 1.0)  # 假设20关为满进度
	var multiplier := time_curve.sample(progress) if time_curve else 1.0
	return base_time * multiplier


func _get_enemy_count() -> int:
	# 根据曲线计算当前关卡敌人数量
	var progress := clampf((current_room - 1) / 20.0, 0.0, 1.0)
	var multiplier := enemy_curve.sample(progress) if enemy_curve else 1.0
	return int(ceil(base_enemy_count * multiplier))


func _get_cover_count() -> int:
	# 根据曲线计算当前关卡掩体数量
	var progress := clampf((current_room - 1) / 20.0, 0.0, 1.0)
	var multiplier := cover_curve.sample(progress) if cover_curve else 1.0
	return int(ceil(base_cover_count * multiplier))


func _on_enemy_died() -> void:
	enemies_alive -= 1
	
	if enemies_alive <= 0:
		# 所有敌人被消灭，移动到路径点3
		
		# 禁用玩家控制
		if player:
			player.disable_control()
			player.reset_view()
		
		# 移动到路径点3
		await get_tree().create_timer(1.0).timeout
		if rail_system:
			rail_system.continue_to_waypoint3()


## 人质被杀时触发游戏失败
func _on_hostage_died() -> void:
	_trigger_game_over()


## 关联的敌人被击杀时，人质也消失（被救出）
func _on_linked_enemy_died(hostage: Hostage) -> void:
	if is_instance_valid(hostage):
		# 人质被救出：变成绿色，0.5秒后消失
		hostage._set_model_color(Color(0.3, 1.0, 0.3, 1.0))  # 绿色
		await get_tree().create_timer(0.5).timeout
		if is_instance_valid(hostage):
			hostage.queue_free()


func _teleport_and_restart() -> void:
	"""传送回路径点1并开始下一关"""
	current_room += 1
	GameManager.rooms_cleared += 1
	
	# 传送到路径点1
	if rail_system:
		rail_system.teleport_to_waypoint1()
	
	# 重置前门
	if front_door:
		front_door.is_open = false
		var pivot := front_door.get_node_or_null("DoorPivot") as Node3D
		if pivot:
			pivot.rotation_degrees.x = 0
	
	# 重置后门
	if back_door:
		back_door.is_open = false
		var pivot := back_door.get_node_or_null("DoorPivot") as Node3D
		if pivot:
			pivot.rotation_degrees.x = 0
	
	# 重新生成敌人
	_respawn_enemies()
	
	# 等待一小段时间后再次开始移动（从路径点1开始）
	await get_tree().create_timer(0.3).timeout
	if rail_system:
		rail_system.start_moving()  # 从路径点1开始移动，到达后会自动触发开门


func _respawn_enemies() -> void:
	if not entities:
		return
	
	# 清除现有敌人和人质
	for child in entities.get_children():
		if child is Enemy or child is Hostage:
			child.queue_free()
	
	# 清除现有掩体
	if covers_container:
		for child in covers_container.get_children():
			child.queue_free()
	cover_positions.clear()
	
	# 清除射击提示
	_clear_shooting_hints()
	
	# 等待一帧确保节点被清除
	await get_tree().process_frame
	
	# 生成配置
	var enemy_count := _get_enemy_count()
	var cover_count := _get_cover_count()
	var standalone_enemy_count := enemy_count - cover_count  # 独立敌人数量
	
	# 计算敌人槽位数量（人质会生成在敌人斜前方，不需要独立槽位）
	var total_objects := cover_count + standalone_enemy_count
	if total_objects == 0:
		enemies_alive = 0
		return
	
	# 从 SpawnArea 节点获取区域范围
	var spawn_x_min := -10.0
	var spawn_x_max := 10.0
	var door_x_min := -2.5
	var door_x_max := 2.5
	var min_spacing := 3.5
	var enemy_z_min := -26.0
	var enemy_z_max := -16.0
	var hostage_z_min := -32.0
	var hostage_z_max := -28.0
	
	if enemy_spawn_area:
		var x_range := enemy_spawn_area.get_x_range()
		var z_range := enemy_spawn_area.get_z_range()
		spawn_x_min = x_range.x
		spawn_x_max = x_range.y
		enemy_z_min = z_range.x
		enemy_z_max = z_range.y
		min_spacing = enemy_spawn_area.min_spacing
	
	if hostage_spawn_area:
		var z_range := hostage_spawn_area.get_z_range()
		hostage_z_min = z_range.x
		hostage_z_max = z_range.y
	
	if door_avoid_area:
		var x_range := door_avoid_area.get_x_range()
		door_x_min = x_range.x
		door_x_max = x_range.y
	
	# 统一计算所有物体的X位置槽（均匀分布，不打乱）
	var all_x_slots := _calculate_uniform_x_slots(
		total_objects, spawn_x_min, spawn_x_max, door_x_min, door_x_max,
		[], min_spacing
	)
	
	# 按X位置排序，确保从左到右均匀
	all_x_slots.sort()
	
	var enemy_scene := preload("res://src/entities/Enemy.tscn")
	var hostage_scene := preload("res://src/entities/Hostage.tscn")
	
	# 先生成敌人，记录位置，然后人质生成在敌人斜前方
	# 物体类型: 0=掩体+敌人, 1=独立敌人
	var enemy_slots_count := cover_count + standalone_enemy_count
	var enemy_x_slots := all_x_slots.slice(0, enemy_slots_count)
	var spawned_enemies: Array[Dictionary] = []  # 记录生成的敌人位置 {x, z, node}
	
	# 创建敌人类型列表
	var enemy_types: Array[int] = []  # 0=掩体+敌人, 1=独立敌人
	for i in range(cover_count):
		enemy_types.append(0)
	for i in range(standalone_enemy_count):
		enemy_types.append(1)
	
	# 交错排列敌人类型
	var sorted_enemy_types: Array[int] = []
	var type_indices := [0, 0]
	var type_counts := [cover_count, standalone_enemy_count]
	var added := true
	while added:
		added = false
		for t in range(2):
			if type_indices[t] < type_counts[t]:
				sorted_enemy_types.append(t)
				type_indices[t] += 1
				added = true
	
	# 生成敌人
	for i in range(mini(sorted_enemy_types.size(), enemy_x_slots.size())):
		var x_pos: float = enemy_x_slots[i]
		var enemy_type: int = sorted_enemy_types[i]
		
		if enemy_type == 0:  # 掩体+敌人
			var z_pos := randf_range(enemy_z_min, enemy_z_max)
			
			# 生成掩体
			var cover := MeshInstance3D.new()
			var box_mesh := BoxMesh.new()
			box_mesh.size = Vector3(1.5, 1.2, 0.4)
			var material := StandardMaterial3D.new()
			material.albedo_color = Color(0.4, 0.3, 0.2, 1.0)
			material.roughness = 0.8
			box_mesh.material = material
			cover.mesh = box_mesh
			if covers_container:
				covers_container.add_child(cover)
			cover.global_position = Vector3(x_pos, 0.6, z_pos)
			cover_positions.append(Vector3(x_pos, 1.0, z_pos))
			
			# 生成掩体后的敌人
			var enemy: Enemy = enemy_scene.instantiate()
			entities.add_child(enemy)
			var enemy_z := z_pos - randf_range(0.8, 1.2)
			enemy.global_position = Vector3(x_pos, 0, enemy_z)
			if front_door:
				enemy.look_at_target(front_door.global_position)
			enemy.died.connect(_on_enemy_died)
			spawned_enemies.append({"x": x_pos, "z": enemy_z, "node": enemy})
			
		else:  # 独立敌人
			var enemy: Enemy = enemy_scene.instantiate()
			entities.add_child(enemy)
			var enemy_z := randf_range(enemy_z_min, enemy_z_max)
			enemy.global_position = Vector3(x_pos, 0, enemy_z)
			if front_door:
				enemy.look_at_target(front_door.global_position)
			enemy.died.connect(_on_enemy_died)
			spawned_enemies.append({"x": x_pos, "z": enemy_z, "node": enemy})
	
	# 生成人质 - 随机选择敌人，生成在敌人斜前方
	for i in range(hostage_count):
		if spawned_enemies.is_empty():
			break
		
		# 随机选择一个敌人
		var enemy_index := randi() % spawned_enemies.size()
		var enemy_info: Dictionary = spawned_enemies[enemy_index]
		
		# 人质生成在敌人斜前方（确保不完全遮挡敌人）
		# 前方偏移（Z轴正方向是玩家方向）: 0.3-0.8米（较近）
		var forward_offset := randf_range(0.3, 0.8)
		# 左右偏移: 随机左或右 1.0-1.5米（确保足够偏移，不遮挡敌人）
		var side_offset := randf_range(1.0, 1.5) * (1 if randf() > 0.5 else -1)
		
		var hostage_x: float = float(enemy_info["x"]) + side_offset
		var hostage_z: float = float(enemy_info["z"]) + forward_offset  # Z正方向是靠近玩家
		
		# 限制在合理范围内
		hostage_x = clampf(hostage_x, spawn_x_min, spawn_x_max)
		# 确保不在门的正前方
		if hostage_x > door_x_min - 0.5 and hostage_x < door_x_max + 0.5:
			hostage_x = door_x_max + 1.0 if hostage_x >= 0 else door_x_min - 1.0
		
		var hostage: Hostage = hostage_scene.instantiate()
		entities.add_child(hostage)
		hostage.global_position = Vector3(hostage_x, 0, hostage_z)
		hostage.died.connect(_on_hostage_died)
		
		# 关联敌人和人质：敌人死亡时人质也消失
		var linked_enemy: Enemy = enemy_info["node"] as Enemy
		if linked_enemy and is_instance_valid(linked_enemy):
			linked_enemy.died.connect(_on_linked_enemy_died.bind(hostage))
		
		# 移除已使用的敌人，避免多个人质在同一敌人旁边
		spawned_enemies.remove_at(enemy_index)
	
	enemies_alive = enemy_count


func _respawn_covers() -> void:
	# 掩体现在在 _respawn_enemies 中统一生成，这个函数保留为空
	pass


## 计算X轴上均匀分布的位置槽
## count: 需要的位置数量
## x_min, x_max: X轴范围
## door_x_min, door_x_max: 门的X范围（需要避开）
## occupied: 已占用的X位置
## min_spacing: 最小间距
func _calculate_uniform_x_slots(
	count: int, 
	x_min: float, x_max: float, 
	door_x_min: float, door_x_max: float,
	occupied: Array[float],
	min_spacing: float
) -> Array[float]:
	var result: Array[float] = []
	if count <= 0:
		return result
	
	# 可用区域：左侧 [x_min, door_x_min] 和 右侧 [door_x_max, x_max]
	var left_width := door_x_min - x_min
	var right_width := x_max - door_x_max
	var total_width := left_width + right_width
	
	if total_width <= 0:
		return result
	
	# 根据宽度比例分配数量
	var left_count := int(round(count * (left_width / total_width)))
	var right_count := count - left_count
	
	# 确保两边都有合理数量
	if left_count == 0 and count > 0 and left_width > min_spacing:
		left_count = 1
		right_count = count - 1
	if right_count == 0 and count > 0 and right_width > min_spacing:
		right_count = 1
		left_count = count - 1
	
	# 左侧区域均匀分布
	if left_count > 0:
		var step := left_width / float(left_count + 1)
		for i in range(left_count):
			var base_x := x_min + step * (i + 1)
			var final_x := _find_non_overlapping_x(base_x, occupied, min_spacing, x_min, door_x_min - 0.5)
			result.append(final_x)
			occupied.append(final_x)
	
	# 右侧区域均匀分布
	if right_count > 0:
		var step := right_width / float(right_count + 1)
		for i in range(right_count):
			var base_x := door_x_max + step * (i + 1)
			var final_x := _find_non_overlapping_x(base_x, occupied, min_spacing, door_x_max + 0.5, x_max)
			result.append(final_x)
			occupied.append(final_x)
	
	return result


## 在给定基准位置附近找到不重叠的X位置
func _find_non_overlapping_x(base_x: float, occupied: Array[float], min_spacing: float, x_min: float, x_max: float) -> float:
	# 先检查基准位置是否可用
	if _is_x_valid(base_x, occupied, min_spacing):
		return base_x
	
	# 尝试在附近找到可用位置
	for offset in [0.5, -0.5, 1.0, -1.0, 1.5, -1.5, 2.0, -2.0]:
		var test_x := clampf(base_x + offset, x_min, x_max)
		if _is_x_valid(test_x, occupied, min_spacing):
			return test_x
	
	# 如果找不到，返回带随机偏移的基准位置
	return clampf(base_x + randf_range(-0.5, 0.5), x_min, x_max)


## 检查X位置是否与已占用位置保持足够间距
func _is_x_valid(x: float, occupied: Array[float], min_spacing: float) -> bool:
	for occ_x in occupied:
		if absf(x - occ_x) < min_spacing:
			return false
	return true


func _return_to_start() -> void:
	# 重置游戏状态
	GameManager.reset_stats()
	GameManager.set_state(GameManager.GameState.START)
	
	# 重置关卡
	current_room = 1
	timer_active = false
	time_remaining = 0.0
	
	# 重置 HUD 显示
	if hud and hud.timer_label:
		hud.timer_label.text = ""
		hud.timer_label.remove_theme_color_override("font_color")
	
	# 重置玩家
	if player:
		player.disable_control()
		player.reset_view()
	
	# 重置轨道位置
	if rail_system:
		rail_system.reset_position()
	
	# 重置前门
	if front_door:
		front_door.is_open = false
		var pivot := front_door.get_node_or_null("DoorPivot") as Node3D
		if pivot:
			pivot.rotation_degrees.x = 0
	
	# 重置后门
	if back_door:
		back_door.is_open = false
		var pivot := back_door.get_node_or_null("DoorPivot") as Node3D
		if pivot:
			pivot.rotation_degrees.x = 0
	
	# 清除现有敌人和人质
	if entities:
		for child in entities.get_children():
			if child is Enemy or child is Hostage:
				child.queue_free()
	
	# 清除掩体
	if covers_container:
		for child in covers_container.get_children():
			child.queue_free()
	cover_positions.clear()
	
	# 清除射击提示
	_clear_shooting_hints()
	
	# 显示开始界面
	_show_start_ui()


func _show_start_ui() -> void:
	GameManager.set_state(GameManager.GameState.START)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if start_ui:
		start_ui.visible = true
	if game_over_ui:
		game_over_ui.visible = false
	if hud:
		hud.visible = false


func _show_game_over_ui() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# 更新结算数据
	if score_label:
		score_label.text = "SCORE: %d" % GameManager.score
	if rooms_label:
		rooms_label.text = "ROOMS: %d" % GameManager.rooms_cleared
	if kills_label:
		kills_label.text = "KILLS: %d" % GameManager.kills
	
	if game_over_ui:
		game_over_ui.visible = true
	if hud:
		hud.visible = false


func _on_start_button_pressed() -> void:
	if start_ui:
		start_ui.visible = false
	if hud:
		hud.visible = true
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# 重新生成敌人
	_respawn_enemies()
	
	# 开始游戏 - 玩家沿轨道移动
	GameManager.set_state(GameManager.GameState.PLAYING)
	await get_tree().create_timer(0.5).timeout
	if rail_system:
		rail_system.start_moving()


func _on_restart_button_pressed() -> void:
	# 隐藏结算界面
	if game_over_ui:
		game_over_ui.visible = false
	
	# 重置游戏状态
	GameManager.reset_stats()
	
	# 重置关卡
	current_room = 1
	timer_active = false
	time_remaining = 0.0
	
	# 重置 HUD 显示
	if hud:
		hud.visible = true
		if hud.timer_label:
			hud.timer_label.text = ""
			hud.timer_label.remove_theme_color_override("font_color")
	
	# 重置玩家
	if player:
		player.disable_control()
		player.reset_view()
	
	# 重置轨道位置
	if rail_system:
		rail_system.reset_position()
	
	# 重置前门
	if front_door:
		front_door.is_open = false
		var pivot := front_door.get_node_or_null("DoorPivot") as Node3D
		if pivot:
			pivot.rotation_degrees.x = 0
	
	# 重置后门
	if back_door:
		back_door.is_open = false
		var pivot := back_door.get_node_or_null("DoorPivot") as Node3D
		if pivot:
			pivot.rotation_degrees.x = 0
	
	# 清除现有敌人和人质
	if entities:
		for child in entities.get_children():
			if child is Enemy or child is Hostage:
				child.queue_free()
	
	# 清除掩体
	if covers_container:
		for child in covers_container.get_children():
			child.queue_free()
	cover_positions.clear()
	
	# 清除射击提示
	_clear_shooting_hints()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# 重新生成敌人并开始游戏
	_respawn_enemies()
	
	GameManager.set_state(GameManager.GameState.PLAYING)
	# 开始从起点移动到路径点1
	if rail_system:
		rail_system.start_moving()
