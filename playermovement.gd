extends RigidBody3D
# all the constants, most of the numbers are based on tests and not actual measured units, basically we eyeballed it
# all the speeds (relative, I dont know what they are based on)
# speed and max speed use different metrics so 70.0 walk speed may only cap at 6 max speed or smth
# gravity is 5 default
const CROUCH_SPEED = 30.0
const WALK_SPEED = 70.0
const MAX_WALK_SPEED = 7.0 # this one is based on smth else
const MAX_SPRINT_SPEED = 2 # this is an increment
const MAX_CROUCH_SPEED = 5.0
const AIR_SPEED = 15.0
const SLIDE_FRICTION = 2 # this changes linear damp
const SLIDE_FORCE = 20.0 # extra push applied when sliding
const SLIDE_POINT = 11.0 # slide threshold
const JUMP_HEIGHT = 20.0 # how high you jump
const JUMP_VECTOR = Vector3(-100,-JUMP_HEIGHT,-100) # vector used to show direction of jump when player jumps
const SPRINT_MULTIPLIER = 2.0 # how much sprinting multiplies the
const MOUSE_SENSITIVITY = 0.004 
const CONTROLLER_SENSITIVITY = 0.03 

# for movement, walking forward bob, unused
const BOB_FREQ = 2.0
const BOB_AMP = 0.0
# FOV, unused
const BASE_FOV = 75.0
const FOV_CHANGE = 1 # when sprint

# variables
var t_bob = 0.0 # unused, for bobbing
var input:= Vector3.ZERO # IMPORTANT, used to store direction of movement based on input, not magnitude
var last_input = Vector3.ZERO # used to store last direction so slide is fixed direction
var is_on_floor = true # stores whether player is touching floor
var is_roofed = false # stores whether player is touching the roof of anything
var thirdperson_toggle = false # thirdperson toggle
var crouch_check = false # check whether player is crouching
var slide_check = false # check whether player is sliding
var lock_direction = false # does something with slide, magic, ask jeff
var headmovement = Vector3() # where head is facing
var speed = 0 # magnitude of impulse applied
var max_speed = MAX_WALK_SPEED # max speed of player, which changes when crouching or sprinting
var sprint_toggle = 1
var cooldown = false

# object variables
#head and pivot are important but its kinda hard to explain, its pretty much another node inside the rigidbody that can act as the head, pivot adds another axis
# all of these are paths to other nodes, find them in the directory
@onready var head = $Head
@onready var pivot = $Head/pivot
# two POVs
@onready var camera = $Head/Camera3D # main first person
@onready var OtherCamera = $Head/pivot/FOVcamera # third person
# raycasts for checking roof and floor
@onready var DownFacingnRayCast = $RayCast3D
@onready var UpFacingRayCast = $upboy # upboy is the name of the raycast
# 2d debugging labels
@onready var label = $"../GUI/crouch_status"
@onready var label2 = $"../GUI/total_linear_velocity"
# animation player
@onready var animationPlayer = $"../AnimationPlayer"
# Called when the node enters the scene tree for the first time.
@onready var timer = $"../Timer"
@onready var cooldown_status = $"../GUI/Linear_x"
@onready var times = $"../GUI/Linear_v"

func _ready() -> void:
	# so theres coollision logic
	self.set_contact_monitor(true)
	self.set_max_contacts_reported(999)
	# idk just do it
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_gravity_scale(4)
	linear_damp = 7 # linear damp is basically friction btw
	# init both raycasts
	DownFacingnRayCast.enabled = true
	UpFacingRayCast.enabled = true
	
func _unhandled_input(event):
	headmovement.y = Input.get_axis("headup","headdown") # the strings are mapped to input set in the project settings
	headmovement.x = Input.get_axis("headleft","headright")
	if headmovement != Vector3.ZERO: # if theres joystick
		if OtherCamera.current == true: # if third personing
			head.rotate_y(-headmovement.x * CONTROLLER_SENSITIVITY)
			pivot.rotate_x(-headmovement.y * CONTROLLER_SENSITIVITY) # weird rotation, ORDER MATTERS
			pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-40), deg_to_rad(60)) # so you cant look vertically weirdly, you cant rotate your head upwards by 360 degrees.
		else:
			head.rotate_y(-headmovement.x * CONTROLLER_SENSITIVITY)
			camera.rotate_x(-headmovement.y * CONTROLLER_SENSITIVITY)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
	elif event is InputEventMouseMotion: # for mouse
		if OtherCamera.current == true:
			head.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
			pivot.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
			pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		else:
			head.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
			camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		
		
		
