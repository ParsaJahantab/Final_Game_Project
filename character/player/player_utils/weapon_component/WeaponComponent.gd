@tool
extends Node2D
class_name WeaponComponent

@export var damage: int = 50

@onready var weapon_sprite: Node2D = $Weapon
@onready var collision_shape: CollisionShape2D = $Weapon/sword/Sword/CollisionShape2D

var is_attacking: bool = false

func _ready() -> void:
	weapon_sprite.visible = false
	collision_shape.disabled = true

func start_attack() -> void:
	if not is_attacking:
		weapon_sprite.visible = true
		is_attacking = true
		collision_shape.disabled = false

func end_attack() -> void:
	is_attacking = false
	collision_shape.disabled = true
	weapon_sprite.visible = false
