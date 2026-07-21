extends RefCounted
class_name BattleGrid

@export var width: int = 9
@export var height: int = 6
@export var cell_size: float = 100.0

var characters: Array[BattleCharacter] = []
var grid_data: Array[Array[Dictionary]] = []
var traps: Dictionary = {}  # position -> trap_data
var mines: Dictionary = {}  # position -> mine_data
var obstacles: Array[Vector2i] = []

func _init():
	_init_grid()

func _init_grid():
	grid_data.resize(height)
	for y in range(height):
		grid_data[y].resize(width)
		for x in range(width):
			grid_data[y][x] = {
				"character": null,
				"terrain": "平地",
				"height": 0,
				"movement_cost": 1
			}

func is_valid_position(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < width and pos.y >= 0 and pos.y < height

func get_character_at(pos: Vector2i) -> BattleCharacter:
	if is_valid_position(pos):
		return grid_data[pos.y][pos.x]["character"]
	return null

func add_character(character: BattleCharacter, pos: Vector2i) -> bool:
	if not is_valid_position(pos):
		return false
	if grid_data[pos.y][pos.x]["character"] != null:
		return false
	
	grid_data[pos.y][pos.x]["character"] = character
	character.grid_pos = pos
	if character not in characters:
		characters.append(character)
	return true

func remove_character(character: BattleCharacter) -> bool:
	if character.grid_pos == Vector2i(-1, -1):
		return false
	
	var pos = character.grid_pos
	if is_valid_position(pos) and grid_data[pos.y][pos.x]["character"] == character:
		grid_data[pos.y][pos.x]["character"] = null
		character.grid_pos = Vector2i(-1, -1)
		characters.erase(character)
		return true
	return false

func move_character(character: BattleCharacter, new_pos: Vector2i) -> bool:
	if not is_valid_position(new_pos):
		return false
	if grid_data[new_pos.y][new_pos.x]["character"] != null:
		return false
	
	var old_pos = character.grid_pos
	if is_valid_position(old_pos):
		grid_data[old_pos.y][old_pos.x]["character"] = null
	
	grid_data[new_pos.y][new_pos.x]["character"] = character
	character.grid_pos = new_pos
	return true

func get_characters_in_range(center: Vector2i, range_min: int, range_max: int, team_filter: int = -1) -> Array[BattleCharacter]:
	var result = []
	for x in range(width):
		for y in range(height):
			var pos = Vector2i(x, y)
			var char = get_character_at(pos)
			if char and char.is_alive():
				var dist = center.distance_to(pos)
				if dist >= range_min and dist <= range_max:
					if team_filter == -1 or char.team == team_filter:
						result.append(char)
	return result

func get_characters_in_aoe(center: Vector2i, pattern: String, size: int, team_filter: int = -1) -> Array[BattleCharacter]:
	var positions = get_aoe_positions(center, pattern, size)
	var result = []
	for pos in positions:
		var char = get_character_at(pos)
		if char and char.is_alive():
			if team_filter == -1 or char.team == team_filter:
				result.append(char)
	return result

func get_aoe_positions(center: Vector2i, pattern: String, size: int) -> Array[Vector2i]:
	var positions = []
	match pattern:
		"单体":
			if is_valid_position(center):
				positions.append(center)
		"横排":
			for x in range(max(0, center.x - size), min(width, center.x + size + 1)):
				positions.append(Vector2i(x, center.y))
		"竖排":
			for y in range(max(0, center.y - size), min(height, center.y + size + 1)):
				positions.append(Vector2i(center.x, y))
		"十字":
			for i in range(-size, size + 1):
				var p1 = Vector2i(center.x + i, center.y)
				var p2 = Vector2i(center.x, center.y + i)
				if is_valid_position(p1):
					positions.append(p1)
				if is_valid_position(p2):
					positions.append(p2)
		"菱形":
			for x in range(-size, size + 1):
				for y in range(-size + abs(x), size - abs(x) + 1):
					var pos = Vector2i(center.x + x, center.y + y)
					if is_valid_position(pos):
						positions.append(pos)
		"全体":
			for x in range(width):
				for y in range(height):
					positions.append(Vector2i(x, y))
		"圆形":
			for x in range(max(0, center.x - size), min(width, center.x + size + 1)):
				for y in range(max(0, center.y - size), min(height, center.y + size + 1)):
					if Vector2i(x, y).distance_to(center) <= size:
						positions.append(Vector2i(x, y))
		"扇形":
			var direction = Vector2i(1, 0)
			for x in range(center.x, min(width, center.x + size + 1)):
				for y in range(max(0, center.y - size), min(height, center.y + size + 1)):
					var pos = Vector2i(x, y)
					var dir = (pos - center).normalized()
					if dir.dot(direction) > 0.5:
						positions.append(pos)
		"矩形":
			for x in range(max(0, center.x - size), min(width, center.x + size + 1)):
				for y in range(max(0, center.y - size), min(height, center.y + size + 1)):
					positions.append(Vector2i(x, y))
	return positions

func get_valid_positions() -> Array[Vector2i]:
	var positions = []
	for x in range(width):
		for y in range(height):
			if grid_data[y][x]["character"] == null and Vector2i(x, y) not in obstacles:
				positions.append(Vector2i(x, y))
	return positions

func get_friendly_positions(team: int) -> Array[Vector2i]:
	var positions = []
	for char in characters:
		if char.team == team and char.is_alive():
			positions.append(char.grid_pos)
	return positions

func get_enemy_positions(team: int) -> Array[Vector2i]:
	var positions = []
	for char in characters:
		if char.team != team and char.is_alive():
			positions.append(char.grid_pos)
	return positions

func get_lowest_hp_target(team: int, enemy: bool) -> BattleCharacter:
	var target_team = team if not enemy else (1 - team)
	var lowest = null
	var lowest_hp = INF
	for char in characters:
		if char.team == target_team and char.is_alive():
			if char.current_hp < lowest_hp:
				lowest_hp = char.current_hp
				lowest = char
	return lowest

func get_highest_hp_target(team: int, enemy: bool) -> BattleCharacter:
	var target_team = team if not enemy else (1 - team)
	var highest = null
	var highest_hp = -1
	for char in characters:
		if char.team == target_team and char.is_alive():
			if char.current_hp > highest_hp:
				highest_hp = char.current_hp
				highest = char
	return highest

func find_path(start: Vector2i, end: Vector2i, move_range: int, ignore_characters: bool = false) -> Array[Vector2i]:
	if not is_valid_position(start) or not is_valid_position(end):
		return []
	if start == end:
		return [start]
	
	# A*寻路
	var open_set = [start]
	var came_from = {}
	var g_score = {start: 0}
	var f_score = {start: heuristic(start, end)}
	
	while open_set.size() > 0:
		var current = open_set[0]
		var min_f = f_score[current]
		for pos in open_set:
			if f_score[pos] < min_f:
				current = pos
				min_f = f_score[pos]
		
		if current == end:
			return reconstruct_path(came_from, current)
		
		open_set.erase(current)
		
		for neighbor in get_neighbors(current, ignore_characters):
			var tentative_g = g_score[current] + get_movement_cost(current, neighbor)
			if tentative_g > move_range:
				continue
			
			if not g_score.has(neighbor) or tentative_g < g_score[neighbor]:
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g
				f_score[neighbor] = tentative_g + heuristic(neighbor, end)
				if neighbor not in open_set:
					open_set.append(neighbor)
	
	return []

func get_neighbors(pos: Vector2i, ignore_characters: bool) -> Array[Vector2i]:
	var neighbors = []
	var dirs = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	for dir in dirs:
		var neighbor = pos + dir
		if is_valid_position(neighbor) and neighbor not in obstacles:
			if ignore_characters or grid_data[neighbor.y][neighbor.x]["character"] == null:
				neighbors.append(neighbor)
	return neighbors

func get_movement_cost(from_pos: Vector2i, to_pos: Vector2i) -> int:
	if not is_valid_position(to_pos):
		return 999
	return grid_data[to_pos.y][to_pos.x]["movement_cost"]

func heuristic(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)

func reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array[Vector2i]:
	var path = [current]
	while came_from.has(current):
		current = came_from[current]
		path.insert(0, current)
	return path

func get_reachable_positions(start: Vector2i, move_range: int, ignore_characters: bool = false) -> Array[Vector2i]:
	var reachable = []
	var visited = {}
	var queue = [{ "pos": start, "cost": 0 }]
	visited[start] = true
	
	while queue.size() > 0:
		var current = queue.pop_front()
		reachable.append(current.pos)
		
		if current.cost >= move_range:
			continue
		
		for neighbor in get_neighbors(current.pos, ignore_characters):
			if not visited.has(neighbor):
				var cost = current.cost + get_movement_cost(current.pos, neighbor)
				if cost <= move_range:
					visited[neighbor] = true
					queue.append({ "pos": neighbor, "cost": cost })
	
	return reachable

func find_empty_adjacent(pos: Vector2i) -> Vector2i:
	var dirs = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	for dir in dirs:
		var neighbor = pos + dir
		if is_valid_position(neighbor) and grid_data[neighbor.y][neighbor.x]["character"] == null and neighbor not in obstacles:
			return neighbor
	return Vector2i(-1, -1)

func add_trap(pos: Vector2i, trap_id: String, caster: BattleCharacter):
	if is_valid_position(pos):
		traps[pos] = {
			"id": trap_id,
			"caster": caster,
			"turns": 3
		}

func add_mine(pos: Vector2i, mine_id: String, caster: BattleCharacter):
	if is_valid_position(pos):
		mines[pos] = {
			"id": mine_id,
			"caster": caster,
			"turns": 5
		}

func trigger_trap(pos: Vector2i, triggerer: BattleCharacter):
	if traps.has(pos):
		var trap = traps[pos]
		var trap_data = TrapDatabase.get_trap(trap["id"])
		if trap_data:
			trap_data.trigger(triggerer, trap["caster"])
		traps.erase(pos)

func trigger_mine(pos: Vector2i, triggerer: BattleCharacter):
	if mines.has(pos):
		var mine = mines[pos]
		var mine_data = MineDatabase.get_mine(mine["id"])
		if mine_data:
			mine_data.explode(triggerer, mine["caster"])
		mines.erase(pos)

func on_turn_end():
	for pos in traps:
		traps[pos]["turns"] -= 1
		if traps[pos]["turns"] <= 0:
			traps.erase(pos)
	
	for pos in mines:
		mines[pos]["turns"] -= 1
		if mines[pos]["turns"] <= 0:
			mines.erase(pos)

func set_obstacle(pos: Vector2i, is_obstacle: bool):
	if is_valid_position(pos):
		if is_obstacle:
			if pos not in obstacles:
				obstacles.append(pos)
		else:
			obstacles.erase(pos)

func get_terrain(pos: Vector2i) -> String:
	if is_valid_position(pos):
		return grid_data[pos.y][pos.x]["terrain"]
	return "无效"

func set_terrain(pos: Vector2i, terrain: String):
	if is_valid_position(pos):
		grid_data[pos.y][pos.x]["terrain"] = terrain
		match terrain:
			"平地": grid_data[pos.y][pos.x]["movement_cost"] = 1
			"草地": grid_data[pos.y][pos.x]["movement_cost"] = 1
			"森林": grid_data[pos.y][pos.x]["movement_cost"] = 2
			"山地": grid_data[pos.y][pos.x]["movement_cost"] = 3
			"水面": grid_data[pos.y][pos.x]["movement_cost"] = 2
			"沼泽": grid_data[pos.y][pos.x]["movement_cost"] = 3
			"冰面": grid_data[pos.y][pos.x]["movement_cost"] = 1
			"岩浆": grid_data[pos.y][pos.x]["movement_cost"] = 1
			_: grid_data[pos.y][pos.x]["movement_cost"] = 1

func clear():
	characters.clear()
	traps.clear()
	mines.clear()
	obstacles.clear()
	_init_grid()

func to_dict() -> Dictionary:
	return {
		"width": width,
		"height": height,
		"characters": [c.to_dict() for c in characters],
		"traps": traps,
		"mines": mines,
		"obstacles": obstacles
	}

func from_dict(data: Dictionary):
	width = data.get("width", 9)
	height = data.get("height", 6)
	_init_grid()
	
	for c_data in data.get("characters", []):
		var bc = BattleCharacter.new().from_dict(c_data)
		if bc and bc.grid_pos != Vector2i(-1, -1):
			add_character(bc, bc.grid_pos)
	
	traps = data.get("traps", {})
	mines = data.get("mines", {})
	obstacles = data.get("obstacles", [])