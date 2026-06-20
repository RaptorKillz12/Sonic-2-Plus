extends Node

# Music

var musicParent: Node = null
var music: AudioStreamPlayer = null
var life: AudioStreamPlayer = null

var startVolumeLevel: float = 0 # used as reference for when a volume change started
var setVolumeLevel: float = 0 # where to fade the volume to
var volume_fade_amount: float = 0 # current stage between start and set for volume level
var volumeFadeSpeed: float = 1 # speed for volume changing

# index for current theme
var currentTheme: int = 0

# The Audio Resource that is the currently playing song.
# Used to avoid the same song being queued twice,
# unless the queue request is agnostic.
var currentMusic: AudioStream = null
var level_music: AudioStream = null
var level_music_fast: AudioStream = null

# song themes to play for things like invincibility and speed shoes
enum THEME {
	NORMAL,
	INVINCIBLE,
	SPEED,
	FAST_INVINCIBLE,
	SUPER,
	BOSS,
	DROWN,
	RESULTS
}

var themes: Array[AudioStream] = [
	null, # NORMAL
	preload("res://Audio/Soundtrack/Invincibility.ogg"), # INVINCIBLE
	null, # SPEED
	null, # FAST_INVINCIBLE
	preload("res://Audio/Soundtrack/Super.ogg"), # SUPER
	preload("res://Audio/Soundtrack/Boss.ogg"), # BOSS
	preload("res://Audio/Soundtrack/Drowning.ogg"), # DROWN
	preload("res://Audio/Soundtrack/ActComplete.ogg") # RESULTS
]

# Sound, used for play_sound (used for a global sound, use this if multiple nodes use the same sound)
var soundChannel: AudioStreamPlayer = AudioStreamPlayer.new()

# Alternate global Sound player
var soundChannel2: AudioStreamPlayer = AudioStreamPlayer.new()

## Emitted once a volume fade function is complete.
signal volume_set

func _ready() -> void:
	# set sound settings
	add_child(soundChannel)
	soundChannel.bus = "SFX"

	add_child(soundChannel2)
	soundChannel2.bus = "SFX"

	volume_set.connect(On_volume_set)

func _process(delta: float) -> void:
	if !get_tree().paused and !music.stream_paused:
		# check that volume lerp isn't transitioned yet
		if volume_fade_amount < 1:
			# move volume lerp to 1
			volume_fade_amount = move_toward(volume_fade_amount, 1, delta * volumeFadeSpeed)

			# use volume lerp to set the effect volume
			SoundDriver.music.volume_db = lerp(
				float(startVolumeLevel),
				float(setVolumeLevel),
				float(volume_fade_amount)
			)

			if volume_fade_amount >= 1:
				emit_signal("volume_set")

# use this to play a sound globally, use load("res://...") or a preloaded sound
func play_sound(sound: AudioStream = null) -> void:
	if sound != null:
		soundChannel.stream = sound
		soundChannel.play()

func play_sound2(sound: AudioStream = null) -> void:
	if sound != null:
		soundChannel2.stream = sound
		soundChannel2.play()

func playNormalMusic() -> void:
	if Global.stage_cleared:
		return

	var selected_song: AudioStream = themes[THEME.NORMAL]
	currentTheme = THEME.NORMAL

	for player in Global.players:
		var has_shoes := player.shoe_time > 0
		var has_inv := player.super_time > 0

		print(
			"shoe=", player.shoe_time,
			" inv=", player.super_time,
			" super=", player.is_super
		)

		# Super Sonic
		if player.is_super:
			currentTheme = THEME.SUPER
			selected_song = themes[THEME.SUPER]
			break

		# Invincible + Speed Shoes
		elif has_inv and has_shoes:
			currentTheme = THEME.FAST_INVINCIBLE
			selected_song = themes[THEME.FAST_INVINCIBLE]
			break

		# Invincible
		elif has_inv:
			currentTheme = THEME.INVINCIBLE
			selected_song = themes[THEME.INVINCIBLE]
			break

		# Speed Shoes
		elif has_shoes:
			currentTheme = THEME.SPEED
			selected_song = themes[THEME.SPEED]

	# Boss music (unless overridden)
	if Global.fightingBoss:
		if currentTheme != THEME.SUPER \
		and currentTheme != THEME.INVINCIBLE \
		and currentTheme != THEME.FAST_INVINCIBLE:
			currentTheme = THEME.BOSS
			selected_song = themes[THEME.BOSS]

	print("Theme=", currentTheme, " Song=", selected_song)

	playMusic(selected_song)


func playMusic(musID: AudioStream = null, agnostic: bool = false) -> void:
	if musID == null:
		return

	if musID != currentMusic or agnostic:
		var pos := 0.0

		if SoundDriver.music.playing:
			pos = SoundDriver.music.get_playback_position()

		SoundDriver.music.stop()
		SoundDriver.music.stream = musID
		SoundDriver.music.play(pos)

		currentMusic = musID

## Play Arg1, unless it matches the current song and arg2 is false.


func playExtraLifeMusic() -> void:
	music.stream_paused = true
	music.volume_db = -100

	life.stop()
	life.play()

	await life.finished

	music.stream_paused = false
	set_volume(1.0, 0.5)

# set the volume level
func set_volume(final_volume: float = 0, fade_speed: float = 1) -> void:
	# set the start volume level to the current volume
	startVolumeLevel = music.volume_db

	# set the volume level to go to
	setVolumeLevel = final_volume

	# set volume transition
	volume_fade_amount = 0

	# set the speed for the transition
	volumeFadeSpeed = fade_speed

	# this is continued in _process() as it needs to run during gameplay

func reset_volume() -> void:
	# stop life sound (if it's still playing)
	if SoundDriver.life.is_playing():
		SoundDriver.life.stop()

	# set volume level to default
	music.volume_db = 0
	startVolumeLevel = 0

func On_volume_set() -> void:
	pass

func set_level_music(normal: AudioStream, fast: AudioStream) -> void:
	level_music = normal
	level_music_fast = fast

	themes[THEME.NORMAL] = normal
	themes[THEME.SPEED] = fast

func set_invincible_music(normal: AudioStream, fast: AudioStream) -> void:
	themes[THEME.INVINCIBLE] = normal
	themes[THEME.FAST_INVINCIBLE] = fast
