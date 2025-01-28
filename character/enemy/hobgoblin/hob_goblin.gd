extends BaseEnemy

class_name Hobgoblin

@onready var attack_timer = $AttackTimer
var damage : int

@export var MAX_PLAYER_DISTANCE: float = 200.0
@export var MIN_PLAYER_DISTANCE: float = 100.0

const LANCE := preload("res://character/enemy/hobgoblin/util/lance/lance.tscn")

var can_shoot : bool = true


func _ready():
	super._ready()
	health_component.max_health = 100
	movement_component.speed = 100.0
	combat_component.damage = 20
	combat_component.knockback_power = 700
	currency_component.currency = 10
	
enum State {
	CHASE,    
	ATTACK,   
	RETREAT   
}

var current_state: State = State.CHASE
	
func _physics_process(delta: float) -> void:
	if is_hurt or combat_component.is_attacking or is_dead:
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
			
	#if not navigation_component.is_navigation_finished():
		#var direction = to_local(navigation_component.get_next_position()).normalized()
		#movement_component.move(direction)
		#animation_component.update_direction(movement_component.velocity)
		#animation_component.play("walk")
	#elif navigation_component.is_navigation_finished() and not player.is_dead:
		#animation_component.animation_player.stop()
		#combat_component.start_attack()
		#await animation_component.animation_player.animation_finished
		#combat_component.end_attack()
	
	
func update_state(distance: float) -> void:
	if distance > MAX_PLAYER_DISTANCE:
		current_state = State.CHASE
	elif distance < MIN_PLAYER_DISTANCE:
		current_state = State.RETREAT
	else:
		current_state = State.ATTACK
		
func chase_player() -> void:
	navigation_component.target = player
	#nav_agent.target_position = player.global_position
	
	if navigation_component.is_navigation_finished():
		return
		
	var next_path_position: Vector2 = navigation_component.get_next_position()
	var direction: Vector2 = global_position.direction_to(next_path_position)
	movement_component.move(direction)
	animation_component.update_direction(movement_component.velocity)
	animation_component.play("walk")

func retreat_from_player() -> void:
	var direction: Vector2 = global_position.direction_to(player.global_position)
	movement_component.move(direction * -1)
	animation_component.update_direction(movement_component.velocity)
	animation_component.play("walk")

func attack_player() -> void:
	animation_component.animation_player.stop()
	if can_shoot:
		can_shoot = false
		attack_timer.start()
		combat_component.is_attacking = true
		var v : Vector2
		if player.global_position < global_position:
			v = Vector2(0,-1)
		else:
			v = Vector2(0,1)
		animation_component.update_direction(v)
		_on_attack_started()
		await animation_component.animation_player.animation_finished
		combat_component.is_attacking = false
		var lance : Lance = LANCE.instantiate()
		lance.global_position = global_position
		lance.global_position.y = lance.global_position.y - 5
		lance.global_rotation = ((player.global_position + Vector2(1,14) )- global_position).angle()
		get_tree().root.add_child(lance)
		lance.shot(combat_component.damage)
		


func _on_hurt_box_area_entered(area):
	take_damage(area.get_parent().damage,((position - player.position).normalized()),combat_component.knockback_power)


func _on_attack_timer_timeout():
	can_shoot = true
