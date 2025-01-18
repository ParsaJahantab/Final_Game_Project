extends Control

@export var player:Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	player.health_changed.connect(update)
	update()

func update():
	$CanvasLayer/HealthBar.value = player.current_health
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
