extends Node2D

@export var offset = Vector2(0,200)
@export var duration = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_loops().set_parallel(false)
	tween.tween_property($TileMap, "position", offset, duration / 2.0).from_current()
	tween.tween_property($TileMap, "position", Vector2.ZERO, duration / 2.0)
	tween.set_trans(Tween.TRANS_SINE)
