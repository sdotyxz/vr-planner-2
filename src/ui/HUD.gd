extends Control
class_name HUD
## 游戏内界面 - 显示分数、击杀数

## 准心大小（像素）
@export var crosshair_size: float = 42.0
## 外圈准心大小（像素）
@export var crosshair_outer_size: float = 48.0
## 后坐力缩放倍数
@export var recoil_scale: float = 1.4
## 后坐力动画时间
@export var recoil_duration: float = 0.08

@onready var crosshair: CenterContainer = $Crosshair
@onready var crosshair_inner: TextureRect = $Crosshair/CrosshairInner
@onready var crosshair_outer: TextureRect = $Crosshair/CrosshairOuter

var mouse_position: Vector2 = Vector2.ZERO
var _recoil_tween: Tween = null


func _ready() -> void:
	# 确保 HUD 不拦截任何鼠标事件
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_children_mouse_filter(self)
	
	# 添加到hud组
	add_to_group("hud")
	
	# 初始化准心在屏幕中心
	mouse_position = get_viewport_rect().size / 2
	
	# 设置准心大小
	_update_crosshair_size()


func _set_children_mouse_filter(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_set_children_mouse_filter(child)


func _update_crosshair_size() -> void:
	if crosshair_inner:
		crosshair_inner.custom_minimum_size = Vector2(crosshair_size, crosshair_size)
		crosshair_inner.size = Vector2(crosshair_size, crosshair_size)
		crosshair_inner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		crosshair_inner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		crosshair_inner.pivot_offset = crosshair_inner.size / 2
	if crosshair_outer:
		crosshair_outer.custom_minimum_size = Vector2(crosshair_outer_size, crosshair_outer_size)
		crosshair_outer.size = Vector2(crosshair_outer_size, crosshair_outer_size)
		crosshair_outer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		crosshair_outer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		crosshair_outer.pivot_offset = crosshair_outer.size / 2


func _input(event: InputEvent) -> void:
	# 跟踪鼠标移动
	if event is InputEventMouseMotion:
		mouse_position += event.relative
		# 限制在屏幕范围内
		var viewport_size = get_viewport_rect().size
		mouse_position.x = clampf(mouse_position.x, 0, viewport_size.x)
		mouse_position.y = clampf(mouse_position.y, 0, viewport_size.y)


func _process(_delta: float) -> void:
	# 更新准心位置跟随鼠标（准心中心对准鼠标位置）
	if crosshair:
		# CenterContainer 的 pivot 在左上角，所以需要偏移一半的尺寸
		var half_size := Vector2(32, 32)  # CenterContainer 尺寸是 64x64
		crosshair.position = mouse_position - half_size


## 播放射击后坐力动画（外圈准心放大后恢复）
func play_recoil() -> void:
	if not crosshair_outer:
		return
	
	# 取消正在进行的动画
	if _recoil_tween and _recoil_tween.is_valid():
		_recoil_tween.kill()
	
	# 立即放大
	crosshair_outer.scale = Vector2(recoil_scale, recoil_scale)
	
	# 创建恢复动画
	_recoil_tween = create_tween()
	_recoil_tween.tween_property(crosshair_outer, "scale", Vector2.ONE, recoil_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
