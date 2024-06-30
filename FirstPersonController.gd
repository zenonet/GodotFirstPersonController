extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var mouse_sensitivity = 0.25

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _process(delta):
	if Input.is_action_just_released("close"):
		get_tree().quit()

func _input(event):  		
	if event is InputEventMouseMotion:

		rotation_degrees.y += -event.relative.x*mouse_sensitivity
		var x = -event.relative.y*mouse_sensitivity
		if $Camera.rotation_degrees.x+x>-50 and $Camera.rotation_degrees.x+x<50:
			$Camera.rotation_degrees.x += x


func get_body_forward():
	return Vector3(cos(rotation.y), 0, sin(rotation.y))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (Vector3(input_dir.x, 0, input_dir.y)).normalized()
	print(get_body_forward())
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
