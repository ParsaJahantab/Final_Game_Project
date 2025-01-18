extends TextureProgressBar

@export var enemy:Node2D
# Called when the node enters the scene tree for the first time.
func _ready():
	max_value = enemy.max_health
	enemy.health_changed.connect(update)
	update()

func update():
	value = enemy.current_health
	
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
