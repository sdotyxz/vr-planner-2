extends Node
## 音频管理器 - 全局单例

var sfx_library: Dictionary = {}  ## 单个音效 {name: AudioStream}
var sfx_library_array: Dictionary = {}  ## 多个音效（随机播放）{name: Array[AudioStream]}
var bgm_player: AudioStreamPlayer

## BGM 播放列表
var bgm_playlist: Array[AudioStream] = []
## 是否正在循环播放BGM
var bgm_loop_enabled: bool = false
## 上一首播放的BGM索引（用于避免连续重复）
var _last_bgm_index: int = -1
## 当前BGM已循环次数
var _bgm_loop_count: int = 0
## 每首BGM循环播放次数（播放完这么多次后切换下一首）
const BGM_LOOPS_BEFORE_SWITCH: int = 3


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	bgm_player = AudioStreamPlayer.new()
	bgm_player.volume_db = -10.0  # BGM音量调小
	add_child(bgm_player)
	
	# 连接BGM播放完成信号
	bgm_player.finished.connect(_on_bgm_finished)
	
	# 预加载音效
	_preload_sound_effects()
	
	# 预加载BGM
	_preload_bgm()


## 预加载所有音效
func _preload_sound_effects() -> void:
	# 射击音效（随机）
	sfx_library_array["fire"] = [
		load("res://assets/sfx/gun/gun_shot_01.wav"),
		load("res://assets/sfx/gun/gun_shot_02.wav"),
		load("res://assets/sfx/gun/gun_shot_03.wav"),
		load("res://assets/sfx/gun/gun_shot_04.wav"),
		load("res://assets/sfx/gun/gun_shot_05.wav"),
	]
	
	# 敌人死亡音效（随机）
	sfx_library_array["enemy_die"] = [
		load("res://assets/sfx/die/Male_enemy_death_gru_#1-1768628802992.mp3"),
		load("res://assets/sfx/die/Male_enemy_death_gru_#2-1768628817765.mp3"),
		load("res://assets/sfx/die/Male_enemy_death_gru_#3-1768628823325.mp3"),
		load("res://assets/sfx/die/Male_enemy_death_gru_#4-1768628828446.mp3"),
	]
	
	# 房间通关音效（随机）
	sfx_library_array["room_clear"] = [
		load("res://assets/sfx/clear/Cinematic_tactical_s_#1-1768629361209.mp3"),
		load("res://assets/sfx/clear/Futuristic_tactical__#3-1768629433102.mp3"),
	]
	
	# 游戏结束音效（随机）
	sfx_library_array["game_over"] = [
		load("res://assets/sfx/gamemove/Game_over_sound_effe_#1-1768628694320.mp3"),
		load("res://assets/sfx/gamemove/Melancholic_descendi_#1-1768621247570.mp3"),
	]
	
	# 脚步声（随机）
	sfx_library_array["footstep"] = [
		load("res://assets/sfx/foot/Foley_tactical_boots_#1-1768631501785.mp3"),
		load("res://assets/sfx/foot/Foley_tactical_boots_#2-1768631517515.mp3"),
		load("res://assets/sfx/foot/Foley_tactical_boots_#3-1768631522273.mp3"),
		load("res://assets/sfx/foot/Foley_tactical_boots_#4-1768631527276.mp3"),
	]
	
	# 破门音效（随机）
	sfx_library_array["door_kick"] = [
		load("res://assets/sfx/door/Sharp_kick_hitting_w_#1-1768631880490.mp3"),
		load("res://assets/sfx/door/Sharp_kick_hitting_w_#2-1768631766622.mp3"),
		load("res://assets/sfx/door/Sharp_kick_hitting_w_#2-1768631886833.mp3"),
		load("res://assets/sfx/door/Sharp_kick_hitting_w_#3-1768631891815.mp3"),
		load("res://assets/sfx/door/Sharp_kick_hitting_w_#4-1768631783855.mp3"),
		load("res://assets/sfx/door/Sharp_kick_hitting_w_#4-1768631896588.mp3"),
	]
	
	# 上弹音效（随机）
	sfx_library_array["reload"] = [
		load("res://assets/sfx/reload/Exaggerated_cinemati_#1-1768632583836.mp3"),
		load("res://assets/sfx/reload/Exaggerated_cinemati_#2-1768632471215.mp3"),
		load("res://assets/sfx/reload/Exaggerated_cinemati_#3-1768632494735.mp3"),
		load("res://assets/sfx/reload/Exaggerated_cinemati_#3-1768632613054.mp3"),
		load("res://assets/sfx/reload/Exaggerated_cinemati_#4-1768632618946.mp3"),
	]
	
	# 家具破坏音效（随机）
	sfx_library_array["furniture_break"] = [
		load("res://assets/sfx/furniture_break/A_heavy_wooden_chair_#1-1768876130176.mp3"),
		load("res://assets/sfx/furniture_break/A_heavy_wooden_chair_#2-1768876130177.mp3"),
		load("res://assets/sfx/furniture_break/A_heavy_wooden_chair_#3-1768876176616.mp3"),
		load("res://assets/sfx/furniture_break/A_heavy_wooden_chair_#4-1768876176617.mp3"),
		load("res://assets/sfx/furniture_break/A_heavy_wooden_chair_#1-1768876247828.mp3"),
		load("res://assets/sfx/furniture_break/A_heavy_wooden_chair_#2-1768876247828.mp3"),
		load("res://assets/sfx/furniture_break/A_heavy_wooden_chair_#3-1768876247829.mp3"),
		load("res://assets/sfx/furniture_break/A_heavy_wooden_chair_#4-1768876247830.mp3"),
	]
	
	# 开始游戏音效
	sfx_library["game_start"] = load("res://assets/sfx/start/Heavy_military_equip_#1-1768633177894.mp3")


