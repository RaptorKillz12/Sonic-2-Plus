extends CanvasLayer

func _ready() -> void:
	#await Main.scene_faded
	Global.Clean_Up_Object_References()
	
	Global.beta_mode = Input.is_action_pressed("ui_cancel")
	
	SoundDriver.music.stop()
	await queue_level()

func queue_level() -> void:
	match clampi(Global.saved_zone_id,0,Global.ZONES.size()+1):
		Global.ZONES.EMERALD_HILL:
			match Global.saved_act_id:
				0:
					Global.current_zone_pointer = "res://Data/Stages/Zones/EmeraldHill1.tscn"
				_:
					Global.current_zone_pointer = "res://Data/Stages/Zones/EmeraldHill2.tscn"
		Global.ZONES.HIDDEN_PALACE:
			match Global.saved_act_id:
				0:
					Global.current_zone_pointer = "res://Data/Stages/Zones/Hidden Palace 1.tscn"
				_:
					Global.current_zone_pointer = "res://Data/Stages/Zones/Hidden Palace 2.tscn"
		Global.ZONES.HILL_TOP:
			match Global.saved_act_id:
				0:
					Global.current_zone_pointer = "res://Data/Stages/Zones/HillTop1.tscn"
				_:
					Global.current_zone_pointer = "res://Data/Stages/Zones/HillTop2.tscn"
		Global.ZONES.CHEMICAL_PLANT:
			match Global.saved_act_id:
				0:
					Global.current_zone_pointer = "res://Data/Stages/Zoness/ChemicalPlant.tscn"
				_:
					Global.current_zone_pointer = "res://Data/Stages/Zones/ChemicalPlant2.tscn"
		Global.ZONES.OIL_OCEAN:
			match Global.saved_act_id:
				0:
					Global.current_zone_pointer = "res://Data/Stages/Zones/OilOcean.tscn"
				_:
					Global.current_zone_pointer = "res://Data/Stages/Zones/OilOceanAct2.tscn"
		Global.ZONES.NEO_GREEN_HILL:
			match Global.saved_act_id:
				0:
					Global.current_zone_pointer = "res://Data/Stages/Zones/NeoGreenHill1.tscn"
				_:
					Global.current_zone_pointer = "res://Data/Stages/Zones/NeoGreenHill2.tscn"
		Global.ZONES.METROPOLIS:
			match Global.saved_act_id:
				0:
					Global.current_zone_pointer = "res://Data/Stages/Zones/Metropolis1.tscn"
				_:
					Global.current_zone_pointer = "res://Data/Stages/Zones/Metropolis2.tscn"
		Global.ZONES.DUST_HILL:
			match Global.saved_act_id:
				0:
					Global.current_zone_pointer = "res://Data/Stages/Zones/DustHill1.tscn"
				_:
					Global.current_zone_pointer = "res://Data/Stages/Zones/DustHill2.tscn"

		Global.ZONES.CASINO_NIGHT:
			match Global.saved_act_id:
				0:
					Global.current_zone_pointer = "res://Data/Stages/Zones/CasinoNight1New.tscn"
				_:
					Global.current_zone_pointer = "res://Data/Stages/Zones/CasinoNight2New.tscn"
		Global.ZONES.CYBER_CITY:
			match Global.saved_act_id:
				#0:
				#	Global.current_zone_pointer = "res://Data/Stages/Zones/Metropolis3.tscn"
				_:
					Global.current_zone_pointer = "res://Data/Stages/Zones/CyberCity.tscn"
		Global.ZONES.SKY_FORTRESS:
			match Global.saved_act_id:
				0:
					Global.current_zone_pointer = "res://Data/Stages/Zones/SkyFortress1.tscn"
				_:
					Global.current_zone_pointer = "res://Data/Stages/Zones/SkyFortress2.tscn"
		Global.ZONES.DEATH_EGG:
			match Global.saved_act_id:
				#0:
				#	Global.current_zone_pointer = "res://Data/Stages/Zones/DeathEgg1.tscn"
				_:
					Global.current_zone_pointer = "res://Data/Stages/Zones/DeathEgg2.tscn"
		Global.ZONES.SPECIAL_STAGE:
				Global.saved_zone_id = Global.ZONES.EMERALD_HILL
				Global.saved_act_id = 0
				Global.current_zone_pointer = "res://Data/Stages/Zones/EmeraldHill1.tscn"
				await Main.change_scene("res://Data/Stages/SpecialStage/SpecialStage.tscn","WhiteOut",0.0,true)
				return
		_:
			Global.current_zone_pointer = "res://Data/Stages/Presentation/DemoCredits.tscn"
	#Load the Zone
	await Main.change_scene(Global.current_zone_pointer,"",0.0,true)
