extends Control

var level : int 
var base_level : int
@onready var label := $Label
@onready var attribute_label := $Attribute


signal increase_button
signal decrease_button

func _ready():
	
	initialize_attribute("health")

func _process(_delta):
	pass

func initialize_attribute(attribute: String):
	attribute_label.text = attribute + ":"
	var attribute_name = "player_" + attribute + "_level" 
	level = GameState.get(attribute_name)
	base_level = level
	label.text = str(level)

func _on_right_button_pressed():
	level += 1
	label.text = str(level)
	increase_button.emit()

func _on_left_button_pressed():
	if level > base_level :
		level -= 1
		label.text = str(level)
		decrease_button.emit()
