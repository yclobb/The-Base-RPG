extends Button
@onready var bg = $ColorRect
@export var player: Node2D
@export var enemy: Node2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bg.visible = false
	visible = false
	disabled = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	bg.global_position = player.global_position
	if stats.gameover == true:
		player.global_position = Vector2.ZERO
		enemy.global_position = stats.enemy1returnpoint
		visible = true
		bg.visible = true
		disabled = false
	else:
		visible = false
		bg.visible = false
		disabled = true


func _on_pressed() -> void:
	stats.current_health = stats.max_health
	stats.gameover = false
