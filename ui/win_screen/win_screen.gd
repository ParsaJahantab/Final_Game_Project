extends CanvasLayer


@onready var currency: Label = $MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/Currency

func _ready() -> void:
	currency.text = "Currency:  " + str(GameState.temp_player_currency)


func _on_texture_button_pressed() -> void:
	GameState.temp_currency_change(GameState.temp_player_currency * -1)
	SceneManager.goto_scene("res://hub/hub.tscn", 2)
	queue_free() 
