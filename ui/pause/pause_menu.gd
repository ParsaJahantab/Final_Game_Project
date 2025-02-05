extends Control


func _ready():
	GameState.pause()


func _process(delta):
	pass


func _on_exit_game_button_pressed():
	get_tree().quit()
	queue_free()


func _on_continue_game_button_pressed():
	GameState.unpause()
	queue_free()
