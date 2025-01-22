extends Node2D
class_name DungeonRoom

# Constants
const SPAWN_EXPLOSION_SCENE := preload("res://character/enemy/enemy_utils/spwan/spawn_explosion.tscn")
const DOOR := preload("res://dungeon_rooms/room_utils/door/door.tscn")
const HEALTH_POTION := preload("res://dungeon_rooms/room_utils/potions/health_potion.tscn")
const MANA_POTION := preload("res://dungeon_rooms/room_utils/potions/mana_potion.tscn")
const BLOCKING_SPIKE := preload("res://dungeon_rooms/room_utils/spike/blocking_spike.tscn")
const ENEMY_SCENES := {
	&"GOBLIN": preload("res://character/enemy/goblin/goblin.tscn")
}

const ROOM_POWER_MULTIPLIER := {
	GlobalConfig.Room_size.SMALL: 1.0,
	GlobalConfig.Room_size.MEDIUM: 1.5,
	GlobalConfig.Room_size.LARGE: 2.0
}

const ROOM_POWER_BASE := {
	GlobalConfig.Room_diff.EASY: 6,
	GlobalConfig.Room_diff.CHALLENGEING: 12,
	GlobalConfig.Room_diff.HARDCORE: 24
}

# Floor tile variations
const FLOOR_TILE_VARIATIONS := [
	Vector2i(3, 2),
	Vector2i(3, 3),
	Vector2i(2, 1),
	Vector2i(2, 2),
	Vector2i(2, 3),
	Vector2i(4, 2),
	Vector2i(4, 3),
	Vector2i(5, 2),
	Vector2i(5, 3)
]

# Wall tile patterns
const WALL_TILE_VARIATIONS := [
	Vector2i(6, 5),
	Vector2i(7, 5),
	Vector2i(8, 5)
]

const WALL_PATTERN := {
	"left": Vector2i(6, 4),
	"middle": Vector2i(7, 4),
	"right": Vector2i(8, 4)
}

const DECORATIONS := [
	Vector2i(5, 1),
	Vector2i(2, 0),
	Vector2i(0, 1),
	Vector2i(1, 0)
]

const MAX_DECORATIONS := {
	GlobalConfig.Room_size.SMALL: 2,
	GlobalConfig.Room_size.MEDIUM: 4,
	GlobalConfig.Room_size.LARGE: 6
}

const WALL_CLEARANCE := 2
const DOOR_CLEARANCE := 3
const SPAWN_CLEARANCE := 2

const DEFAULT_FLOOR_TILE := Vector2i(3, 1)
const VARIATION_CHANCE := 0.25

const COLLISION_AREA_OFFSET := 72.0
const AREA_SIZE := Vector2(64, 64)

const POTION_SPAWN_CHANCE := 0.4  
const MAX_POTIONS := 2
const POTION_CLEARANCE := 3  

signal direction_detected(id:int ,direction: String,exit:bool)

# Properties with type hints
@export var room_size: GlobalConfig.Room_size
@export var room_type: GlobalConfig.Room_type
@export var room_diff: GlobalConfig.Room_diff
@onready var collision_areas: Node2D = Node2D.new()

var size: Vector2
var tile_size: float
var tiles_x: int
var tiles_y: int
var top_door_x: int
var bottom_door_x: int
var left_spike_y: int
var right_spike_y: int
var room_enemy_power: float
var num_of_enemies: int
var is_in_conflict: bool
var is_player_in_the_room : bool
var enemies_killed := false
var exit_dungeon_door : String

var player: Node2D
var rng := RandomNumberGenerator.new()
var room_id: int
var connections: Dictionary
var player_been_here = false
var _level : int
# Node references using onready
@onready var tile_map: TileMap = $DungeonTileMap

