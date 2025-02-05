extends Node2D
class_name PlayerInputComponent

signal attack_pressed
var can_process = false

func _ready():
	await get_tree().process_frame
	await get_tree().process_frame
	can_process = true
	
	

func get_movement_direction() -> Vector2:
	return Input.get_vector("left", "right", "up", "down")

func _process(_delta: float) -> void:
	if can_process:
		if Input.is_action_just_pressed("attack"):
			attack_pressed.emit()
