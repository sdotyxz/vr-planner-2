extends Area3D
class_name SpawnArea
## 生成区域 - 可视化配置敌人/人质的生成范围

## 区域类型
enum AreaType {
	ENEMY,    ## 敌人生成区域
	HOSTAGE,  ## 人质生成区域
	DOOR      ## 门区域（避开）
}

@export var area_type: AreaType = AreaType.ENEMY  ## 区域类型
@export var min_spacing: float = 3.5  ## 物体之间的最小间距（仅用于 ENEMY 类型）

@onready var collision_shape: CollisionShape3D = $CollisionShape3D

## 颜色配置（编辑器中可视化）
const COLOR_ENEMY := Color(1.0, 0.3, 0.3, 0.3)    # 红色半透明
const COLOR_HOSTAGE := Color(0.3, 0.3, 1.0, 0.3)  # 蓝色半透明
const COLOR_DOOR := Color(1.0, 1.0, 0.3, 0.3)     # 黄色半透明


func _ready() -> void:
	# 仅用于编辑器可视化，运行时禁用碰撞
	monitoring = false
	monitorable = false


## 获取区域边界 (返回 AABB)
func get_bounds() -> AABB:
	if collision_shape and collision_shape.shape is BoxShape3D:
		var box: BoxShape3D = collision_shape.shape
		var half_size := box.size / 2.0
		var min_pos := global_position - half_size
		var size := box.size
		return AABB(min_pos, size)
	return AABB(global_position, Vector3.ONE)


## 获取 X 范围
func get_x_range() -> Vector2:
	var bounds := get_bounds()
	return Vector2(bounds.position.x, bounds.position.x + bounds.size.x)


## 获取 Z 范围
func get_z_range() -> Vector2:
	var bounds := get_bounds()
	return Vector2(bounds.position.z, bounds.position.z + bounds.size.z)


## 在区域内生成随机位置
func get_random_position(y_offset: float = 1.0) -> Vector3:
	var bounds := get_bounds()
	return Vector3(
		randf_range(bounds.position.x, bounds.position.x + bounds.size.x),
		y_offset,
		randf_range(bounds.position.z, bounds.position.z + bounds.size.z)
	)


## 编辑器中绘制区域（仅在编辑器中显示）
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not collision_shape:
		warnings.append("需要一个 CollisionShape3D 子节点")
	elif not collision_shape.shape is BoxShape3D:
		warnings.append("CollisionShape3D 需要使用 BoxShape3D")
	return warnings
