extends Node2D
class_name Dungeon

var Room = preload("res://dungeon_rooms/room.tscn")  
var Win_sc = preload("res://ui/win_screen/win_screen.tscn")

var Hint = preload("res://ui/help_UI/help_screen.tscn") 
var player: Player
var tile_size = 16
var min_size : int = 15
var max_size : int = 30
var drew_once = false

var graph_generator: GraphGenerator
var current_graph: Array
var spanning_tree: Dictionary
var current_room: Node
var zoom = 1
var camera: Camera2D
var spawend : bool = false


var room_level = 2
var room_diff 

var dungeon_bonus : int

func _ready():
	$GameOverScreen.hide()
	player = $Player
	if not player:
		await get_tree().process_frame
		player = $Player
	player.initialize()
	player.died.connect(on_player_death)
	camera = player.get_node("Camera2D")
	if not camera:
		await get_tree().process_frame
	camera = player.get_node("Camera2D")
	zoom = camera.zoom.x
	y_sort_enabled = true
	move_child($Player, get_child_count() - 1)
	
	
func initialize(p_level):
	var num_nodes : int
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	if p_level == 1 :
		num_nodes = rng.randi_range(4,8)
		min_size = 10
		max_size = 20
		dungeon_bonus = rng.randi_range(50,100)
	elif p_level >= 2 and  p_level < 4:
		num_nodes = rng.randi_range(6,10)
		min_size = 15
		max_size = 25
		dungeon_bonus = rng.randi_range(75,125)
	elif p_level >= 4 :
		num_nodes = rng.randi_range(8,12)
		min_size = 20
		max_size = 30
		dungeon_bonus = rng.randi_range(100,150)
	room_level = p_level
	graph_generator = GraphGenerator.new()
	randomize()
	generate_new_level(num_nodes)
	
func generate_new_level(num_nodes):
	# Create the initial random graph
	current_graph = graph_generator.create_random_graph(num_nodes)
	process_rooms()
	
func process_rooms():
	var min_x = -200
	var max_x = 200
	var base_y = 0
	var last_room
	# Iterate through all nodes
	for node in current_graph:
		var w = randi_range(min_size, max_size)
		if w * tile_size < get_viewport_rect().size.x / zoom:
			w = (get_viewport_rect().size.x/tile_size) / zoom
		var h = randi_range(min_size, max_size)
		if h * tile_size < get_viewport_rect().size.y / zoom:
			h = (get_viewport_rect().size.y/tile_size) / zoom
		if last_room : 
			base_y = base_y + (w * tile_size) + last_room.size.x + randf_range(10, 15) * tile_size
		else :
			base_y = base_y + (w * tile_size) + randf_range(10, 15) * tile_size
			
		var pos = Vector2(
			randf_range(min_x, max_x),
			base_y
		)
		var r = Room.instantiate()
		if node.id == 0 : 
			r.init(node.id,node.connections,player,GlobalConfig.LEVEL_TO_DIFF[room_level] , GlobalConfig.Room_type.FIRST,Vector2(w, h) * tile_size , tile_size,room_level)
		elif node.id == current_graph.size()-1:
			r.init(node.id,node.connections,player,GlobalConfig.LEVEL_TO_DIFF[room_level] , GlobalConfig.Room_type.LAST,Vector2(w, h) * tile_size , tile_size,room_level)
		else :	
			r.init(node.id,node.connections,player,GlobalConfig.LEVEL_TO_DIFF[room_level] , GlobalConfig.Room_type.NORMAL,Vector2(w, h) * tile_size , tile_size,room_level)
		
		r.make_room(Vector2(pos.x,pos.y * -1))
		r.direction_detected.connect(on_player_exit)
		$Rooms.add_child(r)
		for direction in node.connections.keys():
			var connected_node = node.connections[direction]
			if connected_node != null:
				pass
		
		last_room = r
	change_room(0,"right")
	_draw()

	
func _draw():
	if not drew_once and  len($Rooms.get_children())>1: 
		for room in $Rooms.get_children():
			room.fill_floor_tiles()
		drew_once =  true 
	
