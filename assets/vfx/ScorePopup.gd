extends Node3D
class_name ScorePopup
## 3D浮动得分弹窗 - 使用 TextMesh 显示击杀分数并向上飘动后消失

@onready var mesh_instance: MeshInstance3D = $TextMeshInstance
var text_mesh: TextMesh

## 动画参数
const FLOAT_HEIGHT: float = 1.0  ## 向上飘动高度
const DURATION: float = 0.6  ## 持续时间
const SCALE_START: float = 0.5  ## 起始缩放
const SCALE_PEAK: float = 1.2  ## 峰值缩放
const SWING_ANGLE: float = deg_to_rad(15.0)  ## 摆动角度（左右15度）
const SWING_COUNT: float = 2.0  ## 摆动次数

## 颜色材质
var material: StandardMaterial3D


func _ready() -> void:
	_ensure_resources()
	# 延迟一帧后开始动画，确保 global_position 已被正确设置
	await get_tree().process_frame
	_animate()


## 设置分数文本
func set_score(score: int) -> void:
	# 确保节点已初始化
	if not is_node_ready():
		await ready
	_ensure_resources()
	if text_mesh:
		text_mesh.text = "+%d" % score
	# 根据分数设置颜色
	if material:
		if score >= 100:
			material.albedo_color = Color(1.0, 0.85, 0.2, 1.0)  # 金色
			material.emission = Color(1.0, 0.7, 0.1, 1.0)
		else:
			material.albedo_color = Color(1.0, 1.0, 1.0, 1.0)  # 白色
			material.emission = Color(0.8, 0.8, 0.8, 1.0)


## 确保资源已加载（复制资源避免共享问题）
func _ensure_resources() -> void:
	if not mesh_instance:
		mesh_instance = get_node_or_null("TextMeshInstance")
	if not mesh_instance:
		return
	
	# 复制 TextMesh 避免多个实例共享
	if not text_mesh:
		var original_mesh = mesh_instance.mesh as TextMesh
		if original_mesh:
			text_mesh = original_mesh.duplicate() as TextMesh
			mesh_instance.mesh = text_mesh
	
	# 复制材质避免多个实例共享
	if not material:
		var original_material = mesh_instance.material_override as StandardMaterial3D
		if original_material:
			material = original_material.duplicate() as StandardMaterial3D
			mesh_instance.material_override = material


func _animate() -> void:
	if not mesh_instance:
		await get_tree().create_timer(DURATION).timeout
		queue_free()
		return
	
	# 初始状态
	mesh_instance.scale = Vector3.ONE * SCALE_START
	if material:
		material.albedo_color.a = 1.0
	
	# 记录初始Y位置，使用全局坐标向上移动
	var start_y := global_position.y
	var end_y := start_y + FLOAT_HEIGHT
	
	# 创建动画
	var tween := create_tween()
	tween.set_parallel(true)
	
	# 位置向上飘动（使用全局Y坐标）
	tween.tween_property(self, "global_position:y", end_y, DURATION).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	# 摆动旋转动画（左右摆动，不超过60度）
	var swing_duration := DURATION / (SWING_COUNT * 2.0)
	var swing_tween := create_tween()
	for i in int(SWING_COUNT):
		swing_tween.tween_property(mesh_instance, "rotation:y", SWING_ANGLE, swing_duration).set_ease(Tween.EASE_IN_OUT)
		swing_tween.tween_property(mesh_instance, "rotation:y", -SWING_ANGLE, swing_duration).set_ease(Tween.EASE_IN_OUT)
	swing_tween.tween_property(mesh_instance, "rotation:y", 0.0, swing_duration * 0.5).set_ease(Tween.EASE_OUT)
	
	# 缩放：先放大再恢复
	tween.tween_property(mesh_instance, "scale", Vector3.ONE * SCALE_PEAK, DURATION * 0.3).set_ease(Tween.EASE_OUT)
	tween.tween_property(mesh_instance, "scale", Vector3.ONE, DURATION * 0.7).set_delay(DURATION * 0.3).set_ease(Tween.EASE_IN_OUT)
	
	# 透明度：后半段淡出（通过材质实现）
	if material:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		tween.tween_property(material, "albedo_color:a", 0.0, DURATION * 0.5).set_delay(DURATION * 0.5).set_ease(Tween.EASE_IN)
	
	# 动画结束后销毁
	tween.chain().tween_callback(queue_free)
