extends Node3D

@onready var morse_antenna: Node3D = $MorseAntenna
@onready var morse_input: Node3D = $MorseInput
@onready var info_screen: Node3D = $InfoScreen
@onready var book: Node3D = $Book

@onready var start_container: PanelContainer = %StartContainer
@onready var night_title: Label = %NightTitle
@onready var night_instructions: Label = %NightInstructions
@onready var start_night_button: Button = %StartNightButton

@onready var wait_timer: Timer = $WaitTimer

@onready var main_ui: MarginContainer = $CanvasLayer/MainUI
@onready var options_menu: PanelContainer = $CanvasLayer/OptionsMenu

@onready var night_name: Label = %NightNumber
@onready var mission_text: Label = %MissionText


var calibration_words = [
	["UP", "EX", "OK"],
	["SOS", "MAP", "JAM"],
	["GAME", "GMTK", "LOOP"]
]

var coordinates = {
	"1B": "PORT",
	"1D": "GATE",
	"3A": "ISLE",
	"4D": "LAKE",
}

var boat = {
	"message": "",
	"type": "", # Calibration, GPS, Telephone
	"answer": "",
}

var nights_data = [
	{
		"name": "Night 0",
		"mission": "Calibrate the system by reproducing and confirming the transmission loops.\nCheck your book for more information.\n",
		"start_instructions": """Before you begin, you should calibrate your machinery.
			Listen carefully to the looped transmissions and try to reproduce the morse message to verify its content.

			Press or hold [SPACE] to send a signal.
			Wait for pauses between letters.
			Use [BACKSPACE] to delete characters.
			When you're confident with your answer, press [ENTER] to submit it.

			At any time, you may check your book for more notes and references.""",
		"task": "CONFIRM TRANSMISSIONS",
		"task_threshold": 3,
	}, 
		{
		"name": "Night 1",
		"mission": "Use your GPS system to relay the destination coordinates to the boats.\nCheck your book for the references.\n",
		"start_instructions": """Help the boats navigate by relaying their destination coordinates.
			Listen carefully to the looped transmission to identify the 4-letter destination code.

			Use your book to look up the corresponding coordinates.
			Then, transmit them using the GPS system.

			You may choose to verify the destination with the boat before sending — or trust your instincts with a half-solved message.

			At any time, you can check your book for notes and reference material.""",
		"task": "SEND COORDINATES",
		"task_threshold": 4,
	}
]

var score = 0
var night := 0
var lost_boats = 0


func _ready() -> void:
	wait_timer.wait_time = MorseTranslator.CLK_TIME * 10
	options_menu.visible = false
	main_ui.visible = true

	morse_antenna.stop_encoding()
	morse_input.is_ready = false
	morse_input.reset_input()

	prepare_night()


func get_new_boat() -> void:
	"""
	Creates a new boat with a random course and legitimacy.
	"""
	morse_antenna.stop_encoding()
	morse_input.reset_input()

	match night:
		0:
			boat.type = "Calibration"
			boat.message = calibration_words[score][randi() % calibration_words[score].size()]
			boat.answer = boat.message

		1:
			boat.type = "GPS"

			var keys = coordinates.keys()
			boat.answer = keys[randi() % keys.size()]
			boat.message = coordinates[boat.answer]
		_:
			boat.type = "GPS"

			var keys = coordinates.keys()
			boat.answer = keys[randi() % keys.size()]
			boat.message = coordinates[boat.answer]

	wait_timer.start()
	

func check_word(input: String) -> void:
	var status: String

	if input == boat.message:
		status = "Message confirmed!"

		if boat.type == "Calibration" and boat.answer == input:
			score += 1
			info_screen.update_score(score, nights_data[night]["task_threshold"], nights_data[night]["task"])

			mission_text.text = nights_data[night]["mission"] + "\nCurrent calibration: " + str(score + 2) + " letters"

			if score >= nights_data[night]["task_threshold"]:
				finish_night()
			else:
				get_new_boat()

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
		lost_boats += 1
	
	info_screen.update_score(score, nights_data[night]["task_threshold"], nights_data[night]["task"])
	info_screen.show_status(status)
	get_new_boat()


func prepare_night() -> void:
	"""
	NIGHT 0
	- Calibrar sistema
	- Verificar mensagens
	- Ensinar uso do Morse

	NIGHT 1
	- Sistema de GPS
	- Recebe um destino e precisa informar as coordenadas no gps
	- Ensinar interação com itens na mesa

	NIGHT 3
	- Sistema de telefone
	- Recebe uma mensagem e precisa informar a organização correta
	"""
	night_name.text = nights_data[night]["name"]
	mission_text.text = nights_data[night]["mission"]

	if night == 0:
		mission_text.text += "\nCurrent calibration: " + str(score + 2) + " letters"

	night_title.text = nights_data[night]["name"]
	night_instructions.text = nights_data[night]["start_instructions"]
	
	score = 0
	info_screen.update_score(score, nights_data[night]["task_threshold"], nights_data[night]["task"])

	start_container.visible = true
	start_night_button.grab_focus()
	main_ui.visible = false


func finish_night() -> void:
	morse_antenna.stop_encoding()
	morse_input.reset_input()
	morse_input.is_ready = false

	night += 1
	book.unlock_page(night)
	prepare_night()


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


func _on_start_night_button_pressed() -> void:
	morse_input.is_ready = true
	get_new_boat()
	start_container.visible = false
	main_ui.visible = true
