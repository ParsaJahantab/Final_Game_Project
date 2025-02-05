extends CharacterBody2D
class_name Player

@onready var movement_component: CharacterMovementComponent = $CharacterMovementComponent
@onready var health_component: CharacterHealthComponent= $CharacterHealthComponent
@onready var mana_component: PlayerManaComponent = $PlayerManaComponent
@onready var animation_component = $PlayerAnimationComponent
@onready var sprite : Sprite2D = $Knight
@onready var hit_box_collision := $hitBox/CollisionShape2D
@onready var camera = $Camera2D
@onready var timer = $Timer
@onready var running_audio: AudioStreamPlayer2D = $AudioRunnig
const ARROW := preload("res://character/player/player_utils/arrow/arrow.tscn")
@export var knockback_power: float = 500.0



signal health_changed
signal mana_changed
signal attack_pressed
signal died

var is_dead : bool = false
var is_hurt : bool = false
var is_rolling : bool
var is_attacking: bool
var can_shoot : bool = true
var is_running : bool = false
var is_input_enable : bool = true
var weapon :String = "Sword"
var base_damage : int
var damage : int
var heading 
var heavy_attack_multiplier :=1.5
var direction = "Right"
var mouse_pos = get_global_mouse_position()



func _ready() -> void:
	await get_tree().process_frame
	#process_mode = Node.PROCESS_MODE_ALWAYS
	if not is_in_group("persistent"):
		add_to_group("persistent")
	health_component.died.connect(_on_died)
	health_component.health_changed.connect(_health_changed)
	mana_component.mana_changed.connect(_mana_changed)
	movement_component.initialize(self)
	health_component.initialize(self)
	mana_component.initialize(self)
	animation_component.initialize(self)
	_health_changed()
	_mana_changed()
	$hitBox/CollisionShape2D.disabled = true
	$Marker2D.visible = false

		
func initialize():
	await get_tree().process_frame
	is_dead = false
	health_component.is_dead = false
	is_hurt = false
	is_attacking = false
	movement_component.speed = GlobalConfig.BASE_PLAYER_ATTRIBUTES["SPEED"]
	movement_component.change_stat(1.0,(GameState.player_speed_level-1)*3,"player")
	health_component.max_health = GlobalConfig.BASE_PLAYER_ATTRIBUTES["HEALTH"]
	health_component.change_stat(1.0,(GameState.player_health_level-1)*10,"player")
	health_component.current_health = health_component.max_health
	mana_component.max_mana = GlobalConfig.BASE_PLAYER_ATTRIBUTES["MANA"]
	mana_component.change_stat(1.0,(GameState.player_mana_level-1)*5,"player")
	mana_component.current_mana = mana_component.max_mana
	base_damage = GlobalConfig.BASE_PLAYER_ATTRIBUTES["DAMAGE"]
	base_damage = base_damage + (GameState.player_damage_level-1)*5
	damage = base_damage
	health_component.is_dead = false
	is_dead = false
	is_hurt = false
	is_attacking = false
	
	
	
func _health_changed():
	health_changed.emit()

func _mana_changed():
	mana_changed.emit()

func set_input_enable(is_enable : bool):
	is_input_enable = is_enable

func _physics_process(_delta: float) -> void:
	
	if is_dead:
		print('here')
		return
	mouse_pos = get_global_mouse_position()
	if is_input_enable:
		handleInput()
	if weapon == "Bow":
		$Marker2D/MarkerSprite.global_position = mouse_pos
		$Marker2D.look_at(mouse_pos)
	
