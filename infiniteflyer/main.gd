extends Node3D

var chunk = preload("res://world/Chunk.tscn")

var num_chunks = 1
var chunk_size = 200
var max_position = -100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $Plane.position.z < max_position:
		num_chunks += 1
		var new_chunk = chunk.instantiate()
		new_chunk.position.z = max_position - chunk_size / 2
		new_chunk.level = num_chunks / 4
		add_child(new_chunk)
		max_position -= chunk_size
