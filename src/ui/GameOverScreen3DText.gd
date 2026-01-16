extends Node3D
class_name GameOverScreen3DText
## 3D游戏结束界面 - 使用 TextMesh 显示3D文字

signal restart_requested
signal name_submitted(player_name: String)

@onready var title_mesh: MeshInstance3D = $TitleMesh
@onready var subtitle_mesh: MeshInstance3D = $SubtitleMesh
@onready var score_container: Node3D = $ScoreContainer
@onready var hint_mesh: MeshInstance3D = $HintMesh

## 材质模板（金色用于高分，白色用于普通）
var gold_material: StandardMaterial3D
var white_material: StandardMaterial3D
var green_material: StandardMaterial3D

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

## 延迟重启时间
const RESTART_DELAY: float = 2.0

## 动画时间
var _time: float = 0.0


func _ready() -> void:
	_setup_materials()
	_duplicate_resources()


func _process(delta: float) -> void:
	if not visible:
		return
	
	_time += delta
	
	# 标题摆动
	if title_mesh:
		title_mesh.rotation.y = sin(_time * SWING_SPEED) * TITLE_SWING_ANGLE
	
	# 副标题摆动（相位偏移）
	if subtitle_mesh:
		subtitle_mesh.rotation.y = sin(_time * SWING_SPEED + 0.5) * SWING_ANGLE * 0.5
	
	# 分数行摆动（每行不同相位）
	for i in range(_score_meshes.size()):
		var mesh := _score_meshes[i]
		if is_instance_valid(mesh):
			mesh.rotation.y = sin(_time * SWING_SPEED + i * 0.3) * SWING_ANGLE * 0.3


func _setup_materials() -> void:
	# 金色材质
	gold_material = StandardMaterial3D.new()
	gold_material.albedo_color = Color(1.0, 0.85, 0.3, 1.0)
	gold_material.emission_enabled = true
	gold_material.emission = Color(1.0, 0.7, 0.1, 1.0)
	gold_material.emission_energy_multiplier = 0.5
	
	# 白色材质
	white_material = StandardMaterial3D.new()
	white_material.albedo_color = Color(0.8, 0.8, 0.8, 1.0)
	white_material.emission_enabled = true
	white_material.emission = Color(0.5, 0.5, 0.5, 1.0)
	white_material.emission_energy_multiplier = 0.3
	
	# 绿色材质（玩家高分）
	green_material = StandardMaterial3D.new()
	green_material.albedo_color = Color(0.3, 1.0, 0.3, 1.0)
	green_material.emission_enabled = true
	green_material.emission = Color(0.2, 0.8, 0.2, 1.0)
	green_material.emission_energy_multiplier = 0.6


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
				subtitle_text_mesh.text = "NEW HIGH SCORE!"
				if subtitle_mat:
					subtitle_mat.albedo_color = Color(0.3, 1.0, 0.3, 1.0)
					subtitle_mat.emission = Color(0.2, 0.8, 0.2, 1.0)
			else:
				subtitle_text_mesh.text = "HIGH SCORES"
				if subtitle_mat:
					subtitle_mat.albedo_color = Color(1.0, 0.85, 0.3, 1.0)
					subtitle_mat.emission = Color(1.0, 0.7, 0.1, 1.0)
	
	# 隐藏点击提示
	if hint_mesh:
		hint_mesh.visible = false
	
	# 生成排行榜分数行
	var y_offset: float = 0.0
	var line_height: float = 0.08
	
	for i in range(LeaderboardManager.MAX_ENTRIES):
		var actual_index := i
		if _player_rank >= 0 and i > _player_rank:
			actual_index = i - 1
		
		var text: String
		var mat: StandardMaterial3D
		
		if i == _player_rank and is_high_score:
			# 玩家新高分 - 直接保存为 PLAYER
			text = "%d. PLAYER  %d" % [i + 1, current_score]
			mat = green_material.duplicate()
			# 自动提交
			call_deferred("_auto_submit_score", current_score)
		elif actual_index >= 0 and actual_index < leaderboard.size():
			var entry: Dictionary = leaderboard[actual_index]
			text = "%d. %s  %d" % [i + 1, entry["name"], entry["score"]]
			mat = gold_material.duplicate()
		else:
			text = "%d. ---  ---" % [i + 1]
			mat = white_material.duplicate()
			mat.albedo_color = Color(0.5, 0.5, 0.5, 1.0)
		
		var score_mesh := _create_text_mesh(text, mat)
		score_mesh.position = Vector3(0, -y_offset, 0)
		score_mesh.scale = Vector3.ONE * 0.5
		score_container.add_child(score_mesh)
		_score_meshes.append(score_mesh)
		
		y_offset += line_height
	
	# 如果没有进入排行榜，延迟后启用点击重启
	if not is_high_score:
		_start_restart_delay()


func _auto_submit_score(score: int) -> void:
	if _name_submitted:
		return
	_name_submitted = true
	
	# 添加到排行榜
	LeaderboardManager.add_entry("PLAYER", score)
	
	# 发送信号
	name_submitted.emit("PLAYER")
	
	# 延迟后刷新并显示重启提示
	await get_tree().create_timer(1.0).timeout
	_show_final_leaderboard()


func _create_text_mesh(text: String, mat: StandardMaterial3D) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	
	var text_mesh := TextMesh.new()
	text_mesh.text = text
	text_mesh.font_size = 32
	text_mesh.depth = 0.2
	
	mesh_instance.mesh = text_mesh
	mesh_instance.material_override = mat
	
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
	
	# 显示点击提示
	if hint_mesh:
		hint_mesh.visible = true
	_can_click_restart = true
	
	# 重新生成排行榜
	var y_offset: float = 0.0
	var line_height: float = 0.08
	
	for i in range(LeaderboardManager.MAX_ENTRIES):
		var text: String
		var mat: StandardMaterial3D
		
		if i < leaderboard.size():
			var entry: Dictionary = leaderboard[i]
			text = "%d. %s  %d" % [i + 1, entry["name"], entry["score"]]
			# 高亮玩家记录
			if entry["score"] == _current_score:
				mat = green_material.duplicate()
			else:
				mat = gold_material.duplicate()
		else:
			text = "%d. ---  ---" % [i + 1]
			mat = white_material.duplicate()
			mat.albedo_color = Color(0.5, 0.5, 0.5, 1.0)
		
		var score_mesh := _create_text_mesh(text, mat)
		score_mesh.position = Vector3(0, -y_offset, 0)
		score_mesh.scale = Vector3.ONE * 0.5
		score_container.add_child(score_mesh)
		_score_meshes.append(score_mesh)
		
		y_offset += line_height


func _clear_scores() -> void:
	for mesh in _score_meshes:
		if is_instance_valid(mesh):
			mesh.queue_free()
	_score_meshes.clear()
	
	for child in score_container.get_children():
		child.queue_free()


func _start_restart_delay() -> void:
	await get_tree().create_timer(RESTART_DELAY).timeout
	if visible:
		_can_click_restart = true
		if hint_mesh:
			hint_mesh.visible = true
