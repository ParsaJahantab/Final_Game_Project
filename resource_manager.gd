extends Node

func _ready():
	pass

func new_game():
	GameState.player_currency = 3000
	GameState.temp_player_currency = 0
	GameState.player_health_level = 1
	GameState.player_mana_level = 3
	GameState.player_speed_level = 1
	GameState.player_damage_level = 1
	GameState.required_mythril = 50
	GameState.avaialble_levels = 2
	GameState.shown_hints = []
	
	GameState.currency_changed.emit()
	GameState.temp_currency_changed.emit()
	
	save_game()
	
	return true

func save_game():
	var save_data = GameSaveResource.new()
	
	save_data.player_currency = GameState.player_currency
	save_data.player_health_level = GameState.player_health_level
	save_data.player_mana_level = GameState.player_mana_level
	save_data.player_speed_level = GameState.player_speed_level
	save_data.player_damage_level = GameState.player_damage_level
	save_data.required_mythril = GameState.required_mythril
	save_data.avaialble_levels = GameState.avaialble_levels
	save_data.shown_hints = GameState.shown_hints
	
	var error = ResourceSaver.save(save_data, "user://game_save.tres")
	if error != OK:
		print("An error occurred while saving the game.")
		return false
	return true
	
func load_game():
	if not FileAccess.file_exists("user://game_save.tres"):
		print("No save file found!")
		return false
	
	# Load the resource file
	var save_data = ResourceLoader.load("user://game_save.tres") as GameSaveResource
	if save_data == null:
		print("Error loading save file!")
		return false
	
	GameState.player_currency = save_data.player_currency
	GameState.temp_player_currency = save_data.temp_player_currency
	GameState.player_health_level = save_data.player_health_level
	GameState.player_mana_level = save_data.player_mana_level
	GameState.player_speed_level = save_data.player_speed_level
	GameState.player_damage_level = save_data.player_damage_level
	GameState.required_mythril = save_data.required_mythril
	GameState.avaialble_levels = save_data.avaialble_levels
	GameState.shown_hints = save_data.shown_hints
	
	# Emit signals to update UI
	GameState.currency_changed.emit()
	GameState.temp_currency_changed.emit()
	
	return true
	
func has_save_file() -> bool:
	return FileAccess.file_exists("user://game_save.tres")
