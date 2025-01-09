extends Control

@onready var L_score = $L_score
@onready var R_score = $R_score
@onready var L_health = $L_health
@onready var R_health = $R_health

func _process(delta: float) -> void:
	L_score.text = str(Global.L_score)
	R_score.text = str(Global.R_score)
	L_health.text = str(Global.L_health)
	R_health.text = str(Global.R_health)
	
