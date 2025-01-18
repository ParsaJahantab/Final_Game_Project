class_name CharacterHealthComponent
extends CharacterComponent

signal health_changed
signal died

@export var max_health: int = 60
@export var health_multiplier: float = 1.0
var current_health: int

func _ready() -> void:
	current_health = int(max_health * health_multiplier)
	health_changed.emit()

func take_damage(amount: int) -> void:
	current_health = current_health - amount
	health_changed.emit()
	
	if current_health <= 0:
		died.emit()
