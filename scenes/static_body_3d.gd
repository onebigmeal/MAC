extends StaticBody3D
@onready var hitbox = $Hitbox
@onready var hitcooldown = false
signal apply_damage
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_hitbox_body_entered(body: Node3D) -> void:
	if hitbox.monitoring == true and hitcooldown == false:
		if body.name == "secondplayer":
			apply_damage.emit()
			hitcooldown = true
		hitcooldown = false
