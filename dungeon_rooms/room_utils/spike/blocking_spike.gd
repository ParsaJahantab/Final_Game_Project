extends StaticBody2D

@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")

signal entred

func _ready():
	pass

func close():
	animation_player.play("spike_out")

func open():
	animation_player.play("spike_in")

func _process(_delta):
	pass


func _on_area_2d_body_entered(body):
	emit_signal("entred")
	
	
