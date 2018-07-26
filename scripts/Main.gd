extends Node

export (PackedScene) var Coin
export (PackedScene) var Powerup
export (PackedScene) var Cactus
export (int) var playtime

var level
var score
var time_left 
var screensize
var playing = false

func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -18)
	randomize()
	screensize = get_viewport().get_visible_rect().size
	$Player.screensize = screensize
	$Player.hide()

func _process(delta):
	if playing and $CoinContainer.get_child_count() == 0:
		new_level()


func new_level():
		level += 1
		time_left += 5
		$HUD.update_timer(time_left)
		$Player.new_level()
		spawn_cacti()
		spawn_coins()
		if $PowerupTimer.is_stopped():
			$PowerupTimer.wait_time = rand_range(5, 10)
			$PowerupTimer.start()
	
func new_game():
	playing = true
	level = 1
	score = 0
	time_left = playtime
	$Player.start($PlayerStart.position)
	$Player.show()
	$GameTimer.start()
	spawn_cacti()
	spawn_coins()
	$HUD.update_score(score)
	$HUD.update_timer(time_left)

func spawn_coins():
	$LevelSound.play()
	for i in range(4 + level):
		var c = Coin.instance()
		$CoinContainer.add_child(c)
		c.screensize = screensize
		c.position = Vector2(rand_range(c.coinsize.x, screensize.x - c.coinsize.x),
		rand_range(c.coinsize.y, screensize.y - c.coinsize.y))

func spawn_cacti():
	randomize()
	var c = Cactus.instance()
	$CactiContainer.add_child(c)
	c.screensize = screensize
	c.position = Vector2(rand_range(c.cactussize.x, screensize.x - c.cactussize.x),
		rand_range(c.cactussize.y, screensize.y - c.cactussize.y))

func _on_GameTimer_timeout():
	time_left -= 1
	$HUD.update_timer(time_left)
	if time_left <= 0:
		game_over()

func _on_Player_pickup(type):
	match type:
		"coin":
			score += 1
			$CoinSound.play()
			$HUD.update_score(score)
		"powerup":
			time_left += 5
			$PowerupSound.play()
			$HUD.update_timer(time_left)

func _on_Player_hurt():
	game_over()

func game_over():
	$EndSound.play()
	playing = false
	$GameTimer.stop()
	for coin in $CoinContainer.get_children():
		coin.queue_free()
	for cactus in $CactiContainer.get_children():
		cactus.queue_free()
	$HUD.show_game_over()
	$Player.die()

func _on_PowerupTimer_timeout():
	var p = Powerup.instance()
	add_child(p)
	p.screensize = screensize
	p.position = Vector2(rand_range(0, screensize.x),
						rand_range(0, screensize.y))