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
	position = Vector2(0, 13)

func _process(delta):
	if is_moving:
		# Simple position update instead of using velocity
		position += direction * speed * delta
		
func disable():
	set_process(false)
	$Area2D/CollisionShape2D.disabled = true
	visible = false
	
func activate():
	set_process(true)
	$Area2D/CollisionShape2D.disabled = false
	visible = true
	
func shot(p_damage):
	damage = p_damage
	is_moving = true
	activate()
	
	# Set direction based on player heading
	if player.heading == "Left":
		direction = Vector2.LEFT
		rotation_degrees = 180
	else:
		direction = Vector2.RIGHT
		rotation_degrees = 0

# Use Area2D for collision detection
	
func collision():
	print("collision detected")
	is_moving = false
	disable()
	position = Vector2(0, 13)
	rotation_degrees = 0
	direction = Vector2.ZERO
	on_hit.emit()






func _on_area_2d_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	print("6")
	collision() # Replace with function body.
