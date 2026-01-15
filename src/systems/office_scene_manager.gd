extends Node
class_name OfficeSceneManager
## Office场景管理器 - 负责随机加载不同的Office场景并提取SpawnPoints

## Office场景路径列表 (所有场景，用于预加载)
const OFFICE_SCENES: Array[String] = [
	"res://src/levels/office_v3.tscn",
	"res://src/levels/office_v4.tscn",
	"res://src/levels/office_v5.tscn",
	"res://src/levels/office_v6.tscn",
	"res://src/levels/office_v7.tscn",
	"res://src/levels/office_v8.tscn",
	"res://src/levels/office_v9.tscn",
	"res://src/levels/office_v10.tscn",
	"res://src/levels/office_v11.tscn",
	"res://src/levels/office_v12.tscn",
	"res://src/levels/office_v13.tscn",
	"res://src/levels/office_v14.tscn",
]

## 按难度分组的场景路径
const SCENE_GROUPS: Dictionary = {
	"easy": [
		"res://src/levels/office_v3.tscn",
		"res://src/levels/office_v7.tscn",
		"res://src/levels/office_v11.tscn",
	],
	"medium": [
		"res://src/levels/office_v4.tscn",
		"res://src/levels/office_v8.tscn",
		"res://src/levels/office_v12.tscn",
	],
	"hard": [
		"res://src/levels/office_v5.tscn",
		"res://src/levels/office_v9.tscn",
		"res://src/levels/office_v13.tscn",
	],
	"expert": [
		"res://src/levels/office_v6.tscn",
		"res://src/levels/office_v10.tscn",
		"res://src/levels/office_v14.tscn",
	],
}

## 当前加载的Office场景实例
var current_office_scene: Node3D = null

## 上一次加载的场景路径（用于去重）
var last_scene_path: String = ""

## 难度曲线配置
var difficulty_curves: DifficultyCurves = null

## 预加载的场景资源缓存
var _scene_cache: Dictionary = {}


func _ready() -> void:
	# 预加载所有Office场景
	for path in OFFICE_SCENES:
		_scene_cache[path] = load(path)
	
	# 加载难度曲线
	var curves_path := "res://src/levels/difficulty_curves.tres"
	if ResourceLoader.exists(curves_path):
		difficulty_curves = load(curves_path) as DifficultyCurves
	else:
		difficulty_curves = DifficultyCurves.create_default()


## 随机选择并加载一个Office场景（支持去重，后备方法）
## parent: 父节点，场景将作为其子节点添加
## 返回: 新加载的场景实例
func load_random_office(parent: Node3D) -> Node3D:
	# 卸载当前场景
	if current_office_scene:
		current_office_scene.queue_free()
		current_office_scene = null
	
	# 随机选择一个不同的场景
	var available_scenes: Array[String] = []
	for path in OFFICE_SCENES:
		if path != last_scene_path:
			available_scenes.append(path)
	
	# 如果只有一个场景，允许重复
	if available_scenes.is_empty():
		available_scenes.append(OFFICE_SCENES[0])
	
	var scene_path: String = available_scenes.pick_random()
	last_scene_path = scene_path
	
	# 实例化场景
	var scene_resource: PackedScene = _scene_cache.get(scene_path)
	if not scene_resource:
		scene_resource = load(scene_path)
	
	current_office_scene = scene_resource.instantiate() as Node3D
	parent.add_child(current_office_scene)
	
	print("[OfficeSceneManager] Loaded office scene: ", scene_path)
	return current_office_scene


