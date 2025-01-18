class_name CharacterMovementComponent
extends CharacterComponent

@export var speed: float = 60.0

var velocity: Vector2

func move(direction: Vector2) -> void:
	velocity = direction * speed
	if entity:
		entity.velocity = velocity
		entity.move_and_slide()

func apply_knockback(source_position: Vector2,absorbed_knockback : float) -> void:
	velocity = ((entity.position - source_position).normalized()) * absorbed_knockback
	if entity:
		entity.velocity = velocity
		entity.move_and_slide()
