extends Node3D
class_name GameOverScreen3DText
## 3D游戏结束界面 - 使用 TextMesh 显示3D文字

signal restart_requested
signal name_submitted(player_name: String)

@onready var title_mesh: MeshInstance3D = $TitleMesh
@onready var title_outline: MeshInstance3D = $TitleOutline
@onready var subtitle_mesh: MeshInstance3D = $SubtitleMesh
@onready var subtitle_outline: MeshInstance3D = $SubtitleOutline
@onready var score_container: Node3D = $ScoreContainer
@onready var hint_mesh: MeshInstance3D = $HintMesh
@onready var hint_outline: MeshInstance3D = $HintOutline

## 材质模板（金色用于高分，白色用于普通）
var gold_material: StandardMaterial3D
var white_material: StandardMaterial3D
var green_material: StandardMaterial3D

## 描边材质
var outline_material: StandardMaterial3D

## 描边网格数组
var _rank_outline_meshes: Array[MeshInstance3D] = []
var _name_outline_meshes: Array[MeshInstance3D] = []
var _points_outline_meshes: Array[MeshInstance3D] = []
var _hint_outline_mesh: MeshInstance3D = null

## 动画参数
const SWING_ANGLE: float = deg_to_rad(8.0)  ## 摆动角度
const SWING_SPEED: float = 2.0  ## 摆动速度
const TITLE_SWING_ANGLE: float = deg_to_rad(5.0)  ## 标题摆动角度

## 状态变量
var _player_rank: int = -1
var _name_submitted: bool = false
var _can_click_restart: bool = false
var _current_score: int = 0
var _score_meshes: Array[MeshInstance3D] = []

## 三列分离的排行榜网格
var _rank_meshes: Array[MeshInstance3D] = []   ## 排名列
var _name_meshes: Array[MeshInstance3D] = []   ## 名字列  
var _points_meshes: Array[MeshInstance3D] = [] ## 分数列

## 布局常量 - 基于"GAME OVER"标题宽度约0.5单位
const LEADERBOARD_LEFT_X: float = -0.80   ## 排名列左端
const LEADERBOARD_NAME_X: float = -0.10   ## 名字列位置
const LEADERBOARD_SCORE_X: float = 0.80   ## 分数列右端

## 玩家名字输入
var _is_entering_name: bool = false
var _player_name: String = ""
const MAX_NAME_LENGTH: int = 5
const ALLOWED_CHARS: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

## 延迟重启时间
const RESTART_DELAY: float = 2.0

## 字体
var _custom_font: Font = preload("res://assets/Kenney Future Narrow.ttf")

## 动画时间
var _time: float = 0.0


func _ready() -> void:
	_setup_materials()
	_duplicate_resources()


func _process(delta: float) -> void:
	if not visible:
		return
	
	_time += delta
	
	# 标题摇摆
	var title_swing := sin(_time * SWING_SPEED) * TITLE_SWING_ANGLE
	if title_mesh:
		title_mesh.rotation.y = title_swing
	if title_outline:
		title_outline.rotation.y = title_swing
	
	# 副标题摇摆（相位偏移）
	var subtitle_swing := sin(_time * SWING_SPEED + 0.5) * SWING_ANGLE * 0.5
	if subtitle_mesh:
		subtitle_mesh.rotation.y = subtitle_swing
	if subtitle_outline:
		subtitle_outline.rotation.y = subtitle_swing
	
	# 提示文字摇摆
	var hint_swing := sin(_time * SWING_SPEED + 1.0) * SWING_ANGLE * 0.3
	if hint_mesh and hint_mesh.visible:
		hint_mesh.rotation.y = hint_swing
	if hint_outline and hint_outline.visible:
		hint_outline.rotation.y = hint_swing
	
	# 分数行摇摆（每行不同相位）
	for i in range(_rank_meshes.size()):
		var swing := sin(_time * SWING_SPEED + i * 0.3) * SWING_ANGLE * 0.3
		if i < _rank_meshes.size() and is_instance_valid(_rank_meshes[i]):
			_rank_meshes[i].rotation.y = swing
		if i < _rank_outline_meshes.size() and is_instance_valid(_rank_outline_meshes[i]):
			_rank_outline_meshes[i].rotation.y = swing
		if i < _name_meshes.size() and is_instance_valid(_name_meshes[i]):
			_name_meshes[i].rotation.y = swing
		if i < _name_outline_meshes.size() and is_instance_valid(_name_outline_meshes[i]):
			_name_outline_meshes[i].rotation.y = swing
		if i < _points_meshes.size() and is_instance_valid(_points_meshes[i]):
			_points_meshes[i].rotation.y = swing
		if i < _points_outline_meshes.size() and is_instance_valid(_points_outline_meshes[i]):
			_points_outline_meshes[i].rotation.y = swing


