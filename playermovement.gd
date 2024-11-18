extends RigidBody3D

const WALK_SPEED = 50.0
const MAX_WALK_SPEED = 15.0
const AIR_SPEED = 15.0
const SPRINT_SPEED = 80.0
const SENSITIVITY = 0.01
const BOB_FREQ = 2.0
const BOB_AMP = 0.0
const JUMP_HEIGHT = 7.0
var t_bob = 0.0
const BASE_FOV = 75.0
const FOV_CHANGE = 1
var was_on_floor 
var direction = Vector3()
var velocity = Vector3()
var is_on_floor = true
var front_collided = false
var left_collided = false
var right_collided = false
var back_collided = false
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var coyote = $CoyoteTimer
@onready var collision = $CollisionShape3D
@onready var floor = $"../floor" 	
@onready var raycast = $RayCast3D
@onready var front = $Head/front
@onready var left = $Head/left
@onready var right = $Head/right
@onready var back = $Head/back
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.set_contact_monitor(true)
	self.set_max_contacts_reported(999)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	linear_damp = 1
	raycast.enabled = true
	front.set_monitoring(true)
	left.set_monitoring(true)
	right.set_monitoring(true)
	back.set_monitoring(true)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)

		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		
		
func _touching_floor() -> bool:
	raycast.force_raycast_update()  # Update the raycast position
	if raycast.is_colliding():
		var collision_point = raycast.get_collision_point()
		var collider = raycast.get_collider()
		return true
	return false

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _touching_wall(vector) -> Vector3:
	if front_collided:
		vector.z = clamp(vector.z,0,1)
	if back_collided:
		vector.z = clamp(vector.z,-1,0)
	if left_collided:
		vector.x = clamp(vector.x,0,1)
	if right_collided:
		vector.x = clamp(vector.x,-1,0)
	return vector

func _process(delta: float) -> void:
	var input:= Vector3.ZERO
	input.x = Input.get_axis("left", "right")
	input.z = Input.get_axis("forward", "back")	
	input = _touching_wall(input)
	input = (head.transform.basis * input).normalized()
	var v = sqrt(pow(linear_velocity.x,2)+pow(linear_velocity.y,2)+pow(linear_velocity.z,2))	
	print(input)
	is_on_floor = _touching_floor()
	if Input.is_action_just_pressed("jump") and is_on_floor:
		apply_central_impulse(Vector3(0.0,1.0,0.0)*JUMP_HEIGHT)
	elif abs(v) < MAX_WALK_SPEED:
		if not is_on_floor:
			pass
			# apply_central_impulse(input*AIR_SPEED*delta)
		else:
			apply_central_impulse(input*WALK_SPEED*delta)
	else: 
		pass
	


func _on_front_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	front_collided = true # Replace with function body.


func _on_front_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	front_collided = false # Replace with function body.


func _on_back_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	back_collided = true # Replace with function body.


func _on_back_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	back_collided = false # Replace with function body.


func _on_left_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	left_collided = true # Replace with function body.


func _on_left_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	left_collided = false # Replace with function body.


func _on_right_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	right_collided = true # Replace with function body.


func _on_right_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	right_collided = false # Replace with function body.
