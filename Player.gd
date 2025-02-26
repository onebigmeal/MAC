extends CharacterBody3D


const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
var speed
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.01
const BOB_FREQ = 2.0
const BOB_AMP = 0.0
var t_bob = 0.0
const BASE_FOV = 75.0
const FOV_CHANGE = 1
var was_on_floor 
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var coyote = $CoyoteTimer



func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) *BOB_AMP
	# pos.x = cos(time*BOB_FREQ/2)*BOB_AMP
	return pos
	
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))


func _physics_process(delta: float) -> void:
	# Add the gravity.
	was_on_floor = is_on_floor()
	if not (is_on_floor()|| !coyote.is_stopped()):
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor()|| !coyote.is_stopped()):
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
		# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if (is_on_floor()|| !coyote.is_stopped()):
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta*7)
			velocity.z = lerp(velocity.z, direction.z * speed, delta*7)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta*2)
		velocity.z = lerp(velocity.z, direction.z * speed, delta*2)
	t_bob += delta*velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	#fov
	var velocity_clamped = clamp(velocity.length(),0.5, SPRINT_SPEED*2)
	var target_fov = BASE_FOV + FOV_CHANGE*velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta*5)
	move_and_slide()
	if was_on_floor && !is_on_floor():
		coyote.start()
	
