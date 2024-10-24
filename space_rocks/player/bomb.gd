extends Area2D

@export var max_radius = 200  # Maximum size of the bomb's radius
@export var expansion_speed = 100  # How fast the radius expands
var explosion_active = false
var radius = 0  # Current radius

func _ready():
	# Start expanding the bomb
	explosion_active = true

func _physics_process(delta):
	if explosion_active:
		# Increase the radius gradually
		radius += expansion_speed * delta
		$CollisionShape2D2.radius = radius

		# Stop the explosion when it reaches the max radius
		if radius >= max_radius:
			explosion_active = false
			queue_free()  # Remove the bomb after the explosion

func _on_body_entered(body):
	# Check if the body is an enemy or object you want to destroy
	if body.is_in_group("enemies") or body.is_in_group("rocks"):
		body.explode()  # Destroy the object
