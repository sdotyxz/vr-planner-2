extends Path3D
class_name RailSystem
## 轨道系统 - 控制玩家沿路径自动移动

@export var speed: float = 5.0
@export var door_stop_ratio: float = 0.5  # 门口位置（轨道50%处）
@export var is_moving: bool = false

@onready var path_follow: PathFollow3D = $PathFollow3D

var passed_door: bool = false

signal reached_door
signal reached_end


func _ready() -> void:
	if path_follow:
		path_follow.loop = false
		path_follow.progress = 0.0


func _process(delta: float) -> void:
	if not is_moving or not path_follow:
		return
	
	path_follow.progress += speed * delta
	
	# 到达门口位置（第一次停止）
	if not passed_door and path_follow.progress_ratio >= door_stop_ratio:
		path_follow.progress_ratio = door_stop_ratio
		is_moving = false
		reached_door.emit()
		return
	
	# 到达终点
	if path_follow.progress_ratio >= 1.0:
		path_follow.progress_ratio = 1.0
		is_moving = false
		reached_end.emit()


func start_moving() -> void:
	is_moving = true


func stop_moving() -> void:
	is_moving = false


func continue_past_door() -> void:
	passed_door = true
	is_moving = true


func reset_position() -> void:
	if path_follow:
		path_follow.progress = 0.0
	passed_door = false
