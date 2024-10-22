extends Area2D

signal picked_up

var type = ""
var carrier = null
var snagged = false
var textures = {
	"cherry": "res://assets/sprites/cherry.png",
	"gem": "res://assets/sprites/gem.png"
	}
	
func init(type):
	$Sprite2D.texture = load(textures[type])
	$AnimationPlayer.play(type)
	self.type = type

func _process(delta):
	if snagged and carrier:
		position = carrier.position

func _on_item_body_entered(body):
	if body.is_in_group("enemies"):
		snagged = true
		carrier = body
		carrier.add_child(self)  # This parents the item to the enemy
	else:
		picked_up.emit()
		print("picked up")
		queue_free()
	
	
