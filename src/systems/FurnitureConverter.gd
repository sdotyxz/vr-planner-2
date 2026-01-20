extends RefCounted
class_name FurnitureConverter
## 家具转换器 - 运行时将场景中的静态家具自动转换为可破坏对象

## 预加载可破坏家具脚本
const DestructibleFurnitureScript = preload("res://src/entities/DestructibleFurniture.gd")

## 家具关键词列表（匹配这些关键词的节点会被转换）
const FURNITURE_KEYWORDS: Array[String] = [
	# 桌子
	"Desk", "Table", "Counter",
	# 椅子
	"Chair", "Stool", "Sofa",
	# 存储
	"Shelf", "Bookshelf", "Cabinet", "FileCabinet", "Drawer", "Box",
	# 电子设备
	"Computer", "Monitor", "Keyboard", "Mouse", "Printer", "Phone", "Laptop", "TV", "PC_",
	# 其他家具
	"Lamp", "WhiteBoard", "TrashBin", "CoffeeCup", "Rug", "Painting", "Deco", "Nature_Deco",
	"Coffee_Table", "Modern_Shelves",
]

## 排除关键词（这些节点不会被转换）
const EXCLUDE_KEYWORDS: Array[String] = [
	"Floor", "Wall", "Ceiling", "Door", "Window", "SpawnPoint", "Marker",
	"Light", "Camera", "Environment", "Cover",
]


## 转换场景中的所有家具为可破坏对象
## scene_root: 办公室场景的根节点
## 返回: 转换的家具数量
static func convert_scene(scene_root: Node3D) -> int:
	var converted_count := 0
	var nodes_to_convert: Array[Node3D] = []
	
	# 收集需要转换的节点
	_collect_furniture_nodes(scene_root, nodes_to_convert)
	
	# 转换收集到的节点
	for node in nodes_to_convert:
		if _convert_node_to_destructible(node):
			converted_count += 1
	
	if converted_count > 0:
		print("[FurnitureConverter] Converted %d furniture items to destructible" % converted_count)
	
	return converted_count


## 递归收集所有符合条件的家具节点
static func _collect_furniture_nodes(node: Node, result: Array[Node3D]) -> void:
	# 检查节点名称是否匹配家具关键词
	if node is Node3D and _is_furniture_node(node):
		result.append(node as Node3D)
		# 不递归进入已匹配的节点内部
		return
	
	# 继续递归子节点
	for child in node.get_children():
		_collect_furniture_nodes(child, result)


## 检查节点是否为家具
static func _is_furniture_node(node: Node) -> bool:
	var node_name := node.name.to_lower()
	
	# 检查排除关键词
	for exclude_keyword in EXCLUDE_KEYWORDS:
		if node_name.contains(exclude_keyword.to_lower()):
			return false
	
	# 检查是否已经是可破坏对象（通过脚本检查）
	if node.get_script() == DestructibleFurnitureScript:
		return false
	
	# 检查是否在 destructible 组中
	if node.is_in_group("destructible"):
		return false
	
	# 检查家具关键词
	for keyword in FURNITURE_KEYWORDS:
		if node_name.contains(keyword.to_lower()):
			# 确保节点包含 MeshInstance3D（直接或间接子节点）
			return _has_mesh_instance(node)
	
	return false


## 检查节点是否包含 MeshInstance3D
static func _has_mesh_instance(node: Node) -> bool:
	if node is MeshInstance3D:
		return true
	for child in node.get_children():
		if _has_mesh_instance(child):
			return true
	return false


## 将普通节点转换为可破坏家具
static func _convert_node_to_destructible(original: Node3D) -> bool:
	var parent := original.get_parent()
	if not parent:
		return false
	
	# 创建 DestructibleFurniture 实例（使用预加载的脚本）
	var destructible: StaticBody3D = StaticBody3D.new()
	destructible.set_script(DestructibleFurnitureScript)
	destructible.name = original.name + "_Destructible"
	destructible.transform = original.transform
	
	# 随机设置碎片数量（8-12）
	destructible.fragment_count = randi_range(8, 12)
	
	# 获取原节点在父节点中的位置
	var index := original.get_index()
	
	# 将原节点从父节点移除（但不销毁）
	parent.remove_child(original)
	
	# 重置原节点的变换（因为它现在是 DestructibleFurniture 的子节点）
	original.transform = Transform3D.IDENTITY
	
	# 设置模型
	destructible.setup_model(original)
	
	# 将 DestructibleFurniture 添加到原位置
	parent.add_child(destructible)
	parent.move_child(destructible, index)
	
	return true
