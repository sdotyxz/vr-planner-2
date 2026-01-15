extends Node3D
class_name GameOverScreen3D
## 3D游戏结束界面 - 在场景中显示排行榜，使用SubViewport渲染UI

signal restart_requested
signal name_submitted(player_name: String)

@onready var viewport: SubViewport = $SubViewport
@onready var sprite: Sprite3D = $Sprite3D
@onready var ui_root: Control = $SubViewport/GameOverUI

## UI组件引用
var title_label: Label = null
var leaderboard_title: Label = null
var leaderboard_container: VBoxContainer = null
var click_hint: Label = null

## 状态变量
var _player_rank: int = -1
var _name_submitted: bool = false
var _can_click_restart: bool = false
var _current_input: LineEdit = null

## 延迟重启时间
const RESTART_DELAY: float = 2.0


func _ready() -> void:
	# 初始化UI组件引用
	_setup_ui_references()
	
	# 等待两帧确保 viewport 已完全渲染
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 设置viewport纹理到Sprite3D
	if sprite and viewport:
		sprite.texture = viewport.get_texture()


func _setup_ui_references() -> void:
	if not ui_root:
		return
	
	# 查找UI组件
	title_label = ui_root.get_node_or_null("VBoxContainer/Title")
	leaderboard_title = ui_root.get_node_or_null("VBoxContainer/LeaderboardTitle")
	leaderboard_container = ui_root.get_node_or_null("VBoxContainer/LeaderboardContainer")
	click_hint = ui_root.get_node_or_null("VBoxContainer/ClickHint")


func _input(event: InputEvent) -> void:
	# 只有在显示时才处理输入
	if not visible:
		return
	
	# 回车键提交名字
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		if _current_input and not _name_submitted:
			_submit_name(_current_input.text)
			get_viewport().set_input_as_handled()
			return
	
	# 鼠标点击重启游戏
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _can_click_restart:
			restart_requested.emit()
			get_viewport().set_input_as_handled()
			return
		
		# 转发鼠标事件到SubViewport（用于输入框聚焦）
		_forward_mouse_event(event)


func _forward_mouse_event(event: InputEventMouseButton) -> void:
	if not viewport:
		return
	
	# 计算viewport中的位置（假设sprite全屏覆盖）
	var viewport_size := viewport.size
	var screen_size := get_viewport().get_visible_rect().size
	
	var new_event := event.duplicate() as InputEventMouseButton
	new_event.position = event.position * Vector2(viewport_size) / screen_size
	viewport.push_input(new_event)


## 显示排行榜（带输入框如果进入排行榜）
func show_leaderboard(current_score: int) -> void:
	visible = true
	_name_submitted = false
	_can_click_restart = false
	_current_input = null
	
	_clear_leaderboard()
	
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
	
	# 更新标题
	if leaderboard_title:
		if is_high_score:
			leaderboard_title.text = "NEW HIGH SCORE!"
			leaderboard_title.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3, 1))
		else:
			leaderboard_title.text = "HIGH SCORES"
			leaderboard_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1))
	
	# 隐藏点击提示
	if click_hint:
		click_hint.visible = false
	
	# 生成排行榜行
	for i in range(LeaderboardManager.MAX_ENTRIES):
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		# 如果是玩家排名位置且未提交，显示输入框
		if i == _player_rank and is_high_score:
			_create_input_row(row, i + 1, current_score)
			leaderboard_container.add_child(row)
			continue
		
		# 计算实际数据索引
		var actual_index := i
		if _player_rank >= 0 and i > _player_rank:
			actual_index = i - 1
		
		_create_score_row(row, i + 1, leaderboard, actual_index)
		leaderboard_container.add_child(row)
	
	# 如果没有进入排行榜，延迟后启用点击重启
	if not is_high_score:
		_start_restart_delay()


