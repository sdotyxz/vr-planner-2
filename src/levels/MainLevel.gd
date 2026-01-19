extends Node3D
class_name MainLevel
## 主关卡 - 轨道移动到门口 -> 开门 -> 射击 -> 清除敌人 -> 下一关

@onready var rail_system: RailSystem = $RailSystem
@onready var front_door: Door = $FrontDoor
@onready var back_door: Door = $BackDoor
@onready var entities: Node3D = $Entities
@onready var player: Player = $Player
@onready var hud: HUD = $UI/HUD
@onready var title_screen: Control = $UI/TitleScreen
@onready var fire_to_start: Label = $UI/TitleScreen/FireToStart
@onready var start_ui: Control = $UI/StartUI
@onready var game_over_ui: Control = $UI/GameOverUI
@onready var covers_container: Node3D = $Covers
@onready var world_environment: WorldEnvironment = $WorldEnvironment

## 标题界面是否已显示过（只显示一次）
var _title_shown: bool = false

## 闪烁动画 Tween
var _blink_tween: Tween = null

# GameOver UI 元素 - 排行榜
@onready var leaderboard_title: Label = $UI/GameOverUI/VBoxContainer/LeaderboardTitle
@onready var leaderboard_container: VBoxContainer = $UI/GameOverUI/VBoxContainer/LeaderboardContainer
@onready var name_input_container: HBoxContainer = $UI/GameOverUI/VBoxContainer/NameInputContainer
@onready var name_input: LineEdit = $UI/GameOverUI/VBoxContainer/NameInputContainer/NameInput
@onready var click_hint: Label = $UI/GameOverUI/VBoxContainer/ClickHint

## 是否可以点击重启（名字已提交后）
var _can_click_restart: bool = false

## 3D结算界面场景（使用 TextMesh 3D字体）
var game_over_screen_3d_scene: PackedScene = preload("res://src/ui/GameOverScreen3DText.tscn")
var game_over_screen_3d: GameOverScreen3DText = null

## Office场景管理器
var office_scene_manager: OfficeSceneManager = null

## Office场景容器节点
@onready var office_container: Node3D = $OfficeContainer

## 关卡配置
@export_group("Level Settings")
@export var base_time: float = 20.0  ## 第一关时间（秒）
@export var base_enemy_count: int = 4  ## 第一关敌人数量
@export var base_hostage_count: int = 1  ## 第一关人质数量
@export var base_hint_time: float = 3.0  ## 基础射击提示时间（秒）
@export var base_hint_interval: float = 1.0  ## 基础射击提示间隔（秒）

## 生成区域节点配置（通过场景中的节点定义区域）- 保留用于后备
@export_group("Spawn Areas (Legacy)")
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
var _spawning_hints: bool = false  ## 是否正在生成射击提示

## 难度曲线变量（用于遗留代码兼容）
var time_curve: Curve = null
var enemy_curve: Curve = null
var cover_curve: Curve = null
var base_cover_count: int = 2
var hostage_count: int = 1  ## 人质数量（遗留代码兼容）

## 射击提示场景
var shooting_hint_scene: PackedScene = preload("res://assets/vfx/ShootingHint.tscn")


func _ready() -> void:
	# 添加到 main_level 组，方便其他节点查找
	add_to_group("main_level")
	
	# 初始化OfficeSceneManager
	office_scene_manager = OfficeSceneManager.new()
	add_child(office_scene_manager)
	
	# 确保office_container存在
	if not office_container:
		office_container = Node3D.new()
		office_container.name = "OfficeContainer"
		add_child(office_container)
		office_container.global_position = Vector3(0, 0, -15)  # 与原OfficeV3位置一致
	
	# 移除静态的OfficeV3场景（如果存在）
	var static_office := get_node_or_null("OfficeV3")
	if static_office:
		static_office.queue_free()
	
	# 获取 SpawnArea 节点引用（保留用于兼容）
	if enemy_spawn_area_path:
		enemy_spawn_area = get_node_or_null(enemy_spawn_area_path) as SpawnArea
	if hostage_spawn_area_path:
		hostage_spawn_area = get_node_or_null(hostage_spawn_area_path) as SpawnArea
	if door_avoid_area_path:
		door_avoid_area = get_node_or_null(door_avoid_area_path) as SpawnArea
	
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
	
	# 隐藏所有UI
	if start_ui:
		start_ui.visible = false
	if game_over_ui:
		game_over_ui.visible = false
	
	# 首次启动显示标题界面
	if title_screen:
		title_screen.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # 使用准心模式
		GameManager.set_state(GameManager.GameState.START)
		_start_blink_animation()
		# 显示HUD以显示准心
		if hud:
			hud.visible = true


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


