extends CharacterBody3D


const SPEED = 5.0
const SPRINT_SPEED = 7.0
const JUMP_VELOCITY = 4.5
const BULLET_SPREAD = 2
const FIRE_RATE = 30 # In bullets/second
const MOVE_RECOIL = 8
const AIM_RECOIL = 0.4

@onready var raycast = $"Camera/RayCast"
@export var bulletScene: PackedScene
var pickupObj = null

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var mouse_sensitivity = 0.25

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
var time_since_bullet = 0.0
func _process(delta):
	time_since_bullet += delta
	if Input.is_action_just_released("close"):
		get_tree().quit()

func _input(event):  		
	if not event is  InputEventMouseMotion: return

	rotation_degrees.y += -event.relative.x*mouse_sensitivity
	var x = -event.relative.y*mouse_sensitivity
	if $Camera.rotation_degrees.x+x>-50 and $Camera.rotation_degrees.x+x<50:
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
	
	time_since_bullet = 0
	var b = bulletScene.instantiate()
	get_tree().root.add_child(b)
	b.position = $"Camera/Guntip".global_position

	# add spread
	var x_spread = randf_range(-BULLET_SPREAD, BULLET_SPREAD)
	var y_spread = randf_range(-BULLET_SPREAD, BULLET_SPREAD)
	
	# add movement recoil
	velocity += transform.basis.z * MOVE_RECOIL
	
	# add aim recoil
	$Camera.rotation_degrees.x += AIM_RECOIL
	rotation_degrees.y += randf_range(-AIM_RECOIL, AIM_RECOIL)
	
	b.rotation_degrees = Vector3($Camera.rotation_degrees.x + x_spread, rotation_degrees.y + y_spread, 0)
	
	
	""""
	# Now, do hitscan:
	var space_state = get_world_3d().direct_space_state
	
	var query = PhysicsRayQueryParameters3D.create($Camera.global_position, $Camera.global_position + -$Camera.transform.basis.z*600)
	var result = space_state.intersect_ray(query)
	if result.is_empty() or result.collider == null:
		print("No hit")
		return
	
	print("hit on %s" % result.collider.name)
	if result.collider.name == "Enemy":
		result.collider.apply_damage(1)
	"""

func _physics_process(delta):
	
	if Input.is_action_just_pressed("pickup"):
		if pickupObj == null and raycast.is_colliding() and raycast.get_collider() is RigidBody3D:
			pickup(raycast.get_collider())
		else:
			if pickupObj != null:
				let_go()
	
	
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
