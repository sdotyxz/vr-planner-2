@tool
extends Marker3D
class_name SpawnPoint
## 可视化Spawn点 - 用于在编辑器中配置敌人和人质的出生位置

enum SpawnType {
	ENEMY,    ## 敌人出生点
	HOSTAGE   ## 人质出生点
}

## Spawn类型
@export var spawn_type: SpawnType = SpawnType.ENEMY:
	set(value):
		spawn_type = value
		_update_visual()

## 朝向目标位置（敌人面向的方向）
@export var facing_target: Vector3 = Vector3(0, 0, -10):
	set(value):
		facing_target = value
		_update_visual()

## 可视化网格实例（从场景中获取）
@onready var _visual_mesh: MeshInstance3D = $VisualMesh
@onready var _arrow_mesh: MeshInstance3D = $ArrowMesh

## 敌人颜色（红色）
const ENEMY_COLOR := Color(0.9, 0.2, 0.2, 0.8)
## 人质颜色（绿色）
const HOSTAGE_COLOR := Color(0.2, 0.9, 0.2, 0.8)


func _ready() -> void:
	# 确保子节点存在
	_ensure_visual_nodes()
	_update_visual()


func _ensure_visual_nodes() -> void:
	# 如果子节点不存在，动态创建（向后兼容）
	if not _visual_mesh:
		_visual_mesh = get_node_or_null("VisualMesh") as MeshInstance3D
	if not _arrow_mesh:
		_arrow_mesh = get_node_or_null("ArrowMesh") as MeshInstance3D
	
	if not _visual_mesh:
		_visual_mesh = MeshInstance3D.new()
		_visual_mesh.name = "VisualMesh"
		var capsule := CapsuleMesh.new()
		capsule.radius = 0.3
		capsule.height = 1.8
		_visual_mesh.mesh = capsule
		_visual_mesh.position.y = 0.9
		add_child(_visual_mesh)
		if Engine.is_editor_hint():
			_visual_mesh.owner = get_tree().edited_scene_root
	
	if not _arrow_mesh:
		_arrow_mesh = MeshInstance3D.new()
		_arrow_mesh.name = "ArrowMesh"
		var cone := CylinderMesh.new()
		cone.top_radius = 0.0
		cone.bottom_radius = 0.15
		cone.height = 0.4
		_arrow_mesh.mesh = cone
		_arrow_mesh.position = Vector3(0, 1.2, -0.4)
		_arrow_mesh.rotation_degrees.x = -90
		add_child(_arrow_mesh)
		if Engine.is_editor_hint():
			_arrow_mesh.owner = get_tree().edited_scene_root


func _update_visual() -> void:
	if not _visual_mesh or not _arrow_mesh:
		return
	
	# 根据类型设置颜色
	var color := ENEMY_COLOR if spawn_type == SpawnType.ENEMY else HOSTAGE_COLOR
	
	# 创建材质
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	_visual_mesh.material_override = material
	_arrow_mesh.material_override = material
	
	# 在运行时隐藏可视化
	var is_runtime := not Engine.is_editor_hint()
	_visual_mesh.visible = not is_runtime
	_arrow_mesh.visible = not is_runtime
	
	# 更新朝向
	if facing_target != Vector3.ZERO:
		var direction := (facing_target - global_position).normalized()
		if direction.length() > 0.01:
			var angle := atan2(direction.x, direction.z)
			_arrow_mesh.rotation.y = angle


func _process(_delta: float) -> void:
	# 仅在编辑器中更新朝向预览
	if Engine.is_editor_hint():
		_update_visual()


## 获取spawn位置（世界坐标）
func get_spawn_position() -> Vector3:
	return global_position


## 获取朝向方向
func get_facing_direction() -> Vector3:
	return (facing_target - global_position).normalized()


## 获取朝向旋转角度（Y轴）
func get_facing_rotation_y() -> float:
	var direction := get_facing_direction()
	return atan2(direction.x, direction.z)
