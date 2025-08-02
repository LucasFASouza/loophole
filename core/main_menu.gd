extends Node3D

@onready var morse: Label3D = %Morse
@onready var morse_antenna: Node3D = $MorseAntenna
@onready var start: Button = %Start

@onready var menu_ui: MarginContainer = %MenuUI
@onready var options_menu: PanelContainer = %OptionsMenu
@onready var tutorial: PanelContainer = %Tutorial

func _ready() -> void:
	menu_ui.visible = true
	options_menu.visible = false
	tutorial.visible = false
	morse_antenna.start_encoding("SOS")
	start.grab_focus()


func _on_start_pressed() -> void:
	GameGlobals.GAME_MODE = "nights"
	get_tree().change_scene_to_file("res://core/main_game.tscn")


func _on_options_pressed() -> void:
	options_menu.visible = true
	menu_ui.visible = false


func _on_options_menu_close_options() -> void:
	options_menu.visible = false
	menu_ui.visible = true


func _on_endless_pressed() -> void:
	GameGlobals.GAME_MODE = "endless"
	get_tree().change_scene_to_file("res://core/main_game.tscn")


func _on_controls_pressed() -> void:
	tutorial.visible = true
	menu_ui.visible = false
	

func _on_tutorial_close_controls() -> void:
	tutorial.visible = false
	menu_ui.visible = true
