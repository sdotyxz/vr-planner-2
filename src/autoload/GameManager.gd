extends Node
## 游戏状态管理器 - 全局单例

enum GameState {
	START,
	PLAYING,
	BREACH,
	GAME_OVER,
	VICTORY
}

var current_state: GameState = GameState.START

# 全局统计
var score: int = 0
var kills: int = 0
var rooms_cleared: int = 0

signal state_changed(new_state: GameState)
signal score_updated(new_score: int)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func set_state(new_state: GameState) -> void:
	current_state = new_state
	state_changed.emit(new_state)
	
	match new_state:
		GameState.BREACH:
			Engine.time_scale = 0.5
		GameState.PLAYING:
			Engine.time_scale = 1.0
		GameState.GAME_OVER, GameState.VICTORY:
			Engine.time_scale = 1.0


func add_score(amount: int) -> void:
	score += amount
	score_updated.emit(score)


func add_kill() -> void:
	kills += 1


func reset_stats() -> void:
	score = 0
	kills = 0
	rooms_cleared = 0
	Engine.time_scale = 1.0
