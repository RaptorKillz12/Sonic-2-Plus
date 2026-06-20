@tool
extends DataSelectPanel

var icon_regions: Array[Rect2] = [
	Rect2(0, 30, 48, 30),      # Sonic & Tails
	Rect2(0, 60, 30, 30),     # Sonic
	Rect2(0, 90, 30, 30),    # Tails
	Rect2(0, 120, 30, 30),    # Knuckles
	Rect2(0, 150, 30, 30)     # Amy
]
func _ready() -> void:
	%CharacterIcon.region_enabled = true
	_update_character_icon()

func _process(_delta: float) -> void:
	pass

func update_selection_state(state: bool) -> void:
	$Sprite2D.visible = state

func update_menu_item(direction: int = 0):
	@warning_ignore("int_as_enum_without_cast")
	character_id = wrapi(
		character_id + direction,
		Global.PLAYER_MODES.SONIC_AND_TAILS,
		Global.PLAYER_MODES.AMY + 1
	) as Global.PLAYER_MODES

	_update_character_icon()
	return true

func use():
	Global.current_save_index = 0
	Global.getPlayerIDsFromPlayerMode(character_id)
	Global.saved_zone_id = Global.ZONES.EMERALD_HILL
	Global.character_selection = character_id
	return true

func _update_character_icon() -> void:
	var index := int(character_id)

	if index >= 0 and index < icon_regions.size():
		%CharacterIcon.region_enabled = true
		%CharacterIcon.region_rect = icon_regions[index]
