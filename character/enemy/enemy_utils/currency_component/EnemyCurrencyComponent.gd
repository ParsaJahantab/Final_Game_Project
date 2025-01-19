class_name EnemyCurrencyComponent
extends CharacterComponent

var currency := 0
var _base_currency : int

func _ready() -> void:
	pass

func initialize(parent: CharacterBody2D) -> void:
	super.initialize(parent)
	
func set_base_currency(base_currency):
	_base_currency = base_currency
	
func change_stat(multiplier:float,stat:int,type:String):
	currency = currency + _base_currency
	currency = (currency * multiplier) + stat
	if type == "enemy":
		currency = randi_range(0.8 * currency, 1.2 * currency)
	

