extends Sprite2D

var scroll_speed_y = 200  # Horizontal scroll speed

func _process(delta):
	position.y += scroll_speed_y * delta
	if position.y >= texture.get_height():
		position.y = 0
