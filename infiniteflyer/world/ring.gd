extends Area3D

var move_x = false
var move_y = false
var move_amount = 2.5
var move_speed = 2.0

func _ready():
	$Score.hide()
	var tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	tween.stop()
	if move_y:
		tween.tween_property($CollisionShape3D,"position:y", -move_amount, move_speed)
		tween.tween_property($CollisionShape3D,"position:y", move_amount, move_speed)
		tween.play()
	if move_x:
		tween.tween_property($CollisionShape3D,"position:x", -move_amount, move_speed)
		tween.tween_property($CollisionShape3D,"position:x", move_amount, move_speed)
		tween.play()

func _on_body_entered(body):
	$CollisionShape3D/MeshInstance3D.hide()
	var d = global_position.distance_to(body.global_position)
	if d < 2.0:
		$Score.text = "200"
		$Score.modulate = Color(1, 1, 0)
		body.fuel = 10
		body.score += 200
	elif d > 3.5:
		$Score.text = "50"
		body.fuel += 1
		body.score += 50
	else:
		$Score.text = "100"
		body.fuel += 2.5
		body.score += 100
	$Score.show()
	var tween = create_tween().set_parallel()
	tween.tween_property($Score, "position", Vector3(0, 10, 0), 1.0)
	tween.tween_property($Score, "modulate:a", 0.0, 0.5)
	
	

func _process(delta: float) -> void:
	$CollisionShape3D/MeshInstance3D.rotate_y(deg_to_rad(50) * delta)
