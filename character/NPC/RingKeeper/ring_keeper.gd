extends Node2D

@export var ui_scene: PackedScene 
var player : Player
var current_ui = null 
var player_in_range = false
var interact_key = KEY_E
var is_ui_open = false


func _ready():
	$AnimatedSprite2D.play("idle")


func _process(delta):
	if Input.is_action_just_pressed("interact") and player_in_range:
		open_ui()


func _on_area_2d_body_entered(body):
	player_in_range = true


func _on_area_2d_body_exited(body):
	player_in_range = false
		
func open_ui():
	if not current_ui:
		current_ui = ui_scene.instantiate()
		current_ui.closed.connect(_on_close)
		get_tree().root.add_child(current_ui)
		player.set_input_enable(false)
	is_ui_open = true
	
func _on_close():
	player.initialize()
	is_ui_open = false
	player.set_input_enable(true)
