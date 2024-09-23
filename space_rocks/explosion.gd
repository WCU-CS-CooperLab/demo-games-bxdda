extends Sprite2D


func _on_explosion_finished():
	queue_free()
