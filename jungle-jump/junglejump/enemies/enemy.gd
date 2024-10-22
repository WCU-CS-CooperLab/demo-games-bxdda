extends CharacterBody2D

signal died
var is_dead = false
@export var speed := 10
@export var gravity := 900
var facing := 1
var mouth = 0

#func _ready():
	

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.x += facing * speed
	$Sprite2D.flip_h = velocity.x > 0
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "Player":
			collision.get_collider().hurt()
		if collision.get_normal().x != 0:
			facing = sign(collision.get_normal().x)
			velocity.y = -100
	if position.y > 10000:
		queue_free()


func take_damage(): 
	if is_dead:
		return  # Prevent further damage processing, 
		#for some reason i was getting multiple calls of either the died signal, 
		#or the score increasing, so score was going up by more than 100 points
	is_dead = true
	died.emit()
	$AnimationPlayer.play("death")
	$HurtSound.play()
	$CollisionShape2D.set_deferred("disabled", true)
	set_physics_process(false)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		queue_free()
