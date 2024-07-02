extends CharacterBody3D


const SPEED = 5.0
const SPRINT_SPEED = 7.0
const JUMP_VELOCITY = 4.5
const BULLET_SPREAD = 1
const FIRE_RATE = 20 # In bullets/second
const MOVE_RECOIL = 8
const AIM_RECOIL = 0.4

@onready var raycast = $"Camera/RayCast"
@export var bulletScene: PackedScene
var pickupObj = null

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var mouse_sensitivity = 0.25

var is_aiming:bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
var time_since_bullet:float = 0.0
func _process(delta):
	time_since_bullet += delta
	# print(-$Camera.global_basis.z)
	if Input.is_action_just_released("close"):
		get_tree().quit()

func _input(event):
	is_aiming = Input.is_action_pressed("aim")
	if not event is  InputEventMouseMotion: return

	rotation_degrees.y += -event.relative.x*mouse_sensitivity
	var x = -event.relative.y*mouse_sensitivity
	if $Camera.rotation_degrees.x+x>-89 and $Camera.rotation_degrees.x+x<89:
		$Camera.rotation_degrees.x += x

func pickup(obj):
	pickupObj = obj
	pickupObj.freeze = true
	pickupObj.reparent($Camera)
	
func let_go():
	pickupObj.freeze = false
	pickupObj.reparent(get_parent())
	pickupObj = null

func shoot():

	if(time_since_bullet < 1.0/FIRE_RATE):
		return
	
	# get spread
	var x_spread = randf_range(-BULLET_SPREAD, BULLET_SPREAD) / (2 if(is_aiming) else 1)
	var y_spread = randf_range(-BULLET_SPREAD, BULLET_SPREAD) / (2 if(is_aiming) else 1)
	
	# do hitscan:
	var bullet_direction:Vector3 = ($Camera.global_position - $Camera.global_basis.z*600).rotated($Camera.global_basis.x, deg_to_rad(y_spread)).rotated($Camera.global_basis.y, deg_to_rad(x_spread))
	var query = PhysicsRayQueryParameters3D.create($Camera.global_position, bullet_direction)

	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if !result.is_empty() and result.collider != null:
		if result.collider.name == "Enemy":
			result.collider.apply_damage(1)
			
		if result.collider is RigidBody3D:
			result.collider.apply_impulse((-transform.basis.z).normalized(), result.position)
	
	
	time_since_bullet = 0
	var b = bulletScene.instantiate()
	get_tree().root.add_child(b)
	b.position = $"Camera/Weapon/Guntip".global_position
	if(!result.is_empty() and result.collider != null):
		b.look_at(b.position+bullet_direction) # Make bullets exactly fly at the hit position of the raycast
	else:
		b.rotation_degrees = Vector3($Camera.rotation_degrees.x+x_spread, rotation_degrees.y+y_spread, 0) # if the ray didn#t hit, just shoot forward
	
	# add movement recoil
	velocity += transform.basis.z * MOVE_RECOIL / (2 if(is_aiming) else 1)
	
	# add aim recoil
	if $Camera.rotation_degrees.x+AIM_RECOIL>-89 and $Camera.rotation_degrees.x+AIM_RECOIL<89:
		$Camera.rotation_degrees.x += AIM_RECOIL / (2 if(is_aiming) else 1)
		rotation_degrees.y += randf_range(-AIM_RECOIL, AIM_RECOIL)
	
	#b.rotation_degrees = Vector3($Camera.rotation_degrees.x + x_spread, rotation_degrees.y + y_spread, 0)
	
	# create noise
	GameManager.sound_created.emit($Camera/Weapon/Guntip.global_position, 1)
	if not $"Camera/audioPlayer".is_playing():
		$"Camera/audioPlayer".play()

var taking_down_enemy: CharacterBody3D = null
var time_left_for_takedown:float
func _physics_process(delta):
	if is_aiming:
		$"Camera/Weapon".position = $"Camera/Weapon".position.move_toward($Camera/AimGunPos.position, 0.05)
	else:
		$"Camera/Weapon".position = $"Camera/Weapon".position.move_toward($Camera/NormalGunPos.position, 0.05)
	
	if Input.is_action_just_pressed("pickup"):
		if pickupObj == null and raycast.is_colliding() and raycast.get_collider() is RigidBody3D:
			pickup(raycast.get_collider())
		else:
			if pickupObj != null:
				let_go()
				
	if Input.is_action_just_pressed("silent_takedown"):
		if raycast.is_colliding() and raycast.get_collider().name == "Enemy":
			taking_down_enemy = raycast.get_collider()
			taking_down_enemy.is_silent_takedown = true
			time_left_for_takedown = 3
	if Input.is_action_pressed("silent_takedown"):
		if taking_down_enemy == null:
			return
		if raycast.is_colliding() and raycast.get_collider() == taking_down_enemy:
			time_left_for_takedown -= delta
			if time_left_for_takedown <= 0:
				taking_down_enemy.die()
				taking_down_enemy = null
		else:
			taking_down_enemy.is_silent_takedown = false
			taking_down_enemy = null
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, rotation.y)

	var speed
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = SPEED
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	if Input.is_action_pressed("shoot"):
		shoot()

	move_and_slide()
