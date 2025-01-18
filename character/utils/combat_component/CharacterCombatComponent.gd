class_name CharacterCombatComponent
extends CharacterComponent

signal attack_started
signal attack_finished

@export var damage: int = 30
@export var knockback_power: float = 700.0
@onready var hitbox_collision: CollisionShape2D

var is_attacking: bool = false

func _ready() -> void:
	hitbox_collision = $HitBox/HitCollision
	hitbox_collision.disabled = true

func start_attack() -> void:
	if not is_attacking:
		is_attacking = true
		attack_started.emit()

func end_attack() -> void:
	is_attacking = false
	hitbox_collision.disabled = true
	attack_finished.emit()