func init(p_room_id: int, p_connected_rooms: Dictionary, p_player: Node2D, p_diff: GlobalConfig.Room_diff, p_type: GlobalConfig.Room_type, p_size: Vector2, p_tile_size: float , level:int) -> void:
	room_id = p_room_id
	connections = p_connected_rooms
	player = p_player
	room_diff = p_diff
	room_type = p_type
	size = p_size
	tile_size = p_tile_size
	_level = level
	
	tiles_x = int(size.x / tile_size)
	tiles_y = int(size.y / tile_size)
	
	room_enemy_power = ROOM_POWER_BASE[room_diff]
	
	var area := tiles_x * tiles_y
	room_size = _calculate_room_size(area)
	room_enemy_power *= ROOM_POWER_MULTIPLIER[room_size]
	
	if room_type == GlobalConfig.Room_type.FIRST:
		room_enemy_power = 0
		enemies_killed = true
	else:
		enemies_killed = false
	
func _ready() -> void:
	# Add collision areas node
	add_child(collision_areas)
	collision_areas.name = "CollisionAreas"

func _setup_doors() -> void:
	if (connections["top"] != null) or (room_type == GlobalConfig.Room_type.LAST and connections["top"] == null):
		top_door_x = rng.randi_range(3, tiles_x - 3)
		var top_door = DOOR.instantiate()
		# top_door.position = Vector2(position.x + (top_door_x * tile_size), position.y + tile_size)
		top_door.position = Vector2(top_door_x * tile_size, tile_size)
		top_door.entred.connect(_on_body_entered)
		$Doors.add_child(top_door)
		if room_type == GlobalConfig.Room_type.LAST and connections["top"] == null:
			exit_dungeon_door = "top"
		var top_area = _create_collision_area("top")
		top_area.position = Vector2(top_door_x * tile_size, COLLISION_AREA_OFFSET * -1) # Put it at the top edge
		collision_areas.add_child(top_area)
	
	# Setup bottom door if connection exists
	if connections["down"] != null or (room_type == GlobalConfig.Room_type.LAST and connections["down"] == null and connections["top"] != null):
		bottom_door_x = rng.randi_range(3, tiles_x - 3)
		var bottom_door = DOOR.instantiate()
		# bottom_door.position = Vector2(position.x + (bottom_door_x * tile_size),position.y+ (tiles_y - 1) * tile_size)
		bottom_door.position = Vector2((bottom_door_x * tile_size), (tiles_y - 1) * tile_size)
		bottom_door.entred.connect(_on_body_entered)
		$Doors.add_child(bottom_door)
		if room_type == GlobalConfig.Room_type.LAST and connections["down"] == null:
			exit_dungeon_door = "down"
		var bottom_area = _create_collision_area("down")
		bottom_area.position = Vector2(bottom_door_x * tile_size, (tiles_y * tile_size) + COLLISION_AREA_OFFSET )# Put it at the bottom edge
		collision_areas.add_child(bottom_area)

func _on_body_entered() -> void:
	is_player_in_the_room = true
	if not player_been_here : 
		player_been_here = true
	if not is_in_conflict and not enemies_killed:
		is_in_conflict = true
		close_all()
		activate_room()
		
func activate_room():
	for enemy in $Enemies.get_children():
		enemy.activate_enemy()
	for spawn_explosion in $Explosions.get_children():
		spawn_explosion.visible = true
		spawn_explosion.get_node("AnimationPlayer").play(&"explode")

		
