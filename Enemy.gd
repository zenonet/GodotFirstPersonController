extends CharacterBody3D

const SPEED:float = 5.0
const JUMP_VELOCITY:float = 4.5
const SPOT_FOV = 38.0

var health:int = 20

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var player = $"%Player"

var state: EnemyState = EnemyState.Idle

func check_vision():
	var angle:float = rad_to_deg((player.global_position - position).angle_to(-$Eyes.global_basis.z))
	if angle < SPOT_FOV:
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create($Eyes.global_position, player.global_position)

		var result = space_state.intersect_ray(query)
		if result.is_empty() or result.collider != player:
			return
			
		state = EnemyState.Chase

func _physics_process(delta):
	if(state == EnemyState.Idle):
		check_vision()
		return
		
	var direction:Vector3
	if(state == EnemyState.Chase):
		$agent.set_target_position(player.position)
		direction = ($agent.get_next_path_position() - position).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	look_at(position+direction)
	rotation_degrees.x = 0
	rotation_degrees.z = 0

	move_and_slide()

func apply_damage(amount:int):
	health -= amount
	# print("now on %d hp" % health)
	if(health <= 0):
		die()
		
func die():
	queue_free()

enum EnemyState{
	Idle,
	Patrol,
	Chase,
}