func _setup_materials() -> void:
	# 金色材质（自发光，不受环境光影响）
	gold_material = StandardMaterial3D.new()
	gold_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	gold_material.albedo_color = Color(1.0, 0.85, 0.3, 1.0)
	
	# 白色材质（自发光，不受环境光影响）
	white_material = StandardMaterial3D.new()
	white_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	white_material.albedo_color = Color(0.9, 0.9, 0.9, 1.0)
	
	# 绿色材质（玩家高分，自发光，不受环境光影响）
	green_material = StandardMaterial3D.new()
	green_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	green_material.albedo_color = Color(0.3, 1.0, 0.3, 1.0)
	
	# 描边材质（深色，自发光，不受环境光影响）
	outline_material = StandardMaterial3D.new()
	outline_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	outline_material.albedo_color = Color(0.05, 0.05, 0.05, 1.0)


func _duplicate_resources() -> void:
	# 复制标题的 TextMesh 和材质
	if title_mesh:
		var orig_mesh := title_mesh.mesh as TextMesh
		if orig_mesh:
			title_mesh.mesh = orig_mesh.duplicate()
		var orig_mat := title_mesh.material_override as StandardMaterial3D
		if orig_mat:
			title_mesh.material_override = orig_mat.duplicate()
	
	# 复制副标题
	if subtitle_mesh:
		var orig_mesh := subtitle_mesh.mesh as TextMesh
		if orig_mesh:
			subtitle_mesh.mesh = orig_mesh.duplicate()
		var orig_mat := subtitle_mesh.material_override as StandardMaterial3D
		if orig_mat:
			subtitle_mesh.material_override = orig_mat.duplicate()
	
	# 复制提示
	if hint_mesh:
		var orig_mesh := hint_mesh.mesh as TextMesh
		if orig_mesh:
			hint_mesh.mesh = orig_mesh.duplicate()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	# 处理玩家名字输入
	if _is_entering_name:
		if event is InputEventKey and event.pressed:
			var key_event := event as InputEventKey
			
			# 回车键确认名字
			if key_event.keycode == KEY_ENTER or key_event.keycode == KEY_KP_ENTER:
				_submit_player_name()
				get_viewport().set_input_as_handled()
				return
			
			# 退格键删除字符
			if key_event.keycode == KEY_BACKSPACE:
				if _player_name.length() > 0:
					_player_name = _player_name.substr(0, _player_name.length() - 1)
					_update_player_name_display()
				get_viewport().set_input_as_handled()
				return
			
			# 获取输入的字符
			var char_typed := ""
			if key_event.unicode > 0:
				char_typed = char(key_event.unicode).to_upper()
			
			# 检查是否是允许的字符
			if char_typed != "" and ALLOWED_CHARS.contains(char_typed):
				if _player_name.length() < MAX_NAME_LENGTH:
					_player_name += char_typed
					_update_player_name_display()
					_trigger_typing_effect()
				get_viewport().set_input_as_handled()
				return
	
	# 鼠标点击重启游戏
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _can_click_restart:
			restart_requested.emit()
			get_viewport().set_input_as_handled()


