extends Node3D
class_name Door
## 门 - 玩家到达时打开，触发 BREACH 状态

signal door_opened

@export var open_duration: float = 0.5
@export var open_angle: float = 90.0

@onready var left_door: MeshInstance3D = $LeftDoor
@onready var right_door: MeshInstance3D = $RightDoor

var is_open: bool = false


func open() -> void:
	if is_open:
		return
	is_open = true
	
	# 播放开门动画
	var tween := create_tween()
	tween.set_parallel(true)
	
	if left_door:
		tween.tween_property(left_door, "rotation_degrees:y", -open_angle, open_duration)
	if right_door:
		tween.tween_property(right_door, "rotation_degrees:y", open_angle, open_duration)
	
	await tween.finished
	door_opened.emit()
