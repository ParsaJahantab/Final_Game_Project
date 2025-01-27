extends Node2D
class_name Arrow

var player: Player
var damage: int
var direction: Vector2
var is_moving := false
var speed := 200.0
signal on_hit

func _ready():
	disable()

func initialize(p_player):
	player = p_player
	# Set initial position relative to player, but then make it absolute
	position = Vector2(0, 13)
	global_position = player.global_position + position

func _process(delta):
	if is_moving:
		position += direction * speed * delta
		
func disable():
	set_process(false)
	$Area2D/CollisionShape2D.disabled = true
	visible = false
	$Area2D.monitoring = false
	$Area2D.monitorable = false
	
func activate():
	set_process(true)
	$Area2D/CollisionShape2D.disabled = false
	visible = true
	$Area2D.monitoring = true
	$Area2D.monitorable = true
	
func shot(p_damage):
	damage = p_damage
	is_moving = true
	# Set the arrow's global position before activating
	global_position = player.global_position + Vector2(0, 13)
	activate()
	
	# Set direction based on player heading
	if player.heading == "Left":
		direction = Vector2.LEFT
		rotation_degrees = 180
	else:
		direction = Vector2.RIGHT
		rotation_degrees = 0

func collision():
	print("collision detected")
	is_moving = false
	disable()
	position = Vector2(0, 13)
	rotation_degrees = 0
	direction = Vector2.ZERO
	on_hit.emit()



func _on_area_2d_body_entered(body):
	print("Collision with:", body.name)
	collision()
