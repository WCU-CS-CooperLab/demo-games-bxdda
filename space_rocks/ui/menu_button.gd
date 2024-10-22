extends MenuButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ItemList.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_item_list_item_activated(index: int) -> void:
	match index:
		0:
			print("Settings")
		1:
			print("Controls")
		2:
			print("Exit")
			get_tree().quit()


func _on_pressed() -> void:
	$ItemList.visible = !$ItemList.visible 