## 显示排行榜
func show_leaderboard(current_score: int) -> void:
	visible = true
	_name_submitted = false
	_can_click_restart = false
	_current_score = current_score
	_time = 0.0
	_player_name = ""
	_is_entering_name = false
	
	_clear_scores()
	
	var leaderboard := LeaderboardManager.get_leaderboard()
	var is_high_score := LeaderboardManager.is_high_score(current_score)
	
	# 确定玩家排名位置
	_player_rank = -1
	if is_high_score:
		for i in range(leaderboard.size()):
			if current_score > leaderboard[i]["score"]:
				_player_rank = i
				break
		if _player_rank == -1 and leaderboard.size() < LeaderboardManager.MAX_ENTRIES:
			_player_rank = leaderboard.size()
	
	# 更新副标题
	if subtitle_mesh:
		var subtitle_text_mesh := subtitle_mesh.mesh as TextMesh
		var subtitle_mat := subtitle_mesh.material_override as StandardMaterial3D
		if subtitle_text_mesh:
			if is_high_score:
				subtitle_text_mesh.text = "ENTER YOUR NAME"
				if subtitle_mat:
					subtitle_mat.albedo_color = Color(0.3, 1.0, 0.3, 1.0)
					subtitle_mat.emission = Color(0.2, 0.8, 0.2, 1.0)
				# 同步描边
				if subtitle_outline:
					var outline_mesh := subtitle_outline.mesh as TextMesh
					if outline_mesh:
						outline_mesh.text = "ENTER YOUR NAME"
			else:
				subtitle_text_mesh.text = "HIGH SCORES"
				if subtitle_mat:
					subtitle_mat.albedo_color = Color(1.0, 0.85, 0.3, 1.0)
					subtitle_mat.emission = Color(1.0, 0.7, 0.1, 1.0)
				# 同步描边
				if subtitle_outline:
					var outline_mesh := subtitle_outline.mesh as TextMesh
					if outline_mesh:
						outline_mesh.text = "HIGH SCORES"
	
	# 显示/隐藏提示
	if hint_mesh:
		if is_high_score:
			# 显示输入名字的提示
			var hint_text_mesh := hint_mesh.mesh as TextMesh
			if hint_text_mesh:
				hint_text_mesh.text = "TYPE NAME + ENTER"
			hint_mesh.visible = true
		else:
			hint_mesh.visible = false
	
	# 生成排行榜分数行 - 三列分离
	var y_offset: float = 0.0
	var line_height: float = 0.12
	var row_scale: float = 0.6
	
	for i in range(LeaderboardManager.MAX_ENTRIES):
		var actual_index := i
		if _player_rank >= 0 and i > _player_rank:
			actual_index = i - 1
		
		var rank_text: String = "%d." % [i + 1]
		var name_text: String
		var score_text: String
		var mat: StandardMaterial3D
		
		if i == _player_rank and is_high_score:
			# 玩家新高分 - 显示输入提示
			name_text = "_____"
			score_text = "%d" % current_score
			mat = green_material.duplicate()
			# 启用名字输入模式
			_is_entering_name = true
		elif actual_index >= 0 and actual_index < leaderboard.size():
			var entry: Dictionary = leaderboard[actual_index]
			name_text = str(entry["name"]).substr(0, 5)
			score_text = "%d" % entry["score"]
			mat = gold_material.duplicate()
		else:
			name_text = "-----"
			score_text = "---"
			mat = white_material.duplicate()
			mat.albedo_color = Color(0.5, 0.5, 0.5, 1.0)
		
		# 创建排名列（左对齐）+ 描边
		var rank_outline := _create_outline_mesh(rank_text, HORIZONTAL_ALIGNMENT_LEFT)
		rank_outline.position = Vector3(LEADERBOARD_LEFT_X, -y_offset, -0.005)
		rank_outline.scale = Vector3.ONE * row_scale * 1.04
		score_container.add_child(rank_outline)
		_rank_outline_meshes.append(rank_outline)
		
		var rank_mesh := _create_text_mesh_aligned(rank_text, mat.duplicate(), HORIZONTAL_ALIGNMENT_LEFT)
		rank_mesh.position = Vector3(LEADERBOARD_LEFT_X, -y_offset, 0)
		rank_mesh.scale = Vector3.ONE * row_scale
		score_container.add_child(rank_mesh)
		_rank_meshes.append(rank_mesh)
		
		# 创建名字列（居中）+ 描边
		var name_outline := _create_outline_mesh(name_text, HORIZONTAL_ALIGNMENT_CENTER)
		name_outline.position = Vector3(LEADERBOARD_NAME_X, -y_offset, -0.005)
		name_outline.scale = Vector3.ONE * row_scale * 1.04
		score_container.add_child(name_outline)
		_name_outline_meshes.append(name_outline)
		
		var name_mesh := _create_text_mesh_aligned(name_text, mat.duplicate(), HORIZONTAL_ALIGNMENT_CENTER)
		name_mesh.position = Vector3(LEADERBOARD_NAME_X, -y_offset, 0)
		name_mesh.scale = Vector3.ONE * row_scale
		score_container.add_child(name_mesh)
		_name_meshes.append(name_mesh)
		
		# 创建分数列（右对齐）+ 描边
		var points_outline := _create_outline_mesh(score_text, HORIZONTAL_ALIGNMENT_RIGHT)
		points_outline.position = Vector3(LEADERBOARD_SCORE_X, -y_offset, -0.005)
		points_outline.scale = Vector3.ONE * row_scale * 1.04
		score_container.add_child(points_outline)
		_points_outline_meshes.append(points_outline)
		
		var points_mesh := _create_text_mesh_aligned(score_text, mat.duplicate(), HORIZONTAL_ALIGNMENT_RIGHT)
		points_mesh.position = Vector3(LEADERBOARD_SCORE_X, -y_offset, 0)
		points_mesh.scale = Vector3.ONE * row_scale
		score_container.add_child(points_mesh)
		_points_meshes.append(points_mesh)
		
		y_offset += line_height
	
	# 如果没有进入排行榜，延迟后启用点击重启
	if not is_high_score:
		_start_restart_delay()


