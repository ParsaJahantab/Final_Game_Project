extends Node2D

class_name Hub

var player: Player
var HUD 
var Hint = preload("res://ui/help_UI/help_screen.tscn")  

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
		SceneManager.load_hub()
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
			

		player.position = Vector2(0, 0)
	
	
	player.camera.limit_left = -28 * 16
	player.camera.limit_top = -14 * 16
	player.camera.limit_right = 28 * 16
	player.camera.limit_bottom = 14 * 16
	$RingKeeper.player = player
	player.initialize()
	player.sprite.frame = 60
	if "movement" not in GameState.shown_hints:
		var hint = Hint.instantiate()
		var hints : Array[String] = ["Press 'W' to move up","Press 'S' to move down","Press 'D' to move right","Press 'A' to move left" , "Press space to roll"]
		hint.initialize(hints)
		add_child(hint)
		GameState.shown_hints.append("movement")
		await hint.done
	if "attack" not in GameState.shown_hints:
		var hint = Hint.instantiate()
		var hints : Array[String] = ["Press 'LMB' for light attack","Press 'RMB' for heavy attack","Heavy attack deals more damage" , "It also has more range" , "However, it is slower"]
		hint.initialize(hints)
		add_child(hint)
		GameState.shown_hints.append("attack")
		await hint.done
	if "upgrade" not in GameState.shown_hints:
		var hint = Hint.instantiate()
		var hints : Array[String] = ["Press 'E' to interact with the upgrade  \n when near the ringkeeper" , "Each upgrade require currency" , "The amount of currency gets higher \n with each upgrade"]
		hint.initialize(hints)
		add_child(hint)
		GameState.shown_hints.append("upgrade") 
		
		


		

func initialize(params):
	pass
func _process(delta):
	pass
	
func on_exit(level : int) -> void:
	SceneManager.goto_scene("res://dungeon_rooms/dungeon.tscn",level)
