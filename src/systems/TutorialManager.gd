extends Node
class_name TutorialManager
## 教程管理器 - 管理前三关的教程提示，等待玩家操作后继续游戏

## 教程提示场景
var dialogue_popup_scene: PackedScene = preload("res://assets/vfx/DialoguePopup.tscn")

## 当前教程提示实例
var current_popup: DialoguePopup = null

## 玩家点击信号
signal player_fired

## 教程房间数量（前3关为教程）
const TUTORIAL_ROOM_COUNT: int = 3

## 教程文本内容（按房间号索引）
const TUTORIAL_TEXTS: Dictionary = {
	1: "点击绿圈消灭敌人！",
	2: "快速瞄准，注意时间限制！",
	3: "蓝色是人质，不要误伤！",
}

## 提示文本颜色
const TUTORIAL_COLOR: Color = Color.YELLOW

## 提示显示距离（相机前方距离）
const POPUP_DISTANCE: float = 2.5

## 提示显示高度偏移
const POPUP_HEIGHT_OFFSET: float = 0.3

## 教程文本缩放（相对于默认大小）
const TUTORIAL_SCALE: float = 0.49


func _ready() -> void:
	set_process_input(true)


func _input(event: InputEvent) -> void:
	# 检测玩家点击（fire action）
	if event.is_action_pressed("fire"):
		player_fired.emit()


## 检查是否为教程关卡
func is_tutorial_room(room: int) -> bool:
	return room >= 1 and room <= TUTORIAL_ROOM_COUNT


## 获取指定房间的教程文本
func get_tutorial_text(room: int) -> String:
	if TUTORIAL_TEXTS.has(room):
		return TUTORIAL_TEXTS[room]
	return ""


## 在相机前方显示教程提示
## camera: 玩家相机
## text: 提示文本
## 返回: 创建的 DialoguePopup 实例
func show_prompt(camera: Camera3D, text: String) -> DialoguePopup:
	# 关闭之前的提示
	dismiss_prompt()
	
	if not camera or text.is_empty():
		return null
	
	# 计算相机前方位置
	var forward := -camera.global_transform.basis.z.normalized()
	var popup_pos := camera.global_position + forward * POPUP_DISTANCE
	popup_pos.y += POPUP_HEIGHT_OFFSET
	
	# 创建弹窗
	var popup: DialoguePopup = dialogue_popup_scene.instantiate()
	popup.persistent = true  # 设置为持久模式
	get_tree().root.add_child(popup)
	popup.global_position = popup_pos
	
	# 设置文本和颜色
	popup.set_text(text)
	popup.set_color(TUTORIAL_COLOR)
	
	# 缩小教程文本（70%大小）
	popup.scale = Vector3.ONE * TUTORIAL_SCALE
	
	# 让弹窗面向相机
	popup.look_at(camera.global_position, Vector3.UP)
	popup.rotate_y(PI)  # 翻转180度面向相机
	
	current_popup = popup
	return popup


## 关闭当前教程提示
func dismiss_prompt() -> void:
	if current_popup and is_instance_valid(current_popup):
		current_popup.dismiss()
		current_popup = null


## 等待玩家点击
## 返回: 当玩家点击后返回
func await_player_fire() -> void:
	await player_fired


## 显示教程并等待玩家操作
## camera: 玩家相机
## room: 当前房间号
## 返回: 教程完成后返回
func show_tutorial_and_wait(camera: Camera3D, room: int) -> void:
	if not is_tutorial_room(room):
		return
	
	var text := get_tutorial_text(room)
	if text.is_empty():
		return
	
	# 暂停游戏时间（但仍能接收输入）
	var original_time_scale := Engine.time_scale
	Engine.time_scale = 0.0
	
	# 显示提示
	show_prompt(camera, text)
	
	# 等待玩家点击
	await await_player_fire()
	
	# 关闭提示
	dismiss_prompt()
	
	# 恢复游戏时间
	Engine.time_scale = original_time_scale
