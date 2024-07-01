extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var health:int = 50

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var player = $"%Player"

func _physics_process(delta):
	$agent.set_target_position(player.position)
	var direction = ($agent.get_next_path_position() - position).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func apply_damage(amount:int):
	health -= amount
	print("now on %d hp" % health)
	if(health <= 0):
		die()
		
func die():
	queue_free()
