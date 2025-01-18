extends BaseEnemy


func _ready():
	super._ready()
	health_component.max_health = 60
	movement_component.speed = 60.0
	combat_component.damage = 30
	combat_component.knockback_power = 700
	

	


func _on_hurt_box_area_entered(area):
	take_damage(area.get_parent().get_parent().get_parent().damage,((position - player.position).normalized()),combat_component.knockback_power)