func _input(event: InputEvent) -> void:
	# 标题界面：射击开始游戏
	if not _title_shown and title_screen and title_screen.visible:
		if event.is_action_pressed("fire"):
			_dismiss_title_and_start()
			get_viewport().set_input_as_handled()
			return


func _unhandled_input(event: InputEvent) -> void:
	# 游戏结束界面：点击任意位置重新开始
	if _can_click_restart and GameManager.current_state == GameManager.GameState.GAME_OVER:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_restart_button_pressed()
			get_viewport().set_input_as_handled()


## 关闭标题界面并开始游戏
func _dismiss_title_and_start() -> void:
	_title_shown = true
	
	# 停止闪烁动画
	_stop_blink_animation()
	
	# 播放开始游戏音效并等待播放完成
	var audio_player := AudioManager.play_sfx_and_wait("game_start")
	if audio_player:
		await audio_player.finished
	
	if title_screen:
		title_screen.visible = false
	_start_game()


## 开始游戏
func _start_game() -> void:
	if hud:
		hud.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# 开始播放BGM（随机循环）
	AudioManager.start_bgm_loop()
	
	_respawn_enemies()
	GameManager.set_state(GameManager.GameState.PLAYING)


## 开始 FIRE TO START 闪烁动画
func _start_blink_animation() -> void:
	if not fire_to_start:
		return
	
	# 停止现有动画
	if _blink_tween and _blink_tween.is_valid():
		_blink_tween.kill()
	
	# 创建循环闪烁动画
	_blink_tween = create_tween().set_loops()
	_blink_tween.tween_property(fire_to_start, "modulate:a", 0.3, 0.5).set_ease(Tween.EASE_IN_OUT)
	_blink_tween.tween_property(fire_to_start, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_IN_OUT)


## 停止 FIRE TO START 闪烁动画
func _stop_blink_animation() -> void:
	if _blink_tween and _blink_tween.is_valid():
		_blink_tween.kill()
		_blink_tween = null
	
	# 恢复完全不透明
	if fire_to_start:
		fire_to_start.modulate.a = 1.0
	await get_tree().create_timer(0.5).timeout
	if rail_system:
		rail_system.start_moving()


func _update_timer_display() -> void:
	# 倒计时已移除，此函数保留但不做任何操作
	pass


func _on_time_up() -> void:
	_trigger_game_over()


