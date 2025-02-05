extends Control

var player:Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	player = get_parent().player
	player.health_changed.connect(update)
	$CanvasLayer/HealthBar.max_value= player.health_component.max_health
	update()

func update():
	$CanvasLayer/HealthBar.value = player.health_component.current_health
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
