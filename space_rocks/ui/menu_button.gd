extends MenuButton
@onready var prev_window = DisplayServer.window_get_mode()

var resolutions = [
	Vector2(1280, 720),
	Vector2(1920, 1080),
	Vector2(2560, 1440),
	Vector2(3840, 2160)
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ItemList.visible = false
	$ItemList2.visible = false
	for resolution in resolutions:
		$ItemList/VBoxContainer2/OptionButton.add_item(str(resolution.x) + "x" + str(resolution.y))
	var current_resolution = DisplayServer.window_get_size()
	for i in range(resolutions.size()):
		if resolutions[i].x == current_resolution.x and resolutions[i].y == current_resolution.y:
			$ItemList/VBoxContainer2/OptionButton.select(i)
			break
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_item_list_item_activated(index: int) -> void:
	match index:
		0:
			print("Settings")
			$ItemList2.hide()
			$ItemList/VBoxContainer.show()
			$ItemList/VBoxContainer2.show()
		1:
			print("Controls")
			$ItemList/VBoxContainer.hide()
			$ItemList/VBoxContainer2.hide()
			$ItemList2.show()
		2:
			print("Exit")
			get_tree().quit()

func _on_res_item_selected(index):
	var user_resolution = DisplayServer.window_get_size()
	if !resolutions.has(user_resolution):
		resolutions.append(user_resolution)
		$ItemList/VBoxContainer2/OptionButton.add_item(str(user_resolution))

	var new_resolution = resolutions[index]
	DisplayServer.window_set_size(new_resolution)


func _on_pressed() -> void:
	$ItemList.visible = !$ItemList.visible 
	if $ItemList/VBoxContainer.visible and $ItemList/VBoxContainer2.visible:
		$ItemList/VBoxContainer.visible = !$ItemList/VBoxContainer.visible
		$ItemList/VBoxContainer2.visible = !$ItemList/VBoxContainer2.visible
	
func _on_volume_slider_value_changed(value):
	# Set the Master bus volume based on the slider value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)

func _on_fullscreen_toggled(toggled):
	var curr_window = DisplayServer.window_get_mode()
	if toggled:
		prev_window = curr_window
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	else:
		DisplayServer.window_set_mode(prev_window)
		
func _on_vsync_toggled(toggled):
	ProjectSettings.set_setting("display/window/vsync/use_vsync", toggled)
	


func _on_item_list_2_empty_clicked(at_position: Vector2, mouse_button_index: int) -> void:
	$ItemList2.hide()
