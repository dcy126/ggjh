extends Resource
class_name SummonData

@export var summon_id: String = ""
@export var name: String = ""
@export var base_hp: int = 500
@export var base_atk: int = 50
@export var base_def: int = 20
@export var base_spd: int = 50
@export var skills: Array[String] = []
@export var ai: String = "attack_nearest"
