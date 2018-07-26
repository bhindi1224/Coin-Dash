extends Area2D

signal pickup
signal hurt

export (int) var speed
var invulnerable = false
var velocity = Vector2()
var screensize
onready var playersize = $CollisionShape2D.get_shape().get_extents() * self.scale

func _process(delta):
	get_input()
	position += velocity * delta
	position.x = clamp(position.x, playersize.x / 2, screensize.x - playersize.x / 2)
	position.y = clamp(position.y, playersize.y / 2, screensize.y - playersize.y / 2)
	if velocity.length() > 0:
		$AnimatedSprite.animation = "run"
		$AnimatedSprite.flip_h = velocity.x < 0
	else:
		$AnimatedSprite.animation = "idle"


func start(pos):
	set_process(true)
	position = pos
	$AnimatedSprite.animation = "idle"

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		
func die():
	$AnimatedSprite.animation = "hurt"
	set_process(false)

func new_level():
	invulnerable = true
	$Invulnerability.start()
	set_process(false)
	$NewLevel.start()

func _on_Player_area_entered(area):
	if area.is_in_group("coins"):
		area.pickup()
		emit_signal("pickup", "coin")
		
	if area.is_in_group("powerups"):
		area.pickup()
		emit_signal("pickup", "powerup")
		
	if area.is_in_group("obstacles") and not invulnerable:
		emit_signal("hurt")
		die()

func _on_Invulnerability_timeout():
	invulnerable = false


func _on_NewLevel_timeout():
	set_process(true)
