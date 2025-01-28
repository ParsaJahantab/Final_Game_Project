extends Node

enum Room_size {SMALL ,MEDIUM , LARGE}
enum Room_type {FIRST ,NORMAL , LAST , BOSS}
enum Room_diff {EASY ,CHALLENGEING, HARDCORE}

const ENEMY_POWER: Dictionary = {
	"ORC" : 6,
	"GOBLIN" : 6,
	"HOBGOBLIN" : 4
	
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
	Room_diff.CHALLENGEING : ["GOBLIN" , "HOBGOBLIN"],
	Room_diff.HARDCORE : ["GOBLIN" , "HOBGOBLIN" , "ORC"]
	
} 


const GOBLIN_ATTRIBUTES : Dictionary = {
	"max_health" : 60,
	"speed" : 80.0,
	"damage" : 15,
	"knockback_power" : 700,
	"currency" : 30
}
const ORC_ATTRIBUTES : Dictionary = {
	"max_health" : 240,
	"speed" : 40.0,
	"damage" : 30,
	"knockback_power" : 700,
	"currency" : 90
}
const HOBGOBLIN_ATTRIBUTES : Dictionary = {
	"max_health" : 80,
	"speed" : 30.0,
	"damage" : 10,
	"knockback_power" : 700,
	"currency" : 60
}

const BASE_PLAYER_ATTRIBUTES : Dictionary = {
	
	"HEALTH" : 200,
	"MANA" : 100,
	"DAMAGE" : 80,
	"SPEED" : 150,
	
}

