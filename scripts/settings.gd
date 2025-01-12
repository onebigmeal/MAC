extends Control

@onready var volume = $MarginContainer/VBoxContainer/Volume
@onready var csens = $MarginContainer/VBoxContainer/Controller_Sensitivity
@onready var fov = $MarginContainer/VBoxContainer/FOV

func _ready() -> void:
	volume.value = Global.volume
	csens.value = Global.CONTROLLER_SENSITIVITY
	fov.value = Global.BASE_FOV
	
func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0,value)
	Global.volume = volume.value


func _on_mouse_sensitivity_value_changed(value: float) -> void:
	Global.CONTROLLER_SENSITIVITY = value


func _on_fov_value_changed(value: float) -> void:
	Global.BASE_FOV = value



func _on_mute_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioServer.set_bus_volume_db(0,-999)
	else:
		AudioServer.set_bus_volume_db(0,Global.volume)


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
