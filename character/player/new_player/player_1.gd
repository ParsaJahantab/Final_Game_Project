extends CharacterBody2D

@onready var movement_component: CharacterMovementComponent = $CharacterMovementComponent
@onready var weapon_component: WeaponComponent = $WeaponComponent
@onready var health_component: CharacterHealthComponent= $CharacterHealthComponent
@onready var animation_component: PlayerAnimationComponent = $PlayerAnimationComponent
@export var knockback_power: float = 500.0
var is_dead = false
signal health_changed
signal attack_pressed
var weapon := "Sword"
var is_attacking: bool
var damage = 50
func _ready() -> void:
	# Connect signals
	await get_tree().process_frame
	health_component.died.connect(_on_died)
	health_component.health_changed.connect(_health_changed)
	movement_component.initialize(self)
	health_component.initialize(self)
	health_component.max_health = 100
	health_component.current_health = 100
	movement_component.speed = 150.0
	$hitBox/CollisionShape2D.disabled = true
	
func _health_changed():
	health_changed.emit()

func _physics_process(_delta: float) -> void:
	
	if is_dead:
		return
	
	handleInput()
	
func handleInput():
	if not Input.is_anything_pressed() and not is_attacking:
		$Run.visible = false
		$SwordAttack.visible = false
		$Idle.visible = true
		$Death.visible = false
		
		animation_component.play_idle()
		return
	var direction = Input.get_vector("left", "right","up","down")
	if not is_attacking:
		movement_component.move(direction)
	
	if direction.length() !=0 and not is_attacking:
		animation_component.update_direction(movement_component.velocity)
		$Run.visible = true
		$Idle.visible = false
		$SwordAttack.visible = false
		$Death.visible = false
		animation_component.play_run()
	
	if Input.is_action_just_pressed("attack"):
		$Run.visible = false
		$Idle.visible = false
		$SwordAttack.visible = true
		$Death.visible = false
		_on_attack_pressed()

func _on_attack_pressed() -> void:
	if health_component.is_dead or weapon_component.is_attacking:
		return
	if not is_attacking :
		is_attacking = true
		animation_component.play_attack(weapon)
		await animation_component.animation_player.animation_finished
		print("signal: ",animation_component.animation_player.animation_finished)
		is_attacking = false

func _on_hurt_box_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	knockback(enemy.position, enemy.damage)

func knockback(enemy_pos: Vector2, damage_received: int) -> void:
	if health_component.is_dead:
		return
		
	#animation_component.play_hurt()
	movement_component.apply_knockback(enemy_pos,knockback_power)
	health_component.take_damage(damage_received)
	
	if health_component.is_dead:
		movement_component.velocity *= 2
		$Run.visible = false
		$Idle.visible = false
		$SwordAttack.visible = false
		if animation_component.current_direction == "Right":
			$Death.flip_h = false
		else:
			$Death.flip_h = true
		$Death.visible = true
		await animation_component.animation_player.animation_finished
		animation_component.play_death()

func _on_died() -> void:
	is_dead = true
	# Additional death handling if needed
	pass
