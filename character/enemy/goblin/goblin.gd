extends BaseEnemy

func _ready():
	super._ready()
	health_component.max_health = GlobalConfig.GOBLIN_ATTRIBUTES["max_health"]
	movement_component.speed = GlobalConfig.GOBLIN_ATTRIBUTES["speed"]
	combat_component.damage = GlobalConfig.GOBLIN_ATTRIBUTES["damage"]
	combat_component.knockback_power = GlobalConfig.GOBLIN_ATTRIBUTES["knockback_power"]
	currency_component.currency = GlobalConfig.GOBLIN_ATTRIBUTES["currency"]
	

	


func _on_hurt_box_area_entered(area):
	take_damage(area.get_parent().damage,((position - player.position).normalized()),combat_component.knockback_power)


