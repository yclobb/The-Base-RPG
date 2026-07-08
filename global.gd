extends Node
@export var max_health: float = 100.0
@export var current_health: float = 100.0
@export var regenrate: float = 5
@export var enemy1hp: float = 100.0
@export var enemy1damage: float = 15.5
@export var enemy1maxhp: float = 100.0
@export var enemy1regenrate: float = 4
var gameover: bool = false
var swordcooldown: float = 1.5
var swordhitting: bool = false
var playerhit: bool = false
var enemylevel: int = 1
var playerpos: Vector2 = Vector2.ZERO
var enemy1pos: Vector2 = Vector2.ZERO
var baseenemy1damage: float = 15.5
var baseenemy1maxhp: float = 100.0
var baseenemy1regenrate: float = 4
var enemy1returnpoint: Vector2 = Vector2.ZERO
var money: float = 0
var levelmult: float = 1
@export var sworddamage = 25
var isheavyattacking: bool = false
func _process(delta: float) -> void:
    if current_health < 100 and current_health > 0:
        current_health += delta * regenrate
    elif current_health >= 100:
        current_health = 100
    if enemylevel > 1:
        var enemyvar = pow(pow(1.2, enemylevel), 1.65)
        levelmult = snappedf(pow(2.5, log(enemyvar)/log(70)), 0.01)
    if enemylevel > 1:
        enemy1maxhp = baseenemy1maxhp * levelmult
        enemy1damage = baseenemy1damage * levelmult
        enemy1regenrate = baseenemy1regenrate * levelmult