extends Node3D
class_name MainLevel
## 主关卡 - 轨道移动到门口 -> 开门 -> 射击 -> 清除敌人 -> 下一关

@onready var rail_system: RailSystem = $RailSystem
@onready var door: Door = $Door
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

var enemies_alive: int = 0
var current_room: int = 1
var time_remaining: float = 0.0
var timer_active: bool = false
var cover_positions: Array[Vector3] = []  ## 当前掩体位置列表


func _ready() -> void:
	# 初始化默认曲线（如果没有配置）
	_init_default_curves()
	
	# 连接信号
	if rail_system:
		rail_system.reached_door.connect(_on_reached_door)
		rail_system.reached_end.connect(_on_reached_end)
	
	if door:
		door.door_opened.connect(_on_door_opened)
	
	# 禁用玩家控制
	if player:
		player.disable_control()
	
	# 显示开始界面
	_show_start_ui()


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


func _on_reached_door() -> void:
	# 到达门口，进入 BREACH 状态
	GameManager.set_state(GameManager.GameState.BREACH)
	if door:
		door.open()


func _on_door_opened() -> void:
	# 门打开后，继续移动穿过门
	if rail_system:
		rail_system.continue_past_door()


func _on_reached_end() -> void:
	# 穿过门后，进入射击阶段，启用玩家控制，开始倒计时
	GameManager.set_state(GameManager.GameState.PLAYING)
	
	# 启用玩家控制（可以开火和转视角）
	if player:
		player.enable_control()
	
	_start_timer()


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
		# 所有敌人被消灭，停止计时，进入下一关
		timer_active = false
		_start_next_room()


func _start_next_room() -> void:
	current_room += 1
	GameManager.rooms_cleared += 1
	
	# 禁用玩家控制并重置视角
	if player:
		player.disable_control()
		player.reset_view()
	
	# 重置轨道位置
	if rail_system:
		rail_system.reset_position()
	
	# 重置门
	if door:
		door.is_open = false
		var pivot := door.get_node_or_null("DoorPivot") as Node3D
		if pivot:
			pivot.rotation_degrees.y = 0
	
	# 重新生成敌人
	_respawn_enemies()
	
	# 开始移动
	await get_tree().create_timer(0.5).timeout
	if rail_system:
		rail_system.start_moving()


func _respawn_enemies() -> void:
	if not entities:
		return
	
	# 清除现有敌人和人质
	for child in entities.get_children():
		if child is Enemy or child is Hostage:
			child.queue_free()
	
	# 等待一帧确保节点被清除
	await get_tree().process_frame
	
	# 先生成掩体
	_respawn_covers()
	
	# 生成配置
	var enemy_count := _get_enemy_count()
	var cover_count := cover_positions.size()
	
	# 确保至少有 cover_count 个敌人在掩体后（但不超过敌人总数）
	var enemies_behind_cover := mini(cover_count, enemy_count)
	var enemies_random := enemy_count - enemies_behind_cover
	
	const MIN_HOSTAGE_ENEMY_DISTANCE := 2.0  # 人质与敌人最小距离
	
	# 房间X轴范围
	const X_MIN := -10.0
	const X_MAX := 10.0
	# Z轴范围（深度方向，更远离玩家）
	const Z_MIN := -28.0
	const Z_MAX := -14.0
	
	var occupied_positions: Array[Vector3] = []
	var enemy_scene := preload("res://src/entities/Enemy.tscn")
	
	# 先在掩体后生成敌人
	for i in range(enemies_behind_cover):
		var cover_pos := cover_positions[i]
		# 敌人在掩体后面（Z 更负的方向，即更远离玩家）
		var enemy_pos := Vector3(
			cover_pos.x + randf_range(-0.5, 0.5),
			1.0,
			cover_pos.z - randf_range(0.5, 1.5)  # 在掩体后 0.5-1.5 米
		)
		occupied_positions.append(enemy_pos)
		
		var enemy: Enemy = enemy_scene.instantiate()
		entities.add_child(enemy)
		enemy.global_position = enemy_pos
		enemy.died.connect(_on_enemy_died)
	
	# 剩余敌人在X轴上均匀分布（带微小随机偏移）
	if enemies_random > 0:
		var x_step := (X_MAX - X_MIN) / float(enemies_random + 1)  # 均匀间隔
		for i in range(enemies_random):
			var base_x := X_MIN + x_step * (i + 1)  # 均匀分布的基准X位置
			var random_offset_x := randf_range(-1.5, 1.5)  # X轴微小随机偏移
			var final_x := clampf(base_x + random_offset_x, X_MIN, X_MAX)
			
			var pos := Vector3(
				final_x,
				1.0,
				randf_range(Z_MIN, Z_MAX)  # Z轴随机
			)
			occupied_positions.append(pos)
			
			var enemy: Enemy = enemy_scene.instantiate()
			entities.add_child(enemy)
			enemy.global_position = pos
			enemy.died.connect(_on_enemy_died)
	
	# 生成人质（在敌人之间的位置）
	var hostage_scene := preload("res://src/entities/Hostage.tscn")
	for i in range(hostage_count):
		var pos := _find_valid_position(occupied_positions, X_MIN, X_MAX, Z_MIN, Z_MAX, MIN_HOSTAGE_ENEMY_DISTANCE)
		occupied_positions.append(pos)
		
		var hostage: Hostage = hostage_scene.instantiate()
		entities.add_child(hostage)
		hostage.global_position = pos
	
	enemies_alive = enemy_count


