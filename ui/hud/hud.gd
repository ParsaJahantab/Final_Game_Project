extends Control

@export var player : Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_in_group("persistent"):
		add_to_group("persistent")
	
	process_mode = Node.PROCESS_MODE_ALWAYS


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
