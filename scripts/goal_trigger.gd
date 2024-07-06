extends Area3D


func _on_body_entered(body):
	if(body.name != "Player" or !body.has_briefcase):
		return
		
	GameManager.level_completed.emit()