func _respawn_covers() -> void:
	# 清除现有掩体
	if covers_container:
		for child in covers_container.get_children():
			child.queue_free()
	
	cover_positions.clear()
	
	var cover_count := _get_cover_count()
	
	# 掩体生成范围（匹配房间尺寸）
	const X_MIN := -9.0
	const X_MAX := 9.0
	const Z_MIN := -26.0
	const Z_MAX := -15.0
	const MIN_COVER_DISTANCE := 4.0  # 掩体之间最小距离
	
	for i in range(cover_count):
		var pos := _find_valid_position(cover_positions, X_MIN, X_MAX, Z_MIN, Z_MAX, MIN_COVER_DISTANCE)
		cover_positions.append(pos)
		
		# 创建掩体 MeshInstance3D（纯色方块）
		var cover := MeshInstance3D.new()
		var box_mesh := BoxMesh.new()
		box_mesh.size = Vector3(1.5, 1.2, 0.4)
		
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(0.4, 0.3, 0.2, 1.0)  # 棕色
		material.roughness = 0.8
		box_mesh.material = material
		
		cover.mesh = box_mesh
		
		if covers_container:
			covers_container.add_child(cover)
		cover.global_position = Vector3(pos.x, 0.6, pos.z)


func _find_valid_position(occupied: Array[Vector3], x_min: float, x_max: float, z_min: float, z_max: float, min_distance: float) -> Vector3:
	const MAX_ATTEMPTS := 50
	
	for attempt in range(MAX_ATTEMPTS):
		var test_pos := Vector3(
			randf_range(x_min, x_max),
			1.0,
			randf_range(z_min, z_max)
		)
		
		var valid := true
		for existing_pos in occupied:
			var dist := Vector2(test_pos.x, test_pos.z).distance_to(Vector2(existing_pos.x, existing_pos.z))
			if dist < min_distance:
				valid = false
				break
		
		if valid:
			return test_pos
	
	# 如果找不到合适位置，返回一个随机位置
	return Vector3(randf_range(x_min, x_max), 1.0, randf_range(z_min, z_max))


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
	
	# 重置门
	if door:
		door.is_open = false
		var pivot := door.get_node_or_null("DoorPivot") as Node3D
		if pivot:
			pivot.rotation_degrees.y = 0
	
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
	
	# 重置门
	if door:
		door.is_open = false
		var pivot := door.get_node_or_null("DoorPivot") as Node3D
		if pivot:
			pivot.rotation_degrees.y = 0
	
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
	await get_tree().create_timer(0.5).timeout
	if rail_system:
		rail_system.start_moving()
