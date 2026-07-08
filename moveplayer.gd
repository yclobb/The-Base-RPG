extends CharacterBody2D

@export var speed: float = 200.0
@export var acceleration: float = 1400.0
@export var friction: float = 1200.0

@export var dashspeed: float = 1450
@export var dashtime: float = 0.15
@export var dashcooldown: float = 0.4
@onready var cdbar = $CDBar
var dashtimer := 0.0
var cooldowntimer := 0.0
var isdashing := false
var stamina: float = 40.0
var maxstamina: float = 40.0
var staminaregen: float = 3.0
var dashcost: float = 20
var knockbackstun: float = 0.3
var respawntimer: float = 3
var alive: bool = true
func _process(_delta: float) -> void:
	stats.playerpos = global_position
	if stats.current_health <= 0:
		stats.gameover = true
		alive = false
func _physics_process(delta: float) -> void:
	if stats.swordcooldown > 1.5:
		cdbar.max_value = 4.8
		cdbar.self_modulate = Color.SKY_BLUE
	else:
		cdbar.max_value = 1.5
		cdbar.self_modulate = Color.WHITE
	cdbar.value = stats.swordcooldown
	cdbar.min_value = 0
	if alive == true:
		if stats.playerhit == false:
			$StaminaBar.min_value = 0
			$StaminaBar.max_value = maxstamina
			$StaminaBar.value = stamina
			if stamina < maxstamina:
				stamina += staminaregen * delta
			else:
				stamina = maxstamina
			var inputdir := Vector2(
				Input.get_axis("ui_left", "ui_right") + (float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_A))),
				Input.get_axis("ui_up", "ui_down") + (float(Input.is_key_pressed(KEY_S)) - float(Input.is_key_pressed(KEY_W)))
			)
			if cooldowntimer > 0:
				cooldowntimer -= delta
			if isdashing:
				dashtimer -= delta
				if dashtimer <= 0:
					isdashing = false
				move_and_slide()
				return
			if Input.is_key_pressed(KEY_Q) and cooldowntimer <= 0 and inputdir != Vector2.ZERO and stamina >= dashcost:
				isdashing = true
				stamina -= dashcost
				dashtimer = dashtime
				cooldowntimer = dashcooldown
				velocity = inputdir.normalized() * dashspeed
				move_and_slide()
				return
			if inputdir != Vector2.ZERO:
				var targetvelocity := inputdir.normalized() * speed

				if velocity.dot(inputdir) < 0:
					velocity = velocity.move_toward(targetvelocity, acceleration * 2 * delta)
				else:
					velocity = velocity.move_toward(targetvelocity, acceleration * delta)
			else:
				velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		else:
			#commense stun of buns
			velocity = stats.enemy1pos.direction_to(global_position) * 350
			knockbackstun -= delta
			if knockbackstun <= 0:
				stats.playerhit = false
				knockbackstun = 0.3
	else:
		velocity = Vector2.ZERO
		global_position = Vector2.ZERO
		respawntimer -= delta
		if respawntimer <= 0 and stats.gameover == false:
			alive = true
			stats.current_health = stats.max_health
			respawntimer = 3
	move_and_slide()
