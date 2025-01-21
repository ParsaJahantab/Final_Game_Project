extends CharacterBody2D

@onready var movement_component: CharacterMovementComponent = $CharacterMovementComponent
@onready var health_component: CharacterHealthComponent= $CharacterHealthComponent
@onready var animation_component: PlayerAnimationComponent = $PlayerAnimationComponent
@export var knockback_power: float = 500.0
var is_dead = false
signal health_changed
signal attack_pressed
var weapon := "Sword"
var is_attacking: bool
var is_rolling : bool
var base_damage = 100
var damage = 100
var heavy_attack_multiplier :=1.5
var direction
func _ready() -> void:
	# Connect signals
	await get_tree().process_frame
	health_component.died.connect(_on_died)
	health_component.health_changed.connect(_health_changed)
	movement_component.initialize(self)
	health_component.initialize(self)
	health_component.max_health = 100
	health_component.current_health = 100
	_health_changed()
	movement_component.speed = 150.0
	$hitBox/CollisionShape2D.disabled = true
	
func _health_changed():
	health_changed.emit()

func _physics_process(_delta: float) -> void:
	
	if is_dead:
		return
	
	handleInput()
	
func handleInput():
	if not Input.is_anything_pressed() and not is_attacking and not is_rolling:
		$Run.visible = false
		$SwordLightAttack.visible = false
		$SwordHeavyAttack.visible = false
		$Idle.visible = true
		$Death.visible = false
		$Roll.visible = false
		animation_component.play_idle()
		return
	direction = Input.get_vector("left", "right","up","down")
	if not is_attacking and not is_rolling:
		movement_component.move(direction)
	
	if direction.length() !=0 and not is_attacking and not is_rolling:
		animation_component.update_direction(movement_component.velocity)
		$Run.visible = true
		$Idle.visible = false
		$SwordLightAttack.visible = false
		$SwordHeavyAttack.visible = false
		$Death.visible = false
		$Roll.visible = false
		animation_component.play_run()
	
	if Input.is_action_just_pressed("roll") and not is_attacking:
		_on_roll_pressed()
	
	if (Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("heavy_attack")) and not is_rolling:
		$Run.visible = false
		$Idle.visible = false
		$SwordLightAttack.visible = true
		$Death.visible = false
		$Roll.visible = false
		if Input.is_action_just_pressed("attack"):
			$SwordLightAttack.visible = true
			$SwordHeavyAttack.visible = false
			_on_attack_pressed("Light")
		else:
			$SwordLightAttack.visible = false
			$SwordHeavyAttack.visible = true
			damage = int(damage * heavy_attack_multiplier)
			_on_attack_pressed("Heavy")
		
func _on_roll_pressed() -> void:
	if health_component.is_dead:
		return
	if not is_rolling:
		is_rolling = true
		animation_component.play_roll()
		movement_component.roll(direction)
		await animation_component.animation_player.animation_finished
		is_rolling = false

func _on_attack_pressed(attack_type:String) -> void:
	if health_component.is_dead:
		return
	if not is_attacking :
		is_attacking = true
		animation_component.play_attack(weapon,attack_type)
		await animation_component.animation_player.animation_finished
		is_attacking = false
		damage = base_damage

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
		$SwordLightAttack.visible = false
		$SwordHeavyAttack.visible = false
		if animation_component.current_direction == "Right":
			$Death.flip_h = false
		else:
			$Death.flip_h = true
		$Death.visible = true
		animation_component.play_death()

func _on_died() -> void:
	is_dead = true
	# Additional death handling if needed
	pass
