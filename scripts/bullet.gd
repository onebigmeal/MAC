extends Node3D

const SPEED = 500

@onready var mesh = $MeshInstance3D
@onready var ray = $"Bullet Raycast"
# @onready var particles = $GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ray.enabled = true
	mesh.visible = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	ray.force_raycast_update()
	if ray.is_colliding():
		print (ray.get_collider().name)
		if ray.get_collider().name == "secondplayer" or ray.get_collider().name == "firstplayer":
			$AudioStreamPlayer3D.play()
			ray.get_collider().hit(2)
		await get_tree().create_timer(1.0).timeout
		queue_free()


func _on_timer_timeout() -> void:
	queue_free()
