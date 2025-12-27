extends Path3D
class_name RailSystem
## 轨道系统 - 控制玩家沿路径自动移动

@export var speed: float = 5.0
@export var waypoint1_index: int = 1  # 路径点1（门前停留点）
@export var waypoint2_index: int = 2  # 路径点2（门后停留点，射击位置）
@export var waypoint3_index: int = 3  # 路径点3（最后一个点，准备传送回路径点1）
@export var proximity_threshold: float = 0.1  # 到达点位的判定距离
@export var is_moving: bool = false

@onready var path_follow: PathFollow3D = $PathFollow3D

# 轨道阶段
enum Stage {
	TO_WAYPOINT1,       # 移动到路径点1（门前）
	WAIT_AT_WAYPOINT1,  # 在路径点1停留
	PASS_DOOR,          # 穿过门
	TO_WAYPOINT2,       # 移动到路径点2（门后射击位置）
	WAIT_AT_WAYPOINT2,  # 在路径点2停留并射击
	TO_WAYPOINT3,       # 移动到路径点3
	TELEPORT_BACK       # 传送回路径点1
}

var current_stage: Stage = Stage.TO_WAYPOINT1
var target_progress: float = 0.0  # 当前目标点的progress值

signal reached_waypoint1        # 到达路径点1（门前）
signal door_ready_to_open       # 准备开门
signal passed_door              # 穿过门
signal reached_waypoint2        # 到达路径点2（射击位置）
signal shooting_complete        # 射击阶段完成
signal reached_waypoint3        # 到达路径点3
signal ready_to_teleport        # 准备传送回路径点1


func _ready() -> void:
	if path_follow:
		path_follow.loop = false
		path_follow.progress = 0.0
	
	# 根据点索引计算目标progress值
	_update_target_progress()


func _update_target_progress() -> void:
	"""根据当前阶段更新目标progress值"""
	if not curve:
		return
	
	match current_stage:
		Stage.TO_WAYPOINT1, Stage.WAIT_AT_WAYPOINT1:
			if waypoint1_index < curve.get_point_count():
				target_progress = _get_progress_at_point(waypoint1_index)
		Stage.TO_WAYPOINT2, Stage.WAIT_AT_WAYPOINT2:
			if waypoint2_index < curve.get_point_count():
				target_progress = _get_progress_at_point(waypoint2_index)
		Stage.TO_WAYPOINT3:
			if waypoint3_index < curve.get_point_count():
				target_progress = _get_progress_at_point(waypoint3_index)


func _get_progress_at_point(point_index: int) -> float:
	"""计算到达指定点的progress值"""
	if not curve or point_index >= curve.get_point_count():
		return 0.0
	
	# 获取指定点的位置
	var target_position = curve.get_point_position(point_index)
	
	# 使用curve的sample_baked方法找到最接近该点的progress值
	# 通过二分查找或遍历找到最接近的progress
	var closest_progress: float = 0.0
	var min_distance: float = INF
	var curve_length = curve.get_baked_length()
	var step_size = 0.1  # 精度，可以调整
	
	var progress_test = 0.0
	while progress_test <= curve_length:
		var sampled_pos = curve.sample_baked(progress_test)
		var dist = sampled_pos.distance_to(target_position)
		if dist < min_distance:
			min_distance = dist
			closest_progress = progress_test
		progress_test += step_size
	
	return closest_progress


func _process(delta: float) -> void:
	if not is_moving or not path_follow:
		return
	
	path_follow.progress += speed * delta
	
	match current_stage:
		Stage.TO_WAYPOINT1:
			# 到达路径点1（门前）
			if path_follow.progress >= target_progress - proximity_threshold:
				path_follow.progress = target_progress
				is_moving = false
				current_stage = Stage.WAIT_AT_WAYPOINT1
				reached_waypoint1.emit()
		
		Stage.TO_WAYPOINT2:
			# 到达路径点2（射击位置）
			if path_follow.progress >= target_progress - proximity_threshold:
				path_follow.progress = target_progress
				is_moving = false
				current_stage = Stage.WAIT_AT_WAYPOINT2
				reached_waypoint2.emit()
		
		Stage.TO_WAYPOINT3:
			# 到达路径点3（准备传送）
			if path_follow.progress >= target_progress - proximity_threshold:
				path_follow.progress = target_progress
				is_moving = false
				current_stage = Stage.TELEPORT_BACK
				reached_waypoint3.emit()


func start_moving() -> void:
	"""开始从出生点移动"""
	current_stage = Stage.TO_WAYPOINT1
	_update_target_progress()
	is_moving = true


func stop_moving() -> void:
	is_moving = false


func open_door_and_pass() -> void:
	"""门打开的同时穿过门移动到路径点2"""
	current_stage = Stage.PASS_DOOR
	door_ready_to_open.emit()
	# 立即开始移动，不等待门打开完成
	current_stage = Stage.TO_WAYPOINT2
	_update_target_progress()
	is_moving = true
	passed_door.emit()


func continue_to_waypoint3() -> void:
	"""射击完成后，移动到路径点3"""
	current_stage = Stage.TO_WAYPOINT3
	_update_target_progress()
	is_moving = true


func teleport_to_waypoint1() -> void:
	"""传送回路径点1（重新开始下一关）"""
	if path_follow:
		# 传送到路径点1的位置
		path_follow.progress = _get_progress_at_point(waypoint1_index)
	current_stage = Stage.WAIT_AT_WAYPOINT1
	_update_target_progress()
	is_moving = false
	ready_to_teleport.emit()


func reset_position() -> void:
	"""重置到起点"""
	if path_follow:
		path_follow.progress = 0.0
	current_stage = Stage.TO_WAYPOINT1
	_update_target_progress()
	is_moving = false
