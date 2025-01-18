extends Node2D
@onready var tile_map: TileMap = $DungeonTileMap
@onready var pos1 = Vector2i(10,16)
@onready var pos2 = Vector2i(16,4)
# Called when the node enters the scene tree for the first time.
func _ready():
	#corridor_horizontal(true,5,Vector2i(10,13))
	#horizontal_to_vertical_turn(true,Vector2i(14,13))
	#corridor_vertical(5,Vector2i(13,11),true,false)
	#vertical_to_horizontal_turn(true,Vector2i(6,7))
	#corridor_horizontal(true,5,Vector2i(8,8))
	#corridor_vertical((pos1.y - pos2.y)/2,pos1,false,false) 
	#vertical_to_horizontal_turn(true,Vector2i(pos1.x,pos2.x - ((pos1.y - pos2.y)/2)))
	#
	pass
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
func corridor_horizontal(is_direction_right:bool , distance : int , pos : Vector2i):
	var direction : int
	if is_direction_right:
		direction = 1
	else :
		direction = -1
	for i in range(distance):
		tile_map.set_cell(1,Vector2i(pos.x + (i * direction) ,pos.y-3),1,Vector2i(2,7))
		tile_map.set_cell(0,Vector2i(pos.x + (i * direction),pos.y-2),1,Vector2i(7,4))
		tile_map.set_cell(0,Vector2i(pos.x + (i * direction),pos.y-1),1,Vector2i(3,1))
		tile_map.set_cell(0,Vector2i(pos.x + (i * direction),pos.y),1,Vector2i(3,1))
		tile_map.set_cell(1,Vector2i(pos.x + (i * direction),pos.y),1,Vector2i(2,7))
		tile_map.set_cell(0,Vector2i(pos.x + (i * direction),pos.y+1),1,Vector2i(7,4))
		
func corridor_vertical(distance : int , pos : Vector2i, is_continues : bool , is_right : bool):
	for i in range(distance):
		var j = i * -1
		if i!=0  or not is_continues or is_right:
			tile_map.set_cell(1,Vector2i(pos.x -1 ,pos.y + j),1,Vector2i(4,5))
		tile_map.set_cell(0,Vector2i(pos.x,pos.y + j),1,Vector2i(3,1))
		tile_map.set_cell(0,Vector2i(pos.x + 1,pos.y + j),1,Vector2i(3,1))
		if i!=0 or not is_continues or not is_right:
			tile_map.set_cell(1,Vector2i(pos.x + 2,pos.y + j),1,Vector2i(3,5))
		
func vertical_to_horizontal_turn(is_direction_right:bool , pos : Vector2i):
	var to_add : int
	var to_earse : int
	var celling
	if is_direction_right:
		to_earse = 2
		to_add = -1
		celling = 4
	else :
		to_earse = -1
		to_add = 2
		celling = 3
		
	tile_map.erase_cell(1,Vector2i(pos.x + to_earse,pos.y))
	tile_map.erase_cell(1,Vector2i(pos.x + to_earse,pos.y + 1))
	tile_map.set_cell(0,Vector2i(pos.x,pos.y - 1),1,Vector2i(7,4))
	tile_map.set_cell(0,Vector2i(pos.x + 1,pos.y - 1),1,Vector2i(7,4))
	tile_map.set_cell(1,Vector2i(pos.x + to_add,pos.y - 1),1,Vector2i(celling,5))
	tile_map.set_cell(1,Vector2i(pos.x + to_add,pos.y - 2),1,Vector2i(celling,4))
	tile_map.set_cell(1,Vector2i(pos.x,pos.y - 2),1,Vector2i(2,7))
	tile_map.set_cell(1,Vector2i(pos.x + 1,pos.y - 2),1,Vector2i(2,7))
	
func horizontal_to_vertical_turn(is_direction_right:bool , pos : Vector2i):
	var to_earse : int
	var celling
	if is_direction_right:
		to_earse = -1
		celling = 3
		
	else :
		to_earse = 1
		celling = 4
		
	tile_map.erase_cell(1,Vector2i(pos.x,pos.y - 3))
	tile_map.erase_cell(1,Vector2i(pos.x + to_earse,pos.y - 3))
	tile_map.erase_cell(0,Vector2i(pos.x,pos.y - 2))
	tile_map.erase_cell(0,Vector2i(pos.x + to_earse,pos.y - 2))
	tile_map.set_cell(1,Vector2i(pos.x - to_earse,pos.y - 1),1,Vector2i(celling,5))
	tile_map.set_cell(1,Vector2i(pos.x - to_earse,pos.y),1,Vector2i(celling,5))

