extends Control

var player:Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	player = get_parent().player
	player.mana_changed.connect(update)
	$CanvasLayer/ManaBar.max_value= player.mana_component.max_mana
	update()

func update():
	$CanvasLayer/ManaBar.value = player.mana_component.current_mana
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
