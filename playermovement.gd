extends RigidBody3D

const CROUCH_SPEED = 20.0
const WALK_SPEED = 40.0
const SPRINT_BONUS = 1.5
const MAX_WALK_SPEED = 15.0
const MAX_SPRINT_SPEED = 20.0
const SLIDE_POINT = 10.0 # flashpoint ifykyk
const AIR_SPEED = 1
const MOUSE_SENSITIVITY = 0.004
const CONTROLLER_SENSITIVITY = 0.03
const JUMP_HEIGHT = 7.0
var crouch = 0
var direction = Vector3()
var velocity = Vector3()
var is_on_floor = true
var is_roofed = false
var thirdperson = false
var sprint_toggle = false
var jump_vector = Vector3(-100,-JUMP_HEIGHT,-100)
var crouch_check = false
var slide_check = false
var fixed_direction = 0
var lock_direction = false
var speed_input = 0.0
var test3 = Vector3.ZERO
var last_input = Vector3.ZERO
var headmovement = Vector3()
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var coyote = $CoyoteTimer
@onready var collision = $CollisionShape3D
@onready var floor = $"../floor" 	
@onready var raycast = $RayCast3D
@onready var upboy = $upboy
@onready var othercamera = $Head/pivot/FOVcamera
@onready var pivot = $Head/pivot
@onready var central_force_label_z := $"../central_force_z"
@onready var central_force_label_x := $"../central_force_x"
@onready var label = $"../GUI/crouch_status"
@onready var label2 = $"../GUI/total_linear_velocity"
@onready var label3 = $"../GUI/Linear_x"
@onready var label4 = $"../GUI/Linear_v"
# Called when the node enters the scene tree for the first time.
# crouch: 1 = start crouch 0 = not animating -1 = end crouch

func _ready() -> void:
	self.set_contact_monitor(true)
	self.set_max_contacts_reported(999)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	linear_damp = 5
	raycast.enabled = true
	upboy.enabled = true
	
func _unhandled_input(event):
	headmovement.y = Input.get_axis("headup","headdown")
	headmovement.x = Input.get_axis("headleft","headright")
	if headmovement != Vector3.ZERO:
		if othercamera.current == true:
			head.rotate_y(-headmovement.x * CONTROLLER_SENSITIVITY)
			pivot.rotate_x(-headmovement.y * CONTROLLER_SENSITIVITY)
			pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		else:
			head.rotate_y(-headmovement.x * CONTROLLER_SENSITIVITY)
			camera.rotate_x(-headmovement.y * CONTROLLER_SENSITIVITY)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
	elif event is InputEventMouseMotion:
		if othercamera.current == true:
			head.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
			pivot.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
			pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		else:
			head.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
			camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		
		
		
func _touching_floor() -> bool:
	raycast.force_raycast_update()  # Update the raycast position
	if raycast.is_colliding():
		var collision_point = raycast.get_collision_point()
		var collider = raycast.get_collider()
		return true
	return false

func _uncrouch_collision() -> bool:
	upboy.force_raycast_update()  # Update the raycast position
	if upboy.is_colliding():
		var collision_point = upboy.get_collision_point()
		var collider = upboy.get_collider()
		return true
	return false

func _crouch() -> void:
	$"../AnimationPlayer".play("crouch")
	label.text = "crouch down"
	linear_damp = 10
	linear_velocity = Vector3(0,0,0)

func _uncrouch():
	$"../AnimationPlayer".play_backwards("crouch")
	label.text = "crouch up"
	set_gravity_scale(1)
	linear_damp = 5
	
func _slide():
	$"../AnimationPlayer".play("crouch")
	label.text = "slide down"
func _unslide():
	$"../AnimationPlayer".play_backwards("crouch")
	label.text = "slide up"
	
func _process(delta: float) -> void:
	# pre-input loop cycle init processes
	label2.text = "Total absolute velocity= " + str(abs(linear_velocity.x)+abs(linear_velocity.z))
	var input:= Vector3.ZERO
	var v = sqrt(pow(linear_velocity.x,2)+pow(linear_velocity.y,2)+pow(linear_velocity.z,2))	
	is_on_floor = _touching_floor()
	is_roofed = _uncrouch_collision()
	
	#all input below
	if Input.is_action_just_pressed("sprint"):
		sprint_toggle = true
	elif Input.is_action_just_released("sprint"):
		sprint_toggle = false
	if Input.is_action_just_pressed("crouch") and not crouch_check:
		if v<SLIDE_POINT:
			_crouch()
			crouch_check = true
		else:
			fixed_direction = head.transform.basis
			slide_check = true
			_slide()
			
	elif Input.is_action_just_released("crouch") and not is_roofed:
		if slide_check:
			slide_check = false
			_unslide()
		if crouch_check:
			crouch_check = false
			_uncrouch()
			
	if Input.is_action_just_pressed("thirdperson"):
		if not thirdperson:
			thirdperson = true
			othercamera.current = true
		else:
			thirdperson = false
			camera.current = true
			
	# main movement processes

	
	if slide_check:
		linear_damp = 1
		if not lock_direction:
			#print((fixed_direction * Vector3(10, 0, 10)).normalized())
			if abs(head.transform.basis.x) > abs(head.transform.basis.z):
				apply_central_impulse(last_input * fixed_direction * 3.5)
			else:
				apply_central_impulse(last_input * fixed_direction * -3.5)
			label3.text = str(fixed_direction)	
		input = (fixed_direction * input).normalized()
		lock_direction = true
		
	else:
		input.x = Input.get_axis("left", "right")
		input.z = Input.get_axis("forward", "back")
		linear_damp = 5
		input = (head.transform.basis * input).normalized()
	
	if Input.is_action_just_pressed("jump") and is_on_floor:
		apply_central_impulse(Vector3(input.x,JUMP_HEIGHT,input.z))
	elif abs(v) < (MAX_WALK_SPEED if not sprint_toggle else MAX_SPRINT_SPEED):
		speed_input = WALK_SPEED
		
		if not is_on_floor:
			linear_damp = 0.1
			speed_input = AIR_SPEED
			set_inertia(jump_vector)
			set_gravity_scale(2)
			
		else:
			if crouch_check:
				linear_damp = 10
				speed_input = CROUCH_SPEED
			if sprint_toggle:
				speed_input *= SPRINT_BONUS
		apply_central_impulse(input*speed_input*delta)
	
	# wrap up processes
	
	last_input = input
