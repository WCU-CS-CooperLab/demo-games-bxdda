extends Area2D

@export var speed = 2000
var pen = 0
var velocity = Vector2.ZERO

func start(_transform):
	transform = _transform
	velocity = transform.x * speed
	
	
func startDir(_transform, direction):
	transform = _transform
	velocity = direction * 20

func _process(delta):
		position += velocity * delta


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_body_entered(body: Node2D):
	if body.is_in_group("rocks"):
		pen += 1
		body.explode()
	if (pen >= 3):
		queue_free()


func _on_area_entered(area):
		if area.is_in_group("enemies"):
			area.take_damage(3)
			$Explosion.show()
			$Explosion/ExplosionSound.pitch_scale = 0.2
			$Explosion/ExplosionSound.play()
			$Explosion/AnimationPlayer.speed_scale = 1.5
			$Explosion/AnimationPlayer.play("explosion")
			await $Explosion/AnimationPlayer.animation_finished
		queue_free()
			

#func spawn_explosion(position: Vector2):
#	var explosion_instance = preload("res://explosion.tscn").instantiate()
#	explosion_instance.global_position = position
#	get_tree().root.add_child(explosion_instance)
#	var anim = explosion_instance.get_node("AnimationPlayer")
#	anim.play("explosion")
#	await get_tree().create_timer(0.64).timeout
#	get_tree().root.remove_child(explosion_instance)
	