## 触发游戏失败（射击提示变红或杀死人质）
func _trigger_game_over() -> void:
	# 防止重复触发
	if GameManager.current_state == GameManager.GameState.GAME_OVER:
		return
	
	GameManager.set_state(GameManager.GameState.GAME_OVER)
	
	# 停止BGM
	AudioManager.stop_bgm()
	
	# 播放游戏结束音效
	AudioManager.play_sfx("game_over")
	
	# 禁用玩家控制
	if player:
		player.disable_control()
	
	# 清除所有射击提示
	_clear_shooting_hints()
	
	# 快速调暗场景灯光
	_dim_scene_lights()
	
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
	
	# 播放上弹音效
	AudioManager.play_sfx("reload")
	
	await get_tree().create_timer(0.7).timeout  # 等待0.7秒
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
	
	# 设置标志为正在生成
	_spawning_hints = true
	
	# 收集所有敌人
	var enemies: Array[Node] = []
	if entities:
		for child in entities.get_children():
			if child is Enemy:
				enemies.append(child)
	
	if enemies.is_empty():
		_spawning_hints = false
		return
	
	# 随机打乱敌人顺序
	enemies.shuffle()
	
	# 逐个生成射击提示
	for i in range(enemies.size()):
		# 检查是否应该停止生成
		if not _spawning_hints:
			return
		
	# 等待随机间隔（根据难度曲线动态调整）
		if i > 0:
			var hint_interval := base_hint_interval
			if office_scene_manager:
				hint_interval = office_scene_manager.get_hint_interval(base_hint_interval, current_room)
			var delay := randf_range(hint_interval * 0.5, hint_interval)
			await get_tree().create_timer(delay).timeout
			
			# 再次检查，因为wait之后可能已经停止
			if not _spawning_hints:
				return
		
		# 检查敌人是否仍然有效
		if not is_instance_valid(enemies[i]):
			continue
		
		var enemy: Enemy = enemies[i]
		
		# 在敌人头部锚点位置生成射击提示
		var hint := shooting_hint_scene.instantiate() as Node3D
		add_child(hint)
		hint.global_position = enemy.get_head_position()
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
		
		# 获取当前关卡的提示时间
		var hint_time := base_hint_time
		if office_scene_manager:
			hint_time = office_scene_manager.get_hint_time(base_hint_time, current_room)
		
		# 创建缩放动画：从2倍缩放到1倍，持续时间根据难度动态调整
		var tween := create_tween()
		tween.tween_property(hint, "scale", Vector3(1.0, 1.0, 1.0), hint_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		
		# 从绿色渐变到红色，变红后触发游戏失败
		_animate_hint_color(hint, enemy, hint_time)
		
		# 连接敌人死亡信号，敌人死亡时移除对应的射击提示
		if not enemy.died.is_connected(_on_enemy_died_remove_hint.bind(hint)):
			enemy.died.connect(_on_enemy_died_remove_hint.bind(hint))


## 敌人死亡时移除对应的射击提示
func _on_enemy_died_remove_hint(hint: Node3D) -> void:
	if is_instance_valid(hint):
		shooting_hints.erase(hint)
		hint_to_enemy.erase(hint)
		hint.queue_free()


## 清除所有射击提示
func _clear_shooting_hints() -> void:
	# 停止正在进行的生成
	_spawning_hints = false
	
	for hint in shooting_hints:
		if is_instance_valid(hint):
			hint.queue_free()
	shooting_hints.clear()
	hint_to_enemy.clear()


## 调暗场景灯光（游戏结束时）
func _dim_scene_lights() -> void:
	if not world_environment or not world_environment.environment:
		return
	
	var env := world_environment.environment
	
	# 调暗天空背景亮度
	if env.background_mode == Environment.BG_SKY and env.sky:
		var tween := create_tween()
		tween.tween_property(env, "background_energy_multiplier", 0.5, 0.5)


## 恢复场景灯光（重启游戏时）
func _restore_scene_lights() -> void:
	if not world_environment or not world_environment.environment:
		return
	
	var env := world_environment.environment
	
	# 恢复天空背景亮度
	if env.background_mode == Environment.BG_SKY and env.sky:
		var tween := create_tween()
		tween.tween_property(env, "background_energy_multiplier", 1.0, 0.3)


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
	
	# 调试：打印鼠标位置和视口大小
	print("[DEBUG] Mouse: %s, Viewport: %s" % [screen_pos, viewport_size])
	
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
			
			# 计算射击提示在屏幕上的半径
			var distance_to_cam := cam.global_position.distance_to(hint_world_pos)
			
			# ShootingHint 的 pixel_size = 0.01，纹理约 64 像素，世界尺寸约 0.64 米
			# 半径 = 0.32 米 * 缩放（动画从2到1）
			var world_radius: float = 0.32 * hint.scale.x
			
			# 使用透视投影公式计算屏幕半径
			var fov_rad := deg_to_rad(cam.fov)
			var projected_radius: float = (world_radius / maxf(distance_to_cam, 0.1)) * (viewport_size.y * 0.5) / tan(fov_rad * 0.5)
			
			# 无额外容差，判定区域与视觉提示一致
			var screen_radius: float = projected_radius * 1.0
			screen_radius = clampf(screen_radius, 50.0, 300.0)  # 最小50像素，更严格的判定
			
			# 检查鼠标是否在范围内
			var dist_to_hint := screen_pos.distance_to(hint_screen_pos)
			
			# 调试：打印每个提示的位置和判定信息
			print("[DEBUG] Hint at screen: %s, dist: %.1f, radius: %.1f, hit: %s" % [hint_screen_pos, dist_to_hint, screen_radius, dist_to_hint <= screen_radius])
			
			if dist_to_hint <= screen_radius and dist_to_hint < closest_dist:
				closest_dist = dist_to_hint
				closest_enemy = enemy
	
	return closest_enemy


## 计算击杀得分
## 规则：
## - 如果射击提示没出来就杀死敌人 = 200分（快速击杀奖励）
## - 如果射击提示已出来，距离中心越近得分越高，最多200分，最少50分
## screen_pos: 屏幕坐标（鼠标位置）
## cam: 用于投影的相机
## enemy: 被击杀的敌人
## 返回: 击杀得分
func calculate_kill_score(screen_pos: Vector2, cam: Camera3D, enemy: Enemy) -> int:
	if not cam or not enemy or not is_instance_valid(enemy):
		return 100  # 默认分数
	
	# 查找该敌人对应的射击提示
	var hint: Node3D = null
	for h in shooting_hints:
		if is_instance_valid(h) and hint_to_enemy.get(h) == enemy:
			hint = h
			break
	
	# 如果没有射击提示（快速击杀），给予最高分数200分
	if hint == null:
		return 200
	
	# 射击提示已存在，根据距离中心计算分数
	var viewport_size := cam.get_viewport().get_visible_rect().size
	var hint_world_pos: Vector3 = hint.global_position
	
	# 检查是否在相机前方
	if cam.is_position_behind(hint_world_pos):
		return 100  # 后方敌人默认分数
	
	# 投影到屏幕坐标
	var hint_screen_pos := cam.unproject_position(hint_world_pos)
	
	# 计算屏幕上的击中距离
	var dist_to_center := screen_pos.distance_to(hint_screen_pos)
	
	# 计算判定半径（与 check_shooting_hint_hit 保持一致）
	var distance_to_cam := cam.global_position.distance_to(hint_world_pos)
	var world_radius: float = 0.32 * hint.scale.x
	var fov_rad := deg_to_rad(cam.fov)
	var projected_radius: float = (world_radius / maxf(distance_to_cam, 0.1)) * (viewport_size.y * 0.5) / tan(fov_rad * 0.5)
	var screen_radius: float = projected_radius * 1.0
	screen_radius = clampf(screen_radius, 50.0, 300.0)
	
	# 计算分数：距离越近分数越高
	# 中心 = 200分，边缘 = 50分
	var distance_ratio := clampf(dist_to_center / screen_radius, 0.0, 1.0)
	var score := int(lerpf(200.0, 50.0, distance_ratio))
	
	return score


## 从绿色渐变到红色，变红后触发游戏失败
func _animate_hint_color(hint: Node3D, enemy: Enemy, hint_time: float = 2.0) -> void:
	if not hint is Sprite3D:
		return
	
	var sprite := hint as Sprite3D
	if not sprite.material_override or not sprite.material_override is StandardMaterial3D:
		return
	
	var mat := sprite.material_override as StandardMaterial3D
	
	# 创建颜色渐变动画：根据难度动态调整时间，从绿色变红色
	var color_tween := create_tween()
	color_tween.tween_property(mat, "albedo_color", Color(1.0, 0.3, 0.3, 0.9), hint_time).set_ease(Tween.EASE_IN)
	
	# 时间到后检查并触发游戏失败
	await get_tree().create_timer(hint_time).timeout
	
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
		
		# 延迟0.5秒后播放房间通关音效
		await get_tree().create_timer(0.5).timeout
		AudioManager.play_sfx("room_clear")
		
		# 再等待0.5秒后移动到路径点3
		await get_tree().create_timer(0.5).timeout
		if rail_system:
			rail_system.continue_to_waypoint3()


## 人质被杀时触发游戏失败
func _on_hostage_died() -> void:
	_trigger_game_over()


## 关联的敌人被击杀时，人质也消失（被救出）
func _on_linked_enemy_died(hostage: Hostage) -> void:
	if is_instance_valid(hostage):
		# 人质被救出：变成绿色安全材质，0.5秒后消失
		hostage.set_safe_material()
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
	
	# 清除现有掩体（不再使用）
	if covers_container:
		for child in covers_container.get_children():
			child.queue_free()
	cover_positions.clear()
	
	# 清除射击提示
	_clear_shooting_hints()
	
	# 等待一帧确保节点被清除
	await get_tree().process_frame
	
	# 根据当前房间难度加载Office场景
	if office_scene_manager and office_container:
		office_scene_manager.load_office_by_difficulty(office_container, current_room)
	
	# 等待一帧确保场景加载完成
	await get_tree().process_frame
	
	# 从Office场景的SpawnPoints生成敌人和人质
	_spawn_from_office_scene()


## 从当前Office场景的SpawnPoints生成敌人和人质
func _spawn_from_office_scene() -> void:
	if not office_scene_manager:
		push_warning("[MainLevel] OfficeSceneManager not initialized!")
		return
	
	var enemy_scene := preload("res://src/entities/Enemy.tscn")
	var hostage_scene := preload("res://src/entities/Hostage.tscn")
	
	# 获取激活的敌人SpawnPoints
	var enemy_spawns := office_scene_manager.get_active_enemy_spawns(base_enemy_count, current_room)
	var hostage_spawns := office_scene_manager.get_active_hostage_spawns(base_hostage_count, current_room)
	
	var spawned_enemies: Array[Enemy] = []
	
	# 生成敌人
	for spawn_point in enemy_spawns:
		var enemy: Enemy = enemy_scene.instantiate()
		entities.add_child(enemy)
		
		# 使用SpawnPoint的位置（需要转换到世界坐标）
		enemy.global_position = spawn_point.global_position
		
		# 使用SpawnPoint的朝向
		if front_door:
			enemy.look_at_target(front_door.global_position)
		else:
			var rotation_y := spawn_point.get_facing_rotation_y()
			enemy.rotation.y = rotation_y
		
		enemy.died.connect(_on_enemy_died)
		spawned_enemies.append(enemy)
	
	# 生成人质
	var enemy_index := 0
	for spawn_point in hostage_spawns:
		var hostage: Hostage = hostage_scene.instantiate()
		entities.add_child(hostage)
		
		# 使用SpawnPoint的位置
		hostage.global_position = spawn_point.global_position
		hostage.died.connect(_on_hostage_died)
		
		# 关联一个敌人（循环使用）
		if not spawned_enemies.is_empty():
			var linked_enemy := spawned_enemies[enemy_index % spawned_enemies.size()]
			if is_instance_valid(linked_enemy):
				linked_enemy.has_linked_hostage = true
				linked_enemy.died.connect(_on_linked_enemy_died.bind(hostage))
			enemy_index += 1
	
	enemies_alive = enemy_spawns.size()
	print("[MainLevel] Spawned %d enemies and %d hostages" % [enemy_spawns.size(), hostage_spawns.size()])


## 旧的敌人生成逻辑（保留用于回退）
func _respawn_enemies_legacy() -> void:
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
	
	if enemy_spawn_area:
		var x_range := enemy_spawn_area.get_x_range()
		var z_range := enemy_spawn_area.get_z_range()
		spawn_x_min = x_range.x
		spawn_x_max = x_range.y
		enemy_z_min = z_range.x
		enemy_z_max = z_range.y
		min_spacing = enemy_spawn_area.min_spacing
	
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
			linked_enemy.has_linked_hostage = true
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
	if hud:
		hud.visible = true
	
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
	
	# 将鼠标移动到屏幕中心，确保可见
	var viewport_size := get_viewport().get_visible_rect().size
	get_viewport().warp_mouse(viewport_size / 2)
	
	# 隐藏原有2D结算界面
	if game_over_ui:
		game_over_ui.visible = false
	if hud:
		hud.visible = false
	
	# 创建3D结算界面
	if game_over_screen_3d:
		game_over_screen_3d.queue_free()
	
	game_over_screen_3d = game_over_screen_3d_scene.instantiate()
	
	# 将界面添加到玩家摄像机前方
	if player and player.camera:
		player.camera.add_child(game_over_screen_3d)
		game_over_screen_3d.position = Vector3(0, 0, -2)  # 在摄像机前方2米
	else:
		add_child(game_over_screen_3d)
	
	# 连接信号
	game_over_screen_3d.restart_requested.connect(_on_game_over_3d_restart)
	
	# 显示排行榜
	game_over_screen_3d.show_leaderboard(GameManager.score)


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
	# 防止重复触发
	if not _can_click_restart and GameManager.current_state != GameManager.GameState.GAME_OVER:
		return
	
	# 立即禁用点击重启，防止重复触发
	_can_click_restart = false
	
	# 隐藏/销毁结算界面
	if game_over_ui:
		game_over_ui.visible = false
	if game_over_screen_3d:
		game_over_screen_3d.queue_free()
		game_over_screen_3d = null
	
	# 恢复场景灯光
	_restore_scene_lights()
	
	# 重置游戏状态
	GameManager.reset_stats()
	
	# 重置关卡
	current_room = 1
	timer_active = false
	time_remaining = 0.0
	
	# 重置 HUD 显示
	if hud:
		hud.visible = true
	
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
	
	# 重新开始播放BGM
	AudioManager.start_bgm_loop()
	
	GameManager.set_state(GameManager.GameState.PLAYING)
	# 开始从起点移动到路径点1
	if rail_system:
		rail_system.start_moving()


## ==================== 排行榜相关函数 ====================

## 当前玩家是否进入排行榜
var _player_rank: int = -1
## 当前玩家是否已提交名字
var _name_submitted: bool = false
## 重启延迟时间（秒）
const RESTART_DELAY: float = 2.0


## 延迟后启用点击重启
func _start_restart_delay() -> void:
	await get_tree().create_timer(RESTART_DELAY).timeout
	# 确保仍在游戏结束状态
	if GameManager.current_state == GameManager.GameState.GAME_OVER:
		_can_click_restart = true
		if click_hint:
			click_hint.visible = true


## 刷新排行榜显示，如果进入排行榜则在对应位置显示名字输入框
func _refresh_leaderboard_with_input() -> void:
	_clear_leaderboard_display()
	_name_submitted = false
	_can_click_restart = false
	
	if not leaderboard_container:
		return
	
	var leaderboard := LeaderboardManager.get_leaderboard()
	var is_high_score := LeaderboardManager.is_high_score(GameManager.score)
	
	# 确定玩家排名位置
	_player_rank = -1
	if is_high_score:
		for i in range(leaderboard.size()):
			if GameManager.score > leaderboard[i]["score"]:
				_player_rank = i
				break
		if _player_rank == -1 and leaderboard.size() < LeaderboardManager.MAX_ENTRIES:
			_player_rank = leaderboard.size()
	
	# 更新标题
	if leaderboard_title:
		if is_high_score:
			leaderboard_title.text = "NEW HIGH SCORE!"
			leaderboard_title.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3, 1))
		else:
			leaderboard_title.text = "HIGH SCORES"
			leaderboard_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1))
	
	# 隐藏单独的名字输入容器（使用内联输入）
	if name_input_container:
		name_input_container.visible = false
	
	# 显示/隐藏点击提示
	if click_hint:
		if is_high_score:
			# 进入排行榜，等待输入名字后才能点击重启
			click_hint.visible = false
			_can_click_restart = false
		else:
			# 没有进入排行榜，延迟2秒后才能点击重启
			click_hint.visible = false
			_can_click_restart = false
			_start_restart_delay()
	
	# 生成排行榜行
	for i in range(LeaderboardManager.MAX_ENTRIES):
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		# 如果是玩家排名位置且未提交，显示输入框
		if i == _player_rank and is_high_score:
			_create_input_row(row, i + 1, GameManager.score)
			leaderboard_container.add_child(row)
			continue
		
		# 计算实际数据索引
		var actual_index := i
		if _player_rank >= 0 and i > _player_rank:
			actual_index = i - 1  # 玩家位置之后的数据往前移一位
		
		_create_score_row(row, i + 1, leaderboard, actual_index)
		leaderboard_container.add_child(row)