## 根据当前房间难度选择并加载Office场景
## parent: 父节点，场景将作为其子节点添加
## current_room: 当前房间号，用于计算难度
## 返回: 新加载的场景实例
func load_office_by_difficulty(parent: Node3D, current_room: int) -> Node3D:
	# 卸载当前场景
	if current_office_scene:
		current_office_scene.queue_free()
		current_office_scene = null
	
	# 根据进度确定难度组
	var progress := DifficultyCurves.calculate_progress(current_room)
	var group_key := _get_difficulty_group(progress)
	var group_scenes: Array = SCENE_GROUPS[group_key]
	
	# 从对应难度组中随机选择（支持去重）
	var available_scenes: Array[String] = []
	for path in group_scenes:
		if path != last_scene_path:
			available_scenes.append(path)
	
	# 如果组内只有一个场景或所有都被排除，允许重复
	if available_scenes.is_empty():
		available_scenes.append(group_scenes[0])
	
	var scene_path: String = available_scenes.pick_random()
	last_scene_path = scene_path
	
	# 实例化场景
	var scene_resource: PackedScene = _scene_cache.get(scene_path)
	if not scene_resource:
		scene_resource = load(scene_path)
	
	current_office_scene = scene_resource.instantiate() as Node3D
	parent.add_child(current_office_scene)
	
	print("[OfficeSceneManager] Loaded office scene (difficulty: %s, room: %d): %s" % [group_key, current_room, scene_path])
	return current_office_scene


## 根据进度获取难度组名称
func _get_difficulty_group(progress: float) -> String:
	if progress < 0.25:
		return "easy"
	elif progress < 0.5:
		return "medium"
	elif progress < 0.75:
		return "hard"
	else:
		return "expert"


## 获取当前场景中的所有敌人SpawnPoint
func get_enemy_spawn_points() -> Array[SpawnPoint]:
	return _get_spawn_points_by_type(SpawnPoint.SpawnType.ENEMY)


## 获取当前场景中的所有人质SpawnPoint
func get_hostage_spawn_points() -> Array[SpawnPoint]:
	return _get_spawn_points_by_type(SpawnPoint.SpawnType.HOSTAGE)


## 根据难度曲线获取需要激活的敌人SpawnPoint列表
## base_count: 基础敌人数量
## current_room: 当前房间号
## 返回: 随机选择的SpawnPoint列表
func get_active_enemy_spawns(base_count: int, current_room: int) -> Array[SpawnPoint]:
	var all_points := get_enemy_spawn_points()
	var target_count := base_count
	
	if difficulty_curves:
		target_count = difficulty_curves.get_enemy_count(base_count, current_room)
	
	return _select_random_points(all_points, target_count)


## 根据难度曲线获取需要激活的人质SpawnPoint列表
## base_count: 基础人质数量
## current_room: 当前房间号
## 返回: 随机选择的SpawnPoint列表
func get_active_hostage_spawns(base_count: int, current_room: int) -> Array[SpawnPoint]:
	var all_points := get_hostage_spawn_points()
	var target_count := base_count
	
	if difficulty_curves:
		target_count = difficulty_curves.get_hostage_count(base_count, current_room)
	
	return _select_random_points(all_points, target_count)


## 获取当前关卡的射击提示时间
func get_hint_time(base_time: float, current_room: int) -> float:
	if difficulty_curves:
		return difficulty_curves.get_hint_time(base_time, current_room)
	return base_time


## 内部方法：按类型获取SpawnPoints
func _get_spawn_points_by_type(spawn_type: SpawnPoint.SpawnType) -> Array[SpawnPoint]:
	var result: Array[SpawnPoint] = []
	
	if not current_office_scene:
		push_warning("[OfficeSceneManager] No office scene loaded!")
		return result
	
	# 查找 SpawnPoints 节点
	var spawn_points_node := current_office_scene.get_node_or_null("SpawnPoints")
	if not spawn_points_node:
		push_warning("[OfficeSceneManager] SpawnPoints node not found in office scene!")
		return result
	
	# 遍历所有子节点
	for child in spawn_points_node.get_children():
		if child is SpawnPoint and child.spawn_type == spawn_type:
			result.append(child as SpawnPoint)
	
	return result


## 内部方法：从列表中随机选择指定数量的点
func _select_random_points(points: Array[SpawnPoint], count: int) -> Array[SpawnPoint]:
	var result: Array[SpawnPoint] = []
	
	if points.is_empty():
		return result
	
	# 确保不超过可用点数
	count = mini(count, points.size())
	
	# 打乱顺序后取前N个
	var shuffled := points.duplicate()
	shuffled.shuffle()
	
	for i in range(count):
		result.append(shuffled[i])
	
	return result
