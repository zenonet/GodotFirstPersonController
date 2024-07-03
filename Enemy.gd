extends CharacterBody3D

const SPEED:float = 5.0
const JUMP_VELOCITY:float = 4.5
const SPOT_FOV = 38.0
const EAR_THRESHOLD = 0.05

var health:int = 20
var is_silent_takedown:bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var player = $"%Player"

var state: EnemyState = EnemyState.Idle
var investigationTarget: Vector3
@onready var idlePosition:Vector3 = position

func _ready():
	GameManager.sound_created.connect(sound_created)
	
func sound_created(sound_position:Vector3, volume:float):
	if(sound_position == global_position or is_silent_takedown):
		return
	var local_volume:float = volume/position.distance_to(sound_position)

	if(local_volume <= EAR_THRESHOLD): 
		return
	
	if state != EnemyState.Chase:
		print("Investigating...")
		state = EnemyState.Investigating
		investigationTarget = sound_position
		$agent.set_target_position(sound_position)
	
func check_vision():
	
	var angle:float = rad_to_deg((player.find_child("Camera").global_position - position).angle_to(-$Eyes.global_basis.z))
	if angle < SPOT_FOV:
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create($Eyes.global_position, player.global_position)

		var result = space_state.intersect_ray(query)
		if result.is_empty() or result.collider != player:
			return
		print("Chasing...")
		on_found_player()

func on_found_player():
	$Voice.play()
	GameManager.sound_created.emit(global_position, 0.4)
	state = EnemyState.Chase

func _physics_process(delta):
	if is_silent_takedown:
		return
	
	if(state == EnemyState.Idle):
		if(position.distance_squared_to(idlePosition) > 1):
			$agent.set_target_position(idlePosition)
		check_vision()
	
	if(state == EnemyState.Investigating):
		check_vision()
		if $agent.is_target_reached():
			var desRot = rad_to_deg(global_position.angle_to(idlePosition)) + 360
			if(abs(desRot - rotation_degrees.y) < 5):
				print("Investigation over, returning to idle position")
				state = EnemyState.Idle
				return
			rotation_degrees.y = move_toward(rotation_degrees.y, desRot, 0.8)
		
	var direction:Vector3
	if(state == EnemyState.Chase):
		$agent.set_target_position(player.position)
		
	if $agent.is_target_reached():
		return
	
	direction = ($agent.get_next_path_position() - position).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	rotation_degrees.y = rad_to_deg(rotate_toward(rotation.y, global_position.angle_to(direction), 0.4))
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
	Chase,
	Investigating,
}
