extends Label

## If 0, the number of rings will be calculated automatically.
@onready var ringsForPerfect: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ringsForPerfect <= 0:
		ringsForPerfect = get_tree().get_nodes_in_group("Rings").size()
		text = str(ringsForPerfect)
		print("Rings found: ", get_tree().get_nodes_in_group("Rings").size())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
