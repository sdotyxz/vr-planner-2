extends Node3D
class_name Door
## 门 - 玩家到达时打开，触发 BREACH 状态

signal door_opened

@export var open_duration: float = 0.5
@export var open_angle: float = 90.0

@onready var door_pivot: Node3D = $DoorPivot

var is_open: bool = false


func open() -> void:
	if is_open:
		return
	is_open = true
	
	# 播放开门动画（以右边为轴向内旋转）
	var tween := create_tween()
	
	if door_pivot:
		tween.tween_property(door_pivot, "rotation_degrees:y", -open_angle, open_duration)
	
	await tween.finished
	door_opened.emit()


func close() -> void:
	if not is_open:
		return
	is_open = false
	
	var tween := create_tween()
	if door_pivot:
		tween.tween_property(door_pivot, "rotation_degrees:y", 0.0, open_duration)
