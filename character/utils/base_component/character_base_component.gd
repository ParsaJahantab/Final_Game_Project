extends Node2D
class_name CharacterComponent

@export var entity: CharacterBody2D

func _ready():
	pass 
	
func initialize(parent: CharacterBody2D) -> void:
	entity = parent

func _process(delta):
	pass
