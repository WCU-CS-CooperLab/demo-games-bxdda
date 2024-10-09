extends RigidBody2D

signal shield_changed
signal lives_changed
signal health_changed
signal dead

@export var engine_power := 500
@export var boost_power := 1000
@export var spin_power := 8000

@export var bullet_scene: PackedScene
@export var fire_rate = 0.25

@export var max_shield = 100.0
@export var shield_regen = 5.0
@export var health_regen = 3.0
@export var max_health = 100.0
@export var max_lives = 3

var shield = 0: set = set_shield
var reset_pos = false
var lives = 0: set = set_lives
var can_shoot = true

var health = 0: set = set_health


var screensize = Vector2.ZERO

var thrust := Vector2.ZERO
var rotation_dir := 0

var shield_off = false

enum player_state { INIT, ALIVE, INVULNERABLE, DEAD }
var state = player_state.INIT

func _ready():
	change_state(player_state.ALIVE)
	screensize = get_viewport_rect().size
	$GunCooldown.wait_time = fire_rate

func change_state(new_state):
	match new_state:
		player_state.INIT:
			$CollisionShape2D.set_deferred("disabled",true)
			$Sprite2D.modulate.a = 0.5
		player_state.ALIVE:
			$CollisionShape2D.set_deferred("disabled",false)
			$Sprite2D.modulate.a = 1.0
		player_state.INVULNERABLE:
			$CollisionShape2D.set_deferred("disabled",true)
			$Sprite2D.modulate.a = 0.5
			$InvulnerabilityTimer.start()
		player_state.DEAD:
			$CollisionShape2D.set_deferred("disabled",true)
			$Sprite2D.hide()
			linear_velocity = Vector2.ZERO
			dead.emit()
			$EngineSound.stop()
	state = new_state

func _process(delta):
	get_input()
	if not thrust == transform.x * boost_power : 
		shield += shield_regen * delta
	health += health_regen * delta

func get_input():
	$Exhaust.emitting = false
	$Exhaust2.emitting = false
	thrust = Vector2.ZERO
	if state in [player_state.DEAD, player_state.INIT] :
		return
	if Input.is_action_pressed("thrust"):
		$Exhaust.emitting = true
		if not $EngineSound.playing:
			$EngineSound.play()
		else:
			$EngineSound.stop()
			$EngineSound2.stop()
		thrust = transform.x * engine_power
	if Input.is_action_pressed("boost"):
		$Exhaust.emitting = false
		$Exhaust2.emitting = true
		thrust = transform.x * boost_power
		$EngineSound2.play()
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func _physics_process(delta):
	constant_force = thrust
	constant_torque = rotation_dir * spin_power
	
func _integrate_forces(physics_state):
	var xform = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, 0, screensize.x)
	xform.origin.y = wrapf(xform.origin.y, 0, screensize.y)
	physics_state.transform = xform
	if reset_pos:
		physics_state.transform.origin = screensize / 2
		reset_pos = false

func shoot():
	if state == player_state.INVULNERABLE:
		return
	can_shoot = false
	$GunCooldown.start()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start($Muzzle.global_transform)
	$LaserSound.play()

func _on_gun_cooldown_timeout() -> void:
	can_shoot = true


func set_lives(value):
	lives = min(value, max_lives)
	lives_changed.emit(lives)
	if lives <= 0:
		change_state(player_state.DEAD)
	else:
		change_state(player_state.INVULNERABLE)
	shield_off = false
	shield = max_shield
	health = max_health
	
func add_life():
	lives += 1


func reset():
	reset_pos = true
	$Sprite2D.show()
	lives = 3
	change_state(player_state.ALIVE)

func _on_invulnerability_timer_timeout():
	change_state(player_state.ALIVE)

func _on_body_entered(body):
	if body.is_in_group("rocks"):
		take_damage(body.size * 25)
		body.explode()

func explode():
	$ExplosionSound.play()
	$Explosion.show()
	$Explosion/AnimationPlayer.play("explosion")
	await $Explosion/AnimationPlayer.animation_finished
	$Explosion.hide()
	
func set_shield(value):
	value = min(value, max_shield)
	shield = value
	shield_changed.emit(shield / max_shield)
	if shield <= 0:
		shield_off = true
	else: 
		shield_off = false
		#explode() # make this an electric explosion
	
func set_health(value):
		value = min(value, max_shield)
		health = value
		health_changed.emit(health / max_health)
		if health <= 0:
			lives -= 1
			explode()
			

func take_damage(value):
	value = min(value, max_health)
	if shield_off:
		health -= 1.5 * value
	else:
		shield -= value
	
