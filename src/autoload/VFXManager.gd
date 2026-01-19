extends Node
## VFX管理器 - 全局单例，管理粒子特效

var vfx_library: Dictionary = {}
var score_popup_scene: PackedScene = null
var dialogue_popup_scene: PackedScene = null


func _ready() -> void:
	# 预加载粒子场景
	vfx_library["blood"] = load("res://assets/vfx/BloodSplatter.tscn")
	vfx_library["muzzle"] = load("res://assets/vfx/MuzzleFlash.tscn")
	
	# 预加载得分弹窗场景
	score_popup_scene = load("res://assets/vfx/ScorePopup.tscn")
	
	# 预加载对话弹窗场景
	dialogue_popup_scene = load("res://assets/vfx/DialoguePopup.tscn")


func spawn_vfx(vfx_name: String, pos: Vector3, normal: Vector3 = Vector3.UP) -> void:
	if not vfx_library.has(vfx_name):
		return
	
	var instance: Node3D = vfx_library[vfx_name].instantiate()
	get_tree().root.add_child(instance)
	instance.global_position = pos
	
	# 根据法线方向对齐
	if normal != Vector3.ZERO and normal.length_squared() > 0.001:
		var up := Vector3.UP if abs(normal.dot(Vector3.UP)) < 0.99 else Vector3.RIGHT
		instance.look_at(pos + normal, up)
	
	# 启动粒子并自动销毁
	if instance is CPUParticles3D or instance is GPUParticles3D:
		instance.emitting = true
		var lifetime: float = instance.lifetime if instance.lifetime > 0 else 1.0
		get_tree().create_timer(lifetime + 0.5).timeout.connect(instance.queue_free)


## 生成3D浮动得分弹窗
func spawn_score_popup(pos: Vector3, score: int) -> void:
	if not score_popup_scene:
		return
	
	var popup: Node3D = score_popup_scene.instantiate()
	get_tree().root.add_child(popup)
	popup.global_position = pos
	
	# 设置分数
	if popup.has_method("set_score"):
		popup.set_score(score)


## 生成3D浮动对话弹窗
func spawn_dialogue_popup(pos: Vector3, text: String, color: Color = Color.GREEN) -> void:
	if not dialogue_popup_scene:
		return
	
	var popup: Node3D = dialogue_popup_scene.instantiate()
	get_tree().root.add_child(popup)
	popup.global_position = pos
	
	# 设置对话文本
	if popup.has_method("set_text"):
		popup.set_text(text)
	
	# 设置颜色
	if popup.has_method("set_color"):
		popup.set_color(color)
