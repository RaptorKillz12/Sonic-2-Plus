extends Node2D

@export var music: AudioStream = preload("res://Audio/Soundtrack/s2br_TitleScreen.ogg")
var opening_cutscene: String = "res://Scene/Cutscenes/Opening.tscn"
var menu: String = "res://Scene/Presentation/DataSelectMenu.tscn"


@export var demo_flag: bool = false

enum STATES{INTRO,WAITING,FADEOUT}
var state: int = STATES.INTRO
## If the Title Screen should be moving
var title_scroll: bool = false

signal music_finished

var 	titleEnd: bool = false
## If a cheat code has been applied on this loop, don't allow it to be again
var cheat_active: bool = false

var BackgroundScene: PackedScene
var parallaxBackgrounds: Array[StringName] = [
	"res://Scene/Backgrounds/17-Ending.tscn",
]
var sceneInstance: ParallaxBackground = null

var paraOffsets: Array[float] = [
	0,
	-216,
	0,
	0,
	-256,
	-256,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0
]

#Cheat Code Inputs
var levelSelectCheat: Array[Vector2] = [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.DOWN,
	Vector2.DOWN,
	Vector2.UP
]
var cheatInputCount: int = 0 #Correct inputs
var lastCheatInput: Vector2 = Vector2.ZERO
## Last saved directional input.
var lastInput: Vector2 = Vector2.ZERO

func _ready() -> void:
	self.music_finished.connect(_on_music_finished)
	get_tree().paused = false
	#Wipe the player arrays to avoid contamination.
	reset_values()
	#Prepare the Title Streen Music
	SoundDriver.music.stream = music
	#Prepare the background
	var parallax: String = parallaxBackgrounds[min(Global.saved_zone_id,parallaxBackgrounds.size()-1)]
	BackgroundScene = load(parallax)
	if demo_flag:
		$"CanvasLayer/Menu/2PlayerVS".queue_free()

func _process(delta: float) -> void:
	if title_scroll:
		$TitleBanner.global_position.x += (5*60*delta)

	if state < STATES.FADEOUT:
		_unhandledInput()

func _unhandledInput() -> void:
	var inputCue: Vector2 = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	inputCue.x = round(inputCue.x)
	inputCue.y = round(inputCue.y)
	CheckCheatInputs(inputCue)
	lastInput = inputCue


func _input(event):
	# end title on start press
	if event.is_action_pressed("ui_pause") and !titleEnd:
		titleEnd = true
		SetFadeOut(menu)


func CheckCheatInputs(inputCue: Vector2 = Vector2.ZERO) -> void:
	if inputCue != lastCheatInput and inputCue:
		if !cheat_active:
			if inputCue == levelSelectCheat[cheatInputCount]:
				cheatInputCount += 1
				#print("Correct input!"+ str(inputCue))
			else:
				cheatInputCount = 0
				#print("Wrong input!" + str(inputCue))
			if cheatInputCount == levelSelectCheat.size():
				cheatInputCount = 0
				Global.emeralds += 1
				$TitleBanner/RingChime.play(0.0)
				Global.tails_name_cheat = !Global.tails_name_cheat
				if !Global.tails_name_cheat:
					Global.characterNames[1] = "MILES"
					Global.playerModes[0] = "SONIC & MILES"
					Global.playerModes[2] = "MILES"
				else:
					Global.characterNames[1] = "TAILS"
					Global.playerModes[0] = "SONIC & TAILS"
					Global.playerModes[2] = "TAILS"
	lastCheatInput = inputCue

func InstantiateBG() -> void:
	if sceneInstance == null:
		sceneInstance = BackgroundScene.instantiate()
		sceneInstance.scroll_base_offset.y = paraOffsets[min(Global.saved_zone_id,parallaxBackgrounds.size()-1)]
		add_child(sceneInstance)


func PlayMusic() -> void:
	SoundDriver.music.play()
	title_scroll = true #Begin scrolling
	await SoundDriver.music.finished
	emit_signal("music_finished")


func SetFadeOut(newScene: String) -> void:
	if state < STATES.FADEOUT:
		state = STATES.FADEOUT

		await Main.change_scene(newScene,"FadeOut",1.0,false)


#The wait timer has run out, activate the spakls in time with the shooting star sound


func reset_values() -> void:
	Global.stage_cleared = false 
	Global.reset_level_data()
	Global.two_player_mode = false
	Global.score = 0
	Global.scoreP2 = 0
	Global.levelTime = 0
	Global.levelTimeP2 = 0
	Global.lives = 3
	Global.livesP2 = 3
	Global.twoPlayerZoneResults.clear()
	Global.twoPlayActResults.clear()
	Global.twoPlayerRound = 0
	Global.continues = 0
	#Global.emeralds = 0
	Global.special_stage_id = 0
	Global.checkpoint_time_p1 = 0
	Global.checkpoint_time_p2 = 0
	Global.saved_checkpoint = -1
	Global.saved_checkpointP2 = -1
	Global.animals = [0,1]


func _on_music_finished() -> void:
	SetFadeOut(opening_cutscene)
