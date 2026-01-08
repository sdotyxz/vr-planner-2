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


func _ready() -> void:
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
	timer_active = false
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
	
	# 启用玩家控制（可以开火和转视角）
	if player:
		player.enable_control()
	
	_start_timer()


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
	
	if enemies_alive <= 0 and timer_active:
		# 所有敌人被消灭，停止计时，移动到路径点3
		timer_active = false
		
		# 禁用玩家控制
		if player:
			player.disable_control()
			player.reset_view()
		
		# 移动到路径点3
		await get_tree().create_timer(1.0).timeout
		if rail_system:
			rail_system.continue_to_waypoint3()


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
	
	# 等待一帧确保节点被清除
	await get_tree().process_frame
	
	# 生成配置
	var enemy_count := _get_enemy_count()
	var cover_count := _get_cover_count()
	var standalone_enemy_count := enemy_count - cover_count  # 独立敌人数量
	
	# 计算总物体数量：掩体+敌人算一个，独立敌人，人质
	var total_objects := cover_count + standalone_enemy_count + hostage_count
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
	
	# 创建物体类型列表，然后交错分配到槽位
	# 物体类型: 0=掩体+敌人, 1=独立敌人, 2=人质
	var object_types: Array[int] = []
	for i in range(cover_count):
		object_types.append(0)
	for i in range(standalone_enemy_count):
		object_types.append(1)
	for i in range(hostage_count):
		object_types.append(2)
	
	# 交错排列物体类型，让不同类型分散开
	var sorted_types: Array[int] = []
	var type_indices := [0, 0, 0]  # 每种类型当前索引
	var type_counts := [cover_count, standalone_enemy_count, hostage_count]
	
	# 轮流从每种类型取一个
	var added := true
	while added:
		added = false
		for t in range(3):
			if type_indices[t] < type_counts[t]:
				sorted_types.append(t)
				type_indices[t] += 1
				added = true
	
	# 根据排列好的类型和槽位生成物体
	for i in range(mini(sorted_types.size(), all_x_slots.size())):
		var x_pos: float = all_x_slots[i]
		var obj_type: int = sorted_types[i]
		
		if obj_type == 0:  # 掩体+敌人
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
			enemy.global_position = Vector3(x_pos, 1.0, z_pos - randf_range(0.8, 1.2))
			enemy.died.connect(_on_enemy_died)
			
		elif obj_type == 1:  # 独立敌人
			var enemy: Enemy = enemy_scene.instantiate()
			entities.add_child(enemy)
			enemy.global_position = Vector3(x_pos, 1.0, randf_range(enemy_z_min, enemy_z_max))
			enemy.died.connect(_on_enemy_died)
			
		else:  # 人质
			var hostage: Hostage = hostage_scene.instantiate()
			entities.add_child(hostage)
			hostage.global_position = Vector3(x_pos, 1.0, randf_range(hostage_z_min, hostage_z_max))
	
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
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# 重新生成敌人并开始游戏
	_respawn_enemies()
	
	GameManager.set_state(GameManager.GameState.PLAYING)
	# 开始从起点移动到路径点1
	if rail_system:
		rail_system.start_moving()
