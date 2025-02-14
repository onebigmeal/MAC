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
var dead = false
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

func hit(damage):
	if not dead:
		print(Global.R_health)
		if Global.R_health <= 0:
			dead = true
			Global.R_health = 0.0
		else:
			Global.R_health  -= damage
		
func _process(delta: float) -> void:
	pass

func _on_static_body_3d_apply_damage() -> void:
	hit(10)