func _setup_spikes() -> void:
	# Setup right spike if connection exists
	if connections["right"] != null:
		right_spike_y = rng.randi_range(3, tiles_y - 3)
		var right_spike = BLOCKING_SPIKE.instantiate()
		#right_spike.position = Vector2(
			#position.x + (tiles_x - 1) * tile_size,
			#position.y + right_spike_y * tile_size
		#)
		right_spike.position = Vector2(
			  (tiles_x - 1) * tile_size,
			(right_spike_y + 1) * tile_size
		)
		right_spike.entred.connect(_on_body_entered)
		$BlockingSpikes.add_child(right_spike)

		var right_area = _create_collision_area("right")
		right_area.position = Vector2((tiles_x * tile_size) + COLLISION_AREA_OFFSET, (right_spike_y + 1) * tile_size)
		collision_areas.add_child(right_area)

		
		
	
	# Setup left spike if connection exists
	if connections["left"] != null:
		left_spike_y = rng.randi_range(3, tiles_y - 3)
		var left_spike = BLOCKING_SPIKE.instantiate()
		#left_spike.position = Vector2(
			#position.x + tile_size,
			#position.y + left_spike_y * tile_size
		#)
		left_spike.position = Vector2(
			tile_size,
			(left_spike_y + 1) * tile_size
		)
		$BlockingSpikes.add_child(left_spike)
		
		# Add spike body detection
		left_spike.entred.connect(_on_body_entered)

		var left_area = _create_collision_area("left")
		left_area.position = Vector2(COLLISION_AREA_OFFSET * -1, (left_spike_y + 1) * tile_size)
		collision_areas.add_child(left_area)
		
func _create_collision_area(direction: String) -> Area2D:
	var area = Area2D.new()
	area.name = direction + "_detector"
	
	var collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = AREA_SIZE
	collision_shape.shape = shape
	var exiting = false
	# Set up collision properties
	area.collision_layer = 1
	area.collision_mask = 1  # Layer 5 (1 << 4)
	if room_type == GlobalConfig.Room_type.LAST and ((direction == "top" and exit_dungeon_door == "top") or (direction == "down" and exit_dungeon_door == "down")):
		exiting = true
		
	
	
	area.body_entered.connect(
		func(_body): 
			#print("Detected collision from: ", direction)  # Debug print
			direction_detected.emit(room_id,direction,exiting)
	)
	
	area.add_child(collision_shape)
	return area
	

func _on__player_body_entered():
	# Check if the body is the player
		print("Player entered the collision area")


func _calculate_room_size(area: int) -> GlobalConfig.Room_size:
	if area <= 130:
		return GlobalConfig.Room_size.SMALL
	elif area <= 260:
		return GlobalConfig.Room_size.MEDIUM
	return GlobalConfig.Room_size.LARGE

func make_room(pos: Vector2) -> void:
	position = pos
	var shape := RectangleShape2D.new()
	shape.custom_solver_bias = 0.75
	shape.extents = size

func spawn_enemies() -> void:
	while room_enemy_power > 1:
		var allowed_enemies: Array = GlobalConfig.ALLOWED_ENEMIES[room_diff]
		var random_enemy: String = allowed_enemies.pick_random()
		room_enemy_power -= GlobalConfig.ENEMY_POWER[random_enemy]
		num_of_enemies += 1
		
		var enemy_position := Vector2(
			rng.randi_range(3, tiles_x - 3) * tile_size,
			rng.randi_range(3, tiles_y - 3) * tile_size
		)
		
		
		
		var enemy: BaseEnemy = ENEMY_SCENES[random_enemy].instantiate()
		enemy.player = player
		enemy.enemy_killed.connect(_on_enemy_killed)
		#call_deferred("add_child", enemy)
		$Enemies.call_deferred("add_child", enemy)
		enemy.call_deferred("initialize",enemy_position, _level)
		var spawn_explosion: Sprite2D = SPAWN_EXPLOSION_SCENE.instantiate()
		$Explosions.call_deferred("add_child", spawn_explosion)
		spawn_explosion.call_deferred("initialize",enemy_position)
	
func spawn_potions(potion_type) -> void:
	
	if randf() > POTION_SPAWN_CHANCE:
		return
		
	var num_potions := rng.randi_range(1, MAX_POTIONS)
	var placed_potions := []
	var attempts := 0
	const MAX_ATTEMPTS := 50
	
	while placed_potions.size() < num_potions and attempts < MAX_ATTEMPTS:
		var potion_position := _get_valid_potion_position(placed_potions)
		if potion_position:
			var potion = potion_type.instantiate()
			add_child(potion)
			potion.position = potion_position
			placed_potions.append(potion_position)
		attempts += 1

