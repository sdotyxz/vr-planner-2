extends Node3D
class_name ScorePopup
## 3D浮动得分弹窗 - 显示击杀分数并向上飘动后消失

@onready var label: Label3D = $Label3D

## 动画参数
const FLOAT_HEIGHT: float = 0.5  ## 向上飘动高度
const DURATION: float = 1.0  ## 持续时间
const SCALE_START: float = 0.5  ## 起始缩放
const SCALE_PEAK: float = 1.2  ## 峰值缩放


func _ready() -> void:
	# 延迟一帧后开始动画，确保 global_position 已被正确设置
	await get_tree().process_frame
	_animate()


## 设置分数文本
func set_score(score: int) -> void:
	if label:
		label.text = "+%d" % score
		# 根据分数设置颜色
		if score >= 100:
			label.modulate = Color(1.0, 0.85, 0.2, 1.0)  # 金色
		else:
			label.modulate = Color(1.0, 1.0, 1.0, 1.0)  # 白色


func _animate() -> void:
	if not label:
		await get_tree().create_timer(DURATION).timeout
		queue_free()
		return
	
	# 初始状态
	label.scale = Vector3.ONE * SCALE_START
	label.modulate.a = 1.0
	
	# 记录初始Y位置，使用全局坐标向上移动
	var start_y := global_position.y
	var end_y := start_y + FLOAT_HEIGHT
	
	# 创建动画
	var tween := create_tween()
	tween.set_parallel(true)
	
	# 位置向上飘动（使用全局Y坐标）
	tween.tween_property(self, "global_position:y", end_y, DURATION).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	# 缩放：先放大再恢复
	tween.tween_property(label, "scale", Vector3.ONE * SCALE_PEAK, DURATION * 0.3).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector3.ONE, DURATION * 0.7).set_delay(DURATION * 0.3).set_ease(Tween.EASE_IN_OUT)
	
	# 透明度：后半段淡出
	tween.tween_property(label, "modulate:a", 0.0, DURATION * 0.5).set_delay(DURATION * 0.5).set_ease(Tween.EASE_IN)
	
	# 动画结束后销毁
	tween.chain().tween_callback(queue_free)
