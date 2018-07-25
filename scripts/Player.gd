extends Area2D

signal pickup
signal hurt

export (int) var speed
export var buffer = 5
var velocity = Vector2()
var screensize = Vector2(480, 720)
onready var playersize = $CollisionShape2D.get_shape().get_extents()

func _ready():
	print(playersize)

func _process(delta):
	get_input()
	position += velocity * delta
	position.x = clamp(position.x, playersize.x + buffer, screensize.x - playersize.x - buffer)
	position.y = clamp(position.y, playersize.y + buffer, screensize.y - playersize.y - buffer)
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

func _on_Player_area_entered(area):
	if area.is_in_group("coins"):
		area.pickup()
		emit_signal("pickup", "coin")
		
	if area.is_in_group("powerups"):
		area.pickup()
		emit_signal("pickup", "powerup")
		
	if area.is_in_group("obstacles"):
		emit_signal("hurt")
		die()