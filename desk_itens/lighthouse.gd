extends Node3D

@onready var lamp = $Lamp

var max_rotation: float = 45.0
var rotation_duration: float = 12.0
var tween: Tween

func _ready() -> void:
	start_lamp_rotation()

func start_lamp_rotation() -> void:
	tween = create_tween()
	tween.set_loops()
	
	tween.tween_method(set_lamp_rotation, -max_rotation, max_rotation, rotation_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_method(set_lamp_rotation, max_rotation, -max_rotation, rotation_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func set_lamp_rotation(angle: float) -> void:
	lamp.rotation.y = deg_to_rad(angle)
