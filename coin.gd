extends RigidBody3D

func _on_body_entered(body):
	print("Coin sound!")
	GameManager.sound_created.emit(global_position, 1)
