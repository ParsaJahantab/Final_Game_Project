extends CharacterBody2D


@export var SPEED = 120.0
@export var knokback_power = 500
const JUMP_VELOCITY = -400.0

@onready var animations = $AnimationPlayer
@onready var hurt_effect = $Effects
@onready var weapon = $Weapon
@onready var sword_collision = $Weapon/sword/Sword/CollisionShape2D
@export var damage = 50 

var isAttacking: bool = false
var heading = "Down"
var health = 3
@export var max_health = 100
@onready var current_health:int = max_health
var is_dead = false
signal health_changed

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready():
	weapon.visible = false
	sword_collision.disabled = true


func handleInput():
	if is_dead : return
	var direction = Input.get_vector("left", "right","up","down")
	velocity = direction * SPEED
		
	if Input.is_action_just_pressed("attack"):
		weapon.visible = true
		isAttacking = true
		sword_collision.disabled = false
		animations.play("SwordAttack" + heading)
		await animations.animation_finished
		isAttacking = false
		sword_collision.disabled = true
		weapon.visible = false
	
func updateAnimation():
	if isAttacking : return
	if is_dead : return
	if velocity.length() == 0:
		animations.stop()
	else:
		heading = "Down"
		if velocity.x < 0 : heading = "Left"
		elif velocity.x > 0 : heading = "Right"
		elif velocity.y < 0 : heading = "Up"
		
		animations.play("walk" + heading)


	


func _physics_process(delta):
	handleInput()
	move_and_slide()
	updateAnimation()
	
	





func _on_hurt_box_area_entered(area):
	knockback(area.get_parent().position,area.get_parent().damage)
	
	
func knockback(enemy_pos,damage_recived):
	if is_dead : return
	hurt_effect.play("hurtEffect")
	velocity = ((position - enemy_pos).normalized()) * knokback_power
	current_health = current_health - damage_recived
	health_changed.emit()
	if current_health <= 0:
		velocity = velocity * 2
		await hurt_effect.animation_finished
		is_dead = true
		animations.play("dead")
	move_and_slide()
	
