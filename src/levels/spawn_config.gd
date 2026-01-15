@tool
extends Resource
class_name SpawnConfig
## Spawn配置资源 - 定义敌人和人质的基础数量

## 基础敌人数量（第1关）
@export var base_enemy_count: int = 4

## 基础人质数量（第1关）
@export var base_hostage_count: int = 1

## 基础射击提示时间（秒）
@export var base_hint_time: float = 3.0

## 达到满难度的关卡数
@export var max_difficulty_room: int = 20
