extends StaticBody3D
@onready var hitbox = $Hitbox
@onready var hitcooldown = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_hitbox_area_entered(area: Area3D) -> void:
	print("uncooler")
	if hitbox.monitoring == true:
		print("uncool")
		if area.name == "secondplayer":
			print("cool")
		hitcooldown = true


func _on_hitbox_area_exited(area: Area3D) -> void:
	pass # Replace with function body.
