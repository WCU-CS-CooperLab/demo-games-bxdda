extends CharacterBody2D

signal life_changed
signal died


@export var gravity = 750
@export var run_speed = 150
@export var jump_speed = -300

var life = 3: set = set_life

enum PlayerState{ IDLE, RUN, JUMP, HURT, DEAD}
var state = PlayerState.IDLE

func _ready():
	change_state(PlayerState.IDLE)

func change_state(new_state):
	state = new_state
	match new_state:
		PlayerState.IDLE:
			$AnimationPlayer.play("idle")
		PlayerState.RUN:
			$AnimationPlayer.play("run")
		PlayerState.HURT:
			$AnimationPlayer.play("hurt")
			velocity.y = -200
			velocity.x = -100 *sign(velocity.x)
			life -= 1
			await get_tree().create_timer(0.5).timeout
			change_state(PlayerState.IDLE)
		PlayerState.JUMP:
			$AnimationPlayer.play("jump_up")
			
		PlayerState.DEAD:
			$AnimationPlayer.play("dead")
			died.emit()
			hide()

func get_input():
	if state == PlayerState.HURT:
			return
	var right = Input.is_action_pressed("right")	
	var left = Input.is_action_pressed("left")	
	var jump = Input.is_action_pressed("jump")	

	#movement occurs in all states
	
	velocity.x = 0
	if right:
		velocity.x += run_speed
		$Sprite2D.flip_h = false
	if left:
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
	if state == PlayerState.JUMP and velocity.y > 0:
		$AnimationPlayer.play("jump_down")
		
	match state:
		PlayerState.IDLE:
			print("IDLE")	
		PlayerState.JUMP:
			print("JUMP")
		PlayerState.RUN:
			print("RUN")
		PlayerState.HURT:
			print("HURT")
		PlayerState.DEAD:
			print("DEAD")
	print("velocity y", velocity.y)
	print("velocity x", velocity.x)
	
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
