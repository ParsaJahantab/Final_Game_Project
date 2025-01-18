extends Node2D

@export var entity:Node2D
@onready var overhaead_healthbar = $OverHaeadHealthBar
func _ready():
	await get_tree().process_frame
	overhaead_healthbar.max_value = entity.health_component.max_health
	entity.health_changed.connect(update)
	update()

func update():
	overhaead_healthbar.value = entity.health_component.current_health

func _process(_delta):
	pass