## 创建带名字输入框的行（无按钮，只用回车确认）
func _create_input_row(row: HBoxContainer, rank: int, score: int) -> void:
	# 排名
	var rank_label := Label.new()
	rank_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rank_label.custom_minimum_size = Vector2(50, 0)
	rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	rank_label.add_theme_font_size_override("font_size", 32)
	rank_label.add_theme_constant_override("outline_size", 2)
	rank_label.add_theme_color_override("font_outline_color", Color.BLACK)
	rank_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3, 1))
	rank_label.text = "%d." % rank
	
	# 名字输入框
	var input := LineEdit.new()
	input.custom_minimum_size = Vector2(200, 0)
	input.add_theme_font_size_override("font_size", 32)
	input.max_length = 5
	input.placeholder_text = "NAME"
	input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	input.caret_blink = true
	input.text_submitted.connect(_on_inline_name_submitted)
	# 保存引用用于提交
	input.set_meta("rank", rank)
	
	# 分数
	var score_lbl := Label.new()
	score_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	score_lbl.custom_minimum_size = Vector2(100, 0)
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_lbl.add_theme_font_size_override("font_size", 32)
	score_lbl.add_theme_constant_override("outline_size", 2)
	score_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	score_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3, 1))
	score_lbl.text = str(score)
	
	row.add_child(rank_label)
	row.add_child(input)
	row.add_child(score_lbl)
	
	# 延迟获取焦点
	input.call_deferred("grab_focus")


