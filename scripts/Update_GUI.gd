extends Control

@onready var L_score = $L_score
@onready var R_score = $R_score
@onready var R_stamina = $rightside/right_stamina/TextureProgressBar
@onready var L_stamina = $leftside/Left_stamina/TextureProgressBar
@onready var R_health = $rightside/right_health/TextureProgressBar
@onready var L_health = $leftside/left_health/TextureProgressBar

func _process(delta: float) -> void:
	L_score.text = str(Global.L_score)
	R_score.text = str(Global.R_score)
	R_stamina.value = Global.R_stamina
	L_stamina.value = Global.L_stamina
	L_health.value = Global.L_health
	R_health.value = Global.R_health
