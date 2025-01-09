extends Node3D

const SPEED = 150

@onready var mesh = $MeshInstance3D
@onready var ray = $"Bullet Raycast"
@onready var particles = $GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mesh.visible = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	if ray.is_colliding():
		if ray.get_collider().is_in_group("enemy"):
			ray.get_collider().hit(0.01)
		await get_tree().create_timer(1.0).timeout
		queue_free()


func _on_timer_timeout() -> void:
	queue_free()
