extends Resource
class_name WorldArea

@export var id: String
@export var name: String
@export var description: String
@export var type: String = "主城"
@export var level_range: Vector2i = Vector2i(1, 10)
@export var connected_areas: Array[String] = []
@export var npcs: Array[String] = []
@export var shops: Array[String] = []
@export var enemies: Array[String] = []
@export var resources: Array[String] = []
@export var dungeons: Array[String] = []
@export var features: Array[String] = []
@export var events: Array[String] = []
@export var secret_locations: Array[String] = []
@export var background_music: String = ""
@export var background_image: String = ""
@export var is_visited: bool = false
@export var visit_count: int = 0
@export var discovered_secrets: Array[String] = []
@export var exploration_progress: float = 0.0
@export var boss: String = ""
@export var rewards: Array = []
@export var schedule: String = ""
@export var floors: int = 1
@export var chapters: int = 1

func _init():
	if connected_areas.is_empty():
		connected_areas = []
	if npcs.is_empty():
		npcs = []
	if shops.is_empty():
		shops = []
	if enemies.is_empty():
		enemies = []
	if resources.is_empty():
		resources = []
	if dungeons.is_empty():
		dungeons = []
	if features.is_empty():
		features = []
	if events.is_empty():
		events = []
	if secret_locations.is_empty():
		secret_locations = []
	if discovered_secrets.is_empty():
		discovered_secrets = []

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"description": description,
		"type": type,
		"level_range": level_range,
		"connected_areas": connected_areas,
		"npcs": npcs,
		"shops": shops,
		"enemies": enemies,
		"resources": resources,
		"dungeons": dungeons,
		"features": features,
		"events": events,
		"secret_locations": secret_locations,
		"background_music": background_music,
		"background_image": background_image,
		"is_visited": is_visited,
		"visit_count": visit_count,
		"discovered_secrets": discovered_secrets,
		"exploration_progress": exploration_progress
	}

func from_dict(data: Dictionary) -> WorldArea:
	id = data.get("id", "")
	name = data.get("name", "")
	description = data.get("description", "")
	type = data.get("type", "主城")
	level_range = data.get("level_range", Vector2i(1, 10))
	connected_areas = data.get("connected_areas", [])
	npcs = data.get("npcs", [])
	shops = data.get("shops", [])
	enemies = data.get("enemies", [])
	resources = data.get("resources", [])
	dungeons = data.get("dungeons", [])
	features = data.get("features", [])
	events = data.get("events", [])
	secret_locations = data.get("secret_locations", [])
	background_music = data.get("background_music", "")
	background_image = data.get("background_image", "")
	is_visited = data.get("is_visited", false)
	visit_count = data.get("visit_count", 0)
	discovered_secrets = data.get("discovered_secrets", [])
	exploration_progress = data.get("exploration_progress", 0.0)
	return self