## 更新玩家名字显示
func _update_player_name_display() -> void:
	if _player_rank < 0 or _player_rank >= _name_meshes.size():
		return
	
	var mesh := _name_meshes[_player_rank]
	if not is_instance_valid(mesh):
		return
	
	var text_mesh := mesh.mesh as TextMesh
	if text_mesh:
		# 显示当前输入的名字，未输入部分用下划线填充
		var display_name := _player_name
		var remaining := MAX_NAME_LENGTH - _player_name.length()
		if remaining > 0:
			display_name += "_".repeat(remaining)
		text_mesh.text = display_name


## 触发输入特效（射击VFX + 屏幕抖动）
func _trigger_typing_effect() -> void:
	# 获取名字 TextMesh 的世界位置
	if _player_rank >= 0 and _player_rank < _name_meshes.size():
		var name_mesh := _name_meshes[_player_rank]
		if is_instance_valid(name_mesh):
			var vfx_position := name_mesh.global_position
			# 在名字附近随机偏移生成 VFX
			var random_offset := Vector3(
				randf_range(-0.2, 0.2),
				randf_range(-0.05, 0.1),
				randf_range(-0.1, 0.1)
			)
			vfx_position += random_offset
			
			# 生成射击特效
			if VFXManager:
				VFXManager.spawn_vfx("muzzle", vfx_position, Vector3.BACK)
	
	# 屏幕抖动
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("shake_camera"):
		player.shake_camera(0.03, 0.05)


