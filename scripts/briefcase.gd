extends Node3D



func _on_area_3d_body_entered(body):
	if body.name != "Player":
		return
	
	body.has_briefcase = true
	queue_free()
	GameManager.briefcase_picked_up.emit()
