extends RigidBody3D

const CROUCH_SPEED = 30.0
const WALK_SPEED = 70.0
const MAX_WALK_SPEED = 7.0
const MAX_SPRINT_SPEED = 12.0
const SLIDE_FORCE = 7.0
const SLIDE_FRICTION = 2
const AIR_SPEED = 15.0
const SLIDE_POINT = 1.0
const SPRINT_MULTIPLIER = 2.0
const MOUSE_SENSITIVITY = 0.004
const CONTROLLER_SENSITIVITY = 0.03
const BOB_FREQ = 2.0
const BOB_AMP = 0.0
const JUMP_HEIGHT = 10.0
var t_bob = 0.0
const BASE_FOV = 75.0
const FOV_CHANGE = 1
var sprint_toggle = 0
var crouch = 0
var direction = Vector3()
var velocity = Vector3()
var input:= Vector3.ZERO
var last_input = Vector3.ZERO
var is_on_floor = true
var is_roofed = false
var thirdperson = false
var jump_vector = Vector3(-100,-JUMP_HEIGHT,-100)
var crouch_check = false
var slide_check = false
var lock_direction = false
var headmovement = Vector3()
var speed = 0
var max_speed = MAX_WALK_SPEED
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var coyote = $CoyoteTimer
@onready var collision = $CollisionShape3D
@onready var floor = $"../floor" 	
@onready var raycast = $RayCast3Dw
@onready var upboy = $upboy
@onready var othercamera = $Head/pivot/FOVcamera
@onready var pivot = $Head/pivot
@onready var central_force_label_z := $"../central_force_z"
@onready var central_force_label_x := $"../central_force_x"
@onready var label = $"../GUI/crouch_status"
@onready var label2 = $"../GUI/total_linear_velocity"
@onready var label3 = $"../GUI/Linear_x"
@onready var label4 = $"../GUI/Linear_v"
@onready var label5 = $"../central_force_z"
@onready var label6 = $"../central_force_x"
# Called when the node enters the scene tree for the first time.
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

func _process(delta: float) -> void:
	# setup
	label2.text = "Total absolute velocity= " + str(sqrt(pow(linear_velocity.x,2)+pow(linear_velocity.z,2)))
	var v = sqrt(pow(linear_velocity.x,2)+pow(linear_velocity.y,2)+pow(linear_velocity.z,2))	
	is_on_floor = _touching_floor()
	is_roofed = _uncrouch_collision()
	# input
	
	if Input.is_action_just_pressed("crouch"):
		crouch = 1
	elif Input.is_action_just_released("crouch"):
		crouch = -1
	if Input.is_action_just_pressed("sprint"):
		sprint_toggle = 1
		max_speed = MAX_SPRINT_SPEED
	elif Input.is_action_just_released("sprint"):
		sprint_toggle = 0
		max_speed = MAX_WALK_SPEED
		
	if crouch == 1:
		crouch = 0
		$"../AnimationPlayer".play("crouch")
		if abs(linear_velocity.x)+abs(linear_velocity.z)<SLIDE_POINT and not slide_check:
			label.text = "crouch down"
			linear_damp = 10
			linear_velocity = Vector3(0,0,0)
			crouch_check = true
		elif not crouch_check:
			slide_check = true
			label.text = "slide down"
	elif crouch == -1 and not is_roofed:
		crouch = 0
		$"../AnimationPlayer".play_backwards("crouch")
		if crouch_check:
			label.text = "crouch up"
			linear_damp = 5
			crouch_check = false
		elif slide_check:
			slide_check = false
			label.text = "slide up"
		
		
	if Input.is_action_just_pressed("thirdperson"):
		if not thirdperson:
			thirdperson = true
			othercamera.current = true
		else:
			thirdperson = false
			camera.current = true
			
	if slide_check:
		linear_damp = 0.1
		input = Vector3.ZERO
		if not lock_direction:   
			var forward_direction = head.transform.basis.z.normalized()
			var side_direction = head.transform.basis.x.normalized()       
			var slide_input = Vector3(last_input.x, 0, last_input.z).normalized()        
			var slide_impulse = (forward_direction * slide_input.z + side_direction * slide_input.x) *SLIDE_FORCE
			apply_central_impulse(slide_impulse)           
			label3.text = str(slide_impulse)
			lock_direction = true
	else:
		input.x = Input.get_axis("left", "right")
		input.z = Input.get_axis("forward", "back")
		linear_damp = 2
		last_input = input
		lock_direction = false
		input = (head.transform.basis * input).normalized()
		
	if Input.is_action_just_pressed("jump") and is_on_floor and not slide_check:
		apply_central_impulse(Vector3(input.x,JUMP_HEIGHT,input.z))
	else:
		set_gravity_scale(1)
		linear_damp = 5 if not slide_check else SLIDE_FRICTION
	speed = 0
	if abs(v) < max_speed:
		if not is_on_floor:
			if crouch == -1:
				linear_damp = 0.5
			set_inertia(jump_vector)
			set_gravity_scale(3)
			speed += AIR_SPEED
		elif crouch_check:
			speed += CROUCH_SPEED
		else:
			speed += WALK_SPEED
	if sprint_toggle:
		speed *= SPRINT_MULTIPLIER
	apply_central_impulse(input*speed*delta)
	#crouching below
