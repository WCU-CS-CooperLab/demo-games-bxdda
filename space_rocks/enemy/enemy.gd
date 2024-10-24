extends Area2D

signal exploded(pos)

@export var bullet_scene : PackedScene
@export var speed = 150
@export var rotation_speed = 120
@export var health = 3
@export var bullet_spread = 0.2
var path = null

var follow = PathFollow2D.new()
var target = null

func _ready():
	$Sprite2D.frame = randi() % 3
	path = $EnemyPaths.get_children()[randi() % $EnemyPaths.get_child_count()]
	path.add_child(follow)
	follow.loop = false
	
func _physics_process(delta):
	if get_tree().paused:
		return
	
	rotation += deg_to_rad(rotation_speed) * delta
	follow.progress += speed * delta
	position = follow.global_position
	if follow.progress_ratio >= 1:
		queue_free()

func _on_gun_cooldown_timeout():
		shoot_pulse(3, 0.15)

func shoot():
	var dir = global_position.direction_to(target.global_position)
	dir = dir.rotated(randf_range(-bullet_spread,bullet_spread))
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start(global_position, dir)
	$LaserSound.play()

func shoot_pulse(n, delay):
	if get_tree().paused:
		return
	for i in n:
		shoot()
		await get_tree().create_timer(delay).timeout

func take_damage(amount):
	health -= amount
	$AnimationPlayer.play("flash")
	if health <= 0:
		explode()

func explode():
	speed = 0
	$GunCooldown.stop()
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.hide()
	$ExplosionSound.play()
	$Explosion.show()
	$Explosion/AnimationPlayer.play("explosion")
	exploded.emit(position)
	await $Explosion/AnimationPlayer.animation_finished
	queue_free()


func _on_body_entered(body):
	if body.is_in_group("rocks"):
		health -= 0.2 * body.size
		if randf() > 0.75:
			explode()
			if randf() > 0.50:
				body.explode()
			if not body.is_in_group("rocks"):
				body.explode()


		
