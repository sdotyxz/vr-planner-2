extends Node3D
class_name Door
## 门 - 玩家到达时打开，触发 BREACH 状态

signal door_opened

@export var open_duration: float = 0.2  # 加快速度，从0.5改为0.2
@export var fall_angle: float = 90.0  # 门倒下的角度

@onready var door_pivot: Node3D = $DoorPivot

var is_open: bool = false


func open() -> void:
	if is_open:
		return
	is_open = true
	
	# 触发相机抖动效果
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("shake_camera"):
		player.shake_camera()
	
	# 播放开门动画（门向前倒下）
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)  # 加速倒下效果
	tween.set_trans(Tween.TRANS_QUAD)
	
	if door_pivot:
		# 绕X轴旋转，使门向前倒下（远离玩家）
		tween.tween_property(door_pivot, "rotation_degrees:x", -fall_angle, open_duration)
	
	await tween.finished
	door_opened.emit()


func close() -> void:
	if not is_open:
		return
	is_open = false
	
	var tween := create_tween()
	if door_pivot:
		# 恢复到初始位置
		tween.tween_property(door_pivot, "rotation_degrees:x", 0.0, open_duration)