func on_player_exit(id,direction,exit):
	if exit:
		GameState.currency_change(GameState.temp_player_currency + dungeon_bonus)
		if room_level == GameState.avaialble_levels:
			GameState.avaialble_levels += 1
		var wsc = Win_sc.instantiate()
		add_child(wsc)
	elif current_room.player_been_here and current_room.is_player_in_the_room:
		var opposites = {
			"top": "down",
			"down": "top",
			"left": "right",
			"right": "left"
		}
		current_room.is_player_in_the_room = false
		change_room(current_room.connections[direction].id,opposites[direction])
		
		
func change_room(index:int,direction):
	
	var new_room = $Rooms.get_child(index)
	current_room = new_room
	var new_player_pos : Vector2
	if not spawend : 
		spawend = true
		new_player_pos = Vector2(
			current_room.position.x + ((current_room.tiles_x/2) * tile_size),
			current_room.position.y + ((current_room.tiles_y/2) * tile_size)
		)
		if "first_dungeon" not in GameState.shown_hints:
			var hint = Hint.instantiate()
			var hints : Array[String] = ["Each dungeon has a number of rooms","Beat the ones in the main path","To beat the dungeon","each dungeon yields an amount of currency"]
			hint.initialize(hints)
			add_child(hint)
			GameState.shown_hints.append("first_dungeon")
	else : 
		if room_level == 1 and "goblin" not in GameState.shown_hints:
			var hint = Hint.instantiate()
			var hints : Array[String] = ["Goblins are fast" , "They are meele enemies and swarm you" , "Yet, they have low damage and health" , "Each enemy yields an amount of currency"]
			hint.initialize(hints)
			add_child(hint)
			GameState.shown_hints.append("goblin")
		if room_level >= 2 and "hobgoblin" not in GameState.shown_hints:
			var hint = Hint.instantiate()
			var hints : Array[String] = ["Watch out hobgoblins are here too" , "They are ranged enemies that throw spears at you" , "Once you get close to them,they'll run away" , "Also remember enemies get stronger in each level "]
			hint.initialize(hints)
			add_child(hint)
			GameState.shown_hints.append("hobgoblin")
		if room_level >= 4 and "orc" not in GameState.shown_hints:
			var hint = Hint.instantiate()
			var hints : Array[String] = ["Watch out orc are here too" , "They are meele enemies" , "With they have high damage and health"]
			hint.initialize(hints)
			add_child(hint)
			GameState.shown_hints.append("orc")
		if direction == "left": 
			new_player_pos = Vector2(
				current_room.position.x + (-2 * tile_size),
				current_room.position.y + (current_room.left_spike_y * tile_size)
		)
		elif direction == "right": 
			new_player_pos = Vector2(
				current_room.position.x + (2 * tile_size) + (current_room.tiles_x * tile_size),
				current_room.position.y + (current_room.right_spike_y * tile_size)
		)
		elif direction == "top": 
			new_player_pos = Vector2(
				current_room.position.x + current_room.top_door_x * tile_size,
				current_room.position.y + (-2 * tile_size)
		)
		elif direction == "down": 
			new_player_pos = Vector2(
				current_room.position.x + current_room.bottom_door_x * tile_size,
				current_room.position.y + (current_room.tiles_y * tile_size )+(2 * tile_size)
		)
		
	player.position = new_player_pos
	var tilemap = current_room.get_node("DungeonTileMap")
	var map_rect = tilemap.get_used_rect()
	
	#var tile_size = tilemap.tile_set.tile_size
	
	## Calculate pixel coordinates
	var limits_min = map_rect.position * tile_size
	var limits_max = (map_rect.position + map_rect.size) * tile_size
	#
	## Set camera limits
	camera.limit_left = current_room.position.x
	camera.limit_top = current_room.position.y + +tile_size/2
	camera.limit_right = current_room.position.x + ((current_room.tiles_x) * tile_size)
	camera.limit_bottom = current_room.position.y + ((current_room.tiles_y) * tile_size)

func on_player_death():
	$GameOverScreen.show()
	#get_tree().paused = true
	if $GameOverScreen.restart_button_pressed:
		player.initialize()
		GameState.temp_currency_change(GameState.temp_player_currency * -1)
		#get_tree().paused = false
