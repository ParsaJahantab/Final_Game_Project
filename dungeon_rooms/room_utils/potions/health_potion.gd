extends BasePotion




func _on_area_2d_body_entered(body):
	body.health_component.heal(30)
	queue_free()