## 提交玩家名字
func _submit_player_name() -> void:
	if _name_submitted:
		return
	
	# 如果名字为空，使用默认名字
	if _player_name.strip_edges().is_empty():
		_player_name = "PLAYER"
	
	_name_submitted = true
	_is_entering_name = false
	
	# 添加到排行榜
	LeaderboardManager.add_entry(_player_name, _current_score)
	
	# 发送信号
	name_submitted.emit(_player_name)
	
	# 延迟后刷新并显示重启提示
	await get_tree().create_timer(0.5).timeout
	_show_final_leaderboard()


func _auto_submit_score(score: int) -> void:
	# 已废弃，保留以兼容旧调用
	if _name_submitted:
		return
	_player_name = "PLAYER"
	_submit_player_name()


func _create_text_mesh(text: String, mat: StandardMaterial3D) -> MeshInstance3D:
	return _create_text_mesh_aligned(text, mat, HORIZONTAL_ALIGNMENT_CENTER)


func _create_text_mesh_aligned(text: String, mat: StandardMaterial3D, alignment: HorizontalAlignment) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	
	var text_mesh := TextMesh.new()
	text_mesh.font = _custom_font
	text_mesh.text = text
	text_mesh.font_size = 13
	text_mesh.depth = 0.05
	text_mesh.horizontal_alignment = alignment
	
	mesh_instance.mesh = text_mesh
	mesh_instance.material_override = mat
	
	return mesh_instance


func _create_outline_mesh(text: String, alignment: HorizontalAlignment) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	mesh_instance.visible = false  # 隐藏描边
	
	var text_mesh := TextMesh.new()
	text_mesh.font = _custom_font
	text_mesh.text = text
	text_mesh.font_size = 13
	text_mesh.depth = 0.02
	text_mesh.horizontal_alignment = alignment
	
	mesh_instance.mesh = text_mesh
	mesh_instance.material_override = outline_material.duplicate()
	
	return mesh_instance


