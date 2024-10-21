extends Node2D

signal score_changed
signal gems_changed


var door_scene = load("res://items/door.tscn")
var item_scene = load("res://items/item.tscn")
var score = 0: set = set_score
var gems = 0: set = set_gems


func _ready(): 
	$Items.hide()
	$Player.reset($SpawnPoint.position)
	set_camera_limits()
	connect_items()
	connect_gems()
	connect_triggers()
	$ThemeMusic.play()
	score = 100
	$Door.body_entered.connect(_on_door_entered)
	
	
	
	


func set_camera_limits():
	var map_size = $World.get_used_rect()
	var cell_size = $World.tile_set.tile_size
	$Player/Camera2D.limit_left = (map_size.position.x - 5) * cell_size.x
	$Player/Camera2D.limit_right = (map_size.end.x + 5) * cell_size.x
	$Player/Camera2D.limit_bottom = 5000
	$Player/Camera2D.limit_top = -2000
	
func set_score(value):
	score = value
	score_changed.emit(score)
	
	

func set_gems(value):
	gems = value
	gems_changed.emit(gems)
	
	
#func spawn_items():
	#var item_cells = $Items.get_used_cells(0)
	#for cell in item_cells:
		#var data =$Items.get_cell_tile_data(0,cell)
		#var type = data.get_custom_data("type")
		#if type == "door":
			#var door = door_scene.instantiate()
			#add_child(door)
			#print("creating door", type)
			#door.position = $Items.map_to_local(cell)
			#
		#else:
			#
			#var item = item_scene.instantiate()
			#add_child(item)
			#print("creating ", type)
			#item.init(type,$Items.map_to_local(cell))
			#item.picked_up.connect(self._on_item_picked_up)

func _on_door_entered(body):
	GameState.next_level()

func connect_items():
	var items_group = $ItemsGroup
	for child in items_group.get_children():
		if child.has_signal("picked_up"):  # Check if the child has the "picked_up" signal
			child.picked_up.connect(_on_item_picked_up)
			

func connect_gems():
	var gems_group = $GemsGroup
	var hidden_gems = $HiddenGems
	for child in gems_group.get_children():
		child.init("gem")
		if child.has_signal("picked_up"):  # Check if the child has the "picked_up" signal
			child.picked_up.connect(_on_gems_picked_up)
	for child in hidden_gems.get_children():
		child.init("gem")
		child.hide()
		if child.has_signal("picked_up"):  # Check if the child has the "picked_up" signal
			child.picked_up.connect(_on_gems_picked_up)

func connect_triggers():
	var triggers_group = $Triggers
	for child in triggers_group.get_children():
		if child.has_signal("entered"):  
			child.entered.connect(show_hidden)
		if child.has_signal("died"):  
			child.died.connect(show_hidden)
	
func _on_item_picked_up():
	score += 50

func _on_gems_picked_up():
	gems += 1

func _on_player_died() -> void:
	await get_tree().create_timer(1.7).timeout
	GameState.gameover()
	

func _on_ladders_body_entered(body: Node2D) -> void:
	body.is_on_ladder = true


func _on_ladders_body_exited(body: Node2D) -> void:
	body.is_on_ladder = false


func _on_enemy_died() -> void:
	score += 100

func show_hidden():
	var hidden_gems = $HiddenGems
	for child in hidden_gems.get_children():
		child.visible = true
		
