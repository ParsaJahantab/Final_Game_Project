class_name CharacterMovementComponent
extends CharacterComponent

@export var speed: float = 60.0
@export var roll_multiplier = 1.8
var roll_duration = 0.6 
var roll_timer = 0.0
var is_rolling = false
var _direction

var velocity: Vector2

func _physics_process(_delta: float) -> void:
	
	if is_rolling and entity:
		roll_timer += _delta
		
		var roll_progress = roll_timer / roll_duration
		
		if roll_progress >= 1.0:
			is_rolling = false
			roll_timer = 0.0
		else:
			var speed_factor = cos(roll_progress * PI * 0.5)  
			entity.velocity = _direction * speed * roll_multiplier * speed_factor
			entity.move_and_slide()

func move(direction: Vector2) -> void:
	_direction = direction
	velocity = direction * speed
	if entity:
		entity.velocity = velocity
		entity.move_and_slide()
		
func roll(direction: Vector2) -> void:
	if not is_rolling:  # Prevent rolling while already rolling
		is_rolling = true
		roll_timer = 0.0

func apply_knockback(source_position: Vector2,absorbed_knockback : float) -> void:
	velocity = ((entity.position - source_position).normalized()) * absorbed_knockback
	if entity:
		entity.velocity = velocity
		entity.move_and_slide()

func change_stat(multiplier:float,stat:int,type:String):
	speed = (speed * multiplier) + stat
	if type == "enemy":
		speed = randi_range(0.8 * speed, 1.2 * speed)
