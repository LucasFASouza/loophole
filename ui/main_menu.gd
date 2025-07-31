extends Node3D

@onready var morse: Label3D = %Morse
@onready var morse_encoder: Node3D = $MorseEncoder

func _ready() -> void:
	morse_encoder.message = "SOS"
	morse_encoder.start_encoding()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://gameplay_loop/main_game.tscn")
