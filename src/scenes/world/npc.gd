extends Node2D
class_name WorldNPC

signal interacted(npc_data: NPCData)

var npc_data: NPCData = null
var label: Label
var sprite: Sprite2D

func _ready():
	sprite = Sprite2D.new()
	sprite.texture = create_rect_texture(Color.WHITE, Vector2(32, 48))
	add_child(sprite)
	label = Label.new()
	label.position = Vector2(-48, -60)
	label.size = Vector2(128, 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)

func set_npc_data(data: NPCData):
	npc_data = data
	if npc_data and label:
		label.text = npc_data.name

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		interacted.emit(npc_data)

static func create_rect_texture(color: Color, size: Vector2) -> ImageTexture:
	var img = Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)
