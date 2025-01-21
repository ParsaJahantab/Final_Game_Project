extends Node2D

var player_currency := 1000
var player_health_level := 1
var player_mana_level := 3
var player_speed_level := 1
var player_damage_level := 1
var required_mythril := 50

signal currency_changed


func _ready():
	pass # Replace with function body.
	
func currency_change(amount_of_change : int):
	player_currency = player_currency + amount_of_change
	currency_changed.emit()

func _process(delta):
	pass
