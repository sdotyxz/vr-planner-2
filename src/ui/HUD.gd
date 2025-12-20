extends Control
class_name HUD
## 游戏内界面 - 显示分数、击杀数

@onready var score_label: Label = $ScoreLabel
@onready var kills_label: Label = $KillsLabel
@onready var timer_label: Label = $TimerLabel


func _ready() -> void:
	# 确保 HUD 不拦截任何鼠标事件
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_children_mouse_filter(self)
	
	if GameManager:
		GameManager.score_updated.connect(_update_score)
		_update_score(GameManager.score)


func _set_children_mouse_filter(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_set_children_mouse_filter(child)


func _update_score(new_score: int) -> void:
	if score_label:
		score_label.text = "Score: %d" % new_score


func _process(_delta: float) -> void:
	if kills_label:
		kills_label.text = "Kills: %d" % GameManager.kills
