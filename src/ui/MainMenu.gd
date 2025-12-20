extends Control
class_name MainMenu
## 主菜单


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GameManager.reset_stats()


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/levels/MainLevel.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
