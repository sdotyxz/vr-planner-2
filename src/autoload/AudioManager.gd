extends Node
## 音频管理器 - 全局单例

var sfx_library: Dictionary = {}
var bgm_player: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	# 预加载音效（当有音频文件时取消注释）
	# sfx_library["fire"] = load("res://assets/audio/fire.wav")
	# sfx_library["hit"] = load("res://assets/audio/hit.wav")
	# sfx_library["error"] = load("res://assets/audio/error.wav")


func play_sfx(sfx_name: String) -> void:
	if not sfx_library.has(sfx_name):
		return
	
	var player := AudioStreamPlayer.new()
	player.stream = sfx_library[sfx_name]
	player.autoplay = true
	add_child(player)
	player.finished.connect(player.queue_free)


func play_bgm(stream: AudioStream) -> void:
	if bgm_player.stream != stream:
		bgm_player.stream = stream
		bgm_player.play()


func stop_bgm() -> void:
	bgm_player.stop()
