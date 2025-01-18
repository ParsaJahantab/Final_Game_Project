extends CharacterBody2D

const SPEED = 60.0

@export var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var animations = $AnimationPlayer
@onready var hitbox_collision = $hitBox/hitCollision
@export var knokback_power = 700

var heading = "Right"
var is_attaking = false
var is_hurt = false
@export var damage:int = 30
@export var max_health = 60
@onready var current_health:int = max_health

signal health_changed
signal enemy_killed

func _ready():
	health_changed.emit()
	$hitBox/hitCollision.disabled = true
	make_path()

func _physics_process(delta):
	if player and not player.is_dead:
		nav_agent.target_position = player.global_position
		if not nav_agent.is_navigation_finished():
			var dir = to_local(nav_agent.get_next_path_position()).normalized()
			velocity = dir * SPEED
			if not is_attaking and not is_hurt:
				move_and_slide()
			#handle_collision()
		else:
			velocity = Vector2.ZERO
		if player.is_dead:
			animations.stop()
		elif not is_attaking:
			updateAnimation()


func make_path():
	if player and not player.is_dead:
		nav_agent.target_position = player.global_position
		
#func handle_collision():
	#for i in get_slide_collision_count():
		#var collision = get_slide_collision(i)
		#var collider = collision.get_collider()
		#print(collider)
		
		
func updateAnimation():
	if not is_hurt:
		if nav_agent.is_navigation_finished() and not player.is_dead:
			animations.stop()
			is_attaking = true
			animations.play("attack" + heading)
			await animations.animation_finished
			is_attaking = false
			
		else:
			if not is_attaking:
				hitbox_collision.disabled = true
				if velocity.x < 0 : 
					heading = "Left"
				elif velocity.x > 0 : 
					heading = "Right"
				
				animations.play("walk" + heading)

func _on_timer_timeout():
	make_path()
	
	


func _on_hurt_box_area_entered(area):
	knockback(area.get_parent().get_parent().get_parent().damage)
	
	
func knockback(damage_recived):

	velocity = ((position - player.position).normalized()) * knokback_power
	current_health = current_health - damage_recived
	health_changed.emit()
	if current_health <= 0 :
		velocity = velocity * 2
	animations.stop()
	is_hurt = true
	is_attaking = false
	if not hitbox_collision.disabled :
		hitbox_collision.disabled = true
	move_and_slide()
	animations.play("hurt" + heading)
	await animations.animation_finished
	if current_health <= 0 :
		animations.play("dead" + heading)
		await animations.animation_finished
		emit_signal("enemy_killed")
		queue_free()
	is_hurt = false
	
