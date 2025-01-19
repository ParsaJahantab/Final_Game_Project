class_name CharacterHealthComponent
extends CharacterComponent

signal health_changed
signal died

@export var max_health: int = 60
var current_health: int
var is_dead: bool

func _ready() -> void:
	current_health = max_health
	health_changed.emit()
	is_dead = false


func take_damage(amount: int) -> void:
	current_health = current_health - amount
	health_changed.emit()
	
	if current_health <= 0:
		is_dead = true
		died.emit()
		
func change_stat(multiplier:float,stat:int,type:String):
	print(max_health)
	current_health = (max_health * multiplier) + stat
	if type == "enemy":
		current_health = randi_range(0.8 * current_health, 1.2 * current_health)
	
	print(current_health)
	health_changed.emit()
	
	
