extends Control

class_name Hint

@onready var next_button = $CanvasLayer/NextButton
@onready var prev_button = $CanvasLayer/PreviousButton
@onready var done_button = $CanvasLayer/DoneButton
@onready var label = $CanvasLayer/Label

var _texts : Array[String]
var index : int = 0

signal done

func _ready():
	GameState.pause()
	label.text = _texts[0]
	show_buttons()
	

func initialize(texts : Array[String]):
	_texts = texts


func _process(delta):
	pass
	
func show_buttons():
	if index == len(_texts) -1:
		disable_or_enable_button(next_button,false)
		disable_or_enable_button(done_button,true)
	else:
		disable_or_enable_button(next_button,true)
		disable_or_enable_button(done_button,false)
	if index == 0:
		disable_or_enable_button(prev_button,false)
	else:
		disable_or_enable_button(prev_button,true)

func disable_or_enable_button(button,is_button_active : bool):
	button.disabled = not is_button_active
	button.visible = is_button_active

func _on_next_button_pressed():
	index +=1
	label.text = _texts[index]
	show_buttons()

func _on_previous_button_pressed():
	index -=1
	label.text = _texts[index]
	show_buttons()
	
func _on_done_button_pressed():
	GameState.unpause()
	done.emit()
	GameState.save_game()
	queue_free()
