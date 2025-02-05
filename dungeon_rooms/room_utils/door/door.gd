extends StaticBody2D
class_name Door

@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var door_closing_sound_player: AudioStreamPlayer2D = get_node("DoorClosingSound")

signal entred
signal exited

func _ready():
	$DoorInMotion.visible = false

func init_to_close():
	$CloseDoor.visible = true
	$OpenDoor.visible = false
	$CollisionShape2D.disabled = false

func init_to_open():
	$OpenDoor.visible = true
	$CloseDoor.visible = false
	$CollisionShape2D.disabled = true
	

func open() -> void:
	animation_player.play("open")
	door_closing_sound_player.play()
	
	
func close() -> void:
	animation_player.play("close")
	door_closing_sound_player.play()
	


func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	emit_signal("entred")
	




func _on_exit_area_2d_body_entered(body):
	exited.emit()
