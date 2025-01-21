class_name BaseEnemy
extends CharacterBody2D

@onready var health_component: CharacterHealthComponent = $CharacterHealthComponent
@onready var movement_component: CharacterMovementComponent = $CharacterMovementComponent
@onready var navigation_component: EnemyNavigationComponent = $EnemyNavigationComponent
@onready var combat_component: CharacterCombatComponent = $CharacterCombatComponent
@onready var animation_component: CharacterAnimationComponent = $CharacterAnimationComponent
@onready var currency_component: EnemyCurrencyComponent = $EnemyCurrencyComponent
@export var player: Node2D

var is_hurt: bool = false
var is_dead : bool = false
signal health_changed
signal enemy_killed

func _ready() -> void:
	for component in [$CharacterHealthComponent, $CharacterMovementComponent, $EnemyNavigationComponent, $CharacterCombatComponent, $CharacterAnimationComponent, $EnemyCurrencyComponent]:
		component.initialize(self)
	
	navigation_component.target = player
	health_component.died.connect(_on_died)
	health_component.health_changed.connect(_on_health_change)
	combat_component.attack_started.connect(_on_attack_started)
	#combat_component.attack_finished.connect(_on_attack_finished)

func initialize(p_position: Vector2,level):
	position = p_position
	
	var multipler = {
	1: 1,
	2: 1.2,
	3: 1.4,
	4: 1.6,
	5: 2.0,
	}

	for component in [$CharacterHealthComponent, $CharacterMovementComponent, $EnemyNavigationComponent, $CharacterCombatComponent, $CharacterAnimationComponent, $EnemyCurrencyComponent]:
		component.change_stat(multipler[level],0,"enemy")
	disable_enemy()

func _physics_process(delta: float) -> void:
	if is_hurt or combat_component.is_attacking or is_dead:
		return
	navigation_component.make_path()
	
	if not navigation_component.is_navigation_finished():
		var direction = to_local(navigation_component.get_next_position()).normalized()
		movement_component.move(direction)
		animation_component.update_direction(movement_component.velocity)
		animation_component.play("walk")
	elif navigation_component.is_navigation_finished() and not player.is_dead:
		animation_component.animation_player.stop()
		combat_component.start_attack()
		await animation_component.animation_player.animation_finished
		combat_component.end_attack()
		
func disable_enemy():
	set_physics_process(false)
	set_process(false)
	visible = false
	
func activate_enemy():
	set_physics_process(true)
	set_process(true)
	visible = true

func take_damage(amount: int, source_position: Vector2, absorbed_knockback : float) -> void:
	is_hurt = true
	combat_component.is_attacking = false
	if not combat_component.hitbox_collision.disabled :
		#combat_component.hitbox_collision.set_disabled(true)
		call_deferred("combat_component.hitbox_collision.set_disabled",true)
		
	health_component.take_damage(amount)
	movement_component.apply_knockback(source_position,absorbed_knockback)
	animation_component.play("hurt")
	await animation_component.animation_player.animation_finished
	is_hurt = false

func _on_died() -> void:
	call_deferred("_handle_death")
func _handle_death() -> void:
	is_dead = true
	animation_component.animation_player.stop()
	animation_component.play("hurt")
	await animation_component.animation_player.animation_finished
	animation_component.play("dead")
	await animation_component.animation_player.animation_finished
	enemy_killed.emit()
	GameState.temp_currency_change(currency_component.currency)
	queue_free()

func _on_attack_started() -> void:
	animation_component.play("attack")

func _on_timer_timeout():
	navigation_component.make_path()
	
func _on_health_change() -> void:
	health_changed.emit()


