extends Control
class_name SummaryScreen
## 结算画面 - 显示得分和击杀数

@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var kills_label: Label = $VBoxContainer/KillsLabel


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if score_label:
		score_label.text = "Score: %d" % GameManager.score
	if kills_label:
		kills_label.text = "Scope Creep Denied: %d" % GameManager.kills


func _on_restart_pressed() -> void:
	GameManager.reset_stats()
	get_tree().change_scene_to_file("res://src/levels/MainLevel.tscn")


func _on_menu_pressed() -> void:
	GameManager.reset_stats()
	get_tree().change_scene_to_file("res://src/ui/MainMenu.tscn")
