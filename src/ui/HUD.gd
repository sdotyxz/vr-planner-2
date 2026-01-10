extends Control
class_name HUD
## 游戏内界面 - 显示分数、击杀数

## 准心大小（像素）
@export var crosshair_size: float = 42.0

@onready var score_label: Label = $ScoreLabel
@onready var kills_label: Label = $KillsLabel
@onready var timer_label: Label = $TimerLabel
@onready var crosshair: CenterContainer = $Crosshair
@onready var crosshair_sprite: TextureRect = $Crosshair/CrosshairSprite

var mouse_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	# 确保 HUD 不拦截任何鼠标事件
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_children_mouse_filter(self)
	
	# 添加到hud组
	add_to_group("hud")
	
	if GameManager:
		GameManager.score_updated.connect(_update_score)
		_update_score(GameManager.score)
	
	# 初始化准心在屏幕中心
	mouse_position = get_viewport_rect().size / 2
	
	# 设置准心大小
	_update_crosshair_size()


func _set_children_mouse_filter(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_set_children_mouse_filter(child)


func _update_score(new_score: int) -> void:
	if score_label:
		score_label.text = "Score: %d" % new_score


func _update_crosshair_size() -> void:
	if crosshair_sprite:
		crosshair_sprite.custom_minimum_size = Vector2(crosshair_size, crosshair_size)
		crosshair_sprite.size = Vector2(crosshair_size, crosshair_size)
		crosshair_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		crosshair_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED


func _input(event: InputEvent) -> void:
	# 跟踪鼠标移动
	if event is InputEventMouseMotion:
		mouse_position += event.relative
		# 限制在屏幕范围内
		var viewport_size = get_viewport_rect().size
		mouse_position.x = clampf(mouse_position.x, 0, viewport_size.x)
		mouse_position.y = clampf(mouse_position.y, 0, viewport_size.y)


func _process(_delta: float) -> void:
	if kills_label:
		kills_label.text = "Kills: %d" % GameManager.kills
	
	# 更新准心位置跟随鼠标（准心中心对准鼠标位置）
	if crosshair:
		# CenterContainer 的 pivot 在左上角，所以需要偏移一半的尺寸
		var half_size := Vector2(32, 32)  # CenterContainer 尺寸是 64x64
		crosshair.position = mouse_position - half_size
