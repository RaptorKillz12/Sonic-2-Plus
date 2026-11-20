extends Area2D

@export_enum("Normal", "Fire", "Elec", "Water") var damageType: int = 0
var playerHit: Array[Player2D] = []

func _process(_delta: float) -> void:
	# do hit if player array isn't empty
	if (playerHit.size() > 0):
		for i in playerHit:
			if (i.has_method("hit_player")):
				i.hit_player(global_position,damageType)

func _on_body_entered(body: Player2D) -> void:
	if (!playerHit.has(body)):
		playerHit.append(body)


func _on_body_exited(body: Player2D) -> void:
	if (playerHit.has(body)):
		playerHit.erase(body)
