extends Node2D

class_name Hub

var player: Player
var HUD 

static var player_added = false

func _ready():
	await get_tree().process_frame

	var i: int = 1
	for door: Door in $Doors.get_children():
		door.exited.connect(Callable(self, "on_exit").bind(i))
		if i <= GameState.avaialble_levels:
			door.init_to_open()
		else:
			door.init_to_close()
		i += 1

	if not player_added:
		player = preload("res://character/player/player/player.tscn").instantiate()
		add_child(player)
		HUD = preload("res://ui/hud/hud.tscn").instantiate()
		HUD.player = player
		add_child(HUD)

		player_added = true
		if not SceneManager.persistent_nodes.has("HUD"):
			SceneManager.register_persistent_node(HUD, "HUD")
		if not SceneManager.persistent_nodes.has("Player"):
			SceneManager.register_persistent_node(player, "Player")
	else:
		player = SceneManager.persistent_nodes["Player"]
		HUD = SceneManager.persistent_nodes["HUD"]

		if not player.get_parent():
			add_child(player)
		if not HUD.get_parent():
			add_child(HUD)
			
		player.camera.limit_left = -10000000
		player.camera.limit_top = -10000000
		player.camera.limit_right = 10000000
		player.camera.limit_bottom = 10000000

		player.position = Vector2(0, 0)

	player.initialize()


		

func initialize(params):
	pass
func _process(delta):
	pass
	
func on_exit(level : int) -> void:
	SceneManager.goto_scene("res://dungeon_rooms/dungeon.tscn",level)
