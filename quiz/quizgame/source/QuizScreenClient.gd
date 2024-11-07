extends Control


func _on_quiz_panel_answered(is_answer_correct):
	pass


@rpc
func answered(user):
	pass


@rpc
func missed(user):
	pass
