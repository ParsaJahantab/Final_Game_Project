extends Node2D

var player_currency := 0

signal currency_changed


func _ready():
	pass # Replace with function body.
	
func currency_change(amount_of_change : int):
	player_currency = player_currency + amount_of_change
	currency_changed.emit()

func _process(delta):
	pass
