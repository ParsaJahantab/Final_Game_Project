class_name CharacterAnimationComponent
extends CharacterComponent

@onready var animation_player: AnimationPlayer
var current_direction: String = "Right"

func _ready() -> void:
	animation_player = $AnimationPlayer

func play(animation: String) -> void:
	animation_player.play(animation + current_direction)

func update_direction(velocity: Vector2) -> void:
	if velocity.x < 0:
		current_direction = "Left"
	elif velocity.x > 0:
		current_direction = "Right"
