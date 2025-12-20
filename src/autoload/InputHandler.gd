extends Node
## 全局输入处理器 - 确保鼠标移动事件被正确传递

signal mouse_motion(relative: Vector2)

func _ready() -> void:
	print("InputHandler: Ready")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# print("InputHandler: Motion ", event.relative)
		mouse_motion.emit(event.relative)
