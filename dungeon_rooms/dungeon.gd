extends Node2D
class_name  Dungeon

var Room = preload("res://dungeon_rooms/room.tscn")  
@export var player: Player
var tile_size = 16
var num_rooms = 5
var min_size = 15
var max_size = 30
var drew_once = false
var level = 2
var graph_generator: GraphGenerator
var current_graph: Array
var spanning_tree: Dictionary
var current_room: Node
var zoom = 1
var camera: Camera2D

func _ready():
	if not player:
		await get_tree().process_frame
	player.initialize()
	camera = player.get_node("Camera2D")
	if not camera:
		await get_tree().process_frame
	camera = player.get_node("Camera2D")
	zoom = camera.zoom.x
	y_sort_enabled = true
	graph_generator = GraphGenerator.new()
	randomize()
	generate_new_level()
	move_child($Player, get_child_count() - 1)
	
func generate_new_level():
	# Create the initial random graph
	current_graph = graph_generator.create_random_graph()
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
			r.init(node.id,node.connections,player,GlobalConfig.Room_diff.EASY , GlobalConfig.Room_type.FIRST,Vector2(w, h) * tile_size , tile_size,level)
		elif node.id == current_graph.size()-1:
			r.init(node.id,node.connections,player,GlobalConfig.Room_diff.EASY , GlobalConfig.Room_type.LAST,Vector2(w, h) * tile_size , tile_size,level)
		else :	
			r.init(node.id,node.connections,player,GlobalConfig.Room_diff.EASY , GlobalConfig.Room_type.NORMAL,Vector2(w, h) * tile_size , tile_size,level)
		
		r.make_room(Vector2(pos.x,pos.y * -1))
		#r.visible = false
		#r.process_mode = 4s
		r.direction_detected.connect(on_player_exit)
		$Rooms.add_child(r)
		#print('\n')
		#print(node.id)
		for direction in node.connections.keys():
			var connected_node = node.connections[direction]
			if connected_node != null:
				#print("- Connected to room ", connected_node.id, " via ", direction)
				pass
		
		last_room = r
	change_room(0,"right")

	
func _draw():
	if not drew_once : 
		for room in $Rooms.get_children():
			room.fill_floor_tiles()
		drew_once =  true 
	
func on_player_exit(id,direction,exit):
	if exit:
		GameState.currency_change(GameState.temp_player_currency)
		GameState.temp_currency_change(GameState.temp_player_currency * -1)
		queue_free()
	elif current_room.player_been_here and current_room.is_player_in_the_room:
		#print("id: " , id , " signal: ",direction)
		#print(current_room.connections[direction])
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
	if index == 0 : 
		new_player_pos = Vector2(
			current_room.position.x + ((current_room.tiles_x/2) * tile_size),
			current_room.position.y + ((current_room.tiles_y/2) * tile_size)
		)
	else : 
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
		pass
	player.position = new_player_pos
	var tilemap = current_room.get_node("DungeonTileMap")
	var map_rect = tilemap.get_used_rect()
	#var tile_size = tilemap.tile_set.tile_size
	#
	## Calculate pixel coordinates
	var limits_min = map_rect.position * tile_size
	var limits_max = (map_rect.position + map_rect.size) * tile_size
	#
	## Set camera limits
	camera.limit_left = current_room.position.x
	camera.limit_top = current_room.position.y + tile_size/2
	camera.limit_right = current_room.position.x + ((current_room.tiles_x) * tile_size)
	camera.limit_bottom = current_room.position.y + ((current_room.tiles_y) * tile_size)
#
#
#func _input(event):
	#if event.is_action_pressed('ui_select'):
		#for n in $Rooms.get_children():
			#n.queue_free()
		#make_rooms()
		#_draw()
