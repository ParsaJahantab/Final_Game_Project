extends Control


func _ready():
	print(GameState.has_save_file())
	if GameState.has_save_file():
		$CanvasLayer/ContinueGameButton.show()
		$CanvasLayer/ContinueGameButton.disabled = false 
	else:
		$CanvasLayer/ContinueGameButton.hide()
		$CanvasLayer/ContinueGameButton.disabled = true 


func _process(delta):
	pass


func _on_new_game_button_pressed():
	GameState.new_game()
	get_tree().process_frame
	get_tree().process_frame
	get_tree().process_frame
	get_tree().change_scene_to_file("res://hub/hub.tscn")


func _on_exit_game_button_pressed():
	GameState.save_game()
	get_tree().quit()



func _on_continue_game_button_pressed():
	GameState.load_game()
	get_tree().process_frame
	get_tree().process_frame
	get_tree().process_frame
	get_tree().change_scene_to_file("res://hub/hub.tscn")
