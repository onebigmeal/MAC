extends RigidBody3D

const CROUCH_SPEED = 20.0
const WALK_SPEED = 50.0
const MAX_WALK_SPEED = 10.0
const AIR_SPEED = 1
const SPRINT_SPEED = 80.0
const MOUSE_SENSITIVITY = 0.004
const CONTROLLER_SENSITIVITY = 0.03
const BOB_FREQ = 2.0
const BOB_AMP = 0.0
const JUMP_HEIGHT = 7.0
var t_bob = 0.0
const BASE_FOV = 75.0
const FOV_CHANGE = 1
var friction = 0
var crouch = 0
var was_on_floor 
var direction = Vector3()
var velocity = Vector3()
var is_on_floor = true
var front_collided = false
var left_collided = false
var right_collided = false
var back_collided = false
var is_roofed = false
var thirdperson = false
var jump_vector = Vector3(-100,-JUMP_HEIGHT,-100)
var crouch_check = false
var slide_check = false
var fixed_direction = 0
var lock_direction = false
var test3 = Vector3.ZERO
var last_input = Vector3.ZERO
var headmovement = Vector3()
@onready var head = $Head
@onready var camera = $Head/Camera3D2
@onready var coyote = $CoyoteTimer
@onready var collision = $CollisionShape3D
@onready var floor = $"../../../../../floor"
@onready var raycast = $RayCast3D
@onready var upboy = $upboy
@onready var othercamera = $Head/pivot/FOVcamera2
@onready var pivot = $Head/pivot
@onready var central_force_label_z := $"../../../../../GUI/central_force_z"
@onready var central_force_label_x := $"../../../../../GUI/central_force_x"
@onready var label = $"../../../../../GUI/Linear_v"
@onready var label2 = $"../../../../../GUI/Linear_x"
@onready var label3 = $"../../../../../GUI/total_linear_velocity"
@onready var label4 = $"../../../../../GUI/crouch_status"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.set_contact_monitor(true)
	self.set_max_contacts_reported(999)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	linear_damp = 5
	raycast.enabled = true
	upboy.enabled = true
	
func _unhandled_input(event):
	pass
		
		
		
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

func _process(delta: float) -> void:
	headmovement.y = Input.get_axis("headup2","headdown2")
	headmovement.x = Input.get_axis("headleft2","headright2")
	if headmovement != Vector3.ZERO:
		if othercamera.current == true:
			head.rotate_y(-headmovement.x * CONTROLLER_SENSITIVITY)
			pivot.rotate_x(-headmovement.y * CONTROLLER_SENSITIVITY)
			pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		else:
			head.rotate_y(-headmovement.x * CONTROLLER_SENSITIVITY)
			camera.rotate_x(-headmovement.y * CONTROLLER_SENSITIVITY)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
			
	label2.text = "Total absolute velocity= " + str(abs(linear_velocity.x)+abs(linear_velocity.z))
	label3.text = "velocity x = " + str(linear_velocity.x)
	label4.text = "velocity z = " + str(linear_velocity.z)
	var input:= Vector3.ZERO
# does not work
	if not slide_check:
		input.x = Input.get_axis("left2", "right2")
		input.z = Input.get_axis("forward2", "back2")
		test3 = input
		linear_damp = 2
	if slide_check:
		linear_damp = 0.1
		if not lock_direction:
			last_input = input
			fixed_direction = head.transform.basis
			#print((fixed_direction * Vector3(10, 0, 10)).normalized())
			apply_central_impulse(last_input * Vector3(10, 0, 10))
		input = (fixed_direction * input).normalized()
		lock_direction = true
	else:
		lock_direction = false
		input = (head.transform.basis * input).normalized()
	var v = sqrt(pow(linear_velocity.x,2)+pow(linear_velocity.y,2)+pow(linear_velocity.z,2))	
	is_on_floor = _touching_floor()
	is_roofed = _uncrouch_collision()
	if Input.is_action_just_pressed("jump2") and is_on_floor:
		apply_central_impulse(Vector3(input.x,1.0*JUMP_HEIGHT,input.z))
	elif abs(v) < MAX_WALK_SPEED:
		if not is_on_floor:
			if crouch == -1:
				linear_damp = 0.5
			set_inertia(jump_vector)
			set_gravity_scale(1.5)
			apply_central_impulse(input*AIR_SPEED*delta)
		else:
			linear_damp = 5
			if crouch:
				apply_central_impulse(input*CROUCH_SPEED*delta)
			else:
				apply_central_impulse(input*WALK_SPEED*delta)
	else: 
		pass
	#crouching below
	if Input.is_action_just_pressed("crouch2"):
		crouch = 1
	elif Input.is_action_just_released("crouch2"):
		crouch = -1
	elif crouch == 1 and abs(linear_velocity.x)+abs(linear_velocity.z)<10 and not slide_check: 
		crouch = 0
		$"../../../../../AnimationPlayer".self.play("crouch")
		label.text = "crouch down"
		linear_damp = 10
		linear_velocity = Vector3(0,0,0)
		crouch_check = true
	if crouch == -1 and not is_roofed and abs(linear_velocity.x)+abs(linear_velocity.z)<10 and not slide_check:
		crouch = 0
		$"../../../../../AnimationPlayer".play_backwards("crouch")
		label.text = "crouch up"
		set_gravity_scale(1)
		linear_damp = 5
		crouch_check = false
	elif crouch == 1 and abs(linear_velocity.x)+abs(linear_velocity.z)>10 and not crouch_check: 
		crouch = 0
		slide_check = true
		$"../../../../../AnimationPlayer".play("crouch")
		label.text = "slide down"
	elif crouch == -1 and not is_roofed and not crouch_check:
		crouch = 0
		slide_check = false
		$"../../../../../AnimationPlayer".play_backwards("crouch")
		label.text = "slide up"
	if Input.is_action_just_pressed("thirdperson2"):
		if not thirdperson:
			thirdperson = true
			othercamera.current = true
		else:
			thirdperson = false
			camera.current = true
