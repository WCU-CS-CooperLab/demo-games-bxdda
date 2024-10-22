extends Area2D
signal entered

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_ladders_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("on ladder")
		body.is_on_ladder = true


func _on_ladders_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("off ladder")
		await get_tree().create_timer(0.2).timeout
		body.is_on_ladder = false
