extends BaseEnemy


func _ready():
	super._ready()
	health_component.max_health = GlobalConfig.ORC_ATTRIBUTES["max_health"]
	movement_component.speed = GlobalConfig.ORC_ATTRIBUTES["speed"]
	combat_component.damage = GlobalConfig.ORC_ATTRIBUTES["damage"]
	combat_component.knockback_power = GlobalConfig.ORC_ATTRIBUTES["knockback_power"]
	currency_component.currency = GlobalConfig.ORC_ATTRIBUTES["currency"]
	

	


func _on_hurt_box_area_entered(area):
	take_damage(area.get_parent().damage,((position - player.position).normalized()),combat_component.knockback_power)
