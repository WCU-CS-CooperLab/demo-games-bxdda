extends Node

@export var rock_scene : PackedScene
@export var enemy_scene : PackedScene
@export var powerup_scene: PackedScene

var screensize = Vector2.ZERO

var level = 0
var score = 0
var playing = false
var enemies = []
var powerup_count = 0
var enemy_count = 0

func _ready():
	screensize = get_viewport().get_visible_rect().size
	for i in 3:
		spawn_rock(3)

func spawn_rock(size, pos=null, vel=null):
	if pos == null:
		$RockPath/RockSpawn.progress = randi()
		pos = $RockPath/RockSpawn.position
	if vel == null:
		vel = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(50, 125)
	var r = rock_scene.instantiate()
	r.screensize = screensize
	r.start(pos, vel, size)
	call_deferred("add_child", r)
	r.exploded.connect(_on_rock_exploded)
	
func _on_enemy_exploded(pos):
	score += 50
	spawn_powerup(pos)
	

func _on_rock_exploded(size, radius, pos, vel):
	score += size * 5
	$ExplosionSound.play()
	if size <= 1:
		if randf() > 0.8:
			if powerup_count >= 1:
				spawn_powerup(pos)
				powerup_count -= 1
		return
	for offset in [-1, 1]:
		var dir = $Player.position.direction_to(pos).orthogonal() * offset
		var newpos = pos + dir * radius
		var newvel = dir * vel.length() * 1.1
		spawn_rock(size - 1, newpos, newvel)

func spawn_powerup(pos):
	var pu = powerup_scene.instantiate()
	pu.init(pos)
	call_deferred("add_child", pu)



func new_game():
# remove any old rocks from previous game
	$Player.playing = true
	$Music.play()
	get_tree().call_group("rocks", "queue_free")
	get_tree().call_group("power_ups", "queue_free")
	get_tree().call_group("enemies", "queue_free")
	level = 0
	score = 0
	$HUD.update_score(score)
	$HUD.show_message("ARE YOU READY?")
	$Player.reset()
	await $HUD/Timer.timeout
	playing = true
	

func new_level():
	$LevelupSound.play()
	level += 1
	if level >= 1:
		score += 10
		powerup_count = 5
		enemy_count = randi() % 6
	elif level > 10:
		score += 5
		powerup_count = 8
		enemy_count = randi() % 9
	$HUD.show_message("LEVEL %s" % level)
	for i in level * 3:
		spawn_rock(randi_range(1, 6))
	$EnemyTimer.start(randf_range(5, 10))

func _process(delta):
	$HUD.update_score(score)
	if not playing:
		return
	if get_tree().get_nodes_in_group("rocks").size() == 0:
		new_level()

func game_over():
	playing = false
	$HUD.game_over()
	$Music.stop()
	
	
func _input(event):
	if event.is_action_pressed("pause"):
		if not playing:
			return
		get_tree().paused = not get_tree().paused
		var message = $HUD/Message
		if get_tree().paused:
			message.text = "Paused"
			message.show()
		else:
			message.text = ""
			message.hide()
	if event.is_action_pressed("menu"):
		$HUD/MarginContainer/HBoxContainer/MenuButton._on_pressed()
		_on_menu_button_pressed()
	if event.is_action_pressed("new_life"):
		if ($Player.lives < 3) && (score / 500 >= 1):
			$Player.add_life()
			score -= 500

func _on_enemy_timer_timeout():
	if playing:
		if enemy_count >= 1:
			var e = enemy_scene.instantiate()
			enemies.append(e)
			add_child(e)
			e.target = $Player
			e.exploded.connect(self._on_enemy_exploded)
			$EnemyTimer.start(randf_range(20, 40))
			enemy_count -= 1


func _on_menu_button_pressed() -> void:
	if playing:
		get_tree().paused = not get_tree().paused
