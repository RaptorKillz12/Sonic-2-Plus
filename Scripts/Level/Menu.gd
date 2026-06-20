extends Node2D

@export var music: AudioStream = preload("res://Audio/Soundtrack/MainMenu.ogg")
var buttons: Array[TextureButton] = []
var selected := 0

@onready var menu := $UI/Menu
@onready var selector := $UI/Menu/Selector

@export var normal_textures: Array[Texture2D]
@export var selected_textures: Array[Texture2D]

func _ready():
	SoundDriver.music.stream = music
	SoundDriver.music.play()
	buttons = [
		$UI/Menu/Start,
		$UI/Menu/Options,
		$UI/Menu/Extras,
		$UI/Menu/Exit
	]

	await get_tree().process_frame

	_layout_menu()
	_update_selection()

func _layout_menu():
	buttons[0].position = Vector2(285, 78)   # START
	buttons[1].position = Vector2(285, 116)  # OPTIONS
	buttons[2].position = Vector2(285, 154)  # EXTRAS
	buttons[3].position = Vector2(285, 192)  # EXIT
	
func _process(_delta):
	if Input.is_action_just_pressed("ui_down"):
		selected = wrapi(selected + 1, 0, buttons.size())
		_update_selection()

	if Input.is_action_just_pressed("ui_up"):
		selected = wrapi(selected - 1, 0, buttons.size())
		_update_selection()

	if Input.is_action_just_pressed("ui_accept"):
		$Acept.play()
		match selected:
			0:
				Main.change_scene("res://Scene/Presentation/DataSelectMenu.tscn")
			1:
				print("OPTIONS")
			2:
				print("EXTRAS")
			3:
				Main.quit_game()

func _update_selection():
	$Bleep.play()
	for i in range(buttons.size()):
		buttons[i].texture_normal = normal_textures[i]

	buttons[selected].texture_normal = selected_textures[selected]

	var btn = buttons[selected]

	var target = btn.position + Vector2(-35, 8)

	var tween = create_tween()
	tween.tween_property(selector, "position", target, 0.12)
