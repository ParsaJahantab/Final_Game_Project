extends CharacterComponent
class_name PlayerManaComponent


signal mana_changed

@export var max_mana: int = 50
var current_mana: int

func _ready() -> void:
	current_mana = max_mana
	mana_changed.emit()

func use_spell(amount: int) -> void:
	if amount <= current_mana:
		current_mana = current_mana - amount
		mana_changed.emit()
		
func add_mana(amount: int) -> void:
	current_mana = min(max_mana,current_mana + amount)
	mana_changed.emit()
		
func change_stat(multiplier:float,stat:int,type:String):
	max_mana = (max_mana * multiplier) + stat
	current_mana = max_mana
	mana_changed.emit()
	
