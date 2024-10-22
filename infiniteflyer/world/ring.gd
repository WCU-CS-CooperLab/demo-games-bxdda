extends Area3D

func _ready():
	$Label3D.hide()

func _on_body_entered(body):
	$CollisionShape3D/MeshInstance3D.hide()
	var d = global_position.distance_to(body.global_position)
	if d < 2.0:
		$Score.text = "200"
		$Score.modulate = Color(1, 1, 0)
	elif d > 3.5:
		$Score.text = "50"
	else:
		$Score.text = "100"
	$Score.show()
	var tween = create_tween().set_parallel()
	tween.tween_property($Label3D, "position", Vector3(0, 10, 0), 1.0)
	tween.tween_property($Label3D, "modulate:a", 0.0, 0.5)
	
	

func _process(delta: float) -> void:
	$CollisionShape3D/MeshInstance3D.rotate_y(deg_to_rad(50) * delta)
