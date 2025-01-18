extends StaticBody2D

@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")

signal entred

func _ready():
	$CloseDoor.visible = false
	$OpenDoor.visible = true
	$DoorInMotion.visible = false
	

func open() -> void:
	animation_player.play("open")
	
func close() -> void:
	animation_player.play("close")
	


func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	emit_signal("entred")
