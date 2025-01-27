extends Node

enum Room_size {SMALL ,MEDIUM , LARGE}
enum Room_type {FIRST ,NORMAL , LAST , BOSS}
enum Room_diff {EASY ,CHALLENGEING, HARDCORE}

const ENEMY_POWER: Dictionary = {
	"ORC" : 6,
	"GOBLIN" : 6,
	"HOBGOBLINS" : 4
	
}

const LEVEL_TO_DIFF : Dictionary = {
	1 : Room_diff.EASY,
	2 : Room_diff.CHALLENGEING,
	3 : Room_diff.CHALLENGEING,
	4 : Room_diff.HARDCORE,
	5 : Room_diff.HARDCORE
}

const ALLOWED_ENEMIES: Dictionary = {
	Room_diff.EASY : ["GOBLIN"],
	Room_diff.CHALLENGEING : ["GOBLIN" , "HOBGOBLINS"],
	Room_diff.HARDCORE : ["GOBLIN" , "HOBGOBLINS" , "ORC"]
	
} 

const BASE_PLAYER_ATTRIBUTES : Dictionary = {
	
	"HEALTH" : 100,
	"MANA" : 100,
	"DAMAGE" : 50,
	"SPEED" : 130,
	
}

