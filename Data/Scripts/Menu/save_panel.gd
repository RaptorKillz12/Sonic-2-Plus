@tool
extends DataSelectPanel

@export var level_id: Global.ZONES
@onready var delete_label: Label = $DataBox/DeleteLabel

const SAVEZONE_NAMES: Array[StringName] = [
	"Emerald Hill",
	"Hidden Palace",
	"Hill Top",
	"Chemical Plant",
	"Oil Ocean",
	"Aquatic Ruin",
	"Metropolis",
	"Mystic Cave",
	"Wood Gadget",
	"Casino Night",
	"Jewel Grotto",
	"Emerald Hill",
	"Sand Shower",
	"Jade Cove",
	"Cyber City",
	"Sky Fortress",
	"Death Egg",
	"Emerald Hill"
]
# Replace these Rect2 values with your actual sprite sheet regions
var icon_regions: Array[Rect2] = [
	Rect2(0, 30, 48, 30),      # Sonic & Tails
	Rect2(0, 60, 30, 30),     # Sonic
	Rect2(0, 90, 30, 30),    # Tails
	Rect2(0, 120, 30, 30),    # Knuckles
	Rect2(0, 150, 30, 30)     # Amy
]

var skip_zones = [
	Global.ZONES.WOOD_GADGET,
	Global.ZONES.JEWEL_GROTTO,
	Global.ZONES.WINTER,
	Global.ZONES.SAND_SHOWER,
	Global.ZONES.TROPICAL,
	Global.ZONES.SKY_FORTRESS,
	Global.ZONES.DEATH_EGG
]

var delete_mode := false
var delete_yes := false

func toggle_delete():
	delete_mode = true
	delete_yes = false
	text_label.text = "DELETE?\nNO"
	
func _ready() -> void:
	if Engine.is_editor_hint():
		return

	await get_tree().process_frame

	data = Global.LoadSaveGameSlotData(save_game_id)

	if data:
		character_id = data[0]
		level_id = data[3]
		text_label.text = "file " + str(save_game_id).pad_zeros(2)

	%CharacterIcon.region_enabled = true
	#%LevelIcon.frame = level_id
	var zone_name := SAVEZONE_NAMES[Global.saved_zone_id]
	var display_name := "%s Act %d" % [zone_name, Global.saved_act_id]
	$DataBox/Label.text = display_name
	_update_character_icon_texture()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	#%LevelIcon.frame = level_id

func _update_character_icon_texture() -> void:
	var index := int(character_id)

	if index >= 0 and index < icon_regions.size():
		%CharacterIcon.region_enabled = true
		%CharacterIcon.region_rect = icon_regions[index]

func update_selection_state(state: bool) -> void:
	$Sprite2D.visible = state

func update_menu_item(direction: int = 0):
	if !data:
		character_id = wrapi(
			character_id + direction,
			Global.PLAYER_MODES.SONIC_AND_TAILS,
			Global.PLAYER_MODES.AMY + 1
		) as Global.PLAYER_MODES

		_update_character_icon_texture()
		return true

	elif data[3] == Global.ZONES.ENDING:
		level_id = wrapi(
			level_id + direction,
			Global.ZONES.EMERALD_HILL,
			Global.ZONES.CYBER_CITY
		) as Global.ZONES

		while skip_zones.has(level_id):
			level_id = wrapi(
				level_id + direction,
				Global.ZONES.EMERALD_HILL,
				Global.ZONES.CYBER_CITY
			) as Global.ZONES

		return true

	return false

func use() -> bool:
	if delete_mode:
		if delete_yes and save_game_id:
			data.clear()
			level_id = Global.ZONES.EMERALD_HILL
			text_label.text = "no save"

		else:
			if data:
				text_label.text = "file " + str(save_game_id).pad_zeros(2)

		delete_mode = false
		return false

	Global.getPlayerIDsFromPlayerMode(character_id)
	Global.character_selection = character_id
	Global.saved_zone_id = level_id

	if data:
		Global.character_selection = data[0]
		Global.continues = data[2]
		Global.emeralds = data[4]
		Global.lives = data[5]
		Global.score = data[6]

	Global.current_save_index = save_game_id
	return true
