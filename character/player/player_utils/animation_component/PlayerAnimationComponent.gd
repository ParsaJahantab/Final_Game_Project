@tool
extends Node
class_name PlayerAnimationComponent

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_direction: String = "Right"
var is_attacking: bool = false

func update_direction(velocity: Vector2) -> void:
	if velocity.length() == 0:
		animation_player.stop()
		return
		
	if velocity.x < 0:
		current_direction = "Left"
	elif velocity.x > 0:
		current_direction = "Right"

func play_run():
	if not is_attacking:
		animation_player.play("run" + current_direction)
		
func play_idle() -> void :
	animation_player.play("idle" + current_direction)

func play_attack(weapon : String) -> void:
	if not is_attacking :
		animation_player.stop()
		is_attacking = true
		animation_player.play(weapon+ "Attack" + current_direction)
		await animation_player.animation_finished
		is_attacking = false

#func play_hurt() -> void:
	#effects_player.play("hurtEffect")

func play_death() -> void:
	animation_player.play("death" + current_direction)