func _get_valid_potion_position(placed_positions: Array) -> Vector2:
	var x := rng.randi_range(3, tiles_x - 3) * tile_size
	var y := rng.randi_range(3, tiles_y - 3) * tile_size
	var pos := Vector2(x, y)
	
	# Check distance from doors
	if connections["top"] != null:
		var top_door_pos := Vector2(top_door_x * tile_size, tile_size)
		if pos.distance_to(top_door_pos) < POTION_CLEARANCE * tile_size:
			return Vector2.ZERO
	
	if connections["down"] != null:
		var bottom_door_pos := Vector2(bottom_door_x * tile_size, (tiles_y - 1) * tile_size)
		if pos.distance_to(bottom_door_pos) < POTION_CLEARANCE * tile_size:
			return Vector2.ZERO
	
	# Check distance from spikes
	if connections["left"] != null:
		var left_spike_pos := Vector2(tile_size, (left_spike_y + 1) * tile_size)
		if pos.distance_to(left_spike_pos) < POTION_CLEARANCE * tile_size:
			return Vector2.ZERO
	
	if connections["right"] != null:
		var right_spike_pos := Vector2((tiles_x - 1) * tile_size, (right_spike_y + 1) * tile_size)
		if pos.distance_to(right_spike_pos) < POTION_CLEARANCE * tile_size:
			return Vector2.ZERO
	
	# Check distance from other potions
	for other_pos in placed_positions:
		if pos.distance_to(other_pos) < POTION_CLEARANCE * tile_size:
			return Vector2.ZERO
	
	# Check distance from decorations
	for cell_pos in tile_map.get_used_cells(0):
		var cell_world_pos := Vector2(cell_pos.x * tile_size, cell_pos.y * tile_size)
		if pos.distance_to(cell_world_pos) < POTION_CLEARANCE * tile_size:
			var cell_data := tile_map.get_cell_atlas_coords(0, cell_pos)
			if cell_data in DECORATIONS:
				return Vector2.ZERO
	
	return pos

func fill_floor_tiles() -> void:
	if not tile_map:
		return
	_setup_doors()
	_setup_spikes()
	_place_floor_tiles()
	_place_wall_tiles()
	_place_decorations()
	spawn_enemies()
	spawn_potions(HEALTH_POTION)
	spawn_potions(MANA_POTION)

func _place_floor_tiles() -> void:
	for x in range(tiles_x + 1):
		for y in range(tiles_y + 1):
			if _should_place_floor_tile(x, y):
				var tile_coords := _get_random_floor_tile()
				tile_map.set_cell(0, Vector2i(x, y), 1, tile_coords)

func _get_random_floor_tile() -> Vector2i:
	if randf() >= VARIATION_CHANCE:
		return DEFAULT_FLOOR_TILE
	return FLOOR_TILE_VARIATIONS.pick_random()

func _place_wall_tiles() -> void:
	# Top wall and second row
	for x in range(tiles_x):
		# Top wall - skip if there's a door
		if (connections["top"] == null and exit_dungeon_door!="top") or (x != top_door_x and x != top_door_x - 1):
			var wall_type := _get_wall_type(x)
			tile_map.set_cell(0, Vector2i(x, 0), 1, wall_type)
			
			# Second row wall
			var wall_coord := _get_wall_pattern_tile(x)
			tile_map.set_cell(0, Vector2i(x, 1), 1, wall_coord)
	
	# Bottom walls and second-to-last row
	for x in range(tiles_x):
		# Bottom wall - skip if there's a door
		if (connections["down"] == null and exit_dungeon_door != "down") or (x != bottom_door_x and x != bottom_door_x - 1) :
			var wall_coord := _get_wall_pattern_tile(x)
			tile_map.set_cell(0, Vector2i(x, tiles_y - 1), 1, wall_coord)
			
			# Second-to-last row wall
			var wall_type := _get_wall_type(x)
			tile_map.set_cell(0, Vector2i(x, tiles_y - 2), 1, wall_type)
	
	# Side walls
	for y in range(1, tiles_y - 1):
		# Left wall - skip if there's a spike
		if connections["left"] == null or (y != left_spike_y and y != left_spike_y + 1):
			tile_map.set_cell(1, Vector2i(0, y), 1, Vector2i(3, 5))
		
		# Right wall - skip if there's a spike
		if connections["right"] == null or (y != right_spike_y and y != right_spike_y + 1):
			tile_map.set_cell(1, Vector2i(tiles_x - 1, y), 1, Vector2i(4, 5))