func _touching_floor() -> bool: # basically check if raycast is colliding with object, if it is you are on floor
	DownFacingnRayCast.force_raycast_update()  # Update the raycast position
	if DownFacingnRayCast.is_colliding():
		var collision_point = DownFacingnRayCast.get_collision_point()
		var collider = DownFacingnRayCast.get_collider()
		return true
	return false

func _uncrouch_collision() -> bool: # same but for roof
	UpFacingRayCast.force_raycast_update()  # Update the raycast position
	if UpFacingRayCast.is_colliding():
		var collision_point = UpFacingRayCast.get_collision_point()
		var collider = UpFacingRayCast.get_collider()
		return true
	return false

func _process(delta: float) -> void:
	# setup
	times.text = str(timer.get_time_left())
	linear_damp = 7 if not slide_check else SLIDE_FRICTION # set friction here for some reason
	label2.text = "Total absolute velocity= " + str(sqrt(pow(linear_velocity.x,2)+pow(linear_velocity.z,2))) # set 2d label
	var v = sqrt(pow(linear_velocity.x,2)+pow(linear_velocity.y,2)+pow(linear_velocity.z,2)) # maths
	is_on_floor = _touching_floor()
	is_roofed = _uncrouch_collision()
	# input
	
	if Input.is_action_just_pressed("crouch"):
		animationPlayer.play("crouch")
		if abs(linear_velocity.x)+abs(linear_velocity.z)+abs(linear_velocity.y)<SLIDE_POINT and not slide_check: # if the speed does not exceed a threshold and is not sliding, so you cant crouch while sliding
			label.text = "crouch down"
			linear_velocity = Vector3(0,0,0) # so you don't maintain you momentum, so you cannot crouch and retain sprint speed
			crouch_check = true
			max_speed = MAX_CROUCH_SPEED # change max speed
		elif not crouch_check: # same but if speed is high and not crouching
			slide_check = true
			label.text = "slide down"
	elif Input.is_action_just_released("crouch"): # pretty much only detect chang from 1 to 0 of button crouch
		animationPlayer.play_backwards("crouch")
		if crouch_check:
			label.text = "crouch up"
			crouch_check = false
			max_speed = MAX_WALK_SPEED
		elif slide_check:
			slide_check = false
			label.text = "slide up"
			
	if Input.is_action_just_pressed("sprint") and not crouch_check: # only activate when button first pressed or release, no need toggle
		max_speed *= MAX_SPRINT_SPEED # sprint multiplies your max
		sprint_toggle += 1
	elif Input.is_action_just_released("sprint"):
		max_speed /= MAX_SPRINT_SPEED
		
	if Input.is_action_just_pressed("thirdperson"):
		OtherCamera.current =  camera.current # if current is true, the camera with true will be the one you see through
		camera.current = not OtherCamera.current # i just exchanged the cameras. 
	
			
	if Input.is_action_just_pressed("jump") and is_on_floor and not slide_check: # jump only when touching floor and not sliding
		apply_central_impulse(Vector3(input.x,JUMP_HEIGHT,input.z)) # push player up once
		
	# main processes 
	if slide_check: # if sliding
		input = Vector3.ZERO
		if not lock_direction:   # jeff voodoo
			cooldown_status.text = str(cooldown)
			var forward_direction = head.transform.basis.z.normalized()
			var side_direction = head.transform.basis.x.normalized()       
			var slide_input = Vector3(last_input.x, 0, last_input.z).normalized()        
			var slide_impulse = (forward_direction * slide_input.z + side_direction * slide_input.x) *SLIDE_FORCE
			if not cooldown:
				apply_central_impulse(slide_impulse)           
				if not is_on_floor:
					apply_central_impulse(slide_impulse*1.5)
			lock_direction = true
			if not cooldown:
				timer.start(1)
			cooldown = true
	else: # if not sliding
		input.x = Input.get_axis("left", "right") # get input from keyboard or joystick
		input.z = Input.get_axis("forward", "back")
		last_input = input # for sliding
		lock_direction = false # same for sliding
		input = (head.transform.basis * input).normalized() # make the input face the head direction, where player is facing
		
		
	if not is_on_floor: # if jumping, idk what happens 
		set_inertia(JUMP_VECTOR)
	if abs(v) < max_speed: # if doesn't exceed speed, it will apply the same force.
		apply_central_impulse(input*100*delta)


func _on_timer_timeout() -> void:
	timer.stop
	cooldown = false
	cooldown_status.text = str(cooldown)
