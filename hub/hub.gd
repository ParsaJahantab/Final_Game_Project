extends Node2D


func _ready():
	$Player.initialize()
	var i : int = 1
	for door : Door in $Doors.get_children():
		door.exited.connect(Callable(self, "on_exit").bind(i))
		if i<= GameState.avaialble_levels:
			door.init_to_open()
			
		else:
			door.init_to_close()
		i +=1
		


func _process(delta):
	pass
	
func on_exit(level : int) -> void:
	pass