## 创建普通分数行
func _create_score_row(row: HBoxContainer, rank: int, leaderboard: Array, data_index: int) -> void:
	# 排名
	var rank_label := Label.new()
	rank_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rank_label.custom_minimum_size = Vector2(50, 0)
	rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	rank_label.add_theme_font_size_override("font_size", 32)
	rank_label.add_theme_constant_override("outline_size", 2)
	rank_label.add_theme_color_override("font_outline_color", Color.BLACK)
	
	# 名字
	var name_label := Label.new()
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.custom_minimum_size = Vector2(140, 0)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 32)
	name_label.add_theme_constant_override("outline_size", 2)
	name_label.add_theme_color_override("font_outline_color", Color.BLACK)
	
	# 占位（与按钮对齐）
	var spacer := Control.new()
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spacer.custom_minimum_size = Vector2(60, 0)
	
	# 分数
	var score_lbl := Label.new()
	score_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	score_lbl.custom_minimum_size = Vector2(100, 0)
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_lbl.add_theme_font_size_override("font_size", 32)
	score_lbl.add_theme_constant_override("outline_size", 2)
	score_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	
	if data_index >= 0 and data_index < leaderboard.size():
		var entry: Dictionary = leaderboard[data_index]
		rank_label.text = "%d." % rank
		name_label.text = entry["name"]
		score_lbl.text = str(entry["score"])
	else:
		rank_label.text = "%d." % rank
		name_label.text = "---"
		score_lbl.text = "---"
		rank_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
		name_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
		score_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
	
	row.add_child(rank_label)
	row.add_child(name_label)
	row.add_child(spacer)
	row.add_child(score_lbl)


