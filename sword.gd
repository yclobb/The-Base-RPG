extends Node2D
var cooldown: float = 1.5
var timer: float = cooldown
var mousepos: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO
var swordanim: bool = false
var swordanimdegrees: float = 130
var swing_angle: float = 0.0
var heavyattacking: bool = false
var heavycooldown: float = 4.8
var heavytimer: float = 0.0

@export var player: Node2D

func _ready() -> void:
	$Sprite2D.modulate.a = 0.0
func _process(delta: float) -> void:
	stats.swordcooldown = timer
	heavytimer -= delta
	if swordanim == false:
		mousepos = get_global_mouse_position()
		direction = mousepos - player.global_position
		$SwordHitbox.rotation_degrees = rad_to_deg(direction.angle()) + 90
		$Sprite2D.rotation_degrees = rad_to_deg(direction.angle()) + 90
		$SwordHitbox.position = direction.normalized()*100
		$Sprite2D.position = direction.normalized()*100
		timer -= delta
	else:
		var swing_dir = Vector2.RIGHT.rotated(swing_angle)
		$SwordHitbox.rotation_degrees = rad_to_deg(swing_angle) + 90
		$Sprite2D.rotation_degrees = rad_to_deg(swing_angle) + 90
		$SwordHitbox.position = swing_dir * 100
		$Sprite2D.position = swing_dir * 100
func _unhandled_input(event) -> void:
	if stats.gameover == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if timer <= 0:
					timer = cooldown
					heavyattacking = false
					swordanim = true
					var aim = direction.angle()
					swing_angle = aim - deg_to_rad(swordanimdegrees / 2.0)
					var fade = create_tween()
					fade.tween_property($Sprite2D, "modulate:a", 1.0, 0.1)
					fade.tween_callback(func(): stats.swordhitting = true)
					fade.tween_interval(0.8)
					fade.tween_callback(func(): stats.swordhitting = false)
					fade.tween_property($Sprite2D, "modulate:a", 0.0, 0.2)
					fade.tween_callback(func(): swordanim = false)
					var swing = create_tween()
					swing.tween_property(self, "swing_angle", aim + deg_to_rad(swordanimdegrees / 2.0), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				if heavytimer <= 0 and timer <= 0:
					heavytimer = heavycooldown
					timer = cooldown * 2.5
					heavyattacking = true
					swordanim = true
					var aim = direction.angle()
					swing_angle = aim - deg_to_rad(swordanimdegrees / 2.0)
					var fade = create_tween()
					fade.tween_property($Sprite2D, "modulate:a", 1.0, 0.1)
					fade.tween_callback(func(): stats.swordhitting = true; stats.isheavyattacking = true)
					fade.tween_interval(1.2)
					fade.tween_callback(func(): stats.swordhitting = false; stats.isheavyattacking = false)
					fade.tween_property($Sprite2D, "modulate:a", 0.0, 0.2)
					fade.tween_callback(func(): swordanim = false)
					var swing = create_tween()
					swing.tween_property(self, "swing_angle", aim + deg_to_rad(swordanimdegrees / 2.0), 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				