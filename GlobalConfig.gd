extends Node

enum Room_size {SMALL ,MEDIUM , LARGE}
enum Room_type {FIRST ,NORMAL , LAST , BOSS}
enum Room_diff {EASY ,CHALLENGEING, HARDCORE}

const ENEMY_POWER: Dictionary = {
	"ORC" : 6,
	"GOBLIN" : 6,
	"HOBGOBLINS" : 4
	
}

const ALLOWED_ENEMIES: Dictionary = {
	Room_diff.EASY : ["GOBLIN"],
	Room_diff.CHALLENGEING : ["GOBLIN" , "HOBGOBLINS"],
	Room_diff.HARDCORE : ["GOBLIN" , "HOBGOBLINS" , "ORC"]
	
} 

