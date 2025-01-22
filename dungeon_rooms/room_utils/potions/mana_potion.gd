extends BasePotion


func _on_area_2d_body_entered(body):
	body.mana_component.add_mana(20)
	queue_free() 
