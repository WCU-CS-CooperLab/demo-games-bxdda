extends CharacterBody2D

signal life_changed
signal died


@export var gravity = 750
@export var run_speed = 150
@export var jump_speed = -300
@export var climb_speed = 50


@export var max_jumps = 2
@export var double_jump_factor = 0.9

var jump_count = 0
var is_on_ladder = false
var life = 3: set = set_life

enum PlayerState{ IDLE, RUN, JUMP, HURT, DEAD, CLIMB}
var state = PlayerState.IDLE

func _ready():
	change_state(PlayerState.IDLE)

func change_state(new_state):
	state = new_state
	match new_state:
		PlayerState.IDLE:
			$AnimationPlayer.play("idle")
			await get_tree().create_timer(0.2).timeout
			$Dust2.hide()
			$Dust3.hide()
		PlayerState.RUN:
			$AnimationPlayer.play("run")
		PlayerState.HURT:
			$AnimationPlayer.play("hurt")
			$HurtSound.play()
			if life > 1:
				velocity.y = -200
				velocity.x = -100 *sign(velocity.x)
			life -= 1
			if life > 0:
				await get_tree().create_timer(0.5).timeout
				change_state(PlayerState.IDLE)
		PlayerState.JUMP:
			$AnimationPlayer.play("jump_up")
			$JumpSound.play()
			jump_count = 1
			await get_tree().create_timer(0.45).timeout
			$Dust2.hide()
			$Dust3.hide()
		PlayerState.DEAD:
			$CollisionShape2D.disabled = true
			$Death.play()
			died.emit()
			velocity.y = -700
			await get_tree().create_timer(1).timeout
			velocity.y = 700
		PlayerState.CLIMB:
			$Dust2.hide()
			$Dust3.hide()
			$AnimationPlayer.play("climb")

func get_input():
	if state == PlayerState.HURT:
			return
	var right = Input.is_action_pressed("right")	
	var left = Input.is_action_pressed("left")	
	var jump = Input.is_action_pressed("jump")	
	var up = Input.is_action_pressed("climb")
	var down = Input.is_action_pressed("crouch")
	#movement occurs in all states
	
	velocity.x = 0
	if right && state != PlayerState.DEAD:
		if is_on_floor():
			$Dust2.show()
			$Dust3.show()
		velocity.x += run_speed
		$Sprite2D.flip_h = false
	if left && state != PlayerState.DEAD:
		if is_on_floor():
			$Dust2.show()
			$Dust3.show()
		velocity.x -= run_speed
		$Sprite2D.flip_h = true
	
	
	#only jump when on the ground
	if jump and is_on_floor():
		change_state(PlayerState.JUMP)
		velocity.y = jump_speed
		
		#IDLE transitions to RUN when moving
	if state == PlayerState.IDLE and velocity.x != 0:
		change_state(PlayerState.RUN)
		
		#RUN transitions to IDLE when standing still
	if state == PlayerState.RUN	 and velocity.x == 0:
		change_state(PlayerState.IDLE)
			
		#transition to jump in air
	if state in [PlayerState.IDLE, PlayerState.RUN] and !is_on_floor():
		change_state(PlayerState.JUMP)
	if up and state != PlayerState.CLIMB and is_on_ladder:
		change_state(PlayerState.CLIMB)
	if state == PlayerState.CLIMB:
		if up:
			velocity.y = -climb_speed
			$AnimationPlayer.play("climb")
		elif down:
			velocity.y = climb_speed
			$AnimationPlayer.play("climb")
		else:
			velocity.y = 0
			$AnimationPlayer.stop()
		if state == PlayerState.CLIMB and not is_on_ladder:
			change_state(PlayerState.IDLE)


func _physics_process(delta):
	velocity.y += gravity * delta
	get_input()
	move_and_slide()
	if state == PlayerState.HURT:
		return
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("danger"):
			hurt()
		if collision.get_collider().is_in_group("enemies"):
			if position.y < collision.get_collider().position.y:
				collision.get_collider().take_damage()
				velocity.y = -200
			else:
				hurt()
	if state == PlayerState.JUMP and is_on_floor():
		change_state(PlayerState.IDLE)
		$Dust.emitting = true
		jump_count = 0
	if state == PlayerState.JUMP and velocity.y > 0 and life != 0:
		$AnimationPlayer.play("jump_down")
		if Input.is_action_pressed("jump") and jump_count == 1:
			$AnimationPlayer.play("jump_up")
			$JumpSound.play()
			jump_count = 2
			velocity.y = jump_speed
	if state != PlayerState.CLIMB:
		velocity.y += gravity * delta
	if position.y > 7000 && state != PlayerState.DEAD:
		GameState.gameover()

func reset(_position):
	position = _position
	show()
	change_state(PlayerState.IDLE)
	life = 3
	

func set_life(value):
	life = value
	life_changed.emit(life)
	if life <= 0:
		change_state(PlayerState.DEAD)

func hurt():
	if state != PlayerState.HURT:
		change_state(PlayerState.HURT)
func die():
	change_state(PlayerState.HURT)
	
	#change_state(PlayerState.DEAD)
