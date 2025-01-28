extends BaseEnemy

func _ready():
	super._ready()
	health_component.max_health = 100
	movement_component.speed = 80.0
	combat_component.damage = 20
	combat_component.knockback_power = 700
	currency_component.currency = 10
	

	


func _on_hurt_box_area_entered(area):
	take_damage(area.get_parent().damage,((position - player.position).normalized()),combat_component.knockback_power)


