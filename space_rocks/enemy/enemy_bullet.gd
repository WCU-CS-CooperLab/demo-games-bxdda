extends Area2D
@export var speed = 1000
@export var damage = 15

func start(_pos, _dir):
	position = _pos
	rotation = _dir.angle()

func _process(delta):
	position += transform.x * speed * delta

func _on_body_entered(body):
	if body.is_in_group("players"):
		body.take_damage(damage)
		$Explosion.show()
		$Explosion/ExplosionSound.pitch_scale = 0.5
		$Explosion/ExplosionSound.play()
		$Explosion/AnimationPlayer.speed_scale = 1.5
		$Explosion/AnimationPlayer.play("explosion")
		await $Explosion/AnimationPlayer.animation_finished
	queue_free()
	

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()