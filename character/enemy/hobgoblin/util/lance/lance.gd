extends Node2D
class_name Lance

var Entity: BaseEnemy
var damage: int
var direction: Vector2
var is_moving := false
var speed := 100.0
signal on_hit


func _ready():
	visible = false



func _process(delta):
	if is_moving:
		position += (Vector2.RIGHT * speed ).rotated(rotation) * delta

func shot(p_damage):
	visible = true
	damage = p_damage
	is_moving = true
	




func _on_visible_on_screen_enabler_2d_screen_exited():
	is_moving = false
	queue_free()


func _on_area_2d_area_entered(area):
	is_moving = false
	queue_free()


func _on_area_2d_body_entered(body):
	is_moving = false
	queue_free()
