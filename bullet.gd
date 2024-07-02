extends Node3D

const speed = 5
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += -transform.basis.z * speed


func _on_body_entered(body):
	queue_free()
