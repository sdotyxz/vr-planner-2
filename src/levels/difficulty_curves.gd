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

## 射击提示间隔曲线：关卡越高，敌人提示出现间隔越短（乘数越小）
@export var hint_interval_curve: Curve

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


## 获取当前关卡的射击提示间隔时间（最小值0.2秒）
func get_hint_interval(base_interval: float, current_room: int, max_room: int = 20) -> float:
	if not hint_interval_curve:
		return base_interval
	var progress := calculate_progress(current_room, max_room)
	var interval := base_interval * hint_interval_curve.sample(progress)
	return maxf(interval, 0.2)  # 最小间隔0.2秒，避免过于密集


## 创建默认曲线配置（指数曲线形状，整体提升约75%难度，12关满难度）
static func create_default() -> DifficultyCurves:
	var curves := DifficultyCurves.new()
	
	# 敌人曲线：1.9 -> 3.2 -> 5.0（指数曲线，再提升25%）
	curves.enemy_curve = Curve.new()
	curves.enemy_curve.add_point(Vector2(0.0, 1.9))   # 第1关：1.9倍
	curves.enemy_curve.add_point(Vector2(0.5, 3.2))   # 中期：3.2倍
	curves.enemy_curve.add_point(Vector2(1.0, 5.0))   # 后期：5.0倍
	
	# 人质曲线：1.75 -> 2.75 -> 3.75（指数曲线，再提升25%）
	curves.hostage_curve = Curve.new()
	curves.hostage_curve.add_point(Vector2(0.0, 1.75))  # 第1关：1.75倍
	curves.hostage_curve.add_point(Vector2(0.5, 2.75))  # 中期：2.75倍
	curves.hostage_curve.add_point(Vector2(1.0, 3.75))  # 后期：3.75倍
	
	# 射击提示时间曲线：0.7 -> 0.35 -> 0.2（越来越快消失，再压缩20%）
	curves.hint_time_curve = Curve.new()
	curves.hint_time_curve.add_point(Vector2(0.0, 0.7))   # 第1关：0.7倍（2.1秒）
	curves.hint_time_curve.add_point(Vector2(0.5, 0.35))  # 中期：0.35倍（1.05秒）
	curves.hint_time_curve.add_point(Vector2(1.0, 0.2))   # 后期：0.2倍（0.6秒）
	
	# 射击提示间隔曲线：0.65 -> 0.28 -> 0.12（越来越快出现，再压缩20%）
	curves.hint_interval_curve = Curve.new()
	curves.hint_interval_curve.add_point(Vector2(0.0, 0.65))  # 第1关：0.65倍（间隔0.65秒）
	curves.hint_interval_curve.add_point(Vector2(0.5, 0.28))  # 中期：0.28倍（间隔0.28秒）
	curves.hint_interval_curve.add_point(Vector2(1.0, 0.12))  # 后期：0.12倍（间隔0.2秒，受最小值限制）
	
	return curves
