extends Node2D

var player_currency := 3000
var temp_player_currency :=0
var player_health_level := 1
var player_mana_level := 3
var player_speed_level := 1
var player_damage_level := 1
var required_mythril := 50
var avaialble_levels = 1

signal currency_changed
signal temp_currency_changed



func _ready():
	await get_tree().process_frame
	await get_tree().process_frame
	currency_changed.emit()
	
func currency_change(amount_of_change : int):
	player_currency = player_currency + amount_of_change
	currency_changed.emit()
func temp_currency_change(amount_of_change : int):
	temp_player_currency = temp_player_currency + amount_of_change
	temp_currency_changed.emit()

func _process(delta):
	pass