func _show_final_leaderboard() -> void:
	_clear_scores()
	
	var leaderboard := LeaderboardManager.get_leaderboard()
	
	# 更新副标题
	if subtitle_mesh:
		var subtitle_text_mesh := subtitle_mesh.mesh as TextMesh
		var subtitle_mat := subtitle_mesh.material_override as StandardMaterial3D
		if subtitle_text_mesh:
			subtitle_text_mesh.text = "HIGH SCORES"
		if subtitle_mat:
			subtitle_mat.albedo_color = Color(1.0, 0.85, 0.3, 1.0)
			subtitle_mat.emission = Color(1.0, 0.7, 0.1, 1.0)
		# 同步描边
		if subtitle_outline:
			var outline_mesh := subtitle_outline.mesh as TextMesh
			if outline_mesh:
				outline_mesh.text = "HIGH SCORES"
	
	# 显示点击提示
	if hint_mesh:
		var hint_text_mesh := hint_mesh.mesh as TextMesh
		if hint_text_mesh:
			hint_text_mesh.text = "CLICK TO RESTART"
		hint_mesh.visible = true
	_can_click_restart = true
	
	# 重新生成排行榜 - 三列分离
	var y_offset: float = 0.0
	var line_height: float = 0.12
	var row_scale: float = 0.6
	
	for i in range(LeaderboardManager.MAX_ENTRIES):
		var rank_text: String = "%d." % [i + 1]
		var name_text: String
		var score_text: String
		var mat: StandardMaterial3D
		
		if i < leaderboard.size():
			var entry: Dictionary = leaderboard[i]
			name_text = str(entry["name"]).substr(0, 5)
			score_text = "%d" % entry["score"]
			# 高亮玩家记录
			if entry["score"] == _current_score:
				mat = green_material.duplicate()
			else:
				mat = gold_material.duplicate()
		else:
			name_text = "-----"
			score_text = "---"
			mat = white_material.duplicate()
			mat.albedo_color = Color(0.5, 0.5, 0.5, 1.0)
		
		# 创建排名列（左对齐）+ 描边
		var rank_outline := _create_outline_mesh(rank_text, HORIZONTAL_ALIGNMENT_LEFT)
		rank_outline.position = Vector3(LEADERBOARD_LEFT_X, -y_offset, -0.005)
		rank_outline.scale = Vector3.ONE * row_scale * 1.04
		score_container.add_child(rank_outline)
		_rank_outline_meshes.append(rank_outline)
		
		var rank_mesh := _create_text_mesh_aligned(rank_text, mat.duplicate(), HORIZONTAL_ALIGNMENT_LEFT)
		rank_mesh.position = Vector3(LEADERBOARD_LEFT_X, -y_offset, 0)
		rank_mesh.scale = Vector3.ONE * row_scale
		score_container.add_child(rank_mesh)
		_rank_meshes.append(rank_mesh)
		
		# 创建名字列（居中）+ 描边
		var name_outline := _create_outline_mesh(name_text, HORIZONTAL_ALIGNMENT_CENTER)
		name_outline.position = Vector3(LEADERBOARD_NAME_X, -y_offset, -0.005)
		name_outline.scale = Vector3.ONE * row_scale * 1.04
		score_container.add_child(name_outline)
		_name_outline_meshes.append(name_outline)
		
		var name_mesh := _create_text_mesh_aligned(name_text, mat.duplicate(), HORIZONTAL_ALIGNMENT_CENTER)
		name_mesh.position = Vector3(LEADERBOARD_NAME_X, -y_offset, 0)
		name_mesh.scale = Vector3.ONE * row_scale
		score_container.add_child(name_mesh)
		_name_meshes.append(name_mesh)
		
		# 创建分数列（右对齐）+ 描边
		var points_outline := _create_outline_mesh(score_text, HORIZONTAL_ALIGNMENT_RIGHT)
		points_outline.position = Vector3(LEADERBOARD_SCORE_X, -y_offset, -0.005)
		points_outline.scale = Vector3.ONE * row_scale * 1.04
		score_container.add_child(points_outline)
		_points_outline_meshes.append(points_outline)
		
		var points_mesh := _create_text_mesh_aligned(score_text, mat.duplicate(), HORIZONTAL_ALIGNMENT_RIGHT)
		points_mesh.position = Vector3(LEADERBOARD_SCORE_X, -y_offset, 0)
		points_mesh.scale = Vector3.ONE * row_scale
		score_container.add_child(points_mesh)
		_points_meshes.append(points_mesh)
		
		y_offset += line_height


func _clear_scores() -> void:
	# 清理旧的单行结构（兼容）
	for mesh in _score_meshes:
		if is_instance_valid(mesh):
			mesh.queue_free()
	_score_meshes.clear()
	
	# 清理三列结构
	for mesh in _rank_meshes:
		if is_instance_valid(mesh):
			mesh.queue_free()
	_rank_meshes.clear()
	
	for mesh in _name_meshes:
		if is_instance_valid(mesh):
			mesh.queue_free()
	_name_meshes.clear()
	
	for mesh in _points_meshes:
		if is_instance_valid(mesh):
			mesh.queue_free()
	_points_meshes.clear()
	
	# 清理描边结构
	for mesh in _rank_outline_meshes:
		if is_instance_valid(mesh):
			mesh.queue_free()
	_rank_outline_meshes.clear()
	
	for mesh in _name_outline_meshes:
		if is_instance_valid(mesh):
			mesh.queue_free()
	_name_outline_meshes.clear()
	
	for mesh in _points_outline_meshes:
		if is_instance_valid(mesh):
			mesh.queue_free()
	_points_outline_meshes.clear()
	
	# 清理提示描边
	if _hint_outline_mesh and is_instance_valid(_hint_outline_mesh):
		_hint_outline_mesh.queue_free()
		_hint_outline_mesh = null
	
	for child in score_container.get_children():
		child.queue_free()


func _start_restart_delay() -> void:
	await get_tree().create_timer(RESTART_DELAY).timeout
	if visible:
		_can_click_restart = true
		if hint_mesh:
			hint_mesh.visible = true
