extends Control

const INCREASE_MULTIPLIER := 1.2

# Store attributes in a dictionary for easier management
var attributes := {
	"health": null,
	"damage": null,
	"speed": null
}

var required_mythril: int  
var required_mythrils: Array[int] = []

@onready var mythril_var: Label = $CanvasLayer/mythrilVar
@onready var required_var: Label = $CanvasLayer/RequiredVar

signal closed

func _ready() -> void:
	for attr_name in attributes:
		var node: Control = $CanvasLayer.get_node(attr_name.capitalize())
		attributes[attr_name] = node
		node.initialize_attribute(attr_name)
		# Connect signals
		node.increase_button.connect(level_increase)
		node.decrease_button.connect(level_decrease)
	
	required_mythril = GameState.required_mythril
	update_currency_display()
	required_mythrils.append(required_mythril)

func update_currency_display() -> void:
	mythril_var.text = str(GameState.player_currency)
	required_var.text = str(round(required_mythril)) 

func level_increase() -> void:
	required_mythril *= INCREASE_MULTIPLIER
	required_mythrils.append(required_mythril)
	required_var.text = str(round(required_mythril))

func level_decrease() -> void:
	if required_mythrils.size() > 1:  
		required_mythrils.pop_back()
		required_mythril = required_mythrils[-1]
		required_var.text = str(round(required_mythril))

func _on_texture_button_pressed() -> void:
	if required_mythrils.size() > 1:
		if GameState.player_currency >= required_mythril:
			GameState.required_mythril = required_mythril
			required_mythrils.pop_back()
			GameState.currency_change(round(required_mythrils[-1] * -1))
			for attr_name in attributes:
				var property_name = "player_%s_level" % attr_name
				GameState.set(property_name, attributes[attr_name].level)
	closed.emit()
	queue_free() 
