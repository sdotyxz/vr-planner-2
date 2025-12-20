extends StaticBody3D
class_name Enemy
## 敌人 - 红色方块，被击中后销毁

signal died

@onready var mesh: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	add_to_group("enemy")


func die() -> void:
	died.emit()
	GameManager.add_kill()
	GameManager.add_score(100)
	queue_free()
