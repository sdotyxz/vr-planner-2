extends StaticBody3D
class_name Enemy
## 敌人 - 使用随机图片素材的2D片

signal died

@onready var sprite: Sprite3D = $Sprite3D

const ENEMY_TEXTURES: Array[String] = [
	"res://assets/character/enemy1.png",
	"res://assets/character/enemy2.png",
	"res://assets/character/enemy3.png",
	"res://assets/character/enemy4.png",
	"res://assets/character/enemy5.png",
	"res://assets/character/enemy6.png",
	"res://assets/character/enemy7.png",
]


func _ready() -> void:
	add_to_group("enemy")
	_randomize_texture()


func _randomize_texture() -> void:
	if sprite and ENEMY_TEXTURES.size() > 0:
		var random_index := randi() % ENEMY_TEXTURES.size()
		var texture := load(ENEMY_TEXTURES[random_index]) as Texture2D
		if texture:
			sprite.texture = texture


func die() -> void:
	died.emit()
	GameManager.add_kill()
	GameManager.add_score(100)
	queue_free()
