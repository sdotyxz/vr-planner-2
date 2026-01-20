extends Node3D
class_name Player
## 玩家控制器 - 第一人称视角和射击

@export var mouse_sensitivity: float = 0.003
@export var max_distance: float = 100.0

## 相机旋转限制配置
@export_group("Camera Limits")
@export var yaw_limit: float = 90.0  ## Yaw 限制角度（左右各一半）
@export var pitch_limit: float = 60.0  ## Pitch 限制角度（上下各一半）
@export var enable_yaw_limit: bool = true  ## 是否启用 Yaw 限制
@export var enable_pitch_limit: bool = true  ## 是否启用 Pitch 限制

## 相机视野配置
@export_group("Camera FOV")
@export_range(30.0, 120.0, 1.0) var camera_fov: float = 80.0  ## 相机视野角度

## 相机抖动配置
@export_group("Camera Shake")
@export var shake_intensity: float = 0.3  ## 踢门抖动强度
@export var shake_duration: float = 0.2  ## 踢门抖动持续时间
@export var shoot_shake_intensity: float = 0.08  ## 射击抖动强度
@export var shoot_shake_duration: float = 0.08  ## 射击抖动持续时间

@onready var camera: Camera3D = $Camera3D

var yaw: float = 0.0
var pitch: float = 0.0
var _initial_yaw: float = 0.0  # 记录初始朝向，用于 yaw 限制的中心点
var _shot_this_frame: bool = false
var can_control: bool = false  # 是否允许开火和转动视角
var shake_offset: Vector3 = Vector3.ZERO  # 相机抖动偏移


func _ready() -> void:
	print("Player: Ready")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# 添加到player组，方便其他节点查找
	add_to_group("player")
	
	# 设置相机 FOV
	if camera:
		camera.fov = camera_fov
	
	# 记录初始朝向作为 yaw 限制的中心点
	_initial_yaw = yaw
	
	# 连接全局输入处理器的鼠标移动信号
	var input_handler = get_node_or_null("/root/InputHandler")
	if input_handler:
		print("Player: Connected to InputHandler")
		input_handler.mouse_motion.connect(_on_mouse_motion)
	else:
		push_error("Player: InputHandler NOT FOUND at /root/InputHandler")


func _on_mouse_motion(relative: Vector2) -> void:
	if not can_control:
		return
	_rotate_camera(relative)


func _input(event: InputEvent) -> void:
	# 后备：直接处理鼠标移动
	if event is InputEventMouseMotion and can_control:
		_rotate_camera(event.relative)
		
	# ESC 释放鼠标
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _rotate_camera(relative: Vector2) -> void:
	yaw -= relative.x * mouse_sensitivity
	pitch -= relative.y * mouse_sensitivity
	
	# 应用 Yaw 限制（左右旋转）
	if enable_yaw_limit:
		var half_yaw := deg_to_rad(yaw_limit / 2.0)
		yaw = clampf(yaw, _initial_yaw - half_yaw, _initial_yaw + half_yaw)
	
	# 应用 Pitch 限制（上下旋转）
	if enable_pitch_limit:
		var half_pitch := deg_to_rad(pitch_limit / 2.0)
		pitch = clampf(pitch, -half_pitch, half_pitch)
	else:
		# 即使不限制也要防止翻转
		pitch = clampf(pitch, -deg_to_rad(89), deg_to_rad(89))


## 重置视角到初始状态
func reset_view() -> void:
	yaw = _initial_yaw
	pitch = 0.0


## 启用控制（开火和转动视角）
func enable_control() -> void:
	can_control = true


## 禁用控制
func disable_control() -> void:
	can_control = false


func _physics_process(_delta: float) -> void:
	# 摄像机跟随玩家位置（top_level=true 所以需要手动同步位置）
	if camera:
		camera.global_position = global_position + Vector3(0, 1.7, 0) + shake_offset
		# 固定视角，不随鼠标旋转
		# camera.global_rotation = Vector3(pitch, yaw, 0)
	
	# 游戏结束时不处理鼠标和射击
	if GameManager.current_state == GameManager.GameState.GAME_OVER:
		return
	
	# 确保点击时捕获鼠标（仅在游戏进行中）
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# 射击检测（仅在允许控制时）
	if can_control and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if not _shot_this_frame:
			_shot_this_frame = true
			_shoot()
	else:
		_shot_this_frame = false


