extends Control

@onready var pause_menu = preload("res://ui/pause/pause_menu.tscn")  


func _ready():
	pass # Replace with function body.


func _process(delta):
	pass
	



func _on_texture_button_pressed():
	var pause = pause_menu.instantiate()
	var root = get_tree().get_root()
	root.add_child(pause)
