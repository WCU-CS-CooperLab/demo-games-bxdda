extends Camera2D

var scroll_speed_y = 100  # Vertical scroll speed

func _process(delta):
	position.y += scroll_speed_y * delta
