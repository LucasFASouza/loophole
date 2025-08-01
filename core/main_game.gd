extends Node3D

var coordinates = {
	"1B": "RIVER",
	"1D": "PORT",
	"3A": "COAST",
	"4D": "LIGHT",
}

var boat = {
	"message": "",
	"type": "GPS", # GPS, Telephone
	"answer": "",
}

@onready var morse_antenna: Node3D = $MorseAntenna
@onready var morse_input: Node3D = $MorseInput
@onready var info_screen: Node3D = $InfoScreen

@onready var main_ui: MarginContainer = $CanvasLayer/MainUI
@onready var options_menu: PanelContainer = $CanvasLayer/OptionsMenu

@onready var wait_timer: Timer = $WaitTimer

var score := 0 
var night := 0


func _ready() -> void:
	wait_timer.wait_time = MorseTranslator.CLK_TIME * 10
	options_menu.visible = false
	main_ui.visible = true

	get_new_boat()


func get_new_boat() -> void:
	"""
	Creates a new boat with a random course and legitimacy.
	"""
	# Suponhetamos que seria escolhido um dos sistemas; nesse caso o de coordenadas GPS
	var keys = coordinates.keys()
	boat.answer = keys[randi() % keys.size()]
	boat.message = coordinates[boat.answer]

	morse_antenna.stop_encoding()
	morse_input.reset_input()

	wait_timer.start()
	

func check_word(input: String) -> void:
	var status: String

	print("Checking word: ", input)
	print("Boat message: ", boat.message)

	if input == boat.message:
		status = "Message confirmed!"
	elif input in boat.message:
		status = "That part checks out..."
	else:
		status = "Incorrect message :/"
	
	info_screen.show_status(status)


func _send_answer(input: String) -> void:
	var status: String

	var correct_direction: bool = input.to_upper().replace("?", "") == boat.answer

	if correct_direction:
		status = "Correct!"
		score += 1
	else:
		status = "Boat lost :("
		score -= 1
	
	info_screen.update_score(score)
	info_screen.show_status(status)
	get_new_boat()


func _on_pause_pressed() -> void:
	options_menu.visible = true
	main_ui.visible = false
	get_tree().paused = true


func _on_options_menu_close_options() -> void:
	options_menu.visible = false
	main_ui.visible = true
	get_tree().paused = false


func _on_wait_timer_timeout() -> void:
	info_screen.show_status("INCOMING TRANSMISSION")
	morse_antenna.start_encoding(boat.message)
