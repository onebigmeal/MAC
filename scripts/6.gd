extends CSGBox3D

const MAX_DISPLACE = 10
const CHANGE = 0.05
var back = false
var geez
@onready var mover = $"."
var original
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original = mover.get_position()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	geez = mover.get_position().x
	if geez == original.x or geez - original.x > MAX_DISPLACE:
		back = !back
	if back:
		mover.position.x += CHANGE
	elif !back:
		mover.position.x -= CHANGE
	
	
