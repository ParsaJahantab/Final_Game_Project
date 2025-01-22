@tool
extends Node
class_name PlayerAnimationComponent

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_direction: String = "Right"
var is_attacking: bool = false
var is_rolling: bool = false

var player : Player

func _ready():
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
func initialize(p_player):
	player = p_player

func update_direction(velocity: Vector2) -> void:
	if velocity.length() == 0:
		animation_player.stop()
		return
		
	if velocity.x < 0:
		current_direction = "Left"
	elif velocity.x > 0:
		current_direction = "Right"
		
func set_dircetion():
	if player:
		if current_direction == "Left":
			player.sprite.flip_h = true
		else:
			player.sprite.flip_h = false

func play_run():
	if not is_attacking:
		set_dircetion()
		animation_player.play("run")
		
func play_idle() -> void :
	set_dircetion()
	animation_player.play("idle")
	
func play_hurt() -> void :
	if not is_attacking or not is_rolling:
		animation_player.stop()
		set_dircetion()
		animation_player.play("hurt")

func play_attack(weapon : String,attack_type:String) -> void:
	if not is_attacking :
		animation_player.stop()
		is_attacking = true
		set_dircetion()
		if current_direction == "Right":
			player.hit_box_collision.position = Vector2i(26,20)
		else:
			player.hit_box_collision.position = Vector2i(-26,20)
		if weapon == "Axe":
			player.hit_box_collision.scale *=1.2 
		if attack_type == "Heavy":
			player.hit_box_collision.scale *=1.2 
		animation_player.play(weapon+attack_type+ "Attack")
		await animation_player.animation_finished
		is_attacking = false
		
func play_bow_attack():
	if not is_attacking :
		animation_player.stop()
		is_attacking = true
		set_dircetion()
		animation_player.play("BowAttack")
		await animation_player.animation_finished
		is_attacking = false

func play_roll() -> void:
	if not is_rolling:
		set_dircetion()
		animation_player.stop()
		is_rolling = true
		animation_player.play("roll")
		await animation_player.animation_finished
		is_rolling = false
		

#func play_hurt() -> void:
	#effects_player.play("hurtEffect")

func play_death() -> void:
	set_dircetion()
	animation_player.play("death")
