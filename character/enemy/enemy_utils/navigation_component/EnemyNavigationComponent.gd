class_name EnemyNavigationComponent
extends CharacterComponent

@onready var nav_agent: NavigationAgent2D
@export var target: Node2D

func _ready() -> void:
	nav_agent = $NavigationAgent2D

func initialize(parent: CharacterBody2D) -> void:
	super.initialize(parent)
	make_path()

func make_path() -> void:
	if target and is_instance_valid(target) and not target.is_dead:
		nav_agent.target_position = target.global_position

func get_next_position() -> Vector2:
	return nav_agent.get_next_path_position()

func is_navigation_finished() -> bool:
	return nav_agent.is_navigation_finished()
