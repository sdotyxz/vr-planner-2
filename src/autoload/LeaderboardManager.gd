extends Node
## 本地排行榜管理器 - 街机风格，保存前10名最高分

const SAVE_PATH := "user://leaderboard.json"
const MAX_ENTRIES := 10
const MAX_NAME_LENGTH := 5

## 排行榜数据 [{name: String, score: int}, ...]
var _leaderboard: Array[Dictionary] = []

## 排行榜加载完成信号
signal leaderboard_loaded


func _ready() -> void:
	load_leaderboard()


## 加载排行榜数据
func load_leaderboard() -> void:
	_leaderboard.clear()
	
	if not FileAccess.file_exists(SAVE_PATH):
		# 初始化默认排行榜
		_init_default_leaderboard()
		save_leaderboard()
		leaderboard_loaded.emit()
		return
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_warning("LeaderboardManager: Failed to open leaderboard file")
		_init_default_leaderboard()
		leaderboard_loaded.emit()
		return
	
	var json_string := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var parse_result := json.parse(json_string)
	if parse_result != OK:
		push_warning("LeaderboardManager: Failed to parse leaderboard JSON")
		_init_default_leaderboard()
		leaderboard_loaded.emit()
		return
	
	var data = json.get_data()
	if data is Array:
		for entry in data:
			if entry is Dictionary and entry.has("name") and entry.has("score"):
				_leaderboard.append({
					"name": str(entry["name"]).substr(0, MAX_NAME_LENGTH),
					"score": int(entry["score"])
				})
	
	_sort_leaderboard()
	leaderboard_loaded.emit()


## 保存排行榜数据
func save_leaderboard() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("LeaderboardManager: Failed to save leaderboard file")
		return
	
	var json_string := JSON.stringify(_leaderboard, "\t")
	file.store_string(json_string)
	file.close()


## 初始化默认排行榜（空的或带有示例数据）
func _init_default_leaderboard() -> void:
	_leaderboard = [
		{"name": "AAA", "score": 1000},
		{"name": "BBB", "score": 800},
		{"name": "CCC", "score": 600},
		{"name": "DDD", "score": 400},
		{"name": "EEE", "score": 200},
	]


## 排序排行榜（按分数降序）
func _sort_leaderboard() -> void:
	_leaderboard.sort_custom(_compare_scores)
	# 只保留前10名
	if _leaderboard.size() > MAX_ENTRIES:
		_leaderboard.resize(MAX_ENTRIES)


## 比较函数：按分数降序
func _compare_scores(a: Dictionary, b: Dictionary) -> bool:
	return a["score"] > b["score"]


## 检查分数是否能进入排行榜
func is_high_score(score: int) -> bool:
	if _leaderboard.size() < MAX_ENTRIES:
		return true
	# 检查是否高于最低分
	if _leaderboard.is_empty():
		return true
	return score > _leaderboard[_leaderboard.size() - 1]["score"]


## 添加新记录
## name: 玩家名字（最多5个字符，仅字母和数字）
## score: 分数
## 返回: 排名位置（1-10），如果未进入排行榜返回 -1
func add_entry(player_name: String, score: int) -> int:
	# 过滤名字：只保留字母和数字，最多5个字符
	var filtered_name := _filter_name(player_name)
	if filtered_name.is_empty():
		filtered_name = "ANON"
	
	var entry := {
		"name": filtered_name,
		"score": score
	}
	
	_leaderboard.append(entry)
	_sort_leaderboard()
	save_leaderboard()
	
	# 查找排名
	for i in range(_leaderboard.size()):
		if _leaderboard[i] == entry:
			return i + 1  # 1-based ranking
	
	return -1


## 过滤玩家名字：只保留字母和数字，最多5个字符
func _filter_name(input: String) -> String:
	var regex := RegEx.new()
	regex.compile("[^a-zA-Z0-9]")
	var filtered := regex.sub(input, "", true)
	return filtered.substr(0, MAX_NAME_LENGTH).to_upper()


## 验证名字是否有效
func is_valid_name(input: String) -> bool:
	if input.is_empty():
		return false
	var regex := RegEx.new()
	regex.compile("^[a-zA-Z0-9]+$")
	return regex.search(input) != null


## 获取排行榜数据
func get_leaderboard() -> Array[Dictionary]:
	return _leaderboard


## 获取指定排名的记录
func get_entry(rank: int) -> Dictionary:
	var index := rank - 1
	if index >= 0 and index < _leaderboard.size():
		return _leaderboard[index]
	return {}


## 获取最低上榜分数
func get_min_score() -> int:
	if _leaderboard.size() < MAX_ENTRIES:
		return 0
	if _leaderboard.is_empty():
		return 0
	return _leaderboard[_leaderboard.size() - 1]["score"]
