extends Area2D

signal picked_up

var types = {
	"health": "res://assets/health.png",
	"shield": "res://assets/shield_gold.png",
	"laser_upgrade": "res://assets/laser.png",
	"laser_beam": "res://assets/laser.png",
	"rapid_fire": "res://assets/laser.png",
	"laser_spread": "res://assets/laser_green.png"
	#"destructo": "res://assets/laser.png"
}
var type = null

func init(pos):
	type = types.keys()[randi() % types.size()]
	$Sprite2D.texture = load(types[type])
	if type in ["laser_upgrade", "laser_beam", "laser_spread", "rapid_fire"]:
		$Sprite2D.scale = Vector2(0.9, 0.9)
	position = pos

func init_type(type, pos):
	$Sprite2D.texture = load(types[type])
	if type == "laser_upgrade":
		$Sprite2D.scale = Vector2(-3, -3)
	position = pos
	self.type = type

func _on_body_entered(body: Node2D) -> void:
	picked_up.emit()
	if body.is_in_group("players"):
		powerup(body)
		print(type + " picked up")
		queue_free()

func powerup(body):
	match type:
		"health":
			body.give_health(25)
		"shield":
			body.give_shield(25)
		"laser_upgrade":
			body.laser_upgrade()
		"laser_beam":
			body.laser_beam()
		"rapid_fire":
			body.rapid_fire()
		"laser_spread":
			body.spreader()
				