func _find_pattern_position(x: int) -> String:
	@warning_ignore("integer_division")
	var pattern_start := int(x / 3) * 3
	var position_in_pattern := x - pattern_start
	
	match position_in_pattern:
		0: return "left"
		1: return "middle"
		2: return "right"
	return "middle"

func _get_wall_pattern_tile(x: int) -> Vector2i:
	if randf() < VARIATION_CHANCE:
		return WALL_TILE_VARIATIONS.pick_random()
	return WALL_PATTERN[_find_pattern_position(x)]

func _get_wall_type(x: int) -> Vector2i:
	if x == 0:
		return Vector2i(1, 6)
	elif x == tiles_x - 1:
		return Vector2i(5, 6)
	return Vector2i(2, 6)

func _should_place_floor_tile(x: int, y: int) -> bool:
	var is_top_door := connections["top"] != null and (x == top_door_x or x == top_door_x - 1) and y == 1
	# var is_bottom_door := connections["down"] != null and (x == bottom_door_x or x == bottom_door_x - 1) and y == tiles_y - 1
	var is_top_row := y == 0
	return not (is_top_door  or is_top_row)

func _place_decorations() -> void:
	var max_decorations: int = MAX_DECORATIONS[room_size]
	var num_decorations := rng.randi_range(0, max_decorations)
	
	var placed_decorations := []
	var attempts := 0
	const MAX_ATTEMPTS := 100
	
	while placed_decorations.size() < num_decorations and attempts < MAX_ATTEMPTS:
		var pos = _get_random_valid_decoration_position(placed_decorations)
		if pos:
			var decoration = DECORATIONS.pick_random()
			tile_map.set_cell(0, pos, 1, decoration)
			placed_decorations.append(pos)
		attempts += 1

func _get_random_valid_decoration_position(placed_decorations: Array):
	var x := rng.randi_range(WALL_CLEARANCE, tiles_x - WALL_CLEARANCE - 1)
	var y := rng.randi_range(WALL_CLEARANCE, tiles_y - WALL_CLEARANCE - 1)
	var pos := Vector2i(x, y)
	
	if _is_valid_decoration_position(pos, placed_decorations):
		return pos

func _is_valid_decoration_position(pos: Vector2i, placed_decorations: Array) -> bool:
	for decoration in placed_decorations:
		if Vector2(decoration).distance_to(Vector2(pos)) < WALL_CLEARANCE:
			return false
	
	# Check door clearance for top door
	if connections["top"] != null:
		var top_door_pos := Vector2i(top_door_x, 1)
		if Vector2(pos).distance_to(Vector2(top_door_pos)) < DOOR_CLEARANCE:
			return false
	
	# Check door clearance for bottom door
	if connections["down"] != null:
		var bottom_door_pos := Vector2i(bottom_door_x, tiles_y - 1)
		if Vector2(pos).distance_to(Vector2(bottom_door_pos)) < DOOR_CLEARANCE:
			return false
	
	return true

func open_all() -> void:
	for door in $Doors.get_children():
		door.open()
	for spike in $BlockingSpikes.get_children():
		spike.open()

func close_all() -> void:
	for door in $Doors.get_children():
		door.close()
	for spike in $BlockingSpikes.get_children():
		spike.close()

func _on_enemy_killed() -> void:
	num_of_enemies -= 1
	if num_of_enemies == 0:
		enemies_killed = true
		open_all()
		is_in_conflict = false
