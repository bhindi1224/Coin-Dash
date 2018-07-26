extends Area2D

onready var cactussize = $CollisionShape2D.get_shape().get_extents() * self.scale
var screensize

func _on_Cactus_area_entered( area ):
	if area.is_in_group("player"):
		position = Vector2(rand_range(cactussize.x, screensize.x - cactussize.x),
				rand_range(cactussize.y, screensize.y - cactussize.y))