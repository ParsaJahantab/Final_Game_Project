extends Node2D
class_name CharacterComponent

@export var entity: CharacterBody2D

func _ready():
	pass 
	
func initialize(parent: CharacterBody2D) -> void:
	entity = parent
	
func change_stat(multiplier:float,stat:int,type:String):
	pass

func _process(delta):
	pass
