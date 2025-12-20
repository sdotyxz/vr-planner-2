extends StaticBody3D
class_name Hostage
## 人质 - 使用随机图片素材的2D片

@onready var sprite: Sprite3D = $Sprite3D

const HOSTAGE_TEXTURES: Array[String] = [
	"res://assets/character/hostage1.png",
	"res://assets/character/hostage2.png",
]


func _ready() -> void:
	add_to_group("hostage")
	_randomize_texture()


func _randomize_texture() -> void:
	if sprite and HOSTAGE_TEXTURES.size() > 0:
		var random_index := randi() % HOSTAGE_TEXTURES.size()
		var texture := load(HOSTAGE_TEXTURES[random_index]) as Texture2D
		if texture:
			sprite.texture = texture


func hit() -> void:
	# 人质被击中的反馈（闪烁红色后消失）
	if sprite:
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.2).timeout
	queue_free()
