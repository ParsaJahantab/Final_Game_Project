extends CanvasLayer

var restart_button_pressed: bool = false

#func _on_ready():
	#process_mode = Node.PROCESS_MODE_ALWAYS
	#$PanelContainer/MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/RestartButton.process_mode = Node.PROCESS_MODE_ALWAYS 
	#$PanelContainer/MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/QuitButton.process_mode = Node.PROCESS_MODE_ALWAYS

func _on_restart_button_pressed() -> void:
	restart_button_pressed = true
	var room_level = 2
	SceneManager.goto_scene("res://hub/hub.tscn",room_level)



func _on_quit_button_pressed() -> void:
	get_tree().quit()
