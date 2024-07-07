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
var sound_type_being_investigated:int = -1
@onready var idlePosition:Vector3 = position
var attention = 0
var player_visibility:int = 0 

@export var pathFollow:PathFollow3D
@export var investigationSounds: Array[AudioStreamWAV]
@export var investigationCancelledSounds: Array[AudioStreamWAV]
@export var playerFoundSounds: Array[AudioStreamWAV]

var sound_volume = {
	SoundType.Coin: 0.8,
	SoundType.Shot: 10.0,
	SoundType.Steps: 0.35,
	SoundType.GuardYell: 1.2,
}

func _ready():
	GameManager.sound_created.connect(sound_created)
	
	set_physics_process(false)
	await get_tree().physics_frame
	set_physics_process(true)

func sound_created(sound_position:Vector3, type:int):
	if(sound_position == global_position or is_silent_takedown):
		return
	var local_volume:float = float(sound_volume[type])/position.distance_to(sound_position)
	
	if(local_volume <= EAR_THRESHOLD): 
		return
	
	if state != EnemyState.Chase and state != EnemyState.Investigating:
		if type == SoundType.GuardYell:
			state = EnemyState.Chase
		else:
			print("Investigating...")
			sound_type_being_investigated = type
			investigate(sound_position)

func check_vision():
	# if state == EnemyState.Investigating
	var angle:float = rad_to_deg((player.find_child("Camera").global_position - position).angle_to(-$Eyes.global_basis.z))
	if angle <= SPOT_FOV:
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create($Eyes.global_position, player.global_position + Vector3.DOWN)

		var result = space_state.intersect_ray(query)
		if result.is_empty() or result.collider != player:
			if player_visibility > 0:
				player_visibility -= 1
			return
			
		var a = (65.0 / player.global_position.distance_to(global_position)) * (0.8 if player.is_crouching else 1.0)
		print("Player visibility increase: %f" % a)
		player_visibility += a
		
		if player_visibility >= 150 - attention:
			print("Chasing...")
			on_found_player()
	if player_visibility > 0:
			player_visibility -= 1

func on_found_player():
	$Voice.stream = playerFoundSounds[randi_range(0, len(playerFoundSounds)-1)]
	$Voice.play()
	GameManager.sound_created.emit(global_position, SoundType.GuardYell)
	state = EnemyState.Chase

func investigate(position:Vector3):
	if state == EnemyState.Chase:
		return
	if state != EnemyState.Investigating:
		attention += 1
		$Voice.stream = investigationSounds[randi_range(0, len(investigationSounds)-1)]
		$Voice.play()

	state = EnemyState.Investigating
	investigationTarget = position
	$agent.set_target_position(position)

func _physics_process(delta):
	if is_silent_takedown:
		return
	
	if(state == EnemyState.Idle):
		if(pathFollow != null):
			idlePosition = pathFollow.global_position
		if(position.distance_squared_to(idlePosition) > 1):
			$agent.set_target_position(idlePosition)
		elif pathFollow != null:
			pathFollow.progress += 0.2
			
		check_vision()
	
	if(state == EnemyState.Investigating):
		check_vision()
		if $agent.is_target_reached():
			if sound_type_being_investigated == SoundType.Steps or sound_type_being_investigated == SoundType.Shot:
				var desRot = rad_to_deg(global_position.angle_to(idlePosition)) + 360
				if(abs(desRot - rotation_degrees.y) < 5):
					print("Investigation over, returning to idle position")
					return_to_idle()
					attention -= 0.9
					return
				rotation_degrees.y = move_toward(rotation_degrees.y, desRot, 1.5)
			elif sound_type_being_investigated == SoundType.Coin and $InvestigationTimer.is_stopped():
				$InvestigationTimer.start(2.5)
		
	var direction:Vector3
	if(state == EnemyState.Chase):
		$agent.set_target_position(player.position)
		
		if player.global_position.distance_to(global_position) < 1.8:
			player.apply_damage(2)
			
	if $agent.is_target_reached():
		return
	
	direction = ($agent.get_next_path_position() - position).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		rotation.y = rotate_toward(rotation.y, atan2(-direction.x,-direction.z), 0.18)
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	# rotation_degrees.y = rad_to_deg(rotate_toward(deg_to_rad(rotation_degrees.y), Vector3.ZERO.angle_to(direction), 0.4))

	move_and_slide()

func return_to_idle():
	$Voice.stream = investigationCancelledSounds[randi_range(0, len(investigationCancelledSounds)-1)]
	$Voice.play()
	state = EnemyState.Idle
func apply_damage(amount:int):
	health -= amount
	attention += amount/100
	investigate(global_position)
	if(health <= 0):
		die()
		
func die():
	queue_free()

enum EnemyState{
	Idle,
	Chase,
	Investigating,
}


func _on_investigation_timeout():
	return_to_idle()
