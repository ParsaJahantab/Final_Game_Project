@tool
extends Node2D
class_name InputComponent

signal attack_pressed

func get_movement_direction() -> Vector2:
	return Input.get_vector("left", "right", "up", "down")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		attack_pressed.emit()