## 预加载所有BGM
func _preload_bgm() -> void:
	bgm_playlist = [
		load("res://assets/bgm/bgm_01.mp3"),
		load("res://assets/bgm/bgm_02.mp3"),
		load("res://assets/bgm/bgm_03.mp3"),
		load("res://assets/bgm/bgm_04.mp3"),
		load("res://assets/bgm/bgm_05.mp3"),
		load("res://assets/bgm/bgm_06.mp3"),
		load("res://assets/bgm/bgm_07.mp3"),
	]


## 播放音效（如果有多个同名音效，随机播放其中一个）
func play_sfx(sfx_name: String, volume_db: float = 0.0) -> void:
	var stream: AudioStream = null
	
	# 优先从数组库中获取（随机）
	if sfx_library_array.has(sfx_name):
		var sounds: Array = sfx_library_array[sfx_name]
		if sounds.size() > 0:
			stream = sounds[randi() % sounds.size()]
	# 然后从单个音效库获取
	elif sfx_library.has(sfx_name):
		stream = sfx_library[sfx_name]
	
	if not stream:
		return
	
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	player.autoplay = true
	add_child(player)
	player.finished.connect(player.queue_free)


## 播放音效并返回播放器（可用于等待播放完成）
func play_sfx_and_wait(sfx_name: String, volume_db: float = 0.0) -> AudioStreamPlayer:
	var stream: AudioStream = null
	
	# 优先从数组库中获取（随机）
	if sfx_library_array.has(sfx_name):
		var sounds: Array = sfx_library_array[sfx_name]
		if sounds.size() > 0:
			stream = sounds[randi() % sounds.size()]
	# 然后从单个音效库获取
	elif sfx_library.has(sfx_name):
		stream = sfx_library[sfx_name]
	
	if not stream:
		return null
	
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	player.autoplay = true
	add_child(player)
	player.finished.connect(player.queue_free)
	return player


## 播放3D空间音效（有位置感）
func play_sfx_3d(sfx_name: String, position: Vector3, volume_db: float = 0.0) -> void:
	var stream: AudioStream = null
	
	# 优先从数组库中获取（随机）
	if sfx_library_array.has(sfx_name):
		var sounds: Array = sfx_library_array[sfx_name]
		if sounds.size() > 0:
			stream = sounds[randi() % sounds.size()]
	# 然后从单个音效库获取
	elif sfx_library.has(sfx_name):
		stream = sfx_library[sfx_name]
	
	if not stream:
		return
	
	var player := AudioStreamPlayer3D.new()
	player.stream = stream
	player.volume_db = volume_db
	player.autoplay = true
	player.max_distance = 50.0
	add_child(player)
	player.global_position = position
	player.finished.connect(player.queue_free)


func play_bgm(stream: AudioStream) -> void:
	if bgm_player.stream != stream:
		bgm_player.stream = stream
		bgm_player.play()


func stop_bgm() -> void:
	bgm_loop_enabled = false
	bgm_player.stop()


## 开始随机循环播放BGM
func start_bgm_loop() -> void:
	if bgm_playlist.is_empty():
		return
	
	# 如果已经在播放，不重复启动
	if bgm_loop_enabled and bgm_player.playing:
		return
	
	bgm_loop_enabled = true
	_bgm_loop_count = 0
	_play_random_bgm()


## 播放随机BGM（避免连续重复）
func _play_random_bgm() -> void:
	if bgm_playlist.is_empty():
		return
	
	var new_index: int
	if bgm_playlist.size() == 1:
		new_index = 0
	else:
		# 避免连续播放同一首
		new_index = randi() % bgm_playlist.size()
		while new_index == _last_bgm_index:
			new_index = randi() % bgm_playlist.size()
	
	_last_bgm_index = new_index
	bgm_player.stream = bgm_playlist[new_index]
	bgm_player.play()


## BGM播放完成时自动播放下一首或重复当前曲目
func _on_bgm_finished() -> void:
	if not bgm_loop_enabled:
		return
	
	_bgm_loop_count += 1
	
	# 循环次数未达到阈值，重复播放当前曲目
	if _bgm_loop_count < BGM_LOOPS_BEFORE_SWITCH:
		bgm_player.play()
	else:
		# 达到循环次数，切换到下一首
		_bgm_loop_count = 0
		_play_random_bgm()
