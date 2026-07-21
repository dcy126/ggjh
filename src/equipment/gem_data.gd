extends Resource
class_name GemData

@export var id: String = ""
@export var name: String = ""
@export var type: String = ""
@export var stats: Dictionary = {}
@export var quality: String = "白"

func _init():
	if stats.is_empty():
		stats = {}