func handleInput():
	if not Input.is_anything_pressed() and not is_attacking and not is_rolling and not is_hurt:
		animation_component.play_idle()
		if is_running : 
			running_audio.stop()
			is_running = false
		return
	direction = Input.get_vector("left", "right","up","down")
	if not is_attacking and not is_rolling and not is_hurt:
		movement_component.move(direction)
	
	if direction.length() !=0 and not is_attacking and not is_rolling and not is_hurt:
		if !is_running :
			running_audio.play()
			is_running = true
		animation_component.update_direction(movement_component.velocity)
		if velocity.x < 0:
			heading = "Left"
		elif velocity.x > 0:
			heading = "Right"
		animation_component.play_run()
	
	if Input.is_action_just_pressed("roll") and not is_attacking and not is_hurt:
		if is_running : 
			running_audio.stop()
			is_running = false
		_on_roll_pressed()
	
	if (Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("heavy_attack")) and not is_rolling and not is_hurt:
		if is_running : 
			running_audio.stop()
			is_running = false
		if Input.is_action_just_pressed("attack"):
			_on_attack_pressed("Light")
		else:
			damage = int(damage * heavy_attack_multiplier)
			_on_attack_pressed("Heavy")
	if (Input.is_action_just_pressed("ChangeToSword")):
		$Marker2D.visible = false
		weapon = "Sword"
	elif(Input.is_action_just_pressed("ChangeToAxe")):
		$Marker2D.visible = false
		weapon = "Axe"
	elif(Input.is_action_just_pressed("ChangeToBow")):
		$Marker2D.visible = true
		weapon = "Bow"
		
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
		if weapon !="Bow":
			animation_component.play_attack(weapon,attack_type)
			await animation_component.animation_player.animation_finished
		else :
			if can_shoot:
				can_shoot = false
				timer.start()
				animation_component.play_bow_attack()
				var arrow : Arrow = ARROW.instantiate()
				arrow.global_position = global_position
				arrow.global_position.y = arrow.global_position.y + 11
				arrow.global_rotation = $Marker2D.global_rotation
				get_parent().add_child(arrow)
				arrow.shot(damage)
				await animation_component.animation_player.animation_finished
		is_attacking = false
		damage = base_damage

func _on_hurt_box_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	knockback(enemy.position, enemy.damage)

func knockback(enemy_pos: Vector2, damage_received: int) -> void:
	if health_component.is_dead:
		return
	is_hurt = true
	$hurtBox/CollisionShape2D.disabled = true
	animation_component.play_hurt()
	await animation_component.animation_player.animation_finished
	is_hurt = false
	$hurtBox/CollisionShape2D.disabled = false
	movement_component.apply_knockback(enemy_pos,knockback_power)
	health_component.take_damage(damage_received)
	
	if health_component.is_dead:
		movement_component.velocity *= 2
		animation_component.play_death()

func _on_died() -> void:
	is_dead = true
	died.emit()
	
var weapon_sounds = {
	"Sword": {
		"Light": preload("res://music_and_sfx/sword_light_slash.mp3"),
		"Heavy": preload("res://music_and_sfx/sword_heavy_attack.mp3")
	},
	"Axe": {
		"Light": preload("res://music_and_sfx/axe_light_attack.mp3"),
		"Heavy": preload("res://music_and_sfx/axe_heavy_attack.mp3")
	},
	"Bow": {
		"Light": preload("res://music_and_sfx/bow_attack_2.mp3"),
		"Heavy": preload("res://music_and_sfx/bow_attack_2.mp3")
	}
	
}

func get_weapon_sound(weapon: String, attack_type: String) -> AudioStream:
	if weapon in weapon_sounds and attack_type in weapon_sounds[weapon]:
		return weapon_sounds[weapon][attack_type]
	push_warning("Sound not found for %s_%s" % [weapon, attack_type])
	return null
	

func play_sound(sound_to_play, position: Vector2 = Vector2.ZERO):
	if not sound_to_play:
		push_warning("Attempted to play null sound")
		return
	
	if not has_node("SoundPool"):
		var sound_pool = Node.new()
		sound_pool.name = "SoundPool"
		add_child(sound_pool)
	
	var sound_pool = $SoundPool
	
	var player: AudioStreamPlayer2D = null
	
	for child in sound_pool.get_children():
		if not child.playing:
			player = child
			break
	
	if not player:
		player = AudioStreamPlayer2D.new()
		sound_pool.add_child(player)
		
		if sound_pool.get_child_count() > 20:
			sound_pool.get_child(0).queue_free()
	
	player.stream = sound_to_play
	player.position = position
	
	if player.stream == null:
		push_warning("Invalid sound stream")
		return
	
	player.play()
	
	player.finished.connect(
		func(): 
			if is_instance_valid(player):
				player.queue_free(), 
			CONNECT_ONE_SHOT
	)
	
func play_weapon_sound(attack_type: String) -> void:
	var sound = get_weapon_sound(weapon, attack_type)
	if sound:
		play_sound(sound, position)
	




func _on_timer_timeout():
	if not can_shoot:
		can_shoot = true
		
	
