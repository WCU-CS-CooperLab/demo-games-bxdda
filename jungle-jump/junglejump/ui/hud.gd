extends MarginContainer

@onready var life_counter = $HBoxContainer/LifeCounter.get_children()
var score = 0
var gems = 0
func update_life(value):
	for heart in life_counter.size():
		life_counter[heart].visible = value > heart
		
func update_score(value):
	$HBoxContainer/Score.text = str(value)
	score = int($HBoxContainer/Score.text)
	
	if (value != 100): 
		$HBoxContainer/Score/LowEffect.emitting = true
		$HBoxContainer/Score/Points2.play()
		
	if (score > 500):
		$HBoxContainer/Score/HighEffect.emitting = true
		$HBoxContainer/Score/Points.play()

func update_gems(value):
	$HBoxContainer2/Gems.text = str(value)
	gems = int($HBoxContainer2/Gems.text)
