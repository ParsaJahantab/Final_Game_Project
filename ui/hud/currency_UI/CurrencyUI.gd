extends Control

@onready var label = $CanvasLayer/TextureRect/Label


# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.currency_changed.connect(change_text)
	GameState.temp_currency_changed.connect(change_text)

	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func change_text():
	label.text = str(GameState.player_currency) + " + " + str(GameState.temp_player_currency)