func _shoot() -> void:
	# 音效
	AudioManager.play_sfx("fire")
	
	# 屏幕抖动（使用射击专用的较弱抖动）
	shake_camera(shoot_shake_intensity, shoot_shake_duration)
	
	# 准心后坐力动画
	var hud = get_tree().get_first_node_in_group("hud") as HUD
	if hud and hud.has_method("play_recoil"):
		hud.play_recoil()
	
	# 射线检测 - 使用鼠标位置而不是屏幕中心
	var space_state := get_world_3d().direct_space_state
	
	# 获取HUD的鼠标位置
	var mouse_pos: Vector2
	if hud and "mouse_position" in hud:
		mouse_pos = hud.mouse_position
	else:
		# 后备方案：使用屏幕中心
		mouse_pos = get_viewport().get_visible_rect().size / 2
	
	# 在相机前方生成枪口火焰（根据射击方向）
	var ray_dir := camera.project_ray_normal(mouse_pos)
	var muzzle_pos := camera.global_position + ray_dir * 0.5
	VFXManager.spawn_vfx("muzzle", muzzle_pos, ray_dir)
	
	# 优先检查是否点击在射击提示范围内
	var main_level = get_tree().get_first_node_in_group("main_level") as MainLevel
	if not main_level:
		main_level = get_parent() as MainLevel
	
	if main_level and main_level.has_method("check_shooting_hint_hit"):
		var hint_enemy: Enemy = main_level.check_shooting_hint_hit(mouse_pos, camera)
		if hint_enemy and is_instance_valid(hint_enemy):
			_hit_enemy(hint_enemy, hint_enemy.global_position, Vector3.UP)
			return
	
	# 如果没有命中射击提示，使用物理射线检测
	var from := camera.project_ray_origin(mouse_pos)
	var to := from + ray_dir * max_distance
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := space_state.intersect_ray(query)
	
	if result.is_empty():
		return
	
	var collider: Node3D = result.collider
	var hit_point: Vector3 = result.position
	var hit_normal: Vector3 = result.normal
	
	if collider.is_in_group("enemy"):
		_hit_enemy(collider, hit_point, hit_normal)
	elif collider.is_in_group("hostage"):
		_hit_hostage(collider)
	elif collider.is_in_group("destructible"):
		_hit_destructible(collider, hit_point)


func _hit_enemy(enemy: Node3D, _point: Vector3, _normal: Vector3) -> void:
	AudioManager.play_sfx("hit")
	
	# 获取鼠标位置用于计算分数
	var hud = get_tree().get_first_node_in_group("hud")
	var mouse_pos: Vector2
	if hud and "mouse_position" in hud:
		mouse_pos = hud.mouse_position
	else:
		mouse_pos = get_viewport().get_visible_rect().size / 2
	
	# 计算基础击杀分数（基于射击提示和精度）
	var base_score := 100
	var main_level = get_tree().get_first_node_in_group("main_level") as MainLevel
	if main_level and main_level.has_method("calculate_kill_score") and enemy is Enemy:
		base_score = main_level.calculate_kill_score(mouse_pos, camera, enemy as Enemy)
	
	# 带有人质的敌人额外+50分
	var bonus_score := 0
	if enemy is Enemy and enemy.has_linked_hostage:
		bonus_score = 50
	var total_score := base_score + bonus_score
	
	GameManager.add_score(total_score)
	GameManager.add_kill()
	
	# 在敌人位置生成浮动得分弹窗
	VFXManager.spawn_score_popup(enemy.global_position + Vector3(0, 1.5, 0), total_score)
	
	if enemy.has_method("die"):
		enemy.die()
	else:
		enemy.queue_free()


func _hit_hostage(hostage: Node3D) -> void:
	AudioManager.play_sfx("error")
	
	if hostage.has_method("hit"):
		hostage.hit()


## 命中可破坏家具
func _hit_destructible(furniture: Node3D, _hit_point: Vector3) -> void:
	if furniture.has_method("destroy"):
		furniture.destroy()


## 相机抖动效果
func shake_camera(intensity: float = -1.0, duration: float = -1.0) -> void:
	var shake_strength := intensity if intensity >= 0 else shake_intensity
	var shake_time := duration if duration >= 0 else shake_duration
	
	var tween := create_tween()
	tween.set_parallel(true)
	
	# 随机方向的抖动
	var shake_count := 8  # 抖动次数
	var time_per_shake := shake_time / float(shake_count)
	
	for i in range(shake_count):
		var progress := float(i) / float(shake_count)
		var current_intensity := shake_strength * (1.0 - progress)  # 逐渐减弱
		
		var random_offset := Vector3(
			randf_range(-current_intensity, current_intensity),
			randf_range(-current_intensity, current_intensity),
			randf_range(-current_intensity, current_intensity)
		)
		
		tween.tween_property(self, "shake_offset", random_offset, time_per_shake).set_delay(time_per_shake * i)
	
	# 最后回到0
	tween.tween_property(self, "shake_offset", Vector3.ZERO, time_per_shake * 0.5).set_delay(shake_time)
