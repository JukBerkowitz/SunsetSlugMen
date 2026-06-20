extends Camera2D

var target: Node2D 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_target()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position = target.position

func get_target():
	var player_reference = get_tree().get_nodes_in_group('Player')
	if player_reference.size() == 0:
		push_error("Player not foud")
		return
	target = player_reference[0]
