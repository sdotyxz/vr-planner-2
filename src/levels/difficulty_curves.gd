@tool
extends Resource
class_name DifficultyCurves
## 难度曲线配置资源 - 控制游戏难度随关卡的变化

## 敌人数量曲线：关卡越高，敌人乘数越大
@export var enemy_curve: Curve

## 人质数量曲线：关卡越高，人质乘数越大
@export var hostage_curve: Curve

## 射击提示时间曲线：关卡越高，提示消失越快（乘数越小）
@export var hint_time_curve: Curve

## 计算难度进度（0.0 - 1.0）
## max_room: 达到满难度的关卡数
static func calculate_progress(current_room: int, max_room: int = 20) -> float:
	return clampf(float(current_room - 1) / float(max_room), 0.0, 1.0)


## 获取当前关卡的敌人数量
func get_enemy_count(base_count: int, current_room: int, max_room: int = 20) -> int:
	if not enemy_curve:
		return base_count
	var progress := calculate_progress(current_room, max_room)
	return int(floor(base_count * enemy_curve.sample(progress)))


## 获取当前关卡的人质数量
func get_hostage_count(base_count: int, current_room: int, max_room: int = 20) -> int:
	if not hostage_curve:
		return base_count
	var progress := calculate_progress(current_room, max_room)
	return int(floor(base_count * hostage_curve.sample(progress)))


## 获取当前关卡的射击提示时间
func get_hint_time(base_time: float, current_room: int, max_room: int = 20) -> float:
	if not hint_time_curve:
		return base_time
	var progress := calculate_progress(current_room, max_room)
	return base_time * hint_time_curve.sample(progress)


## 创建默认曲线配置
static func create_default() -> DifficultyCurves:
	var curves := DifficultyCurves.new()
	
	# 敌人曲线：1.0 -> 1.5 -> 2.5
	curves.enemy_curve = Curve.new()
	curves.enemy_curve.add_point(Vector2(0.0, 1.0))   # 第1关：1.0倍
	curves.enemy_curve.add_point(Vector2(0.5, 1.5))   # 中期：1.5倍
	curves.enemy_curve.add_point(Vector2(1.0, 2.5))   # 后期：2.5倍
	
	# 人质曲线：1.0 -> 1.5 -> 2.0
	curves.hostage_curve = Curve.new()
	curves.hostage_curve.add_point(Vector2(0.0, 1.0))  # 第1关：1.0倍
	curves.hostage_curve.add_point(Vector2(0.5, 1.5))  # 中期：1.5倍
	curves.hostage_curve.add_point(Vector2(1.0, 2.0))  # 后期：2.0倍
	
	# 射击提示时间曲线：1.0 -> 0.7 -> 0.4（越来越快消失）
	curves.hint_time_curve = Curve.new()
	curves.hint_time_curve.add_point(Vector2(0.0, 1.0))  # 第1关：1.0倍
	curves.hint_time_curve.add_point(Vector2(0.5, 0.7))  # 中期：0.7倍
	curves.hint_time_curve.add_point(Vector2(1.0, 0.4))  # 后期：0.4倍
	
	return curves