## 内联名字输入框回车提交
func _on_inline_name_submitted(text: String) -> void:
	_submit_inline_name(text)


## 内联确认按钮点击
func _on_inline_confirm_pressed(input: LineEdit) -> void:
	_submit_inline_name(input.text)


## 提交内联名字
func _submit_inline_name(text: String) -> void:
	if _name_submitted:
		return
	_name_submitted = true
	
	var player_name := text.strip_edges()
	
	# 过滤非法字符
	if not LeaderboardManager.is_valid_name(player_name):
		player_name = "ANON"
	
	# 添加到排行榜
	LeaderboardManager.add_entry(player_name, GameManager.score)
	
	# 刷新排行榜显示（不再显示输入框）
	_show_final_leaderboard()


## 显示最终排行榜（提交名字后）
func _show_final_leaderboard() -> void:
	_clear_leaderboard_display()
	
	if not leaderboard_container:
		return
	
	var leaderboard := LeaderboardManager.get_leaderboard()
	
	if leaderboard_title:
		leaderboard_title.text = "HIGH SCORES"
		leaderboard_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1))
	
	# 显示点击提示，启用点击重启
	if click_hint:
		click_hint.visible = true
	_can_click_restart = true
	
	for i in range(LeaderboardManager.MAX_ENTRIES):
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_create_score_row(row, i + 1, leaderboard, i)
		
		# 高亮玩家的记录
		if i < leaderboard.size() and leaderboard[i]["score"] == GameManager.score:
			for child in row.get_children():
				if child is Label:
					child.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3, 1))
		
		leaderboard_container.add_child(row)


## 清空排行榜显示
func _clear_leaderboard_display() -> void:
	if not leaderboard_container:
		return
	for child in leaderboard_container.get_children():
		child.queue_free()


## 名字确认按钮回调（保留兼容）
func _on_name_confirm_button_pressed() -> void:
	pass


## 名字输入框回车提交回调（保留兼容）
func _on_name_input_submitted(_text: String) -> void:
	pass


## 3D结算界面重启回调
func _on_game_over_3d_restart() -> void:
	_on_restart_button_pressed()
