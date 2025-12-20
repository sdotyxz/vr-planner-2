extends Node3D
class_name Player
## 玩家控制器 - 第一人称视角和射击

@export var mouse_sensitivity: float = 0.003
@export var max_distance: float = 100.0

@onready var camera: Camera3D = $Camera3D

var yaw: float = 0.0
var pitch: float = 0.0
var _shot_this_frame: bool = false


func _ready() -> void:
	print("Player: Ready")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# 连接全局输入处理器的鼠标移动信号
	var input_handler = get_node_or_null("/root/InputHandler")
	if input_handler:
		print("Player: Connected to InputHandler")
		input_handler.mouse_motion.connect(_on_mouse_motion)
	else:
		push_error("Player: InputHandler NOT FOUND at /root/InputHandler")


func _on_mouse_motion(relative: Vector2) -> void:
	# print("Player: Motion received ", relative)
	_rotate_camera(relative)


func _input(event: InputEvent) -> void:
	# 后备：直接处理鼠标移动
	if event is InputEventMouseMotion:
		# print("Player: Direct input motion ", event.relative)
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
	pitch = clampf(pitch, -deg_to_rad(89), deg_to_rad(89))


func _physics_process(_delta: float) -> void:
	# 摄像机跟随玩家位置（top_level=true 所以需要手动同步位置）
	if camera:
		camera.global_position = global_position + Vector3(0, 1.7, 0)
		# 使用 global_rotation 确保绝对旋转，不受父节点影响
		camera.global_rotation = Vector3(pitch, yaw, 0)
	
	# 确保点击时捕获鼠标
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# 射击检测
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if not _shot_this_frame:
			_shot_this_frame = true
			_shoot()
	else:
		_shot_this_frame = false


func _shoot() -> void:
	# 音效和枪口火焰
	AudioManager.play_sfx("fire")
	var muzzle_pos := camera.global_position - camera.global_transform.basis.z * 0.5 + camera.global_transform.basis.x * 0.2
	VFXManager.spawn_vfx("muzzle", muzzle_pos, -camera.global_transform.basis.z)
	
	# 射线检测
	var space_state := get_world_3d().direct_space_state
	var from := camera.global_position
	var to := from - camera.global_transform.basis.z * max_distance
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


func _hit_enemy(enemy: Node3D, point: Vector3, normal: Vector3) -> void:
	AudioManager.play_sfx("hit")
	VFXManager.spawn_vfx("blood", point, normal)
	GameManager.add_score(100)
	GameManager.add_kill()
	
	if enemy.has_method("die"):
		enemy.die()
	else:
		enemy.queue_free()


func _hit_hostage(hostage: Node3D) -> void:
	GameManager.add_score(-500)
	AudioManager.play_sfx("error")
	
	if hostage.has_method("hit"):
		hostage.hit()
