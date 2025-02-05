extends BaseEnemy
class_name Hobgoblin

@onready var attack_timer = $AttackTimer
@export var MAX_PLAYER_DISTANCE: float = 200.0
@export var MIN_PLAYER_DISTANCE: float = 100.0
const LANCE := preload("res://character/enemy/hobgoblin/util/lance/lance.tscn")

enum State {
	CHASE,	
	ATTACK,   
	RETREAT   
}

var current_state: State = State.CHASE
var can_shoot: bool = true

func _ready():
	super._ready()
	health_component.max_health = GlobalConfig.HOBGOBLIN_ATTRIBUTES["max_health"]
	movement_component.speed = GlobalConfig.HOBGOBLIN_ATTRIBUTES["speed"]
	combat_component.damage = GlobalConfig.HOBGOBLIN_ATTRIBUTES["damage"]
	combat_component.knockback_power = GlobalConfig.HOBGOBLIN_ATTRIBUTES["knockback_power"]
	currency_component.currency = GlobalConfig.HOBGOBLIN_ATTRIBUTES["currency"]

func _physics_process(delta: float) -> void:
	if is_hurt or combat_component.is_attacking or is_dead:
		combat_component.is_attacking = false
		return
		
	var distance_to_player = global_position.distance_to(player.global_position)
	update_state(distance_to_player)
	match current_state:
		State.CHASE:
			chase_player()
		State.ATTACK:
			attack_player()
		State.RETREAT:
			retreat_from_player()
			
	navigation_component.make_path()

func update_state(distance: float) -> void:
	var new_state = current_state
	
	if distance > MAX_PLAYER_DISTANCE:
		new_state = State.CHASE
	elif distance < MIN_PLAYER_DISTANCE:
		new_state = State.RETREAT
	else:
		new_state = State.ATTACK
		
	if new_state != current_state:
		current_state = new_state

func chase_player() -> void:
	if not is_instance_valid(player):
		return
	combat_component.is_attacking = false
	navigation_component.target = player
	
	if not navigation_component.is_navigation_finished():
		var next_path_position: Vector2 = navigation_component.get_next_position()
		var direction: Vector2 = global_position.direction_to(next_path_position)
		movement_component.move(direction)
		animation_component.update_direction(movement_component.velocity)
		animation_component.play("walk")

func retreat_from_player() -> void:
	if not is_instance_valid(player):
		return
	
	combat_component.is_attacking = false
	var direction: Vector2 = global_position.direction_to(player.global_position)
	movement_component.move(-direction)  
	animation_component.update_direction(movement_component.velocity)
	animation_component.play("walk")

func attack_player() -> void:
	if not is_instance_valid(player) or not can_shoot:
		return
		
	animation_component.animation_player.stop()
	can_shoot = false
	attack_timer.start()
	combat_component.is_attacking = true
	
	var attack_direction = Vector2.UP if player.global_position.y < global_position.y else Vector2.DOWN
	animation_component.update_direction(attack_direction)
	
	_on_attack_started()
	await animation_component.animation_player.animation_finished
	combat_component.is_attacking = false
	
	spawn_lance()

func spawn_lance() -> void:
	if not is_instance_valid(player):
		return
		
	var lance: Lance = LANCE.instantiate()
	lance.global_position = global_position
	lance.global_position.y -= 5
	lance.global_rotation = (player.global_position + Vector2(1, 14) - global_position).angle()
	get_tree().root.add_child(lance)
	lance.shot(combat_component.damage)

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if not is_instance_valid(player):
		return
		
	take_damage(
		area.get_parent().damage,
		(position - player.position).normalized(),
		combat_component.knockback_power
	)

func _on_attack_timer_timeout() -> void:
	can_shoot = true
