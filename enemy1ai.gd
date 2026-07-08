extends CharacterBody2D
var detect: int = 0
var returnpoint: Vector2
@export var target: Node2D
@export var speed: float = 250
@export var acceleration: float = 1350.0
@export var friction: float = 1250.0
@onready var level = $"LevelText"
var overshoottolerance: int = 10
var maxchasedistance: int = 3000
var maxplayerdistance: int = 500
var originaltexty: float = 0.0
var sussytimer: float = 0
var randfgenerated: bool = false
var gettingknocked: bool = false
var knockvelocity: Vector2 = Vector2.ZERO
var alreadyhit: bool = false
@export var knockbackslowdown: float = 500
@export var sword: Node2D
@export var swordhitbox: Node2D
@export var maxwanderdistance: float = 80
var wandertarget: Vector2
var wandertimer: float = 0.0
@export var staretime: float = 1.8
@onready var interactiontext = $"Exclamation Mark"
@onready var healthbar = $"Health Bar"
@export var knockbackmult: float = 200
@export var knockbacktimer: float = 0.3
var diddamage: bool = false
var respawntimer: float = 3
var alive: bool = true
var dmgtimer: float = 0
var istouching: bool = false
func _ready() -> void:
	returnpoint = global_position
	originaltexty = interactiontext.position.y
	interactiontext.visible = false
	wandertarget = generateapointnear(returnpoint, maxwanderdistance)
func _process(delta: float) -> void:
	stats.enemy1returnpoint = returnpoint
	level.position = Vector2(-41, 70)
	level.text = "Level: " + str(stats.enemylevel) + "\nStat Mult: " + str(stats.levelmult)
	stats.enemy1pos = global_position
	dmgtimer -= delta
	if dmgtimer <= 0:
		dmgtimer = 0
		diddamage = false
	if stats.enemy1hp < 100 and stats.enemy1hp > 0:
		stats.enemy1hp += stats.enemy1regenrate * delta
	elif stats.enemy1hp > 100:
		stats.enemy1hp = 100
	elif stats.enemy1hp <= 0:
		alive = false
	healthbar.value = stats.enemy1hp
	if stats.swordhitting == true:
		for body in swordhitbox.get_overlapping_bodies():
			if body == self:
				if alreadyhit == false:
					var knock_dir = (global_position - sword.global_position).normalized()
					if stats.isheavyattacking:
						stats.enemy1hp -= stats.sworddamage * 1.4
						knockbacktimer = 0.6
						knockvelocity = knock_dir * knockbackmult * 2
					else:
						stats.enemy1hp -= stats.sworddamage
						knockbacktimer = 0.3
						knockvelocity = knock_dir * knockbackmult
					velocity = knockvelocity
					alreadyhit = true
					gettingknocked = true
	if istouching == true:
		if diddamage == false:
			if dmgtimer <= 0:
				stats.current_health -= stats.enemy1damage + randi_range(-3, 20)
				dmgtimer = 2
				diddamage = true
				stats.playerhit = true
func _physics_process(delta: float) -> void:
	if alive == true:
		#follow player go grr
		if gettingknocked == false:
			if detect == 1 and is_instance_valid(target):
				if global_position.distance_to(target.global_position) > maxplayerdistance and global_position.distance_to(returnpoint) > maxchasedistance or global_position.distance_to(returnpoint) > maxchasedistance + 400 or alreadyhit == true:
					if randfgenerated == false:
						randfgenerated = true
						staretime = randf_range(1.5, 2.5)
					sussytimer += delta
					velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
					if sussytimer >= staretime:
						randfgenerated = false
						sussytimer = 0
						detect = 0
				else:
					randfgenerated = false
					sussytimer = 0
					move_to(target.global_position, delta)
			#oh noes i cant see player
			else:
				if global_position.distance_to(returnpoint) > maxwanderdistance + overshoottolerance:
					move_to(returnpoint, delta)
				else:
					if global_position.distance_to(wandertarget) < maxwanderdistance + overshoottolerance + 5:
						velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
					else:	
						move_to(wandertarget, delta)#<- idle wander code
				if detect != 1:
					wandertimer -= delta
					if wandertimer <= 0:
						wandertarget = generateapointnear(returnpoint, maxwanderdistance)
						wandertimer = randf_range(2.5, 3.5)
		else:
			velocity = knockvelocity.limit_length(500)
			knockvelocity = knockvelocity.move_toward(Vector2.ZERO, knockbackslowdown * delta)
			knockbacktimer -= delta
			if knockbacktimer <= 0:
				gettingknocked = false
				alreadyhit = false
			pass
		move_and_slide()
	else:
		$CollisionShape2D.disabled = true
		visible = false
		global_position = returnpoint
		respawntimer -= delta
		if respawntimer <= 0:
			stats.money += pow(1.4, 5.5 * log(stats.enemylevel)/log(7.25))
			stats.enemylevel += 1
			$CollisionShape2D.disabled = false
			stats.enemy1hp = 100
			gettingknocked = false
			alreadyhit = false
			detect = 0 
			visible = true
			alive = true
			diddamage = false
			diddamage = false
			stats.playerhit = false
			respawntimer = 3	
func move_to(target_pos: Vector2, delta: float) -> void:
	var input_dir = global_position.direction_to(target_pos)
	if input_dir != Vector2.ZERO:
		var target_velocity := input_dir.normalized() * speed
		if velocity.dot(input_dir) < 0:
			velocity = velocity.move_toward(target_velocity, acceleration * 2 * delta)
		else:
			velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
func _on_stationary_body_entered(body: Node2D) -> void:
	if body == target:
		if detect == 0:
			interactiontext.visible = true
			interactiontext.modulate.a = 1.0
			interactiontext.position.y = originaltexty
			var tween = create_tween().set_parallel(true)
			tween.tween_property(interactiontext, "position:y", originaltexty - 20, 0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)	
			tween.tween_property(interactiontext, "modulate:a", 0.0, 0.4).set_delay(0.6)
		detect = 1
func generateapointnear(home: Vector2, wanderamount: float) -> Vector2:
	var randomoffset = Vector2(randf_range(-wanderamount, wanderamount), randf_range(-wanderamount, wanderamount))
	return randomoffset + home
func _on_player_area_body_entered(body: Node2D) -> void:
	if body == self:
		istouching = true
func _on_player_area_body_exited(body: Node2D) -> void:
	if body == self:
		istouching = false
		diddamage = false
		stats.playerhit = false
