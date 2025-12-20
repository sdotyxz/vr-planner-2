extends Node3D
class_name MainLevel
## 主关卡 - 轨道移动到门口 -> 开门 -> 射击 -> 清除敌人 -> 下一关

@onready var rail_system: RailSystem = $RailSystem
@onready var door: Door = $Door
@onready var entities: Node3D = $Entities
@onready var player: Player = $Player
@onready var hud: HUD = $UI/HUD

var enemies_alive: int = 0
var current_room: int = 1


func _ready() -> void:
	# 连接信号
	if rail_system:
		rail_system.reached_door.connect(_on_reached_door)
		rail_system.reached_end.connect(_on_reached_end)
	
	if door:
		door.door_opened.connect(_on_door_opened)
	
	# 统计敌人数量
	_count_enemies()
	
	# 开始游戏 - 玩家沿轨道移动
	GameManager.set_state(GameManager.GameState.PLAYING)
	if rail_system:
		rail_system.start_moving()


func _process(_delta: float) -> void:
	# 手动同步玩家位置到轨道
	if player and rail_system:
		var path_follow = rail_system.get_node_or_null("PathFollow3D")
		if path_follow:
			player.global_position = path_follow.global_position


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
	# 穿过门后，进入射击阶段
	GameManager.set_state(GameManager.GameState.PLAYING)


func _on_enemy_died() -> void:
	enemies_alive -= 1
	
	if enemies_alive <= 0:
		# 所有敌人被消灭，进入下一关
		_start_next_room()


func _start_next_room() -> void:
	current_room += 1
	GameManager.rooms_cleared += 1
	
	# 重置轨道位置
	if rail_system:
		rail_system.reset_position()
	
	# 重置门
	if door:
		door.is_open = false
		var left := door.get_node_or_null("LeftDoor") as MeshInstance3D
		var right := door.get_node_or_null("RightDoor") as MeshInstance3D
		if left:
			left.rotation_degrees.y = 0
		if right:
			right.rotation_degrees.y = 0
	
	# 重新生成敌人
	_respawn_enemies()
	
	# 开始移动
	await get_tree().create_timer(0.5).timeout
	if rail_system:
		rail_system.start_moving()


func _respawn_enemies() -> void:
	if not entities:
		return
	
	# 重新激活/生成敌人
	for child in entities.get_children():
		if child is Enemy:
			child.queue_free()
	
	# 生成新敌人（随机位置）
	var enemy_scene := preload("res://src/entities/Enemy.tscn")
	var spawn_positions := [
		Vector3(-2, 1, -12),
		Vector3(3, 1, -15),
		Vector3(-1, 1, -20),
		Vector3(2, 1, -25),
	]
	
	for pos in spawn_positions:
		var enemy: Enemy = enemy_scene.instantiate()
		entities.add_child(enemy)
		enemy.global_position = pos
		enemy.died.connect(_on_enemy_died)
	
	enemies_alive = spawn_positions.size()