## 创建带名字输入框的行（无按钮，只用回车确认）
func _create_input_row(row: HBoxContainer, rank: int, score: int) -> void:
	# 排名
	var rank_label := Label.new()
	rank_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rank_label.custom_minimum_size = Vector2(50, 0)
	rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	rank_label.add_theme_font_size_override("font_size", 32)
	rank_label.add_theme_constant_override("outline_size", 2)
	rank_label.add_theme_color_override("font_outline_color", Color.BLACK)
	rank_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3, 1))
	rank_label.text = "%d." % rank
	
	# 名字输入框
	var input := LineEdit.new()
	input.custom_minimum_size = Vector2(200, 0)
	input.add_theme_font_size_override("font_size", 32)
	input.max_length = 5
	input.placeholder_text = "NAME"
	input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	input.caret_blink = true
	input.text_submitted.connect(_on_name_input_submitted)
	
	# 保存输入框引用
	_current_input = input
	
	# 分数
	var score_lbl := Label.new()
	score_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	score_lbl.custom_minimum_size = Vector2(100, 0)
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_lbl.add_theme_font_size_override("font_size", 32)
	score_lbl.add_theme_constant_override("outline_size", 2)
	score_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	score_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3, 1))
	score_lbl.text = str(score)
	
	row.add_child(rank_label)
	row.add_child(input)
	row.add_child(score_lbl)
	
	# 延迟获取焦点
	input.call_deferred("grab_focus")


## 创建普通分数行
func _create_score_row(row: HBoxContainer, rank: int, leaderboard: Array, data_index: int) -> void:
	# 排名
	var rank_label := Label.new()
	rank_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rank_label.custom_minimum_size = Vector2(50, 0)
	rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	rank_label.add_theme_font_size_override("font_size", 32)
	rank_label.add_theme_constant_override("outline_size", 2)
	rank_label.add_theme_color_override("font_outline_color", Color.BLACK)
	
	# 名字
	var name_label := Label.new()
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.custom_minimum_size = Vector2(200, 0)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 32)
	name_label.add_theme_constant_override("outline_size", 2)
	name_label.add_theme_color_override("font_outline_color", Color.BLACK)
	
	# 分数
	var score_lbl := Label.new()
	score_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	score_lbl.custom_minimum_size = Vector2(100, 0)
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_lbl.add_theme_font_size_override("font_size", 32)
	score_lbl.add_theme_constant_override("outline_size", 2)
	score_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	
	if data_index >= 0 and data_index < leaderboard.size():
		var entry: Dictionary = leaderboard[data_index]
		rank_label.text = "%d." % rank
		name_label.text = entry["name"]
		score_lbl.text = str(entry["score"])
	else:
		rank_label.text = "%d." % rank
		name_label.text = "---"
		score_lbl.text = "---"
		rank_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
		name_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
		score_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
	
	row.add_child(rank_label)
	row.add_child(name_label)
	row.add_child(score_lbl)


func _on_name_input_submitted(text: String) -> void:
	_submit_name(text)


func _submit_name(text: String) -> void:
	if _name_submitted:
		return
	_name_submitted = true
	
	var player_name := text.strip_edges()
	
	# 过滤非法字符
	if not LeaderboardManager.is_valid_name(player_name):
		player_name = "ANON"
	
	# 添加到排行榜
	LeaderboardManager.add_entry(player_name, GameManager.score)
	
	# 发送信号
	name_submitted.emit(player_name)
	
	# 刷新排行榜显示
	_show_final_leaderboard()


func _show_final_leaderboard() -> void:
	_clear_leaderboard()
	_current_input = null
	
	var leaderboard := LeaderboardManager.get_leaderboard()
	
	if leaderboard_title:
		leaderboard_title.text = "HIGH SCORES"
		leaderboard_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1))
	
	# 显示点击提示，启用点击重启
	if click_hint:
		click_hint.visible = true
	_can_click_restart = true
	
	for i in range(LeaderboardManager.MAX_ENTRIES):
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_create_score_row(row, i + 1, leaderboard, i)
		
		# 高亮玩家的记录
		if i < leaderboard.size() and leaderboard[i]["score"] == GameManager.score:
			for child in row.get_children():
				if child is Label:
					child.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3, 1))
		
		leaderboard_container.add_child(row)


func _clear_leaderboard() -> void:
	if not leaderboard_container:
		return
	for child in leaderboard_container.get_children():
		child.queue_free()


func _start_restart_delay() -> void:
	await get_tree().create_timer(RESTART_DELAY).timeout
	# 确保仍在显示状态
	if visible:
		_can_click_restart = true
		if click_hint:
			click_hint.visible = true
