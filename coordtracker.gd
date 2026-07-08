extends Label

# Drag your CharacterBody2D Player node here via the Inspector
@export var player: Node2D 
func _ready() -> void:
	player.global_position = Vector2.ZERO

func _process(_delta: float) -> void:
	if player:
		var player_x: float = snappedf(player.global_position.x, 0.01)/20
		var player_y: float = snappedf(player.global_position.y, 0.01)/20
		text = "Coordinates: X: %d, Y: %d" % [player_x, player_y]
